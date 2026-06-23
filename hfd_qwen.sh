#!/bin/bash

# ============================================
# HF 数据集/模型快速下载脚本
# ============================================
# 
# 使用方法：
# 1. 复制此文件为 download_start.sh: cp download_start.sh.example download_start.sh
# 2. 根据需要修改下面的配置
# 3. 运行: bash download_start.sh
#

set -e

echo "=========================================="
echo "HF 数据集/模型快速下载"
echo "=========================================="
echo ""

# ============================================
# 配置区域 - 请根据实际情况修改
# ============================================

# 1. Conda 环境配置（如果不需要可以注释掉）
# source /path/to/anaconda3/bin/activate your_env_name

# 2. 下载配置
SAVE_DIR="../ckpts/Qwen/Qwen3.5-27B"                    # 保存目录
REPO_ID="Qwen/Qwen3.5-27B"                       # HF 仓库 ID
HFD_SCRIPT="./scripts/hfd.sh"                                  # hfd.sh 脚本路径（相对或绝对路径）

# 3. 镜像配置（国内用户推荐开启）
export HF_ENDPOINT='https://hf-mirror.com'             # 使用国内镜像加速
# export HF_ENDPOINT='https://huggingface.co'         # 使用官方地址（国外）

# 4. 下载工具配置
TOOL="aria2c"                # 下载工具: aria2c 或 wget
THREADS=10                   # aria2c 线程数（1-16，推荐 8-10）
CONCURRENT=10                 # aria2c 并发下载数（1-10，推荐 5）

# 5. 下载类型（二选一，去掉注释启用）
# DOWNLOAD_TYPE="--dataset"    # 下载数据集
DOWNLOAD_TYPE=""           # 下载模型（默认）

# 6. 文件过滤（可选）
# INCLUDE_PATTERN="*.json *.txt"              # 只下载这些文件
# EXCLUDE_PATTERN="*.safetensors *.md"        # 排除这些文件

# 7. 认证信息（私有仓库需要）
# HF_USERNAME="your_username"
# HF_TOKEN="hf_xxxxxxxxxxxx"

# 8. 版本控制（可选）
# REVISION="main"              # 分支/标签/commit hash

# ============================================
# 以下为执行逻辑，一般不需要修改
# ============================================

# 检查配置
if [[ "$SAVE_DIR" == "/path/to/save/directory" ]]; then
    echo "❌ 错误：请先修改 SAVE_DIR 配置！"
    exit 1
fi

if [[ "$REPO_ID" == "organization/repo-name" ]]; then
    echo "❌ 错误：请先修改 REPO_ID 配置！"
    exit 1
fi

# 打印配置信息
echo "📊 配置信息:"
echo "  - 仓库: $REPO_ID"
echo "  - 保存路径: $SAVE_DIR"
echo "  - 下载工具: $TOOL"
echo "  - 线程数: $THREADS"
echo "  - 并发数: $CONCURRENT"
[[ -n "$DOWNLOAD_TYPE" ]] && echo "  - 类型: 数据集" || echo "  - 类型: 模型"
[[ -n "$HF_ENDPOINT" ]] && echo "  - 镜像: $HF_ENDPOINT"
[[ -n "$INCLUDE_PATTERN" ]] && echo "  - 包含: $INCLUDE_PATTERN"
[[ -n "$EXCLUDE_PATTERN" ]] && echo "  - 排除: $EXCLUDE_PATTERN"
[[ -n "$REVISION" ]] && echo "  - 版本: $REVISION"
echo ""

# 检查工具
if ! command -v $TOOL &> /dev/null; then
    echo "❌ $TOOL 未找到，请先安装："
    if [[ "$TOOL" == "aria2c" ]]; then
        echo "   conda install -y -c conda-forge aria2"
        echo "   # 或"
        echo "   sudo apt-get install aria2"
    else
        echo "   sudo apt-get install wget"
    fi
    exit 1
fi

echo "✅ $TOOL 已安装"
echo ""

# 创建保存目录
mkdir -p "$SAVE_DIR"

echo "🚀 开始下载..."
echo ""

# 构建下载命令
CMD="$HFD_SCRIPT \"$REPO_ID\""
CMD="$CMD --tool $TOOL"
CMD="$CMD -x $THREADS"
CMD="$CMD -j $CONCURRENT"
CMD="$CMD --local-dir \"$SAVE_DIR\""
[[ -n "$DOWNLOAD_TYPE" ]] && CMD="$CMD $DOWNLOAD_TYPE"
[[ -n "$INCLUDE_PATTERN" ]] && CMD="$CMD --include $INCLUDE_PATTERN"
[[ -n "$EXCLUDE_PATTERN" ]] && CMD="$CMD --exclude $EXCLUDE_PATTERN"
[[ -n "$HF_USERNAME" ]] && CMD="$CMD --hf_username \"$HF_USERNAME\""
[[ -n "$HF_TOKEN" ]] && CMD="$CMD --hf_token \"$HF_TOKEN\""
[[ -n "$REVISION" ]] && CMD="$CMD --revision \"$REVISION\""

# 执行下载
eval $CMD

echo ""
echo "=========================================="
if [[ $? -eq 0 ]]; then
    echo "✅ 下载完成！"
    echo "=========================================="
    echo "保存位置: $SAVE_DIR"
    echo ""
    echo "使用方法："
    echo "  from transformers import AutoModel, AutoTokenizer"
    echo "  model = AutoModel.from_pretrained('$SAVE_DIR')"
    echo "  tokenizer = AutoTokenizer.from_pretrained('$SAVE_DIR')"
else
    echo "❌ 下载失败"
    echo "=========================================="
    exit 1
fi
