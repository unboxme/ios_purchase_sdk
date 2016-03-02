#!/usr/bin/env bash

# End script if one of the lines fails
set -e

# Go to root folder
cd ..

# Create needed folders if they don't exist
mkdir -p Frameworks/Static
mkdir -p Frameworks/Dynamic
mkdir -p Frameworks/Carthage

# Build static AdjustPurchaseSdk.framework
xcodebuild -target AdjustPurchaseStatic -configuration Release

# Build dynamic AdjustPurchaseSdk.framework
xcodebuild -target AdjustPurchaseSdk -configuration Release

# Build Carthage AdjustPurchaseSdk.framework
carthage build --no-skip-current

# Copy build Carthage framework to Frameworks folder
cp -R Carthage/Build/iOS/* Frameworks/Carthage/
