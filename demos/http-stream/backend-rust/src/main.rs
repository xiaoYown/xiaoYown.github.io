use std::{net::SocketAddr, path::PathBuf, sync::Arc};
use axum::{
    body::Body,
    extract::State,
    http::{HeaderValue, StatusCode},
    response::{IntoResponse, Response},
    routing::{get, post},
    Router,
};
use futures::{Stream, StreamExt};
use serde::Serialize;
use tokio::{
    fs,
    time::{sleep, Duration},
};
use tower_http::{
    cors::{Any, CorsLayer},
    services::ServeDir,
};
use tracing::{info, warn};
use axum_server::tls_rustls::RustlsConfig;
use bytes::Bytes;

// Configuration constants
const PORT: u16 = 3000;
const CHUNK_SIZE: usize = 10;
const INTERVAL_MS: u64 = 50;
const CACHE_DIR: &str = "../.cache";
const CERT_DIR: &str = "../../cert";
const FRONTEND_DIR: &str = "../frontend";

#[derive(Clone)]
struct AppState {
    text_store: Arc<TextStore>,
}

struct TextStore {
    uploaded_text_path: PathBuf,
    sample_text_path: PathBuf,
}

#[derive(Serialize)]
struct UploadResponse {
    message: String,
    bytes_received: usize,
}

impl TextStore {
    async fn new() -> Result<Self, std::io::Error> {
        let cache_path = PathBuf::from(CACHE_DIR);
        let uploaded_text_path = cache_path.join("uploaded_text.txt");
        let sample_text_path = cache_path.join("uploaded_text.txt");

        // Create cache directory if it doesn't exist
        if !cache_path.exists() {
            fs::create_dir_all(&cache_path).await?;
        }

        // Create sample text if it doesn't exist
        if !sample_text_path.exists() {
            let sample_text = "This is a sample streaming text. ".repeat(100);
            fs::write(&sample_text_path, sample_text.as_bytes()).await?;
        }

        Ok(Self {
            uploaded_text_path,
            sample_text_path,
        })
    }

    async fn save(&self, data: &[u8]) -> Result<(), std::io::Error> {
        fs::write(&self.uploaded_text_path, data).await
    }

    async fn get_sample_text(&self) -> Result<Vec<u8>, std::io::Error> {
        fs::read(&self.sample_text_path).await
    }
}

async fn handle_upload(
    State(state): State<AppState>,
    body: Bytes,
) -> Result<impl IntoResponse, StatusCode> {
    match state.text_store.save(&body).await {
        Ok(_) => {
            let response = UploadResponse {
                message: "Upload complete".to_string(),
                bytes_received: body.len(),
            };
            Ok(axum::Json(response))
        }
        Err(e) => {
            warn!("Upload failed: {}", e);
            Err(StatusCode::INTERNAL_SERVER_ERROR)
        }
    }
}

async fn stream_binary(data: Vec<u8>) -> impl Stream<Item = Result<Bytes, std::io::Error>> {
    let chunks = data
        .chunks(CHUNK_SIZE)
        .map(|chunk| chunk.to_vec())
        .collect::<Vec<_>>();

    futures::stream::iter(chunks).then(|chunk| async move {
        sleep(Duration::from_millis(INTERVAL_MS)).await;
        Ok(Bytes::from(chunk))
    })
}

#[axum::debug_handler]
async fn handle_download(
    State(state): State<AppState>,
) -> impl IntoResponse {
    match state.text_store.get_sample_text().await {
        Ok(data) => {
            let stream = stream_binary(data).await;
            let body = Body::from_stream(stream);
            
            let mut response = Response::new(body);
            response.headers_mut().insert(
                "content-type",
                HeaderValue::from_static("application/octet-stream"),
            );
            
            Ok(response)
        }
        Err(e) => {
            warn!("Download failed: {}", e);
            Err(StatusCode::INTERNAL_SERVER_ERROR)
        }
    }
}

#[tokio::main]
async fn main() {
    // Initialize tracing
    tracing_subscriber::fmt::init();

    // Initialize TextStore
    let text_store = Arc::new(
        TextStore::new()
            .await
            .expect("Failed to initialize TextStore"),
    );

    // Create app state
    let app_state = AppState {
        text_store: text_store.clone(),
    };

    // Configure CORS
    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    // Build router with static file serving
    let app = Router::new()
        .route("/upload", post(handle_upload))
        .route("/download", get(handle_download))
        .nest_service("/", ServeDir::new(FRONTEND_DIR))
        .layer(cors)
        .with_state(app_state);

    // Create the server
    let addr = SocketAddr::from(([0, 0, 0, 0], PORT));
    info!("Server starting on https://localhost:{}", PORT);

    // Configure TLS
    let config = RustlsConfig::from_pem_file(
        PathBuf::from(CERT_DIR).join("certificate.crt"),
        PathBuf::from(CERT_DIR).join("private.key"),
    )
    .await
    .expect("Failed to load TLS config");

    // Start the server
    info!("Listening on {}", addr);
    axum_server::bind_rustls(addr, config)
        .serve(app.into_make_service())
        .await
        .unwrap();
} 