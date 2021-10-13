import 'dart:io';

import 'package:flutter/material.dart';

import 'logger.dart';
import 'sysutils.dart';

void main() {
  runApp(MyApp());
}

final Logger log = new Logger("main");

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Manager',
      theme: ThemeData(
        brightness: Brightness.light,
        accentColor: Colors.blueGrey,
        primarySwatch: Colors.blue,
      ),
      home: FileManagerPage(title: "File Manager"),
    );
  }
}

class FileManagerPage extends StatefulWidget {
  FileManagerPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _FileManagerPageState createState() => _FileManagerPageState();
}

class _FileManagerPageState extends State<FileManagerPage> {
  Directory _currentDirectory = Directory.current;
  List<_FileListEntry> _folderList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Container(
            alignment: AlignmentDirectional.centerStart,
            padding: const EdgeInsets.all(8),
            child: Text(_currentDirectory.path),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: _folderList.length,
              itemBuilder: (BuildContext context, int index) {
                _FileListEntry item = _folderList[index];
                return ListTile(
                  leading: Icon(item._icon),
                  title: Text(item._name),
                  onTap: () => _move(item),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _reload,
        tooltip: 'Reload',
        child: Icon(Icons.refresh),
      ), //
    );
  }

  void _reload() async {
    try {
      Stream<FileSystemEntity> stream = _currentDirectory.list();
      _folderList.clear();
      _folderList.add(await _FileListEntry.create(_currentDirectory.parent,
          isParent: true));
      await for (var v in stream) {
        log.debug("Item: ${v}");
        _folderList.add(await _FileListEntry.create(v));
      }
      _folderList.sort((a, b) => _compare(a, b));
      setState(() {
        _folderList = _folderList;
      });
    } catch (e) {
      log.error("Error getting files for ${_currentDirectory}", e);
      _currentDirectory = Directory(Sysutils.getUserHome());
      log.debug("CurrentDir set to ${_currentDirectory}");
    }
  }

  int _compare(_FileListEntry a, _FileListEntry b) {
    int result = b._weight - a._weight;
    if (result == 0) {
      result = a._name.compareTo(b._name);
    }
    return result;
  }

  _move(_FileListEntry item) {
    log.debug("${item}");
    if (item._fileStat.type == FileSystemEntityType.directory) {
      _currentDirectory = item._fileSystemEntity as Directory;
      _reload();
    }
  }
}

class _FileListEntry {
  FileSystemEntity _fileSystemEntity;
  late IconData _icon;
  late String _name;
  late FileStat _fileStat;
  int _weight = 0;
  bool isParent;

  static Future<_FileListEntry> create(FileSystemEntity fileSystemEntity,
      {bool isParent = false}) async {
    var result = _FileListEntry(fileSystemEntity, isParent: isParent);
    return Future(() {
      result.init();
      return result;
    });
  }

  _FileListEntry(this._fileSystemEntity, {this.isParent = false});

  void init() async {
    await _fileSystemEntity.stat().then((value) => {_fileStat = value});

    switch (_fileStat.type) {
      case FileSystemEntityType.directory:
        var pos = _fileSystemEntity.uri.pathSegments.length - 2;
        if (pos > 0) {
          _name = _fileSystemEntity.uri.pathSegments[pos];
        } else {
          _name = _fileSystemEntity.path;
        }
        _icon = Icons.folder;
        _weight = 2;
        break;
      case FileSystemEntityType.file:
        _name = _fileSystemEntity.uri.pathSegments.last;
        _icon = Icons.file_present;
        _weight = 1;
        break;
      default:
        _name = _fileSystemEntity.uri.pathSegments.last;
        _icon = Icons.list;
        _weight = 0;
    }
    if (isParent) {
      _icon = Icons.arrow_back;
      _weight = 10;
    }
  }
}
