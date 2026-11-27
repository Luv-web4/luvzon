<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db_config.jspf" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>LuvZon - Database Connection Diagnostic</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light py-5">
<div class="container" style="max-width: 800px;">
    <div class="card shadow-sm border-0 rounded-4">
        <div class="card-header bg-dark text-white p-4 rounded-top-4">
            <h3 class="mb-1">LuvZon Database Diagnostic Tool</h3>
            <p class="mb-0 text-white-50 small">Step-by-step check of Driver, MySQL Server, Credentials, Database, and Tables</p>
        </div>
        <div class="card-body p-4">
            <ul class="list-group list-group-flush">
                <!-- Environment Info -->
                <li class="list-group-item">
                    <strong>Environment:</strong><br>
                    Server: <code><%= application.getServerInfo() %></code><br>
                    Java Version: <code><%= System.getProperty("java.version") %></code><br>
                    Configured Host/Port: <code><%= DB_HOST %>:<%= DB_PORT %></code> | DB: <code><%= DB_NAME %></code> | User: <code><%= DB_USER %></code>
                </li>

                <!-- Step 1: JDBC Driver Check -->
                <li class="list-group-item">
                    <strong>Step 1: MySQL JDBC Driver JAR Check</strong><br>
                    <%
                        boolean driverOk = false;
                        String loadedDriver = "";
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            driverOk = true;
                            loadedDriver = "com.mysql.cj.jdbc.Driver (MySQL Connector/J 8.x/9.x)";
                        } catch (ClassNotFoundException e1) {
                            try {
                                Class.forName("com.mysql.jdbc.Driver");
                                driverOk = true;
                                loadedDriver = "com.mysql.jdbc.Driver (Legacy Connector/J 5.x)";
                            } catch (ClassNotFoundException e2) {
                                driverOk = false;
                            }
                        }

                        if (driverOk) {
                    %>
                        <span class="badge bg-success mt-1">PASS</span> Loaded: <code><%= loadedDriver %></code>
                    <% } else { %>
                        <span class="badge bg-danger mt-1">FAIL</span> MySQL JDBC Driver JAR is missing!<br>
                        <div class="alert alert-danger mt-2 mb-0 small">
                            <strong>Fix:</strong> Download <code>mysql-connector-j-8.x.x.jar</code> (or <code>9.x.x.jar</code>) and place it inside:<br>
                            <code>&lt;Tomcat_Home&gt;/lib/</code> OR <code>luvzon/WEB-INF/lib/</code>, then <strong>restart Tomcat</strong>.
                        </div>
                    <% } %>
                </li>

                <!-- Step 2: MySQL Server & Credentials Check (without DB) -->
                <li class="list-group-item">
                    <strong>Step 2: MySQL Server &amp; Login Credentials Check</strong><br>
                    <%
                        boolean serverOk = false;
                        String serverErr = "";
                        if (driverOk) {
                            Connection sConn = null;
                            try {
                                String baseUrl = "jdbc:mysql://" + DB_HOST + ":" + DB_PORT + "/?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
                                sConn = DriverManager.getConnection(baseUrl, DB_USER, DB_PASS);
                                serverOk = true;
                            } catch (Exception e) {
                                serverErr = e.getClass().getSimpleName() + ": " + e.getMessage();
                            } finally {
                                closeQuietly(sConn);
                            }
                        }
                        if (!driverOk) {
                    %>
                        <span class="badge bg-secondary mt-1">SKIPPED</span> Fix Step 1 first.
                    <% } else if (serverOk) { %>
                        <span class="badge bg-success mt-1">PASS</span> Connected to MySQL server as user <code><%= DB_USER %></code>.
                    <% } else { %>
                        <span class="badge bg-danger mt-1">FAIL</span> Could not connect to MySQL server.<br>
                        <div class="alert alert-danger mt-2 mb-0 small">
                            <strong>Error:</strong> <code><%= serverErr %></code><br><br>
                            <strong>Common Fixes:</strong>
                            <ul class="mb-0">
                                <li>If <code>Communications link failure</code>: MySQL service is not running, or it is running on a different port (check port 3306 vs 3307 in MySQL/XAMPP).</li>
                                <li>If <code>Access denied for user 'root'</code>: Your MySQL password is not <code>root</code> (e.g., in XAMPP the default password is empty <code>""</code>). Update <code>DB_PASS</code> in <code>db_config.jspf</code>.</li>
                            </ul>
                        </div>
                    <% } %>
                </li>

                <!-- Step 3: Target Database & Tables Check -->
                <li class="list-group-item">
                    <strong>Step 3: Database (<code><%= DB_NAME %></code>) &amp; Tables Check</strong><br>
                    <%
                        boolean dbOk = false;
                        String dbErr = "";
                        int userRows = -1, productRows = -1, orderRows = -1;
                        if (serverOk) {
                            Connection dConn = null;
                            Statement st = null;
                            ResultSet rs = null;
                            try {
                                dConn = getDBConnection();
                                dbOk = true;
                                st = dConn.createStatement();

                                rs = st.executeQuery("SELECT COUNT(*) FROM users");
                                if (rs.next()) userRows = rs.getInt(1);
                                closeQuietly(rs);

                                rs = st.executeQuery("SELECT COUNT(*) FROM products");
                                if (rs.next()) productRows = rs.getInt(1);
                                closeQuietly(rs);

                                rs = st.executeQuery("SELECT COUNT(*) FROM orders");
                                if (rs.next()) orderRows = rs.getInt(1);
                            } catch (Exception e) {
                                dbErr = e.getClass().getSimpleName() + ": " + e.getMessage();
                            } finally {
                                closeQuietly(rs);
                                closeQuietly(st);
                                closeQuietly(dConn);
                            }
                        }

                        if (!serverOk) {
                    %>
                        <span class="badge bg-secondary mt-1">SKIPPED</span> Fix Step 2 first.
                    <% } else if (dbOk && userRows >= 0 && productRows >= 0 && orderRows >= 0) { %>
                        <span class="badge bg-success mt-1">PASS</span> Database and all 3 tables are ready!<br>
                        <div class="mt-2 small">
                            <code>users</code>: <strong><%= userRows %></strong> rows |
                            <code>products</code>: <strong><%= productRows %></strong> rows |
                            <code>orders</code>: <strong><%= orderRows %></strong> rows
                        </div>
                    <% } else { %>
                        <span class="badge bg-danger mt-1">FAIL</span> Database or tables missing!<br>
                        <div class="alert alert-danger mt-2 mb-0 small">
                            <strong>Error:</strong> <code><%= dbErr %></code><br><br>
                            <strong>Fix:</strong> Import <code>database.sql</code> in MySQL Workbench, phpMyAdmin, or MySQL Command Line:<br>
                            <code>SOURCE C:/MMMUT files/1 st year/IT/project/luvzon/database.sql;</code>
                        </div>
                    <% } %>
                </li>
            </ul>

            <div class="mt-4 d-flex justify-content-between">
                <a href="test_db.jsp" class="btn btn-outline-primary">Re-run Diagnostics</a>
                <a href="login.jsp" class="btn btn-primary">Go to Login Page</a>
            </div>
        </div>
    </div>
</div>
</body>
</html>
