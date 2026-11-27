<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Invalidate user session
    if (session != null) {
        session.invalidate();
    }
    // Redirect to login page with notice
    response.sendRedirect("login.jsp?logged_out=1");
%>
