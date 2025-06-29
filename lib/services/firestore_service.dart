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
}
