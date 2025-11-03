package culturarte.servicios.cliente.propuestas;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;

/**
 * Clase LocalDate personalizada con los campos necesarios para serialización.
 * Esta clase reemplaza la clase vacía generada automáticamente.
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "localDate", propOrder = {
    "anio",
    "mes",
    "dia"
})
public class LocalDate {

    @XmlElement(required = false)
    public int anio;

    @XmlElement(required = false)
    public int mes;

    @XmlElement(required = false)
    public int dia;

    public LocalDate() {
    }

    public LocalDate(int anio, int mes, int dia) {
        this.anio = anio;
        this.mes = mes;
        this.dia = dia;
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

    @Override
    public String toString() {
        return String.format("%04d-%02d-%02d", anio, mes, dia);
    }
}
