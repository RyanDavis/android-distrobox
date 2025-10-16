#!/usr/bin/env bash
set -e

CONTAINER_NAME="android-dev"
IMAGE_NAME="android-dev:ndk25"

if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  echo "🚀 Building Docker image: $IMAGE_NAME..."
  docker build -t "$IMAGE_NAME" .
fi

# TODO: Test the appended --no-home to the distrobox create below.   This may break GUI access / Android Studio, but will also keep the containerized
#  Android Studio from sharing settings with the host Android Studio.   Or Android Studio settings in another dev container.

if ! DBX_CONTAINER_MANAGER="docker" distrobox list | grep -q "$CONTAINER_NAME"; then
  echo "📦 Creating distrobox: $CONTAINER_NAME..."
  DBX_CONTAINER_MANAGER="docker" distrobox create \
    -n "$CONTAINER_NAME" \
    -i "$IMAGE_NAME" \
    --no-home \
    --volume "$HOME/Android:/opt/android-sdk" \
    --volume "$(pwd):/home/dev/workspace" \
    --additional-flags "--device /dev/bus/usb --group-add plugdev"
fi

echo "🌱 Entering $CONTAINER_NAME..."
DBX_CONTAINER_MANAGER="docker" distrobox enter "$CONTAINER_NAME"
