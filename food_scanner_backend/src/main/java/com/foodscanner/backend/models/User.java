package com.foodscanner.backend.models;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.ArrayList;
import java.util.List;

@Data
@Document(collection = "users")
public class User {
    @Id
    private String id;
    private String username;
    private String fullName;
    private String email;
    private String password; // Will be hashed in real implementation
    private String avatarUrl;
    private boolean isPro = false;
    private String joinDate;
    
    private List<String> allergens = new ArrayList<>();
    private List<String> conditions = new ArrayList<>();
    private List<String> dietaryPreferences = new ArrayList<>();
    
    // Reward System
    private int rewardPoints = 0;
    private int totalScans = 0;
}
