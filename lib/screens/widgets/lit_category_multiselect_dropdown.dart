import 'package:flutter/material.dart';
import 'package:lit_reader/controllers/search_controller.dart' as litcontroller;
import 'package:lit_reader/data/categories.dart';
import 'package:lit_reader/env/colors.dart';
import 'package:lit_reader/env/global.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class LitMultiCategories extends StatefulWidget {
  const LitMultiCategories({
    super.key,
    required this.searchController,
  });
  final litcontroller.SearchController searchController;

  @override
  State<LitMultiCategories> createState() => _LitMultiCategoriesState();
}

class _LitMultiCategoriesState extends State<LitMultiCategories> {
  int? selectValue;
  List<Category> categoryItems = [];
  final MultiSelectController<Category> _controller = MultiSelectController();

  @override
  void initState() {
    super.initState();
    // print(categories.length);
    // categories.sort((a, b) => a.name.compareTo(b.name));
    categoryItems = litSearchController.categories;
    Category? allCatItem = categoryItems.where((cat) => cat.id == 1).firstOrNull;
    if (allCatItem != null && categoryItems.indexOf(allCatItem) != 0) {
      categoryItems.removeAt(categoryItems.indexOf(allCatItem));
      categoryItems.insert(0, allCatItem);
    }

    selectValue = categoryItems.firstOrNull?.id ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Categories"),
        const SizedBox(height: 20),
        MultiDropdown<Category>(
          // showClearIcon: false,
          controller: _controller,
          onSelectionChange: (options) {
            widget.searchController.selectedCategory = [
              ...options.where((option) => option.id != 1).map((option) => option.id.toString())
            ];
          },
          items: categoryItems.map((category) {
            return DropdownItem<Category>(
              value: category,
              label: category.name,
              selected: widget.searchController.selectedCategory.contains(category.id.toString()) ||
                  (widget.searchController.selectedCategory.isEmpty && category.id == 1),
            );
          }).toList(),
          dropdownItemDecoration: DropdownItemDecoration(
            selectedIcon: const Icon(Icons.check_circle),
            selectedTextColor: Colors.white,
            selectedBackgroundColor: kRed,
            backgroundColor: Colors.black87,
          ),
          dropdownDecoration: DropdownDecoration(
            backgroundColor: Colors.transparent,
            maxHeight: 300,
            borderRadius: BorderRadius.circular(10),
          ),
          singleSelect: widget.searchController.searchTags,
          chipDecoration: ChipDecoration(
            backgroundColor: kRed,
            borderRadius: BorderRadius.circular(10),
            // padding: const EdgeInsets.all( 5),
          ),
          // selectedOptions: [
          //   ...categoryItems.where((cat) => widget.searchController.selectedCategory.isNotEmpty
          //       ? (widget.searchController.selectedCategory.contains(cat.value) && cat.value != "1")
          //       : cat.value == "1")
          // ],

          // fieldBackgroundColor: Colors.transparent,

          // chipConfig: const ChipConfig(
          //   wrapType: WrapType.wrap,
          //   runSpacing: 0,
          //   padding: EdgeInsets.all(5),
          //   backgroundColor: kred,
          // ),
        ),
      ],
    );
  }
}
