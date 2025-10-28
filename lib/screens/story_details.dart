import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:lit_reader/classes/search_config.dart';
import 'package:lit_reader/data/categories.dart';
import 'package:lit_reader/env/colors.dart';
import 'package:lit_reader/env/consts.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/submission.dart';
import 'package:lit_reader/screens/author.dart';
import 'package:lit_reader/screens/authors_stories.dart';
import 'package:lit_reader/screens/series.dart';
import 'package:lit_reader/screens/similar.dart';
import 'package:lit_reader/screens/widgets/bookmarks_popup_menu.dart';
import 'package:lit_reader/screens/widgets/lit_badge.dart';
import 'package:lit_reader/screens/widgets/lit_tags.dart';
import 'package:moon_design/moon_design.dart';
import 'package:url_launcher/url_launcher.dart';

class StoryDetailsScreen extends StatefulWidget {
  const StoryDetailsScreen({super.key, required this.submission});

  final Submission submission;

  @override
  State<StoryDetailsScreen> createState() => _StoryDetailsScreenState();
}

class _StoryDetailsScreenState extends State<StoryDetailsScreen> {
  bool isBusy = true;
  late List<int> existingLists;
// Author? author;

  @override
  void initState() {
    super.initState();
    setInitState();
  }

  Future<void> setInitState() async {
    await api.getListsWithStory((widget.submission).id.toString()).then((value) {
      setState(() {
        existingLists = value;
        isBusy = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  void updateExistingLists(List<int> newLists) {
    setState(() {
      existingLists = newLists;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isBusy) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
        actions: [
          if (loginController.loginState == LoginState.loggedIn)
            IconButton(
              onPressed: () async {
                await showMoonModalBottomSheet(
                  enableDrag: true,
                  height: MediaQuery.of(context).size.height * 0.75,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  context: context,
                  builder: (BuildContext context) {
                    return BookmarksPopupMenu(
                        submission: widget.submission,
                        existingLists: existingLists,
                        onUpdateLists: updateExistingLists,
                        context: context);
                  },
                );
              },
              icon: existingLists.isEmpty
                  ? const Icon(Icons.bookmark_border)
                  : const Icon(
                      Icons.bookmark,
                      color: kRed,
                    ),
            ),
          IconButton(
            onPressed: () {
              _launchInBrowser(Uri.parse("${litUrl}s/${widget.submission.url}"));
            },
            icon: const Icon(Icons.link),
          ),
        ],
      ),
      body: SafeArea(
        child: body(),
      ),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.submission.title, style: const TextStyle(fontSize: 25)),
          const SizedBox(height: 10),
          Text(
            widget.submission.description,
            style: const TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            children: [
              litButton("Chapters", () {
                knavigatorKey.currentState!.push(MaterialPageRoute(
                    builder: (context) => SeriesScreen(
                          story: widget.submission,
                        )));
              }),
              const SizedBox(width: 10),
              if (widget.submission.author != null)
                litButton("By Author", () {
                  knavigatorKey.currentState!.push(MaterialPageRoute(
                      builder: (context) => AuthorsStoriesScreen(
                            author: widget.submission.author!,
                          )));
                }),
              const SizedBox(width: 10),
              litButton("Similar Stories", () {
                knavigatorKey.currentState!.push(MaterialPageRoute(
                    builder: (context) => SimilarScreen(
                          story: widget.submission,
                        )));
              }),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (widget.submission.isNew) const LitBadge(text: 'New', color: kNewTag),
              if (widget.submission.isHot) const LitBadge(text: 'Hot', color: kHotTag),
              if (widget.submission.writersPick) const LitBadge(text: 'Writers Pick', color: kWriterTag),
              if (widget.submission.contestWinner == 1) const LitBadge(text: 'Contest Winner', color: kWinnerTag),
            ],
          ),
          const SizedBox(height: 10),
          if (widget.submission.author != null)
            litLabelTextRow(
              "Author",
              trailing: GestureDetector(
                onTap: () {
                  print(widget.submission.author!.userid.toString());
                  knavigatorKey.currentState!.push(MaterialPageRoute(
                      builder: (context) => AuthorScreen(
                            author: widget.submission.author!,
                          )));
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: AutoSizeText(
                        widget.submission.author!.username,
                        style: const TextStyle(
                          color: kRed,
                          fontSize: 25,
                        ),
                        maxLines: 1,
                        minFontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.open_in_new, size: 12)
                  ],
                ),
              ),
            ),
          litLabelTextRow(
            "Category",
            value: litSearchController.categories.where((cat) => cat.id == widget.submission.category).first.name,
            fontSize: 16,
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
              Category category = litSearchController.categories.where((cat) => cat.id == widget.submission.category).first;

              SearchConfig searchConfig = SearchConfig.categorySearch(
                selectedCategory: category.id,
                random: true,
              );

              litSearchController.selectedCategory = [category.id.toString()];
              navigateToSearch(searchConfig);
            },
          ),
          if (widget.submission.tags.isNotEmpty)
            litLabelTextRow(
              "Tags",
              trailing: Wrap(
                spacing: 4,
                children: [
                  for (var tag in widget.submission.tags)
                    LitTags(
                      tag: tag,
                      height: 2,
                      onTap: () {
                        Navigator.popUntil(context, ModalRoute.withName('/'));

                        SearchConfig searchConfig = SearchConfig.tagSearch(
                          tagList: [tag.tag],
                        );

                        navigateToSearch(searchConfig);
                      },
                    )
                ],
              ),
              fontSize: 16,
            ),
          litLabelTextRow("Rating", value: widget.submission.rateAll.toString(), fontSize: 16),
          litLabelTextRow("Views", value: widget.submission.viewCount.toString(), fontSize: 16),
          litLabelTextRow("Date", value: widget.submission.dateApprove, fontSize: 16),
        ],
      ),
    );
  }

  Widget litLabelTextRow(String title,
      {double fontSize = 18, String? value, Widget? trailing, double height = 1.6, Function()? onTap}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          "$title: ",
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
        if (trailing != null) Flexible(child: trailing),
        if (trailing == null && value != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              value,
              style: TextStyle(
                height: height,
                fontSize: fontSize,
                color: kRed,
              ),
            ),
          ),
      ],
    );
  }

  OutlinedButton litButton(String text, Function() onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: kRed,
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.black),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
