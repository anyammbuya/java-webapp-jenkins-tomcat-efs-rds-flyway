<%@ page import="java.net.InetAddress" %>
<%@ page import="jakarta.servlet.http.Cookie" %>
<%@ page import="redis.clients.jedis.Jedis" %>
<%@ page import="com.example.webapp.RedisUtil" %>
<!DOCTYPE html>
<html>
<head>
    <title>Services Portal | Project Zeus</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; background-color: #f8f9fa; color: #333; }
        .service-item { margin-bottom: 20px; padding: 20px; background: white; border-left: 5px solid #007bff; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        .nav-box { margin-bottom: 20px; padding: 12px; border: 1px solid #bce1ff; background-color: #eef7ff; text-align: center; border-radius: 4px;}
        .secure-badge { background-color: #28a745; color: white; padding: 2px 6px; font-size: 12px; border-radius: 3px; vertical-align: middle; }
        .public-badge { background-color: #6c757d; color: white; padding: 2px 6px; font-size: 12px; border-radius: 3px; vertical-align: middle; }
    </style>
</head>
<body>

    <%
        // Look up identity data inside Redis to tailor the experience if they are active
        String activeUser = null;
        
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("ZEUS_SESSION_ID".equals(c.getName())) {
                    try (Jedis jedis = RedisUtil.getRedisConnection()) {
                        activeUser = jedis.hget("session:" + c.getValue(), "firstName");
                    } catch(Exception e) {}
                    break;
                }
            }
        }
    %>

    <div class="nav-box">
        <% if (activeUser != null) { %>
            <span>Hello, <strong><%= activeUser %></strong> (Active Redis Session Verified) | </span>
            <a href="welcome.jsp" style="font-weight: bold; color: #007bff;">Go to Dashboard</a>
        <% } else { %>
            <span>Browsing anonymously (No active session tracking) | </span>
            <a href="login.jsp" style="font-weight: bold; color: #007bff;">Back to Login</a>
        <% } %>
    </div>

    <h2>Project Zeus Application Services</h2>
    <p>Explore the services provided by our high-availability application cluster nodes.</p>
    <hr style="border: 0; border-top: 1px solid #ddd; margin-bottom: 25px;">

    <!-- Service 1: Available to everyone -->
    <div class="service-item">
        <h3>🛠 Core API Gateway <span class="public-badge">Public Available</span></h3>
        <p>Our distributed microservices layer exposes stateless RESTful access points. Perfect for querying public system statuses and retrieving public configuration manifests across your deployment environment.</p>
    </div>

    <!-- Service 2: Dynamic / Interactive (Perfect for this JSP) -->
    <div class="service-item">
        <h3>🚀 Real-time Compute Node Profiling 
            <% if (activeUser != null) { %>
                <span class="secure-badge">Unlocked</span>
            <% } else { %>
                <span class="public-badge" style="background-color: #dc3545;">Locked</span>
            <% } %>
        </h3>
        <p>Monitors distributed job executions and cluster worker threads dynamically.</p>
        
        <% if (activeUser != null) { %>
            <div style="background: #f1f3f5; padding: 10px; margin-top: 10px; border-radius: 4px; font-family: monospace;">
                <strong>Server Host Name:</strong> <%= InetAddress.getLocalHost().getHostName() %><br>
                <strong>Cluster Connection Status:</strong> HEALTHY (Connected to Redis State Machine)
            </div>
        <% } else { %>
            <p style="color: #666; font-style: italic; font-size: 14px; margin-top: 10px;">
                🔒 Detailed cluster performance indicators are hidden. Please sign in to authenticate against the Redis cache and access this tool.
            </p>
        <% } %>
    </div>

    <!-- Bottom Navigation -->
    <div style="text-align: center; margin-top: 30px;">
        Need to view system data maps? 
        <a href="welcome.jsp" style="color:#28a745; font-weight:bold; text-decoration: none;">Access Secure Area Dashboard →</a>
    </div>

</body>
</html>