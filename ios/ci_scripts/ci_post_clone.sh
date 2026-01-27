#!/bin/sh

# Exit on error
set -e

# The CI_WORKSPACE is the path to the git repository
# Root of the project is CI_WORKSPACE
cd $CI_WORKSPACE

# Install Flutter using git
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Check Flutter version
flutter --version

# Precache the iOS artifacts
echo "Precaching iOS artifacts..."
flutter precache --ios

# Install dependencies
echo "Installing pub dependencies..."
flutter pub get

# Install CocoaPods
echo "Installing Pods..."
cd ios
pod install

echo "Xcode Cloud setup completed successfully!"
exit 0
