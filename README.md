# UniNotas Carpetas

Aplicación móvil desarrollada en Flutter para crear, editar, consultar, eliminar y organizar notas dentro de carpetas personalizadas.

## Descripción

Esta versión elimina por completo las notas compartidas y el flujo de sincronización en la nube. La app ahora trabaja como una libreta local organizada por carpetas: el usuario puede crear categorías como Escuela, Trabajo, Pendientes o Personal, y asignar cada nota a una de ellas.

## Integrantes

- Daniel Morales
- Dilan Bañuelos

## Funcionalidades principales

- Pantalla de inicio con escudo de la Universidad de Sonora, nombre de la app e integrantes.
- Lista de notas guardadas en el dispositivo.
- Creación de notas con título obligatorio, contenido opcional, color y carpeta.
- Edición de título, contenido, color y carpeta de una nota existente.
- Eliminación de notas con mensaje de confirmación.
- Creación, edición y eliminación de carpetas.
- Al eliminar una carpeta, las notas se mueven automáticamente a la carpeta General.
- Buscador por título, contenido o carpeta.
- Almacenamiento local con Hive.

## Diseño

El rediseño usa una línea visual institucional basada en colores UNISON:

- Azul Unison: `#00529E`
- Azul oscuro Unison: `#015294`
- Dorado Unison: `#F8BB00`
- Dorado oscuro Unison: `#D99E30`

La interfaz se reorganizó con tarjetas, chips de carpetas, fondo claro y encabezado institucional para que sea más intuitiva en teléfono.

## Tecnologías utilizadas

- Flutter 3.x
- Dart 3.x
- Hive `^2.2.3`
- Hive Flutter `^1.1.0`
- UUID `^4.3.3`
- Flutter Color Picker `^1.1.0`

## Estructura relevante

```text
lib/
  app.dart
  main.dart
  data/
    notes_repo.dart
  models/
    category.dart
    note.dart
  screens/
    welcome_screen.dart
    notes_screen.dart
    note_form_screen.dart
    note_view_screen.dart
  widgets/
    color_picker.dart
    note_card.dart
  utils/
    constants.dart
    date_format.dart
```

## Ejecución

```bash
flutter pub get
flutter run
```

## Compilar APK

```bash
flutter build apk --release
```

## Cambios realizados sobre la versión anterior

- Se retiró la navegación y lógica de notas compartidas.
- Se retiró la dependencia funcional de Supabase, Railway, API REST, autenticación y conectividad.
- Se agregó el modelo `NoteCategory`.
- Se agregó agrupación de notas por carpetas.
- Se actualizó el formulario para seleccionar carpeta.
- Se actualizó la pantalla principal para mostrar filtros por carpeta.
- Se actualizaron los nombres de los integrantes.
