package com.greenharbor.Green.Harbor.Backend.services;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.greenharbor.Green.Harbor.Backend.config.AppConstantConfig;
import com.greenharbor.Green.Harbor.Backend.config.AuthRequest;
import com.greenharbor.Green.Harbor.Backend.config.JwtUtil;
import com.greenharbor.Green.Harbor.Backend.model.User;
import com.greenharbor.Green.Harbor.Backend.repository.UserRepo;

@Service
public class AuthService {

    @Autowired
    private UserRepo userRepo;

    @Autowired
    private PasswordEncoder encoder;

    @Autowired
    private JwtUtil jwtUtil;

    public User register(User user) {
        System.out.println("=== USER REGISTRATION ===");
        System.out.println("Registering user: " + user.getEmail());
        System.out.println("Password provided: " + user.getPassword());
        
        Optional<User> existingUser = userRepo.findByEmail(user.getEmail());
        if (existingUser.isPresent()) {
            System.err.println("Email already registered: " + user.getEmail());
            throw new IllegalArgumentException("Email already registered");
        }

        // Set default role if not provided
        if (user.getRole() == null || user.getRole().isEmpty()) {
            user.setRole("USER");
        }

        String encodedPassword = encoder.encode(user.getPassword());
        System.out.println("Encoded password (first 20 chars): " + encodedPassword.substring(0, Math.min(20, encodedPassword.length())));
        
        user.setPassword(encodedPassword);
        User savedUser = userRepo.save(user);
        System.out.println("User registered successfully with ID: " + savedUser.getId());
        
        return savedUser;
    }

    public Map<String, Object> login(AuthRequest request) {
        System.out.println("=== LOGIN ATTEMPT ===");
        System.out.println("Login email: " + request.getEmail());
        
        User user = userRepo.findByEmail(request.getEmail())
                .orElseThrow(() -> {
                    System.err.println("User not found with email: " + request.getEmail());
                    return new RuntimeException(AppConstantConfig.USER_NOT_FOUND);
                });

        System.out.println("User found: " + user.getName());
        System.out.println("User ID: " + user.getId());
        System.out.println("User Role: " + user.getRole());
        System.out.println("Stored password hash (first 20 chars): " + user.getPassword().substring(0, Math.min(20, user.getPassword().length())));
        System.out.println("Provided password: " + request.getPassword());

        boolean passwordMatches = encoder.matches(request.getPassword(), user.getPassword());
        System.out.println("Password match result: " + passwordMatches);

        if (!passwordMatches) {
            System.err.println("PASSWORD MISMATCH: Provided password does not match stored hash");
            throw new RuntimeException(AppConstantConfig.INVALID_PASSWORD);
        }

        try {
            System.out.println("About to generate token...");
            System.out.println("Token params - email: " + user.getEmail() + ", role: " + user.getRole() + ", userId: " + user.getId());
            
            String token = jwtUtil.generateToken(user.getEmail(), user.getRole(), user.getId());
            
            System.out.println("Token generated successfully: " + token.substring(0, Math.min(20, token.length())) + "...");

            Map<String, Object> response = new HashMap<>();
            response.put(AppConstantConfig.TOKEN, token);
            response.put(AppConstantConfig.ROLE, user.getRole());
            response.put(AppConstantConfig.EMAIL, user.getEmail());
            response.put("id", user.getId());
            response.put("name", user.getName());

            System.out.println("Response built: " + response);
            System.out.println("=== LOGIN SUCCESS ===");
            return response;
        } catch (Exception e) {
            System.err.println("ERROR in token generation: " + e.getMessage());
            System.err.println("Exception type: " + e.getClass().getName());
            e.printStackTrace();
            throw e;
        }
    }

    public Map<String, String> logout(String authHeader) {
        String token = authHeader.replace(AppConstantConfig.BEARER, "");
        Map<String, String> response = new HashMap<>();
        response.put(AppConstantConfig.MESSAGE, AppConstantConfig.LOGOUT_SUCCESSFUL);
        return response;
    }

    public Optional<User> getUserByEmail(String email) {
        return userRepo.findByEmail(email);
    }

    public List<User> getAllUsers() {
        return userRepo.findAll();
    }

    public Optional<User> getUserById(String id) {
        return userRepo.findById(id);
    }

    public User updateUser(String id, User user) {
        Optional<User> existingUser = userRepo.findById(id);
        if (existingUser.isPresent()) {
            User userToUpdate = existingUser.get();
            if (user.getName() != null) {
                userToUpdate.setName(user.getName());
            }
            if (user.getEmail() != null) {
                userToUpdate.setEmail(user.getEmail());
            }
            if (user.getAddress() != null) {
                userToUpdate.setAddress(user.getAddress());
            }
            if (user.getPassword() != null && !user.getPassword().isEmpty()) {
                userToUpdate.setPassword(encoder.encode(user.getPassword()));
            }
            return userRepo.save(userToUpdate);
        }
        throw new RuntimeException("User not found");
    }

    public void deleteUser(String id) {
        userRepo.deleteById(id);
    }

    public Map<String, String> forgotPassword(String email, String newPassword) {
        System.out.println("=== FORGOT PASSWORD ATTEMPT ===");
        System.out.println("Email: " + email);
        System.out.println("New password received: " + newPassword);
        
        Optional<User> user = userRepo.findByEmail(email);
        if (user.isPresent()) {
            User userToUpdate = user.get();
            System.out.println("User found: " + userToUpdate.getName());
            
            String encodedPassword = encoder.encode(newPassword);
            System.out.println("Encoded password (first 20 chars): " + encodedPassword.substring(0, Math.min(20, encodedPassword.length())));
            
            userToUpdate.setPassword(encodedPassword);
            User savedUser = userRepo.save(userToUpdate);
            
            System.out.println("Password updated and saved");
            System.out.println("Saved password hash (first 20 chars): " + savedUser.getPassword().substring(0, Math.min(20, savedUser.getPassword().length())));
            
            // Verify the update
            boolean verifyMatch = encoder.matches(newPassword, savedUser.getPassword());
            System.out.println("Verification - does new password match saved hash? " + verifyMatch);
            
            Map<String, String> response = new HashMap<>();
            response.put("message", "Password updated successfully");
            return response;
        }
        System.err.println("User not found with email: " + email);
        throw new RuntimeException("User not found");
    }
}
