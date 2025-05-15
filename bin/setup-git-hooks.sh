#!/bin/bash

# Script to install git hooks for the WordPress Gmail CLI project

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Setting up Git hooks for WordPress Gmail CLI...${NC}"

# Check if we're in the right directory by looking for key files
if [ ! -d ".git" ] || [ ! -d "bin" ]; then
  echo -e "${RED}Error: This script must be run from the root of the wordpress-gmail-cli repository.${NC}"
  exit 1
fi

# Create the .githooks directory if it doesn't exist
if [ ! -d ".githooks" ]; then
  mkdir -p .githooks
  echo -e "${GREEN}Created .githooks directory${NC}"
fi

# Configure git to use the custom hooks directory
git config core.hooksPath .githooks
echo -e "${GREEN}Configured Git to use hooks from .githooks directory${NC}"

# Make all hooks in .githooks executable
chmod +x .githooks/*
echo -e "${GREEN}Made all hooks executable${NC}"

# Verify the installation
echo -e "${YELLOW}Verifying hooks installation...${NC}"
if [ "$(git config core.hooksPath)" == ".githooks" ]; then
  echo -e "${GREEN}Git hooks successfully installed!${NC}"
else
  echo -e "${RED}Something went wrong. Git hooks are not properly configured.${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}Git hooks have been set up successfully.${NC}"
echo -e "${YELLOW}These hooks will help catch common issues before they're committed to the repository:${NC}"
echo -e "  • Missing newlines at the end of PHP files"
echo -e "  • PHP syntax errors"
echo -e "  • PSR-12 compliance issues"
echo -e "  • CodeQL configuration problems in GitHub Actions workflows"
echo -e "  • Shell script executable permissions"
echo ""
echo -e "${YELLOW}All team members should run this script after cloning the repository:${NC}"
echo -e "  ./bin/setup-git-hooks.sh"
exit 0
