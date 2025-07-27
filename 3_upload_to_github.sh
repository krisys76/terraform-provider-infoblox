#!/bin/bash

# Script 3: Upload GPG key and passphrase to GitHub secrets

set -e

REPO="krisys76/terraform-provider-infoblox"
GPG_PASSPHRASE="terraform-provider-prod-2026"

echo "🔄 Uploading GPG key and passphrase to GitHub secrets..."

# Check if private key file exists
if [ ! -f "/tmp/production_private_key.asc" ]; then
    echo "❌ Private key file not found at /tmp/production_private_key.asc"
    echo "💡 Please run 2_generate_gpg_key.sh first"
    exit 1
fi

# Update GitHub secrets
echo "📤 Setting GPG_PRIVATE_KEY secret..."
gh secret set GPG_PRIVATE_KEY -R "$REPO" < /tmp/production_private_key.asc

echo "📤 Setting PASSPHRASE secret..."
gh secret set PASSPHRASE -R "$REPO" -b "$GPG_PASSPHRASE"

# Verify secrets were set
echo "🔍 Verifying GitHub secrets..."
gh secret list -R "$REPO"

# Clean up the private key file
echo "🧹 Cleaning up temporary files..."
rm -f /tmp/production_private_key.asc

echo ""
echo "✅ GitHub secrets updated successfully!"
echo "📋 Summary:"
echo "   Repository: $REPO"
echo "   Secrets set: GPG_PRIVATE_KEY, PASSPHRASE"
echo ""
echo "🚀 Ready to test the release workflow!"