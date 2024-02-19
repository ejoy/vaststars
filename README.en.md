# Red Frontier

![Screenshot](https://github.com/ejoy/vaststars/blob/master/screenshot/startup.jpg)

Red Frontier (project name vaststars）is a factory construction mobile game developed by [Lingxi Interactive Entertainment](https://www.lingxigames.com/).

Inspired by games such as Factorio and Plan B: Terraform, it tells a story about building automated factories to colonize the Red Planet.

It is the first project of the open source game engine [Ant](https://github.com/ejoy/ant). It has been developed by the engine development team in cooperation with a three-person game development team (including one person each for programming, planning, and art) from the end of 2021 to the present. Lingxi Interactive Entertainment will donate all of this game project (including but not limited to code and art assets) to the Ant Engine project in early 2024 to serve as an example of how to use the engine and help Ant Engine users understand the engine. This game project and Ant Engine also use the MIT open source license.

There have been huge changes since the Ant Engine was used when the game project started and today's version of the engine. Game implementations have been following these changes, but inevitably there are still many old usage patterns that have not been updated in time to the latest recommended methods of the engine. Therefore, the complete implementation of the game should not be considered as best practice for the Ant engine. If you have any questions, you can participate in the discussion in the [Discussions](https://github.com/ejoy/vaststars/discussions) area.

The game is specially designed for mobile phones, with a lot of design work on touch screen operations, and is not currently considered for release on PC. While it is possible to build a Windows or Mac version from this repository, it is for development and testing purposes only. If you want to get a better gaming experience, you need to build the iOS version yourself.

## Play Game

At present, the technical part of the game is basically completed and can be used as a reference for the use of Ant Engine. However, the game is still under development, and there is still a lot of work to be done in terms of gameplay. It has not yet reached a playable level.

If you want to experience the prototype of the game, it is recommended to enter the teaching mode first to complete the teaching level and understand the basic operations of the game. Sandbox play can then be started in Adventure mode.

**NOTE: At this current stage of development, all game save files are not guaranteed to be available as development continues.**

## Build Game

### Compile

#### PC Version

Please refer to [Ant’s compilation guide](https://github.com/ejoy/ant/blob/master/README.md)

#### iOS Version

1. Compile the macOS version for running the build tool
``` bash
luamake
luamake tools -mode release
```
2. Compile iOS version
``` bash
luamake -os ios
```
3. Resource packaging
``` bash
./bin/macos/debug/vaststars -p ios
```
4. Open the [iOS](https://github.com/ejoy/vaststars/tree/master/runtime/ios/vaststars) project with Xcode and generate ipa

### Run

Run the PC version of the game
``` bash
./bin/msvc/debug/vaststars.exe
```

Run editor
``` bash
./bin/msvc/debug/vaststars.exe -d
```

Run file server
``` bash
./bin/msvc/debug/vaststars.exe -s
```

Resource packaging
``` bash
./bin/msvc/debug/vaststars.exe -p
```

Run other tools (such as running test/simple in ant)
``` bash
./bin/msvc/debug/vaststars.exe [lua path]
```

### iOS Version

After building the iOS App, you can connect the phone to the PC development machine via USB, and run iTunes and Ant file server on the PC.

When the file server of the development machine is turned on, most modifications on the PC can be synchronized to the mobile phone while the iOS App is running, and will take effect the next time the App is run. You can also view the local 9000 port through the browser to open the web console.
