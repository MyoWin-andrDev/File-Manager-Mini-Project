import 'package:flutter/material.dart';

class CreateEntryInput {
  const CreateEntryInput({required this.name, required this.content});

  final String name;
  final String content;
}

Future<CreateEntryInput?> showCreateEntryDialog(
  BuildContext context, {
  required bool isFolder,
}) async {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  final CreateEntryInput? result = await showDialog<CreateEntryInput>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(isFolder ? "Create New Folder" : "Create New File"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: isFolder ? "Folder Name" : "File Name",
                  hintText: isFolder ? "e.g. New Folder" : "e.g. note.txt",
                ),
              ),
              if (!isFolder) ...[
                SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "File Content",
                    hintText: "Optional",
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final String name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.of(dialogContext).pop(
                CreateEntryInput(name: name, content: contentController.text),
              );
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );

  return result;
}
