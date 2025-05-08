# HTTP Streaming Demo

这是一个演示 HTTP 流式传输的示例项目，包含了 Node.js、Go 和 Rust 三个版本的后端实现。项目展示了如何实现文本数据的分块传输，并包含了前端进度显示等功能。

## 项目结构

```
http-stream/
├── frontend/          # 前端代码
├── backend-node/      # Node.js 后端实现
├── backend-go/        # Go 后端实现
├── backend-rust/      # Rust 后端实现
├── cert/             # SSL 证书目录
└── .cache/           # 文件缓存目录
```

## 功能特性

- 支持文本数据的流式上传和下载
- 实时显示传输进度
- 支持 HTTP/2
- 支持 CORS
- 文件系统缓存
- 可配置的传输参数（块大小、传输间隔等）

## 后端实现

### Rust 版本

Rust 版本的后端使用了以下技术：

- Axum 框架实现 HTTP 服务
- Tokio 异步运行时
- Rustls 提供 TLS 支持
- 配置文件管理
- 文件系统存储
- 分块传输编码

开发工具：
- cargo-make：任务运行器
- cargo-watch：热重载开发

### Go 版本

Go 版本的后端使用了以下技术：

- 原生 `net/http` 包实现 HTTP 服务
- YAML 配置文件管理
- 文件系统存储
- 分块传输编码

配置文件 (`config.yaml`):
```yaml
server:
  port: 3000

stream:
  chunk_size: 10    # 每个数据块的大小（字节）
  interval: 50ms    # 数据块发送间隔
```

### Node.js 版本

Node.js 版本使用了以下技术：

- Express.js 框架
- 文件系统存储
- 分块传输编码

## 运行项目

### 前置要求

- Node.js >= 14.0.0
- Go >= 1.21 (如果运行 Go 版本)
- Rust >= 1.75 (如果运行 Rust 版本)
- SSL 证书（用于 HTTPS/HTTP2）

### 启动 Rust 后端

```bash
cd backend-rust
# 开发模式（带热重载）
cargo make dev
# 或者直接运行
cargo run
```

### 启动 Go 后端

```bash
cd backend-go
go mod tidy
go run main.go
```

### 启动 Node.js 后端

```bash
cd backend-node
npm install
node server.js
```

### 访问前端

启动后端服务后，访问：
- https://localhost:3000 (Go 版本)
- https://localhost:3000 (Node.js 版本)
- https://localhost:3000 (Rust 版本)

## 性能优化

项目包含了多项性能优化措施：

1. 使用 HTTP/2 提升传输效率
2. 可配置的块大小和传输间隔
3. 适当的缓冲区管理
4. 文件系统缓存而非内存存储

## 前端优化

1. 平滑的进度显示
2. 防抖动的状态更新
3. CSS 过渡效果
4. 整数百分比更新

## 注意事项

1. 确保 `cert` 目录下有有效的 SSL 证书
2. `.cache` 目录用于存储上传的文件，已在 `.gitignore` 中忽略
3. 配置文件中的参数可根据需要调整

## 开发说明

1. 前端代码位于 `frontend` 目录
2. 两个后端实现保持了相同的接口和行为
3. 配置文件可以根据需要修改传输参数
4. 所有文本存储均使用文件系统，避免内存占用 