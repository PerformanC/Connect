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

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'helper.dart';

List<Server> servers = [];
List<PublicServer> publicServers = [];

void main() async {
  servers = await getServers();

  runApp(const HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      if (lightColorScheme == null && darkColorScheme == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final platformBrightness = MediaQuery.of(context).platformBrightness;
      final systemTheme = (platformBrightness == Brightness.light
          ? lightColorScheme
          : darkColorScheme) ??
        ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple, brightness: platformBrightness);

      return MaterialApp(
        title: 'Connect',
        theme: ThemeData(
          colorScheme: systemTheme,
          useMaterial3: true,
        ),
        home: const MyHomePage(),
        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      );
    });
  }
}

class AddServerPage extends StatelessWidget {
  const AddServerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MyAddServerPage();
  }
}

class ConnectServerPage extends StatelessWidget {
  final String username;
  final String servername;
  final String url;
  final String password;

  const ConnectServerPage(this.username, this.servername, this.url, this.password, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyConnectServerPage(username, servername, url, password);
  }
}

class ChatPage extends StatelessWidget {
  final StreamController<List<int>> controller;
  final Socket socket;
  final String username;
  final String servername;
  final String url;
  final String password;

  const ChatPage(this.controller, this.socket, this.username, this.servername, this.url, this.password, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyChatPage(controller, socket, username, servername, url, password);
  }
}

class PublicServerPage extends StatelessWidget {
  const PublicServerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PublicServersPage();
  }
}

class AddPublicServerPage extends StatelessWidget {
  const AddPublicServerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MyAddPublicServerPage();
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MySettingsPage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class MyAddServerPage extends StatefulWidget {
  const MyAddServerPage({Key? key}) : super(key: key);

  @override
  State<MyAddServerPage> createState() => _MyAddServerPageState();
}

class MyConnectServerPage extends StatefulWidget {
  final String username;
  final String servername;
  final String url;
  final String password;

  const MyConnectServerPage(this.username, this.servername, this.url, this.password, {Key? key}) : super(key: key);

  @override
  State<MyConnectServerPage> createState() => _MyConnectServerPageState();
}

class MyChatPage extends StatefulWidget {
  final StreamController<List<int>> controller;
  final Socket socket;
  final String username;
  final String servername;
  final String url;
  final String password;

  const MyChatPage(this.controller, this.socket, this.username, this.servername, this.url, this.password, {Key? key}) : super(key: key);

  @override
  State<MyChatPage> createState() => _MyChatPageState();
}

class PublicServersPage extends StatefulWidget {
  const PublicServersPage({Key? key}) : super(key: key);

  @override
  State<PublicServersPage> createState() => _MyPublicServersPageState();
}

class MyAddPublicServerPage extends StatefulWidget {
  const MyAddPublicServerPage({Key? key}) : super(key: key);

  @override
  State<MyAddPublicServerPage> createState() => _MyAddPublicServerPageState();
}

class MySettingsPage extends StatefulWidget {
  const MySettingsPage({Key? key}) : super(key: key);

  @override
  State<MySettingsPage> createState() => _MySettingsPageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Locale appLocale = Localizations.localeOf(context);

  void didChangeLocales(List<Locale>? locale) {
    setState(() {
      appLocale = locale!.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (dis) {
        if (dis.delta.dx < 0) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => const PublicServerPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(getTranslation('Home page', appLocale)),
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          children: [
            for (var server in servers)
              Card(
                child: ListTile(
                  title: Text(server.servername),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.connect_without_contact_rounded),
                    alignment: Alignment.centerRight,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConnectServerPage(
                            server.username,
                            server.servername,
                            server.url,
                            server.password,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddServerPage()),
            ).then((_) {
              setState(() {});
            });
          },
          child: const Icon(Icons.add_rounded),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: getTranslation('Home', appLocale)
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.public_rounded),
              label: getTranslation('Public servers', appLocale),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_rounded),
              label: getTranslation('Settings', appLocale),
            )
          ],
          onTap: (index) {
            switch (index) {
              case 0: {
                break;
              }
              case 1: {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => const PublicServerPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );

                break;
              }
              case 2: {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => const SettingsPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );

                break;
              }
            }
          },
        ),
      ),
    );
  }
}

class _MyAddServerPageState extends State<MyAddServerPage> {
  late Locale appLocale = Localizations.localeOf(context);
  final _formKey = GlobalKey<FormState>();
  late String _name = '';
  late String _servername = '';
  late String _url = '';
  late String _password = '';

  void didChangeLocales(List<Locale>? locale) {
    setState(() {
      appLocale = locale!.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslation('Add server', appLocale)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    hintText: getTranslation('Username', appLocale),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return getTranslation('Please enter your username', appLocale);
                    }

                    if (value.length > 16) {
                      return getTranslation('It must be smaller than 16 characters', appLocale);
                    }

                    return null;
                  },
                  onSaved: (value) => _name = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    hintText: getTranslation('Server name', appLocale),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return getTranslation('Please enter a server name', appLocale);
                    }

                    if (value.length > 16) {
                      return getTranslation('Server name must be smaller than 16 characters', appLocale);
                    }

                    return null;
                  },
                  onSaved: (value) => _servername = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    hintText: getTranslation('Server URL', appLocale),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return getTranslation('Please enter a server URL', appLocale);
                    }

                    if (!isValidUrl(value)) {
                      return getTranslation('Please enter a valid URL', appLocale);
                    }

                    return null;
                  },
                  onSaved: (value) => _url = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    hintText: getTranslation('Password', appLocale),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 2,
                      ),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return getTranslation('Please enter a password', appLocale);
                    }

                    return null;
                  },
                  onSaved: (value) => _password = value!,
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final newServer = Server(
                        username: _name,
                        servername: _servername,
                        url: _url,
                        password: _password,
                      );

                      servers.add(newServer);
                      addServer(newServer);
                      
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MyConnectServerPageState extends State<MyConnectServerPage> {
  late Locale appLocale = Localizations.localeOf(context);

  void didChangeLocales(List<Locale>? locale) {
    setState(() {
      appLocale = locale!.first;
    });
  }

  @override
  void initState() {
    super.initState();

    Socket.connect(widget.url, 8888).then((socket) {
      socket.write("{\"op\":\"auth\",\"password\":\"${widget.password}\",\"username\":\"${widget.username}\"}");

      StreamController<List<int>> controller = StreamController<List<int>>.broadcast();

      socket.listen((data) {
        controller.add(data);
      }, onDone: () {
        controller.close();
      }, onError: (error) {
        controller.close();

        Navigator.of(context)..pop()..pop();
      });

      StreamSubscription<List<int>>? subscription;

      subscription = controller.stream.listen((payload) {
        final payloadString = utf8.decode(payload);
        final data = AuthResponse.fromJson(jsonDecode(payloadString) as Map<String, dynamic>);

        if (data.op == 'auth') {
          if (data.status == 'ok') {
            subscription?.cancel();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  controller,
                  socket,
                  widget.username,
                  widget.servername,
                  widget.url,
                  widget.password,
                ),
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (dialogContext) {
                socket.destroy();

                return WillPopScope(
                  onWillPop: () async {
                    Navigator.of(dialogContext)..pop()..pop();

                    return false;
                  },
                  child: AlertDialog(
                    title: Text(getTranslation('Error', appLocale)),
                    content: Text(getTranslation('Incorrect password.', appLocale)),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext)..pop()..pop();
                        },
                        child: Text(getTranslation('OK', appLocale)),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        }
      });
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.of(dialogContext)..pop()..pop();

              return true;
            },
            child: AlertDialog(
              title: Text(getTranslation('Error', appLocale)),
              content: Text(error.toString()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext)..pop()..pop();
                  },
                  child: Text(getTranslation('OK', appLocale)),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          title: Text(getTranslation('Connecting to server', appLocale)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(getTranslation('Connecting to server...', appLocale)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyChatPageState extends State<MyChatPage> {
  late Locale appLocale = Localizations.localeOf(context);
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<MessageList> _messages = [];

  void didChangeLocales(List<Locale>? locale) {
    setState(() {
      appLocale = locale!.first;
    });
  }

  @override
  void dispose() {
    widget.socket.destroy();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    widget.controller.stream.listen((payload) {
      final payloadString = utf8.decode(payload);
      final jsons = payloadString.split('\n');
      final jsonsLength = jsons.length;

      for (var i = 0; i < jsonsLength; i++) {
        final data = jsonDecode(payloadString) as Map<String, dynamic>;

        final op = data['op'] as String;

        switch (op) {
          case 'msg':
            final message = Message.fromJson(data);

            setState(() {
              _addMessage(MessageList(
                msg: message.msg,
                author: message.author,
                authorId: message.authorId,
              ));
            });

            break;
          case 'userJoin':
            final userJoin = UserLog.fromJson(data);

            setState(() {
              _addMessage(MessageList(
                msg: '${userJoin.username} ${getTranslation('joined the chat.', appLocale)}',
                author: getTranslation('Server\'s system', appLocale),
                authorId: -1,
              ));
            });

            break;
          case 'userLeave':
            final userLeave = UserLog.fromJson(data);

            setState(() {
              _addMessage(MessageList(
                msg: '${userLeave.username} ${getTranslation('left the chat.', appLocale)}',
                author: getTranslation('Server\'s system', appLocale),
                authorId: -1,
              ));
            });

            break;
        }
      }
    });

    _textController.addListener(() {
      setState(() {});
    });
  }

  void _addMessage(MessageList message) {
    final messagesFinal = _messages.length - 1;
    if (messagesFinal != -1 && _messages[messagesFinal].authorId == message.authorId) {
      setState(() {
        _messages[messagesFinal].msg += '\n${message.msg}';
      });
    } else {
      setState(() {
        _messages.add(message);
      });
    }

    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - (MediaQuery.of(context).size.height / 2)) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + MediaQuery.of(context).size.height * 0.1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_textController.text.isEmpty) return;

    widget.socket.write("{\"op\":\"msg\",\"msg\":\"${_textController.text}\"}");

    _addMessage(MessageList(
      msg: _textController.text,
      author: widget.username,
      authorId: -2,
    ));

    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.servername),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];

                    if (message.authorId == -1) {
                      return ListTile(
                        title: Row(
                          children: [
                            Text(message.author),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                getTranslation('SYSTEM', appLocale),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(message.msg),
                      );
                    } else {
                      return ListTile(
                        title: Text(message.author),
                        subtitle: Text(message.msg),
                      );
                    }
                  },
                ),
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    width: orientation == Orientation.portrait
                        ? MediaQuery.of(context).size.width * 0.79
                        : MediaQuery.of(context).size.width * 0.901,
                    height: orientation == Orientation.portrait
                        ? MediaQuery.of(context).size.height * 0.06
                        : MediaQuery.of(context).size.height * 0.135,
                    child: TextFormField(
                      controller: _textController,
                      autofocus: true,
                      textInputAction: TextInputAction.send,
                      onFieldSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        hintText: getTranslation('Type a message', appLocale),
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: _textController.text.isEmpty ? null : _sendMessage,
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MyPublicServersPageState extends State<PublicServersPage> {
  late Locale appLocale = Localizations.localeOf(context);
  final _textController = TextEditingController();
  late String _username = '';

  void didChangeLocales(List<Locale>? locale) {
    setState(() {
      appLocale = locale!.first;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (dis) {
        if (dis.delta.dx > 0) {
          Navigator.pop(context);
        } else if (dis.delta.dx < 0) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => const SettingsPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(getTranslation('Public servers', appLocale)),
          automaticallyImplyLeading: false,
        ),
        body: publicServers.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            return getPublicServers().then((updatedServers) {
              setState(() {
                publicServers = updatedServers;
              });
            });
          },
          child: ListView(
            children: [
              for (var server in publicServers)
                Card(
                  child: ListTile(
                    title: Text(server.servername),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.connect_without_contact_rounded),
                      alignment: Alignment.centerRight,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return WillPopScope(
                              onWillPop: () async {
                                _textController.clear();

                                return true;
                              },
                              child: AlertDialog(
                                title: Text(getTranslation('Enter your username', appLocale)),
                                content: TextFormField(
                                  controller: _textController,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Theme.of(context).colorScheme.surface,
                                    hintText: getTranslation('Username', appLocale),
                                    contentPadding: const EdgeInsets.all(16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).colorScheme.surfaceVariant,
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).colorScheme.surfaceVariant,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return getTranslation('Please enter your username', appLocale);
                                    }

                                    if (value.length > 16) {
                                      return getTranslation('It must be smaller than 16 characters', appLocale);
                                    }

                                    return null;
                                  },
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  onSaved: (value) => _username = value!,    
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);

                                      _textController.clear();
                                    },
                                    child: Text(getTranslation('Cancel', appLocale)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (_username.isEmpty || _username.length > 16) return;
                                      
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ConnectServerPage(
                                            _username,
                                            server.servername,
                                            server.url,
                                            server.password,
                                          ),
                                        ),
                                      );

                                      _textController.clear();
                                    },
                                    child: Text(getTranslation('Connect', appLocale)),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ) : FutureBuilder<List<PublicServer>>(
          future: getPublicServers(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final serversData = snapshot.data!;

              if (serversData.isEmpty) {
                return LayoutBuilder(
                  builder: (context, constraints) => RefreshIndicator(
                    onRefresh: () async {
                      return getPublicServers().then((updatedServers) {
                        setState(() {
                          publicServers = updatedServers;
                        });
                      });
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [ Text(getTranslation('No public servers was found', appLocale)) ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              publicServers = serversData;

              return RefreshIndicator(
                onRefresh: () async {
                  return getPublicServers().then((updatedServers) {
                    setState(() {
                      publicServers = updatedServers;
                    });
                  });
                },
                child: ListView(
                  children: [
                    for (var server in serversData)
                      Card(
                        child: ListTile(
                          title: Text(server.servername),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.connect_without_contact_rounded),
                            alignment: Alignment.centerRight,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return WillPopScope(
                                    onWillPop: () async {
                                      _textController.clear();

                                      return true;
                                    },
                                    child: AlertDialog(
                                      title: Text(getTranslation('Enter your username', appLocale)),
                                      content: TextFormField(
                                        controller: _textController,
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Theme.of(context).colorScheme.surface,
                                          hintText: getTranslation('Username', appLocale),
                                          contentPadding: const EdgeInsets.all(16),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(width: 2),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                              color: Theme.of(context).colorScheme.surfaceVariant,
                                              width: 2,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                              color: Theme.of(context).colorScheme.surfaceVariant,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return getTranslation('Please enter your username', appLocale);
                                          }

                                          if (value.length > 16) {
                                            return getTranslation('It must be smaller than 16 characters', appLocale);
                                          }

                                          return null;
                                        },
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        onSaved: (value) => _username = value!,    
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);

                                            _textController.clear();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            if (_username.isEmpty || _username.length > 16) return;

                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ConnectServerPage(
                                                  _username,
                                                  server.servername,
                                                  server.url,
                                                  server.password,
                                                ),
                                              ),
                                            );

                                            _textController.clear();
                                          },
                                          child: const Text('Connect'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPublicServerPage()),
            );
          },
          child: const Icon(Icons.add_rounded),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: getTranslation('Home', appLocale),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.public_rounded),
              label: getTranslation('Public servers', appLocale),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_rounded),
              label: getTranslation('Settings', appLocale),
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0: {
                Navigator.pop(context);

                break;
              }
              case 1: {
                break;
              }
              case 2: {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => const SettingsPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );

                break;
              }
            }
          },
        ),
      ),
    );
  }
}

class _MyAddPublicServerPageState extends State<MyAddPublicServerPage> {
  late Locale appLocale = Localizations.localeOf(context);
  final _formKey = GlobalKey<FormState>();
  late String _email = '';
  late String _servername = '';
  late String _url = '';
  late String _password = '';

  void didChangeLocales(List<Locale>? locale) {
    setState(() {
      appLocale = locale!.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslation('Add public server', appLocale)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    hintText: getTranslation('Email', appLocale),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return getTranslation('Please enter your email', appLocale);
                    }

                    if (!value.contains('@')) {
                      return getTranslation('Please enter a valid email', appLocale);
                    }

                    return null;
                  },
                  onSaved: (value) => _email = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    hintText: getTranslation('Server name', appLocale),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return getTranslation('Please enter a server name', appLocale);
                    }

                    if (value.length > 16) {
                      return getTranslation('Server name must be smaller than 16 characters', appLocale);
                    }

                    return null;
                  },
                  onSaved: (value) => _servername = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    hintText: getTranslation('Server URL', appLocale),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return getTranslation('Please enter a server URL', appLocale);
                    }

                    return null;
                  },
                  onSaved: (value) => _url = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    hintText: getTranslation('Password', appLocale),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        width: 2,
                      ),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return getTranslation('Please enter a password', appLocale);
                    }

                    return null;
                  },
                  onSaved: (value) => _password = value!,
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      // Socket.connect("the-main-server.performancorgan.repl.co", 7777).then((socket) {
                      //   socket.write('{"op":"addServer","email":"$_email","servername":"$_servername","url":"$_url","password":"$_password"}');
                      //   socket.close();
                      // });

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(getTranslation('Adding server...', appLocale)),
                          content: const LinearProgressIndicator(),
                        ),
                      );

                      HttpClient()
                        .getUrl(Uri.parse('https://the-main-server.performancorgan.repl.co/addServer?email=$_email&servername=$_servername&url=$_url&password=$_password'))
                        .then((request) {
                          request.close();

                          Navigator.of(context)..pop()..pop();
                        });
                    }
                  },
                  child: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MySettingsPageState extends State<MySettingsPage> {
  late Locale appLocale = Localizations.localeOf(context);

  void didChangeLocales(List<Locale>? locale) {
    setState(() {
      appLocale = locale!.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (dis) {
        if (dis.delta.dx > 0) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => const PublicServerPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(getTranslation('Settings', appLocale)),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('...')
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: getTranslation('Home', appLocale),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.public_rounded),
              label: getTranslation('Public Servers', appLocale),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_rounded),
              label: getTranslation('Settings', appLocale),
            )
          ],
          onTap: (index) {
            switch (index) {
              case 0: {
                Navigator.pop(context);

                break;
              }
              case 1: {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => const PublicServerPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );

                break;
              }
              case 2: {
                break;
              }
            }
          },
        ),
      ),
    );
  }
}