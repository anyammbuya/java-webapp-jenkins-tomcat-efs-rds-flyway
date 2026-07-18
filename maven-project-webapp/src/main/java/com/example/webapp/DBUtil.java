package com.example.webapp;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {

    // Primary cluster - writer endpoint
    private static final String DB_WRITER_ENDPOINT =
            "zeus-db.cxsee6smsxz1.us-west-2.rds.amazonaws.com";

    // 3 Read Replica endpoint
    private static final String DB_READER_ENDPOINT =
            "zeus-db-replica.cxsee6smsxz1.us-west-2.rds.amazonaws.com";

    private static final String DB_PORT = "3306";

    private static final String AWS_REGION = "us-west-2";

    public static Connection getConnection(
            String dbUser,
            String dbName,
            boolean isReadOnly
    ) throws SQLException {

        try {

            Class.forName("software.amazon.jdbc.Driver");

            // Pick endpoint based on the intent of the request
            String targetEndpoint = isReadOnly ? DB_READER_ENDPOINT : DB_WRITER_ENDPOINT;

            String url =
                    "jdbc:aws-wrapper:mysql://"
                    + targetEndpoint
                    + ":"
                    + DB_PORT
                    + "/"
                    + dbName
                    + "?wrapperPlugins=iam"
                    + "&iamRegion="
                    + AWS_REGION;

            Connection connection =
                    DriverManager.getConnection(
                            url,
                            dbUser,
                            null
                    );

            System.out.println(
                    "IAM database authentication successful (" 
                    + (isReadOnly ? "READER" : "WRITER") 
                    + ") for user: " + dbUser
            );

            return connection;

        } catch (ClassNotFoundException e) {

            throw new SQLException(
                    "AWS JDBC wrapper driver not found",
                    e
            );
        }
    }
}