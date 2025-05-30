[来源](https://juejin.cn/post/7016593221815910408)

### HTTP 和 HTTPS

#### http 和 https 的基本概念

http: 是一个客户端和服务器端请求和应答的标准（TCP），用于从 WWW 服务器传输超文本到本地浏览器的超文本传输协议。

https: 是以安全为目标的 HTTP 通道，即 HTTP 下 加入 SSL 层进行加密。其作用是：建立一个信息安全通道，来确保数据的传输，确保网站的真实性。

#### http 和 https 的区别及优缺点？

- http 是超文本传输协议，信息是明文传输，HTTPS 协议要比 http 协议安全，https 是具有安全性的 ssl 加密传输协议，可防止数据在传输过程中被窃取、改变，确保数据的完整性(当然这种安全性并非绝对的，对于更深入的 Web 安全问题，此处暂且不表)。
- http 协议的默认端口为 80，https 的默认端口为 443。
- http 的连接很简单，是无状态的。https 握手阶段比较费时，会使页面加载时间延长 50%，增加 10%~20%的耗电。
- https 缓存不如 http 高效，会增加数据开销。
- Https 协议需要 ca 证书，费用较高，功能越强大的证书费用越高。
- SSL 证书需要绑定 IP，不能再同一个 IP 上绑定多个域名，IPV4 资源支持不了这种消耗。

#### https 协议的工作原理

客户端在使用 HTTPS 方式与 Web 服务器通信时有以下几个步骤：

1. 客户端使用 https url 访问服务器，则要求 web 服务器建立 ssl 链接。
2. web 服务器接收到客户端的请求之后，会将网站的证书（证书中包含了公钥），传输给客户端。
3. 客户端和 web 服务器端开始协商 SSL 链接的安全等级，也就是加密等级。
4. 客户端浏览器通过双方协商一致的安全等级，建立会话密钥，然后通过网站的公钥来加密会话密钥，并传送给网站。
5. web 服务器通过自己的私钥解密出会话密钥。
6. web 服务器通过会话密钥加密与客户端之间的通信。

### 扩展

#### http 缓存字段

Expires: 响应头，代表该资源的过期时间。

Cache-Control: 请求/响应头，缓存控制字段，精确控制缓存策略。

If-Modified-Since: 请求头，资源最近修改时间，由浏览器告诉服务器。

Last-Modified: 响应头，资源最近修改时间，由服务器告诉浏览器。

Etag: 响应头，资源标识，由服务器告诉浏览器。

If-None-Match: 请求头，缓存资源标识，由浏览器告诉服务器。

#### 为什么要了解 http/https

1. 正如上面所说 "SSL 证书需要绑定 IP，不能再同一个 IP 上绑定多个域名", 在做前端应用时, 为了保证项目的可移植性, 要善于利用路由设计应用整体
2. 处理跨域时, 需要快速定位产生跨域的原因, 并制定解决方案. JSONP/CORS 服务配置安全域名/\<iframe + windows.postMessage\>

### 开发环境配置 SSL 证书

#### 创建证书和私钥

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /usr/local/etc/nginx/ssl/nginx-selfsigned.key -out /usr/local/etc/nginx/ssl/nginx-selfsigned.crt
```

- keyout：私钥保存路径（如 /usr/local/etc/nginx/ssl/nginx-selfsigned.key）。
- out：证书保存路径（如 /usr/local/etc/nginx/ssl/nginx-selfsigned.crt）。
- days 365：证书有效期（1 年）。
- newkey rsa:2048：生成 2048 位的 RSA 密钥。

#### nginx 配置

```bash
# 配置 https
server {
    listen 443 ssl;
    server_name localhost;  # 替换为你的域名或 IP

    ssl_certificate /usr/local/etc/nginx/ssl/nginx-selfsigned.crt;
    ssl_certificate_key /usr/local/etc/nginx/ssl/nginx-selfsigned.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        root /usr/local/var/www;  # 替换为你的网站根目录
        index index.html index.htm;
    }
}
# 重定向
server {
    listen 80;
    server_name localhost;  # 替换为你的域名或 IP

    return 301 https://$host$request_uri;
}
```
