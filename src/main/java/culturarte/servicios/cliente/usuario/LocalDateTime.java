package culturarte.servicios.cliente.usuario;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;

/**
 * Clase LocalDateTime personalizada con los campos necesarios para serialización.
 * Esta clase reemplaza la clase vacía generada automáticamente.
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "localDateTime", propOrder = {
    "anio",
    "mes",
    "dia",
    "hora",
    "minuto",
    "segundo",
    "nanosegundo"
})
public class LocalDateTime {

    @XmlElement(required = true)
    public int anio;

    @XmlElement(required = true)
    public int mes;

    @XmlElement(required = true)
    public int dia;

    @XmlElement(required = true)
    public int hora;

    @XmlElement(required = true)
    public int minuto;

    @XmlElement(required = true)
    public int segundo;

    @XmlElement(required = false)
    public int nanosegundo;

    public LocalDateTime() {
    }

    public LocalDateTime(int anio, int mes, int dia, int hora, int minuto, int segundo, int nanosegundo) {
        this.anio = anio;
        this.mes = mes;
        this.dia = dia;
        this.hora = hora;
        this.minuto = minuto;
        this.segundo = segundo;
        this.nanosegundo = nanosegundo;
    }

    public int getAnio() {
        return anio;
    }

    public void setAnio(int anio) {
        this.anio = anio;
    }

    public int getMes() {
        return mes;
    }

    public void setMes(int mes) {
        this.mes = mes;
    }

    public int getDia() {
        return dia;
    }

    public void setDia(int dia) {
        this.dia = dia;
    }

    public int getHora() {
        return hora;
    }

    public void setHora(int hora) {
        this.hora = hora;
    }

    public int getMinuto() {
        return minuto;
    }

    public void setMinuto(int minuto) {
        this.minuto = minuto;
    }

    public int getSegundo() {
        return segundo;
    }

    public void setSegundo(int segundo) {
        this.segundo = segundo;
    }

    public int getNanosegundo() {
        return nanosegundo;
    }

    public void setNanosegundo(int nanosegundo) {
        this.nanosegundo = nanosegundo;
    }

    @Override
    public String toString() {
        return String.format("%04d-%02d-%02d %02d:%02d:%02d", anio, mes, dia, hora, minuto, segundo);
    }
}





