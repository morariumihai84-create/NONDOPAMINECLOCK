#!/bin/bash
# Graphify Serve Script for NONDOPAMINECLOCK

echo "🚀 Starting Graphify knowledge graph server..."
echo ""

# Check if graphify-out/graph.json exists
if [ ! -f "graphify-out/graph.json" ]; then
  echo "❌ Error: graphify-out/graph.json not found"
  echo ""
  echo "Please run the following commands first:"
  echo "  1. uv tool install graphifyy"
  echo "  2. graphify copilot install"
  echo "  3. graphify ."
  echo ""
  exit 1
fi

echo "📊 Graph file found: graphify-out/graph.json"
echo ""
echo "Starting server on http://localhost:8000"
echo "Press Ctrl+C to stop the server"
echo ""

# Run the graphify server
python -m graphify.serve graphify-out/graph.json
