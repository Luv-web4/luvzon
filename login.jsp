<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db_config.jspf" %>
<%
    String errorMessage = "";
    String successMessage = request.getParameter("registered") != null ? "Account created successfully! Please log in with your credentials." : "";
    if (request.getParameter("logged_out") != null) {
        successMessage = "You have been successfully logged out.";
    }

    String action = request.getParameter("action");
    if (action == null) {
        action = "login";
    }

    // Process Form Submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String formType = request.getParameter("formType");
        
        // ------------------ LOGIN ACTION ------------------
        if ("login".equalsIgnoreCase(formType)) {
            String user = request.getParameter("username");
            String pass = request.getParameter("password");

            if (user == null || user.trim().isEmpty() || pass == null || pass.trim().isEmpty()) {
                errorMessage = "Please enter both username and password.";
            } else {
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;

                try {
                    conn = getDBConnection();
                    String sql = "SELECT role, username FROM users WHERE username = ? AND password = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, user.trim());
                    pstmt.setString(2, pass);
                    rs = pstmt.executeQuery();

                    if (rs.next()) {
                        String role = rs.getString("role");
                        String loggedInUser = rs.getString("username");

                        session.setAttribute("loggedInUser", loggedInUser);
                        session.setAttribute("role", role);

                        if ("producer".equalsIgnoreCase(role)) {
                            response.sendRedirect("producer.jsp");
                            return;
                        } else {
                            response.sendRedirect("user.jsp");
                            return;
                        }
                    } else {
                        errorMessage = "Invalid username or password!";
                    }
                } catch (Exception e) {
                    errorMessage = "Database Connection Error (" + e.getClass().getSimpleName() + "): " + e.getMessage() + ". Open test_db.jsp for diagnostics.";
                } finally {
                    closeQuietly(rs);
                    closeQuietly(pstmt);
                    closeQuietly(conn);
                }
            }
        }
        // ------------------ REGISTER ACTION ------------------
        else if ("register".equalsIgnoreCase(formType)) {
            String user = request.getParameter("reg_username");
            String pass = request.getParameter("reg_password");
            String confirmPass = request.getParameter("reg_confirm_password");
            String role = request.getParameter("reg_role");
            String fullName = request.getParameter("reg_fullname");

            if (user == null || user.trim().isEmpty() || pass == null || pass.isEmpty()) {
                errorMessage = "All registration fields are required.";
                action = "register";
            } else if (!pass.equals(confirmPass)) {
                errorMessage = "Passwords do not match.";
                action = "register";
            } else if (role == null || (!role.equalsIgnoreCase("user") && !role.equalsIgnoreCase("producer"))) {
                errorMessage = "Please select a valid account type (Customer / User or Producer / Seller).";
                action = "register";
            } else {
                Connection conn = null;
                PreparedStatement checkStmt = null;
                PreparedStatement insertStmt = null;
                ResultSet rs = null;

                try {
                    conn = getDBConnection();
                    // Check if username exists
                    checkStmt = conn.prepareStatement("SELECT id FROM users WHERE username = ?");
                    checkStmt.setString(1, user.trim());
                    rs = checkStmt.executeQuery();

                    if (rs.next()) {
                        errorMessage = "Username '" + user + "' is already registered! Please choose another.";
                        action = "register";
                    } else {
                        // Insert new user
                        String insertSql = "INSERT INTO users (username, password, role, full_name) VALUES (?, ?, ?, ?)";
                        insertStmt = conn.prepareStatement(insertSql);
                        insertStmt.setString(1, user.trim());
                        insertStmt.setString(2, pass);
                        insertStmt.setString(3, role.toLowerCase());
                        insertStmt.setString(4, (fullName != null && !fullName.trim().isEmpty()) ? fullName.trim() : user.trim());
                        
                        int rows = insertStmt.executeUpdate();
                        if (rows > 0) {
                            successMessage = "Account registered successfully as " + role.toUpperCase() + "! You can now log in.";
                            action = "login";
                        } else {
                            errorMessage = "Registration failed. Please try again.";
                            action = "register";
                        }
                    }
                } catch (Exception e) {
                    errorMessage = "Database Error (" + e.getClass().getSimpleName() + "): " + e.getMessage() + ". Open test_db.jsp for diagnostics.";
                    action = "register";
                } finally {
                    closeQuietly(rs);
                    closeQuietly(checkStmt);
                    closeQuietly(insertStmt);
                    closeQuietly(conn);
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LuvZon - Login & Registration</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 50%, #db2777 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 20px 0;
        }
        .auth-card {
            background: #ffffff;
            border-radius: 1.25rem;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.25);
            overflow: hidden;
            width: 100%;
            max-width: 480px;
            animation: fadeIn 0.4s ease-in-out;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(15px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .auth-header {
            background: linear-gradient(135deg, #1e1b4b 0%, #312e81 100%);
            color: #ffffff;
            padding: 2rem;
            text-align: center;
        }
        .brand-badge {
            display: inline-block;
            background: rgba(255, 255, 255, 0.15);
            padding: 6px 14px;
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 500;
            letter-spacing: 0.5px;
            margin-bottom: 0.75rem;
        }
        .nav-pills .nav-link {
            border-radius: 0.5rem;
            font-weight: 600;
            color: #4b5563;
            transition: all 0.2s ease;
        }
        .nav-pills .nav-link.active {
            background-color: #4f46e5;
            color: #fff;
        }
        .role-option {
            cursor: pointer;
            border: 2px solid #e5e7eb;
            border-radius: 0.75rem;
            padding: 12px;
            transition: all 0.2s;
        }
        .role-option:hover {
            border-color: #6366f1;
            background: #f5f3ff;
        }
        .form-check-input:checked + .role-label {
            color: #4338ca;
            font-weight: 600;
        }
        .btn-primary-custom {
            background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            border: none;
            color: white;
            font-weight: 600;
            padding: 0.75rem;
            border-radius: 0.5rem;
            transition: transform 0.15s ease, box-shadow 0.15s ease;
        }
        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 18px rgba(79, 70, 229, 0.35);
            color: white;
        }
    </style>
</head>
<body>

<div class="container d-flex justify-content-center">
    <div class="auth-card">
        <!-- Header -->
        <div class="auth-header">
            <span class="brand-badge"><i class="bi bi-cart3 me-1"></i> E-COMMERCE PORTAL</span>
            <h2 class="fw-bold mb-1"><i class="bi bi-shop me-2 text-warning"></i>LuvZon</h2>
            <p class="text-white-50 mb-0 small">Your One-Stop Online Marketplace</p>
        </div>

        <div class="p-4">
            <!-- Alert Messages -->
            <% if (!errorMessage.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-3" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
                    <div><%= errorMessage %></div>
                    <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <% if (!successMessage.isEmpty()) { %>
                <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-3" role="alert">
                    <i class="bi bi-check-circle-fill me-2 fs-5"></i>
                    <div><%= successMessage %></div>
                    <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <!-- Tabs: Login vs Register -->
            <ul class="nav nav-pills nav-fill mb-4 p-1 bg-light rounded" id="authTab" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link <%= "login".equals(action) ? "active" : "" %>" id="login-tab" data-bs-toggle="pill" data-bs-target="#login-panel" type="button" role="tab">
                        <i class="bi bi-box-arrow-in-right me-1"></i> Login
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link <%= "register".equals(action) ? "active" : "" %>" id="register-tab" data-bs-toggle="pill" data-bs-target="#register-panel" type="button" role="tab">
                        <i class="bi bi-person-plus me-1"></i> Register
                    </button>
                </li>
            </ul>

            <div class="tab-content" id="authTabContent">
                <!-- ================= LOGIN TAB ================= -->
                <div class="tab-pane fade <%= "login".equals(action) ? "show active" : "" %>" id="login-panel" role="tabpanel">
                    <form method="POST" action="login.jsp">
                        <input type="hidden" name="formType" value="login">

                        <div class="mb-3">
                            <label class="form-label fw-semibold text-secondary small">USERNAME</label>
                            <div class="input-group">
                                <span class="input-group-text bg-white text-muted"><i class="bi bi-person"></i></span>
                                <input type="text" name="username" class="form-control" placeholder="Enter username" required autofocus>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold text-secondary small">PASSWORD</label>
                            <div class="input-group">
                                <span class="input-group-text bg-white text-muted"><i class="bi bi-lock"></i></span>
                                <input type="password" name="password" id="loginPassword" class="form-control" placeholder="Enter password" required>
                                <button class="btn btn-outline-secondary" type="button" onclick="togglePassword('loginPassword', this)">
                                    <i class="bi bi-eye"></i>
                                </button>
                            </div>
                        </div>

                        <div class="d-grid mt-4">
                            <button type="submit" class="btn btn-primary-custom">
                                <i class="bi bi-box-arrow-in-right me-2"></i>Sign In
                            </button>
                        </div>
                    </form>

                    <!-- Demo Credentials Helper -->
                    <div class="mt-4 pt-3 border-top text-center text-muted small">
                        <div class="fw-semibold text-dark mb-1">Quick Demo Credentials:</div>
                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle me-1">
                            User: <code>buyer1</code> / <code>password123</code>
                        </span>
                        <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle">
                            Producer: <code>seller1</code> / <code>password123</code>
                        </span>
                    </div>
                </div>

                <!-- ================= REGISTER TAB ================= -->
                <div class="tab-pane fade <%= "register".equals(action) ? "show active" : "" %>" id="register-panel" role="tabpanel">
                    <form method="POST" action="login.jsp">
                        <input type="hidden" name="formType" value="register">

                        <!-- Role Selection (Producer vs User) -->
                        <label class="form-label fw-semibold text-secondary small mb-2">I WANT TO REGISTER AS:</label>
                        <div class="row g-2 mb-3">
                            <div class="col-6">
                                <label class="role-option w-100 d-flex align-items-center">
                                    <input type="radio" name="reg_role" value="user" class="form-check-input me-2" checked>
                                    <div class="role-label small">
                                        <i class="bi bi-cart me-1 text-primary"></i><strong>Customer</strong>
                                        <div class="text-muted" style="font-size: 0.75rem;">Browse & Buy</div>
                                    </div>
                                </label>
                            </div>
                            <div class="col-6">
                                <label class="role-option w-100 d-flex align-items-center">
                                    <input type="radio" name="reg_role" value="producer" class="form-check-input me-2">
                                    <div class="role-label small">
                                        <i class="bi bi-shop me-1 text-warning"></i><strong>Producer</strong>
                                        <div class="text-muted" style="font-size: 0.75rem;">Add & Sell Items</div>
                                    </div>
                                </label>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold text-secondary small">FULL NAME / STORE NAME</label>
                            <div class="input-group">
                                <span class="input-group-text bg-white text-muted"><i class="bi bi-card-text"></i></span>
                                <input type="text" name="reg_fullname" class="form-control" placeholder="e.g. John Doe or Apex Retail">
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold text-secondary small">USERNAME</label>
                            <div class="input-group">
                                <span class="input-group-text bg-white text-muted"><i class="bi bi-person"></i></span>
                                <input type="text" name="reg_username" class="form-control" placeholder="Choose a unique username" required>
                            </div>
                        </div>

                        <div class="row g-2 mb-3">
                            <div class="col-6">
                                <label class="form-label fw-semibold text-secondary small">PASSWORD</label>
                                <input type="password" name="reg_password" class="form-control" placeholder="Password" required>
                            </div>
                            <div class="col-6">
                                <label class="form-label fw-semibold text-secondary small">CONFIRM</label>
                                <input type="password" name="reg_confirm_password" class="form-control" placeholder="Repeat" required>
                            </div>
                        </div>

                        <div class="d-grid mt-4">
                            <button type="submit" class="btn btn-primary-custom">
                                <i class="bi bi-person-check me-2"></i>Create Account
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Standalone Register page link -->
            <div class="text-center mt-3">
                <a href="register.jsp" class="text-decoration-none small text-muted">
                    <i class="bi bi-arrow-up-right-square me-1"></i>Open Dedicated Registration Page
                </a>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap 5 JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function togglePassword(inputId, btn) {
        const input = document.getElementById(inputId);
        const icon = btn.querySelector('i');
        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.remove('bi-eye');
            icon.classList.add('bi-eye-slash');
        } else {
            input.type = 'password';
            icon.classList.remove('bi-eye-slash');
            icon.classList.add('bi-eye');
        }
    }
</script>
</body>
</html>
