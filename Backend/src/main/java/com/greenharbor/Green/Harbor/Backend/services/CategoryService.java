package com.greenharbor.Green.Harbor.Backend.services;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.greenharbor.Green.Harbor.Backend.model.Category;
import com.greenharbor.Green.Harbor.Backend.repository.CategoryRepo;

@Service
public class CategoryService {

    @Autowired
    private CategoryRepo categoryRepo;

    // Get all categories
    public List<Category> getAllCategories() {
        return categoryRepo.findAll();
    }

    // Get category by ID
    public Optional<Category> getCategoryById(String id) {
        return categoryRepo.findById(id);
    }

    // Get category by name
    public Optional<Category> getCategoryByName(String name) {
        return categoryRepo.findByName(name);
    }

    // Create category
    public Category createCategory(Category category) {
        return categoryRepo.save(category);
    }

    // Update category
    public Category updateCategory(String id, Category updatedCategory) {
        Optional<Category> category = categoryRepo.findById(id);
        if (category.isPresent()) {
            Category categoryToUpdate = category.get();
            if (updatedCategory.getName() != null) {
                categoryToUpdate.setName(updatedCategory.getName());
            }
            if (updatedCategory.getDescription() != null) {
                categoryToUpdate.setDescription(updatedCategory.getDescription());
            }
            if (updatedCategory.getImageUrl() != null) {
                categoryToUpdate.setImageUrl(updatedCategory.getImageUrl());
            }
            return categoryRepo.save(categoryToUpdate);
        }
        throw new RuntimeException("Category not found");
    }

    // Delete category
    public void deleteCategory(String id) {
        categoryRepo.deleteById(id);
    }
}
