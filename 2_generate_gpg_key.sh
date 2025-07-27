#!/bin/bash

# Script 2: Generate new GPG key with passphrase

set -e

GPG_PASSPHRASE="terraform-provider-prod-2026"
KEY_NAME="Terraform Provider Publisher"
KEY_EMAIL="kristin.misquitta@icloud.com"

echo "🔑 Generating new GPG key with passphrase..."

# Create GPG key configuration with passphrase
echo "📝 Creating GPG key configuration..."
cat > /tmp/gpg_prod_config << EOF
%echo Generating production GPG key
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $KEY_NAME
Name-Email: $KEY_EMAIL
Expire-Date: 1y
Passphrase: $GPG_PASSPHRASE
%commit
%echo done
EOF

# Generate the GPG key
echo "🔧 Generating GPG key..."
gpg --batch --generate-key /tmp/gpg_prod_config

# Get the new key ID
echo "🔍 Getting new key ID..."
KEY_ID=$(gpg --list-secret-keys --keyid-format=long | grep -E '^sec' | head -1 | awk '{print $2}' | cut -d'/' -f2)
if [ -z "$KEY_ID" ]; then
    echo "❌ Failed to get key ID"
    exit 1
fi

# Export the private key
echo "📤 Exporting private key..."
gpg --batch --pinentry-mode loopback --passphrase "$GPG_PASSPHRASE" --armor --export-secret-keys "$KEY_ID" > /tmp/production_private_key.asc

# Verify the export worked
if [ ! -s /tmp/production_private_key.asc ]; then
    echo "❌ Failed to export private key"
    exit 1
fi

# Clean up config file
rm -f /tmp/gpg_prod_config

echo ""
echo "✅ GPG key generated successfully!"
echo "📋 Key Details:"
echo "   Key ID: $KEY_ID"
echo "   Passphrase: $GPG_PASSPHRASE"
echo "   Private key exported to: /tmp/production_private_key.asc"
echo ""
echo "🔍 Full key info:"
gpg --list-secret-keys --keyid-format=long