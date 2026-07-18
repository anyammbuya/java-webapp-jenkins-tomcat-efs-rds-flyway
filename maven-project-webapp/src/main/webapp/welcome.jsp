<%@ page import="jakarta.servlet.http.Cookie" %>
<%@ page import="redis.clients.jedis.Jedis" %>
<%@ page import="redis.clients.jedis.JedisPool" %>
<%@ page import="redis.clients.jedis.JedisPoolConfig" %>
<%@ page import="com.example.webapp.RedisUtil" %>
<!DOCTYPE html>
<html>
<head>
    <title>Welcome</title>
</head>
<body>

<%
    String sessionToken = null;
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("ZEUS_SESSION_ID".equals(cookie.getName())) {
                sessionToken = cookie.getValue();
                break;
            }
        }
    }

    // Access Guard: If cookie is missing entirely, bounce out to login
    if (sessionToken == null || sessionToken.trim().isEmpty()) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }

    String name = null;
    // Check against the remote Redis cluster state store
    try (Jedis jedis = RedisUtil.getRedisConnection()) {
        name = jedis.hget("session:" + sessionToken, "firstName");
    } catch (Exception e) {
        System.err.println("Redis Connection Failure: " + e.getMessage());
    }

    // Access Guard: If token expired or is not found inside Redis memory cache
    if (name == null) {
        response.sendRedirect("login.jsp?error=expired");
        return;
    }
%>

<h2>Welcome to Project Zeus, <%= name %></h2>

<div style="margin: 20px 0;">
    <img src="https://zeus-app-static-assets.s3.us-west-2.amazonaws.com/images/logo.png" 
         alt="Project Zeus Logo" 
         style="max-width: 250px; height: auto; display: block; border-radius: 4px;" />
</div>

<br/>
<p>You have successfully logged in across your multi-node cluster nodes using decentralized session keys!</p>

<!-- Routes directly to our controller to invalidate the state immediately -->
<a href="logout" style="display:inline-block; padding:10px 15px; background-color:#f44336; color:white; text-decoration:none; border-radius:4px;">Logout</a>

</body>
</html>