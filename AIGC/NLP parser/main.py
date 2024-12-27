# -*- coding: utf-8 -*-
from flask import Flask, request, jsonify, render_template
import spacy
import re
import os

# 初始化 Flask 应用
app = Flask(__name__, template_folder='templates')

# 加载 spaCy 的小型中文模型
nlp = spacy.load("zh_core_web_sm")

# 自定义解析函数
def parse_command(input_text):
    # 使用 spaCy 解析文本
    doc = nlp(input_text)
    
    # 提取动词
    action = None
    for token in doc:
        if token.pos_ == "VERB":  # 动词
            action = token.text
            break  # 假设命令中只会有一个主要动词

    # 提取数字（如"第3行"）
    match = re.search(r"第?(\d+)", input_text)
    target = int(match.group(1)) if match else None

    # 提取内容（如"内容"部分）
    match_content = re.search(r"(内容：?)(.*)", input_text)
    content = match_content.group(2) if match_content else None

    # 映射自然语言到指令
    if action == "创建":
        return f"create file('{content}')"
    elif action == "修改":
        return f"modify file({target}, '{content}')"
    elif action == "删除" and "行" in input_text:
        return f"delete_line({target})"
    elif action == "删除" and "文件" in input_text:
        return f"delete file('{content}')"
    else:
        return "无法解析指令"

# 路由：服务 HTML 页面
@app.route('/')
def index():
    return render_template('index.html')

# 路由：解析自然语言指令
@app.route('/parse', methods=['POST'])
def parse():
    data = request.json
    if 'input_text' not in data:
        return jsonify({'error': 'Missing input_text in request'}), 400

    input_text = data['input_text']
    command = parse_command(input_text)
    return jsonify({'command': command})

# 启动服务
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
