#!/bin/bash

# Script 1: Delete all existing GPG keys

set -e

echo "🧹 Deleting all existing GPG keys..."

# Check if there are any keys first
if ! gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep -q "sec"; then
    echo "✅ No GPG keys found to delete"
    exit 0
fi

echo "🔍 Found existing keys:"
gpg --list-secret-keys --keyid-format=long

# Get all key fingerprints (full 40-char fingerprints) and delete them
gpg --list-secret-keys --with-colons --fingerprint | grep '^fpr:' | cut -d: -f10 | while read fingerprint; do
    if [ ! -z "$fingerprint" ]; then
        echo "Deleting key with full fingerprint: $fingerprint"
        gpg --batch --yes --delete-secret-keys "$fingerprint" 2>/dev/null || true
        gpg --batch --yes --delete-keys "$fingerprint" 2>/dev/null || true
    fi
done

# Alternative method: use key IDs if fingerprints don't work
gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep -E '^sec' | awk '{print $2}' | cut -d'/' -f2 | while read key_id; do
    if [ ! -z "$key_id" ]; then
        echo "Deleting key ID: $key_id"
        gpg --batch --yes --delete-secret-keys "$key_id" 2>/dev/null || true
        gpg --batch --yes --delete-keys "$key_id" 2>/dev/null || true
    fi
done

# Verify no keys remain
echo ""
echo "🔍 Checking remaining keys..."
if gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep -q "sec"; then
    echo "⚠️  Some keys might still exist:"
    gpg --list-secret-keys --keyid-format=long
    echo ""
    echo "💡 You may need to delete them manually with:"
    echo "   gpg --delete-secret-keys <KEY_ID>"
    echo "   gpg --delete-keys <KEY_ID>"
else
    echo "✅ All GPG keys deleted successfully"
fi

echo ""
echo "🎉 Key deletion complete!"