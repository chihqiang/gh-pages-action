#!/bin/bash
set -euo pipefail

# === Logging functions ===
color_echo() {
  local color_code=$1; shift
  echo -e "\033[${color_code}m[$(date +'%H:%M:%S')] $@\033[0m"
}
info()    { color_echo "1;34" "ℹ️  $@"; }
success() { color_echo "1;32" "✅ $@"; }
warning() { color_echo "1;33" "⚠️  $@"; }
error()   { color_echo "1;31" "❌ $@"; }
step()    { color_echo "1;36" "🚀 $@"; }
divider() { echo -e "\033[1;30m--------------------------------------------------\033[0m"; }

# Required environment variables
PUBLISH_DIR="${PUBLISH_DIR:?PUBLISH_DIR is required}"
GITHUB_TOKEN="${GITHUB_TOKEN:?GITHUB_TOKEN is required}"

# Optional variables with defaults
TARGET_BRANCH="${TARGET_BRANCH:-gh-pages}"

CURRENT_HASH=$(git rev-parse HEAD 2>/dev/null || date +'%Y%m%d%H%M%S%3N')
COMMIT_MESSAGE="${COMMIT_MESSAGE:-"deploy commit: ${CURRENT_HASH}"}"
CNAME="${CNAME:-}"

# Allow overriding REPOSITORY, fallback to GITHUB_REPOSITORY
REPOSITORY="${REPOSITORY:-$GITHUB_REPOSITORY}"

# Allow overriding ORIGIN_URL, fallback to token URL
ORIGIN_URL="https://x-access-token:${GITHUB_TOKEN}@github.com/${REPOSITORY}.git"

step "Remote repository: ${REPOSITORY}"
step "Entering publish directory: ${PUBLISH_DIR}"
cd "$PUBLISH_DIR"

step "Initializing git repository"
git init

if [[ -n "$CNAME" ]]; then
  step "Writing CNAME file: $CNAME"
  echo "$CNAME" > CNAME
fi

step "Setting git user config"
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

step "Adding remote origin"
git remote add origin "$ORIGIN_URL"

step "Checking out or creating branch: $TARGET_BRANCH"
git checkout -b "$TARGET_BRANCH" || git checkout "$TARGET_BRANCH"

step "Staging all files"
git add -A

step "Committing changes"
if git commit -m "$COMMIT_MESSAGE"; then
  success "Commit successful"
else
  warning "No changes detected, skipping commit"
fi

step "Pushing to branch $TARGET_BRANCH"
git push -u origin "$TARGET_BRANCH" --force

success "Deployment complete!"
