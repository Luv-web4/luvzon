<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="db_config.jspf" %>
<%
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect("user.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement findStmt = null;
    PreparedStatement insertStmt = null;
    ResultSet rs = null;

    try {
        int productId = Integer.parseInt(idStr.trim());
        conn = getDBConnection();

        // 1. Fetch item details
        findStmt = conn.prepareStatement("SELECT * FROM products WHERE id = ?");
        findStmt.setInt(1, productId);
        rs = findStmt.executeQuery();

        if (rs.next()) {
            String pName = rs.getString("name");
            String pCat = rs.getString("category");
            double pPrice = rs.getDouble("price");

            // 2. Insert into orders table (Table 3)
            String orderSql = "INSERT INTO orders (username, product_id, product_name, category, price, status) VALUES (?, ?, ?, ?, ?, ?)";
            insertStmt = conn.prepareStatement(orderSql);
            insertStmt.setString(1, loggedInUser);
            insertStmt.setInt(2, productId);
            insertStmt.setString(3, pName);
            insertStmt.setString(4, pCat);
            insertStmt.setDouble(5, pPrice);
            insertStmt.setString(6, "Placed (No Payment Taken)");

            int rows = insertStmt.executeUpdate();
            if (rows > 0) {
                // Redirect to product details with purchase flag, or to orderHistory
                response.sendRedirect("orderHistory.jsp?success=1");
                return;
            }
        }
        response.sendRedirect("user.jsp");
    } catch (Exception e) {
        out.println("Error processing purchase: " + e.getMessage());
    } finally {
        closeQuietly(rs);
        closeQuietly(findStmt);
        closeQuietly(insertStmt);
        closeQuietly(conn);
    }
%>
