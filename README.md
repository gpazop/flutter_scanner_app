# Flutter Scanner App

Aplicación Flutter de punto de venta con catálogo local, escaneo de códigos de barras, carrito e impresión Bluetooth.

Este repositorio contiene el proyecto para Android y iOS. Usa Flutter 3.47.9 con Dart 3.13.7 como entorno de referencia. Desde la carpeta que contiene `pubspec.yaml`, ejecuta estos comandos.

```sh
flutter pub get
flutter devices
flutter run -d <ID_DEL_DISPOSITIVO>
```

- **Android** requiere el SDK de Android con la plataforma API 37. Puedes compilar un APK de depuración con `flutter build apk --debug`.
- **iOS** requiere macOS y Xcode con Swift Package Manager habilitado en Flutter. Provisiona la firma en Xcode si vas a ejecutar en un iPhone. Para compilar para el simulador, usa `flutter build ios --simulator`.

Conserva `pubspec.lock` y los archivos de configuración versionados. Flutter genera las cachés y los archivos locales al resolver dependencias y compilar.

## Configuración para Perú

- La interfaz usa español latinoamericano para Perú (`es-PE`).
- El catálogo, el carrito, el cobro y los recibos muestran los importes como `S/ 50.00`. El código ISO 4217 del sol es `PEN`.
- En **Cobro**, el **QR de ejemplo** se actualiza con el total del pedido. Al escanearlo se lee el monto en soles como texto de demostración. La integración de pagos con Yape queda para una actualización posterior.

## Carrito y revisión del pedido

- En **Productos escaneados**, usa **−** y **+** para ajustar una unidad o toca el número para escribir la cantidad.
- Desliza una fila hacia la izquierda para revelar la papelera. Tócala para eliminar el producto o desliza hacia la derecha para cerrar la acción y conservarlo.
- En **Revisar pedido**, puedes volver sin imprimir para agregar o corregir productos. La cámara se reanuda si estaba encendida al entrar.

Consulta el [registro de pruebas en Android](docs/pruebas-android.md) para repetir el flujo y conocer el estado de la validación.

Proyecto de origen de Dinesh Sowndar. [flutter_billing_app](https://github.com/Dinesh-Sowndar/flutter_billing_app)
