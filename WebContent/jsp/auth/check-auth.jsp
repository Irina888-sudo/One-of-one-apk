
<%
    if (session == null || session.getAttribute("userNom") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
%>
