package com.example.vectordemo.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Random;

@Service
public class LogService {

    private static final Logger logger = LoggerFactory.getLogger(LogService.class);
    private final Random random = new Random();

    /**
     * 生成测试日志
     */
    public void generateTestLogs() {
        logger.info("=== 开始生成测试日志 ===");
        
        // 生成不同级别的日志
        logger.trace("这是一条TRACE级别的日志 - {}", LocalDateTime.now());
        logger.debug("这是一条DEBUG级别的日志 - {}", LocalDateTime.now());
        logger.info("这是一条INFO级别的日志 - {}", LocalDateTime.now());
        logger.warn("这是一条WARN级别的日志 - {}", LocalDateTime.now());
        logger.error("这是一条ERROR级别的日志 - {}", LocalDateTime.now());
        
        // 生成结构化日志
        generateStructuredLogs();
        
        // 生成模拟业务日志
        generateBusinessLogs();
        
        logger.info("=== 测试日志生成完成 ===");
    }

    /**
     * 写入自定义日志
     */
    public void writeCustomLog(String level, String message) {
        switch (level.toUpperCase()) {
            case "TRACE":
                logger.trace("自定义TRACE日志: {}", message);
                break;
            case "DEBUG":
                logger.debug("自定义DEBUG日志: {}", message);
                break;
            case "INFO":
                logger.info("自定义INFO日志: {}", message);
                break;
            case "WARN":
                logger.warn("自定义WARN日志: {}", message);
                break;
            case "ERROR":
                logger.error("自定义ERROR日志: {}", message);
                break;
            default:
                logger.info("未知日志级别[{}]，使用INFO级别: {}", level, message);
        }
    }

    /**
     * 生成结构化日志
     */
    private void generateStructuredLogs() {
        logger.info("用户操作日志 - userId: {}, action: {}, timestamp: {}", 
                   "user123", "login", LocalDateTime.now());
        
        logger.info("系统性能日志 - cpu: {}%, memory: {}MB, responseTime: {}ms", 
                   random.nextInt(100), random.nextInt(8192), random.nextInt(1000));
        
        logger.warn("业务警告日志 - orderId: {}, status: {}, reason: {}", 
                   "ORD-" + random.nextInt(10000), "pending", "库存不足");
    }

    /**
     * 生成模拟业务日志
     */
    private void generateBusinessLogs() {
        // 模拟订单处理日志
        String orderId = "ORD-" + System.currentTimeMillis();
        logger.info("订单创建成功 - orderId: {}, amount: {}, customer: {}", 
                   orderId, random.nextInt(10000), "customer" + random.nextInt(100));
        
        // 模拟支付日志
        logger.info("支付处理中 - orderId: {}, paymentMethod: {}, amount: {}", 
                   orderId, "credit_card", random.nextInt(10000));
        
        // 模拟库存日志
        logger.debug("库存检查 - productId: {}, available: {}, reserved: {}", 
                   "PROD-" + random.nextInt(1000), random.nextInt(100), random.nextInt(50));
        
        // 模拟错误日志
        if (random.nextInt(10) < 3) {
            logger.error("模拟业务错误 - orderId: {}, error: {}, stackTrace: {}", 
                       orderId, "支付超时", "PaymentTimeoutException");
        }
    }
}
