package com.culturarteWeb.util;

import culturarte.servicios.cliente.propuestas.LocalDate;
import culturarte.servicios.cliente.propuestas.LocalDateWS;
import culturarte.servicios.cliente.propuestas.LocalDateTime;
import culturarte.servicios.cliente.propuestas.LocalDateTimeWS;

public class WSFechaPropuesta {
    public static LocalDateWS toWSLocalDateWS(java.time.LocalDate fecha) {
        if (fecha == null) return null;
        LocalDateWS wsFecha = new LocalDateWS();
        wsFecha.setAnio(fecha.getYear());
        wsFecha.setMes(fecha.getMonthValue());
        wsFecha.setDia(fecha.getDayOfMonth());
        return wsFecha;
    }

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

    public static LocalDate toWSLocalDate(java.time.LocalDate fecha) {
        if (fecha == null) return null;
        LocalDate wsFecha = new LocalDate();
        wsFecha.anio = fecha.getYear();
        wsFecha.mes = fecha.getMonthValue();
        wsFecha.dia = fecha.getDayOfMonth();
        return wsFecha;
    }

    public static java.time.LocalDate toJavaLocalDate(LocalDate wsFecha) {
        return toJavaLocalDate(wsFecha, null, null);
    }

    public static java.time.LocalDate toJavaLocalDate(LocalDate wsFecha, Object parentObject, String fieldName) {
        if (wsFecha == null) {
            return null;
        }
        try {
            try {
                wsFecha.getAnio();
                wsFecha.getMes();
                wsFecha.getDia();
            } catch (NoSuchMethodError | Exception e) {
                System.out.println("ERROR CRITICO: La clase LocalDate generada vacía está siendo usada!");
                System.out.println("ERROR CRITICO: Clase: " + wsFecha.getClass().getName());
                return null;
            }

            int anio = wsFecha.getAnio();
            int mes = wsFecha.getMes();
            int dia = wsFecha.getDia();

            if ((anio == 0 || mes == 0 || dia == 0) && (wsFecha.anio != 0 || wsFecha.mes != 0 || wsFecha.dia != 0)) {
                anio = wsFecha.anio;
                mes = wsFecha.mes;
                dia = wsFecha.dia;
            }

            if (anio == 0 || mes == 0 || dia == 0) {
                if (parentObject != null && fieldName != null) {
                    try {
                        System.out.println("DEBUG: Intentando obtener fecha desde objeto padre: " + parentObject.getClass().getName() + ", campo: " + fieldName);
                    } catch (Exception e) {
                        System.out.println("DEBUG: Error al intentar obtener fecha desde objeto padre: " + e.getMessage());
                    }
                }

                System.out.println("WARNING: LocalDate campos vacíos - anio=" + anio + ", mes=" + mes + ", dia=" + dia);
                System.out.println("WARNING: El servicio web está enviando la fecha como string simple.");
                System.out.println("WARNING: Solución: El servicio web (Lab1PDA) debe usar un adaptador JAXB para serializar LocalDate correctamente.");
                
                return null;
            }

            if (anio < 1900 || anio > 2100) {
                System.out.println("WARNING: LocalDate tiene un año inválido: " + anio);
                return null;
            }

            if (mes < 1 || mes > 12 || dia < 1 || dia > 31) {
                System.out.println("WARNING: LocalDate tiene valores inválidos - anio=" + anio + ", mes=" + mes + ", dia=" + dia);
                return null;
            }
            
            return java.time.LocalDate.of(anio, mes, dia);
        } catch (Exception e) {
            System.out.println("ERROR: Excepción al convertir LocalDate: " + e.getMessage());
            System.out.println("ERROR: Clase de wsFecha: " + wsFecha.getClass().getName());
            e.printStackTrace();
            return null;
        }
    }

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
