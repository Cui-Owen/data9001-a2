#!/usr/bin/env bash
set -euo pipefail

OWNER="Cui-Owen"
REPO="data9001-a2"
FULL_NAME="$OWNER/$REPO"
PAGES_URL="https://cui-owen.github.io/data9001-a2/"

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI is required. Install gh first."
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated."
  echo "Run: gh auth login -h github.com"
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Run this script from the a2_reference_site git repository."
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree has uncommitted changes. Commit them before publishing."
  git status --short
  exit 1
fi

git branch -M main

if gh repo view "$FULL_NAME" >/dev/null 2>&1; then
  echo "Repository $FULL_NAME already exists."
else
  echo "Creating public repository $FULL_NAME."
  gh repo create "$FULL_NAME" --public --description "DATA9001 Assignment 2 reference solution site"
fi

REMOTE_URL="https://github.com/$FULL_NAME.git"
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REMOTE_URL"
else
  git remote add origin "$REMOTE_URL"
fi

git push -u origin main

if gh api "repos/$FULL_NAME/pages" >/dev/null 2>&1; then
  gh api --method PUT "repos/$FULL_NAME/pages" \
    -f "source[branch]=main" \
    -f "source[path]=/"
else
  gh api --method POST "repos/$FULL_NAME/pages" \
    -f "source[branch]=main" \
    -f "source[path]=/"
fi

echo "Published site target: $PAGES_URL"
echo "GitHub Pages can take a minute or two to become available."
