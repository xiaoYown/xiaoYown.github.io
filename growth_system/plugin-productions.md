## 插件/扩展 产品

### vscode

- [官方文档](https://code.visualstudio.com/api)

_开发语言_: typescript

> 插件目录结构


```
.
├── .vscode
│   ├── launch.json     // Config for launching and debugging the extension
│   └── tasks.json      // Config for build task that compiles TypeScript
├── .gitignore          // Ignore build output and node_modules
├── README.md           // Readable description of your extension's functionality
├── src
│   └── extension.ts    // Extension source code
├── package.json        // Extension manifest
├── tsconfig.json       // TypeScript configuration
```

> 清单文件


```json
{
  "name": "helloworld-sample",
  "displayName": "helloworld-sample",
  "description": "HelloWorld example for VS Code",
  "version": "0.0.1",
  "publisher": "vscode-samples",
  "repository": "https://github.com/microsoft/vscode-extension-samples/helloworld-sample",
  "engines": {
    "vscode": "^1.51.0"
  },
  "categories": ["Other"],
  "activationEvents": ["onCommand:helloworld.helloWorld"],
  "main": "./out/extension.js",
  "contributes": {
    "commands": [
      {
        "command": "helloworld.helloWorld",
        "title": "Hello World"
      }
    ]
  },
  "scripts": {
    "vscode:prepublish": "npm run compile",
    "compile": "tsc -p ./",
    "watch": "tsc -watch -p ./"
  },
  "devDependencies": {
    "@types/node": "^8.10.25",
    "@types/vscode": "^1.51.0",
    "tslint": "^5.16.0",
    "typescript": "^3.4.5"
  }
}
```

> 信息收集


_扩展可对应用本身部分的修改能力(例子)_

- **通用功能**: 注册命令、配置、键绑定或上下文菜单项
- **主题**: 更改源代码的颜色
- **声明性语言特性**: 向 VS Code 介绍一种新的编程语言
- **工作台扩展**: 定义一个新的活动栏视图
- **工作台扩展**: 使用 WebView API 呈现自定义内容

_测试与发布_

```sh
# - Launches VS Code Extension Host
# - Loads the extension at <EXTENSION-ROOT-PATH>
# - Executes the test runner script at <TEST-RUNNER-SCRIPT-PATH>
code \
--extensionDevelopmentPath=<EXTENSION-ROOT-PATH> \
--extensionTestsPath=<TEST-RUNNER-SCRIPT-PATH>
```

```sh
npm install -g vsce
vsce package
# myExtension.vsix generated
vsce publish
# <publisherID>.myExtension published to VS Code Marketplace
```

---

### IntelliJ IDEA

_开发语言:_ kotlin

- [官方文档](https://plugins.jetbrains.com/docs/intellij/welcome.html)
- [模板](https://github.com/JetBrains/intellij-platform-plugin-template)

> The most common types of plugins include:


- UI Themes
- Custom language support
- Framework integration
- Tool integration
- User interface add-ons

### chrome

- [官方文档](https://developer.chrome.com/docs/extensions/)
- [模板](https://github.com/GoogleChrome/chrome-extensions-samples)

> 清单文件 - manifest.json


```json
{
  // Required
  "manifest_version": 3,
  "name": "My Extension",
  "version": "versionString",

  // Recommended
  "action": {...},
  "default_locale": "en",
  "description": "A plain text description",
  "icons": {...},

  // Optional
  "author": ...,
  "automation": ...,
  "background": {
    // Required
    "service_worker": "background.js",
    // Optional
    "type": ...
  },
  "chrome_settings_overrides": {...},
  "chrome_url_overrides": {...},
  "commands": {...},
  "content_capabilities": ...,
  "content_scripts": [{...}],
  "content_security_policy": {...},
  "converted_from_user_script": ...,
  "cross_origin_embedder_policy": {"value": "require-corp"},
  "cross_origin_opener_policy": {"value": "same-origin"},
  "current_locale": ...,
  "declarative_net_request": ...,
  "devtools_page": "devtools.html",
  "differential_fingerprint": ...,
  "event_rules": [{...}],
  "externally_connectable": {
    "matches": ["*://*.example.com/*"]
  },
  "file_browser_handlers": [...],
  "file_system_provider_capabilities": {
    "configurable": true,
    "multiple_mounts": true,
    "source": "network"
  },
  "homepage_url": "https://path/to/homepage",
  "host_permissions": [...],
  "import": [{"id": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}],
  "incognito": "spanning, split, or not_allowed",
  "input_components": ...,
  "key": "publicKey",
  "minimum_chrome_version": "versionString",
  "nacl_modules": [...],
  "natively_connectable": ...,
  "oauth2": ...,
  "offline_enabled": true,
  "omnibox": {
    "keyword": "aString"
  },
  "optional_permissions": ["tabs"],
  "options_page": "options.html",
  "options_ui": {
    "chrome_style": true,
    "page": "options.html"
  },
  "permissions": ["tabs"],
  "platforms": ...,
  "replacement_web_app": ...,
  "requirements": {...},
  "sandbox": [...],
  "short_name": "Short Name",
  "storage": {
    "managed_schema": "schema.json"
  },
  "system_indicator": ...,
  "tts_engine": {...},
  "update_url": "https://path/to/updateInfo.xml",
  "version_name": "aString",
  "web_accessible_resources": [...]
}
```

---

### sketch

_开发语言_: Javascript/Object-C

- [官方文档](https://developer.sketch.com/)

> 插件目录结构


```
select-shapes.sketchplugin
  Contents/
    Sketch/
      manifest.json
      circles.js
      rectangles.js
      shared.js
    Resources/
      icon.png
```

> 清单文件


```json
{
  "author": "",
  "commands": [
    {
      "script": "command.js",
      "name": "Greeting",
      "handlers": {
        "run": "onRun"
      },
      "identifier": "messages.greeting"
    }
  ],
  "menu": {
    "title": "Message…",
    "items": ["messages.greeting"]
  },
  "identifier": "com.bohemiancoding.sketch.messages",
  "version": "1.0",
  "description": "An introduction on how to build plugins.",
  "authorEmail": "developer@sketch.com",
  "name": "Messages"
}
```

> 创建步骤


```sh
npm install -g skpm
skpm --help
skpm create my-plugin
```

### blender

_开发语言_: python

- [官方文档](https://docs.blender.org/manual/zh-hans/dev/advanced/scripting/addon_tutorial.html#intended-audience)
