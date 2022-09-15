class ServerInfo {
  String virtualServerName;
  int virtualServerClientsOnline;
  int virtualServerClientsMax;

  ServerInfo({required this.virtualServerName,
    required this.virtualServerClientsOnline,
    required this.virtualServerClientsMax,
  });
}