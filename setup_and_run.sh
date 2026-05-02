#!/bin/bash

# Lazarus Repo Eval Kit - Setup and Run Script
# This script helps you set up and run the repository evaluator

set -e

echo "=========================================="
echo "  Lazarus Repo Eval Kit - Setup Script"
echo "=========================================="
echo ""

# Check for Python
echo "Checking for Python..."
if ! command -v python &> /dev/null && ! command -v python3 &> /dev/null; then
    echo "❌ Python is not installed. Please install Python 3.6+ first."
    exit 1
fi
PYTHON_CMD=$(command -v python3 || command -v python)
echo "✅ Python found: $PYTHON_CMD"

# Check for Node.js (needed for TypeScript/JavaScript repos)
echo "Checking for Node.js..."
if ! command -v node &> /dev/null; then
    echo "⚠️  Node.js not found. You'll need it to evaluate JS/TS repos like Molly-Core."
    echo "   Install from: https://nodejs.org/"
else
    echo "✅ Node.js found: $(node --version)"
fi

# Check for npm
echo "Checking for npm..."
if ! command -v npm &> /dev/null; then
    echo "⚠️  npm not found."
else
    echo "✅ npm found: $(npm --version)"
fi

# Install Python dependencies
echo ""
echo "Installing Python dependencies..."
$PYTHON_CMD -m pip install -r requirements.txt
echo "✅ Dependencies installed"

# Set up .env file if it doesn't exist
echo ""
if [ ! -f .env ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
    echo "✅ .env file created"
    echo ""
    echo "⚠️  IMPORTANT: You need to edit .env and add your API keys!"
    echo "   Open .env in a text editor and add:"
    echo "   - LLM_PROVIDER=openai (or anthropic, or google)"
    echo "   - OPENAI_API_KEY=sk-your-key-here (or the matching provider key)"
    echo ""
else
    echo "✅ .env file already exists"
fi

# Check for GitHub token
echo ""
if [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  GITHUB_TOKEN environment variable not set."
    echo "   To set it, run: export GITHUB_TOKEN=your_token_here"
    echo "   Get a token from: https://github.com/settings/tokens"
    echo ""
    read -p "Enter your GitHub token (or press Enter to skip): " input_token
    if [ -n "$input_token" ]; then
        export GITHUB_TOKEN="$input_token"
        echo "✅ GitHub token set for this session"
    fi
else
    echo "✅ GitHub token is set"
fi

# Ask which repo to evaluate
echo ""
echo "=========================================="
echo "  Ready to Run Evaluation"
echo "=========================================="
echo ""

read -p "Enter the repository to evaluate (e.g., Molly-agi/Molly-Core): " REPO_TO_EVAL

if [ -z "$REPO_TO_EVAL" ]; then
    REPO_TO_EVAL="Molly-agi/Molly-Core"
    echo "Using default: $REPO_TO_EVAL"
fi

echo ""
echo "Running evaluation on $REPO_TO_EVAL..."
echo ""

$PYTHON_CMD repo_evaluator.py "$REPO_TO_EVAL" --token "$GITHUB_TOKEN"

echo ""
echo "=========================================="
echo "  Evaluation Complete!"
echo "=========================================="