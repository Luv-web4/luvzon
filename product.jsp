<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Forward directly to productDetails.jsp preserving the id parameter
    request.getRequestDispatcher("productDetails.jsp").forward(request, response);
%>
