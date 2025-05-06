# Volta 环境管理脚本

下面是一个用于管理 Volta 环境版本的 Bash 脚本，它可以让你轻松切换 node 版本，并为每个组合命名。

## 脚本内容

创建一个名为 `venv` (version environment) 的文件，内容如下：

```bash
#!/bin/bash

# Node.js 环境管理脚本
# 功能：管理 node 版本，并通过名称进行切换

CONFIG_FILE="$HOME/.venv_config"
DEFAULT_NODE_VERSION=""

# 初始化配置文件
init_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        touch "$CONFIG_FILE"
        echo "# Node.js 环境配置" > "$CONFIG_FILE"
        echo "# 格式: 环境名称 node版本" >> "$CONFIG_FILE"
    fi
}

# 添加新环境
add_env() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "用法: venv add <环境名称> <node版本>"
        return 1
    fi

    # 检查是否已存在同名环境
    if grep -q "^$1 " "$CONFIG_FILE"; then
        echo "错误: 环境 '$1' 已存在"
        return 1
    fi

    # 验证node版本是否存在
    if ! volta list node | grep -q "$2"; then
        echo "警告: node 版本 '$2' 尚未安装，将尝试安装..."
        volta install node@"$2" || return 1
    fi

    echo "$1 $2" >> "$CONFIG_FILE"
    echo "已添加环境: $1 (node: $2)"
}

# 删除环境
remove_env() {
    if [ -z "$1" ]; then
        echo "用法: venv remove <环境名称>"
        return 1
    fi

    if ! grep -q "^$1 " "$CONFIG_FILE"; then
        echo "错误: 环境 '$1' 不存在"
        return 1
    fi

    # 创建临时文件
    tmp_file=$(mktemp)
    grep -v "^$1 " "$CONFIG_FILE" > "$tmp_file"
    mv "$tmp_file" "$CONFIG_FILE"
    
    echo "已删除环境: $1"
}

# 切换环境
use_env() {
    if [ -z "$1" ]; then
        echo "用法: venv use <环境名称>"
        echo "可用环境:"
        list_envs
        return 1
    fi

    local env_info=$(grep "^$1 " "$CONFIG_FILE")
    if [ -z "$env_info" ]; then
        echo "错误: 环境 '$1' 不存在"
        return 1
    fi

    local node_version=$(echo "$env_info" | awk '{print $2}')

    volta install node@"$node_version"
    
    echo "已切换到环境: $1"
    echo "node: $(node -v)"
}

# 列出所有环境
list_envs() {
    if [ ! -s "$CONFIG_FILE" ]; then
        echo "没有配置任何环境"
        return
    fi

    echo "可用环境:"
    echo "-------------------------"
    printf "%-20s %-15s\n" "名称" "Node版本"
    echo "-------------------------"
    while read -r line; do
        # 跳过注释行
        if [[ "$line" =~ ^# ]]; then
            continue
        fi
        local name=$(echo "$line" | awk '{print $1}')
        local node=$(echo "$line" | awk '{print $2}')
        printf "%-20s %-15s\n" "$name" "$node"
    done < "$CONFIG_FILE"
    echo "-------------------------"
}

# 显示配置信息和路径
show_config() {
    echo "配置文件路径: $CONFIG_FILE"
    echo ""
    echo "配置内容:"
    echo "-------------------------"
    cat "$CONFIG_FILE"
    echo "-------------------------"
}

# 帮助信息
show_help() {
    echo "Node.js 环境管理工具"
    echo "用法: venv <命令> [参数]"
    echo ""
    echo "命令:"
    echo "  add <名称> <node版本>            添加新环境"
    echo "  remove <名称>                    删除环境"
    echo "  use <名称>                       切换到指定环境"
    echo "  list                             列出所有环境"
    echo "  config                           显示配置文件信息和内容"
    echo "  help                             显示帮助信息"
}

# 主函数
main() {
    init_config

    case "$1" in
        "add")
            add_env "$2" "$3"
            ;;
        "remove")
            remove_env "$2"
            ;;
        "use")
            use_env "$2"
            ;;
        "list")
            list_envs
            ;;
        "config")
            show_config
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            echo "未知命令: $1"
            show_help
            return 1
            ;;
    esac
}

main "$@"
```

## 安装和使用说明

1. **保存脚本**：
   - 将上面的脚本保存为 `venv` 文件（无扩展名）
   - 建议保存在 `~/bin` 目录下（如果没有该目录可以创建）

2. **使脚本可执行**：
   ```bash
   chmod +x ~/bin/venv
   ```

3. **添加到 PATH**：
   - 确保 `~/bin` 在你的 PATH 环境变量中
   - 如果没有，可以将以下内容添加到你的 shell 配置文件（如 `~/.bashrc`, `~/.zshrc` 等）：
     ```bash
     export PATH="$HOME/bin:$PATH"
     ```
   - 然后运行：
     ```bash
     source ~/.bashrc  # 或 source ~/.zshrc
     ```

4. **使用脚本**：

   - **添加新环境**：
     ```bash
     venv add my-env 18.16.0
     ```
     这会将名为 "my-env" 的环境添加到配置中，使用 node 18.16.0

   - **切换环境**：
     ```bash
     venv use my-env
     ```

   - **列出所有环境**：
     ```bash
     venv list
     ```

   - **删除环境**：
     ```bash
     venv remove my-env
     ```

   - **查看配置**：
     ```bash
     venv config
     ```

   - **获取帮助**：
     ```bash
     venv help
     ```

## 功能说明

1. **切换 node 版本**：通过 `venv use <环境名称>` 可以一键切换 node 的版本

2. **自定义命名环境**：每个环境都可以有自己的名称，便于记忆和管理

3. **配置文件存储**：所有环境配置存储在 `~/.venv_config` 文件中

4. **完整的管理功能**：
   - 添加环境 (`add`)
   - 删除环境 (`remove`)
   - 切换环境 (`use`)
   - 查看环境列表 (`list`)
   - 查看配置信息 (`config`)

5. **自动安装**：如果指定的 node 版本尚未安装，脚本会自动尝试安装

这个脚本简化了使用 Volta 管理多个 node 版本的过程，特别是当你需要在不同项目间频繁切换时。