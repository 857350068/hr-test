package com.hr.backend.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Component
@Slf4j
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private Long expiration;

    private SecretKey getSigningKey() {
        byte[] keyBytes = secret.getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }

    public String generateToken(Long userId, String username, String role) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("username", username);
        claims.put("role", role);
        Date now = new Date();
        Date expiry = new Date(now.getTime() + expiration);
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(username)
                .setIssuedAt(now)
                .setExpiration(expiry)
                .signWith(getSigningKey(), SignatureAlgorithm.HS512)
                .compact();
    }

    public String getUsernameFromToken(String token) {
        try {
            return getClaimsFromToken(token).getSubject();
        } catch (Exception e) {
            log.error("从Token获取用户名失败", e);
            return null;
        }
    }

    public Long getUserIdFromToken(String token) {
        try {
            Object v = getClaimsFromToken(token).get("userId");
            return v == null ? null : Long.valueOf(v.toString());
        } catch (Exception e) {
            log.error("从Token获取用户ID失败", e);
            return null;
        }
    }

    public String getRoleFromToken(String token) {
        try {
            Object v = getClaimsFromToken(token).get("role");
            return v == null ? null : v.toString();
        } catch (Exception e) {
            log.error("从Token获取角色失败", e);
            return null;
        }
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(token);
            return true;
        } catch (SecurityException e) {
            log.error("Token签名无效");
        } catch (MalformedJwtException e) {
            log.error("Token格式无效");
        } catch (ExpiredJwtException e) {
            log.error("Token已过期");
        } catch (Exception e) {
            log.error("Token无效", e);
        }
        return false;
    }

    private Claims getClaimsFromToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
}
