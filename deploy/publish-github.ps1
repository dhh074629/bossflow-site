# 一条命令上线到 GitHub Pages。
# 用法：
#   pwsh deploy/publish-github.ps1                  # 用默认仓库名 bossflow，公开
#   pwsh deploy/publish-github.ps1 -Repo mysite     # 换个仓库名
#
# 前提：本机 gh 已登录（gh auth status 能通过），且账号有 repo + workflow 权限。

param(
  [string]$Repo = "bossflow",
  [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"
Push-Location (Split-Path $PSScriptRoot -Parent)
try {
  if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw "没找到 gh，请先安装 GitHub CLI" }
  gh auth status 2>&1 | Out-Null
  if ($LASTEXITCODE -ne 0) { throw "gh 还没登录，先跑 gh auth login" }

  if (-not (Test-Path .git)) {
    git init -b $Branch | Out-Null
    git add -A
    git commit -m "BossFlow 项目站：纯静态，零依赖" | Out-Null
  }

  $exists = $false
  gh repo view $Repo 2>&1 | Out-Null
  if ($LASTEXITCODE -eq 0) { $exists = $true }

  if ($exists) {
    if (-not (git remote)) { git remote add origin "https://github.com/$(gh api user --jq .login)/$Repo.git" }
    git push -u origin $Branch
  } else {
    gh repo create $Repo --public --source . --remote origin --push
  }

  # 打开 Pages（用 Actions 作为构建源）。已经开过会报错，忽略即可。
  $owner = gh api user --jq .login
  gh api -X POST "repos/$owner/$Repo/pages" -f "build_type=workflow" 2>&1 | Out-Null

  "仓库: https://github.com/$owner/$Repo"
  "站点: https://$owner.github.io/$Repo/  （首次部署约 1 分钟后生效）"
  "查看进度: gh run list --repo $owner/$Repo"
} finally {
  Pop-Location
}
