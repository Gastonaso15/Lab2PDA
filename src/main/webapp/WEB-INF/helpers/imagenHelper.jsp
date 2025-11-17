<%!
    /**
     * Helper function para construir la URL de una imagen en el servidor central.
     * Si la imagen es null o vacía, devuelve null.
     * 
     * @param rutaImagen La ruta relativa de la imagen (ej: "uploads/propuestas/ImagenProp123.jpg")
     * @return La URL completa para acceder a la imagen en el servidor central, o null si no hay imagen
     */
    public String getImagenUrl(String rutaImagen) {
        if (rutaImagen == null || rutaImagen.trim().isEmpty()) {
            return null;
        }
        // El servidor de imágenes está en el puerto 9129
        return "http://localhost:9129/imagenes/" + rutaImagen;
    }
%>

