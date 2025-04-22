#!/bin/bash
set -euo pipefail

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m" # No Color

info()    { echo -e "${GREEN}✅${NC}  $1"; }
success() { echo -e "${GREEN}✅${NC}  $1"; }
warn()    { echo -e "${YELLOW}⚠️ ${NC}  $1"; }
error()   { echo -e "${RED}❌${NC}  $1"; }

has_intel() {

    if ! command -v vainfo &> /dev/null; then
        error "vainfo tool is not installed. Please install it to correctly detect your GPUs."
        return 1
    fi

    va_info=$(vainfo --display drm | grep VAProfileH264Main)
    if [[ -n "$va_info" ]]; then
        success "VAAPI GPU detected"
        return 0
    else
        warn "No VAAPI GPU detected"
        return 1
    fi
}
has_nvidia() {

    if ! command -v nvidia-smi &> /dev/null; then
        error "nvidia-smi tool is not installed. Please install it to correctly detect NVIDIA GPUs."
        return 1
    fi

    nvidia_info=$(nvidia-smi --query-gpu=index,name,uuid --format=csv,noheader)
    if [[ -n "$nvidia_info" ]]; then
        success "NVIDIA GPU detected"
        return 0
    else
        warn "No NVIDIA GPU detected"
        return 1
    fi
}

has_docker() {
    info "Verifying Docker installation..."
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker and try again."
        return 1
    fi

    if ! docker info &> /dev/null; then
        error "Docker is not running or current user lacks access. Please start Docker or fix permissions."
        return 1
    fi
    success "Docker is available"
    return 0
}

info "live-cmaf-transcoder auto-install"


has_docker || {
    error "Docker is not installed or not running. Please install Docker and try again."
    exit 1
}

info "Checking for GPU support..."
profile="cpu"
if has_nvidia; then
    profile="gpu"
elif has_intel; then
    profile="intel"
fi
success "Selecting profile: $profile"

info "Updating to latest version of the cmaf-list-transcoder..."
if ! curl -fsSL -o compose.yaml https://github.com/sessystems/live-cmaf-transcoder/releases/latest/download/compose.yaml; then
    error "Failed to download compose.yaml"
    exit 1
fi

success "Stopping and removing existing containers..."
docker compose --profile=all down || true

success "Pulling latest container images..."
docker compose pull

info "Starting containers using '${profile}' profile..."
export BASE_URL="http://$(ip route get 1 | awk '{print $7}')"
docker compose --profile=${profile} up -d
success "Containers started. Application is available at: ${BASE_URL}"
