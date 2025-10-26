import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/screens/widgets/empty_list_indicator.dart';
import 'package:lit_reader/screens/widgets/list_item.dart';
import 'package:lit_reader/screens/widgets/list_item_list_view.dart';

class ListsListView extends StatefulWidget {
  const ListsListView({super.key});

  @override
  State createState() => _ListsListViewState();
}

class _ListsListViewState extends State<ListsListView> {
  @override
  void initState() {
    if (listController.list.isEmpty) {
      listController.fetchLists();
    }
    super.initState();
  }

  void openList(String listName, String urlname) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ListItemListView(
                  listName: listName,
                  urlname: urlname,
                ))).then((value) {});
  }

  Future<void> _refresh() async {
    await listController.fetchLists();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (listController.list.isEmpty && listController.isBusy) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (listController.list.isEmpty && !listController.isBusy) {
                    return const Center(
                        child: EmptyListIndicator(
                      subtext: "You dont have any lists",
                    ));
                  }

                  return ListView.builder(
                      itemBuilder: (context, index) {
                        return ListItem(openList: openList, list: listController.list[index]);
                      },
                      itemCount: listController.list.length);
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
