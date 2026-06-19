# 颅脑测试 - 推代码前自查

## 不需要 Flutter 环境，纯手动检查

---

### ✅ 1. 文件检查

```bash
# 确认这些文件存在
lib/main.dart
lib/app.dart
pubspec.yaml
android/app/src/main/AndroidManifest.xml
assets/config/sources.json
assets/config/tone_rules.json
```

### ✅ 2. 依赖版本检查

打开 `pubspec.yaml`，确认：
- 没有重复的依赖声明
- 版本号格式正确（如 `^5.0.2`）
- SDK 版本约束合理（`sdk: ^3.2.0`）

### ✅ 3. Import 检查

打开修改过的 `.dart` 文件，确认：
- 所有 import 路径正确（不存在的文件）
- 没有重复 import
- 没有未使用的 import

### ✅ 4. 语法检查

打开修改过的 `.dart` 文件，确认：
- 没有明显的语法错误（缺少分号、括号不匹配）
- 字符串引号闭合
- 类名/方法名拼写正确

### ✅ 5. AndroidManifest 检查

打开 `android/app/src/main/AndroidManifest.xml`，确认：
- 有 `android:usesCleartextTraffic="true"`（HTTP 源需要）
- 有 `<uses-permission android:name="android.permission.INTERNET"/>`

### ✅ 6. 新文件检查

如果新增了文件：
- 确认文件路径正确（`lib/domain/...`）
- 确认文件名符合命名规范（`snake_case.dart`）
- 确认导出路径在 barrel file 中更新

### ✅ 7. 代码风格检查

- 没有 `print()` 调试语句残留
- 没有 `// TODO` 未处理
- 变量命名清晰

---

## 快速检查命令（不需要 Flutter）

```bash
# 检查 pubspec.yaml 语法
cat pubspec.yaml | grep -E "^\s+[a-z].*:.*\^"

# 检查是否有语法错误的文件
grep -rn "class.*{" lib/ | head -20

# 检查 import 是否有不存在的路径
grep -rn "import '" lib/ | grep -v "package:" | head -20
```

---

## 如果不确定，就先推到分支测试

```bash
git checkout -b test-xxx
git push origin test-xxx
# 等 CI 通过后再合并到 main
```
