<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db_config.jspf" %>
<%
    // Ensure session exists
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Read query parameter: supports ?id=electronics or ?category=electronics or ?search=query
    String categoryParam = request.getParameter("id");
    if (categoryParam == null || categoryParam.trim().isEmpty()) {
        categoryParam = request.getParameter("category");
    }
    String searchQuery = request.getParameter("search");

    boolean isSearch = (searchQuery != null && !searchQuery.trim().isEmpty());
    boolean isCategoryFilter = (categoryParam != null && !categoryParam.trim().isEmpty() && !isSearch);

    String pageTitle = "All Products";
    String pageSubtitle = "Explore all available items in the LuvZon store";
    String categoryIcon = "bi-boxes";

    if (isCategoryFilter) {
        pageTitle = getCategoryDisplayName(categoryParam);
        pageSubtitle = "Browsing all items under the '" + pageTitle + "' department";
        categoryIcon = getCategoryIcon(categoryParam);
    } else if (isSearch) {
        pageTitle = "Search Results";
        pageSubtitle = "Showing matching products for: \"" + searchQuery + "\"";
        categoryIcon = "bi-search";
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    int itemCount = 0;

    try {
        conn = getDBConnection();

        if (isCategoryFilter) {
            String sql = "SELECT * FROM products WHERE LOWER(category) = LOWER(?) ORDER BY id DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, categoryParam.trim().toLowerCase());
        } else if (isSearch) {
            String sql = "SELECT * FROM products WHERE LOWER(name) LIKE ? OR LOWER(description) LIKE ? OR LOWER(category) LIKE ? ORDER BY id DESC";
            pstmt = conn.prepareStatement(sql);
            String term = "%" + searchQuery.trim().toLowerCase() + "%";
            pstmt.setString(1, term);
            pstmt.setString(2, term);
            pstmt.setString(3, term);
        } else {
            String sql = "SELECT * FROM products ORDER BY id DESC";
            pstmt = conn.prepareStatement(sql);
        }

        rs = pstmt.executeQuery();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> - LuvZon Store</title>
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
        .catalog-header {
            background: linear-gradient(135deg, #312e81 0%, #4338ca 100%);
            color: white;
            padding: 2.5rem 0;
            margin-bottom: 2rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }
        .category-pill {
            text-decoration: none;
            padding: 8px 18px;
            border-radius: 50px;
            font-size: 0.88rem;
            font-weight: 600;
            background: white;
            color: #475569;
            border: 1px solid #e2e8f0;
            display: inline-flex;
            align-items: center;
            transition: all 0.2s ease;
            white-space: nowrap;
        }
        .category-pill:hover, .category-pill.active {
            background: #4f46e5;
            color: white;
            border-color: #4f46e5;
            box-shadow: 0 4px 10px rgba(79, 70, 229, 0.25);
        }
        .product-card {
            border: none;
            border-radius: 1rem;
            background: white;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            transition: all 0.25s ease;
            display: flex;
            flex-direction: column;
            height: 100%;
            overflow: hidden;
        }
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 24px rgba(0,0,0,0.12);
        }
        .product-img-box {
            height: 200px;
            overflow: hidden;
            background: #f1f5f9;
            position: relative;
        }
        .product-img-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.3s ease;
        }
        .product-card:hover .product-img-box img {
            transform: scale(1.06);
        }
        .price-tag {
            font-size: 1.35rem;
            font-weight: 700;
            color: #4f46e5;
        }
        .btn-view-product {
            background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            border: none;
            color: white;
            font-weight: 600;
            border-radius: 50px;
            padding: 8px 18px;
            transition: all 0.2s;
        }
        .btn-view-product:hover {
            color: white;
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.35);
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
            <form action="products.jsp" method="GET" class="d-flex mx-auto my-2 my-lg-0" style="max-width: 450px; width: 100%;">
                <div class="input-group">
                    <input type="text" name="search" class="form-control rounded-start-pill" placeholder="Search products..." value="<%= isSearch ? searchQuery : "" %>">
                    <button class="btn btn-warning rounded-end-pill px-3" type="submit">
                        <i class="bi bi-search"></i>
                    </button>
                </div>
            </form>

            <ul class="navbar-nav ms-auto mb-2 mb-lg-0 align-items-center">
                <li class="nav-item">
                    <a class="nav-link" href="user.jsp"><i class="bi bi-house me-1"></i> Home</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="orderHistory.jsp"><i class="bi bi-clock-history me-1"></i> Order History</a>
                </li>
                <li class="nav-item ms-lg-2">
                    <a href="logout.jsp" class="btn btn-outline-light btn-sm rounded-pill px-3">
                        <i class="bi bi-box-arrow-right me-1"></i> Logout
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- Page Header / Hero -->
<header class="catalog-header">
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-2 small">
                <li class="breadcrumb-item"><a href="user.jsp" class="text-white-50 text-decoration-none">Home</a></li>
                <li class="breadcrumb-item text-white-50">Department</li>
                <li class="breadcrumb-item active text-white fw-bold" aria-current="page"><%= pageTitle %></li>
            </ol>
        </nav>
        <div class="d-flex align-items-center gap-3">
            <div class="bg-white text-primary p-3 rounded-circle shadow-sm fs-2 d-flex align-items-center justify-content-center" style="width: 65px; height: 65px;">
                <i class="bi <%= categoryIcon %>"></i>
            </div>
            <div>
                <h1 class="fw-bold mb-1"><%= pageTitle %></h1>
                <p class="text-white-50 mb-0"><%= pageSubtitle %></p>
            </div>
        </div>
    </div>
</header>

<div class="container mb-5">
    <!-- Category Switcher Bar -->
    <div class="d-flex align-items-center gap-2 overflow-x-auto pb-3 mb-4">
        <span class="fw-bold text-muted small text-uppercase me-2">Departments:</span>
        <a href="products.jsp" class="category-pill <%= (!isCategoryFilter && !isSearch) ? "active" : "" %>">
            <i class="bi bi-grid-fill me-1"></i> All
        </a>
        <a href="products.jsp?id=electronics" class="category-pill <%= "electronics".equalsIgnoreCase(categoryParam) ? "active" : "" %>">
            <i class="bi bi-laptop me-1"></i> Electronics
        </a>
        <a href="products.jsp?id=medecine" class="category-pill <%= "medecine".equalsIgnoreCase(categoryParam) ? "active" : "" %>">
            <i class="bi bi-capsule me-1"></i> Medicine
        </a>
        <a href="products.jsp?id=toys" class="category-pill <%= "toys".equalsIgnoreCase(categoryParam) ? "active" : "" %>">
            <i class="bi bi-controller me-1"></i> Toys
        </a>
        <a href="products.jsp?id=clothes" class="category-pill <%= "clothes".equalsIgnoreCase(categoryParam) ? "active" : "" %>">
            <i class="bi bi-tag me-1"></i> Clothes
        </a>
        <a href="products.jsp?id=jwells" class="category-pill <%= "jwells".equalsIgnoreCase(categoryParam) ? "active" : "" %>">
            <i class="bi bi-gem me-1"></i> Jewelry (Jwells)
        </a>
        <a href="products.jsp?id=books" class="category-pill <%= "books".equalsIgnoreCase(categoryParam) ? "active" : "" %>">
            <i class="bi bi-book me-1"></i> Books
        </a>
    </div>

    <!-- Product Grid -->
    <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
    <%
        boolean foundAny = false;
        while (rs.next()) {
            foundAny = true;
            itemCount++;
            int prodId = rs.getInt("id");
            String prodName = rs.getString("name");
            String prodCat = rs.getString("category");
            double prodPrice = rs.getDouble("price");
            String prodDesc = rs.getString("description");
            String prodImg = rs.getString("image_url");
            if (prodImg == null || prodImg.trim().isEmpty()) {
                prodImg = getProductImage(prodCat, null);
            }
    %>
        <div class="col">
            <div class="product-card">
                <div class="product-img-box">
                    <img src="<%= prodImg %>" alt="<%= prodName %>" onerror="this.src='https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=500&q=80'">
                    <span class="position-absolute top-0 end-0 m-2 badge bg-dark bg-opacity-75 rounded-pill text-capitalize">
                        <i class="bi <%= getCategoryIcon(prodCat) %> me-1"></i><%= prodCat %>
                    </span>
                </div>
                <div class="p-3 d-flex flex-column flex-grow-1">
                    <h5 class="fw-bold mb-1 text-truncate" title="<%= prodName %>"><%= prodName %></h5>
                    <p class="text-muted small mb-3 flex-grow-1" style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
                        <%= (prodDesc != null && !prodDesc.isEmpty()) ? prodDesc : "No detailed description provided." %>
                    </p>

                    <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                        <div class="price-tag">$<%= String.format("%.2f", prodPrice) %></div>
                        <!-- Link to Product Details page with id query parameter -->
                        <a href="productDetails.jsp?id=<%= prodId %>" class="btn btn-view-product btn-sm">
                            View & Buy <i class="bi bi-arrow-right-short"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    <%
        }
        if (!foundAny) {
    %>
        <div class="col-12 text-center py-5">
            <div class="bg-white p-5 rounded-4 shadow-sm" style="max-width: 500px; margin: 0 auto;">
                <i class="bi bi-search text-muted mb-3" style="font-size: 3.5rem;"></i>
                <h4 class="fw-bold">No Products Found</h4>
                <p class="text-muted mb-4">
                    <% if (isCategoryFilter) { %>
                        No products are currently cataloged under the <strong><%= pageTitle %></strong> category.
                    <% } else if (isSearch) { %>
                        No products matched your search keyword "<strong><%= searchQuery %></strong>".
                    <% } else { %>
                        No products exist in the store inventory yet.
                    <% } %>
                </p>
                <div class="d-flex justify-content-center gap-2">
                    <a href="user.jsp" class="btn btn-primary rounded-pill px-4">
                        <i class="bi bi-house me-1"></i> Return to Main Shop
                    </a>
                    <a href="products.jsp" class="btn btn-outline-secondary rounded-pill px-3">
                        View All Items
                    </a>
                </div>
            </div>
        </div>
    <%
        }
    %>
    </div>
</div>

<!-- Footer -->
<footer class="bg-white border-top py-4 text-center text-muted">
    <div class="container">
        <p class="small mb-0">LuvZon E-Commerce test platform &copy; Powered by JSP, Apache Tomcat, and MySQL</p>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
<%
    } catch (Exception e) {
        out.println("<div class='container my-5 alert alert-danger'>Error: " + e.getMessage() + "</div>");
    } finally {
        closeQuietly(rs);
        closeQuietly(pstmt);
        closeQuietly(conn);
    }
%>
