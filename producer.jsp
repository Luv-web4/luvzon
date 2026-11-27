<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db_config.jspf" %>
<%
    // Authentication & Role verification
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    String role = (String) session.getAttribute("role");

    if (loggedInUser == null || !"producer".equalsIgnoreCase(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String alertMessage = "";
    String alertType = "success";

    // Handle Actions: Add, Edit, Delete
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String actionType = request.getParameter("actionType");

        // ------------------ 1. ADD NEW ITEM ------------------
        if ("addItem".equalsIgnoreCase(actionType)) {
            String name = request.getParameter("name");
            String category = request.getParameter("category");
            String priceStr = request.getParameter("price");
            String description = request.getParameter("description");
            String imageUrl = request.getParameter("image_url");

            if (name == null || name.trim().isEmpty() || category == null || priceStr == null) {
                alertMessage = "Product Name, Category, and Price are required!";
                alertType = "danger";
            } else {
                Connection conn = null;
                PreparedStatement pstmt = null;
                try {
                    double price = Double.parseDouble(priceStr);
                    conn = getDBConnection();
                    String sql = "INSERT INTO products (name, category, price, description, producer_username, image_url) VALUES (?, ?, ?, ?, ?, ?)";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, name.trim());
                    pstmt.setString(2, category.trim().toLowerCase());
                    pstmt.setDouble(3, price);
                    pstmt.setString(4, description != null ? description.trim() : "");
                    pstmt.setString(5, loggedInUser);
                    pstmt.setString(6, (imageUrl != null && !imageUrl.trim().isEmpty()) ? imageUrl.trim() : getProductImage(category, null));

                    int rows = pstmt.executeUpdate();
                    if (rows > 0) {
                        alertMessage = "New item '" + name + "' added successfully!";
                        alertType = "success";
                    }
                } catch (NumberFormatException nfe) {
                    alertMessage = "Invalid price format! Please enter a valid number.";
                    alertType = "danger";
                } catch (Exception e) {
                    alertMessage = "Error adding product: " + e.getMessage();
                    alertType = "danger";
                } finally {
                    closeQuietly(pstmt);
                    closeQuietly(conn);
                }
            }
        }
        // ------------------ 2. EDIT ITEM ------------------
        else if ("editItem".equalsIgnoreCase(actionType)) {
            String idStr = request.getParameter("id");
            String name = request.getParameter("name");
            String category = request.getParameter("category");
            String priceStr = request.getParameter("price");
            String description = request.getParameter("description");
            String imageUrl = request.getParameter("image_url");

            if (idStr == null || name == null || category == null || priceStr == null) {
                alertMessage = "Missing required fields to update item.";
                alertType = "danger";
            } else {
                Connection conn = null;
                PreparedStatement pstmt = null;
                try {
                    int id = Integer.parseInt(idStr);
                    double price = Double.parseDouble(priceStr);
                    conn = getDBConnection();
                    String sql = "UPDATE products SET name = ?, category = ?, price = ?, description = ?, image_url = ? WHERE id = ? AND producer_username = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, name.trim());
                    pstmt.setString(2, category.trim().toLowerCase());
                    pstmt.setDouble(3, price);
                    pstmt.setString(4, description != null ? description.trim() : "");
                    pstmt.setString(5, (imageUrl != null && !imageUrl.trim().isEmpty()) ? imageUrl.trim() : getProductImage(category, null));
                    pstmt.setInt(6, id);
                    pstmt.setString(7, loggedInUser);

                    int rows = pstmt.executeUpdate();
                    if (rows > 0) {
                        alertMessage = "Item #" + id + " ('" + name + "') updated successfully!";
                        alertType = "success";
                    } else {
                        alertMessage = "Item not found or you do not have permission to edit it.";
                        alertType = "warning";
                    }
                } catch (Exception e) {
                    alertMessage = "Error updating product: " + e.getMessage();
                    alertType = "danger";
                } finally {
                    closeQuietly(pstmt);
                    closeQuietly(conn);
                }
            }
        }
        // ------------------ 3. DELETE ITEM ------------------
        else if ("deleteItem".equalsIgnoreCase(actionType)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                Connection conn = null;
                PreparedStatement pstmt = null;
                try {
                    int id = Integer.parseInt(idStr);
                    conn = getDBConnection();
                    String sql = "DELETE FROM products WHERE id = ? AND producer_username = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, id);
                    pstmt.setString(2, loggedInUser);

                    int rows = pstmt.executeUpdate();
                    if (rows > 0) {
                        alertMessage = "Item #" + id + " has been successfully deleted.";
                        alertType = "success";
                    } else {
                        alertMessage = "Could not delete item. Verify ownership.";
                        alertType = "warning";
                    }
                } catch (Exception e) {
                    alertMessage = "Error deleting product: " + e.getMessage();
                    alertType = "danger";
                } finally {
                    closeQuietly(pstmt);
                    closeQuietly(conn);
                }
            }
        }
    }

    // Retrieve Producer's Inventory
    Connection fetchConn = null;
    PreparedStatement fetchStmt = null;
    ResultSet rsProducts = null;
    int productCount = 0;
    double totalInventoryValue = 0.0;

    try {
        fetchConn = getDBConnection();
        // Fetch items belonging to this producer (or all items if seller1)
        String query = "SELECT * FROM products WHERE producer_username = ? ORDER BY id DESC";
        fetchStmt = fetchConn.prepareStatement(query);
        fetchStmt.setString(1, loggedInUser);
        rsProducts = fetchStmt.executeQuery();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Producer Dashboard - LuvZon</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --primary-color: #4f46e5;
            --secondary-color: #f59e0b;
        }
        body {
            background-color: #f8fafc;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: #1e293b;
        }
        .navbar-custom {
            background: linear-gradient(135deg, #1e1b4b 0%, #312e81 100%);
        }
        .dashboard-header {
            background: white;
            border-bottom: 1px solid #e2e8f0;
            padding: 1.75rem 0;
            margin-bottom: 2rem;
        }
        .stat-card {
            border: none;
            border-radius: 1rem;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05), 0 2px 4px -2px rgba(0,0,0,0.05);
            transition: transform 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-2px);
        }
        .table-card {
            background: white;
            border-radius: 1rem;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            border: none;
            overflow: hidden;
        }
        .category-badge {
            font-size: 0.75rem;
            padding: 0.35rem 0.65rem;
            border-radius: 20px;
            font-weight: 600;
            text-transform: capitalize;
        }
        .product-thumb {
            width: 50px;
            height: 50px;
            object-fit: cover;
            border-radius: 8px;
        }
        .btn-action {
            width: 32px;
            height: 32px;
            padding: 0;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 6px;
        }
    </style>
</head>
<body>

<!-- Navigation Bar -->
<nav class="navbar navbar-expand-lg navbar-dark navbar-custom shadow-sm sticky-top">
    <div class="container">
        <a class="navbar-brand fw-bold d-flex align-items-center" href="producer.jsp">
            <i class="bi bi-shop text-warning me-2 fs-4"></i>
            <span>LuvZon <span class="badge bg-warning text-dark ms-1" style="font-size: 0.7rem;">PRODUCER</span></span>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navContent">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navContent">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link active" href="producer.jsp"><i class="bi bi-box-seam me-1"></i> Inventory Manager</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="user.jsp" target="_blank"><i class="bi bi-eye me-1"></i> Preview Customer Store</a>
                </li>
            </ul>
            <div class="d-flex align-items-center text-white">
                <div class="me-3 text-end d-none d-sm-block">
                    <div class="small text-white-50">Logged in as</div>
                    <div class="fw-semibold"><i class="bi bi-person-circle me-1 text-warning"></i><%= loggedInUser %></div>
                </div>
                <a href="logout.jsp" class="btn btn-outline-light btn-sm px-3 rounded-pill">
                    <i class="bi bi-box-arrow-right me-1"></i>Logout
                </a>
            </div>
        </div>
    </div>
</nav>

<!-- Page Header & Action Buttons -->
<header class="dashboard-header">
    <div class="container">
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
            <div>
                <h2 class="fw-bold mb-1">Product Inventory</h2>
                <p class="text-muted mb-0">Manage and update your products. Add new items or delete out-of-stock items.</p>
            </div>
            <div>
                <!-- Primary Option 1: New Item Button -->
                <button type="button" class="btn btn-primary px-4 py-2 fw-semibold shadow-sm rounded-pill" data-bs-toggle="modal" data-bs-target="#addItemModal">
                    <i class="bi bi-plus-circle me-1"></i> Add New Product
                </button>
            </div>
        </div>
    </div>
</header>

<div class="container mb-5">
    <!-- Feedback Alerts -->
    <% if (!alertMessage.isEmpty()) { %>
        <div class="alert alert-<%= alertType %> alert-dismissible fade show d-flex align-items-center shadow-sm" role="alert">
            <i class="bi <%= "success".equals(alertType) ? "bi-check-circle-fill" : "bi-exclamation-triangle-fill" %> me-2 fs-5"></i>
            <div><%= alertMessage %></div>
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <!-- Quick Stats -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="card stat-card p-3 bg-white">
                <div class="d-flex align-items-center">
                    <div class="bg-primary-subtle text-primary p-3 rounded-3 me-3 fs-3">
                        <i class="bi bi-boxes"></i>
                    </div>
                    <div>
                        <div class="text-muted small fw-semibold">TOTAL PRODUCTS</div>
                        <h4 class="fw-bold mb-0" id="statProductCount">Loading...</h4>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card stat-card p-3 bg-white">
                <div class="d-flex align-items-center">
                    <div class="bg-success-subtle text-success p-3 rounded-3 me-3 fs-3">
                        <i class="bi bi-grid-3x3-gap"></i>
                    </div>
                    <div>
                        <div class="text-muted small fw-semibold">ACTIVE CATEGORIES</div>
                        <h4 class="fw-bold mb-0">6 Categories</h4>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card stat-card p-3 bg-white">
                <div class="d-flex align-items-center">
                    <div class="bg-warning-subtle text-warning-emphasis p-3 rounded-3 me-3 fs-3">
                        <i class="bi bi-shield-check"></i>
                    </div>
                    <div>
                        <div class="text-muted small fw-semibold">SELLER STATUS</div>
                        <h4 class="fw-bold mb-0 text-success">Verified Active</h4>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Inventory Table Card -->
    <div class="card table-card">
        <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
            <h5 class="mb-0 fw-bold"><i class="bi bi-list-stars me-2 text-primary"></i>Your Listed Items</h5>
            <span class="text-muted small">Only you can edit or delete your products</span>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th style="width: 70px;">Item</th>
                        <th>Product Details</th>
                        <th>Category</th>
                        <th>Price</th>
                        <th>Description</th>
                        <th class="text-end" style="width: 140px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    boolean hasItems = false;
                    while (rsProducts.next()) {
                        hasItems = true;
                        productCount++;
                        int pId = rsProducts.getInt("id");
                        String pName = rsProducts.getString("name");
                        String pCategory = rsProducts.getString("category");
                        double pPrice = rsProducts.getDouble("price");
                        totalInventoryValue += pPrice;
                        String pDesc = rsProducts.getString("description");
                        String pImg = rsProducts.getString("image_url");
                        if (pImg == null || pImg.trim().isEmpty()) {
                            pImg = getProductImage(pCategory, null);
                        }
                %>
                    <tr>
                        <td>
                            <img src="<%= pImg %>" alt="<%= pName %>" class="product-thumb border" onerror="this.src='https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=100&q=80'">
                        </td>
                        <td>
                            <div class="fw-bold text-dark"><%= pName %></div>
                            <small class="text-muted">Item ID: #<%= pId %></small>
                        </td>
                        <td>
                            <span class="category-badge bg-primary-subtle text-primary border border-primary-subtle">
                                <i class="bi <%= getCategoryIcon(pCategory) %> me-1"></i><%= getCategoryDisplayName(pCategory) %>
                            </span>
                        </td>
                        <td>
                            <span class="fw-bold text-success">$<%= String.format("%.2f", pPrice) %></span>
                        </td>
                        <td>
                            <div class="text-muted small text-truncate" style="max-width: 280px;" title="<%= pDesc != null ? pDesc : "" %>">
                                <%= (pDesc != null && !pDesc.isEmpty()) ? pDesc : "<em>No description</em>" %>
                            </div>
                        </td>
                        <td class="text-end">
                            <!-- EDIT BUTTON (opens edit modal with prefilled editable info) -->
                            <button type="button" class="btn btn-outline-primary btn-action me-1" 
                                    title="Edit Product"
                                    onclick="openEditModal(<%= pId %>, '<%= pName.replace("'", "\\'") %>', '<%= pCategory %>', <%= pPrice %>, '<%= pDesc != null ? pDesc.replace("'", "\\'").replace("\n", " ") : "" %>', '<%= pImg.replace("'", "\\'") %>')">
                                <i class="bi bi-pencil-square"></i>
                            </button>

                            <!-- DELETE BUTTON (Option 2: Delete Item) -->
                            <button type="button" class="btn btn-outline-danger btn-action" 
                                    title="Delete Product"
                                    onclick="confirmDelete(<%= pId %>, '<%= pName.replace("'", "\\'") %>')">
                                <i class="bi bi-trash3"></i>
                            </button>
                        </td>
                    </tr>
                <%
                    }
                    if (!hasItems) {
                %>
                    <tr>
                        <td colspan="6" class="text-center py-5 text-muted">
                            <i class="bi bi-inbox fs-1 d-block mb-2 text-secondary"></i>
                            <h5 class="fw-semibold">No products listed yet</h5>
                            <p class="small mb-3">Get started by clicking the "Add New Product" button above.</p>
                            <button type="button" class="btn btn-primary btn-sm rounded-pill px-3" data-bs-toggle="modal" data-bs-target="#addItemModal">
                                <i class="bi bi-plus-circle me-1"></i> Add Your First Item
                            </button>
                        </td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- ================= MODAL 1: ADD NEW ITEM ================= -->
<div class="modal fade" id="addItemModal" tabindex="-1" aria-labelledby="addItemModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form method="POST" action="producer.jsp">
                <input type="hidden" name="actionType" value="addItem">
                
                <div class="modal-header bg-light">
                    <h5 class="modal-title fw-bold" id="addItemModalLabel">
                        <i class="bi bi-plus-circle text-primary me-2"></i>Add New Product
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body p-4">
                    <!-- Product Name -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-secondary">PRODUCT NAME *</label>
                        <input type="text" name="name" class="form-control" placeholder="e.g. Wireless Noise-Canceling Headphones" required>
                    </div>

                    <!-- Category (The 6 specified categories) -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-secondary">CATEGORY *</label>
                        <select name="category" class="form-select" required>
                            <option value="" disabled selected>-- Select One of 6 Categories --</option>
                            <option value="electronics">&#128187; Electronics</option>
                            <option value="medecine">&#128138; Medicine</option>
                            <option value="toys">&#127918; Toys</option>
                            <option value="clothes">&#128085; Clothes</option>
                            <option value="jwells">&#128142; Jewelry (Jwells)</option>
                            <option value="books">&#128218; Books</option>
                        </select>
                    </div>

                    <!-- Price -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-secondary">PRICE ($ USD) *</label>
                        <div class="input-group">
                            <span class="input-group-text">$</span>
                            <input type="number" step="0.01" min="0.01" name="price" class="form-control" placeholder="0.00" required>
                        </div>
                    </div>

                    <!-- Description -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-secondary">DESCRIPTION</label>
                        <textarea name="description" rows="3" class="form-control" placeholder="Enter key features, specs, and details..."></textarea>
                    </div>

                    <!-- Image URL -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-secondary">IMAGE URL (OPTIONAL)</label>
                        <input type="url" name="image_url" class="form-control" placeholder="https://example.com/image.jpg (leave blank for default)">
                    </div>
                </div>

                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary fw-semibold">
                        <i class="bi bi-check-lg me-1"></i> Save & Publish Item
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ================= MODAL 2: EDIT ITEM ================= -->
<div class="modal fade" id="editItemModal" tabindex="-1" aria-labelledby="editItemModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form method="POST" action="producer.jsp">
                <input type="hidden" name="actionType" value="editItem">
                <input type="hidden" name="id" id="edit_id">

                <div class="modal-header bg-light">
                    <h5 class="modal-title fw-bold" id="editItemModalLabel">
                        <i class="bi bi-pencil-square text-primary me-2"></i>Edit Product Details
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body p-4">
                    <!-- Product Name -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-secondary">PRODUCT NAME *</label>
                        <input type="text" name="name" id="edit_name" class="form-control" required>
                    </div>

                    <!-- Category -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-secondary">CATEGORY *</label>
                        <select name="category" id="edit_category" class="form-select" required>
                            <option value="electronics">&#128187; Electronics</option>
                            <option value="medecine">&#128138; Medicine</option>
                            <option value="toys">&#127918; Toys</option>
                            <option value="clothes">&#128085; Clothes</option>
                            <option value="jwells">&#128142; Jewelry (Jwells)</option>
                            <option value="books">&#128218; Books</option>
                        </select>
                    </div>

                    <!-- Price -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-secondary">PRICE ($ USD) *</label>
                        <div class="input-group">
                            <span class="input-group-text">$</span>
                            <input type="number" step="0.01" min="0.01" name="price" id="edit_price" class="form-control" required>
                        </div>
                    </div>

                    <!-- Description -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-secondary">DESCRIPTION</label>
                        <textarea name="description" id="edit_description" rows="3" class="form-control"></textarea>
                    </div>

                    <!-- Image URL -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-secondary">IMAGE URL</label>
                        <input type="url" name="image_url" id="edit_image_url" class="form-control">
                    </div>
                </div>

                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary fw-semibold">
                        <i class="bi bi-save me-1"></i> Update Item
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ================= MODAL 3: DELETE CONFIRMATION ================= -->
<div class="modal fade" id="deleteItemModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content text-center p-3">
            <div class="modal-body">
                <i class="bi bi-exclamation-triangle text-danger" style="font-size: 3rem;"></i>
                <h5 class="fw-bold mt-2">Delete Product?</h5>
                <p class="text-muted small mb-3">Are you sure you want to delete <span id="del_item_name" class="fw-bold text-dark"></span>? This action cannot be undone.</p>
                
                <form method="POST" action="producer.jsp">
                    <input type="hidden" name="actionType" value="deleteItem">
                    <input type="hidden" name="id" id="del_item_id">
                    
                    <div class="d-flex justify-content-center gap-2">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-danger fw-semibold">Delete</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Update live count
    document.getElementById('statProductCount').innerText = '<%= productCount %> Items';

    // Edit Modal Prefill
    function openEditModal(id, name, category, price, description, imageUrl) {
        document.getElementById('edit_id').value = id;
        document.getElementById('edit_name').value = name;
        document.getElementById('edit_category').value = category.toLowerCase();
        document.getElementById('edit_price').value = price;
        document.getElementById('edit_description').value = description;
        document.getElementById('edit_image_url').value = imageUrl;

        var editModal = new bootstrap.Modal(document.getElementById('editItemModal'));
        editModal.show();
    }

    // Delete Modal Prefill
    function confirmDelete(id, name) {
        document.getElementById('del_item_id').value = id;
        document.getElementById('del_item_name').innerText = name;

        var deleteModal = new bootstrap.Modal(document.getElementById('deleteItemModal'));
        deleteModal.show();
    }
</script>
</body>
</html>
<%
    } catch (Exception e) {
        out.println("<div class='container my-5 alert alert-danger'>Error: " + e.getMessage() + "</div>");
    } finally {
        closeQuietly(rsProducts);
        closeQuietly(fetchStmt);
        closeQuietly(fetchConn);
    }
%>
