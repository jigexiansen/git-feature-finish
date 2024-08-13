1. 确保分支最新

首先，确保你的 develop 和 master 分支是最新的。

```sh
# 更新 develop 分支
git checkout develop
git pull origin develop

# 更新 master 分支
git checkout master
git pull origin master
```

2. 确认当前 Feature 分支

查看当前分支，然后切换到需要完成的 feature 分支。

```sh
# 查看当前分支
git branch

# 切换到需要完成的 feature 分支
git checkout <feature-branch-name>
# 例如：git checkout feature/branch-name
```

3. 完成 Feature 分支

使用 Git Flow 完成 Feature 分支，这会将 Feature 分支合并到 develop 分支，并删除 Feature 分支。

```sh
# 完成 Feature 分支
git flow feature finish <branch-name>
# 例如：git flow feature finish branch-name
```

4. 推送 develop 分支

将 develop 分支推送到远程仓库。

```sh
# 推送 develop 分支
git push origin develop
```

5. 查询最新版本号

查询当前最新的版本号。

```sh
# 获取最新的标签
latest_tag=$(git describe --tags $(git rev-list --tags --max-count=1))
echo "最新版本号: $latest_tag"
```

6. 计算下一个版本号

三段版本号示例

```sh
bash -c '
latest_tag='"$latest_tag"'
if [[ $latest_tag =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  major=${BASH_REMATCH[1]}
  minor=${BASH_REMATCH[2]}
  patch=${BASH_REMATCH[3]}
  
  # 递增补丁版本号
  next_patch=$((patch + 1))
  next_version="v$major.$minor.$next_patch"
  
  echo "下一个版本号: $next_version"
else
  echo "无法解析版本号: $latest_tag"
  exit 1
fi
'
```

假设最新的版本号是 v0.0.25，那么下一个版本号可以是 v0.0.26。

四段版本号示例

```sh
bash -c '
latest_tag='"$latest_tag"'
if [[ $latest_tag =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  major=${BASH_REMATCH[1]}
  minor=${BASH_REMATCH[2]}
  patch=${BASH_REMATCH[3]}
  subpatch=${BASH_REMATCH[4]}
  
  # 递增补丁版本号
  next_subpatch=$((subpatch + 1))
  next_patch=$patch
  
  # 如果补丁版本号达到 100，则递增次补丁版本号
  if [ $next_subpatch -eq 100 ]; then
    next_subpatch=1
    next_patch=$((patch + 1))
  fi
  
  next_version="v$major.$minor.$(printf "%02d" $next_patch).$(printf "%02d" $next_subpatch)"
  
  echo "下一个版本号: $next_version"
else
  echo "无法解析版本号: $latest_tag"
  exit 1
fi
'
```

假设最新的版本号是 v1.0.0.99，那么下一个版本号可以是 v1.0.01.01。

7. 创建 Release 分支

使用 Git Flow 创建一个 Release 分支。

```sh
# 创建 Release 分支
git flow release start $next_version
# 例如：git flow release start v0.0.26
# 或者：git flow release start v1.0.01.01
```

8. 完成 Release 分支

使用 Git Flow 完成 Release 分支，这会将 Release 分支合并到 master 和 develop 分支，并打上标签。

```sh
# 完成 Release 分支
git flow release finish $next_version
# 例如：git flow release finish v0.0.26
# 或者：git flow release finish v1.0.01.01
```

在完成 Release 分支的过程中，Git Flow 会提示你输入标签信息。你可以按照以下格式输入上线内容：

```markdown
上线内容：FS-4417513-【技术优化】线上error日志优化
需求ID：4417513
需求地址：[需求] 【技术优化】线上error日志优化
是否有单测：否
Codereview：@xxx
开发人员：@xxx
测试人员：@xxx
```

输入完上线内容后保存退出，然后还需要在退出后再次输入一次上线内容，保存并退出。

9. 推送 develop 分支和 master 分支

将 develop 和 master 分支推送到远程仓库。

```sh
# 推送 develop 分支
git push origin develop

# 推送 master 分支
git push origin master
```

10. 推送标签

将标签推送到远程仓库。

```sh
# 推送标签
git push origin --tags
```

完整流程总结

1. 确保分支最新

```sh
# 更新 develop 分支
git checkout develop
git pull origin develop

# 更新 master 分支
git checkout master
git pull origin master
```

2. 确认当前 Feature 分支

```sh
# 查看当前分支
git branch

# 切换到需要完成的 feature 分支
git checkout <feature-branch-name>
# 例如：git checkout feature/branch-name
```

3. 完成 Feature 分支

```sh
# 完成 Feature 分支
git flow feature finish <branch-name>
# 例如：git flow feature finish branch-name
```

4. 推送 develop 分支

```sh
# 推送 develop 分支
git push origin develop
```

5. 查询最新版本号

```sh
# 获取最新的标签
latest_tag=$(git describe --tags $(git rev-list --tags --max-count=1))
echo "最新版本号: $latest_tag"
```

6. 计算下一个版本号

三段版本号示例

```sh
bash -c '
latest_tag='"$latest_tag"'
if [[ $latest_tag =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  major=${BASH_REMATCH[1]}
  minor=${BASH_REMATCH[2]}
  patch=${BASH_REMATCH[3]}
  
  # 递增补丁版本号
  next_patch=$((patch + 1))
  next_version="v$major.$minor.$next_patch"
  
  echo "下一个版本号: $next_version"
else
  echo "无法解析版本号: $latest_tag"
  exit 1
fi
'
```

四段版本号示例

```sh
bash -c '
latest_tag='"$latest_tag"'
if [[ $latest_tag =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  major=${BASH_REMATCH[1]}
  minor=${BASH_REMATCH[2]}
  patch=${BASH_REMATCH[3]}
  subpatch=${BASH_REMATCH[4]}
  
  # 递增补丁版本号
  next_subpatch=$((subpatch + 1))
  next_patch=$patch
  
  # 如果补丁版本号达到 100，则递增次补丁版本号
  if [ $next_subpatch -eq 100 ]; then
    next_subpatch=1
    next_patch=$((patch + 1))
  fi
  
  next_version="v$major.$minor.$(printf "%02d" $next_patch).$(printf "%02d" $next_subpatch)"
  
  echo "下一个版本号: $next_version"
else
  echo "无法解析版本号: $latest_tag"
  exit 1
fi
'
```

7. 创建 Release 分支

```sh
# 创建 Release 分支
git flow release start $next_version
# 例如：git flow release start v0.0.26
# 或者：git flow release start v1.0.01.01
```

8. 完成 Release 分支

```sh
# 完成 Release 分支
git flow release finish $next_version
# 例如：git flow release finish v0.0.26
# 或者：git flow release finish v1.0.01.01
```

在完成 Release 分支的过程中，Git Flow 会提示你输入标签信息。你可以按照以下格式输入上线内容：

```markdown
上线内容：FS-4417513-【技术优化】上线标题demo
需求ID：4417513
需求地址：[需求URL]
是否有单测：是
Codereview：@xxx
开发人员：@xxx
测试人员：@xxx
```

输入完上线内容后保存退出，然后还需要在退出后再次输入一次上线内容，保存并退出。

9. 推送 develop 分支和 master 分支

```sh
# 推送 develop 分支
git push origin develop

# 推送 master 分支
git push origin master
```

10. 推送标签

```sh
# 推送标签
git push origin --tags
```

通过以上步骤，可以确保将任何 feature 分支的代码合并到 develop 和 master 分支，并打上标签，同时确保所有相关信息都记录在标签中。
