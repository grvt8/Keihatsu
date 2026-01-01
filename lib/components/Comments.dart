import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class CommentsBottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final int currentChapterIndex;

  const CommentsBottomSheet({
    super.key,
    required this.scrollController,
    required this.currentChapterIndex,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavButton(
                        context, PhosphorIcons.arrowLeft(), "Episode ${currentChapterIndex + 262}"),
                    _buildNavButton(
                        context, PhosphorIcons.arrowRight(), "Episode ${currentChapterIndex + 264}",
                        isRight: true),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(PhosphorIcons.house(), size: 20, color: textColor),
                    const SizedBox(width: 15),
                    Icon(PhosphorIcons.info(), size: 20, color: textColor),
                    const SizedBox(width: 15),
                    Icon(PhosphorIcons.shareNetwork(), size: 20, color: textColor),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  "Comments on Episode ${currentChapterIndex + 263}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 20),
                // Comment Input
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      const TextField(
                        decoration: InputDecoration(
                          hintText: "Your comment...",
                          border: InputBorder.none,
                        ),
                        maxLines: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(PhosphorIcons.gif(), color: textColor.withOpacity(0.5)),
                          const SizedBox(width: 15),
                          Icon(PhosphorIcons.paperclip(), color: textColor.withOpacity(0.5)),
                          const SizedBox(width: 15),
                          CircleAvatar(
                            backgroundColor: brandColor,
                            radius: 18,
                            child: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Filters
                Row(
                  children: [
                    _buildFilterChip("Top", true, brandColor),
                    const SizedBox(width: 10),
                    _buildFilterChip("New", false, brandColor),
                  ],
                ),
                const SizedBox(height: 20),
                // Comment List
                _buildCommentItem(
                  context,
                  user: "Natalie",
                  userImage: "images/user2.jpeg",
                  time: "1 month ago",
                  text: "Bro really pulled out the strap 🤣",
                  likes: "52",
                  image: "images/player.jpg",
                  replies: [
                    _buildCommentItem(
                      context,
                      user: "Raikage",
                      userImage: "images/user6.jpeg",
                      time: "1 month ago",
                      text: "His hiding it",
                      likes: "8",
                      isNested: true,
                    ),
                    _buildCommentItem(
                      context,
                      user: "Kivye",
                      userImage: "images/user3.jpeg",
                      time: "1 month ago",
                      text: "Yeah but why tho",
                      likes: "4",
                      isNested: true,
                      replyTo: "Raiuga",
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCommentItem(
                  context,
                  user: "insomnia",
                  userImage: "images/user4.jpeg",
                  time: "2 weeks ago",
                  text: "This chapter was absolute fire! The art style keeps getting better.",
                  likes: "128",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, PhosphorIconData icon, String label,
      {bool isRight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (!isRight) Icon(icon, size: 16),
          if (!isRight) const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (isRight) const SizedBox(width: 5),
          if (isRight) Icon(icon, size: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Color brandColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? brandColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? brandColor : Colors.black12),
      ),
      child: Row(
        children: [
          if (isSelected) Icon(PhosphorIcons.trophy(), size: 16, color: brandColor),
          if (isSelected) const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: isSelected ? brandColor : Colors.black54, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCommentItem(
    BuildContext context, {
    required String user,
    required String userImage,
    required String time,
    required String text,
    required String likes,
    String? image,
    bool isNested = false,
    String? replyTo,
    List<Widget>? replies,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final textColor = themeProvider.themeMode == ThemeMode.dark ? Colors.white : Colors.black87;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNested) ...[
            const SizedBox(width: 20),
            VerticalDivider(color: textColor.withOpacity(0.1), thickness: 2),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                        radius: 12, backgroundImage: AssetImage(userImage)),
                    const SizedBox(width: 10),
                    Text(user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 10),
                    Text(time, style: TextStyle(color: textColor.withOpacity(0.4), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                if (replyTo != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.arrowBendUpRight(), size: 14, color: textColor.withOpacity(0.4)),
                        const SizedBox(width: 5),
                        Text("Replying to @$replyTo",
                            style: TextStyle(
                                color: textColor.withOpacity(0.4),
                                fontSize: 12,
                                fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                Text(text, style: const TextStyle(fontSize: 14)),
                if (image != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(image, height: 150, width: 100, fit: BoxFit.cover),
                    ),
                  ),
                Row(
                  children: [
                    IconButton(icon: Icon(PhosphorIcons.arrowFatUp(), size: 18), onPressed: () {}),
                    Text(likes, style: const TextStyle(fontSize: 12)),
                    IconButton(icon: Icon(PhosphorIcons.arrowFatDown(), size: 18), onPressed: () {}),
                    const Text("Reply", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Icon(PhosphorIcons.dotsThreeVertical(), size: 18),
                  ],
                ),
                if (replies != null) ...replies,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
