# Pruebas manuales en un celular Android

Registro del 20 de noviembre de 2026. Las observaciones provienen de la prueba en el celular. Las causas confirmadas y las hipótesis se basan en la revisión del código.

## Resultados de la prueba

- **Catálogo persistente.** Al cerrar y volver a abrir la app, los productos seguían registrados. Se almacenan localmente en Hive.
- **Sesión de depuración.** Si Android termina el proceso, la sesión de Flutter se cierra. Para recuperarla, abre de nuevo la app y ejecuta `flutter attach -d <ID_DEL_CELULAR>` con el mismo SDK. Si sigue sin adjuntarse, vuelve a iniciarla con `flutter run -d <ID_DEL_CELULAR>`.
- **Arranque lento.** La causa queda por medir. Conviene cronometrar desde que se toca el icono hasta que aparece la interfaz y, por separado, hasta que la cámara escanea. Repetir en el mismo teléfono en `debug` y en `profile` (`flutter run --profile -d <ID_DEL_CELULAR>`). El arranque espera la apertura de Hive antes de mostrar la interfaz. La cámara se inicializa en la pantalla principal. [Arranque de la app](../lib/main.dart)

## Ajustes del carrito y la cámara

La revisión en el teléfono confirmó una mejora general del flujo del carrito. Dos pruebas de widgets de Flutter, una con configuración de Android y otra de iOS, comprobaron que el gesto revela y oculta la papelera, que la fila se conserva hasta tocarla y que el total se recalcula.

Las comprobaciones del gesto en dispositivos físicos y de la impresión con una impresora real quedan pendientes.

| Ajuste | Prueba manual |
| --- | --- |
| Volver de **Checkout** conserva la compra en curso. Después de una impresión exitosa, salir de **Checkout** vacía el carrito. [Checkout](../lib/features/billing/presentation/pages/checkout_page.dart) | Agregar dos productos, abrir **Review Order** y volver sin imprimir, primero con la flecha y luego con el botón o gesto Atrás de Android. Comprobar productos, cantidades y total. Agregar un tercer producto. Con una impresora disponible, probar también la salida tras imprimir correctamente. |
| El carrito permite sumar, restar y editar la cantidad desde una fila compacta. Deslizar hacia la izquierda revela la papelera y deslizar hacia la derecha la vuelve a ocultar. El producto se elimina al tocar la papelera. Guardar cero también retira el producto. [Carrito principal](../lib/features/billing/presentation/pages/home_page.dart) | Tocar el número, guardar 11 y reducir a 10 con **−**. Deslizar lentamente un tramo corto y soltar para comprobar que la fila vuelve a su posición. Deslizar más allá de la mitad y soltar para mantener visible la papelera con el producto aún en el carrito. Deslizar a la derecha para cerrar. Volver a abrir con un arrastre completo, comprobar que el producto siga en el carrito y tocar la papelera para verificar que se elimina esa línea y se recalcula el total. Repetir el gesto en Android y, cuando haya un iPhone disponible, en iOS. |
| La pantalla principal espera a que la cámara se detenga antes de navegar y la reanuda al regresar si estaba encendida. [Pantalla principal](../lib/features/billing/presentation/pages/home_page.dart) | Abrir **Checkout** con la cámara encendida, volver por cada salida y escanear sin tocar el icono. Apagarla manualmente y repetir. Debe seguir apagada y un toque debe activarla. |

## QR de pago y adaptación a Yape

El QR actual contiene `upi://pay` con el identificador UPI de la tienda, su nombre, el total y la moneda `INR`. Con los datos de ejemplo, el destinatario configurado es `dineshsowndar@oksbi`. Un lector compatible puede enviar ese enlace a una app UPI para preparar el pago. La app de caja no confirma la recepción. Evitar pagos de prueba al destinatario de ejemplo. [Generación del QR](../lib/features/billing/presentation/pages/checkout_page.dart) · [Datos predeterminados de tienda](../lib/features/shop/data/repositories/shop_repository_impl.dart)

Para un primer piloto en Perú, configurar el QR oficial del negocio desde los ajustes de tienda y mostrar el importe de la venta en soles junto al QR. El cliente ingresa el monto en Yape y el comerciante comprueba que el abono llegó antes de cerrar la venta. Ocultar el QR de cobro hasta que esté configurado el del negocio. Un QR con importe precargado y verificación automática requiere evaluar una integración de pagos aparte. [QR de Yape para negocios](https://www.yape.com.pe/preguntas-frecuentes/yape-negocios/como-obtengo-el-qr-de-yape-para-mi-negocio) · [Cómo pagar con QR](https://www.yape.com.pe/preguntas-frecuentes/enviar-y-recibir-yapeos/31--como-hago-un-pago-con-qr) · [Cómo verificar el abono](https://www.yape.com.pe/preguntas-frecuentes/yape-negocios/como-puedo-verificar-que-he-recibido-un-pago-por-yape)

Antes del piloto, verificar con el QR configurado que Yape muestre el destinatario correcto. Confirmar que el total de la venta se muestre en `S/` y que el comercio pueda verificar el abono desde su cuenta.
