<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // If already logged in, route to appropriate dashboard; otherwise route to login.jsp
    String loggedInUser = (String) session.getAttribute("loggedInUser");
    String role = (String) session.getAttribute("role");

    if (loggedInUser != null && role != null) {
        if ("producer".equalsIgnoreCase(role)) {
            response.sendRedirect("producer.jsp");
        } else {
            response.sendRedirect("user.jsp");
        }
    } else {
        response.sendRedirect("login.jsp");
    }
%>
