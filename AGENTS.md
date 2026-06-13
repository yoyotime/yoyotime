# Yoyotime / 悠悠时光 — Project Memory

## 项目信息
- Flutter 项目，CI 通过 GitHub Actions 构建 APK
- Python 后端（FastAPI）做内容聚合
- 版本: 0.2.0
- 包名: com.yoyotime.app

## 项目使命
愿普天之下皆为净土，没有战争，没有罪恶。

## 产品定位
- 反成瘾：知道什么时候停下来的产品
- 反焦虑：过滤煽动性、恐惧诉求的内容
- 反窥探：用户偏好只在端上学习

## 三大空间
- 🌅 今日 — 5-8 条精选内容
- 🎧 听 — 语音消费场景
- 🕊️ 我 — 偏好设置、声音调整

## 四大护城河
1. 语气引擎（Tone Engine）— 识别煽动性/恐惧诉求
2. 反偏好学习（Anti-Preference）— 主动降权不喜欢的内容
3. 声音优先（Voice-First）— 全产品语音可消费
4. 克制美学（Restraint）— 一天不超 10 条

## CI 工作流
- `.github/workflows/build-apk.yml`
- 推送到 `main`：flutter analyze → test → build APK (split-per-abi) → 上传 artifact
- 推送标签 `v*.*.*`：额外创建 GitHub Release 附带 APK 下载

## 技术栈
- 前端：Flutter + Riverpod + GoRouter + flutter_tts
- 存储：SharedPreferences + JSON 文件
- 后端：FastAPI + SQLAlchemy + APScheduler
- 内容源：RSS feed + 关键词匹配

## 发布流程
- 打标签 `v*.*.*`（如 `v0.1.0`）并推送：`git tag v0.1.0 && git push origin v0.1.0`
- CI 自动构建并发布 Release
