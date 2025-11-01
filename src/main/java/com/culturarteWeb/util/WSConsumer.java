package com.culturarteWeb.util;

import com.culturarteWeb.ws.propuestas.PropuestaWSEndpointService;
import com.culturarteWeb.ws.propuestas.IPropuestaControllerWS;
import com.culturarteWeb.ws.usuarios.UsuarioWSEndpointService;
import com.culturarteWeb.ws.usuarios.IUsuarioControllerWS;

import jakarta.xml.ws.BindingProvider;

import java.io.InputStream;
import java.net.URL;
import java.util.Map;
import java.util.Properties;

public final class WSConsumer {
    private static volatile WSConsumer I;

    private final String baseUrl;
    private final PropuestaWSEndpointService propService;
    private final UsuarioWSEndpointService   userService;

    private WSConsumer() {
        String base = "http://127.0.0.1:9128/culturarteWS";

        base = System.getProperty("central.ws.url",
                System.getenv().getOrDefault("CENTRAL_WS_URL", base));

        if ("http://127.0.0.1:9128/culturarteWS".equals(base)) {
            try (InputStream in = Thread.currentThread()
                    .getContextClassLoader().getResourceAsStream("web.properties")) {
                if (in != null) {
                    Properties p = new Properties();
                    p.load(in);
                    base = p.getProperty("central.ws.url", base);
                }
            } catch (Exception ignored) {}
        }

        this.baseUrl = base;
        try {
            propService = new PropuestaWSEndpointService(new URL(baseUrl + "/propuestas?wsdl"));
            userService = new UsuarioWSEndpointService(new URL(baseUrl + "/usuarios?wsdl"));
        } catch (Exception e) {
            throw new RuntimeException("No pude inicializar los Services SOAP", e);
        }
    }

    public static WSConsumer get() {
        if (I == null) synchronized (WSConsumer.class) {
            if (I == null) I = new WSConsumer();
        }
        return I;
    }

    // Devulevo el port
    public IPropuestaControllerWS propuestas() {
        IPropuestaControllerWS port = propService.getPropuestaWSEndpointPort();
        tune((BindingProvider) port, baseUrl + "/propuestas");
        return port;
    }

    public IUsuarioControllerWS usuarios() {
        IUsuarioControllerWS port = userService.getUsuarioWSEndpointPort();
        tune((BindingProvider) port, baseUrl + "/usuarios");
        return port;
    }

    private void tune(BindingProvider bp, String endpoint) {
        Map<String,Object> ctx = bp.getRequestContext();
        ctx.put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, endpoint);
        ctx.put("com.sun.xml.ws.connect.timeout", 4000);
        ctx.put("com.sun.xml.ws.request.timeout", 8000);
    }
}