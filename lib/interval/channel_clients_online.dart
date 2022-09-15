import 'package:lunar/teamspeak3.dart';
import 'package:lunar/models/server_info.dart';
import 'package:lunar/models/channel.dart';

class ChannelClientsOnline {
  static make(TeamSpeak3 ts) async {
    var response = await ts.serverInfo();
    ServerInfo serverInfo = ServerInfo(
        virtualServerName: response.data[0]['virtualserver_name']!,
        virtualServerClientsMax: int.parse(response.data[0]['virtualserver_maxclients']!),
        virtualServerClientsOnline: int.parse(response.data[0]['virtualserver_clientsonline']!)
    );

    print(serverInfo.virtualServerClientsOnline.toString());

    var data = await ts.editChannel(Channel(
        channelId: 3,
        channelName: "Online: "
            "${serverInfo.virtualServerClientsOnline.toString()} "
            "/ "
            "${serverInfo.virtualServerClientsMax.toString()}".replaceAll(' ', r'\s')
    ));

    print(data.errors);
  }
}