class TS3Reply {
  final Map<String, String> errors = {};
  final List<Map<String, String>> data = [];

  TS3Reply(Map<String, String> error, List<Map<String, String>> splice) {
    errors.addAll(error);
    data.addAll(splice);
  }
}