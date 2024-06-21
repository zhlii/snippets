#!/bin/bash

version_add() {
    # 提取标签中的最后一组数字
    tag_number=$(echo "$1" | grep -oE '[0-9]+$')

    # 提取标签的前缀（包含可能的数字）
    prefix=$(echo "$1" | sed -E "s/$tag_number\$//")

    # 将数字部分加1
    new_tag_number=$((tag_number + 1))

    # 构造新的标签
    echo "${prefix}${new_tag_number}"
}

# 获取当前最新的标签
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)

# 检查是否存在标签
if [ -z "$latest_tag" ]; then
    new_tag="0.1"
else
    echo "当前版本号：${latest_tag}。请选择一个操作："
    options=("版本号+1" "增加小版本号" "去除小版本号，大版本号+1" "退出")

    select opt in "${options[@]}"
    do
        case $opt in
            "版本号+1")
                new_tag=$(version_add "$latest_tag")
                break                
                ;;
            "增加小版本号")
                new_tag="${latest_tag}.1"
                break
                ;;
            "去除小版本号，大版本号+1")
                major_version=$(echo "$latest_tag" | sed 's/\.[0-9]*$//')              
                new_tag=$(version_add "$major_version")
                break
                ;;
            "退出")
                echo "退出"
                exit
                ;;
            *) echo "无效的选项 $REPLY";;
        esac
    done    
fi

# 提示用户确认
read -n 1 -p "新标签：${new_tag}，是否确认创建并推送新标签？ (y/n): " confirm

if [ "$confirm" == "y" ]; then
    # 打印新标签并加到仓库
    echo "正在创建并推送新标签：$new_tag"
    git tag "$new_tag"
    git push origin "$new_tag"
    echo "新标签已成功创建并推送。"
else
    echo "操作已取消。"
fi