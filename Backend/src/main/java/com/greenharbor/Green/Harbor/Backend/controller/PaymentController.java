package com.greenharbor.Green.Harbor.Backend.controller;

import com.greenharbor.Green.Harbor.Backend.config.JwtUtil;
import io.jsonwebtoken.Claims;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/payments")
@PreAuthorize("hasRole('USER')")
public class PaymentController {

    @Autowired
    private JwtUtil jwtUtil;

    // Initiate payment
    @PostMapping("/initiate")
    public ResponseEntity<?> initiatePayment(@RequestBody Map<String, Object> paymentData,
                                             @RequestHeader("Authorization") String authHeader) {
        try {
            System.out.println("Payment Data Received: " + paymentData);
            
            String token = authHeader.replace("Bearer ", "");
            Claims claims = JwtUtil.extractAllClaims(token);
            String userId = claims.get("userId", String.class);

            // Generate unique payment ID
            String paymentId = UUID.randomUUID().toString();

            Map<String, Object> response = new HashMap<>();
            response.put("paymentId", paymentId);
            response.put("userId", userId);
            response.put("amount", paymentData.get("amount"));
            response.put("orderId", paymentData.get("orderId"));
            response.put("status", "INITIATED");
            response.put("timestamp", System.currentTimeMillis());

            System.out.println("Payment Initiated with ID: " + paymentId);

            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            System.err.println("Error initiating payment: " + e.getMessage());
            e.printStackTrace();
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to initiate payment: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
    }

    // Verify payment
    @PostMapping("/verify")
    public ResponseEntity<?> verifyPayment(@RequestParam String paymentId,
                                          @RequestParam boolean isSuccess,
                                          @RequestParam(required = false) String failureReason,
                                          @RequestHeader("Authorization") String authHeader) {
        try {
            String token = authHeader.replace("Bearer ", "");
            Claims claims = JwtUtil.extractAllClaims(token);
            String userId = claims.get("userId", String.class);

            Map<String, Object> response = new HashMap<>();
            response.put("paymentId", paymentId);
            response.put("userId", userId);
            response.put("status", isSuccess ? "SUCCESS" : "FAILED");
            response.put("failureReason", failureReason);
            response.put("verifiedAt", System.currentTimeMillis());

            if (isSuccess) {
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }
        } catch (Exception e) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to verify payment");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
    }
}
