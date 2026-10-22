import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String texto;
  final String nomeUsuario;
  final String uidUsuario;
  final String postId;
  final DateTime? criadoEm;

  CommentModel({
    required this.id,
    required this.texto,
    required this.nomeUsuario,
    required this.uidUsuario,
    required this.postId,
    this.criadoEm,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      texto: data['texto'] ?? '',
      nomeUsuario: data['nomeUsuario'] ?? 'Usuário Anônimo',
      uidUsuario: data['uidUsuario'] ?? '',
      postId: data['postId'] ?? '',
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'texto': texto,
      'nomeUsuario': nomeUsuario,
      'uidUsuario': uidUsuario,
      'postId': postId,
      'criadoEm': FieldValue.serverTimestamp(),
    };
  }
}
