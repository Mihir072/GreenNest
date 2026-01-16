package com.greenharbor.Green.Harbor.Backend.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender javaMailSender;

    public void sendEmail(String toEmail, String subject, String body) {
        try {
            SimpleMailMessage email = new SimpleMailMessage();
            if (toEmail == null || toEmail.isEmpty()) {
                System.err.println("Email is null or empty..");
                return;
            }
            email.setTo(toEmail);
            email.setSubject(subject);
            email.setText(body);
            javaMailSender.send(email);
            System.out.println("Email sent successfully to: " + toEmail);
        } catch (Exception e) {
            System.err.println("Error sending email: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
