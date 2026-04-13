package com.example.webapp;

import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;

import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.rds.RdsClient;

public class DBUtil {

    private static final String HOST = "zeus-db.cxsee6smsxz1.us-west-2.rds.amazonaws.com";
    private static final int PORT = 3306;
    private static final Region REGION = Region.US_WEST_2;

    public static Connection getConnection(String user, String db) throws Exception {

        var rdsClient = RdsClient.builder()
                .region(REGION)
                .build();

        var token = rdsClient.utilities().generateAuthenticationToken(builder -> builder
                .hostname(HOST)
                .port(PORT)
                .username(user)
        );

        String dbPart = (db != null) ? "/" + db : "";

        String url = "jdbc:mysql://" + HOST + ":" + PORT + dbPart +
                "?useSSL=true&requireSSL=true";

        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", token);
		
		Class.forName("com.mysql.cj.jdbc.Driver");

        return DriverManager.getConnection(url, props);
    }
}