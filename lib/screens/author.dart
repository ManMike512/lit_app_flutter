import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:lit_reader/env/colors.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/author.dart';
import 'package:lit_reader/models/submission.dart';
import 'package:lit_reader/screens/widgets/lit_chip.dart';
import 'package:lit_reader/screens/widgets/lit_search_bar.dart';
import 'package:lit_reader/screens/widgets/story_item.dart';
import 'package:url_launcher/url_launcher.dart';

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SearchBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 4 : 0,
      child: child,
    );
  }

  @override
  double get maxExtent => 60; // Height of the search bar
  @override
  double get minExtent => 60; // Height of the search bar

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class AuthorScreen extends StatefulWidget {
  const AuthorScreen({super.key, required this.author});

  final Author author;

  @override
  State<AuthorScreen> createState() => _AuthorScreenState();
}

class _AuthorScreenState extends State<AuthorScreen> {
  Timer? _debounce;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  late ScrollController _scrollController;
  bool _hasMoreData = true;
  bool _isExpanded = false;

  late Author author;

  List<Submission> _stories = [];
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  int _currentPage = 1;

  @override
  void initState() {
    author = widget.author;
    super.initState();
    if (author.homepage == null) {
      api.getAuthor(author.userid).then((value) {
        setState(() {
          author = value;
        });
      });
    }
    _scrollController = ScrollController()..addListener(_onScroll);
    _fetchInitialStories();
  }

  void onChangeCustom() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchInitialStories();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _fetchMoreStories();
    }
  }

  Future<void> _fetchInitialStories() async {
    setState(() {
      _isRefreshing = true;
      _hasMoreData = true;
    });
    try {
      final newStories = await api.getAuthorStories(widget.author.username, page: 1, searchTerm: _searchController.text);
      setState(() {
        _stories = newStories.data;
        _currentPage = 2;
      });
    } catch (error) {
      // Handle error
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _fetchMoreStories() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });
    try {
      final newStories = await api.getAuthorStories(widget.author.username, page: _currentPage);
      if (newStories.data.isEmpty) {
        // No more data to fetch
        setState(() {
          _hasMoreData = false;
        });
        return;
      }
      setState(() {
        _stories.addAll(newStories.data);
        _currentPage++;
      });
    } catch (error) {
      // Handle error
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(author.username),
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: body(),
      ),
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  String formatNumber(int num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    } else {
      return num.toString();
    }
  }

  Widget body() {
    return RefreshIndicator(
      onRefresh: _fetchInitialStories,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Sliver for the author info
          SliverToBoxAdapter(
            child: authorInfo(),
          ),

          // Sliver for the sticky search bar
          SliverPersistentHeader(
            pinned: true,
            floating: true,
            delegate: _SearchBarDelegate(
              child: LitSearchBar(
                formKey: formKey,
                searchFieldTextController: _searchController,
                onChanged: onChangeCustom,
              ),
            ),
          ),

          // Sliver for the stories list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == _stories.length) {
                  // Show a loading indicator at the bottom if more data is being fetched
                  return _isLoadingMore ? const Center(child: CircularProgressIndicator()) : null;
                }
                return StoryItem(submission: _stories[index]);
              },
              childCount: _stories.length + (_isLoadingMore ? 1 : 0),
            ),
          ),

          // Sliver for pull-to-refresh (optional)
          if (_isRefreshing)
            const SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  // Widget body1() {
  //   return SingleChildScrollView(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         authorInfo(),
  //         const SizedBox(height: 10),
  //         SizedBox(
  //           height: 600,
  //           child: AuthorsStoriesScreen(
  //             author: widget.author,
  //             listOnly: true,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget authorInfo() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(author.username, style: const TextStyle(fontSize: 25)),
          if (author.location != null && author.location!.isNotEmpty)
            Text('Location: ${author.location}',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                )),
          if (author.lastUpdateApprox.isNotEmpty)
            Text('Updated: ${author.lastUpdateApprox}',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                )),
          if (author.joindateApprox.isNotEmpty)
            Text('Joined: ${author.joindateApprox}',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                )),
          const SizedBox(height: 10),
          Wrap(
            runSpacing: 5,
            spacing: 5,
            children: [
              LitChip(label: "Followers", text: formatNumber(author.followersCount)),
              LitChip(label: "Comments", text: formatNumber(author.commentsCount)),
              LitChip(label: "Series", text: formatNumber(author.seriesCount)),
              LitChip(label: "Stories", text: formatNumber(author.storiesCount)),
              LitChip(label: "Poems", text: formatNumber(author.poemsCount)),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Bio',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          Column(
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                constraints: BoxConstraints(
                  maxHeight: _isExpanded ? double.maxFinite : 100,
                ),
                child: Linkify(
                  onOpen: (link) async {
                    await _launchInBrowser(Uri.parse(link.url));
                  },
                  text: author.biography ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  linkStyle: const TextStyle(color: kRed, decoration: TextDecoration.none),
                ),
              ),
              if (author.biography != null && author.biography!.isNotEmpty)
                TextButton(
                  child: Text(_isExpanded ? "Show Less" : "Show More"),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget litLabelTextRow(String title, {double fontSize = 18, String? value, Widget? trailing, double height = 1.6}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          Text(
            value,
            style: TextStyle(
              height: height,
              fontSize: fontSize,
              color: kRed,
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
