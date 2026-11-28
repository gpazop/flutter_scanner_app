# Pruebas en Android

Registro de las pruebas en el celular, en el emulador y con Flutter.

## Resultados de la prueba del 20 de noviembre

- **Catálogo persistente.** Al cerrar y volver a abrir la app, los productos seguían registrados. Se almacenan localmente en Hive.
- **Sesión de depuración.** Si Android termina el proceso, la sesión de Flutter se cierra. Para recuperarla, abre de nuevo la app y ejecuta `flutter attach -d <ID_DEL_CELULAR>` con el mismo SDK. Si sigue sin adjuntarse, vuelve a iniciarla con `flutter run -d <ID_DEL_CELULAR>`.
- **Arranque lento.** La causa quedó por medir. En esa versión, la app esperaba a que Hive abriera antes de mostrar la interfaz. La cámara se inicializaba en la pantalla principal. [Arranque de la app](../lib/main.dart)

## Validación del 21 de noviembre de 2026

- `flutter analyze --no-pub` terminó sin incidencias en `flutter_scanner_app`.
- Pasaron cinco pruebas automatizadas contra esta copia. Cubrieron la apertura del catálogo, el alta y los campos obligatorios de productos, la actualización del monto del QR y la generación del recibo con importes en soles.
- Se compiló el APK de depuración en `build/app/outputs/flutter-apk/app-debug.apk`.

## Validación del arranque del 24 de noviembre de 2026

- Pasaron las tres pruebas del repositorio. Cubren la subida sincronizada del logo y la bienvenida, la respuesta de **Entrar** y su transición al punto de venta, y el flujo con movimiento reducido.
- Pasaron dos pruebas locales adicionales. Una comprobó la navegación en un tamaño de pantalla móvil. La otra confirmó, con una cámara simulada, que el área del escáner mantiene el degradado durante la inicialización.
- El análisis estático de los archivos modificados del arranque terminó sin incidencias. Queda pendiente comprobar la fluidez de la última versión en un teléfono.

Ejecuta las pruebas versionadas con el SDK indicado en el README y las dependencias resueltas.

```sh
flutter test --no-pub test/startup_gate_test.dart
```

## Validación del lanzador y de la salida del 27 de noviembre de 2026

- El APK de depuración compiló y se instaló en un emulador con Android 13. El cajón de aplicaciones mostró el nombre **SGA** y el monograma completo dentro de la máscara circular.
- Pasaron las cinco pruebas del repositorio. Las dos de salida verifican la navegación desde una pantalla secundaria, la apertura del aviso, la conservación del pedido al cancelar, la solicitud de cierre al confirmar y el ajuste de los botones con texto ampliado.

Desde la raíz del proyecto, con las dependencias resueltas, ejecuta las pruebas y genera el APK.

```sh
flutter test --no-pub
flutter build apk --debug --no-pub
```

El APK queda en `build/app/outputs/flutter-apk/app-debug.apk`.

## Comprobación del arranque en el celular

1. Instala la compilación de prueba con `flutter run -d <ID_DEL_CELULAR>` y vuelve a abrir la app desde un arranque en frío.
2. Comprueba que el fondo azul con el logo dé paso al splash. El logo debe recuperar su orientación y subir junto con el texto y el botón. Esa subida dura 900 ms.
3. Pulsa **Entrar**. El botón se comprime durante 80 ms y el punto de venta sube 20 dp con un fundido de 320 ms. Si la cámara tarda, el degradado permanece en su área hasta que termina de inicializarse.
4. Con la escala de transición de Android en `0×`, comprueba que se muestre la bienvenida estática y que **Entrar** abra el punto de venta directamente.

Tras cerrar la sesión de depuración, puedes forzar un arranque en frío con ADB. Sustituye `<ID_DEL_CELULAR>` por el identificador que aparece en `adb devices`.

```sh
adb -s <ID_DEL_CELULAR> shell am force-stop com.example.billing_app
adb -s <ID_DEL_CELULAR> shell am start -W -n com.example.billing_app/.MainActivity
```

Para medir el arranque, registra por separado el tiempo hasta que aparece la bienvenida y el tiempo desde **Entrar** hasta que la cámara muestra la vista previa. Repite la prueba en el mismo equipo en `debug` y en `profile`.

## Pruebas pendientes en el celular

| Flujo | Qué comprobar |
| --- | --- |
| Catálogo y moneda | Agregar un producto de precio `50.00`. Confirmar que el catálogo, el carrito y **Cobro** muestran `S/ 50.00` y que los mensajes aparecen en español. |
| Cantidades y eliminación | Usar **−** y **+**, tocar la cantidad para editarla y deslizar una fila hacia la izquierda para revelar la papelera. Confirmar que el total se recalcula al cambiar cantidades o eliminar el producto. |
| Volver al carrito | Abrir **Revisar pedido** y volver sin imprimir. Probar la flecha y el botón o gesto Atrás de Android. Comprobar que el carrito conserva los productos y las cantidades. |
| Cámara | Abrir **Revisar pedido** con la cámara encendida y comprobar que escanea al volver. Repetir con la cámara apagada y comprobar que respeta esa elección. |
| Confirmación de salida | Con un pedido en curso, pulsar **Atrás** en la pantalla principal y elegir **Cancelar**. Comprobar que se conservan los productos. Abrir el aviso de nuevo, elegir **Salir** y comprobar que se cierra la app. Repetir con el carrito vacío. |
| Ícono del lanzador | Comprobar en un teléfono que aparece el nombre **SGA** y que la máscara del lanzador deja visible todo el monograma. Si el lanzador admite íconos temáticos, activar esa opción y revisar la variante monocromática. |
| QR de ejemplo | Escanear el QR con otro celular. El texto debe incluir el total en soles. Cambiar la cantidad, volver a **Cobro** y comprobar que el código muestra el nuevo total. |
| Impresión Bluetooth | Imprimir en una impresora térmica física. Revisar que el precio unitario, los subtotales y el total llevan `S/` antes de la cifra y que se imprimen los caracteres acentuados. |

## QR de demostración y futura integración con Yape

El **QR de ejemplo** contiene texto con el total actual en soles. Es una referencia visual para la futura integración de pagos con Yape. [Generación del QR](../lib/features/billing/presentation/pages/checkout_page.dart)
