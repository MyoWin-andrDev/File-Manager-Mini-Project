import 'dart:io';

import 'package:file_management/file_service/file_service.dart';
import 'package:file_management/home/create_entry_dialog.dart';
import 'package:file_management/home/edit_text_screen.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FileService fileService = FileService();
  List<Directory> currentDirList = [];
  List<File> currentFileList = [];
  String currentPath = "";

  @override
  void initState() {
    super.initState();
    _loadFileAndFolder(currentPath);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("File Explorer"),
        leading: currentPath.isEmpty
            ? null
            : IconButton(
                tooltip: "Back",
                icon: Icon(Icons.arrow_back),
                onPressed: _navigateUp,
              ),
        actions: [
          IconButton(
            tooltip: "Create New Folder",
            onPressed: () async {
              await _createFolderAndFile(isFolder: true);
            },
            icon: Icon(Icons.create_new_folder),
          ),
          IconButton(
            tooltip: "Create New File",
            onPressed: () async {
              await _createFolderAndFile(isFolder: false);
            },
            icon: Icon(Icons.upload_file),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Text(
                currentPath.isEmpty ? "/" : "/$currentPath",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          //Dir List
          SliverList.builder(
            itemCount: currentDirList.length,
            itemBuilder: (context, index) {
              Directory dir = currentDirList[index];
              final String folderName = _entityName(dir.path);
              return ListTile(
                leading: Icon(Icons.folder),
                title: Text(folderName),
                subtitle: Text(dir.statSync().changed.toString()),
                onTap: () => _openFolder(folderName),
                trailing: PopupMenuButton<_TileAction>(
                  onSelected: (action) => _handleFolderAction(dir, action),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _TileAction.rename,
                      child: Text("Rename"),
                    ),
                    PopupMenuItem(
                      value: _TileAction.delete,
                      child: Text("Delete"),
                    ),
                  ],
                ),
              );
            },
          ),
          //File List
          SliverList.builder(
            itemCount: currentFileList.length,
            itemBuilder: (context, index) {
              File file = currentFileList[index];
              return ListTile(
                leading: Icon(Icons.file_open),
                title: Text(_entityName(file.path)),
                subtitle: Text(file.statSync().changed.toString()),
                onTap: () => _openFileEditor(file),
                trailing: PopupMenuButton<_TileAction>(
                  onSelected: (action) => _handleFileAction(file, action),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _TileAction.rename,
                      child: Text("Rename"),
                    ),
                    PopupMenuItem(
                      value: _TileAction.delete,
                      child: Text("Delete"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _loadFileAndFolder(String path) async {
    final List<Directory> folders = await fileService.getFolderList(path);
    final List<File> files = await fileService.getFileList(path);
    if (!mounted) return;
    currentDirList = folders;
    currentFileList = files;
    setState(() {});
  }

  Future<void> _createFolderAndFile({required bool isFolder}) async {
    final CreateEntryInput? input = await showCreateEntryDialog(
      context,
      isFolder: isFolder,
    );

    if (!mounted) return;
    if (input == null) return;

    String statusMessage = "";
    if (isFolder) {
      await fileService.createDir(
        input.name,
        path: currentPath,
        status: (value) => statusMessage = value,
      );
    } else {
      await fileService.createFile(
        input.name,
        input.content,
        path: currentPath,
        status: (value) => statusMessage = value,
      );
    }

    if (!mounted) return;
    await _loadFileAndFolder(currentPath);
    if (!mounted) return;
    if (statusMessage.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(statusMessage)));
    }
  }

  String _entityName(String fullPath) {
    return fullPath.split(Platform.pathSeparator).last;
  }

  Future<void> _openFolder(String folderName) async {
    final String nextPath = currentPath.isEmpty
        ? folderName
        : "$currentPath/$folderName";
    currentPath = nextPath;
    await _loadFileAndFolder(currentPath);
  }

  Future<void> _navigateUp() async {
    if (currentPath.isEmpty) return;
    final int splitIndex = currentPath.lastIndexOf('/');
    currentPath = splitIndex == -1 ? "" : currentPath.substring(0, splitIndex);
    await _loadFileAndFolder(currentPath);
  }

  Future<void> _openFileEditor(File file) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditTextScreen(file: file, fileService: fileService),
      ),
    );
    if (!mounted) return;
    await _loadFileAndFolder(currentPath);
  }

  Future<void> _handleFolderAction(Directory dir, _TileAction action) async {
    switch (action) {
      case _TileAction.rename:
        await _renameFolder(dir);
      case _TileAction.delete:
        await _deleteFolder(dir);
    }
  }

  Future<void> _handleFileAction(File file, _TileAction action) async {
    switch (action) {
      case _TileAction.rename:
        await _renameFile(file);
      case _TileAction.delete:
        await _deleteFile(file);
    }
  }

  Future<void> _renameFolder(Directory dir) async {
    final String currentName = _entityName(dir.path);
    final String? newName = await _showRenameDialog(
      title: "Rename Folder",
      currentName: currentName,
    );
    if (!mounted || newName == null) return;

    final String status = await fileService.renameDirectory(dir, newName);
    if (!mounted) return;
    await _loadFileAndFolder(currentPath);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status)));
  }

  Future<void> _renameFile(File file) async {
    final String currentName = _entityName(file.path);
    final String? newName = await _showRenameDialog(
      title: "Rename File",
      currentName: currentName,
    );
    if (!mounted || newName == null) return;

    final String status = await fileService.renameFile(file, newName);
    if (!mounted) return;
    await _loadFileAndFolder(currentPath);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status)));
  }

  Future<void> _deleteFolder(Directory dir) async {
    final bool isConfirmed = await _showDeleteDialog(
      title: "Delete Folder",
      message: "Delete folder '${_entityName(dir.path)}'?",
    );
    if (!mounted || !isConfirmed) return;

    final String status = await fileService.deleteDirectory(dir);
    if (!mounted) return;
    await _loadFileAndFolder(currentPath);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status)));
  }

  Future<void> _deleteFile(File file) async {
    final bool isConfirmed = await _showDeleteDialog(
      title: "Delete File",
      message: "Delete file '${_entityName(file.path)}'?",
    );
    if (!mounted || !isConfirmed) return;

    final String status = await fileService.deleteFile(file);
    if (!mounted) return;
    await _loadFileAndFolder(currentPath);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status)));
  }

  Future<String?> _showRenameDialog({
    required String title,
    required String currentName,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: currentName,
    );

    final String? result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: "New name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text("Rename"),
            ),
          ],
        );
      },
    );

    return result;
  }

  Future<bool> _showDeleteDialog({
    required String title,
    required String message,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}

enum _TileAction { rename, delete }
