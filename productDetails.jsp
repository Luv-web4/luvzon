<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db_config.jspf" %>
<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String idParam = request.getParameter("id");
    if (idParam == null || idParam.trim().isEmpty()) {
        response.sendRedirect("products.jsp");
        return;
    }

    int productId = 0;
    try {
        productId = Integer.parseInt(idParam.trim());
    } catch (NumberFormatException e) {
        response.sendRedirect("products.jsp");
        return;
    }

    String purchaseSuccess = request.getParameter("purchased");
    String errorMessage = "";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // Handle Buy Action when submitted from this page
    if ("POST".equalsIgnoreCase(request.getMethod()) && "buyNow".equalsIgnoreCase(request.getParameter("action"))) {
        Connection buyConn = null;
        PreparedStatement buyStmt = null;
        PreparedStatement infoStmt = null;
        ResultSet rsInfo = null;

        try {
            buyConn = getDBConnection();
            infoStmt = buyConn.prepareStatement("SELECT * FROM products WHERE id = ?");
            infoStmt.setInt(1, productId);
            rsInfo = infoStmt.executeQuery();

            if (rsInfo.next()) {
                String pName = rsInfo.getString("name");
                String pCat = rsInfo.getString("category");
                double pPrice = rsInfo.getDouble("price");

                String insertOrder = "INSERT INTO orders (username, product_id, product_name, category, price, status) VALUES (?, ?, ?, ?, ?, ?)";
                buyStmt = buyConn.prepareStatement(insertOrder);
                buyStmt.setString(1, loggedInUser);
                buyStmt.setInt(2, productId);
                buyStmt.setString(3, pName);
                buyStmt.setString(4, pCat);
                buyStmt.setDouble(5, pPrice);
                buyStmt.setString(6, "Placed (No Payment Taken)");

                int rows = buyStmt.executeUpdate();
                if (rows > 0) {
                    // Redirect to prevent form re-submission
                    response.sendRedirect("productDetails.jsp?id=" + productId + "&purchased=1");
                    return;
                }
            } else {
                errorMessage = "Item not found in inventory!";
            }
        } catch (Exception e) {
            errorMessage = "Order processing error: " + e.getMessage();
        } finally {
            closeQuietly(rsInfo);
            closeQuietly(infoStmt);
            closeQuietly(buyStmt);
            closeQuietly(buyConn);
        }
    }

    try {
        conn = getDBConnection();
        String query = "SELECT * FROM products WHERE id = ?";
        pstmt = conn.prepareStatement(query);
        pstmt.setInt(1, productId);
        rs = pstmt.executeQuery();

        if (!rs.next()) {
            response.sendRedirect("products.jsp");
            return;
        }

        String prodName = rs.getString("name");
        String prodCategory = rs.getString("category");
        double prodPrice = rs.getDouble("price");
        String prodDesc = rs.getString("description");
        String producer = rs.getString("producer_username");
        String prodImg = rs.getString("image_url");
        if (prodImg == null || prodImg.trim().isEmpty()) {
            prodImg = getProductImage(prodCategory, null);
        }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= prodName %> - LuvZon</title>
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
        .product-image-container {
            background: white;
            border-radius: 1.25rem;
            padding: 1.5rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.06);
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            height: 420px;
        }
        .product-main-img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
            border-radius: 0.75rem;
        }
        .details-card {
            background: white;
            border-radius: 1.25rem;
            padding: 2.25rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.06);
            height: 100%;
            display: flex;
            flex-direction: column;
        }
        .price-badge-lg {
            font-size: 2.25rem;
            font-weight: 800;
            color: #4f46e5;
        }
        .btn-buy-now {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            border: none;
            color: white;
            font-size: 1.15rem;
            font-weight: 700;
            padding: 0.9rem 2rem;
            border-radius: 50px;
            box-shadow: 0 8px 20px rgba(16, 185, 129, 0.35);
            transition: all 0.2s ease;
        }
        .btn-buy-now:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 25px rgba(16, 185, 129, 0.45);
            color: white;
        }
        .security-badge {
            background: #f1f5f9;
            border-radius: 0.75rem;
            padding: 1rem;
            margin-top: 1.5rem;
        }
        .related-card {
            background: white;
            border-radius: 0.75rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
            transition: transform 0.2s;
            overflow: hidden;
            border: none;
        }
        .related-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 16px rgba(0,0,0,0.08);
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
            <ul class="navbar-nav ms-auto mb-2 mb-lg-0 align-items-center">
                <li class="nav-item">
                    <a class="nav-link" href="user.jsp"><i class="bi bi-house me-1"></i> Home</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="products.jsp?id=<%= prodCategory %>">
                        <i class="bi <%= getCategoryIcon(prodCategory) %> me-1"></i> <%= getCategoryDisplayName(prodCategory) %>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="orderHistory.jsp"><i class="bi bi-clock-history me-1"></i> Order History</a>
                </li>
                <li class="nav-item ms-lg-2">
                    <a href="logout.jsp" class="btn btn-outline-light btn-sm rounded-pill px-3">Logout</a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<div class="container my-4">
    <!-- Breadcrumbs -->
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="user.jsp" class="text-decoration-none">Home</a></li>
            <li class="breadcrumb-item"><a href="products.jsp?id=<%= prodCategory %>" class="text-decoration-none"><%= getCategoryDisplayName(prodCategory) %></a></li>
            <li class="breadcrumb-item active text-truncate" style="max-width: 300px;" aria-current="page"><%= prodName %></li>
        </ol>
    </nav>

    <!-- Success Alert when Order is placed -->
    <% if ("1".equals(purchaseSuccess)) { %>
        <div class="alert alert-success alert-dismissible fade show p-4 rounded-4 shadow-sm mb-4" role="alert">
            <div class="d-flex align-items-center">
                <div class="bg-success text-white rounded-circle p-3 me-3 fs-3 d-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                    <i class="bi bi-check-lg"></i>
                </div>
                <div>
                    <h5 class="fw-bold mb-1">Order Placed Successfully!</h5>
                    <p class="mb-0 text-success-emphasis">
                        Your test purchase for <strong><%= prodName %></strong> ($<%= String.format("%.2f", prodPrice) %>) has been confirmed and added to your <strong>Order History</strong>. No actual payment was taken!
                    </p>
                </div>
            </div>
            <div class="mt-3 ps-5">
                <a href="orderHistory.jsp" class="btn btn-success btn-sm rounded-pill px-3 me-2 fw-semibold">
                    <i class="bi bi-clock-history me-1"></i> View in Order History
                </a>
                <a href="user.jsp" class="btn btn-outline-success btn-sm rounded-pill px-3">
                    Continue Shopping
                </a>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <% if (!errorMessage.isEmpty()) { %>
        <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i><%= errorMessage %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <!-- Main Product View: Image on Left, Details & Buy Option on Right -->
    <div class="row g-4 mb-5">
        <!-- Product Image -->
        <div class="col-lg-6">
            <div class="product-image-container">
                <img src="<%= prodImg %>" alt="<%= prodName %>" class="product-main-img" onerror="this.src='https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=600&q=80'">
            </div>
        </div>

        <!-- Product Details & Buy Form -->
        <div class="col-lg-6">
            <div class="details-card">
                <!-- Department / Category Badge -->
                <div class="d-flex align-items-center gap-2 mb-2">
                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-3 py-2 rounded-pill fw-semibold text-uppercase" style="font-size: 0.8rem;">
                        <i class="bi <%= getCategoryIcon(prodCategory) %> me-1"></i> <%= getCategoryDisplayName(prodCategory) %>
                    </span>
                    <span class="badge bg-light text-secondary border px-3 py-2 rounded-pill">
                        Item #<%= productId %>
                    </span>
                </div>

                <!-- Product Name -->
                <h2 class="fw-bold text-dark mb-2"><%= prodName %></h2>

                <!-- Producer Info -->
                <div class="text-muted small mb-3">
                    Sold and shipped by: <strong class="text-dark"><i class="bi bi-shop me-1 text-warning"></i><%= producer %></strong>
                </div>

                <!-- Price Tag -->
                <div class="mb-3">
                    <span class="price-badge-lg">$<%= String.format("%.2f", prodPrice) %></span>
                    <span class="text-muted small ms-2">(Taxes and shipping included)</span>
                </div>

                <!-- Description -->
                <div class="mb-4">
                    <h6 class="fw-bold text-secondary text-uppercase small">Description</h6>
                    <p class="text-muted leading-relaxed" style="font-size: 1.05rem; line-height: 1.6;">
                        <%= (prodDesc != null && !prodDesc.trim().isEmpty()) ? prodDesc : "No detailed description provided for this product." %>
                    </p>
                </div>

                <!-- BUY BUTTON (Requirement: "shows buy option which if user push it adds it his order history but no payment is taken") -->
                <div class="mt-auto">
                    <form method="POST" action="productDetails.jsp?id=<%= productId %>">
                        <input type="hidden" name="action" value="buyNow">
                        
                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-buy-now d-flex align-items-center justify-content-center">
                                <i class="bi bi-cart-check-fill me-2 fs-4"></i> Buy Now (Test Order)
                            </button>
                        </div>
                    </form>

                    <!-- Free / No Payment Simulation Notice -->
                    <div class="security-badge d-flex align-items-center gap-3">
                        <div class="text-success fs-3">
                            <i class="bi bi-shield-check"></i>
                        </div>
                        <div class="small text-muted">
                            <div class="fw-bold text-dark">Zero Payment Simulation</div>
                            <span>No credit card or real money is charged. Clicking <strong>Buy Now</strong> instantly records the product into your personal order history.</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Related Products from Same Category -->
    <div class="pt-4 border-top">
        <h4 class="fw-bold mb-4">More in <%= getCategoryDisplayName(prodCategory) %></h4>
        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-4 g-3">
        <%
            Connection relConn = null;
            PreparedStatement relStmt = null;
            ResultSet rsRel = null;
            try {
                relConn = getDBConnection();
                String relSql = "SELECT * FROM products WHERE category = ? AND id != ? LIMIT 4";
                relStmt = relConn.prepareStatement(relSql);
                relStmt.setString(1, prodCategory);
                relStmt.setInt(2, productId);
                rsRel = relStmt.executeQuery();

                boolean foundRel = false;
                while (rsRel.next()) {
                    foundRel = true;
                    int rId = rsRel.getInt("id");
                    String rName = rsRel.getString("name");
                    double rPrice = rsRel.getDouble("price");
                    String rImg = rsRel.getString("image_url");
                    if (rImg == null || rImg.trim().isEmpty()) {
                        rImg = getProductImage(prodCategory, null);
                    }
        %>
            <div class="col">
                <div class="card related-card h-100">
                    <div style="height: 140px; overflow: hidden; background: #f8fafc;">
                        <img src="<%= rImg %>" alt="<%= rName %>" class="w-100 h-100" style="object-fit: cover;" onerror="this.src='https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=300&q=80'">
                    </div>
                    <div class="p-3 d-flex flex-column flex-grow-1">
                        <h6 class="fw-bold text-truncate mb-1" title="<%= rName %>"><%= rName %></h6>
                        <div class="text-primary fw-bold mt-auto mb-2">$<%= String.format("%.2f", rPrice) %></div>
                        <a href="productDetails.jsp?id=<%= rId %>" class="btn btn-outline-primary btn-sm rounded-pill w-100">View</a>
                    </div>
                </div>
            </div>
        <%
                }
                if (!foundRel) {
        %>
            <div class="col-12 text-muted small">No other items in this category yet.</div>
        <%
                }
            } catch (Exception ignored) {
            } finally {
                closeQuietly(rsRel);
                closeQuietly(relStmt);
                closeQuietly(relConn);
            }
        %>
        </div>
    </div>
</div>

<!-- Footer -->
<footer class="bg-white border-top py-4 text-center text-muted mt-5">
    <div class="container">
        <p class="small mb-0">LuvZon E-Commerce Platform &bull; Apache Tomcat JSP Web Application</p>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
<%
    } catch (Exception e) {
        out.println("<div class='container my-5 alert alert-danger'>Error loading product: " + e.getMessage() + "</div>");
    } finally {
        closeQuietly(rs);
        closeQuietly(pstmt);
        closeQuietly(conn);
    }
%>
