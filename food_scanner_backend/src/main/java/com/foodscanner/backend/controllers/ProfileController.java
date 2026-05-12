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
        user.setEmail("test@example.com");
        user.setUsername("Test User");
        
        user.setAllergens(profileUpdate.getAllergens());
        user.setConditions(profileUpdate.getConditions());
        user.setDietaryPreferences(profileUpdate.getDietaryPreferences());

        User savedUser = userRepository.save(user);
        return ResponseEntity.ok(savedUser);
    }

    @GetMapping
    public ResponseEntity<?> getProfile() {
        User user = userRepository.findByEmail("test@example.com").orElse(new User());
        return ResponseEntity.ok(user);
    }
}
