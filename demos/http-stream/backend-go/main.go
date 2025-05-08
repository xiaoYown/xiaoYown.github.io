package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
	"gopkg.in/yaml.v3"
	"io"
	"bytes"
)

// Config 服务器配置常量
type Config struct {
	Server struct {
		Port int `yaml:"port"`
	} `yaml:"server"`
	Paths struct {
		Frontend   string `yaml:"frontend"`    // 前端静态文件目录
		Cert       string `yaml:"cert"`        // SSL 证书目录
		Cache      string `yaml:"cache"`       // 缓存目录路径
		CacheFile  string `yaml:"cache_file"`  // 上传文件的缓存文件名
		SampleText string `yaml:"sample_text"` // 示例文本的文件名
	} `yaml:"paths"`
	Stream struct {
		ChunkSize int           `yaml:"chunk_size"` // 每个数据块的大小（字节）
		Interval  time.Duration `yaml:"interval"`   // 数据块发送间隔
	} `yaml:"stream"`
	MimeTypes map[string]string `yaml:"mime_types"`
}

// TextStore 二进制数据存储管理
type TextStore struct {
	cachePath       string
	uploadedPath    string
	sampleTextPath  string
	defaultSampleText []byte
}

func NewConfig() *Config {
	config := &Config{}
	
	// 读取配置文件
	data, err := ioutil.ReadFile("config.yaml")
	if err != nil {
		log.Fatal("Error reading config file:", err)
	}

	// 解析 YAML
	if err := yaml.Unmarshal(data, config); err != nil {
		log.Fatal("Error parsing config file:", err)
	}

	return config
}

func NewTextStore(config *Config) *TextStore {
	store := &TextStore{
		cachePath:    filepath.Join(config.Paths.Cache),
		defaultSampleText: []byte(strings.Repeat("This is a sample streaming text. ", 100)),
	}
	store.uploadedPath = filepath.Join(store.cachePath, config.Paths.CacheFile)
	store.sampleTextPath = filepath.Join(store.cachePath, config.Paths.SampleText)
	store.initializeStore()
	return store
}

func (s *TextStore) initializeStore() {
	// 确保缓存目录存在
	if err := os.MkdirAll(s.cachePath, 0755); err != nil {
		log.Fatal("Failed to create cache directory:", err)
	}

	// 如果示例文本文件不存在，创建它
	if _, err := os.Stat(s.sampleTextPath); os.IsNotExist(err) {
		if err := ioutil.WriteFile(s.sampleTextPath, s.defaultSampleText, 0644); err != nil {
			log.Fatal("Failed to create sample text file:", err)
		}
	}
}

func (s *TextStore) save(data []byte) error {
	return ioutil.WriteFile(s.uploadedPath, data, 0644)
}

func (s *TextStore) getSampleText() ([]byte, error) {
	data, err := ioutil.ReadFile(s.sampleTextPath)
	if err != nil {
		return s.defaultSampleText, nil
	}
	return data, nil
}

func enableCORS(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Connection, Accept-Encoding")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next(w, r)
	}
}

func main() {
	config := NewConfig()
	store := NewTextStore(config)

	// 处理上传请求
	uploadHandler := enableCORS(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != "POST" {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		// 使用 bytes.Buffer 收集二进制数据
		var buffer bytes.Buffer
		if _, err := io.Copy(&buffer, r.Body); err != nil {
			http.Error(w, "Failed to read request body", http.StatusInternalServerError)
			return
		}
		
		data := buffer.Bytes()
		if err := store.save(data); err != nil {
			http.Error(w, "Failed to save data", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		response := fmt.Sprintf(`{"message":"Upload complete","bytesReceived":%d}`, len(data))
		w.Write([]byte(response))
	})

	// 处理下载请求
	downloadHandler := enableCORS(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != "GET" {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		data, err := store.getSampleText()
		if err != nil {
			http.Error(w, "Failed to read sample text", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/octet-stream")
		w.Header().Set("Content-Length", fmt.Sprintf("%d", len(data)))

		// 分块发送二进制数据
		for i := 0; i < len(data); i += config.Stream.ChunkSize {
			end := i + config.Stream.ChunkSize
			if end > len(data) {
				end = len(data)
			}
			
			chunk := data[i:end]
			w.Write(chunk)
			w.(http.Flusher).Flush()
			
			if i+config.Stream.ChunkSize < len(data) {
				time.Sleep(config.Stream.Interval)
			}
		}
	})

	// 设置路由
	http.HandleFunc("/upload", uploadHandler)
	http.HandleFunc("/download", downloadHandler)
	http.Handle("/", http.FileServer(http.Dir(config.Paths.Frontend)))

	// 启动 HTTPS 服务器
	certFile := filepath.Join(config.Paths.Cert, "certificate.crt")
	keyFile := filepath.Join(config.Paths.Cert, "private.key")
	
	fmt.Printf("HTTP/2 Server running at https://localhost:%d\n", config.Server.Port)
	log.Fatal(http.ListenAndServeTLS(fmt.Sprintf(":%d", config.Server.Port), certFile, keyFile, nil))
} 