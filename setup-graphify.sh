#!/bin/bash
# Graphify Setup Script for NONDOPAMINECLOCK

echo "🚀 Starting Graphify setup..."

# Step 1: Install graphify CLI
echo "📦 Step 1: Installing graphify CLI..."
uv tool install graphifyy

if [ $? -eq 0 ]; then
  echo "✅ graphify CLI installed successfully"
else
  echo "❌ Failed to install graphify CLI"
  exit 1
fi

# Step 2: Install Copilot skill
echo "📚 Step 2: Installing Copilot skill..."
graphify copilot install

if [ $? -eq 0 ]; then
  echo "✅ Copilot skill installed successfully"
else
  echo "❌ Failed to install Copilot skill"
  exit 1
fi

# Step 3: Generate knowledge graph
echo "🗺️  Step 3: Generating knowledge graph..."
graphify .

if [ $? -eq 0 ]; then
  echo "✅ Knowledge graph generated successfully"
else
  echo "❌ Failed to generate knowledge graph"
  exit 1
fi

echo ""
echo "🎉 Graphify setup complete!"
echo ""
echo "Your NONDOPAMINECLOCK project is now mapped into a knowledge graph."
echo "You can now use Copilot to query your codebase with /graphify"
