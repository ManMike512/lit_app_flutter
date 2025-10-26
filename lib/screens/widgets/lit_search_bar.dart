import 'package:flutter/material.dart';
import 'package:lit_reader/controllers/search_controller.dart' as litController;

class LitSearchBar extends StatelessWidget {
  const LitSearchBar({
    super.key,
    required this.formKey,
    // this.initialValue,
    this.searchFieldTextController,
    this.litSearchController,
    this.onChanged,
    this.margin = 10,
    this.labelText = 'Search',
    this.prefixIcon = Icons.search,
  });
  final GlobalKey<FormState> formKey;
  // final String? initialValue;
  final TextEditingController? searchFieldTextController;
  final litController.SearchController? litSearchController;

  final void Function()? onChanged;
  final double margin;
  final String? labelText;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: margin),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: TextFormField(
                controller: searchFieldTextController,
                // initialValue: initialValue, //searchController.searchTerm,
                textInputAction: TextInputAction.search,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 3) {
                    return 'Please enter atleast 3 characters';
                  }
                  return null;
                },
                onChanged: onChanged != null
                    ? (value) {
                        onChanged!();
                      }
                    : null,
                onFieldSubmitted: (value) {
                  if (formKey.currentState!.validate() && litSearchController != null) {
                    litSearchController!.searchTerm = value;
                  }
                },
                decoration: InputDecoration(
                  labelText: labelText,
                  border: InputBorder.none,
                  prefixIcon: Icon(prefixIcon),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      if (searchFieldTextController != null) {
                        searchFieldTextController!.text = "";
                        if (onChanged != null) {
                          onChanged!();
                        }
                      } else if (litSearchController != null) {
                        litSearchController!.searchTerm = "";
                        formKey.currentState!.reset();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
