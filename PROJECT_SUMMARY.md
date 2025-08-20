# Vector Demo 项目总结

## 🎯 项目目标

创建一个完整的 Vector 学习项目，演示如何使用 Vector 收集、转换和输出 Java 服务的日志。

## 🏗️ 项目架构

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Java 服务     │    │   Kubernetes    │    │     Vector      │
│                 │    │                 │    │                 │
│  - REST API     │───▶│  - Pod 日志     │───▶│  - 日志收集     │
│  - 日志输出     │    │  - 标准输出     │    │  - 日志转换     │
│  - 业务逻辑     │    │  - 容器管理     │    │  - 日志路由     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                │                       ▼
                                │              ┌─────────────────┐
                                │              │   输出目标      │
                                │              │                 │
                                │              │  - 控制台       │
                                │              │  - 文件         │
                                │              │  - Elasticsearch│
                                │              │  - Kafka        │
                                └──────────────┴─────────────────┘
```

## 📁 项目结构

```
vector-demo/
├── README.md                    # 项目说明文档
├── PROJECT_SUMMARY.md           # 项目总结（本文件）
├── VECTOR_USAGE.md             # Vector 使用说明
├── java-service/                # Java Spring Boot 服务
│   ├── pom.xml                 # Maven 配置
│   ├── src/                    # 源代码
│   │   └── main/
│   │       ├── java/
│   │       │   └── com/example/vectordemo/
│   │       │       ├── VectorDemoApplication.java
│   │       │       ├── controller/
│   │       │       │   └── LogController.java
│   │       │       └── service/
│   │       │           └── LogService.java
│   │       └── resources/
│   │           └── application.yml
│   └── k8s/                    # Kubernetes 部署配置
│       └── deployment.yaml
├── docker/                      # Docker 相关文件
│   └── Dockerfile
├── vector-config/               # Vector 配置示例
│   └── vector.toml
├── scripts/                     # 部署和测试脚本
│   ├── deploy.sh               # 部署脚本
│   └── test.sh                 # 测试脚本
└── helm-charts/                 # Helm Chart（可选）
    └── vector/
```

## 🚀 核心功能

### 1. Java 服务功能

- **REST API 接口**：
  - `POST /api/logs/test` - 生成测试日志
  - `POST /api/logs/custom` - 写入自定义日志
  - `GET /api/logs/health` - 健康检查

- **日志特性**：
  - 多级别日志（TRACE, DEBUG, INFO, WARN, ERROR）
  - 结构化日志输出
  - 业务场景模拟（订单、支付、库存等）
  - 自动日志轮转

### 2. Vector 日志收集

- **自动收集**：通过 DaemonSet 收集所有 Pod 日志
- **智能解析**：自动解析 JSON 格式日志
- **字段增强**：添加业务元数据和 Kubernetes 信息
- **灵活输出**：支持多种输出目标

### 3. Kubernetes 集成

- **容器化部署**：Docker 镜像构建
- **Kubernetes 部署**：Deployment 和 Service
- **健康检查**：Liveness 和 Readiness 探针
- **资源管理**：CPU 和内存限制

## 🔧 技术栈

- **后端框架**：Spring Boot 3.2.0
- **Java 版本**：OpenJDK 21
- **构建工具**：Maven
- **容器化**：Docker
- **编排平台**：Kubernetes
- **日志收集**：Vector 0.32.0
- **包管理**：Helm

## 📚 学习要点

### 1. Vector 核心概念

- **Sources（源）**：数据输入源
- **Transforms（转换）**：数据处理和转换
- **Sinks（输出）**：数据输出目标
- **VRL 语言**：Vector 的配置语言

### 2. Kubernetes 日志管理

- **容器日志收集**：标准输出和错误输出
- **DaemonSet 模式**：每个节点运行日志收集器
- **日志持久化**：HostPath 和 EmptyDir 卷
- **权限管理**：RBAC 和服务账户

### 3. 微服务日志策略

- **结构化日志**：JSON 格式便于解析
- **日志级别**：合理的日志分级策略
- **业务标识**：在日志中添加业务上下文
- **性能考虑**：异步日志和批量处理

## 🚀 快速开始

### 1. 环境准备

```bash
# 确保已安装以下工具
- kubectl
- helm
- docker
- maven
- java 21
```

### 2. 部署 Vector

```bash
# 使用官方 Helm Chart
helm repo add vector https://helm.vector.dev
helm repo update
helm install vector vector/vector --namespace logging --create-namespace
```

### 3. 部署 Java 服务

```bash
# 运行部署脚本
./scripts/deploy.sh
```

### 4. 测试验证

```bash
# 运行测试脚本
./scripts/test.sh
```

## 🔍 监控和调试

### 1. 查看服务状态

```bash
# 查看 Pod 状态
kubectl get pods -l app=vector-demo-service

# 查看服务状态
kubectl get service vector-demo-service

# 查看 Vector 状态
kubectl get pods -l app.kubernetes.io/name=vector
```

### 2. 查看日志

```bash
# 查看 Java 服务日志
kubectl logs -f -l app=vector-demo-service

# 查看 Vector 日志
kubectl logs -f -l app.kubernetes.io/name=vector

# 查看 Vector 配置
kubectl get configmap vector-config -o yaml
```

### 3. 访问服务

```bash
# 获取服务端口
NODE_PORT=$(kubectl get service vector-demo-service -o jsonpath='{.spec.ports[0].nodePort}')

# 测试健康检查
curl http://localhost:${NODE_PORT}/api/logs/health

# 生成测试日志
curl -X POST http://localhost:${NODE_PORT}/api/logs/test
```

## 🎯 扩展方向

### 1. 日志分析

- 集成 Elasticsearch 进行日志搜索和分析
- 使用 Kibana 创建日志可视化面板
- 实现日志告警和通知

### 2. 性能优化

- 配置日志批处理和压缩
- 实现日志采样和过滤
- 优化 Vector 资源配置

### 3. 多环境支持

- 开发、测试、生产环境配置
- 不同环境的日志级别和输出策略
- 环境特定的监控和告警

### 4. 安全增强

- 日志加密和访问控制
- 敏感信息脱敏处理
- 审计日志和合规性

## 📖 学习资源

- [Vector 官方文档](https://vector.dev/docs/)
- [Spring Boot 官方文档](https://spring.io/projects/spring-boot)
- [Kubernetes 官方文档](https://kubernetes.io/docs/)
- [Helm 官方文档](https://helm.sh/docs/)

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request 来改进这个项目！

## 📄 许可证

本项目采用 MIT 许可证。
