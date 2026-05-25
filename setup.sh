#!/bin/bash
set -e

echo "🔧 Tech Pros iOS — Project Setup"
echo "================================="

# Check for Homebrew
if ! command -v brew &> /dev/null; then
  echo "❌ Homebrew not found. Install it from https://brew.sh then re-run this script."
  exit 1
fi

# Install XcodeGen if not present
if ! command -v xcodegen &> /dev/null; then
  echo "📦 Installing XcodeGen..."
  brew install xcodegen
else
  echo "✅ XcodeGen already installed"
fi

# Generate Xcode project
echo "🏗  Generating Xcode project..."
xcodegen generate

echo ""
echo "✅ Done! Open TechPros.xcodeproj in Xcode."
echo ""
echo "⚠️  Before building, update TechPros/Config.swift with your Supabase credentials:"
echo "   - supabaseURL   → found in Supabase Dashboard → Settings → API"
echo "   - supabaseAnonKey → found in Supabase Dashboard → Settings → API"
echo ""
echo "🚀 Then hit Run in Xcode and you're live!"
