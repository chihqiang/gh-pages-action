#!/bin/bash
# 发布指定目录到目标分支，支持自定义CNAME和带颜色日志输出
set -euo pipefail

# === 日志函数 ===
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

# 必填环境变量
PUBLISH_DIR="${PUBLISH_DIR:?PUBLISH_DIR is required}"
GITHUB_TOKEN="${GITHUB_TOKEN:?GITHUB_TOKEN is required}"

# 可选参数及默认值
TARGET_BRANCH="${TARGET_BRANCH:-gh-pages}"
COMMIT_MESSAGE="${COMMIT_MESSAGE:-"deploy commit: $(git rev-parse HEAD)"}"
CNAME="${CNAME:-}"

# 支持外部覆盖 REPOSITORY，否则用 GITHUB_REPOSITORY
REPOSITORY="${REPOSITORY:-$GITHUB_REPOSITORY}"

# 支持外部覆盖 ORIGIN_URL，否则拼接
ORIGIN_URL="https://x-access-token:${GITHUB_TOKEN}@github.com/${REPOSITORY}.git"

step "远程仓库地址：${REPOSITORY}"
step "进入发布目录：${PUBLISH_DIR}"
cd "$PUBLISH_DIR"

step "初始化 git 仓库"
git init

if [[ -n "$CNAME" ]]; then
  step "写入 CNAME 文件：$CNAME"
  echo "$CNAME" > CNAME
fi

step "配置 git 用户信息"
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

step "添加远程仓库"
git remote add origin "$ORIGIN_URL"

step "切换或新建分支：$TARGET_BRANCH"
git checkout -b "$TARGET_BRANCH" || git checkout "$TARGET_BRANCH"

step "添加所有文件"
git add -A

step "提交更改"
if git commit -m "$COMMIT_MESSAGE"; then
  success "提交成功"
else
  warning "没有检测到文件更改，跳过提交"
fi

step "推送分支 $TARGET_BRANCH"
git push -u origin "$TARGET_BRANCH" --force

success "发布完成！"
