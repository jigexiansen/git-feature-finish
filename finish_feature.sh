#!/bin/bash

# 检查是否在项目根目录下
if [ ! -d ".git" ]; then
  echo "请在项目根目录下执行此脚本。"
  exit 1
fi

# 检查是否安装了 git flow
if ! command -v git-flow &> /dev/null; then
  echo "未检测到 git flow，请先安装 git flow。"
  echo "安装命令如下："
  echo "Mac: brew install git-flow-avh"
  echo "Ubuntu: sudo apt-get install git-flow"
  echo "CentOS: sudo yum install gitflow"
  exit 1
fi

# 检查是否安装了 wget
if ! command -v wget &> /dev/null; then
  echo "未检测到 wget，请先安装 wget。"
  echo "安装命令如下："
  echo "Mac: brew install wget"
  echo "Ubuntu: sudo apt-get install wget"
  echo "CentOS: sudo yum install wget"
  exit 1
fi

# 检查是否初始化了 git flow
if ! git config --get-regexp 'gitflow\..*' &> /dev/null; then
  echo "当前仓库未初始化 git flow，请先运行 'git flow init'。"
  exit 1
fi

# 确认远端主分支是否是 master
read -p "请确认远端主分支是否是 master (y/n): " is_master
if [ "$is_master" != "y" ]; then
  read -p "请输入远端主分支名称 (例如：main): " main_branch
else
  main_branch="master"
fi

# 提示输入分支名称
read -p "请输入分支名称 (例如：feature/branch-name): " branch_name

# 提示输入上线内容
echo "请粘贴完整的上线内容，或输入 i 后按 Enter 键开始逐项输入上线内容。"
read -p "请输入上线内容 (粘贴内容或输入 i): " input_mode

if [ "$input_mode" = "i" ]; then
  echo "请按照提示逐项输入上线内容："
  read -p "请输入上线内容标题 (例如：FS-123456-【技术优化】上线标题demo): " online_content
  read -p "请输入需求ID: " demand_id
  read -p "请输入需求地址: " demand_url
  read -p "是否有单测 (是/否): " has_unit_test
  read -p "Codereview (例如：@张翠花): " code_review
  read -p "开发人员 (例如：@王美丽): " developer
  read -p "测试人员 (例如：@高大尚): " tester

  # 生成上线内容
  release_notes="上线内容：$online_content
需求ID：$demand_id
需求地址：$demand_url
是否有单测：$has_unit_test
Codereview：$code_review
开发人员：$developer
测试人员：$tester"
else
  echo "请粘贴上线内容，然后按 Ctrl+D 结束输入："
  release_notes=$(cat)
fi

# 查询最新版本号
latest_tag=$(git describe --tags $(git rev-list --tags --max-count=1) 2>/dev/null)
if [ -z "$latest_tag" ]; then
  echo "未找到任何标签，无法获取最新版本号。"
  latest_tag="v0.0.0"
fi
echo "最新版本号: $latest_tag"

# 计算下一个版本号的通用函数
increment_version() {
  local version=\$1
  local IFS='.'
  local -a parts=($version)
  local carry=1
  for ((i=${#parts[@]}-1; i>=0; i--)); do
    if [[ ${parts[i]} =~ ^0[0-9]+$ ]]; then
      parts[i]=$((10#${parts[i]} + carry))
    else
      parts[i]=$((parts[i] + carry))
    fi
    if [ ${parts[i]} -lt 100 ]; then
      carry=0
      break
    else
      parts[i]=01
      carry=1
    fi
  done
  if [ $carry -eq 1 ]; then
    parts=(1 "${parts[@]}")
  fi
  echo "${parts[*]}" | tr ' ' '.'
}

# 检查并处理版本号
if [[ $latest_tag =~ ^v([0-9]+(\.[0-9]+)*)$ ]]; then
  version=${BASH_REMATCH[1]}
  next_version="v$(increment_version $version)"
else
  next_version="v1.0.0.0"
fi

echo "下一个版本号: $next_version"
read -p "确认下一个版本号是否正确 (y/n): " confirm_version

if [ "$confirm_version" != "y" ]; then
  read -p "请输入正确的下一个版本号 (例如：v1.0.0.01): " next_version
fi

# 确保分支最新
echo "正在确保 develop 和 $main_branch 分支是最新的..."
git checkout develop
git pull origin develop
git checkout $main_branch
git pull origin $main_branch
echo "develop 和 $main_branch 分支已更新。"

# 确认当前 Feature 分支
echo "正在切换到指定的 Feature 分支: $branch_name..."
git branch
git checkout $branch_name
echo "当前分支: $(git branch --show-current)"

# 确认 Feature 分支是否正确
read -p "确认 Feature 分支是否正确 (y/n): " confirm_branch
if [ "$confirm_branch" != "y" ]; then
  read -p "请输入要完成的 Feature 分支名称: " branch_name
  git checkout $branch_name
  echo "切换到指定的 Feature 分支: $branch_name"
fi

# 完成 Feature 分支
feature_branch=$(echo $branch_name | sed 's/^feature\///')
echo "正在完成 Feature 分支: $feature_branch..."
if ! git flow feature finish $feature_branch; then
  echo "完成 Feature 分支时出错，请检查错误信息。"
  exit 1
fi
echo "Feature 分支 $feature_branch 已完成并合并到 develop 分支。"

# 推送 develop 分支
echo "正在推送 develop 分支..."
if ! git push origin develop; then
  echo "推送 develop 分支时出错，请检查错误信息。"
  exit 1
fi
echo "develop 分支已推送到远程仓库。"

# 创建 Release 分支
echo "正在创建 Release 分支: $next_version..."
if ! git flow release start $next_version; then
  echo "创建 Release 分支时出错，请检查错误信息。"
  exit 1
fi
echo "Release 分支 $next_version 已创建。"

# 完成 Release 分支
echo "正在完成 Release 分支: $next_version..."
if ! git flow release finish $next_version; then
  echo "完成 Release 分支时出错，请检查错误信息。"
  exit 1
fi
echo "Release 分支 $next_version 已完成并合并到 $main_branch 和 develop 分支。"

# 输入上线内容并打标签
echo "正在输入上线内容并打标签..."
if ! git tag -a $next_version -m "$release_notes"; then
  echo "打标签时出错，请检查错误信息。"
  exit 1
fi
echo "上线内容已输入并打标签。"

# 提示完成
echo "Release 分支的创建和合并已完成。"

# 提示用户执行推送命令
echo "请执行以下命令推送 develop 和 $main_branch 分支，以及新标签："
echo "推送 develop 分支: git push origin develop"
echo "推送 $main_branch 分支: git push origin $main_branch"
echo "推送新标签: git push origin --tags"
