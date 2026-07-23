# 🗺️ Graphify Setup & Visualization Guide

This guide will help you set up Graphify for the NONDOPAMINECLOCK project and visualize your codebase as an interactive knowledge graph.

## Prerequisites

- **Python 3.8+** installed
- **uv** package manager installed ([install here](https://docs.astral.sh/uv/))
- **Bash** shell (Linux, macOS, or WSL on Windows)

## Quick Start (3 Steps)

### Step 1: Make Scripts Executable

```bash
chmod +x setup-graphify.sh serve-graphify.sh
```

### Step 2: Initialize Graphify

Run the automated setup script:

```bash
./setup-graphify.sh
```

This will:
- ✅ Install the Graphify CLI via uv
- ✅ Install the GitHub Copilot skill
- ✅ Generate the initial knowledge graph

### Step 3: Start the Visualization Server

```bash
./serve-graphify.sh
```

This will:
- 📊 Start a local server on **http://localhost:8000**
- 🗺️ Display your codebase as an interactive knowledge graph
- 🔗 Show dependencies and connections between files

## What Happens

Once the server is running, you'll be able to:

1. **Explore your codebase** visually
2. **Navigate dependencies** - see how files connect
3. **Query relationships** - understand auth-to-database connections
4. **Analyze code structure** - view modules and their interactions

## Manual Steps (if needed)

If you prefer to run commands manually:

```bash
# Step 1: Install graphify CLI
uv tool install graphifyy

# Step 2: Install Copilot skill
graphify copilot install

# Step 3: Generate knowledge graph for current directory
graphify .

# Step 4: Start the visualization server
python -m graphify.serve graphify-out/graph.json
```

## Using Graphify with Copilot

After setup, you can query your codebase in Copilot:

```
/graphify what connects auth to the database?
/graphify show me the sync flow
/graphify how do tasks get stored?
```

## Stopping the Server

Press **Ctrl+C** in your terminal to stop the visualization server.

## Troubleshooting

### Issue: `graphify: command not found`

**Solution:** Reinstall with uv:
```bash
uv tool install graphifyy
```

### Issue: `graphify-out/graph.json not found`

**Solution:** Run the graph generation first:
```bash
graphify .
```

### Issue: Port 8000 already in use

**Solution:** The script will tell you. You can specify a different port:
```bash
python -m graphify.serve graphify-out/graph.json --port 8001
```

## Configuration

Your Graphify configuration is stored in `.graphify/config.toml`:

- **project_name:** NONDOPAMINECLOCK
- **description:** Free Pomodoro Timer For Android, Mac, Windows, IOS
- **analyze.enabled:** Code analysis is ON
- **visualization.enabled:** Dependency visualization is ON
- **copilot.enabled:** Copilot integration is ON

## File Ignore Patterns

Files to exclude from analysis are configured in `.graphifyignore`:

```
node_modules/
dist/
build/
.git/
__pycache__/
*.pyc
```

Edit this file to customize what Graphify analyzes.

## Next Steps

1. ✅ Run the setup
2. ✅ Start the server
3. ✅ Explore your knowledge graph at http://localhost:8000
4. ✅ Query your codebase with `/graphify` in Copilot

---

**Happy exploring! 🚀**
