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
        Optional<User> existingUser = userRepo.findByEmail(user.getEmail());
        if (existingUser.isPresent()) {
            throw new IllegalArgumentException("Email already registered");
        }

        user.setPassword(encoder.encode(user.getPassword()));
        return userRepo.save(user);
    }

    public Map<String, Object> login(AuthRequest request) {
        User user = userRepo.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException(AppConstantConfig.USER_NOT_FOUND));

        if (!encoder.matches(request.getPassword(), user.getPassword()))
            throw new RuntimeException(AppConstantConfig.INVALID_PASSWORD);

        String token = jwtUtil.generateToken(user.getEmail(), user.getRole(), user.getId());

        Map<String, Object> response = new HashMap<>();
        response.put(AppConstantConfig.TOKEN, token);
        response.put(AppConstantConfig.ROLE, user.getRole());
        response.put(AppConstantConfig.EMAIL, user.getEmail());
        response.put("id", user.getId());
        response.put("name", user.getName());

        return response;
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
        Optional<User> user = userRepo.findByEmail(email);
        if (user.isPresent()) {
            User userToUpdate = user.get();
            userToUpdate.setPassword(encoder.encode(newPassword));
            userRepo.save(userToUpdate);
            Map<String, String> response = new HashMap<>();
            response.put("message", "Password updated successfully");
            return response;
        }
        throw new RuntimeException("User not found");
    }
}
