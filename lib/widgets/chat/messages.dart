import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Here all files
import '../chat/mesage_buble.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.value(FirebaseAuth.instance.currentUser),
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chat')
              .orderBy(
                'createdAt',
                descending: true,
              )
              .snapshots(),
          builder: (ctx, chatSnapshot) {
            if (chatSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final chatDocuments = chatSnapshot.data!.docs;
            return ListView.builder(
              reverse: true,
              itemCount: chatDocuments.length,
              itemBuilder: (ctx, index) => MessageBuble(
                chatDocuments[index]['text'],
                chatDocuments[index]['userName'],
                chatDocuments[index]['userImage'],
                chatDocuments[index]['userId'] == futureSnapshot.data!.uid,
                key: ValueKey(chatDocuments[index].id),
              ),
            );
          },
        );
      },
    );
  }
}
