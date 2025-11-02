package com.culturarteWeb.util;

import culturarte.servicios.cliente.usuario.LocalDate;

public class WSFechaUsuario {
    public static LocalDate toWSLocalDate(java.time.LocalDate fecha) {
        if (fecha == null) return null;
        LocalDate wsFecha = new LocalDate() {
            public int anio = fecha.getYear();
            public int mes = fecha.getMonthValue();
            public int dia = fecha.getDayOfMonth();
        };
        return wsFecha;
    }
}
