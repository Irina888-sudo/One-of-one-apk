<%@ page language="java" contentType="application/octet-stream" pageEncoding="UTF-8"%>
<%@ page import="java.io.*" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%
    String name = request.getParameter("name");

    if (name == null || name.isEmpty() ||
        name.contains("..") || name.contains("/") || name.contains("\\")) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        return;
    }

    File imageFile = new File("C:\\assets\\img", name);

    if (!imageFile.exists() || !imageFile.isFile()) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
        return;
    }

    String mimeType = application.getMimeType(imageFile.getName());
    if (mimeType == null) {
        mimeType = "application/octet-stream";
    }

    response.setContentType(mimeType);
    response.setContentLengthLong(imageFile.length());

    try (BufferedInputStream in = new BufferedInputStream(new FileInputStream(imageFile));
         BufferedOutputStream out = new BufferedOutputStream(response.getOutputStream())) {

        byte[] buffer = new byte[8192];
        int len;

        while ((len = in.read(buffer)) != -1) {
            out.write(buffer, 0, len);
        }
    }
%>