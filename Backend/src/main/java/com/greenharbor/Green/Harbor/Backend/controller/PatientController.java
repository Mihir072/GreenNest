package com.greenharbor.Green.Harbor.Backend.controller;

import com.greenharbor.Green.Harbor.Backend.model.Patient;
import com.greenharbor.Green.Harbor.Backend.repository.PatientRepo;
import com.greenharbor.Green.Harbor.Backend.services.PatientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class PatientController {

    @Autowired
    private PatientService patientService;

    @PostMapping("/patient")
    public ResponseEntity<Patient>addPatient(Patient patient){
        Patient saved = patientService.addPatient(patient);
        return ResponseEntity.status(HttpStatus.OK).body(saved);
    }
}
