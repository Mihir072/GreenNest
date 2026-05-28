package com.greenharbor.Green.Harbor.Backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

@RestController
@RequestMapping("/api")
public class HealthController {

    private static final Logger logger = Logger.getLogger(HealthController.class.getName());

    /**
     * Health check endpoint for monitoring and keep-alive requests
     * This endpoint is pinged every 4 seconds by the keep-alive service
     * to prevent the server from going to sleep on platforms like Render
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", LocalDateTime.now());
        response.put("message", "Server is running");
        
        logger.info("✓ Keep-alive ping received - Server is healthy");
        
        return ResponseEntity.ok(response);
    }
}
