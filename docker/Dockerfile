# 使用OpenJDK 21作为基础镜像
FROM image.company.com/t-mahas-public/prd/custom-jdk:21

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV JAVA_OPTS="-Xmx512m -Xms256m"
ENV TZ=Asia/Shanghai

# 复制JAR文件
COPY java-service/target/vector-demo-service-1.0.0.jar app.jar

# 创建日志目录
RUN mkdir -p /app/logs

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/api/logs/health || exit 1

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
