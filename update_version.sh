#!/bin/bash

# 디버그 모드 활성화
set -x

# 현재 버전 가져오기
CURRENT_VERSION=$(grep 'version: ' pubspec.yaml | sed 's/version: *//;s/[[:space:]]//g')
echo "Current version: $CURRENT_VERSION"

# 버전을 부분으로 나누기
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

echo "MAJOR: $MAJOR, MINOR: $MINOR, PATCH: $PATCH"

# 각 부분이 숫자인지 확인
if ! [[ "$MAJOR" =~ ^[0-9]+$ ]] || ! [[ "$MINOR" =~ ^[0-9]+$ ]] || ! [[ "$PATCH" =~ ^[0-9]+$ ]]; then
    echo "Error: 버전 값이 숫자가 아닙니다."
    exit 1
fi

# 버전 업데이트 로직
if [ "$PATCH" -eq 9 ]; then
    if [ "$MINOR" -eq 9 ]; then
        # 1.9.9 형태일 때 MAJOR 버전 증가
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
    else
        # x.x.9 형태일 때 MINOR 버전 증가
        MINOR=$((MINOR + 1))
        PATCH=0
    fi
else
    # 그 외의 경우 PATCH 버전 증가
    PATCH=$((PATCH + 1))
fi

# 새 버전 생성
NEW_VERSION="$MAJOR.$MINOR.$PATCH"

echo "New version: $NEW_VERSION"

# pubspec.yaml 파일 업데이트 (버전 앞에 공백 추가)
sed -i "s/^version:.*/version: $NEW_VERSION/" pubspec.yaml

echo "Version updated from $CURRENT_VERSION to $NEW_VERSION"

# 새 버전을 GitHub Actions 출력으로 설정
echo "new_version=$NEW_VERSION" >> $GITHUB_OUTPUT

# 디버그 모드 비활성화
set +x