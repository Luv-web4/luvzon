<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db_config.jspf" %>
<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    int totalOrders = 0;
    double totalSpent = 0.0;

    try {
        conn = getDBConnection();
        String sql = "SELECT * FROM orders WHERE username = ? ORDER BY order_date DESC";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, loggedInUser);
        rs = pstmt.executeQuery();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Order History - LuvZon</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body {
            background-color: #f8fafc;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: #1e293b;
        }
        .navbar-luvzon {
            background: linear-gradient(135deg, #1e1b4b 0%, #312e81 100%);
        }
        .page-header {
            background: white;
            border-bottom: 1px solid #e2e8f0;
            padding: 2rem 0;
            margin-bottom: 2rem;
        }
        .order-card {
            background: white;
            border-radius: 1rem;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            border: none;
            overflow: hidden;
        }
        .stat-badge {
            background: #ede9fe;
            color: #6d28d9;
            padding: 1rem 1.5rem;
            border-radius: 1rem;
        }
    </style>
</head>
<body>

<!-- Navigation Bar -->
<nav class="navbar navbar-expand-lg navbar-dark navbar-luvzon sticky-top shadow-sm">
    <div class="container">
        <a class="navbar-brand fw-bold d-flex align-items-center" href="user.jsp">
            <i class="bi bi-cart3 text-warning me-2 fs-3"></i>
            <span class="fs-4">LuvZon</span>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#userNav">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="userNav">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-3">
                <li class="nav-item">
                    <a class="nav-link" href="user.jsp"><i class="bi bi-house-door me-1"></i> Home / Shop</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link active" href="orderHistory.jsp"><i class="bi bi-clock-history me-1"></i> My Order History</a>
                </li>
            </ul>

            <div class="d-flex align-items-center gap-3">
                <div class="text-white text-end d-none d-sm-block">
                    <div class="small text-white-50">Customer</div>
                    <div class="fw-semibold"><i class="bi bi-person-circle text-warning me-1"></i><%= loggedInUser %></div>
                </div>
                <a href="logout.jsp" class="btn btn-outline-light btn-sm rounded-pill px-3">Logout</a>
            </div>
        </div>
    </div>
</nav>

<!-- Page Header -->
<header class="page-header">
    <div class="container">
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
            <div>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-1 small">
                        <li class="breadcrumb-item"><a href="user.jsp" class="text-decoration-none">Home</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Order History</li>
                    </ol>
                </nav>
                <h2 class="fw-bold mb-1"><i class="bi bi-clock-history text-primary me-2"></i>Purchase & Order History</h2>
                <p class="text-muted mb-0">Record of all items purchased by <%= loggedInUser %> (Simulation - No payment taken)</p>
            </div>
            <div>
                <a href="user.jsp" class="btn btn-primary rounded-pill px-4 fw-semibold shadow-sm">
                    <i class="bi bi-bag-plus me-1"></i> Continue Shopping
                </a>
            </div>
        </div>
    </div>
</header>

<div class="container mb-5">
    <!-- Notice Banner -->
    <div class="alert alert-info border-0 rounded-4 shadow-sm d-flex align-items-center mb-4">
        <i class="bi bi-info-circle-fill fs-4 me-3 text-primary"></i>
        <div>
            <strong>Test Environment Notice:</strong> These orders are stored in the database's <code>orders</code> table. No real credit card or payment was processed.
        </div>
    </div>

    <!-- Orders Table Card -->
    <div class="card order-card">
        <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
            <h5 class="mb-0 fw-bold"><i class="bi bi-receipt me-2 text-primary"></i>Orders Ledger</h5>
            <span class="badge bg-secondary rounded-pill" id="orderCountBadge">Loading...</span>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th style="width: 110px;">Order ID</th>
                        <th>Product Ordered</th>
                        <th>Category</th>
                        <th>Price</th>
                        <th>Date & Time</th>
                        <th>Payment Status</th>
                        <th class="text-end" style="width: 120px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    boolean hasOrders = false;
                    while (rs.next()) {
                        hasOrders = true;
                        totalOrders++;
                        int orderId = rs.getInt("id");
                        int pId = rs.getInt("product_id");
                        String pName = rs.getString("product_name");
                        String pCat = rs.getString("category");
                        double pPrice = rs.getDouble("price");
                        totalSpent += pPrice;
                        Timestamp orderDate = rs.getTimestamp("order_date");
                        String status = rs.getString("status");
                %>
                    <tr>
                        <td>
                            <span class="badge bg-light text-dark border fw-bold px-2 py-1">
                                #ORD-<%= orderId %>
                            </span>
                        </td>
                        <td>
                            <div class="fw-bold text-dark"><%= pName %></div>
                            <small class="text-muted">Item Reference #<%= pId %></small>
                        </td>
                        <td>
                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle text-capitalize">
                                <i class="bi <%= getCategoryIcon(pCat) %> me-1"></i><%= pCat %>
                            </span>
                        </td>
                        <td>
                            <span class="fw-bold text-success fs-6">$<%= String.format("%.2f", pPrice) %></span>
                        </td>
                        <td>
                            <div class="text-muted small">
                                <i class="bi bi-calendar-event me-1"></i><%= orderDate != null ? orderDate.toString().substring(0, 16) : "N/A" %>
                            </div>
                        </td>
                        <td>
                            <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1">
                                <i class="bi bi-check-circle me-1"></i><%= (status != null && !status.isEmpty()) ? status : "Placed" %>
                            </span>
                        </td>
                        <td class="text-end">
                            <a href="productDetails.jsp?id=<%= pId %>" class="btn btn-outline-primary btn-sm rounded-pill px-3">
                                View Item
                            </a>
                        </td>
                    </tr>
                <%
                    }
                    if (!hasOrders) {
                %>
                    <tr>
                        <td colspan="7" class="text-center py-5 text-muted">
                            <i class="bi bi-cart-x fs-1 d-block mb-3 text-secondary"></i>
                            <h4 class="fw-bold">No Orders Placed Yet</h4>
                            <p class="text-muted mb-4">You have not ordered any items yet. Explore the shop and push "Buy Now" on any product!</p>
                            <a href="user.jsp" class="btn btn-primary rounded-pill px-4">
                                <i class="bi bi-cart-plus me-1"></i> Start Shopping Now
                            </a>
                        </td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>

        <% if (hasOrders) { %>
        <div class="card-footer bg-light p-3 d-flex justify-content-between align-items-center">
            <div class="text-muted small">
                Showing <strong><%= totalOrders %></strong> orders in your history
            </div>
            <div class="text-end">
                <span class="text-muted small me-2">Total Value Ordered:</span>
                <span class="fw-bold fs-5 text-dark">$<%= String.format("%.2f", totalSpent) %></span>
                <span class="badge bg-success ms-2">Paid: $0.00 (Test)</span>
            </div>
        </div>
        <% } %>
    </div>
</div>

<!-- Footer -->
<footer class="bg-white border-top py-4 text-center text-muted">
    <div class="container">
        <p class="small mb-0">LuvZon E-Commerce Platform &copy; Order History Module</p>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById('orderCountBadge').innerText = '<%= totalOrders %> Orders';
</script>
</body>
</html>
<%
    } catch (Exception e) {
        out.println("<div class='container my-5 alert alert-danger'>Error loading order history: " + e.getMessage() + "</div>");
    } finally {
        closeQuietly(rs);
        closeQuietly(pstmt);
        closeQuietly(conn);
    }
%>
