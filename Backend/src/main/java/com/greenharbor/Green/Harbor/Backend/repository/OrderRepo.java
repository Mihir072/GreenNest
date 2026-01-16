package com.greenharbor.Green.Harbor.Backend.repository;

import java.util.List;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import com.greenharbor.Green.Harbor.Backend.model.Order;

@Repository
public interface OrderRepo extends MongoRepository<Order, String> {
    List<Order> findByUserId(String userId);
    List<Order> findByStatus(String status);
}