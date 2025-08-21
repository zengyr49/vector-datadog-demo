# Vector 配置部署说明

## 🎯 配置目标

收集 `vector-service-demo` namespace 下 `vector-demo-service` Pod 的日志，包括：
- 控制台日志（stdout/stderr）
- 文件日志（`/app/logs/vector-demo.log`）
- 输出到控制台和文件

## 📁 配置文件说明

### 1. `vector-simple.yaml`（推荐使用）
- 简化版本，专注于核心功能
- 自动收集 Kubernetes 日志
- 解析 JSON 格式日志
- 输出到控制台和文件

### 2. `vector-java-service.yaml`
- 完整版本，包含更多高级功能
- 支持多种日志源
- 包含 Prometheus 指标
- 更详细的业务字段分析

## 🔄 配置文件转换

由于 Vector 需要 TOML 格式，我们提供了转换脚本：

### 自动转换
```bash
# 运行转换脚本
chmod +x convert.sh
./convert.sh
```

### 手动转换
```bash
# 转换简化配置
python3 convert-yaml-to-toml.py vector-simple.yaml vector-simple.toml

# 转换完整配置
python3 convert-yaml-to-toml.py vector-java-service.yaml vector-java-service.toml
```

## 🚀 部署步骤

### 步骤 1: 创建 ConfigMap

```bash
# 使用简化配置（推荐）
kubectl create configmap vector-config \
  --from-file=vector.toml=vector-config/vector-simple.toml \
  --namespace=logging \
  --dry-run=client -o yaml | kubectl apply -f -

# 或者使用完整配置
kubectl create configmap vector-config \
  --from-file=vector.toml=vector-config/vector-java-service.toml \
  --namespace=logging \
  --dry-run=client -o yaml | kubectl apply -f -
```

### 步骤 2: 使用 Helm 安装 Vector

```bash
# 创建自定义 values.yaml
cat > vector-values.yaml << 'EOF'
# Vector 自定义配置
customConfig:
  enabled: true
  configMap: vector-config
  configMapKey: vector.toml

# 镜像配置
image:
  repository: image.midea.com/midea-middleware/vector
  tag: "nightly-2025-08-20-debian"
  pullPolicy: IfNotPresent

# RBAC 配置
rbac:
  create: true
  rules:
    - apiGroups: [""]
      resources: ["pods", "namespaces"]
      verbs: ["get", "list", "watch"]

# 服务账户配置
serviceAccount:
  create: true
  name: "vector"

# DaemonSet 配置
daemonSet:
  enabled: true
  
  # 资源限制
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 100m
      memory: 128Mi
  
  # 容忍度（允许在控制平面节点运行）
  tolerations:
    - key: node-role.kubernetes.io/master
      effect: NoSchedule
    - key: node-role.kubernetes.io/control-plane
      effect: NoSchedule

# 服务配置
service:
  type: ClusterIP
  port: 8686
  targetPort: 8686
  ports:
    - name: api
      port: 8686
      targetPort: 8686
      protocol: TCP

# 持久化配置
persistence:
  enabled: false
EOF

# 安装 Vector
helm install vector vector/vector \
  --namespace logging \
  --create-namespace \
  -f vector-values.yaml
```

### 步骤 3: 验证部署

```bash
# 检查 Vector Pod 状态
kubectl get pods -n logging -l app.kubernetes.io/name=vector

# 查看 Vector 日志
kubectl logs -n logging -l app.kubernetes.io/name=vector -f

# 查看 Vector 配置
kubectl get configmap vector-config -n logging -o yaml
```

## 🧪 测试日志收集

### 1. 生成测试日志

```bash
# 获取 Java 服务端口
NODE_PORT=$(kubectl get service vector-demo-service -n vector-service-demo -o jsonpath='{.spec.ports[0].nodePort}')

# 生成测试日志
curl -X POST http://localhost:${NODE_PORT}/api/logs/test

# 生成错误日志
curl -X POST "http://localhost:${NODE_PORT}/api/logs/custom?level=ERROR&message=测试错误日志"
```

### 2. 验证日志收集

```bash
# 查看 Vector 控制台输出
kubectl logs -n logging -l app.kubernetes.io/name=vector --tail=20 | grep "vector-demo"

# 查看 Vector 文件输出
kubectl exec -it -n logging $(kubectl get pods -n logging -l app.kubernetes.io/name=vector -o jsonpath='{.items[0].metadata.name}') -- cat /var/log/vector/vector-demo-logs.log
```

## 🔍 配置说明

### 1. 日志收集流程

```
Java 服务日志 → Kubernetes 日志 → Vector 收集 → 解析转换 → 输出到 Console 和文件
```

### 2. 关键配置点

- **`kubernetes_logs`**: 自动收集所有 Pod 日志
- **`filter_demo_logs`**: 只处理 vector-demo 相关日志
- **`console_output`**: 输出到控制台便于调试
- **`file_output`**: 输出到文件持久化存储

### 3. 日志过滤逻辑

```yaml
condition: |
  # 只处理 vector-demo 相关的日志
  exists(.business_service) && .business_service == "vector-demo"
```

## 🚨 故障排除

### 1. 日志收集不到

```bash
# 检查 Java 服务是否运行
kubectl get pods -n vector-service-demo -l app=vector-demo-service

# 检查 Java 服务日志
kubectl logs -n vector-service-demo -l app=vector-demo-service -f

# 检查 Vector 权限
kubectl get clusterrolebinding | grep vector
```

### 2. 配置不生效

```bash
# 更新 ConfigMap
kubectl apply -f vector-config.yaml

# 重启 Vector DaemonSet
kubectl rollout restart daemonset/vector -n logging

# 查看 Vector 启动日志
kubectl logs -n logging -l app.kubernetes.io/name=vector --previous
```

### 3. 查看 Vector 状态

```bash
# 查看 Vector Pod 状态
kubectl describe pod -n logging -l app.kubernetes.io/name=vector

# 查看 Vector 事件
kubectl get events -n logging --sort-by='.lastTimestamp' | grep vector

# 查看 Vector 配置
kubectl exec -it -n logging $(kubectl get pods -n logging -l app.kubernetes.io/name=vector -o jsonpath='{.items[0].metadata.name}') -- vector validate /etc/vector/vector.yaml
```

## 📊 监控和调试

### 1. 查看 Vector 指标

```bash
# 端口转发
kubectl port-forward svc/vector 8686:8686 -n logging

# 查看指标
curl http://localhost:8686/metrics

# 查看特定指标
curl http://localhost:8686/metrics | grep "vector_"
```

### 2. 实时日志流

```bash
# 实时查看 Vector 日志
kubectl logs -n logging -l app.kubernetes.io/name=vector -f

# 实时查看 Java 服务日志
kubectl logs -n vector-service-demo -l app=vector-demo-service -f
```

## 🎉 完成！

现在你的 Vector 已经配置为：
1. ✅ 自动收集 `vector-demo-service` 的日志
2. ✅ 解析和转换日志数据
3. ✅ 输出到控制台便于调试
4. ✅ 输出到文件持久化存储

你可以通过调用 Java 服务的 API 来生成日志，然后观察 Vector 如何处理和输出这些日志！
