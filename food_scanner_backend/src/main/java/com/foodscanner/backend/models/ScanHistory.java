package com.foodscanner.backend.models;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Document(collection = "scans")
public class ScanHistory {
    @Id
    private String id;
    private String userId;
    private LocalDateTime createdAt = LocalDateTime.now();
    
    private String rawOcrText;
    private List<String> ingredients;
    private List<String> dangerous;
    private int nutritionScore;
    private String riskLevel;
    private String warning;
    private boolean isFavorite;
}
