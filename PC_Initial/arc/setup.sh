#!/bin/bash

# 工具：加密/解密 Arc 的 StorableSidebar.json
# 依赖：openssl (macOS 自带)
# 用法：./arc_space_helper.sh [encrypt|decrypt]

set -e

FILE_NAME="StorableSidebar.json"
ENCRYPTED_FILE="${FILE_NAME}.enc"
OPENSSL_CMD="openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -salt"

# 检查参数
if [[ $# -ne 1 || ($1 != "encrypt" && $1 != "decrypt") ]]; then
    echo "Usage: $0 [encrypt|decrypt]"
    exit 1
fi

# 操作：加密
if [[ $1 == "encrypt" ]]; then
    if [[ ! -f "$FILE_NAME" ]]; then
        echo "Error: File $FILE_NAME not found!"
        exit 1
    fi
    read -s -p "Enter password to encrypt: " password
    echo
    $OPENSSL_CMD -in "$FILE_NAME" -out "$ENCRYPTED_FILE" -pass "pass:$password"
    echo "✅ Encrypted to $ENCRYPTED_FILE (can safely upload to GitHub)"

# 操作：解密
elif [[ $1 == "decrypt" ]]; then
    if [[ ! -f "$ENCRYPTED_FILE" ]]; then
        echo "Error: File $ENCRYPTED_FILE not found!"
        exit 1
    fi
    read -s -p "Enter password to decrypt: " password
    echo
    $OPENSSL_CMD -d -in "$ENCRYPTED_FILE" -out "$FILE_NAME" -pass "pass:$password"
    echo "✅ Decrypted to $FILE_NAME (place it in Arc's profile path)"
fi