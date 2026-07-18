package com.example.webapp;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.UUID;
import org.mindrot.jbcrypt.BCrypt;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;
import redis.clients.jedis.Jedis;

public class LoginServlet extends HttpServlet {


    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        try (Connection con = DBUtil.getConnection("app_user", "zeus_project_db", true)) {

            String sql = "SELECT first_name, password FROM users WHERE username=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            System.out.println("Attempting login for: " + username);

            if (rs.next()) {
                // In production get rid of the logs

                String storedHash = rs.getString("password");

                System.out.println("Stored Hash: " + storedHash);
                
                if (BCrypt.checkpw(password, storedHash)) {
                    String firstName = rs.getString("first_name");

                    // 1. Generate a custom secure session token
                    String sessionToken = UUID.randomUUID().toString();

                    // 2. Write directly to the Redis endpoint
                    try (Jedis jedis = RedisUtil.getRedisConnection()) {
                        // Store session mapping (Token -> Username)
                        jedis.hset("session:" + sessionToken, "username", username);
                        jedis.hset("session:" + sessionToken, "firstName", firstName);
                        
                        // Set session expiration (e.g., 30 minutes / 1800 seconds)
                        jedis.expire("session:" + sessionToken, 1800);
                    }

                    // 3. Send the token back to the browser as a tracking cookie
                    Cookie sessionCookie = new Cookie("ZEUS_SESSION_ID", sessionToken);
                    sessionCookie.setHttpOnly(true); // Secure against XSS
                    sessionCookie.setPath("/");
                    res.addCookie(sessionCookie);

                    System.out.println("Session data explicitly written to Redis endpoint for: " + username);
                    res.sendRedirect("welcome.jsp");
                    return;
                }
            }
            res.sendRedirect("login.jsp?error=1");

        } catch (Exception e) {
            e.printStackTrace();
            res.sendRedirect("login.jsp?error=1");
        }
    }
}