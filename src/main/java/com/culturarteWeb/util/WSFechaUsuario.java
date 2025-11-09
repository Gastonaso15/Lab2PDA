package com.culturarteWeb.util;

import culturarte.servicios.cliente.usuario.LocalDate;
import culturarte.servicios.cliente.usuario.LocalDateWS;
import culturarte.servicios.cliente.usuario.LocalDateTime;
import culturarte.servicios.cliente.usuario.LocalDateTimeWS;

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
    
    // Conversión a LocalDateTimeWS (nuevo tipo generado desde el adaptador)
    public static LocalDateTimeWS toWSLocalDateTimeWS(java.time.LocalDateTime fecha) {
        if (fecha == null) return null;
        LocalDateTimeWS wsFecha = new LocalDateTimeWS();
        wsFecha.setAnio(fecha.getYear());
        wsFecha.setMes(fecha.getMonthValue());
        wsFecha.setDia(fecha.getDayOfMonth());
        wsFecha.setHora(fecha.getHour());
        wsFecha.setMinuto(fecha.getMinute());
        wsFecha.setSegundo(fecha.getSecond());
        wsFecha.setNanosegundo(fecha.getNano());
        return wsFecha;
    }
    
    // Conversión desde LocalDateTimeWS
    public static java.time.LocalDateTime toJavaLocalDateTime(LocalDateTimeWS wsFecha) {
        if (wsFecha == null) return null;
        try {
            return java.time.LocalDateTime.of(
                wsFecha.getAnio(), wsFecha.getMes(), wsFecha.getDia(),
                wsFecha.getHora(), wsFecha.getMinuto(), wsFecha.getSegundo(),
                wsFecha.getNanosegundo()
            );
        } catch (Exception e) {
            throw new RuntimeException("Error convirtiendo WS LocalDateTimeWS a java.time.LocalDateTime: " + e.getMessage(), e);
        }
    }
    
    // Método legacy para LocalDateTime (mantener compatibilidad)
    public static LocalDateTime toWSLocalDateTime(java.time.LocalDateTime fecha) {
        if (fecha == null) return null;
        LocalDateTime wsFecha = new LocalDateTime();
        wsFecha.anio = fecha.getYear();
        wsFecha.mes = fecha.getMonthValue();
        wsFecha.dia = fecha.getDayOfMonth();
        wsFecha.hora = fecha.getHour();
        wsFecha.minuto = fecha.getMinute();
        wsFecha.segundo = fecha.getSecond();
        wsFecha.nanosegundo = fecha.getNano();
        return wsFecha;
    }

    // Método legacy para LocalDateTime (mantener compatibilidad)
    public static java.time.LocalDateTime toJavaLocalDateTime(LocalDateTime wsFecha) {
        if (wsFecha == null) return null;
        try {
            return java.time.LocalDateTime.of(wsFecha.anio, wsFecha.mes, wsFecha.dia, 
                                               wsFecha.hora, wsFecha.minuto, wsFecha.segundo, 
                                               wsFecha.nanosegundo);
        } catch (Exception e) {
            throw new RuntimeException("Error convirtiendo WS LocalDateTime a java.time.LocalDateTime: " + e.getMessage(), e);
        }
    }
}
