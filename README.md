# BossFlow 项目站

纯静态、零依赖、无需构建。三个文件加一个脚本，扔到任何静态托管上就能跑。

```
index.html        单页站点：怎么运转 / 提示词优化器 / 实测结果 / 上手 / 托管方案
styles.css        样式（深色、响应式）
app.js            只有一个功能：复制命令
.github/workflows/deploy-pages.yml   GitHub Pages 自动部署流水线
deploy/publish-github.ps1            一条命令上线
```

本地预览：直接双击 `index.html` 即可，不需要起服务器。

## 上线方案对比

本站是纯静态的，所以"交给哪家云管"其实只取决于三件事：国内访问速度、要不要绑自己的域名、愿不愿意掏钱。

| 方案 | 成本 | 国内访问 | 部署方式 | 域名备案 | 适合 |
| --- | --- | --- | --- | --- | --- |
| **Cloudflare Pages** | 免费 | 一般 | 连 Git 仓库，推送即部署 | 不需要 | 想今天上线、不折腾 |
| **GitHub Pages** | 免费 | 一般 | 本仓库已带流水线，推送即部署 | 不需要 | 代码本来就在 GitHub |
| **Vercel** | 免费额度 | 一般 | 连 Git 仓库，推送即部署 | 不需要 | 以后要加 Node 后端/API |
| **阿里云 OSS + CDN** | 几元/月起 | 好 | `ossutil sync` 或自接 CI | 绑域名必须备案 | 访问速度优先、主要面向国内 |
| **腾讯云轻量 + Coolify** | 约 50 元/月起 | 好 | 面板里点部署 | 绑域名必须备案 | 以后要在浏览器里派活、看运行记录 |

## 三种上线方式

### 一、GitHub Pages（本仓库已备好，最省事）

```powershell
pwsh deploy/publish-github.ps1
```

脚本会做四件事：初始化仓库并提交、在 GitHub 上建仓库并推送、把 Pages 切到 Actions 构建、打印站点地址。
之后每次 `git push`，流水线自动重新部署，不用再管。

### 二、Cloudflare Pages（国内访问通常比 GitHub Pages 稳一点）

1. 把本目录推到一个 Git 仓库（GitHub / GitLab 都行）。
2. 登录 Cloudflare 控制台 → Workers & Pages → Create → Pages → 连接该仓库。
3. 构建命令留空，输出目录填 `/`。之后每次推送自动部署，并自动给 HTTPS。

也可以用命令行直接上传，无需连仓库：

```powershell
npx wrangler pages deploy . --project-name bossflow-site
```

### 三、阿里云 OSS + CDN（国内速度最好）

```powershell
# 装好 ossutil 并配置好 AccessKey 之后
ossutil sync . oss://<你的bucket>/ --delete --exclude ".git/*" --exclude ".github/*" --exclude "deploy/*"
```

关键提醒：**在中国大陆用域名对外提供 HTTP 服务需要 ICP 备案。** 只按 OSS 默认域名或 IP 访问可以绕开，
但用不了自己的域名和 HTTPS。如果这正是你要的，先把备案办了再买域名，不然站会卡在"能传不能开"。

## 以后想升级成控制台

现在这个站只讲清楚 BossFlow 是什么、怎么用。如果你要的是"在浏览器里点按钮派活、看每次运行的报告"，
那就需要一台常驻服务器来跑 BossFlow 本身，这时有两条路：

- **省事路线**：买一台国内轻量服务器（约 50 元/月起），装 Coolify（6.2 万 star，Apache-2.0）或 Dokploy（3.7 万 star），
  它就是一个自托管的 Vercel 面板，连 Git 仓库后一键部署，还带 HTTPS 和日志。
- **纯前端路线**：把运行记录导出成 JSON，让本站直接读它渲染——不需要服务器，但只能看，不能派活。

## 关于数据真实性

页面上的实测数字（5 个子任务、3 个波次、16 个测试、token 消耗）来自本机一次真实运行，不是编的。
依据在 `../bossflow/runs/20261012144553-用-node-test-给-bossflow-的-vxlz/`。
