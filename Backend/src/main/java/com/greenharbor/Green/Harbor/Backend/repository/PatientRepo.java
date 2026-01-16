package com.greenharbor.Green.Harbor.Backend.repository;

import com.greenharbor.Green.Harbor.Backend.model.Patient;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface PatientRepo extends MongoRepository<Patient, String> {
}
