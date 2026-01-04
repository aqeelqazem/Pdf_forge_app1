
# Blueprint: PDF Genius

## Visión General

PDF Genius es una aplicación móvil diseñada para permitir a los usuarios crear documentos PDF de alta calidad a partir de sus imágenes de forma rápida y sencilla. La aplicación se centra en un flujo de trabajo intuitivo, desde la selección de imágenes y la edición hasta la generación del PDF final.

## Características Implementadas

### Funcionalidad Principal

*   **Selección de Imágenes**: Los usuarios pueden seleccionar múltiples imágenes de la galería de su dispositivo.
*   **Gestión de Estado Centralizada**: Se utiliza `ImageCubit` (basado en `flutter_bloc`) para gestionar el estado de las imágenes seleccionadas.
*   **Previsualización y Reordenación**: Una pantalla (`ImageDisplayScreen`) muestra las imágenes seleccionadas en una cuadrícula donde los usuarios pueden:
    *   Reordenar las imágenes arrastrándolas.
    *   Eliminar imágenes individualmente.
    *   Añadir más imágenes a la sesión actual.
    *   Limpiar todas las imágenes para iniciar una nueva sesión.
*   **Generación de PDF**: Los usuarios pueden crear y compartir un documento PDF a partir de las imágenes seleccionadas.
*   **Navegación Robusta**: Se utiliza `go_router` para la navegación, con redirecciones automáticas para garantizar una experiencia de usuario fluida.
*   **Persistencia de Sesión**: La aplicación guarda automáticamente el estado de la sesión (imágenes seleccionadas y su orden), permitiendo a los usuarios continuar donde lo dejaron.

### Editor de Imágenes (Interfaz Integrada Avanzada)

*   **Edición Integrada**: La funcionalidad de edición ha sido completamente rediseñada para una experiencia de usuario superior. En lugar de una herramienta externa, el editor de imágenes ahora es una parte integral de la pantalla de edición.
*   **Paquete Utilizado**: Se reemplazó `image_cropper` por `crop_your_image`, que permite incrustar el editor directamente en la interfaz de usuario.
*   **Interfaz de Edición**:
    *   **Visor de Recorte Activo**: La imagen principal se muestra con un cuadro de recorte activo superpuesto, permitiendo al usuario ver y ajustar el área de recorte en tiempo real.
    *   **Barra de Miniaturas**: Se mantiene la barra de miniaturas en la parte inferior para una navegación rápida entre las imágenes de la sesión.
*   **Herramientas de Edición**:
    *   **Recortar (Crop)**: El usuario puede aplicar el recorte directamente presionando un botón ("Apply Crop"), y la imagen se actualiza en el mismo lugar.
    *   **Girar (Rotate)**: Se proporcionan botones para girar la imagen a la izquierda y a la derecha de forma instantánea.
*   **Flujo de Trabajo No Destructivo**: Al igual que antes, las modificaciones no alteran los archivos originales. Los cambios se guardan como nuevos datos de imagen (`Uint8List`) dentro del estado de la aplicación.

### Tema y Estilo

*   **Tema General**: La aplicación utiliza `ThemeData` con `ColorScheme.fromSeed` para un esquema de color moderno y consistente. El color principal es `Colors.blueGrey`.
*   **Modo Oscuro/Claro**: Soporte completo para ambos modos, con un botón en la pantalla de "Acerca de" para alternar.
*   **Tipografía**: Se utiliza el paquete `google_fonts` con la fuente "Roboto" para una tipografía limpia y legible.

## Próximos Pasos

Aunque la funcionalidad principal está completa, se podrían considerar las siguientes mejoras en el futuro:

*   **Filtros de Imagen**: Añadir filtros básicos (blanco y negro, sepia, etc.).
*   **Ajustes de Calidad de PDF**: Permitir al usuario elegir la calidad y compresión del PDF.
*   **Mejoras en la Interfaz de Usuario**: Añadir animaciones y transiciones para una experiencia más pulida.
