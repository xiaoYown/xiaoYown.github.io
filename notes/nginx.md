### Nginx 配置记录

#### 静态 gzip 开启

```
  gzip_static on;                # 启用预压缩文件支持
  gzip_proxied any;              # 支持代理压缩
  gzip_min_length 1024;          # 对超过 1KB 的文件使用 gzip
  gzip_vary on;                  # 设置 Vary 响应头
  gzip_http_version 1.1;         # 针对 HTTP/1.1 客户端
  gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss image/svg+xml;
  index index.html;
```
