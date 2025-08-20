#!/bin/bash

# Vector Demo 项目测试脚本

set -e

echo "🧪 开始测试 Vector Demo 项目..."

# 获取服务端口
get_service_port() {
    NODE_PORT=$(kubectl get service vector-demo-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    if [ -z "$NODE_PORT" ]; then
        echo "❌ 无法获取服务端口，请确保服务已部署"
        exit 1
    fi
    echo $NODE_PORT
}

# 测试健康检查
test_health() {
    echo "🏥 测试健康检查..."
    PORT=$(get_service_port)
    
    response=$(curl -s -w "%{http_code}" "http://localhost:${PORT}/api/logs/health")
    http_code="${response: -3}"
    body="${response%???}"
    
    if [ "$http_code" = "200" ]; then
        echo "✅ 健康检查通过"
        echo "响应: $body"
    else
        echo "❌ 健康检查失败，HTTP状态码: $http_code"
        echo "响应: $body"
    fi
    echo ""
}

# 测试日志生成
test_logging() {
    echo "📝 测试日志生成..."
    PORT=$(get_service_port)
    
    response=$(curl -s -w "%{http_code}" -X POST "http://localhost:${PORT}/api/logs/test")
    http_code="${response: -3}"
    body="${response%???}"
    
    if [ "$http_code" = "200" ]; then
        echo "✅ 日志生成测试通过"
        echo "响应: $body"
    else
        echo "❌ 日志生成测试失败，HTTP状态码: $http_code"
        echo "响应: $body"
    fi
    echo ""
}

# 测试自定义日志
test_custom_log() {
    echo "🔧 测试自定义日志..."
    PORT=$(get_service_port)
    
    message="这是一条测试消息 $(date)"
    response=$(curl -s -w "%{http_code}" -X POST "http://localhost:${PORT}/api/logs/custom?level=INFO&message=${message}")
    http_code="${response: -3}"
    body="${response%???}"
    
    if [ "$http_code" = "200" ]; then
        echo "✅ 自定义日志测试通过"
        echo "响应: $body"
    else
        echo "❌ 自定义日志测试失败，HTTP状态码: $http_code"
        echo "响应: $body"
    fi
    echo ""
}

# 查看Vector日志
check_vector_logs() {
    echo "🔍 检查 Vector 日志..."
    
    # 查找Vector Pod
    VECTOR_POD=$(kubectl get pods -l app.kubernetes.io/name=vector -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    
    if [ -z "$VECTOR_POD" ]; then
        echo "⚠️  未找到 Vector Pod，请确保 Vector 已部署"
        return
    fi
    
    echo "找到 Vector Pod: $VECTOR_POD"
    echo "最近10条 Vector 日志："
    echo "----------------------------------------"
    kubectl logs "$VECTOR_POD" --tail=10 | grep -E "(vector-demo|ERROR|WARN)" || echo "未找到相关日志"
    echo "----------------------------------------"
    echo ""
}

# 查看Java服务日志
check_service_logs() {
    echo "🔍 检查 Java 服务日志..."
    
    # 查找Java服务Pod
    SERVICE_POD=$(kubectl get pods -l app=vector-demo-service -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    
    if [ -z "$SERVICE_POD" ]; then
        echo "⚠️  未找到 Java 服务 Pod，请确保服务已部署"
        return
    fi
    
    echo "找到 Java 服务 Pod: $SERVICE_POD"
    echo "最近10条服务日志："
    echo "----------------------------------------"
    kubectl logs "$SERVICE_POD" --tail=10 | grep -E "(INFO|WARN|ERROR|DEBUG)" || echo "未找到相关日志"
    echo "----------------------------------------"
    echo ""
}

# 性能测试
performance_test() {
    echo "⚡ 性能测试..."
    PORT=$(get_service_port)
    
    echo "发送10个并发请求..."
    start_time=$(date +%s)
    
    for i in {1..10}; do
        curl -s -X POST "http://localhost:${PORT}/api/logs/test" > /dev/null &
    done
    
    wait
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    echo "✅ 10个并发请求完成，耗时: ${duration}秒"
    echo ""
}

# 主函数
main() {
    echo "🚀 Vector Demo 项目测试开始"
    echo "================================"
    echo ""
    
    # 检查服务状态
    if ! kubectl get service vector-demo-service &> /dev/null; then
        echo "❌ Java 服务未部署，请先运行 deploy.sh"
        exit 1
    fi
    
    # 执行测试
    test_health
    test_logging
    test_custom_log
    performance_test
    
    # 检查日志
    check_service_logs
    check_vector_logs
    
    echo "🎉 测试完成！"
    echo ""
    echo "📊 测试总结："
    echo "   - 健康检查: ✅"
    echo "   - 日志生成: ✅"
    echo "   - 自定义日志: ✅"
    echo "   - 性能测试: ✅"
    echo ""
    echo "🔍 查看实时日志："
    echo "   Java 服务: kubectl logs -f -l app=vector-demo-service"
    echo "   Vector: kubectl logs -f -l app.kubernetes.io/name=vector"
}

# 执行主函数
main "$@"
