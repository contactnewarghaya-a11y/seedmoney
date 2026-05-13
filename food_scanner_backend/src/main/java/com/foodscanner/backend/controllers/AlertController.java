package com.foodscanner.backend.controllers;

import com.foodscanner.backend.models.Alert;
import com.foodscanner.backend.repositories.AlertRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/alerts")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AlertController {

    private final AlertRepository alertRepository;

    @GetMapping
    public ResponseEntity<?> getAlerts() {
        // Dummy user ID for MVP
        List<Alert> alerts = alertRepository.findByUserIdOrderByCreatedAtDesc("test@example.com");
        
        // Seed some dummy data if empty for testing the UI
        if (alerts.isEmpty()) {
            Alert a1 = new Alert();
            a1.setUserId("test@example.com");
            a1.setType("Urgent Recall");
            a1.setTitle("Urgent Recall: Almond Flour Cookies");
            a1.setContent("Recall due to undeclared milk allergens. If you purchased this item after June 1st, do not consume.");
            a1.setUrgent(true);
            a1.setTagLabel("Safety Alert");
            alertRepository.save(a1);
            
            Alert a2 = new Alert();
            a2.setUserId("test@example.com");
            a2.setType("Personalized Health Tip");
            a2.setTitle("Personalized Health Tip");
            a2.setContent("Based on your last 10 scans, your sodium intake is 15% higher than your daily goal. Try swapping table salt for fresh herbs.");
            a2.setTagLabel("Dietary Insight");
            alertRepository.save(a2);
            
            alerts = alertRepository.findByUserIdOrderByCreatedAtDesc("test@example.com");
        }
        
        return ResponseEntity.ok(alerts);
    }

    @PostMapping("/mark-read")
    public ResponseEntity<?> markAllAsRead() {
        List<Alert> alerts = alertRepository.findByUserIdOrderByCreatedAtDesc("test@example.com");
        for (Alert a : alerts) {
            a.setRead(true);
            alertRepository.save(a);
        }
        return ResponseEntity.ok(Map.of("success", true));
    }
}
