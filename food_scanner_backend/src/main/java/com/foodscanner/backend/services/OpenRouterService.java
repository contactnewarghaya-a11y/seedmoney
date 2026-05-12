package com.foodscanner.backend.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.foodscanner.backend.models.ScanHistory;
import com.foodscanner.backend.models.User;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class OpenRouterService {

    private final WebClient webClient;
    private final ObjectMapper objectMapper;

    @Value("${openrouter.model}")
    private String model;

    public OpenRouterService(@Value("${openrouter.url}") String url,
                             @Value("${openrouter.api-key}") String apiKey) {
        this.webClient = WebClient.builder()
                .baseUrl(url)
                .defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey)
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .build();
        this.objectMapper = new ObjectMapper();
    }

    public ScanHistory analyze(List<String> ingredients, User userProfile) {
        try {
            // Build the system prompt
            String systemPrompt = "You are an expert food safety and nutrition AI. Analyze the given ingredients against the user's health profile.\n" +
                    "Return ONLY a raw JSON object matching this EXACT schema (do not use markdown formatting like ```json):\n" +
                    "{\n" +
                    "  \"dangerous\": [\"list\", \"of\", \"dangerous\", \"ingredients\"],\n" +
                    "  \"nutritionScore\": 5,\n" +
                    "  \"riskLevel\": \"Safe|Medium|High\",\n" +
                    "  \"warning\": \"Short explanation of why it is dangerous or safe.\"\n" +
                    "}";

            String userPrompt = "Ingredients: " + String.join(", ", ingredients) + "\n" +
                    "User Allergens: " + String.join(", ", userProfile.getAllergens()) + "\n" +
                    "User Health Conditions: " + String.join(", ", userProfile.getConditions()) + "\n" +
                    "User Dietary Preferences: " + String.join(", ", userProfile.getDietaryPreferences()) + "\n\n" +
                    "Please analyze and return the JSON.";

            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model", model);
            requestBody.put("messages", List.of(
                    Map.of("role", "system", "content", systemPrompt),
                    Map.of("role", "user", "content", userPrompt)
            ));

            // Call OpenRouter API
            Map response = webClient.post()
                    .bodyValue(requestBody)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block(); // Blocking for MVP simplicity

            // Parse response
            List<Map<String, Object>> choices = (List<Map<String, Object>>) response.get("choices");
            Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
            String content = (String) message.get("content");

            // Clean up possible markdown code blocks from the AI response
            content = content.replaceAll("```json", "").replaceAll("```", "").trim();

            // Deserialize to ScanHistory object fields
            ScanHistory scanResult = objectMapper.readValue(content, ScanHistory.class);
            scanResult.setIngredients(ingredients);
            
            return scanResult;

        } catch (Exception e) {
            e.printStackTrace();
            // Fallback object in case of API failure
            ScanHistory fallback = new ScanHistory();
            fallback.setIngredients(ingredients);
            fallback.setDangerous(List.of());
            fallback.setNutritionScore(0);
            fallback.setRiskLevel("Unknown");
            fallback.setWarning("Failed to analyze ingredients due to an AI service error.");
            return fallback;
        }
    }
}
