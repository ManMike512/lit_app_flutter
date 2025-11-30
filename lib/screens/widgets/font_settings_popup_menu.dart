import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:lit_reader/env/colors.dart';
import 'package:lit_reader/env/global.dart';

class FontSettingsPopupMenu extends StatefulWidget {
  const FontSettingsPopupMenu({super.key, required this.context});

  final BuildContext context;

  @override
  State<FontSettingsPopupMenu> createState() => _FontSettingsPopupMenuState();
}

class _FontSettingsPopupMenuState extends State<FontSettingsPopupMenu> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    // late PageController controller;
    // ScrollController scrollController = ScrollController();

    return Obx(() {
      List colourOptions = [
        Theme.of(context).colorScheme.onSurfaceVariant,
        Theme.of(context).colorScheme.onSurface,
        Theme.of(context).colorScheme.secondary,
      ];
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
            Text("Font Settings", style: Theme.of(context).textTheme.headlineSmall),
            SingleChildScrollView(
                child: Material(
                    child: Column(children: [
              Row(
                children: [
                  const Icon(
                    Icons.format_size,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text('Font Size'),
                  Expanded(
                    child: Slider(
                      min: 10,
                      max: 30,
                      divisions: 20,
                      value: uiController.fontSize,
                      onChanged: (v) => uiController.fontSize = v,
                      activeColor: kRed,
                    ),
                  ),
                  Text(uiController.fontSize.toStringAsFixed(0)),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.format_line_spacing,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text('Line Height'),
                  Expanded(
                    child: Slider(
                      min: 1.0,
                      max: 3.0,
                      divisions: 20,
                      value: uiController.lineHeight,
                      onChanged: (v) => uiController.lineHeight = v,
                      activeColor: kRed,
                    ),
                  ),
                  Text(uiController.lineHeight.toStringAsFixed(2)),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.format_color_text,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text('Font Colour'),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: List.generate(colourOptions.length, (index) {
                        final color = colourOptions[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              // Store the index of the selected color
                              uiController.fontColor = index;

                              setState(() {});
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: uiController.fontColor == index
                                    ? Border.all(
                                        color: kRed,
                                        width: 3,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              // SizedBox(height: 8),
              // Row(
              //   children: [
              //     const Icon(
              //       Icons.brightness_6,
              //       color: Colors.white,
              //     ),
              //     const SizedBox(width: 8),
              //     const Text('Dark Mode'),
              //     const Spacer(),
              //     Obx(() => Switch(
              //           value: themeMode.value == ThemeMode.dark,
              //           onChanged: (val) {
              //             uiController.toggleDarkMode();
              //           },
              //         )),
              //   ],
              // ),
            ]))),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }
}
