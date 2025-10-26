import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:lit_reader/classes/db_helper.dart';
import 'package:lit_reader/env/colors.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/page.dart';
import 'package:lit_reader/models/read_history.dart';
import 'package:lit_reader/models/story.dart';
import 'package:lit_reader/models/story_download.dart';
import 'package:lit_reader/models/submission.dart';
import 'package:lit_reader/screens/story_details.dart';
import 'package:lit_reader/screens/widgets/bookmarks_popup_menu.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key, required this.submission});

  final Submission submission;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late Submission submission;

  late PageController controller;
  ScrollController scrollController = ScrollController();

  final List<StoryPage> pages = [];
  int initialPage = 0;
  int nextChapter = 0;
  bool hasNextChapter = false;
  bool isBusy = false;
  bool isFabVisible = false;
  List<int> existingLists = [];

  Future<void>? _fetchPagesFuture;

  bool isDownloaded = false;

  Future<void> setInitState({Submission? setSubmission}) async {
    controller = PageController();
    scrollController = ScrollController();
    initialPage = 0;
    nextChapter = 0;
    hasNextChapter = false;
    pages.clear();
    submission = setSubmission ?? widget.submission;
    if (submission.author?.homepage == null) {
      await api.getAuthor(submission.author!.userid).then((value) {
        setState(() {
          submission = submission.copyWithAuthor(author: value);
        });
      });
    }
    existingLists = await api.getListsWithStory((widget.submission).id.toString());
    _fetchPagesFuture = fetchPages(psubmission: submission).then((value) => setState(() {
          isBusy = false;
        }));
  }

  Future<void> fetchPages({Submission? psubmission}) async {
    psubmission ??= submission;
    controller.addListener(() => prefsFunctions.saveCurrentPage(submission: submission, controller: controller));
    scrollController
        .addListener(() => prefsFunctions.saveScrollPosition(submission: submission, scrollController: scrollController));

    DBHelper dbHelper = DBHelper();
    await dbHelper.init();
    List<StoryDownload> downloads = await dbHelper.getDownloads(psubmission.url);
    ReadHistory history = ReadHistory(
      url: psubmission.url,
      submission: psubmission,
    );
    await dbHelper.addHistory(psubmission.url, history);
    if (downloads.isNotEmpty) {
      StoryDownload download = downloads.first;
      // submission = widget.submission;
      setState(() {
        pages.addAll(download.pages);
        isDownloaded = true;
      });
      return;
    }
    List<Future<Story>> futures = [];

    Story firstPageStory = await api.getStory(psubmission.url, page: 1);
    hasNextChapter = firstPageStory.submission != null
        ? firstPageStory.submission!.series.meta.order.isNotEmpty &&
            firstPageStory.submission!.series.meta.order.lastOrNull != psubmission.id
        : false;
    int index = firstPageStory.submission != null
        ? firstPageStory.submission!.series.meta.order.indexWhere((c) => c == psubmission!.id)
        : 0;
    if (hasNextChapter) {
      nextChapter = firstPageStory.submission!.series.meta.order[index + 1];
    }
    futures.add(Future.value(firstPageStory));
    if (firstPageStory.meta?.pagesCount != null) {
      for (int i = 2; i <= firstPageStory.meta!.pagesCount; i++) {
        futures.add(api.getStory(psubmission.url, page: i));
      }
    }

    List<Story> stories = await Future.wait(futures);
    for (int i = 0; i < stories.length; i++) {
      final page = StoryPage(page: i + 1, content: stories[i].pageText!);
      setState(() {
        pages.add(page);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setInitState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
  }

  @override
  void dispose() {
    controller.removeListener(() => prefsFunctions.saveCurrentPage(submission: submission, controller: controller));
    controller.dispose();
    super.dispose();
  }

  Future<void> downloadStory() async {
    await dbFunctions.downloadStory(submission: submission, pages: pages, isDownloaded: isDownloaded).then(
      (value) {
        setState(() {
          isDownloaded = value;
        });
      },
    );
  }

  double mapValueToRange(double value, double oldMin, double oldMax, {double newMin = 0, double newMax = 100}) {
    double newValue = (value - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin;
    print('old min: $oldMin, old max: $oldMax');
    print('old val: $value, new val: $newValue');
    return newValue;
  }

  void updateExistingLists(List<int> newLists) {
    setState(() {
      existingLists = newLists;
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(scrollController.offset);
    if (isFabVisible) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack, overlays: []);
    }
    return FutureBuilder(
      future: _fetchPagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done || isBusy) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return GestureDetector(
            onTap: () {
              setState(() {
                isFabVisible = !isFabVisible;
              });
            },
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              // backgroundColor: Colors.grey[850],
              body: SafeArea(
                top: false,
                bottom: false,
                child: Stack(children: [
                  body(),
                  // slider(),
                  SizedBox(
                    height: kToolbarHeight + 20,
                    child: AnimatedOpacity(
                      opacity: isFabVisible ? 0.98 : 0.0, // Control the opacity with your condition
                      duration: const Duration(milliseconds: 10), // Control the duration of the animation
                      curve: Curves.easeInOut,
                      child: AppBar(
                        backgroundColor: Colors.grey[900],
                        leading: IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        title: Text(
                          submission.title,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        actions: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              knavigatorKey.currentState!.push(MaterialPageRoute(
                                  builder: (context) => StoryDetailsScreen(
                                        submission: submission,
                                      )));
                            },
                            icon: const Icon(Icons.info),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SpeedDial(
                  backgroundColor: kRed,
                  visible: isFabVisible,
                  animatedIcon: AnimatedIcons.menu_close,
                  children: [
                    SpeedDialChild(
                      child: existingLists.isEmpty
                          ? const Icon(
                              Icons.bookmark_border,
                            )
                          : const Icon(
                              Icons.bookmark,
                              color: kRed,
                            ),
                      label: 'Bookmark',
                      onTap: () async {
                        await showDialog(
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
                    ),
                    SpeedDialChild(
                      child: Icon(
                        Icons.file_download_outlined,
                        color: isDownloaded ? kRed : null,
                      ),
                      label: isDownloaded ? 'Remove from Downloads' : 'Add to Downloads',
                      onTap: () {
                        downloadStory();
                      },
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.info_outline),
                      label: 'Details',
                      onTap: () {
                        knavigatorKey.currentState!.push(MaterialPageRoute(
                            builder: (context) => StoryDetailsScreen(
                                  submission: submission,
                                )));
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  String getHtmlContent(String content) {
    content = content.replaceAll("\n", '<br>');
    content = content.replaceAll("\r", '<p style="margin:0; padding:0; height:10px;"></p>');
    // content = content.replaceAll("</I>", "</I><br>");
    // content = content.replaceAll("</U>", "</U><br>");
    return content;
  }

  Widget body() {
    Widget body = Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 5),
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller,
              children: <Widget>[
                // slider(),
                for (StoryPage page in pages)
                  Stack(children: [
                    SingleChildScrollView(
                      key: PageStorageKey<String>(submission.url + page.page.toString()),
                      scrollDirection: Axis.vertical,
                      controller: scrollController,
                      child: Center(
                        child: Column(
                          children: [
                            AnimatedContainer(
                              height: 0.0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              child: Container(
                                color: Colors.transparent,
                              ),
                            ),
                            // SizedBox(
                            //   height: isFabVisible ? 30 : 30,
                            // ),
                            Html(
                              style: {
                                'body': Style(
                                  fontSize: FontSize(16),
                                  color: Colors.white,
                                ),
                                'u': Style(
                                  color: kRed,
                                  textDecorationColor: kRed,
                                ),
                                'i': Style(
                                  color: Colors.white60,
                                ),
                              },
                              data: getHtmlContent(page.content),
                            ),
                            if (page.page == pages.length && hasNextChapter)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      isBusy = true;
                                    });
                                    await api
                                        .getStory(nextChapter.toString())
                                        .then((value) => {setInitState(setSubmission: value.submission)});
                                  },
                                  child: const Text('Next'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SmoothPageIndicator(
              controller: controller,
              count: pages.isEmpty ? 1 : pages.length,
              effect: const ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: kRed,
              ),
            ),
          ),
        ],
      ),
    );

    prefsFunctions.jumpToLastPage(submission: submission, controller: controller, scrollController: scrollController);

    return body;
  }
}
