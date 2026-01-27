#!/bin/sh

# Exit on error
set -e

# In Xcode Cloud, the script runs from ios/ci_scripts
# Use CI_PRIMARY_REPOSITORY_PATH if available, else go up two levels
if [ -n "$CI_PRIMARY_REPOSITORY_PATH" ]; then
    PROJECT_ROOT=$CI_PRIMARY_REPOSITORY_PATH
else
    PROJECT_ROOT=$(cd ../.. && pwd)
fi

echo "Navigating to project root: $PROJECT_ROOT"
cd "$PROJECT_ROOT"

# Install Flutter using git if not already present
echo "Installing Flutter..."
if [ ! -d "$HOME/flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
fi
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

# Initialize the build settings properly for Xcode Cloud
# This ensures Generated.xcconfig and other files are fully populated
echo "Initializing Flutter iOS build..."
cd ..
flutter build ios --release --no-codesign

echo "Xcode Cloud setup completed successfully!"
exit 0
