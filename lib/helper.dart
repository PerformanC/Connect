/*
  Custom PerformanC License

  Copyright (c) 2023 PerformanC <performancorg@gmail.com>

  This Software may be shared, altered, and used without charge; 
  it may also be sold (though not as a stand-alone product); 
  and it can even be used for commercial purposes. 
  However, the software code neither can be used to train a neural network,
  nor any part of the code can be copied in any way without the permission
  of the PerformanC Organization team members.

  The license can be included at the source code of the PerformanC software, although it is not required.

  The Software is given "as is" and without any warranties, 
  and its developers disclaim all liability for any harm it (The Software) may cause.
*/

import 'dart:convert';
import 'dart:async';
import 'dart:io';

class Server {
  Server(
      {required this.username,
      required this.servername,
      required this.url,
      required this.password});

  final String username;
  final String servername;
  final String url;
  final String password;

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      username: json['username'],
      servername: json['servername'],
      url: json['url'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'servername': servername,
      'url': url,
      'password': password,
    };
  }
}

class PublicServer {
  PublicServer(
      {required this.email,
      required this.servername,
      required this.url,
      required this.password});

  final String email;
  final String servername;
  final String url;
  final String password;

  factory PublicServer.fromJson(Map<String, dynamic> json) {
    return PublicServer(
      email: json['email'],
      servername: json['servername'],
      url: json['url'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'servername': servername,
      'url': url,
      'password': password,
    };
  }
}

class AuthResponse {
  AuthResponse({required this.op, required this.status});

  final String op;
  final String status;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      op: json['op'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'op': op,
      'status': status,
    };
  }
}

class Message {
  Message({required this.op, required this.msg, required this.author, required this.authorId});

  final String op;
  final String msg;
  final String author;
  final int authorId;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      op: json['op'] as String,
      msg: json['msg'] as String,
      author: json['author'] as String,
      authorId: json['authorId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'op': op,
      'msg': msg,
      'author': author,
      'authorId': authorId,
    };
  }
}

class MessageList {
  MessageList({required this.msg, required this.author, required this.authorId});

  String msg;
  final String author;
  final int authorId;

  factory MessageList.fromJson(Map<String, dynamic> json) {
    return MessageList(
      msg: json['msg'] as String,
      author: json['author'] as String,
      authorId: json['authorId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': msg,
      'author': author,
      'authorId': authorId,
    };
  }
}

class UserLog {
  UserLog({required this.op, required this.username});

  final String? op;
  final String username;

  factory UserLog.fromJson(Map<String, dynamic> json) {
    return UserLog(
      op: json['op'] as String,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'op': op,
      'username': username,
    };
  }
}

String getAppDataPath() {
  switch (Platform.operatingSystem) {
    case 'android':
      return '/data/user/0/com.connect.app/files';
    case 'ios':
      return '/var/mobile/Containers/Data/Application/com.connect.app/files';
    case 'linux':
      return '~/.config/connect/files';
    case 'macos':
      return '~/Library/Application Support/connect/files';
    case 'windows':
      return '~\\AppData\\Roaming\\connect\\files';
    default:
      // fuchsia (and Web, since there is no FS API) is the only platform that is not supported
      throw Exception(
          'Unsupported platform, contact developer to add support.');
  }
}

Future<List<Server>> getServers() async {
  final path = getAppDataPath();
  final file = File('$path/servers.json');

  String contents;

  try {
    contents = await file.readAsString();
  } catch (e) {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      await Directory(path).create(recursive: true);
    }

    await file.create();

    await file.writeAsString('[]');

    contents = '[]';
  }

  if (contents.isEmpty) {
    return [];
  }

  final decoded = jsonDecode(contents) as List<dynamic>;
  final servers = decoded.map((item) => Server.fromJson(item)).toList();

  return servers;
}

Future<List<Server>> addServer(Server server) async {
  final path = getAppDataPath();
  final file = File('$path/servers.json');

  String contents;
  try {
    contents = await file.readAsString();
  } catch (e) {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      await Directory(path).create(recursive: true);
    }

    await file.create();

    contents = '[]';
  }

  final decoded = jsonDecode(contents) as List<dynamic>;
  final servers = decoded.map((item) => Server.fromJson(item)).toList();

  servers.add(server);

  file.writeAsString(jsonEncode(servers));

  return servers;
}

Future<File> removeServer(String servername, String url) async {
  final path = getAppDataPath();
  final file = File('$path/servers.json');

  String contents;
  try {
    contents = await file.readAsString();
  } catch (e) {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      await Directory(path).create(recursive: true);
    }

    await file.create();

    contents = '[]';
  }

  final decoded = jsonDecode(contents) as List<dynamic>;
  final servers = decoded.map((item) => Server.fromJson(item)).toList();

  servers.removeWhere(
      (element) => element.servername == servername && element.url == url);

  final encoded = jsonEncode(servers);

  return file.writeAsString(encoded);
}

bool isValidUrl(String url) {
  var pattern =
      "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]).)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9])\$";
  var regExp = RegExp(pattern);

  return regExp.hasMatch(url);
}

Future<List<PublicServer>> getPublicServers() async {
  final completer = Completer<List<PublicServer>>();

  // Socket.connect("old.url", 8300).then((socket) {
  //   socket.write('{"op": "getServers"}');
  //   socket.listen((event) {
  //     final decoded = jsonDecode(utf8.decode(event)) as List<dynamic>;
  //     final servers =
  //         decoded.map((item) => PublicServer.fromJson(item)).toList();

  //     completer.complete(servers);
  //   });
  // }).catchError((error) {
  //   print(error);
  //   completer.completeError(error);
  // });

try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('https://the-main-server.performancorgan.repl.co/getServers'));

    final response = await request.close();
    
    if (response.statusCode == HttpStatus.ok) {
      final responseBody = await response.transform(utf8.decoder).join();

      final decoded = jsonDecode(responseBody) as List<dynamic>;
      final servers = decoded.map((item) => PublicServer.fromJson(item)).toList();

      completer.complete(servers);
    } else {
      completer.completeError(Exception('Failed to fetch servers: ${response.statusCode}'));
    }
  } catch (error) {
    completer.completeError(Exception('Failed to fetch servers: $error'));
  }

  return completer.future;
}
