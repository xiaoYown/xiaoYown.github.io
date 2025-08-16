#!/bin/bash
API_TOKEN=$(cat /var/lib/zerotier-one/authtoken.secret)
NETWORK_ID="bcc2cf8706833c5e"

# 检查必要的工具
if ! command -v jq &> /dev/null; then
    echo "错误: 需要安装 jq 工具"
    exit 1
fi

case $1 in
  "list")
    echo "=== 网络成员 ==="
    
    # 获取成员列表
    members_data=$(curl -s -H "X-ZT1-Auth: $API_TOKEN" "http://localhost:9993/controller/network/$NETWORK_ID/member")
    
    # 检查 curl 是否成功
    if [ $? -ne 0 ]; then
        echo "错误: 无法连接到 ZeroTier Controller API"
        exit 1
    fi
    
    # 检查返回的数据是否为空
    if [ -z "$members_data" ]; then
        echo "错误: API 返回空数据"
        exit 1
    fi
    
    # 解析成员列表并获取每个成员的详细信息
    echo "$members_data" | jq -r 'keys[]' | while read -r node_id; do
        if [ -n "$node_id" ]; then
            echo "正在获取节点 $node_id 的详细信息..."
            member_detail=$(curl -s -H "X-ZT1-Auth: $API_TOKEN" "http://localhost:9993/controller/network/$NETWORK_ID/member/$node_id")
            
            if [ $? -eq 0 ] && [ -n "$member_detail" ]; then
                # 解析成员详细信息
                echo "$member_detail" | jq -r '
                  "节点ID: \(.id // .address // "'"$node_id"'")
                  授权状态: \(if .authorized then "已授权" else "未授权" end)
                  IP地址: \(if .ipAssignments and (.ipAssignments | length > 0) then (.ipAssignments | join(", ")) else "无" end)
                  创建时间: \(if .creationTime then (.creationTime / 1000 | strftime("%Y-%m-%d %H:%M:%S")) else "未知" end)
                  最后授权: \(if .lastAuthorizedTime and .lastAuthorizedTime > 0 then (.lastAuthorizedTime / 1000 | strftime("%Y-%m-%d %H:%M:%S")) else "从未" end)
                  版本: v\(.vMajor // 0).\(.vMinor // 0).\(.vRev // 0)
                  ---"
                ' 2>/dev/null || {
                    echo "节点ID: $node_id (解析失败)"
                    echo "---"
                }
            else
                echo "节点ID: $node_id (无法获取详细信息)"
                echo "---"
            fi
        fi
    done
    ;;
  "auth")
    if [ -z "$2" ]; then 
        echo "用法: $0 auth <节点ID>"
        exit 1
    fi
    
    echo "正在授权节点 $2..."
    response=$(curl -s -X POST -H "X-ZT1-Auth: $API_TOKEN" -H "Content-Type: application/json" \
      -d '{"authorized": true}' "http://localhost:9993/controller/network/$NETWORK_ID/member/$2")
    
    if [ $? -eq 0 ]; then
        echo "节点 $2 已授权"
        echo "响应: $response"
    else
        echo "授权失败"
        exit 1
    fi
    ;;
  "remove")
    if [ -z "$2" ]; then 
        echo "用法: $0 remove <节点ID>"
        exit 1
    fi
    
    echo "正在删除节点 $2..."
    
    # 先获取节点信息确认存在
    member_info=$(curl -s -H "X-ZT1-Auth: $API_TOKEN" "http://localhost:9993/controller/network/$NETWORK_ID/member/$2")
    
    if [ $? -ne 0 ] || [ -z "$member_info" ]; then
        echo "错误: 节点 $2 不存在或无法访问"
        exit 1
    fi
    
    # 显示要删除的节点信息
    echo "即将删除的节点信息:"
    echo "$member_info" | jq -r '
      "节点ID: \(.id // "未知")
      授权状态: \(if .authorized then "已授权" else "未授权" end)
      IP地址: \(if .ipAssignments and (.ipAssignments | length > 0) then (.ipAssignments | join(", ")) else "无" end)"
    ' 2>/dev/null || echo "节点ID: $2"
    
    # 确认删除
    read -p "确认删除此节点? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        response=$(curl -s -X DELETE -H "X-ZT1-Auth: $API_TOKEN" \
          "http://localhost:9993/controller/network/$NETWORK_ID/member/$2")
        
        if [ $? -eq 0 ]; then
            echo "节点 $2 已删除"
        else
            echo "删除失败"
            exit 1
        fi
    else
        echo "取消删除"
    fi
    ;;
  "cleanup")
    echo "=== 清理未授权/离线节点 ==="
    
    # 获取成员列表
    members_data=$(curl -s -H "X-ZT1-Auth: $API_TOKEN" "http://localhost:9993/controller/network/$NETWORK_ID/member")
    
    if [ $? -ne 0 ] || [ -z "$members_data" ]; then
        echo "错误: 无法获取成员列表"
        exit 1
    fi
    
    # 收集要清理的节点
    cleanup_nodes=()
    
    echo "正在扫描节点..."
    echo "$members_data" | jq -r 'keys[]' | while read -r node_id; do
        if [ -n "$node_id" ]; then
            member_detail=$(curl -s -H "X-ZT1-Auth: $API_TOKEN" "http://localhost:9993/controller/network/$NETWORK_ID/member/$node_id")
            
            if [ $? -eq 0 ] && [ -n "$member_detail" ]; then
                # 检查是否为未授权或长期离线的节点
                should_cleanup=$(echo "$member_detail" | jq -r '
                  if (.authorized == false) then
                    "未授权"
                  elif (.online == false and (.lastOnline // 0) < (now - 7*24*3600*1000)) then
                    "长期离线"
                  else
                    "保留"
                  end
                ')
                
                if [ "$should_cleanup" != "保留" ]; then
                    echo "发现可清理节点: $node_id ($should_cleanup)"
                    echo "$node_id" >> /tmp/cleanup_nodes.txt
                fi
            fi
        fi
    done
    
    # 检查是否有需要清理的节点
    if [ ! -f /tmp/cleanup_nodes.txt ]; then
        echo "没有发现需要清理的节点"
        exit 0
    fi
    
    echo ""
    echo "以下节点将被清理:"
    cat /tmp/cleanup_nodes.txt
    echo ""
    
    read -p "确认清理这些节点? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        while read -r node_id; do
            echo "删除节点: $node_id"
            curl -s -X DELETE -H "X-ZT1-Auth: $API_TOKEN" \
              "http://localhost:9993/controller/network/$NETWORK_ID/member/$node_id" > /dev/null
            
            if [ $? -eq 0 ]; then
                echo "✓ 节点 $node_id 已删除"
            else
                echo "✗ 节点 $node_id 删除失败"
            fi
        done < /tmp/cleanup_nodes.txt
        
        rm -f /tmp/cleanup_nodes.txt
        echo "清理完成"
    else
        echo "取消清理"
        rm -f /tmp/cleanup_nodes.txt
    fi
    ;;
  "debug")
    echo "=== 调试信息 ==="
    echo "API Token: ${API_TOKEN:0:10}..."
    echo "Network ID: $NETWORK_ID"
    echo "测试 API 连接..."
    
    # 测试基本连接
    curl -s -H "X-ZT1-Auth: $API_TOKEN" "http://localhost:9993/status" | jq . || echo "API 连接失败"
    
    echo "获取网络信息..."
    curl -s -H "X-ZT1-Auth: $API_TOKEN" "http://localhost:9993/controller/network/$NETWORK_ID" | jq . || echo "网络信息获取失败"
    
    echo "获取成员原始数据..."
    curl -s -H "X-ZT1-Auth: $API_TOKEN" "http://localhost:9993/controller/network/$NETWORK_ID/member" | jq . || echo "成员数据获取失败"
    ;;
  *)
    echo "用法: $0 {list|auth <节点ID>|remove <节点ID>|cleanup|debug}"
    echo ""
    echo "命令说明:"
    echo "  list         - 列出所有网络成员"
    echo "  auth <节点ID> - 授权指定节点"
    echo "  remove <节点ID> - 删除指定节点"
    echo "  cleanup      - 清理未授权和长期离线的节点"
    echo "  debug        - 显示调试信息"
    ;;
esac