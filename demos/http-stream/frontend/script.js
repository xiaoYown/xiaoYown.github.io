/**
 * 应用程序配置对象
 * @constant
 * @type {Object}
 */
const CONFIG = {
  /** API 相关配置 */
  API: {
    /** API 基础URL，使用 HTTPS 协议 */
    BASE_URL: 'https://localhost:3000',
    /** API 端点配置 */
    ENDPOINTS: {
      /** 上传接口路径 */
      UPLOAD: '/upload',
      /** 下载接口路径 */
      DOWNLOAD: '/download'
    }
  },
  /** 流传输相关配置 */
  STREAM: {
    /** 每个数据块的大小（字节） */
    CHUNK_SIZE: 1024,
    /** 数据块发送间隔（毫秒） */
    INTERVAL: 10
  },
  /** Fetch API 请求配置 */
  FETCH_OPTIONS: {
    /** 启用跨域请求 */
    mode: 'cors',
    /** 禁用缓存 */
    cache: 'no-cache',
    /** 半双工模式 */
    duplex: 'half',
    /** 请求头配置 */
    headers: {
      /** 内容类型 */
      'Content-Type': 'application/octet-stream',
      /** 保持连接 */
      'Connection': 'keep-alive',
      /** 支持的编码方式 */
      'Accept-Encoding': 'gzip, deflate, br'
    }
  },
  /** 状态显示相关配置 */
  STATUS: {
    /** 状态消息显示时长（毫秒） */
    DURATION: 3000,
    /** 状态类型定义 */
    TYPES: {
      /** 成功状态 */
      SUCCESS: 'success',
      /** 错误状态 */
      ERROR: 'error',
      /** 信息状态 */
      INFO: 'info'
    }
  }
};

// DOM 元素选择器
const DOM = {
  upload: {
    button: document.querySelector('#uploadBtn'),
    text: document.querySelector('#uploadText'),
    progress: document.querySelector('#uploadProgress'),
    status: document.querySelector('#uploadStatus')
  },
  download: {
    button: document.querySelector('#downloadBtn'),
    text: document.querySelector('#downloadText'),
    progress: document.querySelector('#downloadProgress'),
    status: document.querySelector('#downloadStatus')
  }
};

// 工具函数
const utils = {
  /**
   * 更新进度条
   * @param {HTMLElement} progressBar - 进度条元素
   * @param {number} percentage - 进度百分比
   */
  updateProgress: (progressBar, percentage) => {
    progressBar.style.width = `${Math.min(100, percentage)}%`;
  },

  /**
   * 重置进度条
   * @param {HTMLElement} progressBar - 进度条元素
   * @param {number} delay - 延迟时间（毫秒）
   */
  resetProgress: (progressBar, delay = 0) => {
    setTimeout(() => {
      progressBar.style.width = '0%';
    }, delay);
  },

  /**
   * 显示状态消息
   * @param {HTMLElement} statusElement - 状态显示元素
   * @param {string} message - 消息内容
   * @param {string} type - 消息类型（success/error/info）
   */
  showStatus: (statusElement, message, type = CONFIG.STATUS.TYPES.INFO) => {
    // 如果状态元素已经有相同的消息和类型，则不更新
    if (
      statusElement.textContent === message &&
      statusElement.className === `status-text ${type}`
    ) {
      return;
    }

    statusElement.textContent = message;
    statusElement.className = `status-text ${type}`;
    
    // 只有在不是进度更新消息时才自动清除
    if (
      type !== CONFIG.STATUS.TYPES.ERROR &&
      !message.includes('Uploading:') &&
      !message.includes('Downloading:')
    ) {
      setTimeout(() => {
        statusElement.textContent = '';
        statusElement.className = 'status-text';
      }, CONFIG.STATUS.DURATION);
    }
  },

  /**
   * 处理错误
   * @param {Error} error - 错误对象
   * @param {HTMLElement} statusElement - 状态显示元素
   */
  handleError: (error, statusElement) => {
    console.error('Operation error:', error);
    utils.showStatus(statusElement, `Error: ${error.message}`, CONFIG.STATUS.TYPES.ERROR);
  },

  // 创建 HTTP/2 fetch 请求
  createFetchRequest: (url, options = {}) => {
    return fetch(url, {
      ...CONFIG.FETCH_OPTIONS,
      ...options,
      headers: {
        ...CONFIG.FETCH_OPTIONS.headers,
        ...(options.headers || {})
      }
    });
  }
};

// 上传功能类
class Uploader {
  constructor(elements) {
    this.elements = elements;
    this.encoder = new TextEncoder();
  }

  /**
   * 创建上传流
   * @param {Uint8Array} data - 二进制数据
   * @returns {ReadableStream}
   */
  createUploadStream(data) {
    const { progress, status } = this.elements;
    const totalBytes = data.length;
    let bytesSent = 0;

    return new ReadableStream({
      start: (controller) => {
        utils.showStatus(status, 'Starting upload...', CONFIG.STATUS.TYPES.INFO);
        
        const pushChunk = () => {
          if (bytesSent >= data.length) {
            controller.close();
            return;
          }

          const chunk = data.slice(
            bytesSent,
            bytesSent + CONFIG.STREAM.CHUNK_SIZE
          );
          controller.enqueue(chunk);
          bytesSent += chunk.length;

          const percentage = (bytesSent / totalBytes) * 100;
          utils.updateProgress(progress, percentage);
          
          const roundedPercentage = Math.round(percentage);
          if (roundedPercentage % 1 === 0) {
            utils.showStatus(status, `Uploading: ${roundedPercentage}%`, CONFIG.STATUS.TYPES.INFO);
          }
          
          setTimeout(pushChunk, CONFIG.STREAM.INTERVAL);
        };

        pushChunk();
      }
    });
  }

  /**
   * 执行上传操作
   */
  async upload() {
    const { button, text, progress, status } = this.elements;

    if (!text.value.trim()) {
      utils.showStatus(status, 'Please enter some text to upload', CONFIG.STATUS.TYPES.ERROR);
      return;
    }

    button.disabled = true;

    try {
      // 将文本转换为二进制数据
      const data = this.encoder.encode(text.value);
      const stream = this.createUploadStream(data);

      const response = await utils.createFetchRequest(
        `${CONFIG.API.BASE_URL}${CONFIG.API.ENDPOINTS.UPLOAD}`,
        {
          method: 'POST',
          body: stream
        }
      );

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const result = await response.json();
      utils.updateProgress(progress, 100);
      utils.showStatus(status, 'Upload complete!', CONFIG.STATUS.TYPES.SUCCESS);
    } catch (error) {
      utils.handleError(error, status);
    } finally {
      button.disabled = false;
      utils.resetProgress(progress, CONFIG.STATUS.DURATION);
    }
  }
}

// 下载功能类
class Downloader {
  constructor(elements) {
    this.elements = elements;
    this.decoder = new TextDecoder();
  }

  /**
   * 处理下载的数据块
   * @param {Uint8Array} chunk - 二进制数据块
   * @param {object} state - 状态对象
   */
  handleChunk(chunk, state) {
    const { text, progress, status } = this.elements;
    
    state.receivedLength += chunk.length;
    
    // 将二进制数据解码为文本
    const decodedText = this.decoder.decode(chunk, { stream: true });
    state.content += decodedText;
    
    text.textContent = state.content;
    text.scrollTop = text.scrollHeight;
    
    const percentage = (state.receivedLength / state.totalLength) * 100;
    utils.updateProgress(progress, percentage);
    
    const roundedPercentage = Math.round(percentage);
    if (roundedPercentage % 1 === 0) {
      utils.showStatus(status, `Downloading: ${roundedPercentage}%`, CONFIG.STATUS.TYPES.INFO);
    }
  }

  /**
   * 执行下载操作
   */
  async download() {
    const { button, text, progress, status } = this.elements;

    button.disabled = true;
    text.textContent = '';
    utils.updateProgress(progress, 0);
    utils.showStatus(status, 'Starting download...', CONFIG.STATUS.TYPES.INFO);

    try {
      const response = await utils.createFetchRequest(
        `${CONFIG.API.BASE_URL}${CONFIG.API.ENDPOINTS.DOWNLOAD}`
      );

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      // 获取实际的内容长度
      const totalLength = parseInt(response.headers.get('content-length'), 10);
      
      // 如果服务器没有提供 content-length，使用默认值
      const state = {
        content: '',
        receivedLength: 0,
        totalLength: totalLength || 3000 // 如果没有 content-length 则使用默认值
      };

      const reader = response.body.getReader();

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        this.handleChunk(value, state);
      }

      utils.showStatus(status, 'Download complete!', CONFIG.STATUS.TYPES.SUCCESS);
    } catch (error) {
      utils.handleError(error, status);
    } finally {
      button.disabled = false;
    }
  }
}

// 初始化应用
const initApp = () => {
  const uploader = new Uploader(DOM.upload);
  const downloader = new Downloader(DOM.download);

  // 事件监听
  DOM.upload.button.addEventListener('click', () => uploader.upload());
  DOM.download.button.addEventListener('click', () => downloader.download());
};

// 启动应用
initApp(); 