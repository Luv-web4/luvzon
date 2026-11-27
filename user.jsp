<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db_config.jspf" %>
<%
    // Verify user session
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    String role = (String) session.getAttribute("role");

    if (loggedInUser == null || !"user".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Retrieve order count for navbar badge
    int orderCount = 0;
    Connection countConn = null;
    PreparedStatement countStmt = null;
    ResultSet rsCount = null;
    try {
        countConn = getDBConnection();
        countStmt = countConn.prepareStatement("SELECT COUNT(*) AS total FROM orders WHERE username = ?");
        countStmt.setString(1, loggedInUser);
        rsCount = countStmt.executeQuery();
        if (rsCount.next()) {
            orderCount = rsCount.getInt("total");
        }
    } catch (Exception ignored) {
    } finally {
        closeQuietly(rsCount);
        closeQuietly(countStmt);
        closeQuietly(countConn);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LuvZon - Online Shopping Mall</title>
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
        .hero-section {
            background: linear-gradient(135deg, #4338ca 0%, #6366f1 60%, #a855f7 100%);
            color: white;
            padding: 3.5rem 0 3rem 0;
            border-bottom-left-radius: 2rem;
            border-bottom-right-radius: 2rem;
            box-shadow: 0 10px 25px rgba(67, 56, 202, 0.2);
        }
        .search-box {
            background: white;
            border-radius: 50px;
            padding: 6px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.15);
            max-width: 680px;
            margin: 0 auto;
        }
        .search-input {
            border: none;
            padding-left: 20px;
            outline: none;
            font-size: 1.05rem;
        }
        .search-input:focus {
            box-shadow: none;
        }
        .search-btn {
            border-radius: 50px;
            padding: 10px 28px;
            font-weight: 600;
            background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            border: none;
        }
        .search-btn:hover {
            opacity: 0.95;
        }
        /* 6 Category Icons */
        .category-card {
            background: white;
            border-radius: 1.25rem;
            padding: 1.5rem 1rem;
            text-align: center;
            text-decoration: none;
            color: #1e293b;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            border: 2px solid transparent;
            height: 100%;
        }
        .category-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 12px 25px rgba(79, 70, 229, 0.15);
            border-color: #6366f1;
            color: #4338ca;
        }
        .cat-icon-wrapper {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            margin-bottom: 0.85rem;
            transition: transform 0.25s;
        }
        .category-card:hover .cat-icon-wrapper {
            transform: scale(1.1);
        }
        .cat-electronics { background: #ede9fe; color: #6d28d9; }
        .cat-medecine    { background: #fee2e2; color: #dc2626; }
        .cat-toys        { background: #fef3c7; color: #d97706; }
        .cat-clothes     { background: #e0e7ff; color: #4338ca; }
        .cat-jwells      { background: #fce7f3; color: #be185d; }
        .cat-books       { background: #dcfce7; color: #15803d; }

        .product-card {
            border: none;
            border-radius: 1rem;
            background: white;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            transition: all 0.25s ease;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            height: 100%;
        }
        .product-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 24px rgba(0,0,0,0.1);
        }
        .product-img-wrapper {
            height: 180px;
            overflow: hidden;
            position: relative;
            background: #f1f5f9;
        }
        .product-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.35s ease;
        }
        .product-card:hover .product-img {
            transform: scale(1.05);
        }
        .history-banner {
            background: linear-gradient(135deg, #1e1b4b 0%, #312e81 100%);
            border-radius: 1.25rem;
            color: white;
            padding: 2.5rem;
            box-shadow: 0 10px 25px rgba(30, 27, 75, 0.25);
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
                    <a class="nav-link active" href="user.jsp"><i class="bi bi-house-door me-1"></i> Home</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#categoriesSection"><i class="bi bi-grid me-1"></i> Categories</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#featuredSection"><i class="bi bi-stars me-1"></i> Featured</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="orderHistory.jsp">
                        <i class="bi bi-clock-history me-1"></i> Order History
                        <% if (orderCount > 0) { %>
                            <span class="badge bg-danger rounded-pill ms-1"><%= orderCount %></span>
                        <% } %>
                    </a>
                </li>
            </ul>

            <div class="d-flex align-items-center gap-3">
                <div class="text-white text-end d-none d-sm-block">
                    <div class="small text-white-50">Welcome,</div>
                    <div class="fw-semibold"><i class="bi bi-person-circle text-warning me-1"></i><%= loggedInUser %></div>
                </div>
                <a href="orderHistory.jsp" class="btn btn-warning btn-sm rounded-pill px-3 fw-semibold">
                    <i class="bi bi-bag-check-fill me-1"></i> My Orders
                </a>
                <a href="logout.jsp" class="btn btn-outline-light btn-sm rounded-pill px-3">
                    <i class="bi bi-box-arrow-right me-1"></i> Logout
                </a>
            </div>
        </div>
    </div>
</nav>

<!-- Hero Section with Search -->
<section class="hero-section text-center">
    <div class="container">
        <span class="badge bg-white text-primary px-3 py-2 rounded-pill fw-semibold mb-3">
            <i class="bi bi-lightning-charge-fill text-warning me-1"></i> Discover Quality Products at Unbeatable Prices
        </span>
        <h1 class="display-5 fw-bold mb-3">What are you shopping for today?</h1>
        <p class="lead text-white-50 mb-4">Search through millions of products or browse by category</p>

        <!-- Search Bar (Submits to products.jsp?search=...) -->
        <form action="products.jsp" method="GET" class="search-box d-flex align-items-center">
            <input type="text" name="search" class="form-control search-input" placeholder="Search by product name, keywords or description..." required>
            <button type="submit" class="btn btn-primary search-btn text-white">
                <i class="bi bi-search me-1"></i> Search
            </button>
        </form>
    </div>
</section>

<!-- 6 Categories Section (Below Search as specified) -->
<section class="py-5" id="categoriesSection">
    <div class="container">
        <div class="d-flex justify-content-between align-items-end mb-4">
            <div>
                <span class="text-primary fw-bold text-uppercase small tracking-wide">Explore By Department</span>
                <h2 class="fw-bold mb-0">Shop by Category</h2>
            </div>
            <span class="text-muted small">Click any category icon to view all items</span>
        </div>

        <!-- 6 Icons: electronics, medecine, toys, clothes, jwells, books -->
        <!-- Each category link opens jsp page via query parameter (e.g. products.jsp?id=electronics) -->
        <div class="row row-cols-2 row-cols-md-3 row-cols-lg-6 g-3">
            <!-- 1. Electronics -->
            <div class="col">
                <a href="products.jsp?id=electronics" class="category-card">
                    <div class="cat-icon-wrapper cat-electronics">
                        <i class="bi bi-laptop"></i>
                    </div>
                    <h6 class="fw-bold mb-1">Electronics</h6>
                    <small class="text-muted">Laptops, Audio & Tech</small>
                </a>
            </div>

            <!-- 2. Medicine -->
            <div class="col">
                <a href="products.jsp?id=medecine" class="category-card">
                    <div class="cat-icon-wrapper cat-medecine">
                        <i class="bi bi-capsule"></i>
                    </div>
                    <h6 class="fw-bold mb-1">Medicine</h6>
                    <small class="text-muted">Health, Wellness & First-aid</small>
                </a>
            </div>

            <!-- 3. Toys -->
            <div class="col">
                <a href="products.jsp?id=toys" class="category-card">
                    <div class="cat-icon-wrapper cat-toys">
                        <i class="bi bi-controller"></i>
                    </div>
                    <h6 class="fw-bold mb-1">Toys</h6>
                    <small class="text-muted">Games, Blocks & Plush</small>
                </a>
            </div>

            <!-- 4. Clothes -->
            <div class="col">
                <a href="products.jsp?id=clothes" class="category-card">
                    <div class="cat-icon-wrapper cat-clothes">
                        <i class="bi bi-tag"></i>
                    </div>
                    <h6 class="fw-bold mb-1">Clothes</h6>
                    <small class="text-muted">Shirts, Jeans & Hoodies</small>
                </a>
            </div>

            <!-- 5. Jewelry (Jwells) -->
            <div class="col">
                <a href="products.jsp?id=jwells" class="category-card">
                    <div class="cat-icon-wrapper cat-jwells">
                        <i class="bi bi-gem"></i>
                    </div>
                    <h6 class="fw-bold mb-1">Jewelry (Jwells)</h6>
                    <small class="text-muted">Pendants, Gold & Pearls</small>
                </a>
            </div>

            <!-- 6. Books -->
            <div class="col">
                <a href="products.jsp?id=books" class="category-card">
                    <div class="cat-icon-wrapper cat-books">
                        <i class="bi bi-book"></i>
                    </div>
                    <h6 class="fw-bold mb-1">Books</h6>
                    <small class="text-muted">Fiction, Tech & Non-Fiction</small>
                </a>
            </div>
        </div>
    </div>
</section>

<!-- Featured / Popular Items Grid -->
<section class="py-4 bg-light" id="featuredSection">
    <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <span class="text-primary fw-bold text-uppercase small">Top Picks For You</span>
                <h3 class="fw-bold mb-0">Popular Products</h3>
            </div>
            <a href="products.jsp" class="btn btn-outline-primary btn-sm rounded-pill px-3">
                View All Products <i class="bi bi-arrow-right"></i>
            </a>
        </div>

        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
        <%
            Connection featConn = null;
            PreparedStatement featStmt = null;
            ResultSet rsFeat = null;
            try {
                featConn = getDBConnection();
                String featSql = "SELECT * FROM products ORDER BY id DESC LIMIT 8";
                featStmt = featConn.prepareStatement(featSql);
                rsFeat = featStmt.executeQuery();

                boolean hasProducts = false;
                while (rsFeat.next()) {
                    hasProducts = true;
                    int prodId = rsFeat.getInt("id");
                    String prodName = rsFeat.getString("name");
                    String prodCat = rsFeat.getString("category");
                    double prodPrice = rsFeat.getDouble("price");
                    String prodDesc = rsFeat.getString("description");
                    String prodImg = rsFeat.getString("image_url");
                    if (prodImg == null || prodImg.trim().isEmpty()) {
                        prodImg = getProductImage(prodCat, null);
                    }
        %>
            <div class="col">
                <div class="product-card">
                    <div class="product-img-wrapper">
                        <img src="<%= prodImg %>" alt="<%= prodName %>" class="product-img" onerror="this.src='https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=500&q=80'">
                        <span class="position-absolute top-0 end-0 m-2 badge bg-dark bg-opacity-75 rounded-pill text-capitalize">
                            <%= prodCat %>
                        </span>
                    </div>
                    <div class="p-3 d-flex flex-column flex-grow-1">
                        <h6 class="fw-bold mb-1 text-truncate" title="<%= prodName %>"><%= prodName %></h6>
                        <p class="text-muted small text-truncate mb-2"><%= prodDesc != null ? prodDesc : "" %></p>
                        
                        <div class="mt-auto d-flex justify-content-between align-items-center pt-2 border-top">
                            <div>
                                <span class="fs-5 fw-bold text-primary">$<%= String.format("%.2f", prodPrice) %></span>
                            </div>
                            <!-- Link to Product Details JSP with id query parameter -->
                            <a href="productDetails.jsp?id=<%= prodId %>" class="btn btn-sm btn-outline-primary rounded-pill px-3 fw-semibold">
                                View & Buy
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        <%
                }
                if (!hasProducts) {
        %>
            <div class="col-12 text-center py-5">
                <i class="bi bi-box-seam fs-1 text-muted mb-2 d-block"></i>
                <p class="text-muted">No products available in the database yet.</p>
            </div>
        <%
                }
            } catch (Exception e) {
                out.println("<div class='col-12 alert alert-danger'>Database Error: " + e.getMessage() + "</div>");
            } finally {
                closeQuietly(rsFeat);
                closeQuietly(featStmt);
                closeQuietly(featConn);
            }
        %>
        </div>
    </div>
</section>

<!-- End Section: Order History Banner (As requested: "at end they have order history") -->
<section class="py-5">
    <div class="container">
        <div class="history-banner d-flex flex-column flex-md-row justify-content-between align-items-center gap-4">
            <div>
                <span class="badge bg-warning text-dark px-3 py-1 rounded-pill fw-bold mb-2">
                    <i class="bi bi-bag-check-fill me-1"></i> ORDER TRACKER
                </span>
                <h3 class="fw-bold mb-2">Check Your Purchase History</h3>
                <p class="text-white-50 mb-0" style="max-width: 550px;">
                    Review all items you have purchased during your test session. No actual payment is deducted, and all items are saved in your personal order ledger.
                </p>
            </div>
            <div>
                <a href="orderHistory.jsp" class="btn btn-warning btn-lg px-4 py-2 rounded-pill fw-bold shadow">
                    <i class="bi bi-clock-history me-1"></i> View Order History (<%= orderCount %>)
                </a>
            </div>
        </div>
    </div>
</section>

<!-- Footer -->
<footer class="bg-white border-top py-4 text-center text-muted">
    <div class="container">
        <div class="d-flex justify-content-center align-items-center gap-2 mb-2">
            <i class="bi bi-cart3 text-primary fs-5"></i>
            <span class="fw-bold text-dark">LuvZon E-Commerce Platform</span>
        </div>
        <p class="small mb-0">Academic & Test Project running on Apache Tomcat with JSP, MySQL, Bootstrap & JavaScript.</p>
    </div>
</footer>

<!-- Bootstrap 5 JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
