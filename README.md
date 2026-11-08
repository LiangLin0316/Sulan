# 速栏 · Sulan

在 macOS 右上角菜单栏显示实时网速。上行的 `↓` 显示下载，下行的 `↑` 显示上传，每秒更新一次。点击菜单栏图标可查看数值或退出。

## 下载与安装

**[直接下载 DMG（v1.0.2 测试版）](https://github.com/LiangLin0316/Sulan/releases/download/v1.0.2/Sulan-1.0.2-Universal-Test.dmg)** · [发布说明](https://github.com/LiangLin0316/Sulan/releases/tag/v1.0.2)

适用于 macOS 13 及以上，支持 Apple 芯片和 Intel。打开下载的 DMG，把 `Sulan.app` 拖进「应用程序」，再从那里启动。测试版未经 Apple 公证，首次打开时 macOS 可能拦截。

## 从源码运行

用支持 Swift 6 的 Xcode 打开 `Sulan.xcodeproj`，按 `⌘R` 启动。应用启动后出现在菜单栏。

也可以在项目目录通过命令行构建并运行。

```sh
xcodebuild -project Sulan.xcodeproj -scheme Sulan -configuration Release -destination 'platform=macOS' -derivedDataPath build build
open build/Build/Products/Release/Sulan.app
```

## 采样范围

应用通过 macOS 的 `sysctl` 读取启用的 `en*` 网卡的 64 位收发计数，按两次采样间的实际时间计算速率。通常覆盖 Wi-Fi 和有线网卡。回环、桥接和 VPN 隧道接口不单独计入，经过物理网卡的 VPN 流量仍计入。应用不会发起测速请求。

显示单位为十进制字节每秒，`1 KB/s = 1000 B/s`。应用的最低部署目标为 macOS 13。

## 许可

源码与安装包采用 [PolyForm Strict 1.0.0](LICENSE)。该许可允许非商业用途，不授予商业使用、修改或再分发的权限。欢迎分享项目的发布页链接。
