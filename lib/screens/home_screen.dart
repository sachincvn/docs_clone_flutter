import 'package:docs_clone_flutter/config/colors.dart';
import 'package:docs_clone_flutter/models/document_model.dart';
import 'package:docs_clone_flutter/repository/auth_repository.dart';
import 'package:docs_clone_flutter/repository/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref) {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(WidgetRef ref, BuildContext context) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    final response =
        await ref.read(documentRepositoryProvider).createDocument(token);

    if (response.data != null) {
      navigator.push('/document/${response.data.id}');
    } else {
      snackbar.showSnackBar(SnackBar(content: Text(response.error)));
    }
  }

  void navigateToDocument(BuildContext context, String id) {
    Routemaster.of(context).push('/document/$id');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appWhiteColor,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () => createDocument(ref, context),
              icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () => signOut(ref), icon: const Icon(Icons.logout)),
        ],
      ),
      body: FutureBuilder(
        future: ref
            .watch(documentRepositoryProvider)
            .getDocuments(ref.watch(userProvider)!.token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.data.length,
            itemBuilder: (context, index) {
              DocumentModel documentModel = snapshot.data!.data[index];
              return Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                height: 50,
                child: InkWell(
                  onTap: () => navigateToDocument(context, documentModel.id),
                  child: Card(
                    child: Center(
                      child: Text(
                        documentModel.title,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
