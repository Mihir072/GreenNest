package com.greenharbor.Green.Harbor.Backend.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import java.util.logging.Logger;

@Service
public class KeepAliveService {

    private static final Logger logger = Logger.getLogger(KeepAliveService.class.getName());
    
    private final RestTemplate restTemplate;
    
    @Value("${server.servlet.context-path:}")
    private String contextPath;
    
    @Value("${server.port:8080}")
    private String serverPort;
    
    @Autowired
    public KeepAliveService(RestTemplateBuilder restTemplateBuilder) {
        this.restTemplate = restTemplateBuilder
                .setConnectTimeout(java.time.Duration.ofSeconds(5))
                .setReadTimeout(java.time.Duration.ofSeconds(5))
                .build();
    }

    /**
     * Sends a keep-alive request to the server every 4 seconds
     * This prevents the server from going to sleep on platforms like Render
     */
    @Scheduled(fixedDelay = 4000) // 4 seconds
    public void sendKeepAliveRequest() {
        try {
            String url = "http://localhost:" + serverPort + contextPath + "/api/health";
            
            // Send a GET request to a health check endpoint
            String response = restTemplate.getForObject(url, String.class);
            
            logger.info("✓ Keep-alive request sent successfully at " + java.time.LocalDateTime.now());
        } catch (RestClientException e) {
            // Log but don't fail - this is expected if the endpoint doesn't exist
            logger.warning("Keep-alive request failed: " + e.getMessage());
        } catch (Exception e) {
            logger.severe("Unexpected error in keep-alive service: " + e.getMessage());
        }
    }
}
