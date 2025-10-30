import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:lit_reader/env/colors.dart';
import 'package:lit_reader/env/consts.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/favorite_list_item.dart';
import 'package:lit_reader/models/favorite_lists.dart';
import 'package:lit_reader/models/submission.dart';

class BookmarksPopupMenu extends StatefulWidget {
  const BookmarksPopupMenu(
      {super.key, required this.submission, required this.existingLists, required this.onUpdateLists, required this.context});
  final Submission submission;
  final BuildContext context;

  final List<int> existingLists;
  final Function(List<int>) onUpdateLists;

  @override
  State<BookmarksPopupMenu> createState() => _BookmarksPopupMenuState();
}

class _BookmarksPopupMenuState extends State<BookmarksPopupMenu> {
  List<FavoriteListItem> favoriteitems = [];
  List<int> get existingLists => widget.existingLists;

  @override
  void initState() {
    super.initState();
    fetchListData();
  }

  @override
  Widget build(context) {
    // late PageController controller;
    // ScrollController scrollController = ScrollController();
    return Obx(() {
      if (listController.isBusy) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            Text("Lists", style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            if (favoriteitems.isEmpty) Text("No lists available", style: Theme.of(context).textTheme.bodyLarge),
            if (favoriteitems.isNotEmpty)
              SingleChildScrollView(
                  child:
                      Material(child: Column(children: [...favoriteitems.map((listitem) => favoriteItem(listitem, context))]))),
          ],
        ),
      );
    });
  }

  Future<void> fetchListData() async {
    if (loginController.loginState == LoginState.loggedOut) {
      return;
    }

    if (listController.list.isEmpty) {
      listController.list = await api.getLists();
    }
    List<Lists> lists = listController.list;

    setState(() {
      favoriteitems = lists.map((list) {
        return FavoriteListItem(
          inList: existingLists.contains(list.id),
          list: list,
        );
      }).toList();
    });
  }

  Widget favoriteItem(FavoriteListItem listitem, BuildContext context) {
    return InkWell(
      onTap: () async {
        bool success = await api.toggleListItem(widget.submission.id, listitem.list.id, !listitem.inList);
        if (!success) {
          return;
        }
        int index = favoriteitems.indexOf(listitem);

        FavoriteListItem updatedItem = FavoriteListItem(
          inList: !listitem.inList,
          list: listitem.list,
        );

        List<int> updatedLists = List.from(existingLists);
        if (updatedItem.inList) {
          updatedLists.add(updatedItem.list.id);
        } else {
          updatedLists.remove(updatedItem.list.id);
        }

        listController.updateList(widget.submission.id, increment: updatedItem.inList);

        widget.onUpdateLists(updatedLists);

        setState(() {
          favoriteitems[index] = updatedItem;
        });
      },
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
        child: Row(
          children: [
            listitem.inList
                ? const Icon(
                    Icons.bookmark,
                    color: kRed,
                  )
                : const Icon(
                    Icons.bookmark_border,
                    color: Colors.white,
                  ),
            Text(listitem.list.title, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
