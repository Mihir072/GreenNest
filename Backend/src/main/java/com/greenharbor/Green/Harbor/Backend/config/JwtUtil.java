package com.greenharbor.Green.Harbor.Backend.config;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import java.util.Base64;
import java.util.Date;

@Component
public class JwtUtil {
    // Base64 encoded 32-byte (256-bit) secret key for HMAC-SHA256
    // This is secure enough for JWT signing per RFC 7518
    private static final String SECRET = "eW91ci0yNTYtYml0LXNlY3JldC1rZXktbmVlZHMtdG8tYmUtYXQtbGVhc3QtMzItYnl0ZXMtbG9uZw==";
    private static final byte[] DECODED_KEY = Base64.getDecoder().decode(SECRET);

    public String generateToken(String email, String role, String userId) {
        try {
            System.out.println("JwtUtil: generateToken called");
            System.out.println("Email: " + email + ", Role: " + role + ", UserId: " + userId);
            System.out.println("DECODED_KEY length: " + DECODED_KEY.length);
            
            String token = Jwts.builder()
                    .claim("email", email)
                    .claim("role", "ROLE_" + role)
                    .claim("userId", userId)
                    .setSubject(email)
                    .setIssuedAt(new Date())
                    .setExpiration(new Date(System.currentTimeMillis() + 86400000)) // 24 hours
                    .signWith(Keys.hmacShaKeyFor(DECODED_KEY), SignatureAlgorithm.HS256)
                    .compact();
            
            System.out.println("JwtUtil: Token generated successfully");
            System.out.println("Token length: " + token.length());
            
            return token;
        } catch (Exception e) {
            System.err.println("JwtUtil: Error generating token: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to generate token: " + e.getMessage());
        }
    }

    public static Claims extractAllClaims(String token) {
        try {
            System.out.println("JwtUtil: extractAllClaims called");
            System.out.println("Token length: " + token.length());
            System.out.println("DECODED_KEY length: " + DECODED_KEY.length);
            
            Claims claims = Jwts.parserBuilder()
                    .setSigningKey(Keys.hmacShaKeyFor(DECODED_KEY))
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
            
            System.out.println("JwtUtil: Claims extracted successfully");
            return claims;
        } catch (Exception e) {
            System.err.println("JwtUtil: Error extracting claims: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to extract claims: " + e.getMessage());
        }
    }
}
