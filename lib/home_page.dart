import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedDirectory;

  late TextEditingController _fromController;
  late TextEditingController _replaceController;

  @override
  void initState() {
    _fromController = TextEditingController();
    _replaceController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _replaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Directory Path: ${_selectedDirectory ?? 'null'}"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectDirectory,
              child: const Text('SELECT'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fromController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'From',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _replaceController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Replace',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final count = await renameFiles(_selectedDirectory);
                final snackBar = SnackBar(
                  content: Text('$count files renamed'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: const Text('RUN'),
            ),
          ],
        ),
      ),
    );
  }

  void selectDirectory() async {
    _selectedDirectory = await FilePicker.platform.getDirectoryPath();
    setState(() {});
  }

  Future<int> renameFiles(String? directoryPath) async {
    if (directoryPath == null) {
      return 0;
    }
    var count = 0;
    final Directory directory = Directory(directoryPath);
    final List<FileSystemEntity> files = directory.listSync();
    for (final FileSystemEntity file in files) {
      if (file is File) {
        final String name = file.path.split('/').last;
        final String newName =
            name.replaceAll(_fromController.text, _replaceController.text);
        if (name != newName) {
          file.renameSync(file.parent.path + '/' + newName);
          count++;
        }
      } else {
        count += await renameFiles(file.path);
      }
    }
    return count;
  }
}
