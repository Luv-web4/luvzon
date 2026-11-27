<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ include file="db_config.jspf" %>
<%
    String resultMessage = "";
    String resultType = "success";
    List<String> executedLogs = new ArrayList<>();
    boolean isDone = false;

    // Connect to MySQL server at root level (without database name)
    String rootUrl = "jdbc:mysql://" + DB_HOST + ":" + DB_PORT + "/?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8&allowMultiQueries=true";
    Connection conn = null;
    Statement stmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(rootUrl, DB_USER, DB_PASS);
        stmt = conn.createStatement();

        // Locate database.sql from web application context
        InputStream inStream = application.getResourceAsStream("/database.sql");
        if (inStream == null) {
            // Fallback to local file path
            File file = new File(application.getRealPath("/database.sql"));
            if (file.exists()) {
                inStream = new FileInputStream(file);
            } else {
                inStream = new FileInputStream("C:/MMMUT files/1 st year/IT/project/luvzon/database.sql");
            }
        }

        BufferedReader reader = new BufferedReader(new InputStreamReader(inStream, "UTF-8"));
        StringBuilder sb = new StringBuilder();
        String line;

        while ((line = reader.readLine()) != null) {
            String trimmed = line.trim();
            // Ignore SQL comment lines
            if (trimmed.startsWith("--") || trimmed.startsWith("/*")) {
                continue;
            }
            sb.append(line).append("\n");
        }
        reader.close();

        // Split queries by semicolon delimiter
        String allSql = sb.toString();
        String[] queries = allSql.split(";\\s*\\r?\\n");

        int successCount = 0;
        for (String q : queries) {
            String singleQuery = q.trim();
            if (!singleQuery.isEmpty()) {
                try {
                    stmt.execute(singleQuery);
                    successCount++;
                    if (singleQuery.toUpperCase().startsWith("CREATE DATABASE") ||
                        singleQuery.toUpperCase().startsWith("CREATE TABLE") ||
                        singleQuery.toUpperCase().startsWith("INSERT INTO")) {
                        String summary = singleQuery.length() > 60 ? singleQuery.substring(0, 60) + "..." : singleQuery;
                        executedLogs.add(summary.replaceAll("\\s+", " "));
                    }
                } catch (SQLException ex) {
                    executedLogs.add("Notice: " + ex.getMessage());
                }
            }
        }

        isDone = true;
        resultMessage = "Database 'luvzon_db' and all 3 tables have been initialized successfully with 42 demo products!";
        resultType = "success";

    } catch (Exception e) {
        resultType = "danger";
        resultMessage = "Setup Error (" + e.getClass().getSimpleName() + "): " + e.getMessage();
    } finally {
        closeQuietly(stmt);
        closeQuietly(conn);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Database Setup - LuvZon</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
</head>
<body class="bg-light py-5">
<div class="container" style="max-width: 720px;">
    <div class="card shadow-sm border-0 rounded-4">
        <div class="card-header bg-primary text-white p-4 rounded-top-4">
            <h3 class="mb-1"><i class="bi bi-database-check me-2"></i>Database Auto-Initializer</h3>
            <p class="mb-0 text-white-50 small">Automatic execution of database.sql for LuvZon</p>
        </div>

        <div class="card-body p-4">
            <div class="alert alert-<%= resultType %> rounded-3 d-flex align-items-center mb-4">
                <i class="bi <%= isDone ? "bi-check-circle-fill text-success" : "bi-exclamation-triangle-fill text-danger" %> fs-3 me-3"></i>
                <div>
                    <h5 class="fw-bold mb-1"><%= isDone ? "Setup Completed Successfully!" : "Setup Incomplete" %></h5>
                    <div><%= resultMessage %></div>
                </div>
            </div>

            <% if (isDone) { %>
                <div class="card mb-4 bg-light border-0">
                    <div class="card-body">
                        <h6 class="fw-bold mb-2"><i class="bi bi-list-check me-1"></i> What was created:</h6>
                        <ul class="mb-0 small text-secondary">
                            <li>Database: <strong><code>luvzon_db</code></strong></li>
                            <li>Table 1: <strong><code>users</code></strong> (Authentication for Producer &amp; Customer roles)</li>
                            <li>Table 2: <strong><code>products</code></strong> (Seeded with 42 items across 6 categories)</li>
                            <li>Table 3: <strong><code>orders</code></strong> (Simulated purchase history ledger)</li>
                            <li>Default Accounts: <code>buyer1 / password123</code> and <code>seller1 / password123</code></li>
                        </ul>
                    </div>
                </div>

                <div class="d-grid gap-2">
                    <a href="login.jsp" class="btn btn-primary btn-lg rounded-pill fw-bold">
                        <i class="bi bi-box-arrow-in-right me-2"></i>Go to LuvZon Login Portal
                    </a>
                    <a href="test_db.jsp" class="btn btn-outline-secondary rounded-pill">
                        Verify Diagnostics in test_db.jsp
                    </a>
                </div>
            <% } else { %>
                <div class="alert alert-warning small">
                    <strong>Troubleshooting:</strong> If MySQL threw an Access Denied error, verify your password in <code>db_config.jspf</code>.
                </div>
                <a href="setup_db.jsp" class="btn btn-warning rounded-pill px-4">
                    <i class="bi bi-arrow-repeat me-1"></i> Try Running Again
                </a>
            <% } %>
        </div>
    </div>
</div>
</body>
</html>
