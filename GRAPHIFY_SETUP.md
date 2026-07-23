# Graphify Integration Setup

This repository is now integrated with **Graphify** for code analysis and GitHub Copilot integration.

## Local Setup

To use Graphify locally, run these commands:

```bash
# Install graphify via uv
uv tool install graphifyy

# Install GitHub Copilot integration
graphify copilot install

# Run analysis on the current directory
graphify .
```

## What Graphify Does

- **Code Analysis**: Analyzes your codebase structure and dependencies
- **Visualization**: Generates dependency graphs and code structure diagrams
- **Copilot Integration**: Enhances GitHub Copilot with project-specific context

## Configuration

The Graphify configuration is stored in `.graphify/config.toml`. You can customize:
- Project name and description
- Analysis settings
- Visualization options
- Copilot integration preferences

## GitHub Actions

Graphify analysis runs automatically on:
- Every push to `master`, `main`, or `develop`
- Every pull request to these branches

Results are saved as artifacts and can be reviewed in the Actions tab.

## Ignoring Files

Files and directories to ignore are specified in `.graphifyignore`. Edit this file to customize what Graphify analyzes.

## More Information

For more details about Graphify, visit the official documentation or run:

```bash
graphify --help
```
