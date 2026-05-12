package com.foodscanner.backend.repositories;

import com.foodscanner.backend.models.ScanHistory;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;

public interface ScanHistoryRepository extends MongoRepository<ScanHistory, String> {
    List<ScanHistory> findByUserIdOrderByCreatedAtDesc(String userId);
}
