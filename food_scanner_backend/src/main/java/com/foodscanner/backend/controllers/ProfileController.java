package com.foodscanner.backend.controllers;

import com.foodscanner.backend.models.User;
import com.foodscanner.backend.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ProfileController {

    private final UserRepository userRepository;

    @PostMapping
    public ResponseEntity<?> updateProfile(@RequestBody User profileUpdate) {
        // For MVP, we'll just upsert a dummy user
        User user = userRepository.findByEmail("test@example.com").orElse(new User());
        
        user.setEmail(profileUpdate.getEmail() != null ? profileUpdate.getEmail() : "test@example.com");
        user.setUsername("Test User"); // Kept for legacy compatibility
        
        if (profileUpdate.getFullName() != null) user.setFullName(profileUpdate.getFullName());
        if (profileUpdate.getAvatarUrl() != null) user.setAvatarUrl(profileUpdate.getAvatarUrl());
        if (profileUpdate.getJoinDate() != null) user.setJoinDate(profileUpdate.getJoinDate());
        user.setPro(profileUpdate.isPro());
        
        if (profileUpdate.getAllergens() != null) user.setAllergens(profileUpdate.getAllergens());
        if (profileUpdate.getConditions() != null) user.setConditions(profileUpdate.getConditions());
        if (profileUpdate.getDietaryPreferences() != null) user.setDietaryPreferences(profileUpdate.getDietaryPreferences());

        User savedUser = userRepository.save(user);
        return ResponseEntity.ok(savedUser);
    }

    @GetMapping
    public ResponseEntity<?> getProfile() {
        User user = userRepository.findByEmail("test@example.com").orElse(new User());
        return ResponseEntity.ok(user);
    }
}
