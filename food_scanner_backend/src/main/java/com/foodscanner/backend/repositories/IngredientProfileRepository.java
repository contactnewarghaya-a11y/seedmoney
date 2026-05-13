package com.foodscanner.backend.repositories;

import com.foodscanner.backend.models.IngredientProfile;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

import java.util.List;

public interface IngredientProfileRepository extends MongoRepository<IngredientProfile, String> {
    
    @Query("{ '$or': [ { 'title': { '$regex': ?0, '$options': 'i' } }, { 'description': { '$regex': ?0, '$options': 'i' } } ] }")
    List<IngredientProfile> searchByQuery(String query);
}
