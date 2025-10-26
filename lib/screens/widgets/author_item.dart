import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lit_reader/env/colors.dart';
import 'package:lit_reader/env/global.dart';
import 'package:lit_reader/models/author.dart';
import 'package:lit_reader/screens/author.dart';

class AuthorItem extends StatelessWidget {
  const AuthorItem({super.key, required this.author, this.onDelete});

  final Author author;
  final Function(Author)? onDelete;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(author.userid),
      child: authorListItem(author),
    );
  }

  Widget authorListItem(Author author) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.5, color: kRed),
        ),
      ),
      child: ListTile(
        leading: ClipOval(
          child: Image.network(
            author.userpic,
            width: 50,
            height: 50,
            isAntiAlias: true,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.account_circle,
                size: 50,
                color: Colors.grey,
              );
            },
          ),
        ),
        onTap: () {
          knavigatorKey.currentState!.push(MaterialPageRoute(
            builder: (context) => AuthorScreen(
              author: author,
            ),
          ));
        },
        isThreeLine: true,
        title: titleElement(author),
        subtitle: subtitleElement(author),
      ),
    );
  }

  SingleChildScrollView titleElement(Author author) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(author.username),
          ),
        ],
      ),
    );
  }

  Column subtitleElement(Author author) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          author.bio ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
        const SizedBox(
          height: 5,
        ),
        seriesCount(author),
        storiesCount(author),
        followersCount(author),
      ],
    );
  }

  Widget seriesCount(Author author) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(
              Icons.list,
              size: 12,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              "Series: ${author.seriesCount}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontStyle: FontStyle.italic, color: kRed),
            ),
          ],
        ),
      );

  Widget storiesCount(Author author) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(
              Icons.book,
              size: 12,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              "Stories: ${author.storiesCount}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontStyle: FontStyle.italic, color: kRed),
            ),
          ],
        ),
      );

  Widget followersCount(Author author) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(
              Icons.people,
              size: 12,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              "Followers: ${author.followersCount}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontStyle: FontStyle.italic, color: kRed),
            ),
          ],
        ),
      );
}
