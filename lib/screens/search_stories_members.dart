import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/screens/search.dart';
import 'package:lit_reader/screens/search_members.dart';

class SearchStoriesMembersScreen extends StatefulWidget {
  const SearchStoriesMembersScreen({super.key});

  @override
  State<SearchStoriesMembersScreen> createState() => _SearchStoriesMembersScreenState();
}

class _SearchStoriesMembersScreenState extends State<SearchStoriesMembersScreen> {
  List<Widget> widgetOptions = <Widget>[const SearchScreen(), const SearchMembersScreen()];
  @override
  Widget build(BuildContext context) {
    return Obx(() => widgetOptions.elementAt(litSearchController.selectedIndex));
  }
}
