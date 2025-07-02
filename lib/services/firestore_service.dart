import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para el tipo User

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(User user) async {
    final DocumentReference userDocRef = _db.collection('users').doc(user.uid);

    // Usar SetOptions(merge: true) para crear el documento si no existe,
    // o actualizarlo si ya existe sin sobrescribir campos no incluidos.
    // Si es la primera vez, FieldValue.serverTimestamp() guardará la hora del servidor.
    // Si el documento ya existe y tiene 'createdAt', merge:true no lo sobrescribirá.

    // Para asegurar que 'createdAt' solo se establezca una vez:
    final userSnapshot = await userDocRef.get();

    Map<String, dynamic> userData = {
      'name': user.displayName,
      'email': user.email,
      'photoURL': user.photoURL,
      'lastLogin': FieldValue.serverTimestamp(), // Siempre actualiza el último login
    };

    if (!userSnapshot.exists) {
      userData['createdAt'] = FieldValue.serverTimestamp(); // Solo en la creación
    }

    return userDocRef.set(userData, SetOptions(merge: true));
  }

  // Aquí podrías añadir más métodos para interactuar con Firestore,
  // como guardar pedidos, obtener perfil de usuario, etc.
  // Ejemplo:
  // Future<void> saveOrder(Map<String, dynamic> orderData, String userId) async {
  //   await _db.collection('users').doc(userId).collection('orders').add(orderData);
  // }

  // --- User Profile Data ---
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  Future<void> updateUserPuntajeMax(String uid, int nuevoPuntajeMax) {
    return _db.collection('users').doc(uid).update({'puntajeMax': nuevoPuntajeMax});
  }

  // (Asumiendo que ruteroNivel se actualiza basado en puntajeMax, podría ser parte de updateUserPuntajeMax o una cloud function)
  // Future<void> updateUserRuteroNivel(String uid, String nivel) {
  //   return _db.collection('users').doc(uid).update({'ruteroNivel': nivel});
  // }

  // --- Favoritos ---
  Future<void> addFavorito(String uid, String productoId) {
    return _db.collection('users').doc(uid).update({
      'favoritos': FieldValue.arrayUnion([productoId])
    });
  }

  Future<void> removeFavorito(String uid, String productoId) {
    return _db.collection('users').doc(uid).update({
      'favoritos': FieldValue.arrayRemove([productoId])
    });
  }

  // --- Medios de Pago (Mock) ---
  Future<void> addMedioPago(String uid, Map<String, String> medioPago) {
    // Ejemplo: medioPago = {'tipo': 'Visa', 'ultimos4': '1234'}
    return _db.collection('users').doc(uid).update({
      'medios_pago': FieldValue.arrayUnion([medioPago])
    });
  }

  Future<void> removeMedioPago(String uid, Map<String, String> medioPago) {
    return _db.collection('users').doc(uid).update({
      'medios_pago': FieldValue.arrayRemove([medioPago])
    });
  }

  // --- Pedidos ---
  Future<DocumentReference> createPedido(Map<String, dynamic> pedidoData) {
    // pedidoData debe incluir usuarioId, productos, total, y fecha (como Timestamp)
    // Ejemplo: pedidoData = orderModel.toFirestore();
    // La fecha podría ser FieldValue.serverTimestamp() si se establece aquí.
    // Si OrderModel ya tiene la fecha como Timestamp, se usa directamente.
    return _db.collection('pedidos').add(pedidoData);
  }

  // --- Puntajes (Juego) ---
  Future<void> savePuntajeJuego(String uid, int puntaje) {
    return _db.collection('puntajes').doc(uid).collection('partidas').add({ // Guardar cada partida
      'puntaje': puntaje,
      'fecha': FieldValue.serverTimestamp(),
    });
    // La lógica para actualizar puntajeMax en /users/{uid} se manejaría después de esto,
    // posiblemente en la misma función que llama a savePuntajeJuego.
  }

  // --- Configuración de Recompensas ---
  Future<DocumentSnapshot<Map<String, dynamic>>> getConfigRecompensas() {
    return _db.collection('config').doc('recompensasRutero').get();
  }
}
