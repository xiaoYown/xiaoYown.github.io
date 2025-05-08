const http = require('http');
const { readFile } = require('fs/promises');
const { join } = require('path');

process.on('uncaughtException', (err) => {
  console.error('未捕获的异常:', err);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('未处理的 Promise 拒绝:', reason);
});

const server = http.createServer(async (req, res) => {
  // 添加 CORS 头
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // 处理 OPTIONS 请求
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }
  console.log(`收到请求: ${req.method} ${req.url}`);
  if (req.url === '/') {
    try {
      const htmlPath = join(__dirname, 'index.html');
      console.log(`尝试读取文件: ${htmlPath}`);
      const content = await readFile(htmlPath);
      console.log('文件读取成功，发送响应');
      res.writeHead(200, { 'Content-Type': 'text/html' });
      res.end(content);
    } catch (err) {
      console.error('读取文件失败:', err);
      res.writeHead(500);
      res.end('Error loading index.html');
    }
  } else {
    console.log('请求的路径不存在');
    res.writeHead(404);
    res.end('Not found');
  }
});

const PORT = 3000;
server.listen(PORT, () => {
  console.log(`测试服务器运行在 http://localhost:${PORT}`);
});