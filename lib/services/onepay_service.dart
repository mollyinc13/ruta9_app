import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show debugPrint; // Para debugPrint

class OnePayService {
  // Definir un nombre único para el MethodChannel.
  // Debe coincidir con el nombre usado en la implementación nativa (Android/iOS).
  static const MethodChannel _channel = MethodChannel('cl.ruta9.onepay/payment');

  // Método para iniciar el pago con Onepay.
  // Debería recibir los tokens necesarios desde el backend del usuario.
  // Devuelve un Map con el resultado del pago.
  Future<Map<String, dynamic>> startAndroidPayment({
    required String ott, // One Time Token
    required String externalUniqueNumber, // Identificador único externo de la transacción
    // Otros parámetros que el SDK o tu implementación nativa puedan necesitar.
    // Por ejemplo, el monto y la descripción ya estarían asociados al 'ott'
    // cuando se creó la transacción en el backend.
  }) async {
    try {
      debugPrint("[OnePayService] Attempting to start Android payment via platform channel...");
      debugPrint("[OnePayService] OTT: $ott, ExternalUniqueNumber: $externalUniqueNumber");

      final Map<dynamic, dynamic>? result = await _channel.invokeMethod('startOnePayPayment', {
        'ott': ott,
        'externalUniqueNumber': externalUniqueNumber,
      });

      if (result == null) {
        debugPrint("[OnePayService] Platform channel returned null result.");
        return {'status': 'ERROR', 'message': 'Resultado nulo desde la plataforma nativa.'};
      }

      debugPrint("[OnePayService] Payment result from platform channel: $result");
      // Asegurar que las claves sean String y los valores dynamic.
      return Map<String, dynamic>.from(result);

    } on PlatformException catch (e) {
      debugPrint("[OnePayService] PlatformException during payment: ${e.message}");
      return {'status': 'ERROR', 'message': e.message ?? 'Error de plataforma desconocido', 'details': e.details};
    } catch (e) {
      debugPrint("[OnePayService] Generic exception during payment: $e");
      return {'status': 'ERROR', 'message': e.toString()};
    }
  }

  // Podrías añadir más métodos si el SDK los tiene y son necesarios,
  // por ejemplo, para consultar el estado de una transacción si el callback no es inmediato
  // o si la app se cierra durante el proceso.
}
