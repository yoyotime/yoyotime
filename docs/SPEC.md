# 悠悠时光 (Yoyotime) — 产品规格文档

> 文档版本：v3.1  ·  状态：Phase 1 开发中

---

## 一、产品哲学

### 一句话
> 不是把更多内容塞给你，而是**只把你真正在意的、对你无害的**信息送过来。

### 三条原则
1. **反成瘾**：不让你刷个不停。能听完就是完成。
2. **反焦虑**：不在屏幕上制造恐惧、愤怒、攀比。
3. **反窥探**：你的偏好只在你的设备上学习。

### 我们**不**做的事
- ❌ 没有无限滚动瀑布流
- ❌ 没有"猜你喜欢"的无限推荐
- ❌ 没有评论、点赞、社交
- ❌ 没有广告位、没有数据出售

> 这是一款"知道什么时候停下来"的产品。

---

## 三、竞品分析

### 3.1 痛点维度对比（不按功能比，按痛点比）

| 用户痛点 | 今日头条 | 腾讯/澎湃 | NetNewsWire | MrRSS/Agr | **Yoyotime** |
|----------|---------|-----------|-------------|-----------|-------------|
| 信息过载，刷不完 | ❌ 无限滚动 | ❌ 无限刷新 | ❌ 全靠自己 | ⚠️ AI摘要 | ✅ 每天限10条，到量即止 |
| 看完心情变差 | ❌ 情绪放大 | ⚠️ 中立报道 | ❌ 不处理 | ❌ 不处理 | ✅ 语气引擎过滤恐惧/煽动 |
| 隐私被监控 | ❌ 全方位追踪 | ❌ 用户画像 | ✅ 纯本地 | ✅ 本地优先 | ✅ 全程不上传任何数据 |
| 手被占着想听 | ❌ 只有视频 | ⚠️ 部分有声 | ❌ 无TTS | ❌ 无TTS | ✅ 全产品语音可消费 |
| 不知道信谁 | ❌ 自媒体混杂 | ✅ 专业编辑 | ❌ 自判断 | ⚠️ 源列表 | ✅ 17个经过实测的源 |
| 内容太多无从下手 | ❌ 猜你喜欢 | ❌ 编辑推荐 | ❌ 全部展示 | ⚠️ 摘要 | ✅ 语音输入兴趣→自动筛选 |
| 重复内容 | ❌ 不处理 | ⚠️ 偶尔 | ❌ 不处理 | ❌ 不处理 | ✅ 标题去重+同源合并 |
| 分享给家人 | ❌ 分享链接 | ✅ 分享链接 | ❌ 无 | ❌ 无 | ✅ 分享APK下载链接 |

### 3.2 核心差距：Yoyotime 做了什么别人没做的

**差距 1：不是"让你多看"，而是"帮你少看"**
- 今日头条的 KPI 是 DAU 和停留时长 → 算法目标是让你上瘾
- Yoyotime 的 KPI 是"用户是否在 10 条内找到想要的" → 算法目标是让你满足然后离开
- ❓同类中谁在做：**没人做。** 所有内容 App 都在抢用户时间。

**差距 2：不是"猜你喜欢"，而是"记住你不喜欢"**
- 主流推荐是正反馈循环（like → more like）
- Yoyotime 是负反馈循环（dislike → never see again）
- ❓同类中谁在做：**没人做。** 点"不感兴趣"在头条里只是暂时降权，过两天又出现。

**差距 3：不是"给你更多"，而是"给你更少但更好"**
- 澎湃、腾讯编辑选稿 → 好但千人一面
- 今日头条算法推荐 → 个性但质量参差
- Yoyotime = 编辑级源头（17 个可靠源）× 语气过滤 × 反偏好 → 精选 10 条
- ❓同类中谁在做：**没人做。** 其他 App 在拼"全"，Yoyotime 在拼"精"。

**差距 4：无后端闭环，一个人运营**
- 所有竞品都有后端团队维护推荐系统
- Yoyotime 不需要后端，不需要数据库，不需要用户账号
- 这意味着：**零运维成本、零数据泄露风险、用户可永远使用**

### 3.3 竞品做不到的事（技术差异分析）

| 能力 | 为什么竞品很难抄 | 我们的做法 |
|------|----------------|-----------|
| 语气过滤 | 需要大量标注数据训练分类器 | 配置驱动的关键词+正则规则，快速迭代 |
| 反偏好学习 | 推荐系统架构决定了正反馈优先 | 纯本地黑名单，不需要修改推荐权重 |
| 日限制 | 和商业目标（停留时长）冲突 | 产品哲学天然支持，无商业抵触 |
| 无后端 | 公司需要控制内容、做商业化 | 个人项目不需要盈利，只需覆盖成本 |
| 语音优先 | 需要大量 UI 改造 | 从第一天就设计为语音可消费 |

### 3.4 我们的差异化定位（修正版）

```
别人的推荐："猜你喜欢 → 多推 → 让你上瘾"
我们的推荐："你不喜欢 → 记住 → 永不推"
```

- **不是 Feedly 的翻版**（我们不要求用户自建源管理）
- **不是今日头条的竞品**（我们不去抢用户时长）
- **是给"想少看但想看准"的人做的安静工具**
- **核心竞争力不是技术，是"克制"——竞品做不到因为商业上不允许**

---

## 二、目标用户的真实痛点

### 用户画像
一位关注时事、在意信息质量的普通用户。平时时间碎片化，希望在有限信息中获得真正有价值的新闻。但**她最缺的不是信息，而是"不被信息打扰地获得信息"**。

### 三个真实痛点
1. **痛点一：信息过载 vs 信息饥渴**
   - 现状：互联网内容太多，但**她想看的那一类**（儿童安全、和平、严肃新闻）被淹没在八卦、短视频、软广里
   - 她要的不是更多，是更准

2. **痛点二：算法是情绪放大器**
   - 现状：所有"智能推荐"都在优化点击和停留。越愤怒越推荐，越焦虑越多推
   - 她要的是一个**能克制地减少焦虑**的算法

3. **痛点三：手被占着，耳朵闲着**
   - 现状：带小孩、做饭、洗衣——手是忙的
   - 现有 App 几乎都是**视觉优先**，听新闻要专门打开 App
   - 她要的是**耳朵能消费内容**

---

## 三、四大护城河（不易被复制的设计）

### 护城河 1：语气引擎（Tone Engine）
- **不是**关键词匹配
- **是**内容情感与语气的细粒度分类
- 技术难点：中文新闻的"煽动性/恐惧诉求/道德绑架"识别是行业内难题
- **独特价值**：能识别"看似相关但会让你难受"的内容，主动避开

### 护城河 2：反偏好学习（Anti-Preference Learning）
- 主流推荐算法：用户喜欢什么 → 多推
- **我们反过来**：用户明确表示"不喜欢/难受" → **永久降低该类内容权重**
- 技术难点：需要从被动反馈（划走）和主动反馈（标记不适）中区分真实负面信号
- **独特价值**：用户感受到"这 App 真的懂我不要什么"，建立信任

### 护城河 3：声音优先（Voice-First）
- 全产品语音可消费（TTS 输出）
- 全产品语音可输入（语音转文字，输入兴趣、搜索、添加源）
- 多角色 TTS：新闻用"温和播报员"，生活类用"邻家姐姐"
- 后台播放 + 锁屏控制 + 接续上次
- **独特价值**：场景覆盖——做饭、洗衣、睡前都能用；手被占着时靠嘴操作

### 护城河 4：克制美学（Restraint as Design）
- 一天主动推送不超过 10 条
- 一次会话不超过 30 分钟（软引导）
- 没有任何"红点/未读数字"
- **独特价值**：行业里第一款"希望你少用"的产品，反而因此留住用户

---

## 四、产品形态

### 4.1 三个空间

| 空间 | 含义 | 核心动作 |
|------|------|----------|
| **🏡 今日** | 你今天应该知道的 | 看 5-8 条精选 / 听 5 分钟新闻 |
| **🌊 听** | 语音消费场景 | 选一个话题，听 15-30 分钟 |
| **🕊️ 我** | 个性化控制 | 描述兴趣、调整权重、查看历史 |

### 4.2 一次典型的使用
1. **早晨 7 点**：打开 App，5 分钟听 5 条要闻
2. **做饭时**：进入"听"，选择"儿童安全专题"，边切菜边听
3. **晚上**：进入"今日"，标记"这条讲伊朗的，希望多看看"或"这条讲了不该看的演员八卦，不想看到"
4. **睡前**：放下手机，听一段平静的内容

---

## 五、核心功能规格

### 5.1 兴趣描述（首次引导）

> 单一输入框，让用户**用自然语言**描述自己：
> 
> "我关心国际局势和社会新闻，特别是儿童安全和和平相关的内容。不想看到娱乐八卦和带有暴力血腥的内容。"

**本地处理：**
- 中文分词 + 关键词提取
- 情感极性识别（基于规则）
- 生成初始兴趣词表 + 黑名单词表
- 全部在设备上完成，不上传任何文本

### 5.2 内容流（"今日"）

```
[早晨 7:00 - 8:00 默认推送]
┌──────────────────────────────────┐
│ 🎙 今日要闻 (5 条)               │
│   [▶ 一键播放]                   │
│                                  │
│ 1. 公安部部署新一轮打拐专项      │
│    3 分钟阅读 · 2 分钟朗读        │
│    [❤️ 喜欢] [👎 不感兴趣] [🗑️]  │
│                                  │
│ 2. ...                           │
└──────────────────────────────────┘
```

**交互细节：**
- 👎 不感兴趣：单次降权
- 🗑️ 删除：永久屏蔽该来源/主题
- 双击空白：暂停当前播放
- 长按卡片：查看全部"不喜欢"原因
- 🎤 语音搜索：点击搜索图标后长按麦克风按钮说话，实时转文字搜索标题/摘要

### 5.3 听（语音场景）

```
┌──────────────────────────────────┐
│  🌊 听                            │
│                                  │
│  [▶ 继续听 14:32 / 23:15]       │
│                                  │
│  ━━━━━━━━━━━━━━━━━━━━            │
│                                  │
│  📂 我的播放列表                  │
│  • 儿童安全专题 (5 条 · 28 分钟) │
│  • 今日国际要闻 (5 条 · 23 分钟) │
│  • 和平观察 (3 条 · 14 分钟)     │
│                                  │
│  [➕ 创建新专题]                  │
└──────────────────────────────────┘
```

**特色功能：**
- "听专题"：把同类内容打包成一个音频合集
- 离线下载：一次性下载整个专题
- 播放速度：0.8x ~ 2.0x 可调
- 睡眠定时：到时间自动停止

### 5.4 我（偏好与历史）

```
┌──────────────────────────────────┐
│  🕊️ 我                            │
│                                  │
│  📝 兴趣描述                      │
│  [我关心国际局势和社会新闻...]  │
│  [✏️ 编辑] [🎤 语音输入]          │
│                                  │
│  ✅ 我关心的                       │
│  • 儿童安全  • 和平  • 国防       │
│  [+ 添加]                        │
│                                  │
│  🚫 我不想看的                    │
│  • 娱乐八卦  • 血腥图片           │
│  [+ 添加]                        │
│                                  │
│  🔊 声音设置                      │
│  [播报员音色] [语速 1.0x]         │
│                                  │
│  📚 历史与收藏                    │
│                                  │
│  📤 分享给朋友                    │
└──────────────────────────────────┘
```

**语音输入兴趣描述：**
- 点击 🎤 按钮 → 开始录音 → 说完自动停止（或手动停止）
- 语音转文字结果填入兴趣描述输入框
- 用户可继续手动编辑修正
- 全程不上传语音数据，使用设备本地识别（`speech_to_text`）
- 安静环境下识别率 95%+，支持普通话和基础方言

### 5.5 分享邀请（病毒传播入口）

> **场景**：用户觉得 App 好用 → 想分享给家人朋友 → 对方是非软件用户（非开发者）→ 通过链接下载 APK

**设计原则：**
- 不追踪谁分享给了谁（无邀请码、无统计）
- 分享内容 = "悠悠时光 APK 下载链接 + 一句话推荐"
- 链接指向 GitHub Releases 页面（最新版 APK 下载页）
- 使用系统原生分享（`share_plus`），不嵌入第三方 SDK

**交互流程：**
```
[我 → 分享给朋友]
┌──────────────────────────────────┐
│  邀请好友，安静地了解世界        │
│                                  │
│  悠悠时光 — 每天 10 条精选内容   │
│  反焦虑 · 反成瘾 · 反窥探        │
│                                  │
│  [📤 分享给微信好友]              │
│  [📤 分享到其他应用]              │
│                                  │
│  ┌──────────────────────┐        │
│  │ 或扫码下载：          │        │
│  │  [QR Code]           │        │
│  └──────────────────────┘        │
└──────────────────────────────────┘
```

**分享链接生成：**
- 格式：`https://github.com/anomaloco/yoyotime/releases/latest`
- 或含版本号的稳定链接：`https://github.com/anomaloco/yoyotime/releases/tag/v0.1.0`
- 链接来自 `assets/config/app_config.json` 中的 `release_url`（配置驱动）

### 5.6 自动更新（静默检测 + 用户确认安装）

> **场景**：用户安装了 v0.3.0 → 新版 v0.4.0 发布 → 用户打开 App → 提示更新 → 下载 APK → 安装

**设计原则：**
- 不强制更新，用户可选择"稍后提醒"
- 通过 GitHub Releases API 检测最新版本，不依赖第三方更新服务
- 下载进度可感知（进度条）
- 下载完成后自动打开安装界面（Android）
- 全部请求走 HTTPS，APK 下载走 GitHub Releases 直链

**流程：**
```
① App 冷启动（或每隔 24h）
② GET https://api.github.com/repos/anomaloco/yoyotime/releases/latest
③ 解析 JSON → 获取 tag_name (如 "v0.4.0")
④ 本地版本号 vs 远端版本号
   → 远端更新 → 通知栏 / 我 页面显示"有新版本"
   → 用户点击 → 显示更新日志 + 下载按钮
⑤ 下载 APK (Dio + 进度回调)
⑥ 下载完成 → 打开 APK 安装 (open_filex)
⑦ 安装完成后自动清理下载文件
```

**版本对比规则：**
- 使用 semver 比较（`v0.4.0` > `v0.3.0`）
- 忽略 pre-release 版本（不推送 beta 版）
- 忽略当前版本（不重复提示）
- 每次检测结果缓存到 SharedPreferences，同一版本不重复提示

---

## 六、技术架构（v3.0 — 无需后端，完全闭环）

### 6.1 架构原则

> **没有服务器。没有用户账号。没有数据上传。**
> 一条内容从公网 RSS → 你的手机 → 你的耳朵，全程不经过任何第三方服务器。

### 6.2 总体架构

```
┌──────────────────────────────────────────────────────────┐
│                Flutter 客户端 (完全离线优先)               │
│                                                          │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────────┐     │
│  │ UI 层     │ │ 状态层   │ │ 本地内容引擎         │     │
│  │ (Material)│ │(Riverpod)│ │ ┌──────────────┐    │     │
│  └────┬─────┘ └────┬─────┘ │ │ RSS 抓取器    │    │     │
│       │            │       │ │ (webfeed+Dio) │    │     │
│       │            │       │ └──────┬───────┘    │     │
│       │            │       │ ┌──────┴───────┐    │     │
│       │            │       │ │ 语气引擎      │    │     │
│       │            │       │ │ (ToneEngine)  │    │     │
│       │            │       │ └──────┬───────┘    │     │
│       │            │       │ ┌──────┴───────┐    │     │
│       │            │       │ │ 反偏好过滤器  │    │     │
│       │            │       │ └──────────────┘    │     │
│       └────────────┴───────┴──────────┬───────────┘     │
│                                       │                 │
│  ┌────────────────────────────────────┴──────┐          │
│  │       配置驱动 / assets/config/            │          │
│  │  • sources.json  — RSS 源列表             │          │
│  │  • tone_rules.json — 语气规则             │          │
│  └───────────────────────────────────────────┘          │
│                                       │                 │
│  ┌────────────────────────────────────┴──────┐          │
│  │        本地存储 (SharedPreferences         │          │
│  │         + JSON 文件)                       │          │
│  │  • 内容缓存        • 用户反馈              │          │
│  │  • 偏好词表        • 黑名单词表            │          │
│  │  • 阅读历史        • 来源白名单            │          │
│  └───────────────────────────────────────────┘          │
│                                       │                 │
│  ┌────────────────────────────────────┴──────┐          │
│  │        TTS 引擎 (Flutter TTS)              │          │
│  │   • 设备本地合成 • 离线可用               │          │
│  │   • 语速可调 • 多种音色                  │          │
│  └───────────────────────────────────────────┘          │
└──────────────────────────────────────────────────────────┘
         │                    │
         │ HTTPS (直接请求)    │ 无任何中间服务器
         ▼                    ▼
  ┌──────────────┐    ┌──────────────┐
  │  公网 RSS    │    │  公网 RSS    │
  │  (新华网)    │    │  (联合国)    │
  │  (东方财富)  │    │  (Solidot)   │
  └──────────────┘    └──────────────┘
```

> **配置驱动原则**：所有可变参数（RSS 源、语气规则、UI 文案）都在 `assets/config/*.json` 中定义，不硬编码在 Dart 代码中。用户自定义覆盖存本地，不会被远端更新覆盖。

### 6.3 内容流（闭环数据流）

```
时间线：
① 用户打开 App → 触发 RSS 抓取
② App 直接 HTTP GET 请求公网 RSS 源
③ 解析 XML → 转为 ContentItem 列表
④ 语气过滤器筛选：剔除暴力/煽动内容
⑤ 兴趣排序器根据用户偏好打分排序
⑥ 截取前 N 条展示（克制美学：最多 10 条）
⑦ 用户阅读 / 听 / 反馈
⑧ 反馈记录本地 → 影响下次排序
⑨ 缓存到 JSON 文件 → 下次离线可用
```

### 6.4 时效性策略（内容要"快"更要"准"）

**刷新机制：**
- 用户打开 App → **立即拉取所有活跃 RSS 源**（冷启动刷新）
- 停留在 App 期间 → 后台每 **15 分钟** 静默刷新一次
- 切到后台再切回 → 超过 30 分钟则重新拉取
- 不搞"推送拉活"（反成瘾原则）
- 每次刷新显示最后更新时间戳

**去重策略（避免同事件多条）：**
- **URL 去重**：同 URL 内容只保留最新一条
- **标题相似去重**：编辑距离 < 20% 的标题视为同事件，保留发布时间最早的一条
- **同源合并**：同一 RSS 源内，同专题内容合并显示

**缓存策略：**
- 每次成功拉取 → 覆盖本地缓存（JSON 文件）
- 断网时 → 展示缓存内容，顶部提示"离线模式 · 上次更新 X 分钟前"
- 缓存有效期：24 小时。超时缓存仅做离线兜底，不展示为主

**"准时"而非"实时"原则：**
- 我们不和今日头条比快（秒级推送重大新闻）
- 用户预期：打开 App 时信息是 15 分钟内的 → 满足
- 真正重要的新闻，会在多个 RSS 源中重复出现 → 自然增强了置信度

### 6.5 语气引擎（v1 — 规则驱动，配置驱动，非硬编码）

**目标**：在客户端识别并过滤不合适的内容

**设计原则：**
- 所有规则存在 `assets/config/tone_rules.json` 中，随 App 打包
- 规则按**分类（category）**组织，每条规则有 `type`（keyword/regex）、`pattern`、`action`（block/demote/allow）、`reason`
- 分类策略分三级：`normal`（标准过滤）、`strict`（更严格，财经用）、`relaxed`（仅过滤暴力血腥）
- 用户标记"不想看"的内容 → 动态加入本地黑名单（不影响全局规则包）
- 规则可随版本迭代更新，无需联网

**config/tone_rules.json 实际结构：**
```json
{
  "version": 1,
  "defaultPolicy": "normal",
  "categories": {
    "finance": {
      "policy": "strict",
      "rules": [
        {
          "type": "keyword",
          "pattern": "崩盘|暴跌|恐慌|抛售|踩踏|血洗",
          "action": "block",
          "reason": "恐慌性表述"
        },
        {
          "type": "keyword",
          "pattern": "暴涨|翻倍|十倍|百倍|暴富",
          "action": "block",
          "reason": "煽动性表述"
        },
        {
          "type": "keyword",
          "pattern": "危机|崩盘|熊市|泡沫",
          "action": "demote",
          "reason": "负面渲染"
        }
      ]
    },
    "international": {
      "policy": "normal",
      "rules": [
        {
          "type": "keyword",
          "pattern": "震惊|可怕|恐怖|末日|灭绝",
          "action": "block",
          "reason": "恐惧诉求"
        },
        {
          "type": "keyword",
          "pattern": "威胁|战争|冲突|制裁",
          "action": "demote",
          "reason": "可能含煽动性"
        }
      ]
    },
    "general": {
      "policy": "normal",
      "rules": [
        {
          "type": "keyword",
          "pattern": "震惊|太可怕了|紧急|速看|删前速看|不转不是",
          "action": "block",
          "reason": "标题党/恐惧诉求"
        }
      ]
    }
  }
}
```

**检测流程（运行时）：**
```
输入 ContentItem (title + summary + fullText + topics)
  → 遍历 item.topics，匹配对应 category 的规则
    → 每个规则用 RegExp 匹配 title + summary + fullText
    → 匹配 block → 丢弃（不展示）
    → 匹配 demote → 排到列表末尾
  → 如果无匹配分类，则用 general 兜底
  → 无任何匹配 → allow
  → 输出排序后的 List<ContentItem>（block 已剔除，demote 在后）
```

> 为什么用分类匹配而不是全局规则？因为同一关键词在不同语境下含义不同。例如"崩盘"在财经类中可能是风险信号，在社会新闻中可能是事实描述。分类规则允许按上下文做差异化判断。

> 用户不需要理解规则文件。反馈按钮 👎 和 🗑️ 会自动提取关键词加入本地黑名单。

### 6.6 反偏好学习（Anti-Preference）

- 用户标记"不喜欢/删除" → 提取该内容的主题词
- 这些词进入**个人黑名单词表**
- 再次排序时，命中黑名单的内容降权 90%
- 多次标记同类词 → 该主题整体降权
- **所有数据只存在本地 JSON 文件中**

### 6.7 克制美学（Restraint）— 日限制逻辑

```
每天 00:00 重置计数器
每次展示内容 = min(10, 抓取到的有效内容)
用户阅读/听完第 10 条 → 显示 "今天的内容看完了，明天见" 
```

### 6.8 内容来源管理（配置驱动 + 自动更新）

**设计原则：**
- 初始源列表打包在 `assets/config/sources.json` 中（首次安装用）
- 每次启动时，尝试从远端拉取最新 `sources.json`
- 远端拉取成功 → 覆盖本地缓存 → 下次启动用缓存版本
- 远端拉取失败 → 使用本地缓存（或首次用打包版本）
- 用户可手动增删源、启禁用，**用户修改不会因远端更新丢失**

**三层源列表合并策略：**
```
用户自定义源 (local_overrides.json)  ← 最高优先级，不会被远端覆盖
远端源列表 (remote_sources.json)      ← 中优先级，覆盖打包源
打包默认源 (assets/config/sources.json)  ← 最低优先级，兜底
```

**远端源列表更新机制：**
- 更新 URL：`https://raw.githubusercontent.com/你的名字/yoyotime-sources/main/sources.json`
- 或未来部署后端后的 `/v1/sources`
- 每次 App 启动时静默拉取（后台非阻塞）
- 仅当远端 JSON 的 `version` 大于本地时，才执行合并

**sources.json 实际结构（含版本 + 自动更新支持）：**
```json
{
  "version": 1,
  "sources": [
    {
      "id": "un_news",
      "name": "联合国新闻",
      "url": "https://news.un.org/feed/subscribe/zh/news/all/rss.xml",
      "category": "international",
      "topics": ["国际", "和平"],
      "enabled": true,
      "updateIntervalMinutes": 120
    },
    {
      "id": "east_money",
      "name": "东方财富",
      "url": "http://rss.eastmoney.com/rss_partener.xml",
      "category": "finance",
      "topics": ["财经", "股市"],
      "enabled": true,
      "updateIntervalMinutes": 30
    },
    {
      "id": "solidot",
      "name": "奇客Solidot",
      "url": "https://www.solidot.org/index.rss",
      "category": "independent",
      "topics": ["科技", "社会", "独立"],
      "enabled": true,
      "updateIntervalMinutes": 120
    }
  ]
}
```

**字段说明：**
| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 唯一标识，用于去重和缓存 |
| `name` | string | 展示名称 |
| `url` | string | RSS/Atom feed URL |
| `category` | string | 分类，用于语气引擎匹配（finance/international/official/tech/independent） |
| `topics` | string[] | 默认话题标签，会合并到每条内容的 topics 中 |
| `enabled` | bool | 是否启用 |
| `updateIntervalMinutes` | int | 刷新间隔（分钟） |

**实测可用源（截至 v0.3.1）：**
| 区域 | 分类 | 源 | URL | 状态 |
|------|------|----|-----|------|
| 国际组织 | official | 联合国新闻 | `https://news.un.org/feed/subscribe/zh/news/all/rss.xml` | ✅ 每日更新 |
| 大陆 | official | 新华社时政 | `http://www.news.cn/rss/politics.xml` | ✅ 每日更新 |
| 大陆 | official | 新华社国际 | `http://www.news.cn/rss/world.xml` | ✅ 每日更新 |
| 大陆 | official | 新华社财经 | `http://www.news.cn/rss/finance.xml` | ✅ 每日更新 |
| 大陆 | finance | 东方财富 | `http://rss.eastmoney.com/rss_partener.xml` | ✅ 当日 + 全文+股票代码 |
| 大陆 | finance | 华尔街见闻 | `https://www.wallstreetcn.com/rss` | ✅ 宏观财经 |
| 大陆 | tech | 36氪 | `https://36kr.com/feed` | ✅ 科技商业 |
| 大陆 | independent | 奇客Solidot | `https://www.solidot.org/index.rss` | ✅ 独立科技评论 |
| 大陆 | independent | 少数派 | `https://sspai.com/feed` | ✅ 独立品质内容 |
| 大陆 | independent | 阮一峰 | `https://www.ruanyifeng.com/blog/atom.xml` | ✅ 科技周刊 |
| 英国 | international | BBC中文 | `https://www.bbc.com/zhongwen/simp/index.xml` | ✅ 国际视角 |
| 德国 | international | 德国之声中文 | `http://rss.dw.de/rdf/rss-chi-all` | ✅ 欧洲视角 |
| 台湾 | international | 中央社 | `https://www.cna.com.tw/rss/all.xml` | ✅ 台湾官方通讯社 |
| 新加坡 | international | 联合早报 | `https://feedx.net/rss/zaobao.xml` | ✅ 东南亚华文视角 |
| 台湾 | independent | 关键评论网 | `https://www.thenewslens.com/feed/all` | ✅ 独立评论媒体 |
| 美国 | international | 纽约时报中文 | `http://cn.nytimes.com/rss/news.xml` | ✅ 深度国际报道 |
| 日本 | finance | 日经中文 | `http://feedx.net/rss/nikkei.xml` | ✅ 亚洲财经 |

> 共 **17 个源**，覆盖大陆、台湾、香港、新加坡、英国、德国、美国、日本、联合国，支持 RSS 2.0 / Atom / JSON Feed 三种格式。

> 用户可通过 我 → 内容源 添加/删除/启用/禁用 RSS 源。支持手动输入 URL 添加自定义源，也支持 🎤 语音输入 URL（用说的代替打字）。

### 6.9 关键依赖

| 类别 | 选型 | 理由 |
|------|------|------|
| RSS 解析 | webfeed (Dart) | 客户端直接解析 |
| 网络请求 | Dio | 已集成 |
| TTS 输出 | flutter_tts (设备原生) | 离线可用 |
| 语音输入 | speech_to_text (设备原生) | 本地识别，不上传语音 |
| 分享 | share_plus (系统原生) | 不嵌入第三方 SDK |
| 存储 | SharedPreferences + JSON | 轻量、无额外依赖 |
| 状态管理 | Riverpod | 已集成 |
| 无服务器 | — | 用户零运维 |

---

## 七、状态管理与数据模型（v3.0 — 纯本地）

### 7.1 状态管理架构（Riverpod）

```
Provider 树：
                    App
                     │
        ┌────────────┴────────────┐
        │                         │
   FeedProvider              PreferenceProvider
   (内容流)                   (偏好/黑名单)
        │                         │
   ┌────┴────┐              ┌────┴────┐
   │         │              │         │
fetch    filter          read      write
(拉取)  (排序/过滤)      (加载)    (持久化)
```

| Provider | 职责 | 更新时机 |
|----------|------|----------|
| `feedProvider` | 当前展示的内容列表（已过滤+排序） | 打开 App、刷新按钮、偏好变更时 |
| `allItemsProvider` | 所有 RSS 原始 items（未过滤） | RSS 拉取完成时 |
| `preferenceProvider` | 用户偏好词表 + 黑名单词表 | 用户编辑偏好、标记反馈时 |
| `sourcesProvider` | RSS 源列表（URL + 状态） | 用户管理源、刷新时 |
| `dailyLimitProvider` | 今日已消费条数 | 用户阅读/听完一条时 |

### 7.2 本地数据模型（JSON 存储）

**内容缓存 (`cache/feed_cache.json`)：**
```json
{
  "last_fetch_at": "2026-06-13T08:30:00Z",
  "items": [
    {
      "id": "sha256_of_url",
      "title": "公安部部署新一轮打拐专项",
      "summary": "公安部近日部署...",
      "full_text": "...",
      "source_name": "人民网",
      "source_url": "http://people.com.cn/...",
      "published_at": "2026-06-13T07:00:00Z",
      "topics": ["儿童安全", "法治"],
      "tone_score": 0.85
    }
  ]
}
```

**用户偏好 (`preferences.json`)：**
```json
{
  "description": "我关心国际局势和社会新闻，特别是儿童安全...",
  "interest_words": ["儿童安全", "和平", "国际", "国防"],
  "blocklist_words": ["娱乐八卦", "明星", "暴力"],
  "blocklist_sources": ["sport.qq.com"],
  "tts_speed": 1.0,
  "tts_voice": "zh-CN-XiaoxiaoNeural",
  "daily_count": 5,
  "daily_date": "2026-06-13"
}
```

**用户反馈 (`feedback.json`)：**
```json
{
  "actions": [
    {
      "content_id": "sha256_of_url",
      "action": "dislike",
      "words_matched": ["娱乐", "明星"],
      "created_at": "2026-06-13T10:00:00Z"
    }
  ]
}
```

### 7.3 存储实现

- 使用 `shared_preferences` 存储小数据（偏好 JSON 字符串）
- 使用 `path_provider` + 文件 IO 存储大数据（feed 缓存 JSON）
- 不引入 SQLite / Drift — 纯 JSON 文件即可，数据量小（每天 ≤ 10 条）
- 读取逻辑：`try { 读缓存文件 } catch { 返回空列表 }`

---

## 八、Dart 数据模型

### 8.1 核心模型（lib/shared/models/content.dart + lib/core/feed/feed_fetcher.dart）

```dart
// ─── 配置模型（JSON 反序列化） ───

class RssSource {
  final String id;
  final String name;
  final String url;
  final String category;        // finance | international | official | tech | independent
  final List<String> topics;    // 默认话题标签
  final bool enabled;
  final int updateIntervalMinutes;

  factory RssSource.fromJson(Map<String, dynamic> json);
}

// ─── 内容条目（去掉了 toneScore 和 isRead — 这些由引擎动态计算，不持久化） ───
class ContentItem {
  final String id;           // "${sourceId}-${titleHash}"
  final String title;
  final String summary;
  final String? fullText;
  final String sourceName;
  final String sourceUrl;
  final List<ContentMedia> media;
  final List<String> topics;
  final DateTime publishedAt;
  final DateTime fetchedAt;
  final int estimatedReadTimeMinutes;

  factory ContentItem.fromJson(Map<String, dynamic> json);
  ContentItem copyWith({String? fullText, List<ContentMedia>? media});
}

// ─── 用户偏好 ───
class UserPreferences {
  String description;
  List<String> interests;
  List<String> blocklist;
  bool preferAudio;
  double ttsSpeed;           // 0.5 ~ 2.0

  factory UserPreferences.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

// ─── 反馈枚举 ───
enum FeedbackAction { like, dislike, delete, bookmark }

// ─── 语气引擎模型（运行期，非持久化） ───
enum ToneAction { allow, demote, block }

class ToneRule {
  final String type;           // "keyword" | "regex"
  final RegExp pattern;        // 编译后的正则
  final ToneAction action;     // block / demote / allow
  final String reason;         // 规则说明文案
}

class PolicyConfig {
  final String policy;         // "normal" | "strict" | "relaxed"
  final List<ToneRule> rules;
}

class ToneEngine {
  Map<String, PolicyConfig> _categories = {};
  String _defaultPolicy = 'normal';

  Future<void> loadRules();    // 从 assets/config/tone_rules.json 加载
  ToneResult evaluate(ContentItem item);
  List<ContentItem> filter(List<ContentItem> items);  // block 剔除，demote 移后
}
```

> **设计简化**：v3.1 去掉了 `toneScore` 和 `isRead` 字段。toneScore 改为运行期动态计算（ToneEngine 直接返回过滤后列表），不持久化到缓存。isRead 由外层 FeedState 追踪，不在数据模型中存储。

---

## 九、路线图（v3.0 修订版）

### Phase 1 — 启动期（2026 Q3）
**目标：无后端闭环 MVP 跑通**
- [x] Flutter 项目骨架 + CI/CD + 镜像推送脚本
- [x] Spec v3.1 深度设计
- [x] RSS 源实测筛选（10 可用源 + sources.json）
- [x] 语气引擎 v1（配置驱动，按分类 block/demote/allow）
- [x] RSS 抓取器（webfeed + Dio，支持 RSS 2.0 + Atom）
- [x] TTS ChangeNotifier 修复（语速持久化）
- [ ] FeedController 对接真实 RSS（代替演示数据）
- [ ] "今日"内容流：拉取 → 语气过滤 → 反偏好过滤 → 展示
- [ ] 反偏好学习（用户反馈 → 本地黑名单 → 影响排序）
- [ ] 日限制逻辑（最多 10 条）
- [ ] 分享邀请（通过链接分享 APK 下载）
- [ ] 语音输入（兴趣描述 / 内容搜索 / 添加 RSS 源）
- [ ] 三空间导航（今日 / 听 / 我）
- [ ] 内容源管理界面（添加/删除/启禁用）
- [ ] 离线缓存（JSON 文件）

**交付 v0.4.0**：可用，验证闭环

### Phase 2 — 打磨期（2026 Q4）
- [ ] 语气引擎 v2（更多规则 + 句式分析）
- [ ] 听专题功能（同类内容打包播放）
- [ ] 离线预缓存（WiFi 下提前下载全文）
- [ ] 睡眠定时
- [ ] 播放列表管理
- [ ] 更多优质 RSS 源（扩展至 20+）

**交付 v0.6.0**：体验稳定

### Phase 3 — 扩展期（2027 Q1-Q2）
- [ ] 视频内容支持
- [ ] 自定义内容源
- [ ] 语气引擎 V2（专用小模型）
- [ ] 隐私模式（端到端加密）

**交付 v1.0.0**：正式版

### Phase 4 — 深入期（2027 H2 ~ 2028）
- [ ] 个性化专题推荐
- [ ] 多端同步（端到端加密）
- [ ] 公益联动（用户行为可兑捐）

**交付 v2.0.0**：品牌成熟

### Phase 5 — 影响期（2029+）
- [ ] 多语言（英、日、法、阿拉伯）
- [ ] 公益组织 API 直连
- [ ] 开放平台（白噪音 / 朗读音色 / 公益主题源）
- [ ] 公益版（无任何商业化）

---

## 十、关键指标

### 用户体验指标
- **会话时长**：30 分钟以内（软引导）
- **日活粘性**：每周 4+ 次使用
- **内容满意度**：用户对 5 条推荐的"❤️ + 🗑️" 比例 ≥ 60%
- **TTS 使用率**：≥ 30% 用户每天至少听一次

### 技术指标
- **冷启动到首屏**：≤ 2.5s
- **APK 大小**：≤ 25MB
- **首屏 FPS**：稳定 60fps
- **TTS 启动延迟**：≤ 1.5s
- **抓取成功率**：≥ 95%

---

## 十一、当前状态

| 项目 | 状态 |
|------|------|
| Flutter 项目骨架 | ✅ |
| CI/CD 自动化构建 + 镜像推送 | ✅ |
| Spec 文档（v3.1） | ✅ |
| RSS 源实测 + 筛选（17 可用 / 4 不可用） | ✅ |
| assets/config/sources.json（17 源，配置驱动） | ✅ |
| assets/config/tone_rules.json（按分类配置） | ✅ |
| assets/config/app_config.json（更新 URL 配置） | ✅ |
| FeedFetcher（webfeed + Dio，User-Agent，RSS + Atom + JSON Feed） | ✅ |
| ToneEngine（分类匹配，取最严重 action） | ✅ |
| TTS ChangeNotifier 修复 + 测试 | ✅ |
| FeedController 对接真实 RSS（替代演示数据） | ✅ |
| 反偏好黑名单持久化（dislike 自动提取关键词） | ✅ |
| 日限制逻辑（10 条/天，手动刷新可突破） | ✅ |
| 分享邀请（非用户通过链接下载 APK） | ✅ |
| 语音输入（依赖已添加，UI 占位） | 🔨 进行中 |
| 自动更新（GitHub Releases API + APK 下载安装） | ✅ |
| 听空间（语音专题） | ⏳ 待开始 |
| 内容源管理界面 | ⏳ 待开始 |
| 听专题、播放列表、后台播放 | ⏳ Phase 2 |

---

## 十二、未来扩展可能性

> 这些是可能但**不承诺**的方向，等核心场景验证后再决定

- 🌍 **公益主题内容源**：与世界自然基金会(WWF)、联合国儿童基金会(UNICEF)合作专区
- 📖 **听书功能**：朗读整本书，与出版方合作
- 🎙 **用户自制语音**：让用户为家人录制专属"晚安故事"
- 🌐 **多语言模式**：原版 + 翻译版同时听
- 🧓 **长辈模式**：更大字体、简化操作、方言 TTS

---

> 悠悠时光，安静地了解世界。  
> 愿普天之下皆为净土。
