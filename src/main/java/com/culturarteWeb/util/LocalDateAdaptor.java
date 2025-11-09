package com.culturarteWeb.util;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public final  class LocalDateAdaptor {
    public static final DateTimeFormatter DMY = DateTimeFormatter.ofPattern("dd-MM-uuuu");
    private LocalDateAdaptor(){}
    public static LocalDate parseOrNull(String s){
        return (s==null || s.isEmpty()) ? null : LocalDate.parse(s, DMY);
    }
}





