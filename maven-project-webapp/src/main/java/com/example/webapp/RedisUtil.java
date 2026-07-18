package com.example.webapp;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

public class RedisUtil {

    // Replace with your actual AWS ElastiCache Cluster Configuration Endpoint
    private static final String REDIS_HOST = "zeus-session-cache-n51yvu.serverless.usw2.cache.amazonaws.com";
    private static final int REDIS_PORT = 6379;
    
    private static final JedisPool jedisPool;

    static {
        JedisPoolConfig poolConfig = new JedisPoolConfig();
        
        // Connection Pool Tuning Guidelines
        poolConfig.setMaxTotal(64);         // Max active connections to Redis
        poolConfig.setMaxIdle(32);          // Max idle connections in the pool
        poolConfig.setMinIdle(8);           // Minimum idle connections to maintain
        poolConfig.setTestOnBorrow(true);   // Verify connection health before handing it to code
        
        boolean useSsl = true;
        jedisPool = new JedisPool(poolConfig, REDIS_HOST, REDIS_PORT, 2000, null, useSsl);
        System.out.println("🚀 Centralized JedisPool Initialized successfully for endpoint: " + REDIS_HOST);

        //2000millisecond=2second time needed to establish a connection and time needed to read or 
        // enter data through an established connection (i.e. a socket). If it exceeds in both cases
        // an error is thrown
    }

    /**
     * Obtains a thread-safe Redis connection resource from the centralized pool.
     * Must be wrapped in a try-with-resources statement to return it back to the pool automatically.
     */
    public static Jedis getRedisConnection() {
        return jedisPool.getResource();
    }

    /**
     * Safely closes the pool for the specific container that is shutting down.
     */
    public static void closePool() {
        if (jedisPool != null && !jedisPool.isClosed()) {
            jedisPool.close();
        }
    }
}