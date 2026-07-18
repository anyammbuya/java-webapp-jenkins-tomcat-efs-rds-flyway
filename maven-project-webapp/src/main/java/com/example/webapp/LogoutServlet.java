package com.example.webapp;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import redis.clients.jedis.Jedis;

public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        Cookie[] cookies = req.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("ZEUS_SESSION_ID".equals(cookie.getName())) {
                    String token = cookie.getValue();

                    // 1. Evict session memory segment straight from Redis Cluster
                    try (Jedis jedis = RedisUtil.getRedisConnection()) {
                        jedis.del("session:" + token);
                        System.out.println("Evicted Session key mapping from Redis for Token: " + token);
                    } catch (Exception e) {
                        System.err.println("Failed to evict token from Redis: " + e.getMessage());
                    }

                    // 2. Erase the browser side tracking footprint
                    cookie.setValue("");
                    cookie.setPath("/");
                    cookie.setMaxAge(0); // Destroys cookie instantly
                    res.addCookie(cookie);
                    break;
                }
            }
        }

        // Return user safely to the clean login screen
        res.sendRedirect("login.jsp");
    }
}