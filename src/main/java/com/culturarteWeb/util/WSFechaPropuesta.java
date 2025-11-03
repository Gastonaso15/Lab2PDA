package com.culturarteWeb.util;

import culturarte.servicios.cliente.propuestas.LocalDate;

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
                throw new RuntimeException("No se encontro anio, mes o dia en el LocalDate de WS");
            }

            anioField.setAccessible(true);
            mesField.setAccessible(true);
            diaField.setAccessible(true);
            
            int anio = anioField.getInt(wsFecha);
            int mes = mesField.getInt(wsFecha);
            int dia = diaField.getInt(wsFecha);
            
            return java.time.LocalDate.of(anio, mes, dia);
        } catch (Exception e) {
            throw new RuntimeException("Error convirtiendo WS LocalDate a java.time.LocalDate: " + e.getMessage(), e);
        }
    }

}
