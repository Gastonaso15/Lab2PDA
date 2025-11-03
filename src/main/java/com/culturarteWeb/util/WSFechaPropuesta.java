package com.culturarteWeb.util;

import culturarte.servicios.cliente.propuestas.LocalDate;
import culturarte.servicios.cliente.propuestas.LocalDateTime;

public class WSFechaPropuesta {
    public static LocalDate toWSLocalDate(java.time.LocalDate fecha) {
        if (fecha == null) return null;
        LocalDate wsFecha = new LocalDate() {
            public int anio = fecha.getYear();
            public int mes = fecha.getMonthValue();
            public int dia = fecha.getDayOfMonth();
        };
        return wsFecha;
    }

    public static java.time.LocalDate toJavaLocalDate(LocalDate wsFecha) {
        if (wsFecha == null) return null;
        try {
            Class<?> clazz = wsFecha.getClass();
            java.lang.reflect.Field anioField = null;
            java.lang.reflect.Field mesField = null;
            java.lang.reflect.Field diaField = null;

            Class<?> currentClass = clazz;
            while (currentClass != null && currentClass != Object.class) {
                try {
                    anioField = currentClass.getDeclaredField("anio");
                    mesField = currentClass.getDeclaredField("mes");
                    diaField = currentClass.getDeclaredField("dia");
                    break;
                } catch (NoSuchFieldException e) {
                    currentClass = currentClass.getSuperclass();
                }
            }
            
            if (anioField == null || mesField == null || diaField == null) {
                return null;
            }

            anioField.setAccessible(true);
            mesField.setAccessible(true);
            diaField.setAccessible(true);
            
            int anio = anioField.getInt(wsFecha);
            int mes = mesField.getInt(wsFecha);
            int dia = diaField.getInt(wsFecha);
            
            return java.time.LocalDate.of(anio, mes, dia);
        } catch (Exception e) {
            return null;
        }
    }

    public static LocalDateTime toWSLocalDateTime(java.time.LocalDateTime fecha) {
        if (fecha == null) return null;
        LocalDateTime wsFecha = new LocalDateTime() {
            public int anio = fecha.getYear();
            public int mes = fecha.getMonthValue();
            public int dia = fecha.getDayOfMonth();
            public int hora = fecha.getHour();
            public int minuto = fecha.getMinute();
            public int segundo = fecha.getSecond();
            public int nanosegundo = fecha.getNano();
        };
        return wsFecha;
    }

    public static java.time.LocalDateTime toJavaLocalDateTime(LocalDateTime wsFecha) {
        if (wsFecha == null) return null;
        try {
            Class<?> clazz = wsFecha.getClass();
            java.lang.reflect.Field anioField = null;
            java.lang.reflect.Field mesField = null;
            java.lang.reflect.Field diaField = null;
            java.lang.reflect.Field horaField = null;
            java.lang.reflect.Field minutoField = null;
            java.lang.reflect.Field segundoField = null;
            java.lang.reflect.Field nanosegundoField = null;

            Class<?> currentClass = clazz;
            while (currentClass != null && currentClass != Object.class) {
                try {
                    anioField = currentClass.getDeclaredField("anio");
                    mesField = currentClass.getDeclaredField("mes");
                    diaField = currentClass.getDeclaredField("dia");
                    horaField = currentClass.getDeclaredField("hora");
                    minutoField = currentClass.getDeclaredField("minuto");
                    segundoField = currentClass.getDeclaredField("segundo");
                    try {
                        nanosegundoField = currentClass.getDeclaredField("nanosegundo");
                    } catch (NoSuchFieldException e) {
                    }
                    break;
                } catch (NoSuchFieldException e) {
                    currentClass = currentClass.getSuperclass();
                }
            }
            
            if (anioField == null || mesField == null || diaField == null || 
                horaField == null || minutoField == null || segundoField == null) {
                throw new RuntimeException("No se encontro anio, mes, dia, hora, minuto o segundo en el LocalDateTime de WS");
            }

            anioField.setAccessible(true);
            mesField.setAccessible(true);
            diaField.setAccessible(true);
            horaField.setAccessible(true);
            minutoField.setAccessible(true);
            segundoField.setAccessible(true);
            if (nanosegundoField != null) {
                nanosegundoField.setAccessible(true);
            }
            
            int anio = anioField.getInt(wsFecha);
            int mes = mesField.getInt(wsFecha);
            int dia = diaField.getInt(wsFecha);
            int hora = horaField.getInt(wsFecha);
            int minuto = minutoField.getInt(wsFecha);
            int segundo = segundoField.getInt(wsFecha);
            int nanosegundo = (nanosegundoField != null) ? nanosegundoField.getInt(wsFecha) : 0;
            
            return java.time.LocalDateTime.of(anio, mes, dia, hora, minuto, segundo, nanosegundo);
        } catch (Exception e) {
            throw new RuntimeException("Error convirtiendo WS LocalDateTime a java.time.LocalDateTime: " + e.getMessage(), e);
        }
    }

}
