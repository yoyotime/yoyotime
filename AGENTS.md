# Yoyotime / 悠悠时光 — Project Memory

## 项目信息
- Flutter 项目，CI 通过 GitHub Actions 构建 APK
- 无后端架构 — RSS 直接客户端抓取（webfeed + Dio）
- 版本: 0.4.0
- 包名: com.yoyotime.app

## 项目使命
愿普天之下皆为净土，没有战争，没有罪恶。

## 产品定位
- 反成瘾：知道什么时候停下来的产品（每日限 10 条，到量即止）
- 反焦虑：语气引擎过滤煽动性、恐惧诉求的内容
- 反窥探：用户偏好只在端上学习（不上传任何数据）

## 三大空间
- 🌅 今日 — 10 条精选内容（RSS → 语气过滤 → 反偏好 → 展示）
- 🎧 听 — 语音消费场景（待实现）
- 🕊️ 我 — 偏好设置、声音调整、分享、检查更新

## 四大护城河
1. 语气引擎（Tone Engine）— 配置驱动（assets/config/tone_rules.json），按分类 block/demote/allow
2. 反偏好学习（Anti-Preference）— dislike 自动提取关键词加入本地黑名单
3. 声音优先（Voice-First）— flutter_tts 全产品语音可消费 + 语音输入（speech_to_text）
4. 克制美学（Restraint）— 每天最多 10 条，手动刷新可强制增加

## 技术栈
- 前端：Flutter + Riverpod + GoRouter + flutter_tts
- 存储：SharedPreferences + JSON 文件（无 SQLite）
- 内容源：17 个 RSS/Atom 源，配置驱动（assets/config/sources.json），支持 RSS 2.0 / Atom / JSON Feed
- 分享：share_plus（系统原生，无第三方 SDK）
- 更新：package_info_plus + GitHub Releases API + open_filex（自动检测更新）

## 内容源（17 个）
- 大陆：新华社（3 频道）、东方财富、华尔街见闻、36氪、Solidot、少数派、阮一峰
- 海外：BBC中文、德国之声、中央社（台湾）、联合早报（新加坡）、关键评论网、纽约时报中文、日经中文
- 国际组织：联合国新闻

## 声音输入场景
1. 兴趣描述 — 语音输入偏好（我 → 兴趣描述 → 🎤）
2. 添加话题 — 语音输入关心/不想看的话题
3. 添加 RSS 源 — 语音输入 URL

## CI 工作流
- `.github/workflows/build-apk.yml`
- 推送到 `main`：flutter analyze → test → build APK (split-per-abi) → 上传 artifact
- 推送标签 `v*.*.*`：额外创建 GitHub Release 附带 APK 下载

## 发布流程
- 打标签 `v*.*.*`（如 `v0.4.0`）并推送：`git tag v0.4.0 && git push origin v0.4.0`
- CI 自动构建并发布 Release

## 颅脑测试（推代码前必跑）
**你没有 Flutter 本地环境，所以用这个流程：**

### 方式一：推到测试分支（推荐）
```bash
git checkout -b test-xxx
git push origin test-xxx
# GitHub Actions 自动运行 .github/workflows/preflight.yml
# 等 ✅ 通过后再合并到 main
```

### 方式二：本地快速检查
Windows: `pre_release_check.bat`（不需要 Flutter，只检查文件/语法）

### 检查项
1. 关键文件存在（main.dart, app.dart, pubspec.yaml 等）
2. AndroidManifest 配置正确
3. pubspec.yaml 语法
4. git 状态（未提交文件）
5. print() 调试语句
6. CI 最终验证（preflight.yml → build-apk.yml）

## 最快镜像
- `gh-proxy.com` 推送最快
- yt.bat 镜像列表顺序：gh-proxy.com → ghfast.top → mirror.ghproxy.com → ... → github.com
- push 格式：`https://TOKEN@gh-proxy.com/github.com/user/repo.git`

## 审核清单（推前必查）
1. ToneEngine evaluate() — 取最严重 action（block > demote > allow）
2. FeedFetcher — 有 User-Agent，_fetchJsonFeed 有 try-catch
3. share_plus — 用 SharePlus.instance.share(ShareParams(...))
4. 每日限制 — load() 正常展示 10 条，消耗达 10 条后提示，refresh() 可突破
5. 变量命名 — 避免 controller_ 等冲突名
