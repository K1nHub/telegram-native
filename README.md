# TDLib bindings for 1C:Enterprise

[![Build status](https://ci.appveyor.com/api/projects/status/2ium20h8q5moqkj8/branch/master?svg=true)](https://ci.appveyor.com/project/Infactum/telegram-native/branch/master)

Cross platform native API [add-in](https://1c-dn.com/library/add_in_creation_technology/) bindings for [TDLib](https://github.com/tdlib/td) (Telegram Database library) that allows to create full featured telegram clients within 1C:Enterprise platform.

## How to use

```bsl
AttachAddIn("<path>", "Telegram", AddInType.Native);
ComponentObject = New("AddIn.Telegram.TelegramNative");
```

## Build

Currently tested with tdlib 1.8.49 on Win11 24H2 host

Requirements:
- https://cmake.org/download/
- https://visualstudio.microsoft.com/ru/vs/community/ (with C++ developing)
- https://git-scm.com/downloads

1. Change ```MSVC_HOME``` variable in ```build-telegram-native.ps1```
2. If you already have builded tdlib and added it to PATH, comment line ```& .\build-tdlib.ps1 $CurrDir```
3. Run ```build-telegram-native.ps1```

Result will be in ```./build``` folder