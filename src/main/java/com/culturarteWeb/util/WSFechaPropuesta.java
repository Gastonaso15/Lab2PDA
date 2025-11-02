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

}
