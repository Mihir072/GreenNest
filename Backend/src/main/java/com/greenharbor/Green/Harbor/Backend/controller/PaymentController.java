package com.greenharbor.Green.Harbor.Backend.controller;

import com.greenharbor.Green.Harbor.Backend.config.JwtUtil;
import com.greenharbor.Green.Harbor.Backend.model.Order;
import com.greenharbor.Green.Harbor.Backend.model.OrderItem;
import com.greenharbor.Green.Harbor.Backend.services.OrderService;
import com.greenharbor.Green.Harbor.Backend.services.EmailService;
import io.jsonwebtoken.Claims;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/payments")
@PreAuthorize("hasRole('USER')")
public class PaymentController {

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private OrderService orderService;

    @Autowired
    private EmailService emailService;

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
                                          @RequestParam(required = false) String orderId,
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
                // Send payment confirmation email if orderId is provided
                if (orderId != null && !orderId.isEmpty()) {
                    try {
                        Optional<Order> orderOptional = orderService.getOrderById(orderId);
                        if (orderOptional.isPresent()) {
                            Order order = orderOptional.get();
                            String emailBody = buildPaymentConfirmationEmail(order);
                            emailService.sendEmail(order.getEmail(), "Payment Confirmed - GreenNest", emailBody);
                            System.out.println("Payment confirmation email sent to: " + order.getEmail());
                        }
                    } catch (Exception emailError) {
                        System.err.println("Error sending payment confirmation email: " + emailError.getMessage());
                        emailError.printStackTrace();
                        // Don't fail the entire response if email fails, just log it
                    }
                }
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }
        } catch (Exception e) {
            System.err.println("Error verifying payment: " + e.getMessage());
            e.printStackTrace();
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to verify payment");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
    }

    // Helper method to build payment confirmation email
    private String buildPaymentConfirmationEmail(Order order) {
        StringBuilder emailBody = new StringBuilder();
        emailBody.append("Hello ").append(order.getName()).append(",\n\n");
        emailBody.append("Payment Confirmed! 💚\n\n");
        emailBody.append("Your payment has been successfully processed.\n\n");
        emailBody.append("Order Details:\n");
        emailBody.append("Order ID: ").append(order.getId()).append("\n");
        emailBody.append("Total Amount: ₹").append(order.getTotalAmount()).append("\n\n");
        
        emailBody.append("Items Ordered:\n");
        if (order.getItems() != null) {
            for (OrderItem item : order.getItems()) {
                emailBody.append("- ").append(item.getName())
                        .append(" (x").append(item.getQuantity())
                        .append(") - ₹").append(item.getPrice()).append("\n");
            }
        }

        emailBody.append("\nDelivery Address:\n");
        emailBody.append(order.getAddress()).append("\n\n");
        emailBody.append("Order Status: ").append(order.getStatus()).append("\n\n");
        emailBody.append("Thank you for choosing GreenNest!\n");
        emailBody.append("Track your order in the app.\n\n");
        emailBody.append("Best regards,\nTeam GreenNest");

        return emailBody.toString();
    }
}
