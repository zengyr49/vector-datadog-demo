# Vector 使用说明

## 概述

Vector 是 Datadog 旗下的高性能日志收集、转换和路由工具。它支持多种输入源、转换操作和输出目标，特别适合在 Kubernetes 环境中使用。

## 核心概念

### 1. 组件类型

- **Sources（源）**: 数据输入源，如文件、HTTP、Kubernetes日志等
- **Transforms（转换）**: 数据处理和转换，如过滤、解析、重映射等
- **Sinks（输出）**: 数据输出目标，如文件、数据库、消息队列等

### 2. 数据流

```
Sources → Transforms → Sinks
```

## 在 Kubernetes 中使用 Vector

### 1. 部署 Vector

```bash
# 添加 Vector Helm 仓库
helm repo add vector https://helm.vector.dev
helm repo update

# 安装 Vector
helm install vector vector/vector \
  --namespace logging \
  --create-namespace \
  --set customConfig.enabled=true
```

### 2. 配置 Vector 收集 Java 服务日志

Vector 会自动收集 Kubernetes 中所有 Pod 的标准输出日志。对于我们的 Java 服务：

```toml
# 收集 Kubernetes 日志
[sources.kubernetes_logs]
type = "kubernetes_logs"
glob_minimum_cooldown_ms = 1000

# 解析 JSON 日志
[transforms.parse_json_logs]
type = "remap"
inputs = ["kubernetes_logs"]
source = '''
# 解析日志消息
if exists(.message) {
  parsed = parse_json!(.message)
  if exists(parsed) {
    . = merge(., parsed)
  }
}

# 添加元数据
.service = "vector-demo"
.timestamp = now()
'''
```

### 3. 日志收集流程

1. **Java 服务** 写入日志到 stdout/stderr
2. **Kubernetes** 将日志写入 `/var/log/containers/` 目录
3. **Vector DaemonSet** 在每个节点上运行，收集该节点的所有容器日志
4. **Vector** 应用转换规则，处理日志数据
5. **Vector** 将处理后的日志发送到配置的输出目标

## 常用转换操作

### 1. 过滤日志

```toml
[transforms.filter_errors]
type = "filter"
inputs = ["kubernetes_logs"]
condition = '.level == "ERROR"'
```

### 2. 解析结构化日志

```toml
[transforms.parse_logs]
type = "remap"
inputs = ["kubernetes_logs"]
source = '''
# 解析 JSON 日志
if exists(.message) {
  . = merge(., parse_json!(.message))
}

# 提取字段
.user_id = .user_id
.action = .action
.timestamp = .timestamp
'''
```

### 3. 添加字段

```toml
[transforms.add_fields]
type = "remap"
inputs = ["parse_logs"]
source = '''
.environment = "production"
.datacenter = "us-west-1"
.service_version = "1.0.0"
'''
```

## 输出配置示例

### 1. 控制台输出（调试用）

```toml
[sinks.console]
type = "console"
inputs = ["processed_logs"]
encoding.codec = "json"
```

### 2. 文件输出

```toml
[sinks.file]
type = "file"
inputs = ["processed_logs"]
path = "/var/log/vector/app-logs.log"
encoding.codec = "json"
```

### 3. Elasticsearch 输出

```toml
[sinks.elasticsearch]
type = "elasticsearch"
inputs = ["processed_logs"]
endpoint = "http://elasticsearch:9200"
index = "app-logs-%Y-%m-%d"
encoding.codec = "json"
```

### 4. Kafka 输出

```toml
[sinks.kafka]
type = "kafka"
inputs = ["processed_logs"]
bootstrap_servers = ["kafka:9092"]
topic = "app-logs"
encoding.codec = "json"
```

## 监控和调试

### 1. 查看 Vector 状态

```bash
# 查看 Vector Pod 状态
kubectl get pods -l app.kubernetes.io/name=vector

# 查看 Vector 日志
kubectl logs -l app.kubernetes.io/name=vector -f

# 查看 Vector 配置
kubectl get configmap vector-config -o yaml
```

### 2. 测试配置

```bash
# 进入 Vector Pod 测试配置
kubectl exec -it vector-xxxxx -- vector validate /etc/vector/vector.yaml

# 查看 Vector 指标
kubectl port-forward svc/vector 8686:8686
curl http://localhost:8686/metrics
```

### 3. 常见问题排查

- **日志不收集**: 检查 Pod 标签、命名空间、权限
- **转换失败**: 检查 VRL 语法、字段路径
- **输出失败**: 检查网络连接、认证信息、目标服务状态

## 性能优化

### 1. 资源限制

```yaml
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 100m
    memory: 128Mi
```

### 2. 批处理配置

```toml
[sinks.elasticsearch]
type = "elasticsearch"
inputs = ["logs"]
endpoint = "http://elasticsearch:9200"
batch.max_events = 1000
batch.timeout_secs = 5
```

### 3. 并发控制

```toml
[sinks.elasticsearch]
type = "elasticsearch"
inputs = ["logs"]
endpoint = "http://elasticsearch:9200"
request.concurrency = 10
```

## 最佳实践

1. **使用标签过滤**: 只收集需要的 Pod 日志
2. **结构化日志**: 使用 JSON 格式便于解析
3. **错误处理**: 配置重试和死信队列
4. **监控告警**: 设置 Vector 自身的监控
5. **配置管理**: 使用 ConfigMap 管理配置
6. **版本控制**: 配置变更要经过审核

## 学习资源

- [Vector 官方文档](https://vector.dev/docs/)
- [VRL 语言参考](https://vector.dev/docs/reference/vrl/)
- [Kubernetes 集成指南](https://vector.dev/docs/setup/installation/platforms/kubernetes/)
- [性能调优指南](https://vector.dev/docs/setup/deployment/performance/)
