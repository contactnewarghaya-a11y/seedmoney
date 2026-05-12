package com.foodscanner.backend.controllers;

import com.foodscanner.backend.models.ScanHistory;
import com.foodscanner.backend.models.User;
import com.foodscanner.backend.repositories.ScanHistoryRepository;
import com.foodscanner.backend.repositories.UserRepository;
import com.foodscanner.backend.services.OpenRouterService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/analyze")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") // For Flutter web/local testing
public class AnalysisController {

    private final ScanHistoryRepository scanHistoryRepository;
    private final UserRepository userRepository;
    private final OpenRouterService openRouterService;

    @PostMapping
    public ResponseEntity<?> analyzeIngredients(@RequestBody Map<String, Object> payload) {
        List<String> ingredients = (List<String>) payload.get("ingredients");
        String rawOcrText = (String) payload.get("rawText");
        
        if (ingredients == null || ingredients.isEmpty()) {
            return ResponseEntity.badRequest().body("Ingredients list cannot be empty");
        }

        // Fetch user profile to pass to AI (Dummy user for MVP)
        User user = userRepository.findByEmail("test@example.com").orElse(new User());

        // Perform AI Analysis using OpenRouter!
        ScanHistory scan = openRouterService.analyze(ingredients, user);
        scan.setUserId("dummy_user_id");
        scan.setCreatedAt(LocalDateTime.now());
        scan.setRawOcrText(rawOcrText);

        // Gamification Engine
        user.setTotalScans(user.getTotalScans() + 1);
        if ("Safe".equalsIgnoreCase(scan.getRiskLevel())) {
            user.setRewardPoints(user.getRewardPoints() + 10);
        }
        userRepository.save(user);

        // Save to MongoDB
        ScanHistory savedScan = scanHistoryRepository.save(scan);

        // Return the saved result
        Map<String, Object> response = new HashMap<>();
        response.put("id", savedScan.getId());
        response.put("dangerous", savedScan.getDangerous());
        response.put("nutrition_score", savedScan.getNutritionScore());
        response.put("risk_level", savedScan.getRiskLevel());
        response.put("warning", savedScan.getWarning());
        response.put("raw_text", savedScan.getRawOcrText());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/history")
    public ResponseEntity<?> getHistory() {
        // Mocking user ID for now
        List<ScanHistory> history = scanHistoryRepository.findByUserIdOrderByCreatedAtDesc("dummy_user_id");
        return ResponseEntity.ok(history);
    }
}
