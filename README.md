# SGA

Aplicación Flutter de punto de venta con catálogo local, escaneo de códigos de barras, carrito e impresión Bluetooth.

En el lanzador de Android e iOS, la app se llama **SGA** y usa el monograma blanco sobre un degradado azul y violeta. El nombre previsto para la ficha de tienda es **SGA · Punto de venta**.

Este repositorio contiene el proyecto para Android y iOS. Usa Flutter 3.47.9 con Dart 3.13.7 como entorno de referencia. Desde la carpeta que contiene `pubspec.yaml`, ejecuta estos comandos.

```sh
flutter --version
flutter pub get
flutter devices
flutter run -d <ID_DEL_DISPOSITIVO>
```

Si `flutter --version` muestra Dart 3.9.2 u otro SDK incompatible, agrega la carpeta `bin` del Flutter de referencia al principio del `PATH` de PowerShell. Sustituye la ruta de ejemplo por la de tu instalación.

```powershell
$flutterSgaBin = 'C:\ruta\al\flutter\bin'
$env:Path = "$flutterSgaBin;$env:Path"
flutter --version
```

- **Android** requiere el SDK de Android con la plataforma API 37. Puedes compilar un APK de depuración con `flutter build apk --debug`.
- **iOS** requiere macOS y Xcode con Swift Package Manager habilitado en Flutter. Provisiona la firma en Xcode si vas a ejecutar en un iPhone. Para compilar para el simulador, usa `flutter build ios --simulator`.

Conserva `pubspec.lock` y los archivos de configuración versionados. Flutter genera las cachés y los archivos locales al resolver dependencias y compilar.

## Arranque de SGA

1. Android e iOS muestran el logo SGA centrado sobre un fondo azul durante el arranque nativo.
2. Flutter muestra el splash mientras se inicializan Hive y las dependencias. El logo entra, gira y recupera su orientación. Luego sube con el título, la descripción y el botón **Entrar**.
3. Al pulsar **Entrar**, el botón se comprime brevemente y el punto de venta aparece con un fundido ascendente. El degradado se mantiene en el área del escáner mientras se inicializa la cámara.

Con el movimiento reducido activado, la bienvenida aparece estática y **Entrar** abre el punto de venta directamente. [Logo vectorial de SGA](assets/branding/sga-logo.svg)

## Configuración para Perú

- La interfaz usa español latinoamericano para Perú (`es-PE`).
- El catálogo, el carrito, el cobro y los recibos muestran los importes como `S/ 50.00`. El código ISO 4217 del sol es `PEN`.
- En **Cobro**, el **QR de ejemplo** se actualiza con el total del pedido. Al escanearlo se lee el monto en soles como texto de demostración. La integración de pagos con Yape queda para una actualización posterior.

## Carrito y revisión del pedido

- En **Productos escaneados**, usa **−** y **+** para ajustar una unidad o toca el número para escribir la cantidad.
- Desliza una fila hacia la izquierda para revelar la papelera. Tócala para eliminar el producto o desliza hacia la derecha para cerrar la acción y conservarlo.
- En **Revisar pedido**, puedes volver sin imprimir para agregar o corregir productos. La cámara se reanuda si estaba encendida al entrar.

## Confirmación de salida

Pulsa **Atrás** desde la pantalla principal para abrir el aviso de salida. **Cancelar** vuelve al punto de venta y conserva el pedido. **Salir** cierra la app. Si hay productos en el carrito, el aviso indica que el pedido actual se perderá.

El diálogo se adapta a pantallas estrechas y a texto ampliado. En Android, volver desde **Revisar pedido** o desde otra pantalla continúa por la navegación habitual.

Consulta el [registro de pruebas en Android](docs/pruebas-android.md) para repetir el flujo y conocer el estado de la validación.

Proyecto de origen de Dinesh Sowndar. [flutter_billing_app](https://github.com/Dinesh-Sowndar/flutter_billing_app)
