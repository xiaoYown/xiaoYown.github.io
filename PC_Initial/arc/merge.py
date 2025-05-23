import json
from pathlib import Path

def load_json(file_path):
    """加载 JSON 文件"""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        print(f"❌ 加载 {file_path} 失败: {e}")
        exit(1)

def save_json(data, file_path):
    """保存 JSON 文件"""
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def merge_spaces(old_data, new_data):
    """合并两个 StorableSidebar.json 的 Space 数据"""
    merged_data = new_data.copy()  # 以 new_data 为基础

    # 合并 Spaces
    old_spaces = {space["title"]: space for space in old_data.get("spaces", [])}
    new_spaces = {space["title"]: space for space in merged_data.get("spaces", [])}

    for space_title, old_space in old_spaces.items():
        if space_title in new_spaces:
            # 合并相同 Space 的 Pinned Tabs（去重）
            old_pins = {tab["url"]: tab for tab in old_space.get("pinned", [])}
            new_pins = {tab["url"]: tab for tab in new_spaces[space_title].get("pinned", [])}
            merged_pins = {**old_pins, **new_pins}  # old_pins 优先
            new_spaces[space_title]["pinned"] = list(merged_pins.values())
        else:
            # 直接添加新 Space
            new_spaces[space_title] = old_space

    merged_data["spaces"] = list(new_spaces.values())

    # 合并 Today Pins（去重）
    old_today = {tab["url"]: tab for tab in old_data.get("today", [])}
    new_today = {tab["url"]: tab for tab in merged_data.get("today", [])}
    merged_data["today"] = list({**old_today, **new_today}.values())

    return merged_data

def main():
    print("🔄 正在合并 Arc Browser 的 StorableSidebar.json...")
    
    # 输入文件路径
    old_file = input("第一个文件路径（旧版）: ").strip()
    new_file = input("第二个文件路径（新版）: ").strip()
    output_file = "merged_StorableSidebar.json"

    # 加载数据
    old_data = load_json(old_file)
    new_data = load_json(new_file)

    # 合并
    merged_data = merge_spaces(old_data, new_data)

    # 保存
    save_json(merged_data, output_file)
    print(f"✅ 合并完成！输出文件: {output_file}")
    print("⚠️ 请手动替换 Arc 目录下的 StorableSidebar.json 并重启浏览器。")

if __name__ == "__main__":
    main()