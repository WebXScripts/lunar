import 'package:lunar/logger.dart';
import 'package:lunar/teamspeak3.dart';

late Logger _logger;
late TeamSpeak3 _teamSpeak3;

void main() {
  _logger = Logger('main');
  _logger.log('TeamSpeak3 Bot preparing to start...');

  _teamSpeak3 = TeamSpeak3();
  _teamSpeak3.connect();
}


