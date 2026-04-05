import 'dart:io';

import 'package:file_management/file_service/file_service.dart';
import 'package:flutter/material.dart';

class EditTextScreen extends StatefulWidget {
  const EditTextScreen({
    super.key,
    required this.file,
    required this.fileService,
  });

  final File file;
  final FileService fileService;

  @override
  State<EditTextScreen> createState() => _EditTextScreenState();
}

class _EditTextScreenState extends State<EditTextScreen> {
  late final TextEditingController _controller;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadContent();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    final String content = await widget.fileService.readFile(widget.file);
    if (!mounted) return;
    _controller.text = content;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveContent() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    await widget.fileService.writeFile(widget.file, _controller.text);

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("File saved")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.path.split(Platform.pathSeparator).last),
        actions: [
          IconButton(
            tooltip: "Save",
            onPressed: _isLoading || _isSaving ? null : _saveContent,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Edit file content...",
                ),
              ),
            ),
    );
  }
}
