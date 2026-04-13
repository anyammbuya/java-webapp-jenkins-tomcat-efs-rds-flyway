package com.example.webapp;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;

import org.flywaydb.core.Flyway;

import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;

public class FlywayInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {

        try {
            String secretName = "db-admin-password";
            String region = "us-west-2";

            // -------- FETCH PASSWORD FROM SECRETS MANAGER -------
            SecretsManagerClient client = SecretsManagerClient.builder()
                    .region(Region.of(region))
                    .build();

            String password = client.getSecretValue(
                    GetSecretValueRequest.builder()
                            .secretId(secretName)
                            .build()
            ).secretString();

            // -------- DB CONNECTION INFO -------------
            String username = "admin";
            String host = "zeus-db.cxsee6smsxz1.us-west-2.rds.amazonaws.com";
            String port = "3306";

            String url = "jdbc:mysql://" + host + ":" + port +
                    "/zeus_project_db?useSSL=true&requireSSL=true";

            // -------- FLYWAY --------
            Flyway flyway = Flyway.configure()
                    .dataSource(url, username, password)
                    .locations("classpath:db/migration")
                    .load();

            flyway.migrate();

            System.out.println("Flyway migration completed successfully");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}