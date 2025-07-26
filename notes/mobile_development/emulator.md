## IOS

### 查询设备类别

```sh
xcrun simctl list devices
```

### 启动模拟器

```sh
xcrun simctl boot <device-udid>
open -a Simulator
```
如果设备已经启动，就不需要重复 boot，只需要 open -a Simulator。

## Android

### 查询设备列表

```sh
# emulator 根据实际路径使用($ANDROID_HOME/emulator)
~/Library/Android/sdk/emulator/emulator -list-avds
```

### 启动模拟器

```sh
~/Library/Android/sdk/emulator/emulator -avd Pixel_9
```