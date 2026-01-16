package com.greenharbor.Green.Harbor.Backend.services;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import com.greenharbor.Green.Harbor.Backend.model.Plant;
import com.greenharbor.Green.Harbor.Backend.repository.PlantRepo;

@Service
public class PlantService {

    @Autowired
    private PlantRepo plantRepo;

    // Get all plants with pagination
    public Page<Plant> getAllPlants(int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return plantRepo.findAll(pageable);
    }

    // Get plants by category with pagination
    public Page<Plant> getPlantsByCategory(String category, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return plantRepo.findByCategory(category, pageable);
    }

    // Search plants by name or description
    public List<Plant> searchPlants(String query) {
        return plantRepo.findByNameContainingIgnoreCaseOrDescriptionContainingIgnoreCase(query, query);
    }

    // Get plant by ID
    public Optional<Plant> getPlantById(String id) {
        return plantRepo.findById(id);
    }

    // Create plant
    public Plant createPlant(Plant plant) {
        return plantRepo.save(plant);
    }

    // Update plant
    public Plant updatePlant(String id, Plant updatedPlant) {
        Optional<Plant> plant = plantRepo.findById(id);
        if (plant.isPresent()) {
            Plant plantToUpdate = plant.get();
            if (updatedPlant.getName() != null) {
                plantToUpdate.setName(updatedPlant.getName());
            }
            if (updatedPlant.getDescription() != null) {
                plantToUpdate.setDescription(updatedPlant.getDescription());
            }
            if (updatedPlant.getPrice() > 0) {
                plantToUpdate.setPrice(updatedPlant.getPrice());
            }
            if (updatedPlant.getCategory() != null) {
                plantToUpdate.setCategory(updatedPlant.getCategory());
            }
            if (updatedPlant.getImageUrl() != null) {
                plantToUpdate.setImageUrl(updatedPlant.getImageUrl());
            }
            if (updatedPlant.getStock() >= 0) {
                plantToUpdate.setStock(updatedPlant.getStock());
            }
            return plantRepo.save(plantToUpdate);
        }
        throw new RuntimeException("Plant not found");
    }

    // Delete plant
    public void deletePlant(String id) {
        plantRepo.deleteById(id);
    }

    // Get plants by category (without pagination)
    public List<Plant> getPlantsByCategoryList(String category) {
        return plantRepo.findByCategory(category);
    }

    // Get all plants (without pagination)
    public List<Plant> getAllPlantsList() {
        return plantRepo.findAll();
    }
}
