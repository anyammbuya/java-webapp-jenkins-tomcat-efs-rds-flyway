package com.example.webapp;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;

public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // This triggers the static initialization block inside RedisUtil to open the pool for the 
        // specific container that is being spun up. i.e each container has its own Redis pool of 
        // connections
        try {
            Class.forName("com.example.webapp.RedisUtil");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("Stopping web application... Gracefully closing JedisPool.");
        // destroy the redis pool for the container that is being spun down.
        RedisUtil.closePool(); 
    }
}