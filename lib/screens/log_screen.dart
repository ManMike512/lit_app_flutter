import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lit_reader/controllers/log_controller.dart';
import 'package:lit_reader/env/global.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<List<LogItem>>? _logSubscription;
  bool _followTail = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      _followTail = position.pixels >= position.maxScrollExtent;
    });

    // Auto-scroll to the newest entry while the user is at the bottom.
    // This subscription must be cancelled in dispose(): it fires synchronously
    // from DioLoggingInterceptor, and touching a detached ScrollController
    // throws "Bad state: No element", which would fail every request.
    _logSubscription = logController.logsRx.listen((_) {
      if (!mounted || !_followTail) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Durations.long4, curve: Curves.easeInOut);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleSpacing: null,
        title: const Text('Logs'),
      ),
      body: Obx(
        () => SafeArea(
          child: Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  for (LogItem log in logController.logs)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${DateFormat('HH:mm:ss').format(log.time)}: ",
                            style: const TextStyle(color: Colors.greenAccent),
                          ),
                          Flexible(
                            child: Text(
                              log.log,
                              style: const TextStyle(color: Colors.white),
                              softWrap: true,
                              maxLines: 5000,
                            ),
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
