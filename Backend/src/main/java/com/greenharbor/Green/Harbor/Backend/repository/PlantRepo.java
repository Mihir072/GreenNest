package com.greenharbor.Green.Harbor.Backend.repository;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import com.greenharbor.Green.Harbor.Backend.model.Plant;

@Repository
public interface PlantRepo extends MongoRepository<Plant, String> {
    Page<Plant> findByCategory(String category, Pageable pageable);
    List<Plant> findByCategory(String category);
    List<Plant> findByNameContainingIgnoreCaseOrDescriptionContainingIgnoreCase(String name, String description);
}
