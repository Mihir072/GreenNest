package com.greenharbor.Green.Harbor.Backend.controller;

import com.greenharbor.Green.Harbor.Backend.model.Plant;
import com.greenharbor.Green.Harbor.Backend.services.PlantService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/plants")
public class PlantController {

    @Autowired
    private PlantService plantService;

    // Get all plants with pagination
    @GetMapping
    public ResponseEntity<?> getAllPlants(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size,
            @RequestParam(required = false) String category) {
        try {
            Page<Plant> plants;
            if (category != null && !category.isEmpty()) {
                plants = plantService.getPlantsByCategory(category, page, size);
            } else {
                plants = plantService.getAllPlants(page, size);
            }

            Map<String, Object> response = new HashMap<>();
            response.put("content", plants.getContent());
            response.put("currentPage", plants.getNumber());
            response.put("totalItems", plants.getTotalElements());
            response.put("totalPages", plants.getTotalPages());

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to fetch plants");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
    }

    // Search plants by name or description
    @GetMapping("/search")
    public ResponseEntity<?> searchPlants(@RequestParam("q") String query) {
        try {
            List<Plant> plants = plantService.searchPlants(query);
            return ResponseEntity.ok(plants);
        } catch (Exception e) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to search plants");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
    }

    // Get plant by ID
    @GetMapping("/{id}")
    public ResponseEntity<?> getPlantById(@PathVariable String id) {
        try {
            Optional<Plant> plant = plantService.getPlantById(id);
            if (plant.isPresent()) {
                return ResponseEntity.ok(plant.get());
            }
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Plant not found");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
        } catch (Exception e) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to fetch plant");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
    }

    // Get categories list
    @GetMapping("/categories/list")
    public ResponseEntity<?> getCategories() {
        try {
            List<String> categories = plantService.getAllPlantsList().stream()
                    .map(Plant::getCategory)
                    .distinct()
                    .toList();
            return ResponseEntity.ok(categories);
        } catch (Exception e) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to fetch categories");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
    }
}
