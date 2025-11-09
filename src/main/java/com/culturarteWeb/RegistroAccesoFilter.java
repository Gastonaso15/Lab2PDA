package com.culturarteWeb;

import culturarte.servicios.cliente.usuario.IUsuarioControllerWS;
import culturarte.servicios.cliente.usuario.UsuarioWSEndpointService;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;

import java.io.IOException;

@WebFilter(filterName = "RegistroAccesoFilter", urlPatterns = {"/*"})
public class RegistroAccesoFilter implements Filter {
    private IUsuarioControllerWS IUC;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        try {
            UsuarioWSEndpointService servicio = new UsuarioWSEndpointService();
            IUC = servicio.getUsuarioWSEndpointPort();
        } catch (Exception e) {
            throw new ServletException("Error al inicializar Web Services", e);
        }
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        if (request instanceof HttpServletRequest) {
            HttpServletRequest httpRequest = (HttpServletRequest) request;

            String ip = obtenerIpCliente(httpRequest);
            String url = httpRequest.getRequestURL().toString();
            String queryString = httpRequest.getQueryString();
            if (queryString != null) {
                url += "?" + queryString;
            }

            String userAgent = httpRequest.getHeader("User-Agent");
            String browser = extraerBrowser(userAgent);
            String sistemaOperativo = extraerSistemaOperativo(userAgent);

            try {
                IUC.registrarAcceso(ip, url, browser, sistemaOperativo);
            } catch (Exception e) {
                System.err.println("Error registrando acceso: " + e.getMessage());
            }
        }

        chain.doFilter(request, response);
    }

    private String obtenerIpCliente(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        return ip;
    }

    private String extraerBrowser(String userAgent) {
        if (userAgent == null) return "Desconocido";

        if (userAgent.contains("Edg")) return "Edge";
        if (userAgent.contains("Firefox")) return "Firefox";
        if (userAgent.contains("Safari") && !userAgent.contains("Chrome")) return "Safari";
        if (userAgent.contains("Opera") || userAgent.contains("OPR")) return "Opera";
        if (userAgent.contains("Chrome")) return "Chrome";

        return "Otro";
    }

    private String extraerSistemaOperativo(String userAgent) {
        if (userAgent == null) return "Desconocido";

        if (userAgent.contains("Windows")) return "Windows";
        if (userAgent.contains("Mac OS")) return "macOS";
        if (userAgent.contains("Android")) return "Android";
        if (userAgent.contains("iPhone") || userAgent.contains("iPad")) return "iOS";
        if (userAgent.contains("Linux")) return "Linux";

        return "Otro";
    }
}