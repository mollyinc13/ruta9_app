import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;
  final int puntajeMax;
  final String? ruteroNivel; // "Oro9" | "Plata Rutero" | "Bronce Rutero" | null
  final List<String> favoritos; // Lista de productIds
  final List<Map<String, String>> mediosPago; // Lista de mapas, ej: [{'tipo': 'Visa', 'ultimos4': '1111'}]
  final Timestamp? createdAt;
  final Timestamp? lastLogin;

  UserModel({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    this.puntajeMax = 0,
    this.ruteroNivel,
    this.favoritos = const [],
    this.mediosPago = const [],
    this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception("Documento de usuario no encontrado o datos nulos");

    return UserModel(
      uid: snapshot.id,
      displayName: data['displayName'] as String?,
      email: data['email'] as String?,
      photoURL: data['photoURL'] as String?,
      puntajeMax: data['puntajeMax'] as int? ?? 0,
      ruteroNivel: data['ruteroNivel'] as String?,
      favoritos: List<String>.from(data['favoritos'] as List<dynamic>? ?? []),
      mediosPago: (data['medios_pago'] as List<dynamic>? ?? [])
          .map((item) => Map<String, String>.from(item as Map))
          .toList(),
      createdAt: data['createdAt'] as Timestamp?,
      lastLogin: data['lastLogin'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (displayName != null) 'displayName': displayName,
      if (email != null) 'email': email,
      if (photoURL != null) 'photoURL': photoURL,
      'puntajeMax': puntajeMax,
      if (ruteroNivel != null) 'ruteroNivel': ruteroNivel,
      'favoritos': favoritos,
      'medios_pago': mediosPago,
      // createdAt y lastLogin se manejan con FieldValue.serverTimestamp() en el servicio
      // o se incluyen aquí si se leen y luego se reescriben.
      // Por simplicidad, el servicio se encarga de los timestamps en escritura.
    };
  }
}

// Modelo para un Pedido, según la estructura /pedidos/{id}
class OrderModel {
  final String? id; // Document ID from Firestore, opcional en creación
  final String usuarioId; // UID del usuario o ID genérico del tótem
  final List<Map<String, dynamic>> productos; // [{ "id": "prod1", "nombre": "Burger", "cantidad": 2, "precioUnitario": 5000, "agregados": [{"nombre": "Extra Queso", "precio": 500}] }]
  final double total;
  final Timestamp fecha;
  // Podrían añadirse más campos como estado_pedido, tipo_pedido (cliente/totem), etc.

  OrderModel({
    this.id,
    required this.usuarioId,
    required this.productos,
    required this.total,
    required this.fecha,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception("Documento de pedido no encontrado o datos nulos");

    return OrderModel(
      id: snapshot.id,
      usuarioId: data['usuarioId'] as String,
      productos: (data['productos'] as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      total: (data['total'] as num).toDouble(),
      fecha: data['fecha'] as Timestamp,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usuarioId': usuarioId,
      'productos': productos,
      'total': total,
      'fecha': fecha, // O FieldValue.serverTimestamp() si se establece en creación
    };
  }
}

// Modelo para la configuración de recompensas
class RecompensaConfig {
  final Map<String, RecompensaNivel> niveles;

  RecompensaConfig({required this.niveles});

  factory RecompensaConfig.fromFirestore(Map<String, dynamic> data) {
    return RecompensaConfig(
      niveles: data.map(
        (key, value) => MapEntry(
          key,
          RecompensaNivel.fromJson(value as Map<String, dynamic>)
        ),
      ),
    );
  }
}

class RecompensaNivel {
  final int dcto;
  final String? regalo;

  RecompensaNivel({required this.dcto, this.regalo});

  factory RecompensaNivel.fromJson(Map<String, dynamic> json) {
    return RecompensaNivel(
      dcto: json['dcto'] as int,
      regalo: json['regalo'] as String?,
    );
  }
}
