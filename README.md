# 5700webui-server

基于 Flutter 的 5700 模块 WebUI 管理应用

## 功能特点

- ✅ AT 命令控制台 - 直接与 5700 模块通信
- ✅ WebSocket 服务器 - 为 Web 前端提供接口
- ✅ HTTP 静态服务器 - 内置 Web 管理界面
- ✅ WebView 集成 - 在应用内访问 Web 界面
- ✅ TCP 直连模式 - 连接 192.168.8.1:20249
- ✅ 深色/浅色主题 - TDesign/Ant Design 配色
- ✅ 实时日志 - 自动滚动显示
- ✅ 配置管理 - 持久化设置

## 技术栈

- **Framework**: Flutter 3.7+
- **状态管理**: GetX
- **UI**: Material Design 3 + TDesign 配色
- **网络**: dart:io Socket (TCP), shelf (HTTP/WebSocket)
- **本地存储**: shared_preferences

## 快速开始

### 安装 APK

直接安装编译好的 APK（推荐 arm64-v8a 版本）：

```bash
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

### 从源码构建

1. 安装 Flutter SDK (3.7+)
2. 克隆项目并进入目录
3. 获取依赖并构建：

```bash
cd flutter_app
flutter pub get
flutter build apk --release --split-per-abi
```

## APK 体积

- **通用版**: 52.3 MB (所有架构)
- **arm64-v8a**: 19.4 MB (现代手机，推荐)
- **armeabi-v7a**: 17.0 MB (旧设备)
- **x86_64**: 20.6 MB (模拟器)

## 使用说明

### 1. 连接设备

- 打开应用，进入"设置"页面
- 配置 TCP 连接（默认: 192.168.8.1:20249）
- 启用"自动连接"

### 2. AT 控制台

- 在"AT控制台"页面输入 AT 命令
- 查看实时响应（自动滚动到最新）
- 使用快捷命令按钮

### 3. Web 界面

- 点击"Web界面"标签
- 应用内嵌 WebView 访问管理界面
- WebSocket 服务器运行在 8765 端口

## 配置说明

- **TCP 地址**: 192.168.8.1:20249 (5700 模块默认)
- **WebSocket 端口**: 8765
- **主题模式**: 跟随系统/浅色/深色

## 项目结构

```
flutter_app/
├── lib/
│   ├── app/
│   │   ├── core/         # 核心配置（主题等）
│   │   ├── data/         # 数据模型
│   │   ├── modules/      # 功能模块
│   │   ├── routes/       # 路由配置
│   │   └── services/     # 服务层（TCP、WebSocket等）
│   └── main.dart
├── assets/
│   └── web/             # 内置 Web 前端
└── android/             # Android 平台配置
```

## 开发指南

详见 [flutter_app/README.md](flutter_app/README.md)

## 许可证

MIT License

## 更新日志

### v1.0.0 (2025-10-10)
- ✅ 初始版本发布
- ✅ TDesign 配色系统
- ✅ 深色模式支持
- ✅ 自动滚动日志
- ✅ WebUI 集成
- ✅ 分架构 APK (体积优化)
