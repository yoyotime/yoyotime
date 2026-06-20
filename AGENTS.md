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
- 🎧 听 — 语音消费场景（队列播放 + 速度/语音切换）
- 🕊️ 我 — 偏好设置、声音调整、分享、检查更新、阅读回顾

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

## 内容源（22 个）
- 大陆：新华社（3 频道）、东方财富、华尔街见闻、36氪、少数派、阮一峰、知乎、爱范儿、IT之家、cnbeta
- 海外：BBC中文、德国之声、中央社（台湾）、联合早报（新加坡）、关键评论网、纽约时报中文、日经中文
- 国际：联合国新闻、NPR（美国）

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

### 方式二：本地快速检查（秒级）
```bash
powershell -ExecutionPolicy Bypass -File preflight.ps1
```
检查项：
1. 关键文件存在（main.dart, app.dart, pubspec.yaml 等）
2. 所有 import 路径指向存在的文件

### 注意事项
- preflight.ps1 只检查 import 路径，不检查类型（Flutter 内置类型太多会误报）
- 类型错误、测试失败等由 CI 的 preflight.yml 捕获
- **如果 preflight.ps1 通过但 CI 失败，说明是类型/逻辑错误，需要看 CI 日志**

## 最快镜像
- `gh-proxy.com` 推送最快
- yt.bat 镜像列表顺序：gh-proxy.com → ghfast.top → mirror.ghproxy.com → ... → github.com
- push 格式：`https://TOKEN@gh-proxy.com/github.com/user/repo.git`

## ✅ 已验证通过的 CI 配置
- **Flutter 3.24.0**, **Gradle 8.10.2**, **AGP 8.4.0**, **Kotlin 1.9.22**
- compileSdk 34, targetSdk 34, minSdk 24, NDK 25.1.8937393
- Java 17 (temurin), JVM target 17
- **flutter_tts 必须锁定 4.2.3**（4.2.4+ 的 Kotlin 代码与 1.9.x 编译器不兼容）
- **pubspec.lock 已提交**，CI 构建确定可复现
- 构建命令：`flutter build apk --release --target-platform android-arm64`
- 每次构建前必须清 Gradle JAR 缓存，否则可能 bcprov 损坏

## 将来升级任何版本时
- **每次只能改一个变量**，改完等 CI 结果
- flutter_tts 升级前测试其 Kotlin 源码是否兼容项目 Kotlin 版本
- AGP 升级检查内部 Kotlin stdlib 版本是否与项目 Kotlin 版本冲突

## 审核清单（推前必查）
1. ToneEngine evaluate() — 取最严重 action（block > demote > allow）
2. FeedFetcher — 有 User-Agent，_fetchJsonFeed 有 try-catch
3. share_plus — 用 Share.share()（^7.2.2，新版 API 因依赖冲突不可用）
4. 每日限制 — load() 正常展示 10 条，消耗达 10 条后提示，refresh() 可突破
5. TTS pause — TtsService.pause() 设置 _isPaused、触发 notifyListeners；speak() 重置 _isPaused
6. 听 tab — 队列非空时显示播放列表 + 控制栏；空时提示去今日添加内容；右上角切换语音设置
7. TBK/PDD 降级 — 无 API key 且无商品时显示"请先配置商品来源" + 去配置按钮
8. 变量命名 — 避免 controller_ 等冲突名
9. voice_input_dialog — showDialog().then() 靠外（不要 StatefulBuilder().then()）
