#!/bin/bash

# Production GPG Setup Script for Terraform Provider
# This script creates a GPG key with passphrase and configures GitHub Actions properly

set -e  # Exit on any error

REPO="krisys76/terraform-provider-infoblox"
GPG_PASSPHRASE="terraform-provider-prod-2024"
KEY_NAME="Terraform Provider Publisher"
KEY_EMAIL="kristin.misquitta@icloud.com"

echo "🔐 Setting up production GPG key with passphrase..."

# 1. Clean up existing keys
echo "🧹 Cleaning up existing GPG keys..."
gpg --list-secret-keys --keyid-format=long | grep -E '^sec' | awk '{print $2}' | cut -d'/' -f2 | while read key_id; do
    if [ ! -z "$key_id" ]; then
        echo "Deleting key: $key_id"
        gpg --batch --yes --delete-secret-keys "$key_id" 2>/dev/null || true
        gpg --batch --yes --delete-keys "$key_id" 2>/dev/null || true
    fi
done

# 2. Create GPG key configuration with passphrase
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

# 3. Generate the GPG key
echo "🔑 Generating GPG key with passphrase..."
gpg --batch --generate-key /tmp/gpg_prod_config

# 4. Get the new key ID
echo "🔍 Getting new key ID..."
KEY_ID=$(gpg --list-secret-keys --keyid-format=long | grep -E '^sec' | head -1 | awk '{print $2}' | cut -d'/' -f2)
if [ -z "$KEY_ID" ]; then
    echo "❌ Failed to get key ID"
    exit 1
fi
echo "✅ Generated key ID: $KEY_ID"

# 5. Export the private key
echo "📤 Exporting private key..."
gpg --batch --pinentry-mode loopback --passphrase "$GPG_PASSPHRASE" --armor --export-secret-keys "$KEY_ID" > /tmp/production_private_key.asc

# Verify the export worked
if [ ! -s /tmp/production_private_key.asc ]; then
    echo "❌ Failed to export private key"
    exit 1
fi

echo "✅ Private key exported successfully"

# 6. Update GitHub secrets
echo "🔄 Updating GitHub secrets..."
gh secret set GPG_PRIVATE_KEY -R "$REPO" < /tmp/production_private_key.asc
gh secret set PASSPHRASE -R "$REPO" -b "$GPG_PASSPHRASE"

# 7. Verify secrets were set
echo "🔍 Verifying GitHub secrets..."
gh secret list -R "$REPO"

echo "✅ GitHub secrets updated successfully"

# 8. Clean up temporary files
rm -f /tmp/gpg_prod_config /tmp/production_private_key.asc

echo ""
echo "🎉 Production GPG setup complete!"
echo "📋 Summary:"
echo "   Key ID: $KEY_ID"
echo "   Passphrase: $GPG_PASSPHRASE"
echo "   GitHub repo: $REPO"
echo ""
echo "🚀 The workflow should now work with the passphrase-protected key."
echo "💡 Next step: Update the GitHub Actions workflow to handle the passphrase properly."