import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileService {
  Future<Directory> getRootDirectory() {
    return getApplicationDocumentsDirectory();
  }

  String _buildPath(String base, String child) {
    if (base.isEmpty) return child;
    if (child.isEmpty) return base;
    return "$base/$child";
  }

  Future<Directory> createDir(
    String dir, {
    String path = "",
    Function(String status)? status,
  }) async {
    Directory root = await getRootDirectory();
    final String fullPath = _buildPath(path, dir);
    Directory directory = Directory("${root.path}/$fullPath");
    bool isExist = await directory.exists();
    if (!isExist) {
      await directory.create(recursive: true);
      status?.call("Folder successfully created");
    } else {
      status?.call("Folder already exists");
    }
    return directory;
  }

  Future<File> createFile(
    String file,
    String content, {
    String path = "",
    Function(String status)? status,
  }) async {
    Directory root = await getRootDirectory();
    final String fullPath = _buildPath(path, file);
    File newFile = File("${root.path}/$fullPath");
    bool isExist = await newFile.exists();
    if (!isExist) {
      await newFile.create(recursive: true);
      status?.call("File Successfully Created");
    } else {
      status?.call("File already exists");
      return newFile;
    }
    await newFile.writeAsString(content);
    return newFile;
  }

  Future<List<Directory>> getFolderList(String path) async {
    Directory root = await getRootDirectory();
    Directory currentDir = Directory("${root.path}/$path");
    final dirList = currentDir.list();
    return dirList
        .where((entity) => entity is Directory)
        .cast<Directory>()
        .toList();
  }

  Future<List<File>> getFileList(String path) async {
    Directory root = await getRootDirectory();
    Directory currentDir = Directory("${root.path}/$path");
    final fileList = currentDir.list();
    return fileList.where((entity) => entity is File).cast<File>().toList();
  }

  Future<String> readFile(File file) async {
    final bool exists = await file.exists();
    if (!exists) return "";
    return file.readAsString();
  }

  Future<void> writeFile(File file, String content) async {
    await file.writeAsString(content);
  }

  Future<String> renameDirectory(Directory directory, String newName) async {
    final String trimmedName = newName.trim();
    if (trimmedName.isEmpty) return "Folder name cannot be empty";

    final String parentPath = directory.parent.path;
    final String nextPath = "$parentPath/$trimmedName";
    final Directory target = Directory(nextPath);
    if (await target.exists()) return "Folder already exists";

    await directory.rename(nextPath);
    return "Folder renamed";
  }

  Future<String> renameFile(File file, String newName) async {
    final String trimmedName = newName.trim();
    if (trimmedName.isEmpty) return "File name cannot be empty";

    final String parentPath = file.parent.path;
    final String nextPath = "$parentPath/$trimmedName";
    final File target = File(nextPath);
    if (await target.exists()) return "File already exists";

    await file.rename(nextPath);
    return "File renamed";
  }

  Future<String> deleteDirectory(Directory directory) async {
    final bool exists = await directory.exists();
    if (!exists) return "Folder does not exist";
    await directory.delete(recursive: true);
    return "Folder deleted";
  }

  Future<String> deleteFile(File file) async {
    final bool exists = await file.exists();
    if (!exists) return "File does not exist";
    await file.delete();
    return "File deleted";
  }
}
