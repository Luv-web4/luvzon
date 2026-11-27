<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db_config.jspf" %>
<%
    String errorMessage = "";
    String successMessage = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password");
        String role = request.getParameter("role");
        String fullName = request.getParameter("full_name");

        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            errorMessage = "Username and password are required!";
        } else if (!password.equals(confirmPassword)) {
            errorMessage = "Passwords do not match!";
        } else if (role == null || (!role.equalsIgnoreCase("user") && !role.equalsIgnoreCase("producer"))) {
            errorMessage = "Please choose a valid role: Producer or User.";
        } else {
            Connection conn = null;
            PreparedStatement checkStmt = null;
            PreparedStatement insertStmt = null;
            ResultSet rs = null;

            try {
                conn = getDBConnection();
                checkStmt = conn.prepareStatement("SELECT id FROM users WHERE username = ?");
                checkStmt.setString(1, username.trim());
                rs = checkStmt.executeQuery();

                if (rs.next()) {
                    errorMessage = "Username '" + username + "' is already taken. Please choose another!";
                } else {
                    String insertSql = "INSERT INTO users (username, password, role, full_name) VALUES (?, ?, ?, ?)";
                    insertStmt = conn.prepareStatement(insertSql);
                    insertStmt.setString(1, username.trim());
                    insertStmt.setString(2, password);
                    insertStmt.setString(3, role.toLowerCase());
                    insertStmt.setString(4, (fullName != null && !fullName.trim().isEmpty()) ? fullName.trim() : username.trim());

                    int rows = insertStmt.executeUpdate();
                    if (rows > 0) {
                        response.sendRedirect("login.jsp?registered=1");
                        return;
                    } else {
                        errorMessage = "Could not register account. Please try again.";
                    }
                }
            } catch (Exception e) {
                errorMessage = "Database Error: " + e.getMessage();
            } finally {
                closeQuietly(rs);
                closeQuietly(checkStmt);
                closeQuietly(insertStmt);
                closeQuietly(conn);
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LuvZon - Register Account</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 50%, #db2777 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 25px 0;
        }
        .auth-card {
            background: #ffffff;
            border-radius: 1.25rem;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.25);
            overflow: hidden;
            width: 100%;
            max-width: 500px;
        }
        .auth-header {
            background: linear-gradient(135deg, #1e1b4b 0%, #312e81 100%);
            color: #ffffff;
            padding: 2rem;
            text-align: center;
        }
        .role-box {
            border: 2px solid #e5e7eb;
            border-radius: 0.75rem;
            padding: 14px;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .role-box:hover {
            border-color: #6366f1;
            background-color: #f5f3ff;
        }
        .form-check-input:checked ~ .role-content {
            color: #4338ca;
        }
        .btn-register {
            background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            color: white;
            font-weight: 600;
            padding: 0.75rem;
            border-radius: 0.5rem;
            border: none;
        }
        .btn-register:hover {
            opacity: 0.95;
            color: white;
            box-shadow: 0 8px 18px rgba(79, 70, 229, 0.35);
        }
    </style>
</head>
<body>

<div class="container d-flex justify-content-center">
    <div class="auth-card">
        <div class="auth-header">
            <h2 class="fw-bold mb-1"><i class="bi bi-person-plus-fill me-2 text-warning"></i>Join LuvZon</h2>
            <p class="text-white-50 mb-0 small">Create your account as a Customer or Producer</p>
        </div>

        <div class="p-4">
            <% if (!errorMessage.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorMessage %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <form method="POST" action="register.jsp">
                <!-- Select Producer or User -->
                <label class="form-label fw-bold text-secondary small mb-2">REGISTER ACCOUNT AS:</label>
                <div class="row g-2 mb-3">
                    <div class="col-6">
                        <label class="role-box w-100 d-flex align-items-center">
                            <input type="radio" name="role" value="user" class="form-check-input me-2" checked>
                            <div class="role-content">
                                <div class="fw-bold"><i class="bi bi-person text-primary me-1"></i>User / Buyer</div>
                                <div class="text-muted" style="font-size: 0.75rem;">Shop & place orders</div>
                            </div>
                        </label>
                    </div>
                    <div class="col-6">
                        <label class="role-box w-100 d-flex align-items-center">
                            <input type="radio" name="role" value="producer" class="form-check-input me-2">
                            <div class="role-content">
                                <div class="fw-bold"><i class="bi bi-shop text-warning me-1"></i>Producer</div>
                                <div class="text-muted" style="font-size: 0.75rem;">Add & manage inventory</div>
                            </div>
                        </label>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-semibold text-secondary small">FULL NAME / BUSINESS NAME</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-card-text"></i></span>
                        <input type="text" name="full_name" class="form-control" placeholder="e.g., Alex Johnson" required>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-semibold text-secondary small">USERNAME</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-person"></i></span>
                        <input type="text" name="username" class="form-control" placeholder="Choose username" required>
                    </div>
                </div>

                <div class="row g-2 mb-3">
                    <div class="col-6">
                        <label class="form-label fw-semibold text-secondary small">PASSWORD</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-lock"></i></span>
                            <input type="password" name="password" class="form-control" placeholder="Password" required>
                        </div>
                    </div>
                    <div class="col-6">
                        <label class="form-label fw-semibold text-secondary small">CONFIRM</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                            <input type="password" name="confirm_password" class="form-control" placeholder="Confirm" required>
                        </div>
                    </div>
                </div>

                <div class="d-grid mt-4">
                    <button type="submit" class="btn btn-register">
                        <i class="bi bi-check-circle me-1"></i> Complete Registration
                    </button>
                </div>

                <div class="text-center mt-3 pt-2 border-top">
                    <span class="text-muted small">Already have an account? </span>
                    <a href="login.jsp" class="fw-semibold text-decoration-none">Sign In Here</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
