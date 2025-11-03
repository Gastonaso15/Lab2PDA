package com.culturarteWeb.util;

import culturarte.servicios.cliente.usuario.LocalDate;
import culturarte.servicios.cliente.usuario.LocalDateWS;

public class WSFechaUsuario {
    // Conversión a LocalDateWS (nuevo tipo generado desde el adaptador)
    public static LocalDateWS toWSLocalDateWS(java.time.LocalDate fecha) {
        if (fecha == null) return null;
        LocalDateWS wsFecha = new LocalDateWS();
        wsFecha.setAnio(fecha.getYear());
        wsFecha.setMes(fecha.getMonthValue());
        wsFecha.setDia(fecha.getDayOfMonth());
        return wsFecha;
    }
    
    // Conversión desde LocalDateWS
    public static java.time.LocalDate toJavaLocalDate(LocalDateWS wsFecha) {
        if (wsFecha == null) return null;
        try {
            int anio = wsFecha.getAnio();
            int mes = wsFecha.getMes();
            int dia = wsFecha.getDia();
            
            if (anio == 0 || mes == 0 || dia == 0) {
                return null;
            }
            
            if (anio < 1900 || anio > 2100 || mes < 1 || mes > 12 || dia < 1 || dia > 31) {
                return null;
            }
            
            return java.time.LocalDate.of(anio, mes, dia);
        } catch (Exception e) {
            System.out.println("ERROR: Excepción al convertir LocalDateWS: " + e.getMessage());
            return null;
        }
    }
    
    // Método legacy para LocalDate (mantener compatibilidad)
    public static LocalDate toWSLocalDate(java.time.LocalDate fecha) {
        if (fecha == null) return null;
        LocalDate wsFecha = new LocalDate();
        wsFecha.anio = fecha.getYear();
        wsFecha.mes = fecha.getMonthValue();
        wsFecha.dia = fecha.getDayOfMonth();
        return wsFecha;
    }
}
