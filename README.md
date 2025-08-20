# Vector Demo 项目

这是一个学习Vector（Datadog旗下的日志收集和转换工具）的演示项目。

## 项目结构

```
vector-demo/
├── java-service/          # Java Spring Boot服务
├── helm-charts/           # Vector Helm部署配置
├── docker/                # Docker相关文件
├── scripts/               # 部署脚本
└── README.md              # 项目说明
```

## 功能特性

- **Java服务**: 基于Spring Boot 3.2.0，暴露REST API接口，调用后触发日志写入
- **Vector配置**: 收集、转换和输出日志
- **Helm部署**: 使用Kubernetes Helm快速部署

## 快速开始

### 1. 部署Vector
```bash
cd helm-charts
helm install vector ./vector
```

### 2. 部署Java服务
```bash
cd java-service
kubectl apply -f k8s/
```

### 3. 测试日志收集
```bash
curl http://localhost:8080/api/logs/test
```

## 架构说明

1. **Java服务** 写入日志到stdout
2. **Vector** 通过DaemonSet收集所有Pod的日志
3. **Vector** 转换日志格式并输出到控制台

## 学习要点

- Vector的配置语法
- Helm部署Vector
- Java应用日志收集
- Kubernetes日志管理
