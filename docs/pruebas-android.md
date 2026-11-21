# Pruebas en Android

Registro del 20 de noviembre de 2026. Las observaciones provienen de la prueba en el celular. Las causas confirmadas y las hipótesis se basan en la revisión del código.

## Resultados de la prueba del 20 de noviembre

- **Catálogo persistente.** Al cerrar y volver a abrir la app, los productos seguían registrados. Se almacenan localmente en Hive.
- **Sesión de depuración.** Si Android termina el proceso, la sesión de Flutter se cierra. Para recuperarla, abre de nuevo la app y ejecuta `flutter attach -d <ID_DEL_CELULAR>` con el mismo SDK. Si sigue sin adjuntarse, vuelve a iniciarla con `flutter run -d <ID_DEL_CELULAR>`.
- **Arranque lento.** La causa queda por medir. Conviene cronometrar desde que se toca el icono hasta que aparece la interfaz y, por separado, hasta que la cámara escanea. Repetir en el mismo teléfono en `debug` y en `profile` (`flutter run --profile -d <ID_DEL_CELULAR>`). El arranque espera la apertura de Hive antes de mostrar la interfaz. La cámara se inicializa en la pantalla principal. [Arranque de la app](../lib/main.dart)

## Validación del 21 de noviembre de 2026

- `flutter analyze --no-pub` terminó sin incidencias en `flutter_scanner_app`.
- Pasaron cinco pruebas automatizadas contra esta copia. Cubrieron la apertura del catálogo, el alta y los campos obligatorios de productos, la actualización del monto del QR y la generación del recibo con importes en soles.
- Se compiló el APK de depuración en `build/app/outputs/flutter-apk/app-debug.apk`.

## Pruebas pendientes en el celular

| Flujo | Qué comprobar |
| --- | --- |
| Catálogo y moneda | Agregar un producto de precio `50.00`. Confirmar que el catálogo, el carrito y **Cobro** muestran `S/ 50.00` y que los mensajes aparecen en español. |
| Cantidades y eliminación | Usar **−** y **+**, tocar la cantidad para editarla y deslizar una fila hacia la izquierda para revelar la papelera. Confirmar que el total se recalcula al cambiar cantidades o eliminar el producto. |
| Volver al carrito | Abrir **Revisar pedido** y volver sin imprimir. Probar la flecha y el botón o gesto Atrás de Android. Comprobar que el carrito conserva los productos y las cantidades. |
| Cámara | Abrir **Revisar pedido** con la cámara encendida y comprobar que escanea al volver. Repetir con la cámara apagada y comprobar que respeta esa elección. |
| QR de ejemplo | Escanear el QR con otro celular. El texto debe incluir el total en soles. Cambiar la cantidad, volver a **Cobro** y comprobar que el código muestra el nuevo total. |
| Impresión Bluetooth | Imprimir en una impresora térmica física. Revisar que el precio unitario, los subtotales y el total llevan `S/` antes de la cifra y que se imprimen los caracteres acentuados. |

## QR de demostración y futura integración con Yape

El **QR de ejemplo** contiene texto con el total actual en soles. Es una referencia visual para la futura integración de pagos con Yape. [Generación del QR](../lib/features/billing/presentation/pages/checkout_page.dart)
