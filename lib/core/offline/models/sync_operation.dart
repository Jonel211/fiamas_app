import 'dart:convert'; // IMPORTANTE: Para jsonEncode y jsonDecode
import 'package:uuid/uuid.dart';

class SyncOperation {
  final String id;
  final String type;
  final String entity;
  final String entityId;
  final Map<String, dynamic> payload;
  final String status;
  final int retryCount;
  final DateTime createdAt;

  SyncOperation({
    String? id,
    required this.type,
    required this.entity,
    required this.entityId,
    required this.payload,
    this.status = 'pending',
    this.retryCount = 0,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  //  Convertir a Map para guardar en SQLite (usando jsonEncode)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'entity': entity,
      'entity_id': entityId,
      'payload': jsonEncode(payload), 
      'status': status,
      'retry_count': retryCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  //  Crear desde Map (al leer de SQLite, usando jsonDecode)
  factory SyncOperation.fromMap(Map<String, dynamic> map) {
    return SyncOperation(
      id: map['id'],
      type: map['type'],
      entity: map['entity'],
      entityId: map['entity_id'],
      payload: jsonDecode(map['payload']), //  CORRECTO: Reconstruye el Mapa original
      status: map['status'],
      retryCount: map['retry_count'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}