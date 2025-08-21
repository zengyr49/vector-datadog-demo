package com.example.vectordemo.controller;

import com.example.vectordemo.service.LogService;
import io.cloudevents.CloudEvent;
import io.cloudevents.core.builder.CloudEventBuilder;
import io.cloudevents.core.format.ContentType;
import io.cloudevents.core.provider.EventFormatProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/logs")
public class LogController {

    private static final Logger logger = LoggerFactory.getLogger(LogController.class);

    private static final String CLOUD_EVENT_SOURCE = "JAVA-SERVICE-LOG-CONTROLLER"; // 替换为实际的事件源
    
    @Autowired
    private LogService logService;

    /**
     * 生成CloudEvent日志
     * @return ResponseEntity<Map<String, Object>>
     */
    @PostMapping("/cloudevent")
    public ResponseEntity<Map<String, Object>> generateCloudEventLog() {
        // 写入cloudevents
        CloudEvent event = CloudEventBuilder.v1()
                .withId(UUID.randomUUID().toString())
                .withSource(URI.create(CLOUD_EVENT_SOURCE))
                .withType("com.example.vectordemo.log.testType")
                .withTime(OffsetDateTime.now())
                .withData("application/json", "{\"message\":\"测试日志事件cclloouuddeevveenntt\"}".getBytes())
                .build();
        byte[] jsonEvent = EventFormatProvider.getInstance().resolveFormat(ContentType.JSON).serialize(event);
        logger.info(new String(jsonEvent));
        return ResponseEntity.ok(new HashMap<>());
    }

    /**
     * 测试日志写入接口
     */
    @PostMapping("/test")
    public ResponseEntity<Map<String, Object>> testLogging() {
        logger.info("收到测试日志请求");
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "日志测试成功");
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("status", "success");
        
        // 触发不同类型的日志
        logService.generateTestLogs();
        
        logger.info("测试日志请求处理完成，响应: {}", response);
        return ResponseEntity.ok(response);
    }

    /**
     * 自定义日志级别接口
     */
    @PostMapping("/custom")
    public ResponseEntity<Map<String, Object>> customLogging(
            @RequestParam(defaultValue = "INFO") String level,
            @RequestParam String message) {
        
        logger.info("收到自定义日志请求 - 级别: {}, 消息: {}", level, message);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "自定义日志写入成功");
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("logLevel", level);
        response.put("logMessage", message);
        
        // 根据级别写入日志
        logService.writeCustomLog(level, message);
        
        logger.info("自定义日志请求处理完成");
        return ResponseEntity.ok(response);
    }

    /**
     * 健康检查接口
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("service", "vector-demo-service");
        
        logger.debug("健康检查请求");
        return ResponseEntity.ok(response);
    }
}
