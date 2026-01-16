package com.greenharbor.Green.Harbor.Backend.services;

import java.util.List;
import java.util.Optional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.greenharbor.Green.Harbor.Backend.model.Order;
import com.greenharbor.Green.Harbor.Backend.repository.OrderRepo;

@Service
public class OrderService {

    @Autowired
    private OrderRepo orderRepo;

    // Create order
    public Order createOrder(Order order) {
        return orderRepo.save(order);
    }

    // Get order by ID
    public Optional<Order> getOrderById(String id) {
        return orderRepo.findById(id);
    }

    // Get all orders
    public List<Order> getAllOrders() {
        return orderRepo.findAll();
    }

    // Get orders by user ID
    public List<Order> getOrdersByUserId(String userId) {
        return orderRepo.findByUserId(userId);
    }

    // Update order
    public Order updateOrder(String id, Order updatedOrder) {
        Optional<Order> order = orderRepo.findById(id);
        if (order.isPresent()) {
            Order orderToUpdate = order.get();
            if (updatedOrder.getName() != null) {
                orderToUpdate.setName(updatedOrder.getName());
            }
            if (updatedOrder.getAddress() != null) {
                orderToUpdate.setAddress(updatedOrder.getAddress());
            }
            if (updatedOrder.getStatus() != null) {
                orderToUpdate.setStatus(updatedOrder.getStatus());
            }
            if (updatedOrder.getItems() != null && !updatedOrder.getItems().isEmpty()) {
                orderToUpdate.setItems(updatedOrder.getItems());
            }
            if (updatedOrder.getTotalAmount() > 0) {
                orderToUpdate.setTotalAmount(updatedOrder.getTotalAmount());
            }
            return orderRepo.save(orderToUpdate);
        }
        throw new RuntimeException("Order not found");
    }

    // Delete order
    public void deleteOrder(String id) {
        orderRepo.deleteById(id);
    }

    // Get orders by status
    public List<Order> getOrdersByStatus(String status) {
        return orderRepo.findByStatus(status);
    }
}
