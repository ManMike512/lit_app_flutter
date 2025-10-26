import 'package:get/get.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/favorite_lists.dart';

class ListController extends GetxController {
  final _list = <Lists>[].obs;

  List<Lists> get list => _list;
  set list(List<Lists> value) => _list.value = value;

  final _isBusy = false.obs;

  bool get isBusy => _isBusy.value;
  set isBusy(bool value) => _isBusy.value = value;

  void updateList(int listId, {bool increment = true}) {
    List<Lists> newList = List.from(list);
    final index = newList.indexWhere((element) => element.id == listId);
    if (index != -1) {
      Lists listItem = newList[index];
      Lists updatedListItem = listItem.copyWith(storiesCount: increment ? listItem.storiesCount + 1 : listItem.storiesCount - 1);
      newList[index] = updatedListItem;
      list = newList;
    }
  }

  Future<void> fetchLists() async {
    isBusy = true;
    list = await api.getLists();
    isBusy = false;
  }
}
