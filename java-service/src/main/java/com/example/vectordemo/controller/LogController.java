package com.example.vectordemo.controller;

import com.example.vectordemo.service.LogService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/logs")
public class LogController {

    private static final Logger logger = LoggerFactory.getLogger(LogController.class);
    
    @Autowired
    private LogService logService;

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
