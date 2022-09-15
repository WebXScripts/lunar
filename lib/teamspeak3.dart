import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'logger.dart';
import 'data/ts_reply.dart';
import 'interval/channel_clients_online.dart';
import 'models/channel.dart';

class TeamSpeak3 {

  late Logger _logger;
  late Socket _client;

  final Queue<String> _queue = Queue();
  final Queue<Completer<TS3Reply>> _replyQueue = Queue();

  TeamSpeak3() {
    _logger = Logger('TeamSpeak3');
  }

  _onData(Uint8List data) {
    String decoded = ascii.decode(data).replaceAll('\r', '').trim();
    var values = <String, String>{};
    var splice = <Map<String, String>>[];

    var lines = decoded.split('\n');
    for (var line in lines) {
      if (line.startsWith('error')) {
        var params = line.substring(6).split(' ');
        for (var param in params) {
          final pos = param.indexOf('=');
          if (pos == -1) {
            values[param] = '';
            continue;
          }
          values[param.substring(0, pos)] = param.substring(pos + 1);
        }
      } else {
        var sections = line.split('|');
        for (var section in sections) {
          var sectionMap = <String, String>{};
          var params = section.split(' ');
          for (var param in params) {
            final pos = param.indexOf('=');
            if (pos == -1) {
              sectionMap[param] = '';
              continue;
            }
            sectionMap[param.substring(0, pos)] = param.substring(pos + 1);
          }
          splice.add(sectionMap);
        }
      }
    }
    _replyQueue.removeFirst().complete(TS3Reply(values, splice));
    _processQueue();
  }

  void connect() async {
    _logger.log('Connecting to TeamSpeak3 server...');
    _client = await Socket.connect('localhost', 10011)
      ..listen(_onData);

    await login(
        username: 'serveradmin',
        password: 'cyckSZY8'
    );

    await useServer(1);
    await setNickname('Lunar');
    await sendMsg('Hello World!');

    Timer.periodic(Duration(minutes: 4, seconds: 50), (_) {
      _sendCommand('whoami');
    });

    Timer.periodic(Duration(seconds: 15), (_) {
      ChannelClientsOnline.make(this);
    });

  }

  Future<TS3Reply> login({required String username, required String password}) async {
    return await _sendCommand('login $username $password');
  }

  Future<TS3Reply> useServer(int serverId) async {
    return await _sendCommand('use $serverId');
  }

  Future<TS3Reply> setNickname(String nickname) async {
    return await _sendCommand('clientupdate client_nickname=$nickname');
  }

  Future<TS3Reply> sendMsg(String message) async {
    return await _sendCommand('sendtextmessage targetmode=3 target=1 msg=$message');
  }

  Future<TS3Reply> serverInfo() async {
    return await _sendCommand('serverinfo');
  }

  Future<TS3Reply> clientList() async {
    return await _sendCommand('clientlist');
  }

  Future<TS3Reply> editChannel(Channel channel) async {
    return await _sendCommand('channeledit cid=${channel.channelId} channel_name=${channel.channelName}');
  }

  Future<TS3Reply> _sendCommand(String command) {
    var completer = Completer<TS3Reply>();
    _queue.add(command);
    _replyQueue.add(completer);
    _processQueue();
    return completer.future;
  }

  void _processQueue() {
    if (_queue.length != _replyQueue.length) {
      return;
    }

    if (_queue.isNotEmpty) {
      var data = _queue.removeFirst();
      _client.write("$data\n");
    }
  }
}