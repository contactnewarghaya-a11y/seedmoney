package com.foodscanner.backend.models;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Data
@Document(collection = "alerts")
public class Alert {
    @Id
    private String id;
    private String userId;
    private String type; // e.g. "Urgent Recall", "Personalized Health Tip"
    private String title;
    private String content;
    private LocalDateTime createdAt = LocalDateTime.now();
    private boolean isRead = false;
    private boolean isUrgent = false;
    private String tagLabel;
}
