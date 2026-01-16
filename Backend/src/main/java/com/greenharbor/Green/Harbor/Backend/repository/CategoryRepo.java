package com.greenharbor.Green.Harbor.Backend.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import com.greenharbor.Green.Harbor.Backend.model.Category;

@Repository
public interface CategoryRepo extends MongoRepository<Category, String> {
    Optional<Category> findByName(String name);
    List<Category> findAll();
}
