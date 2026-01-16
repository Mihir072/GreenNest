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
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/orders")
public class OrderController {

    @Autowired
    private OrderService orderService;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private EmailService emailService;

    // Place new order
    @PostMapping("/place")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<?> placeOrder(@RequestBody Order order, @RequestHeader("Authorization") String authHeader) {
        try {
            String token = authHeader.replace("Bearer ", "");
            Claims claims = JwtUtil.extractAllClaims(token);
            String userId = claims.get("userId", String.class);
            order.setUserId(userId);

            System.out.println("Creating order: " + order);
            System.out.println("Order items: " + order.getItems());

            Order savedOrder = orderService.createOrder(order);

            System.out.println("Order created successfully with ID: " + savedOrder.getId());

            // Send confirmation email
            String emailBody = buildOrderConfirmationEmail(order);
            emailService.sendEmail(order.getEmail(), "Your Order Confirmation - GreenNest", emailBody);

            return ResponseEntity.status(HttpStatus.CREATED).body(savedOrder);
        } catch (Exception e) {
            System.err.println("Error placing order: " + e.getMessage());
            e.printStackTrace();
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to place order: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
    }

    // Get user's orders
    @GetMapping("/my-orders")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<?> getUserOrders(@RequestHeader("Authorization") String authHeader) {
        try {
            String token = authHeader.replace("Bearer ", "");
            Claims claims = jwtUtil.extractAllClaims(token);
            String userId = claims.get("userId", String.class);
            List<Order> orders = orderService.getOrdersByUserId(userId);
            return ResponseEntity.ok(orders);
        } catch (Exception e) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to fetch orders");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
    }

    // Get specific order by ID
    @GetMapping("/{orderId}")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<?> getOrderById(@PathVariable String orderId, @RequestHeader("Authorization") String authHeader) {
        try {
            String token = authHeader.replace("Bearer ", "");
            Claims claims = jwtUtil.extractAllClaims(token);
            String userId = claims.get("userId", String.class);

            Optional<Order> order = orderService.getOrderById(orderId);
            if (order.isPresent() && order.get().getUserId().equals(userId)) {
                return ResponseEntity.ok(order.get());
            }

            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Order not found or unauthorized");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
        } catch (Exception e) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to fetch order");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
    }

    // Helper method to format order confirmation email
    private String buildOrderConfirmationEmail(Order order) {
        StringBuilder emailBody = new StringBuilder();
        emailBody.append("Hello ").append(order.getName()).append(",\n\n");
        emailBody.append("Thank you for your order! 🎉\n\n");
        emailBody.append("Here are your order details:\n\n");
        emailBody.append("Items:\n");

        if (order.getItems() != null) {
            for (OrderItem item : order.getItems()) {
                emailBody.append("- ").append(item.getName())
                        .append(" (x").append(item.getQuantity())
                        .append(") - ₹").append(item.getPrice()).append("\n");
            }
        }

        emailBody.append("\nTotal Amount: ₹").append(order.getTotalAmount()).append("\n\n");
        emailBody.append("We will deliver your order to:\n");
        emailBody.append(order.getAddress()).append("\n\n");
        emailBody.append("Order Status: ").append(order.getStatus()).append("\n\n");
        emailBody.append("Thanks,\nTeam GreenNest");

        return emailBody.toString();
    }
}
