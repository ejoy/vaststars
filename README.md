Please visit these Chinese pages by using something like Google or Deepl translate.

# Red Frontier

![Screenshot](https://github.com/ejoy/vaststars/blob/master/screenshot/startup.jpg)

Red Frontier （项目名为 vaststars）是由[灵犀互娱](https://www.lingxigames.com/)开发的一款工厂建设类手机游戏。

它深受 Factorio 、Plan B: Terraform 等游戏的启发，讲述的是一个关于修建自动化工厂开拓红色星球的故事。

它是 [开源游戏引擎 Ant](https://github.com/ejoy/ant) 的第一个项目，由引擎开发组配合三人游戏开发组（其中，程序、策划、美术各一人）从 2021 年底开发至今。灵犀互娱于 2024 年初将此游戏项目全部（包括并不限于代码以及美术资产）捐赠给 Ant 引擎项目，以作为引擎的使用范例，帮助 Ant Engine 用户理解引擎。本游戏项目和 Ant Engine 同样采用了 MIT 开源许可证。

由于游戏项目开始之初所用的 Ant Engine 和今天的引擎版本已有了巨大的变化。游戏实现一直在跟随着这些变化，但难免还有许多旧的使用模式未能及时更新到引擎最新的推荐方法。所以，不应把游戏的全部实现当作 Ant 引擎的最佳实践。如有疑问，可在 [Discussions](https://github.com/ejoy/vaststars/discussions) 区参与讨论。

游戏专门为手机设计，在触摸屏操作上做了大量的设计，且暂时没有考虑在 PC 上发行。虽然可以从本仓库中构建出 Windows 或 Mac 版本，但仅供开发测试使用。如想获得较佳的游戏体验，需要自行构建 iOS 版本。

## Play Game

目前游戏的技术部分基本完成，可以用于 Ant Engine 的使用参考。但游戏部分还在开发中，游戏性方面尚有很多工作要做，目前并未达到可畅玩的水准。

如果希望体验一下游戏的雏形，建议先进入教学模式完成教学关卡，了解游戏的基本操作。然后可以从冒险模式开始沙盒游玩。

**注意：在目前这一开发阶段，所有游戏存档文件都不保证随着开发一直可用。**

## Build Game

### 编译

#### PC版本

可参考 Ant 的 [编译指南](https://github.com/ejoy/ant/blob/master/README.md)

#### iOS版本

1. 编译macos版本，用于运行构建工具
``` bash
luamake
luamake tools -mode release
```
2. 编译ios版本
``` bash
luamake -os ios
```
3. 资源打包
``` bash
./bin/macos/debug/vaststars -p ios
```
4. 用xcode打开[ios工程](https://github.com/ejoy/vaststars/tree/master/runtime/ios/vaststars)，生成ipa

### 运行

运行 PC 版游戏
``` bash
./bin/msvc/debug/vaststars.exe
```

运行编辑器
``` bash
./bin/msvc/debug/vaststars.exe -d
```

运行文件服务器
``` bash
./bin/msvc/debug/vaststars.exe -s
```

资源打包
``` bash
./bin/msvc/debug/vaststars.exe -p
```

运行其他工具(例如运行ant中的test/simple)
``` bash
./bin/msvc/debug/vaststars.exe [lua path]
```

### iOS 版本

构建完 iOS App 后，可将手机通过 USB 连接到 PC 开发机上，并在 PC 上运行 iTunes 以及 Ant 文件服务器。

在开发机的文件服务器开启时，在 PC 上的大多数修改，都能在 iOS App 运行期间同步到手机，在下次 App 运行时生效。另可通过浏览器查看本地 9000 端口打开 web 控制台。
