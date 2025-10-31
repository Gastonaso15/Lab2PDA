package com.culturarteWeb.util;

import jakarta.xml.bind.annotation.adapters.XmlAdapter;
import java.time.LocalDate;

public class AdaptadorLocalDate extends XmlAdapter<AdaptadorLocalDate.LocalDateWS, LocalDate> {

    public static class LocalDateWS {
        public int anio;
        public int mes;
        public int dia;
    }

    @Override
    public LocalDate unmarshal(LocalDateWS v) throws Exception {
        if (v == null) return null;
        return LocalDate.of(v.anio, v.mes, v.dia);
    }

    @Override
    public LocalDateWS marshal(LocalDate v) throws Exception {
        if (v == null) return null;
        LocalDateWS ws = new LocalDateWS();
        ws.anio = v.getYear();
        ws.mes = v.getMonthValue();
        ws.dia = v.getDayOfMonth();
        return ws;
    }
}
