package com.foodscanner.backend.models;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.List;

@Data
@Document(collection = "ingredients")
public class IngredientProfile {
    @Id
    private String id;
    private String type; // e.g., "E-NUMBER", "NATURAL", "PRESERVATIVE"
    private String title;
    private String description;
    private String status; // e.g., "Safe", "Caution", "Moderate"
    private boolean isCaution;
    private boolean isSafe;
    private List<String> allergens;
}
