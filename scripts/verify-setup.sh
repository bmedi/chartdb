#!/bin/bash

# ChartDB Fork Setup Verification Script
# Run this anytime to verify your repository is configured correctly

echo "🔍 ChartDB Fork Setup Verification"
echo "=================================="

# Check remotes
echo ""
echo "📡 Remote Configuration:"
git remote -v

echo ""
echo "🔍 Analysis:"

# Check origin
origin_url=$(git remote get-url origin 2>/dev/null)
if [[ "$origin_url" == *"bmedi/chartdb"* ]]; then
    echo "✅ Origin correctly points to your fork (bmedi/chartdb)"
else
    echo "❌ Origin does NOT point to your fork!"
    echo "   Current origin: $origin_url"
    echo "   Should be: https://github.com/bmedi/chartdb.git"
fi

# Check upstream
upstream_url=$(git remote get-url upstream 2>/dev/null)
if [[ "$upstream_url" == *"chartdb/chartdb"* ]]; then
    echo "✅ Upstream correctly points to original repo (chartdb/chartdb)"
else
    echo "❌ Upstream does NOT point to original repo!"
    echo "   Current upstream: $upstream_url"
    echo "   Should be: https://github.com/chartdb/chartdb.git"
fi

# Check pre-push hook
if [[ -x ".git/hooks/pre-push" ]]; then
    echo "✅ Pre-push hook is active and executable"
else
    echo "❌ Pre-push hook is missing or not executable"
fi

# Check current branch tracking
echo ""
echo "🌿 Current Branch Status:"
git branch -vv

echo ""
echo "📊 Summary:"
if [[ "$origin_url" == *"bmedi/chartdb"* ]] && [[ "$upstream_url" == *"chartdb/chartdb"* ]] && [[ -x ".git/hooks/pre-push" ]]; then
    echo "🎉 Your setup is PERFECT! You're safe to work on your fork."
else
    echo "⚠️  Your setup needs attention. Please fix the issues above."
fi

echo ""
echo "💡 Quick Commands:"
echo "   Push to your fork:     git push origin main"
echo "   Pull from original:    git fetch upstream && git merge upstream/main"
echo "   Check remotes:         git remote -v"
