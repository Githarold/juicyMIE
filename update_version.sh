#!/bin/bash

CURRENT_VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}' | tr -d "'")

IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

if [ "$MINOR" -eq 9 ] && [ "$PATCH" -eq 9 ]; then
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
elif [ "$PATCH" -eq 9 ]; then
    MINOR=$((MINOR + 1))
    PATCH=0
else
    PATCH=$((PATCH + 1))
fi

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

sed -i "s/^version: .*/version: '$NEW_VERSION'/" pubspec.yaml

echo "Version updated from $CURRENT_VERSION to $NEW_VERSION"

echo "::set-output name=new_version::$NEW_VERSION"
