package com.greenharbor.Green.Harbor.Backend.services;

import com.greenharbor.Green.Harbor.Backend.model.Patient;
import com.greenharbor.Green.Harbor.Backend.repository.PatientRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class PatientService {

    @Autowired
    private PatientRepo patientRepo;

    public Patient addPatient(Patient patient){
        return patientRepo.save(patient);
    }
}
