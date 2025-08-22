# Vector Demo 项目

这是一个学习 Vector（Datadog旗下的日志收集和转换工具）的演示项目，展示了如何使用 Vector 收集、转换和输出 Java 服务的日志。

## 🎯 项目目标

- **学习 Vector**: 了解 Vector 的核心概念和配置方法
- **日志收集**: 演示 Vector的agent模式 如何收集 Kubernetes 中的 Java 服务日志
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
└── vector-config/               # Vector 配置示例
    └── vector-simple.toml      # Vector 配置文件
```

## 🏃‍♂️ 快速开始
### 依赖命令
```
helm
maven
docker
kubectl
```
### 依赖组件
```
# 必须
Kubernetes > 1.9 # 可以选择本地的minikube或者真实的k8s集群或者随便k3s集群之流
Java

# 可选
Prometheus
GreptimeDB
```
### 1、安装vector
#### 1.1 更换./vector/values.yaml中的镜像，没有内网镜像就：
```shell
# 将image.repository设置为timberio/vector
# 将image.tag设置为""（空）
```
#### 1.2 helm安装vector
```shell
helm install vector ./vector --namespace vector --create-namespace
```
然后自行用k9s或者kubectl查看部署状态！Running就是跑起来了。
```shell
kubectl get pods -l app.kubernetes.io/name=vector -n vector
```

### 2、打包和部署Java Demo服务
```shell
# 进入java项目打包成jar包
cd java-service
mvn clean install

# 用Dockerfile打包镜像
docker build -t vector-demo-service:1.0.0 . -f ./docker/Dockerfile --platform linux/amd64

# 打包和推送镜像，自选。
docker images # 查看刚打包好的image id
docker tag <你刚打包好的image id> image.<company>.com/<company>-middleware/vector-demo-service:1.0.0
docker push image.<company>.com/<company>-middleware/vector-demo-service:1.0.0

# kubectl部署服务
# kubectl delete -f ./k8s/deployment.yaml -n vector-service-demo
kubectl apply -f ./k8s/deployment.yaml -n vector-service-demo
```

### 3、查看各种
#### 3.1 调用java服务写日志 -> vector日志console有打印
```shell
# 在一个terminal A输入，持续查看日志
kubectl logs -l app.kubernetes.io/name=vector -n vector -f | grep INFO

```

```shell
# 在另一个terminal B输入，触发生成一条info日志
curl -X POST http://<your ip>:8080/api/logs/cloudevent
```

稍等一会则可以在A中可以看到了一条INFO等级的信息

数据流动是 Java Demo Service -> Vector -> Console

#### *3.2 查看prometheus、greptimedb
在configmap中已经留了日志转发到 prometheus和greptimedb 的配置，可以直接在上面写上你的prometheus或greptimedb的服务器地址，则可以将数据传输到对应的组件中。

prometheus用于承接metrics，greptimedb承接log。而greptimedb也可以作为时序数据库，承接来自prometheus的remote write的metrics数据，落库持久化。


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
  - `POST /api/logs/cloudevent` - 写入cloudevent格式的日志（只有消息体是cloudevent格式，实际没什么用）

  例如
  ```shell
  curl -X POST http://<your ip>:8080/api/logs/custom?level=ERROR&message=someMessage
  curl -X POST http://<your ip>:8080/api/logs/test
  curl -X POST http://<your ip>:8080/api/logs/cloudevent
  ```

### 2. Vector 日志收集

- **自动收集**: 通过 DaemonSet 收集 java-demo-service的 Pod 日志
- **智能解析**: 自动解析 JSON 格式日志
- **字段增强**: 添加业务元数据和 Kubernetes 信息
- **灵活输出**: 支持控制台、文件、Prometheus 等多种输出目标

### 3. Kubernetes 集成

- **容器化部署**: Docker 镜像构建和部署
- **Kubernetes 编排**: Deployment 和 Service 配置
- **健康检查**: Liveness 和 Readiness 探针
- **资源管理**: CPU 和内存限制配置

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
