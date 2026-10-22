import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment_model.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  final String postTitulo;
  final String postAutor;

  const CommentsScreen({
    super.key,
    required this.postId,
    required this.postTitulo,
    required this.postAutor,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _enviando = false;

  Future<void> _enviarComentario() async {
    final user = FirebaseAuth.instance.currentUser;
    final texto = _commentController.text.trim();

    if (user == null || texto.isEmpty) return;

    setState(() => _enviando = true);

    try {
      final novoComentario = CommentModel(
        id: '',
        texto: texto,
        nomeUsuario: user.displayName ?? user.email ?? 'Usuário',
        uidUsuario: user.uid,
        postId: widget.postId,
      );

      await FirebaseFirestore.instance
          .collection('publicacoes')
          .doc(widget.postId)
          .collection('comentarios')
          .add(novoComentario.toMap());

      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar comentário: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _excluirComentario(String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('publicacoes')
          .doc(widget.postId)
          .collection('comentarios')
          .doc(commentId)
          .delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível excluir: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentários'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.postAutor,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.postTitulo,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('publicacoes')
                  .doc(widget.postId)
                  .collection('comentarios')
                  .orderBy('criadoEm', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(child: Text('Nenhum comentário ainda.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final comment = CommentModel.fromFirestore(docs[index]);
                    final bool isOwner = comment.uidUsuario == currentUid;

                    return ListTile(
                      title: Text(
                        comment.nomeUsuario,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      subtitle: Text(comment.texto),
                      trailing: isOwner
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _excluirComentario(comment.id),
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Escreva um comentário...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _enviando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    onPressed: _enviando ? null : _enviarComentario,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
