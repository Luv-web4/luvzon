<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Forward directly to products.jsp preserving all query parameters (id, category, search)
    request.getRequestDispatcher("products.jsp").forward(request, response);
%>
