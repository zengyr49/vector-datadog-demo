# Vector Demo 项目

这是一个学习 Vector（Datadog旗下的日志收集和转换工具）的演示项目，展示了如何使用 Vector 收集、转换和输出 Java 服务的日志。

## 🎯 项目目标

- **学习 Vector**: 了解 Vector 的核心概念和配置方法
- **日志收集**: 演示 Vector 如何收集 Kubernetes 中的 Java 服务日志
- **日志转换**: 展示 Vector 的日志解析、过滤和增强功能
- **多输出**: 实现日志同时输出到控制台、文件等不同目标
- **实践应用**: 通过实际项目学习 Vector 的最佳实践

## 🏗️ 项目架构

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Java 服务     │    │   Kubernetes    │    │     Vector      │
│                 │    │                 │    │                 │
│  - Spring Boot  │───▶│  - Pod 日志     │───▶│  - 日志收集     │
│  - CloudEvents  │    │  - 标准输出     │    │  - 日志转换     │
│  - REST API     │    │  - 容器管理     │    │  - 日志路由     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                │                       ▼
                                │              ┌─────────────────┐
                                │              │   输出目标      │
                                │              │                 │
                                │              │  - 控制台       │
                                │              │  - 文件         │
                                │              │  - Prometheus   │
                                └──────────────┴─────────────────┘
```

## 📁 项目结构

```
vector-demo/
├── README.md                    # 项目说明文档（本文件）
├── java-service/                # Java Spring Boot 服务
│   ├── pom.xml                 # Maven 项目配置
│   ├── src/                    # 源代码目录
│   │   └── main/
│   │       ├── java/
│   │       │   └── com/example/vectordemo/
│   │       │       ├── VectorDemoApplication.java    # Spring Boot 主应用
│   │       │       ├── controller/                   # REST API 控制器
│   │       │       │   └── LogController.java        # 日志管理接口
│   │       │       └── service/                      # 业务逻辑服务
│   │       │           └── LogService.java           # 日志生成服务
│   │       └── resources/
│   │           ├── application.yml                   # Spring Boot 配置
│   │           └── logback-spring.xml                # 日志配置
│   └── k8s/                    # Kubernetes 部署配置
│       └── deployment.yaml     # 部署和服务配置
├── docker/                      # Docker 相关文件
│   └── Dockerfile              # Java 服务容器化配置
├── scripts/                     # 部署和测试脚本
│   ├── deploy.sh               # 项目部署脚本
│   └── test.sh                 # 功能测试脚本
└── vector-config/               # Vector 配置示例
    └── vector-simple.toml      # Vector 配置文件
```

## 🔧 技术栈

- **后端框架**: Spring Boot 3.2.0
- **Java 版本**: OpenJDK 21
- **构建工具**: Maven 3.8+
- **容器化**: Docker
- **编排平台**: Kubernetes
- **日志收集**: Vector 0.32.0+
- **包管理**: Helm
- **日志格式**: CloudEvents 1.0 (JSON)

## 🚀 核心功能

### 1. Java 服务功能

- **REST API 接口**：
  - `POST /api/logs/test` - 生成测试日志
  - `POST /api/logs/custom` - 写入自定义日志
  - `GET /api/logs/health` - 健康检查

- **日志特性**：
  - 多级别日志（TRACE, DEBUG, INFO, WARN, ERROR）
  - CloudEvents JSON 格式输出
  - 结构化业务日志（订单、支付、库存等）
  - 自动日志轮转和持久化

### 2. Vector 日志收集

- **自动收集**: 通过 DaemonSet 收集所有 Pod 日志
- **智能解析**: 自动解析 JSON 格式日志
- **字段增强**: 添加业务元数据和 Kubernetes 信息
- **灵活输出**: 支持控制台、文件、Prometheus 等多种输出目标

### 3. Kubernetes 集成

- **容器化部署**: Docker 镜像构建和部署
- **Kubernetes 编排**: Deployment 和 Service 配置
- **健康检查**: Liveness 和 Readiness 探针
- **资源管理**: CPU 和内存限制配置

## 📚 学习要点

### 1. Vector 核心概念

- **Sources（源）**: 数据输入源，如 Kubernetes 日志、文件等
- **Transforms（转换）**: 数据处理和转换，如过滤、解析、重映射等
- **Sinks（输出）**: 数据输出目标，如控制台、文件、数据库等
- **VRL 语言**: Vector 的配置语言，用于数据转换

### 2. Kubernetes 日志管理

- **容器日志收集**: 标准输出和错误输出
- **DaemonSet 模式**: 每个节点运行日志收集器
- **日志持久化**: HostPath 和 EmptyDir 卷管理
- **权限管理**: RBAC 和服务账户配置

### 3. 微服务日志策略

- **结构化日志**: JSON 格式便于解析和分析
- **日志级别**: 合理的日志分级和过滤策略
- **业务标识**: 在日志中添加业务上下文信息
- **性能考虑**: 异步日志和批量处理

## 🎯 适用场景

- **学习 Vector**: 初学者了解 Vector 的基本概念和配置
- **日志收集实践**: 实际项目中实现日志收集和分析
- **微服务监控**: 构建基于日志的微服务监控体系
- **DevOps 实践**: 学习容器化部署和日志管理
- **云原生架构**: 理解云原生应用中的日志处理流程

## 🔍 项目特色

- **完整示例**: 从 Java 服务到 Vector 配置的完整链路
- **实用性强**: 基于实际业务场景的日志生成和处理
- **配置灵活**: 支持多种输出目标和转换规则
- **易于扩展**: 模块化设计，便于添加新功能
- **最佳实践**: 遵循 Vector 和 Kubernetes 的最佳实践

## 📖 相关资源

- [Vector 官方文档](https://vector.dev/docs/)
- [Spring Boot 官方文档](https://spring.io/projects/spring-boot)
- [Kubernetes 官方文档](https://kubernetes.io/docs/)
- [Helm 官方文档](https://helm.sh/docs/)
- [CloudEvents 规范](https://cloudevents.io/)

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request 来改进这个项目！

## 📄 许可证

本项目采用 MIT 许可证。
