import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:lit_reader/env/colors.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/submission.dart';
import 'package:lit_reader/screens/author.dart';
import 'package:lit_reader/screens/story copy.dart';
import 'package:lit_reader/screens/story_details.dart';
import 'package:lit_reader/screens/widgets/lit_badge.dart';
import 'package:lit_reader/screens/widgets/lit_tags.dart';

class StoryItem extends StatelessWidget {
  const StoryItem({super.key, required this.submission, this.onDelete});

  final Submission submission;
  final Function(Submission)? onDelete;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(submission.id),
      endActionPane: ActionPane(
        extentRatio: 0.6,
        motion: const ScrollMotion(),
        dismissible: onDelete != null
            ? DismissiblePane(
                onDismissed: () {
                  onDelete!(submission);
                },
                confirmDismiss: () async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Story'),
                      content: const Text('Are you sure you want to delete this story?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );
                },
              )
            : null,
        children: [
          SlidableAction(
            onPressed: (context) {
              knavigatorKey.currentState!.push(MaterialPageRoute(
                builder: (context) => StoryDetailsScreen(
                  submission: submission,
                ),
              ));
            },
            icon: Icons.info,
            // foregroundColor: kred,
            backgroundColor: kWinnerTag,
            label: 'Details',
          ),
          if (submission.author != null)
            SlidableAction(
              onPressed: (context) {
                knavigatorKey.currentState!.push(MaterialPageRoute(
                  builder: (context) => AuthorScreen(
                    author: submission.author!,
                  ),
                ));
              },
              icon: Icons.person,
              // foregroundColor: kred,
              backgroundColor: kRed,
              label: 'Author',
            ),
        ],
      ),
      child: storyListItem(submission),
    );
  }

  Widget storyListItem(Submission story) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.5, color: kRed),
        ),
      ),
      child: ListTile(
        onTap: () {
          knavigatorKey.currentState!.push(MaterialPageRoute(
            builder: (context) => StoryScreen(
              submission: story,
            ),
          ));
        },
        onLongPress: () {
          knavigatorKey.currentState!.push(MaterialPageRoute(
            builder: (context) => StoryDetailsScreen(
              submission: story,
            ),
          ));
        },
        isThreeLine: true,
        title: titleElement(story),
        subtitle: subtitleElement(story),
      ),
    );
  }

  SingleChildScrollView titleElement(Submission story) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(story.title),
          ),
          const SizedBox(
            width: 5,
          ),
          if (story.isNew) const LitBadge(text: 'N', color: kNewTag),
          if (story.isHot) const LitBadge(text: 'H', color: kHotTag),
          if (story.writersPick) const LitBadge(text: 'E', color: kWriterTag),
          if (story.contestWinner == 1) const LitBadge(text: 'W', color: kWinnerTag),
        ],
      ),
    );
  }

  Column subtitleElement(Submission story) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          story.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
        const SizedBox(
          height: 5,
        ),
        categoryElement(story),
        const SizedBox(
          height: 5,
        ),
        authorElement(story),
        const SizedBox(
          height: 5,
        ),
        if (story.tags.isNotEmpty) tagsElement(story)
      ],
    );
  }

  Widget categoryElement(Submission story) => Row(
        children: [
          const Icon(
            Icons.list,
            size: 12,
          ),
          const SizedBox(
            width: 5,
          ),
          Obx(
            () => Text(
              litSearchController.categories.where((cat) => cat.id == story.category).firstOrNull?.name ?? "Loading...",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: kRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );

  SingleChildScrollView tagsElement(Submission story) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Icon(
            Icons.label,
            size: 12,
          ),
          const SizedBox(
            width: 5,
          ),
          for (var tag in story.tags) LitTags(tag: tag),
        ],
      ),
    );
  }

  SingleChildScrollView authorElement(Submission story) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Icon(
            Icons.star,
            size: 12,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            "${story.rateAll} (${story.viewCount}) by ${story.authorname} on ${story.dateApprove}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontStyle: FontStyle.italic, color: kRed),
          ),
        ],
      ),
    );
  }
}
