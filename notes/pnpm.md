```sh
# 安装子项目依赖
pnpm add npmlog --filter @orgnization/utils  // --filter 表示要作用到哪个子项目

# 链接本地库文件
pnpm add @orgnization/utils --filter @orgnization/core // 在 core 里引用 utils
```
