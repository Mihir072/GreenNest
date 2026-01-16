package com.greenharbor.Green.Harbor.Backend.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "Patient Detail")
public class Patient {
    @Id
    private String id;
    private String name;
    private String age;
    private boolean pregnant;
    private boolean isSynced;

    public Patient() {
    }

    public Patient(String name, String age, boolean pregnant, boolean isSynced) {
        this.name = name;
        this.age = age;
        this.pregnant = pregnant;
        this.isSynced = isSynced;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAge() {
        return age;
    }

    public void setAge(String age) {
        this.age = age;
    }

    public boolean isPregnant() {
        return pregnant;
    }

    public void setPregnant(boolean pregnant) {
        this.pregnant = pregnant;
    }

    public boolean isSynced() {
        return isSynced;
    }

    public void setSynced(boolean synced) {
        isSynced = synced;
    }
}

