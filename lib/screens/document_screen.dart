import 'dart:async';

import 'package:docs_clone_flutter/common/constants.dart';
import 'package:docs_clone_flutter/config/colors.dart';
import 'package:docs_clone_flutter/models/document_model.dart';
import 'package:docs_clone_flutter/repository/auth_repository.dart';
import 'package:docs_clone_flutter/repository/document_repository.dart';
import 'package:docs_clone_flutter/repository/socket_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController =
      TextEditingController(text: 'Untitled Document');

  quill.QuillController? _controller;
  DocumentModel? documentModel;

  SocketRepository socketRepository = SocketRepository();

  @override
  void initState() {
    super.initState();
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();

    socketRepository.changeListner((data) {
      _controller!.compose(
        Delta.fromJson(data['delta']),
        _controller?.selection ?? const TextSelection.collapsed(offset: 0),
        ChangeSource.remote,
      );
    });

    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepository.autoSave(<String, dynamic>{
        'delta': _controller!.document.toDelta(),
        'room': widget.id,
      });
    });
  }

  void fetchDocumentData() async {
    final response = await ref
        .read(documentRepositoryProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);

    if (response.data != null && response.data is DocumentModel) {
      documentModel = response.data;
      titleController.text = documentModel!.title;
      _controller = quill.QuillController(
        document: documentModel!.content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(
                Delta.fromJson(documentModel!.content),
              ),
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {});
    }

    _controller!.document.changes.listen((event) {
      if (event.source == ChangeSource.local) {
        Map<String, dynamic> map = {
          'delta': event,
          'room': widget.id,
        };
        socketRepository.typing(map);
      }
    });
  }

  void updateTitle(WidgetRef ref, String title) {
    ref.read(documentRepositoryProvider).updateTItle(
          token: ref.read(userProvider)!.token,
          title: title,
          id: widget.id,
        );
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appWhiteColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                          text:
                              '${Constants.apiBaseUrl}#/document/${widget.id}'))
                      .then(
                    (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Link copied!',
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.lock),
                label: const Text("Share")),
          )
        ],
        title: Row(
          children: [
            Image.asset(
              'assets/images/docs-logo.png',
              height: 40,
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 140,
              child: TextField(
                controller: titleController,
                onSubmitted: (value) => updateTitle(ref, value),
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue))),
              ),
            )
          ],
        ),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade800,
                  width: 0.1,
                ),
              ),
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
            child: Column(
          children: [
            const SizedBox(height: 10),
            QuillToolbar.simple(
              configurations: QuillSimpleToolbarConfigurations(
                controller: _controller!,
                sharedConfigurations: const QuillSharedConfigurations(
                  locale: Locale('en'),
                ),
              ),
            ),
            Expanded(
              child: QuillEditor.basic(
                configurations: QuillEditorConfigurations(
                  controller: _controller!,
                  readOnly: false,
                  sharedConfigurations: const QuillSharedConfigurations(
                    locale: Locale('en'),
                  ),
                ),
              ),
            )
          ],
        )),
      ),
    );
  }
}
