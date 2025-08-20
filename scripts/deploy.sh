#!/bin/bash

# Vector Demo 项目部署脚本

set -e

echo "🚀 开始部署 Vector Demo 项目..."

# 检查必要的工具
check_requirements() {
    echo "📋 检查部署环境..."
    
    if ! command -v kubectl &> /dev/null; then
        echo "❌ kubectl 未安装，请先安装 kubectl"
        exit 1
    fi
    
    if ! command -v helm &> /dev/null; then
        echo "❌ helm 未安装，请先安装 helm"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        echo "❌ docker 未安装，请先安装 docker"
        exit 1
    fi
    
    if ! command -v java &> /dev/null; then
        echo "❌ java 未安装，请先安装 java 21"
        exit 1
    fi
    
    # 检查Java版本
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$JAVA_VERSION" -lt 21 ]; then
        echo "❌ Java版本过低，需要Java 21或更高版本，当前版本: $JAVA_VERSION"
        exit 1
    fi
    
    if ! command -v mvn &> /dev/null; then
        echo "❌ maven 未安装，请先安装 maven"
        exit 1
    fi
    
    echo "✅ 环境检查通过"
}

# 构建Java服务镜像
build_image() {
    echo "🔨 构建 Java 服务镜像..."
    
    cd java-service
    
    # 编译Java项目
    echo "📦 编译 Java 项目..."
    mvn clean package -DskipTests
    
    # 构建Docker镜像
    echo "🐳 构建 Docker 镜像..."
    docker build -f ../docker/Dockerfile -t vector-demo-service:1.0.0 .
    
    cd ..
    echo "✅ 镜像构建完成"
}

# 部署Java服务
deploy_service() {
    echo "🚀 部署 Java 服务到 Kubernetes..."
    
    # 应用Kubernetes配置
    kubectl apply -f java-service/k8s/
    
    # 等待服务启动
    echo "⏳ 等待服务启动..."
    kubectl wait --for=condition=available --timeout=300s deployment/vector-demo-service
    
    echo "✅ Java 服务部署完成"
}

# 配置Vector
configure_vector() {
    echo "⚙️  配置 Vector 收集日志..."
    
    echo "📝 请将 vector-config/vector.toml 文件内容复制到你的 Vector 配置中"
    echo "📝 或者使用以下命令更新 Vector ConfigMap："
    echo ""
    echo "kubectl create configmap vector-config --from-file=vector.toml=vector-config/vector.toml -o yaml --dry-run=client | kubectl apply -f -"
    echo ""
    echo "然后重启 Vector Pod："
    echo "kubectl rollout restart daemonset/vector"
}

# 测试服务
test_service() {
    echo "🧪 测试服务..."
    
    # 获取服务端口
    NODE_PORT=$(kubectl get service vector-demo-service -o jsonpath='{.spec.ports[0].nodePort}')
    
    echo "📡 服务访问地址："
    echo "   - 健康检查: http://localhost:${NODE_PORT}/api/logs/health"
    echo "   - 测试日志: curl -X POST http://localhost:${NODE_PORT}/api/logs/test"
    echo "   - 自定义日志: curl -X POST 'http://localhost:${NODE_PORT}/api/logs/custom?level=INFO&message=测试消息'"
    
    echo ""
    echo "🔍 查看 Vector 日志："
    echo "   kubectl logs -l app.kubernetes.io/name=vector -f"
}

# 主函数
main() {
    check_requirements
    build_image
    deploy_service
    configure_vector
    test_service
    
    echo ""
    echo "🎉 部署完成！"
    echo ""
    echo "📚 学习要点："
    echo "   1. Vector 通过 DaemonSet 收集所有 Pod 的日志"
    echo "   2. Java 服务写入日志到 stdout，Vector 自动收集"
    echo "   3. Vector 可以转换、过滤和路由日志到不同目标"
    echo "   4. 使用 Helm 可以快速部署和管理 Vector"
}

# 执行主函数
main "$@"
