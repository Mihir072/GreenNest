package com.greenharbor.Green.Harbor.Backend.controller;

import com.greenharbor.Green.Harbor.Backend.model.Plant;
import com.greenharbor.Green.Harbor.Backend.services.PlantService;
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
@RequestMapping("/api/admin/plants")
@PreAuthorize("hasRole('ADMIN')")
public class AdminPlantController {

    @Autowired
    private PlantService plantService;

    // Get all plants (admin)
    @GetMapping
    public ResponseEntity<?> getAllPlants() {
        try {
            List<Plant> plants = plantService.getAllPlantsList();
            return ResponseEntity.ok(plants);
        } catch (Exception e) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to fetch plants");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
    }

    // Create new plant (admin)
    @PostMapping
    public ResponseEntity<?> createPlant(@RequestBody Plant plant) {
        try {
            Plant savedPlant = plantService.createPlant(plant);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedPlant);
        } catch (Exception e) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to create plant");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
    }

    // Update plant (admin)
    @PutMapping("/{id}")
    public ResponseEntity<?> updatePlant(@PathVariable String id, @RequestBody Plant updatedPlant) {
        try {
            Plant plant = plantService.updatePlant(id, updatedPlant);
            return ResponseEntity.ok(plant);
        } catch (Exception e) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
    }

    // Delete plant (admin)
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deletePlant(@PathVariable String id) {
        try {
            plantService.deletePlant(id);
            Map<String, String> response = new HashMap<>();
            response.put("message", "Plant deleted successfully");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to delete plant");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
    }
}
