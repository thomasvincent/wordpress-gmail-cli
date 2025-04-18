#!/bin/bash

# test-docker.sh
# A script to test the Docker image functionality
# This script is used by GitHub Actions to ensure the Docker image works properly

set -e

# shellcheck disable=SC2034 # Used in string formatting for logs
BOLD="\033[1m"
# Text formatting
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

# Function to log messages
log() {
  local level=$1
  local message=$2
  local color=${RESET}

  case ${level} in
    "INFO") color=${BLUE} ;;
    "SUCCESS") color=${GREEN} ;;
    "WARNING") color=${YELLOW} ;;
    "ERROR") color=${RED} ;;
    *)
      # Use default color for unknown levels, log the level itself
      echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RESET}${level}${RESET}: ${message}" >&2
      return
      ;;
  esac

  echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${color}${level}${RESET}: ${message}"
}

# Function to test Docker image
test_docker_image() {
  local image_name=$1
  local version

  log "INFO" "Testing Docker image: ${image_name}"

  # Check if Docker is installed
  if ! command -v docker &>/dev/null; then
    log "ERROR" "Docker is not installed"
    return 1
  fi

  # Check if the image exists
  if ! docker image inspect "${image_name}" &>/dev/null; then
    log "ERROR" "Docker image not found: ${image_name}"
    return 1
  fi

  # Test 1: Basic help command
  log "INFO" "Test 1: Running help command..."
  if ! docker run --rm "${image_name}" --help; then
    log "ERROR" "Help command test failed (Exit code: $?)"
    return 1
  fi
  log "SUCCESS" "Help command test passed"

  # Test 2: Version information
  log "INFO" "Test 2: Checking version information..."
  if ! version=$(docker run --rm "${image_name}" bin/version.sh 2>/dev/null); then
    log "ERROR" "Version command test failed (Exit code: $?)"
    return 1
  fi

  # Use [[ -z ... ]] for checking empty string (more robust than -z)
  if [[ -z "${version}" ]]; then
    log "ERROR" "Version information is empty"
    return 1
  fi
  log "SUCCESS" "Version command test passed: ${version}"

  # Test 3: Check for expected files in the image
  log "INFO" "Test 3: Checking for expected files in the image..."
  # shellcheck disable=SC2086 # We want word splitting for ls arguments if any were added
  if ! docker run --rm --entrypoint ls "${image_name}" /app/bin/wordpress-gmail-cli.sh &>/dev/null; then
    log "ERROR" "Main script not found in the image"
    return 1
  fi
  log "SUCCESS" "Expected files test passed"

  log "SUCCESS" "All Docker image tests passed for: ${image_name}"
  return 0
}

# Main execution
log "INFO" "Starting Docker image tests"

# Default image name
IMAGE_NAME="wordpress-gmail-cli:test"

# Allow overriding the image name, quote $1 (Shellcheck SC2086)
if [[ $# -eq 1 ]]; then
  IMAGE_NAME="$1"
fi

# Run the tests
if test_docker_image "${IMAGE_NAME}"; then
  log "SUCCESS" "Docker image testing completed successfully"
  exit 0
else
  log "ERROR" "Docker image testing failed"
  exit 1
fi
