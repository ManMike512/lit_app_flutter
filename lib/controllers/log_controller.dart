import 'package:get/get.dart';

class LogItem {
  final String log;
  final DateTime time;

  LogItem(this.log, this.time);

  @override
  String toString() => '$time: $log';
}

class LogController extends GetxController {
  final _logs = <LogItem>[].obs;
  List<LogItem> get logs => _logs.toList();

  int logLimit = 1000;

  void addLog(String log) {
    LogItem logItem = LogItem(log, DateTime.now());
    if (log.length > logLimit) {
      popLog();
    }
    _logs.add(logItem);
    print(logItem.toString());
  }

  void clearLogs() {
    _logs.clear();
  }

  void removeLog(int index) {
    _logs.removeAt(index);
  }

  void popLog() {
    if (logs.isNotEmpty) {
      _logs.removeAt(0);
    }
  }
}