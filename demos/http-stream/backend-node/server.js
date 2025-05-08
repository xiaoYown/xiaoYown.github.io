import express from 'express';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';
import http2 from 'http2';
import fs from 'fs';

/**
 * 服务器配置常量
 * @constant
 * @type {Object}
 */
const CONFIG = {
  /** 服务器监听端口 */
  PORT: 3000,

  /** 文件路径相关配置 */
  PATHS: {
    /** 前端静态文件目录 */
    FRONTEND: '../frontend',
    /** SSL 证书目录 */
    CERT: '../../cert',
    /** 默认首页文件 */
    DEFAULT_FILE: '/index.html',
    /** 缓存目录路径 */
    CACHE: '../.cache',
    /** 上传文件的缓存文件名 */
    CACHE_FILE: 'uploaded_text.txt',
    /** 示例文本的文件名（与上传文件相同） */
    SAMPLE_TEXT: 'uploaded_text.txt'
  },

  /** 流传输相关配置 */
  STREAM: {
    /** 每个数据块的大小（字节），较小的值可以实现更细腻的传输控制 */
    CHUNK_SIZE: 20,
    /** 数据块发送间隔（毫秒），控制传输速度，值越小传输越快 */
    INTERVAL: 40
  },

  /** CORS（跨源资源共享）配置 */
  CORS: {
    /** 允许的源，* 表示允许所有源 */
    origin: '*',
    /** 允许的 HTTP 方法 */
    methods: ['GET', 'POST'],
    /** 允许的请求头 */
    allowedHeaders: ['Content-Type', 'Connection', 'Accept-Encoding']
  },

  /** MIME 类型映射配置 */
  MIME_TYPES: {
    /** HTML 文件的 MIME 类型 */
    '.html': 'text/html',
    /** JavaScript 文件的 MIME 类型 */
    '.js': 'text/javascript',
    /** CSS 文件的 MIME 类型 */
    '.css': 'text/css',
    /** JSON 文件的 MIME 类型 */
    '.json': 'application/json',
    /** PNG 图片的 MIME 类型 */
    '.png': 'image/png',
    /** JPEG 图片的 MIME 类型 */
    '.jpg': 'image/jpeg',
    /** GIF 图片的 MIME 类型 */
    '.gif': 'image/gif'
  }
};

// 文件路径配置
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * 存储类 - 管理上传的文本内容
 */
class TextStore {
  constructor() {
    this.cachePath = path.join(__dirname, CONFIG.PATHS.CACHE);
    this.uploadedTextPath = path.join(this.cachePath, CONFIG.PATHS.CACHE_FILE);
    this.sampleTextPath = path.join(this.cachePath, CONFIG.PATHS.SAMPLE_TEXT);
    this.initializeStore();
  }

  /**
   * 初始化存储
   * 确保缓存目录存在并创建示例文本
   */
  initializeStore() {
    try {
      if (!fs.existsSync(this.cachePath)) {
        fs.mkdirSync(this.cachePath, { recursive: true });
      }

      if (!fs.existsSync(this.sampleTextPath)) {
        const sampleText = 'This is a sample streaming text. '.repeat(100);
        fs.writeFileSync(this.sampleTextPath, Buffer.from(sampleText), 'binary');
      }
    } catch (error) {
      console.error('Failed to initialize store:', error);
      throw new Error('Store initialization failed');
    }
  }

  /**
   * 保存二进制数据到文件
   * @param {Buffer} data - 要保存的二进制数据
   * @throws {Error} 如果写入失败
   */
  save(data) {
    try {
      fs.writeFileSync(this.uploadedTextPath, data, 'binary');
    } catch (error) {
      console.error('Failed to save data:', error);
      throw new Error('Failed to save data');
    }
  }

  /**
   * 获取示例文本的二进制数据
   * @returns {Buffer} 二进制数据
   * @throws {Error} 如果读取失败
   */
  getSampleText() {
    try {
      return fs.readFileSync(this.sampleTextPath);
    } catch (error) {
      console.error('Failed to read sample text:', error);
      throw new Error('Failed to read sample text');
    }
  }

  /**
   * 获取上传的二进制数据
   * @returns {Buffer} 二进制数据，如果不存在则返回空 Buffer
   */
  getUploadedText() {
    try {
      if (fs.existsSync(this.uploadedTextPath)) {
        return fs.readFileSync(this.uploadedTextPath);
      }
      return Buffer.alloc(0);
    } catch (error) {
      console.error('Failed to read uploaded text:', error);
      return Buffer.alloc(0);
    }
  }

  /**
   * 清理缓存文件
   */
  cleanup() {
    try {
      if (fs.existsSync(this.uploadedTextPath)) {
        fs.unlinkSync(this.uploadedTextPath);
      }
    } catch (error) {
      console.error('Failed to cleanup cache:', error);
    }
  }
}

/**
 * HTTP/2 服务器类
 */
class HTTP2Server {
  constructor() {
    this.app = express();
    this.textStore = new TextStore();
    this.setupExpress();
    this.setupServer();
  }

  /**
   * 配置 Express 中间件
   */
  setupExpress() {
    this.app.use(cors(CONFIG.CORS));
    this.app.use(express.static(path.join(__dirname, CONFIG.PATHS.FRONTEND)));
  }

  /**
   * 配置 HTTP/2 服务器
   */
  setupServer() {
    const certPath = path.join(__dirname, CONFIG.PATHS.CERT);
    const options = {
      key: fs.readFileSync(path.join(certPath, 'private.key')),
      cert: fs.readFileSync(path.join(certPath, 'certificate.crt')),
      allowHTTP1: true
    };

    this.server = http2.createSecureServer(options);
    this.server.on('stream', this.handleStream.bind(this));
  }

  /**
   * 处理 HTTP/2 流
   * @param {http2.ServerHttp2Stream} stream - HTTP/2 流
   * @param {http2.IncomingHttpHeaders} headers - 请求头
   */
  handleStream(stream, headers) {
    const reqPath = headers[':path'];
    const method = headers[':method'];

    try {
      switch (true) {
        case reqPath === '/upload' && method === 'POST':
          this.handleUpload(stream);
          break;
        case reqPath === '/download' && method === 'GET':
          this.handleDownload(stream);
          break;
        default:
          this.handleStaticFile(stream, reqPath);
      }
    } catch (error) {
      this.handleError(stream, error);
    }
  }

  /**
   * 处理文件上传
   * @param {http2.ServerHttp2Stream} stream - HTTP/2 流
   */
  handleUpload(stream) {
    const chunks = [];
    
    stream.on('data', chunk => {
      // 确保 chunk 是 Buffer 类型
      chunks.push(Buffer.from(chunk));
    });

    stream.on('end', () => {
      const data = Buffer.concat(chunks);
      this.textStore.save(data);
      
      // 只在这里发送一次响应
      const response = {
        message: 'Upload complete',
        bytesReceived: data.length
      };
      const jsonData = JSON.stringify(response);
      const buffer = Buffer.from(jsonData);
      
      stream.respond({
        'content-type': 'application/json',
        'content-length': buffer.length,
        ':status': 200
      });
      stream.end(buffer);
    });

    stream.on('error', error => {
      this.handleError(stream, error);
    });
  }

  /**
   * 处理文件下载
   * @param {http2.ServerHttp2Stream} stream - HTTP/2 流
   */
  handleDownload(stream) {
    const data = this.textStore.getSampleText();
    
    stream.respond({
      'content-type': 'application/octet-stream',
      'content-length': data.length,
      ':status': 200
    });

    let offset = 0;

    const streamData = () => {
      if (offset < data.length) {
        const chunk = data.slice(offset, offset + CONFIG.STREAM.CHUNK_SIZE);
        stream.write(chunk);
        offset += CONFIG.STREAM.CHUNK_SIZE;
        setTimeout(streamData, CONFIG.STREAM.INTERVAL);
      } else {
        stream.end();
      }
    };

    streamData();
  }

  /**
   * 处理静态文件请求
   * @param {http2.ServerHttp2Stream} stream - HTTP/2 流
   * @param {string} reqPath - 请求路径
   */
  handleStaticFile(stream, reqPath) {
    const filePath = reqPath === '/' ? CONFIG.PATHS.DEFAULT_FILE : reqPath;
    const fullPath = path.join(__dirname, CONFIG.PATHS.FRONTEND, filePath);

    if (!fs.existsSync(fullPath)) {
      this.sendError(stream, 404, 'Not Found');
      return;
    }

    try {
      const stat = fs.statSync(fullPath);
      const fileStream = fs.createReadStream(fullPath);

      stream.respond({
        'content-length': stat.size,
        'content-type': this.getContentType(filePath),
        ':status': 200
      });

      fileStream.pipe(stream);
    } catch (error) {
      this.handleError(stream, error);
    }
  }

  /**
   * 获取文件的 Content-Type
   * @param {string} filePath - 文件路径
   * @returns {string} Content-Type
   */
  getContentType(filePath) {
    const ext = path.extname(filePath).toLowerCase();
    return CONFIG.MIME_TYPES[ext] || 'application/octet-stream';
  }

  /**
   * 发送 JSON 响应
   * @param {http2.ServerHttp2Stream} stream - HTTP/2 流
   * @param {Object} data - 响应数据
   * @param {number} [status=200] - HTTP 状态码
   */
  sendJSON(stream, data, status = 200) {
    if (stream.headersSent) {
      console.warn('Headers already sent, cannot send JSON response');
      return;
    }
    
    const jsonData = JSON.stringify(data);
    const buffer = Buffer.from(jsonData);
    
    stream.respond({
      'content-type': 'application/json',
      'content-length': buffer.length,
      ':status': status
    });
    stream.end(buffer);
  }

  /**
   * 发送错误响应
   * @param {http2.ServerHttp2Stream} stream - HTTP/2 流
   * @param {number} status - HTTP 状态码
   * @param {string} message - 错误消息
   */
  sendError(stream, status, message) {
    stream.respond({ ':status': status });
    stream.end(message);
  }

  /**
   * 处理服务器错误
   * @param {http2.ServerHttp2Stream} stream - HTTP/2 流
   * @param {Error} error - 错误对象
   */
  handleError(stream, error) {
    console.error('Server error:', error);
    this.sendError(stream, 500, 'Internal Server Error');
  }

  /**
   * 启动服务器
   */
  start() {
    this.server.listen(CONFIG.PORT, () => {
      console.log(`HTTP/2 Server running at https://localhost:${CONFIG.PORT}`);
    });
  }
}

// 创建并启动服务器
const server = new HTTP2Server();
server.start(); 