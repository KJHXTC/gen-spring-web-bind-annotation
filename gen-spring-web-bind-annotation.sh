#!/bin/bash

# 生成 spring-web-bind-annotation 的脚本
# 从 spring-web JAR 中提取 org/springframework/web/bind/annotation 包

set -e

# 默认配置
DEFAULT_SPRING_WEB_VERSION="6.1.13"
DEFAULT_NEW_GROUP_ID="com.custom.springframework"
DEFAULT_OUTPUT_DIR="./output"

# 使用方法
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -v VERSION           Spring Web version (default: ${DEFAULT_SPRING_WEB_VERSION})"
    echo "  -g GROUP_ID          New groupId (default: ${DEFAULT_NEW_GROUP_ID})"
    echo "  -o OUTPUT_DIR        Output directory (default: ${DEFAULT_OUTPUT_DIR})"
    echo "  -h                   Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -v 6.1.13 -g com.mycompany.springframework -o ./dist"
    exit 1
}

# 解析命令行参数
SPRING_WEB_VERSION="${DEFAULT_SPRING_WEB_VERSION}"
NEW_GROUP_ID="${DEFAULT_NEW_GROUP_ID}"
OUTPUT_DIR="${DEFAULT_OUTPUT_DIR}"

while getopts "v:g:o:h" opt; do
    case ${opt} in
        v)
            SPRING_WEB_VERSION="${OPTARG}"
            ;;
        g)
            NEW_GROUP_ID="${OPTARG}"
            ;;
        o)
            OUTPUT_DIR="${OPTARG}"
            ;;
        h)
            usage
            ;;
        \?)
            echo "Invalid option: -${OPTARG}" >&2
            usage
            ;;
    esac
done

# Maven 坐标
ORIGINAL_GROUP_ID="org.springframework"
ORIGINAL_ARTIFACT_ID="spring-web"
NEW_ARTIFACT_ID="spring-web-bind-annotation"

echo "=========================================="
echo "生成 spring-web-bind-annotation"
echo "=========================================="
echo "Spring Web Version: ${SPRING_WEB_VERSION}"
echo "Original GAV: ${ORIGINAL_GROUP_ID}:${ORIGINAL_ARTIFACT_ID}:${SPRING_WEB_VERSION}"
echo "New GAV: ${NEW_GROUP_ID}:${NEW_ARTIFACT_ID}:${SPRING_WEB_VERSION}"
echo "Output Directory: ${OUTPUT_DIR}"
echo "=========================================="

# 保存当前目录 (Save current directory)
ORIGINAL_DIR=$(pwd)

# 创建临时工作目录
WORK_DIR=$(mktemp -d)
trap "rm -rf ${WORK_DIR}" EXIT

echo "Working directory: ${WORK_DIR}"

# 下载原始 spring-web JAR
echo ""
echo "Step 1: Downloading spring-web JAR..."
ORIGINAL_JAR="${WORK_DIR}/${ORIGINAL_ARTIFACT_ID}-${SPRING_WEB_VERSION}.jar"
ORIGINAL_POM="${WORK_DIR}/${ORIGINAL_ARTIFACT_ID}-${SPRING_WEB_VERSION}.pom"

# 使用 Maven 下载到本地仓库
mvn dependency:get \
    -DgroupId="${ORIGINAL_GROUP_ID}" \
    -DartifactId="${ORIGINAL_ARTIFACT_ID}" \
    -Dversion="${SPRING_WEB_VERSION}" \
    -Dpackaging=jar \
    -Dtransitive=false

mvn dependency:get \
    -DgroupId="${ORIGINAL_GROUP_ID}" \
    -DartifactId="${ORIGINAL_ARTIFACT_ID}" \
    -Dversion="${SPRING_WEB_VERSION}" \
    -Dpackaging=pom \
    -Dtransitive=false

# 获取实际的本地 Maven 仓库路径
LOCAL_REPO=$(mvn help:evaluate -Dexpression=settings.localRepository -q -DforceStdout 2>/dev/null)
if [ -z "${LOCAL_REPO}" ] || [ ! -d "${LOCAL_REPO}" ]; then
    # 回退到默认路径
    LOCAL_REPO="${HOME}/.m2/repository"
fi

GROUP_PATH=$(echo ${ORIGINAL_GROUP_ID} | tr '.' '/')
ARTIFACT_PATH="${LOCAL_REPO}/${GROUP_PATH}/${ORIGINAL_ARTIFACT_ID}/${SPRING_WEB_VERSION}"

# 检查文件是否存在
if [ ! -f "${ARTIFACT_PATH}/${ORIGINAL_ARTIFACT_ID}-${SPRING_WEB_VERSION}.jar" ]; then
    echo "Error: Failed to download JAR file from Maven repository"
    exit 1
fi

if [ ! -f "${ARTIFACT_PATH}/${ORIGINAL_ARTIFACT_ID}-${SPRING_WEB_VERSION}.pom" ]; then
    echo "Error: Failed to download POM file from Maven repository"
    exit 1
fi

cp "${ARTIFACT_PATH}/${ORIGINAL_ARTIFACT_ID}-${SPRING_WEB_VERSION}.jar" ${ORIGINAL_JAR}
cp "${ARTIFACT_PATH}/${ORIGINAL_ARTIFACT_ID}-${SPRING_WEB_VERSION}.pom" ${ORIGINAL_POM}

echo "Downloaded: ${ORIGINAL_JAR}"
echo "Downloaded: ${ORIGINAL_POM}"

# 解压 JAR 文件
echo ""
echo "Step 2: Extracting JAR..."
EXTRACT_DIR="${WORK_DIR}/extracted"
mkdir -p ${EXTRACT_DIR}
cd ${EXTRACT_DIR}
jar xf ${ORIGINAL_JAR}

echo "Extracted to: ${EXTRACT_DIR}"

# 保留 annotation 包，删除其他内容
echo ""
echo "Step 3: Filtering classes..."
ANNOTATION_PACKAGE="org/springframework/web/bind/annotation"

# 检查 annotation 包是否存在
if [ ! -d "${EXTRACT_DIR}/${ANNOTATION_PACKAGE}" ]; then
    echo "Error: Annotation package not found: ${ANNOTATION_PACKAGE}"
    exit 1
fi

# 保存 annotation 包到临时目录
TEMP_ANNOTATION_DIR="${WORK_DIR}/temp-annotation"
mkdir -p ${TEMP_ANNOTATION_DIR}
cp -r ${EXTRACT_DIR}/${ANNOTATION_PACKAGE} ${TEMP_ANNOTATION_DIR}/

# 删除 org 目录
rm -rf ${EXTRACT_DIR}/org

# 恢复 annotation 包
mkdir -p ${EXTRACT_DIR}/org/springframework/web/bind
cp -r ${TEMP_ANNOTATION_DIR}/annotation ${EXTRACT_DIR}/org/springframework/web/bind/

echo "Kept only: ${ANNOTATION_PACKAGE}"

# 重新打包 JAR
echo ""
echo "Step 4: Repackaging JAR..."
NEW_JAR_NAME="${NEW_ARTIFACT_ID}-${SPRING_WEB_VERSION}.jar"
NEW_JAR="${WORK_DIR}/${NEW_JAR_NAME}"

cd ${EXTRACT_DIR}
jar cf ${NEW_JAR} .

echo "Created: ${NEW_JAR}"

# 生成新的 POM 文件
echo ""
echo "Step 5: Generating POM..."
NEW_POM="${WORK_DIR}/${NEW_ARTIFACT_ID}-${SPRING_WEB_VERSION}.pom"

# 从原始 POM 提取基本信息（使用 sed，更加通用和可移植）
DESCRIPTION=$(sed -n 's/.*<description>\(.*\)<\/description>.*/\1/p' ${ORIGINAL_POM} 2>/dev/null | head -1)
if [ -z "${DESCRIPTION}" ]; then
    DESCRIPTION="Spring Web Bind Annotation - extracted from spring-web"
fi

URL=$(sed -n 's/.*<url>\(.*\)<\/url>.*/\1/p' ${ORIGINAL_POM} 2>/dev/null | head -1)
if [ -z "${URL}" ]; then
    URL="https://spring.io"
fi

cat > ${NEW_POM} << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>${NEW_GROUP_ID}</groupId>
    <artifactId>${NEW_ARTIFACT_ID}</artifactId>
    <version>${SPRING_WEB_VERSION}</version>
    <packaging>jar</packaging>

    <name>${NEW_ARTIFACT_ID}</name>
    <description>${DESCRIPTION} (Modified: only annotation package)</description>
    <url>${URL}</url>

    <!-- No dependencies - standalone annotations only -->
</project>
EOF

echo "Created: ${NEW_POM}"

# 创建输出目录并复制文件
echo ""
echo "Step 6: Copying to output directory..."
cd "${ORIGINAL_DIR}"
mkdir -p ${OUTPUT_DIR}
cp ${NEW_JAR} ${OUTPUT_DIR}/
cp ${NEW_POM} ${OUTPUT_DIR}/

echo ""
echo "=========================================="
echo "✓ Successfully generated!"
echo "=========================================="
echo "Output files:"
echo "  JAR: ${OUTPUT_DIR}/${NEW_JAR_NAME}"
echo "  POM: ${OUTPUT_DIR}/${NEW_ARTIFACT_ID}-${SPRING_WEB_VERSION}.pom"
echo ""
echo "To install to local Maven repository:"
echo "  mvn install:install-file \\"
echo "    -Dfile=${OUTPUT_DIR}/${NEW_JAR_NAME} \\"
echo "    -DpomFile=${OUTPUT_DIR}/${NEW_ARTIFACT_ID}-${SPRING_WEB_VERSION}.pom"
echo "=========================================="
