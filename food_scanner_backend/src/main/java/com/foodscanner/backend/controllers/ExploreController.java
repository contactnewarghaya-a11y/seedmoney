package com.foodscanner.backend.controllers;

import com.foodscanner.backend.models.IngredientProfile;
import com.foodscanner.backend.repositories.IngredientProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/explore")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ExploreController {

    private final IngredientProfileRepository ingredientRepository;

    @GetMapping
    public ResponseEntity<?> searchIngredients(@RequestParam(required = false, defaultValue = "") String query) {
        // Seed dummy data if empty
        if (ingredientRepository.count() == 0) {
            seedData();
        }

        List<IngredientProfile> results;
        if (query.isEmpty()) {
            results = ingredientRepository.findAll();
        } else {
            results = ingredientRepository.searchByQuery(query);
        }
        
        return ResponseEntity.ok(results);
    }
    
    private void seedData() {
        IngredientProfile i1 = new IngredientProfile();
        i1.setType("E-NUMBER");
        i1.setTitle("E102 (Tartrazine)");
        i1.setDescription("A synthetic lemon yellow azo dye used as a food coloring. Primarily found in soft drinks and processed snacks.");
        i1.setStatus("Caution");
        i1.setCaution(true);
        i1.setSafe(false);
        i1.setAllergens(List.of("Sulfites", "Salicylates"));
        ingredientRepository.save(i1);

        IngredientProfile i2 = new IngredientProfile();
        i2.setType("NATURAL");
        i2.setTitle("E100 (Curcumin)");
        i2.setDescription("A natural bright yellow dye produced by turmeric. Recognized for anti-inflammatory properties and used in curries.");
        i2.setStatus("Safe");
        i2.setCaution(false);
        i2.setSafe(true);
        i2.setAllergens(List.of("None Reported"));
        ingredientRepository.save(i2);

        IngredientProfile i3 = new IngredientProfile();
        i3.setType("PRESERVATIVE");
        i3.setTitle("Potassium Sorbate");
        i3.setDescription("The potassium salt of sorbic acid. Effective for controlling mold and yeast in cheese, wine, and yogurt.");
        i3.setStatus("Moderate");
        i3.setCaution(false);
        i3.setSafe(false);
        i3.setAllergens(List.of("Skin Irritation"));
        ingredientRepository.save(i3);
    }
}
