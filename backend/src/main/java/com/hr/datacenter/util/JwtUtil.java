package com.hr.datacenter.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.jackson.io.JacksonDeserializer;
import io.jsonwebtoken.jackson.io.JacksonSerializer;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * JWT工具类
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Component
@Slf4j
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private Long expiration;

    /**
     * 生成Token
     */
    public String generateToken(Long userId, String username) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("username", username);
        return generateToken(claims);
    }

    public String generateToken(Long userId, String username, String roleCode) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("username", username);
        claims.put("roleCode", roleCode);
        return generateToken(claims);
    }

    /**
     * 生成Token
     */
    private String generateToken(Map<String, Object> claims) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expiration);

        SecretKey key = getSigningKey();

        return Jwts.builder()
                .setClaims(claims)
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .signWith(key, SignatureAlgorithm.HS512)
                .serializeToJsonWith(new JacksonSerializer<>())
                .compact();
    }

    /**
     * 从Token中获取Claims
     */
    public Claims getClaimsFromToken(String token) {
        try {
            SecretKey key = getSigningKey();
            return Jwts.parserBuilder()
                    .setSigningKey(key)
                    .deserializeJsonWith(new JacksonDeserializer<>())
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * 从Token中获取用户ID
     */
    public Long getUserIdFromToken(String token) {
        Claims claims = getClaimsFromToken(token);
        if (claims != null) {
            return claims.get("userId", Long.class);
        }
        return null;
    }

    /**
     * 从Token中获取用户名
     */
    public String getUsernameFromToken(String token) {
        Claims claims = getClaimsFromToken(token);
        if (claims != null) {
            return claims.get("username", String.class);
        }
        return null;
    }

    public String getRoleCodeFromToken(String token) {
        Claims claims = getClaimsFromToken(token);
        if (claims != null) {
            return claims.get("roleCode", String.class);
        }
        return null;
    }

    /**
     * 验证Token是否过期
     */
    public Boolean isTokenExpired(String token) {
        try {
            Claims claims = getClaimsFromToken(token);
            if (claims == null) {
                return true;
            }
            Date expiration = claims.getExpiration();
            return expiration.before(new Date());
        } catch (Exception e) {
            return true;
        }
    }

    /**
     * 验证Token
     */
    public Boolean validateToken(String token) {
        return !isTokenExpired(token);
    }

    /**
     * 统一构建签名密钥，避免配置密钥长度不足导致认证全链路失败。
     * HS512 要求最少 64 字节，因此对短密钥做 SHA-512 扩展。
     */
    private SecretKey getSigningKey() {
        byte[] raw = secret == null ? new byte[0] : secret.getBytes(StandardCharsets.UTF_8);
        if (raw.length >= 64) {
            return Keys.hmacShaKeyFor(raw);
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-512");
            byte[] expanded = digest.digest(raw);
            log.warn("JWT密钥长度不足64字节，已启用SHA-512扩展签名密钥，建议尽快修正 jwt.secret 配置。");
            return Keys.hmacShaKeyFor(expanded);
        } catch (Exception ex) {
            throw new IllegalStateException("JWT密钥初始化失败", ex);
        }
    }
}
