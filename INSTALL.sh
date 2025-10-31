#!/bin/bash

# Script to install Jekyll and dependencies for the personal website
# تثبيت Jekyll والمكتبات المطلوبة للموقع الشخصي

echo "=================================="
echo "Jekyll Website Setup Script"
echo "=================================="
echo ""

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "⚠️  This script is designed for Linux systems"
    echo "For other systems, please refer to SETUP.md"
    exit 1
fi

# Update system
echo "📦 Updating system packages..."
sudo apt update

# Install Ruby and build tools
echo "💎 Installing Ruby and build tools..."
sudo apt install -y ruby-full build-essential zlib1g-dev

# Check Ruby installation
if ! command -v ruby &> /dev/null; then
    echo "❌ Ruby installation failed"
    exit 1
fi

echo "✅ Ruby installed: $(ruby --version)"

# Setup gem environment
echo "🔧 Setting up Ruby gems environment..."
if ! grep -q "GEM_HOME" ~/.bashrc; then
    echo '' >> ~/.bashrc
    echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
    echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
    echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
    echo "✅ Added gem paths to ~/.bashrc"
else
    echo "ℹ️  Gem paths already configured in ~/.bashrc"
fi

# Source bashrc
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

# Install Jekyll and Bundler
echo "📚 Installing Jekyll and Bundler..."
gem install jekyll bundler

# Check Jekyll installation
if ! command -v jekyll &> /dev/null; then
    echo "❌ Jekyll installation failed"
    exit 1
fi

echo "✅ Jekyll installed: $(jekyll --version)"

# Install project dependencies
echo "📦 Installing project dependencies..."
bundle install

if [ $? -eq 0 ]; then
    echo ""
    echo "=================================="
    echo "✅ Installation completed successfully!"
    echo "=================================="
    echo ""
    echo "To start the development server, run:"
    echo "  bundle exec jekyll serve"
    echo ""
    echo "Or with live reload:"
    echo "  bundle exec jekyll serve --livereload"
    echo ""
    echo "The site will be available at: http://localhost:4000"
    echo ""
    echo "⚠️  Important: Restart your terminal or run:"
    echo "  source ~/.bashrc"
    echo ""
else
    echo ""
    echo "❌ Installation failed"
    echo "Please check the error messages above"
    echo "For manual installation, refer to SETUP.md"
    exit 1
fi
