### 拉取仓库

```sh
git clone https://github.com/Akegarasu/ChatGLM-webui
```

### 下载模型

**下载脚本 download.py**

```py
model_name = "THUDM/chatglm-6b"

from huggingface_hub import snapshot_download

snapshot_download(
    repo_id=model_name,
    local_dir=f"./cache/{model_name}",
    ignore_patterns=["*.bin"],
)
```

_以上安装排除了 .bin 文件, .bin 文件需自行在 huggingface 上下载_

### 修改 module.py

```py
def load_model():
    if cmd_opts.ui_dev:
        return

    # from transformers import AutoModel, AutoTokenizer

    # global tokenizer, model

    # tokenizer = AutoTokenizer.from_pretrained(cmd_opts.model_path, trust_remote_code=True)
    # model = AutoModel.from_pretrained(cmd_opts.model_path, trust_remote_code=True)
    import os
    from transformers import AutoModel, AutoTokenizer

    global tokenizer, model

    model_path = f"./cache/{cmd_opts.model_path}"

    tokenizer = AutoTokenizer.from_pretrained(
        cmd_opts.model_path,
        auto_load_weights=False,
        default_data_dir=model_path,
        verbose=1,
        trust_remote_code=True,
    )
    model = AutoModel.from_pretrained(model_path, trust_remote_code=True)

    prepare_model()
```

### 启动服务

```sh
python webui.py
```
