import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'UserProfileSheet.dart';

class CommentsBottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final int currentChapterIndex;

  const CommentsBottomSheet({
    super.key,
    required this.scrollController,
    required this.currentChapterIndex,
  });

  void _showUserProfile(
      BuildContext context,
      String username,
      String userImage,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          UserProfileSheet(username: username, userImage: userImage),
    );
  }

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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.zero,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Navigation & Meta Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavButton(
                      context,
                      PhosphorIcons.caretLeft(),
                      "Episode ${currentChapterIndex + 262}",
                    ),
                    _buildNavButton(
                      context,
                      PhosphorIcons.caretRight(),
                      "Episode ${currentChapterIndex + 264}",
                      isRight: true,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      PhosphorIcons.house(),
                      size: 22,
                      color: textColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 20),
                    Icon(
                      PhosphorIcons.info(),
                      size: 22,
                      color: textColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 20),
                    Icon(
                      PhosphorIcons.shareNetwork(),
                      size: 22,
                      color: textColor.withOpacity(0.7),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 30, thickness: 0.5),

          // Content Area
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Comments on Episode ${currentChapterIndex + 263}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 25),
                // Premium Comment Input
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: textColor.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: "Your comment...",
                          hintStyle: TextStyle(
                            color: textColor.withOpacity(0.3),
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            PhosphorIcons.gif(),
                            color: textColor.withOpacity(0.4),
                            size: 22,
                          ),
                          const SizedBox(width: 18),
                          Icon(
                            PhosphorIcons.paperclip(),
                            color: textColor.withOpacity(0.4),
                            size: 22,
                          ),
                          const SizedBox(width: 18),
                          GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: brandColor,
                              radius: 20,
                              child: Icon(
                                PhosphorIcons.paperPlaneRight(
                                  PhosphorIconsStyle.fill,
                                ),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Sorting Filters
                Row(
                  children: [
                    _buildFilterChip("Top", true, brandColor),
                    const SizedBox(width: 12),
                    _buildFilterChip("New", false, brandColor),
                  ],
                ),
                const SizedBox(height: 30),
                // Refined Threaded Comment List
                _buildCommentThread(
                  context,
                  user: "Natalie",
                  userImage: "images/user2.jpeg",
                  time: "1 month ago",
                  text: "Bro really pulled out the strap 🤣",
                  likes: "52",
                  image: "images/orb.jpeg",
                  replies: [
                    _buildCommentThread(
                      context,
                      user: "Raikage",
                      userImage: "images/user1.jpeg",
                      time: "1 month ago",
                      text: "His hiding it",
                      likes: "8",
                      isReply: true,
                    ),
                    _buildCommentThread(
                      context,
                      user: "Kivye",
                      userImage: "images/user5.jpg",
                      time: "1 month ago",
                      text: "Yeah but why tho",
                      likes: "4",
                      isReply: true,
                      replyTo: "Raikage",
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                _buildCommentThread(
                  context,
                  user: "insomnia",
                  userImage: "images/user4.jpeg",
                  time: "2 weeks ago",
                  text:
                  "This chapter was absolute fire! The art style keeps getting better.",
                  likes: "128",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
      BuildContext context,
      PhosphorIconData icon,
      String label, {
        bool isRight = false,
      }) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (!isRight) Icon(icon, size: 18),
          if (!isRight) const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          if (isRight) const SizedBox(width: 8),
          if (isRight) Icon(icon, size: 18),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Color brandColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? brandColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? brandColor : Colors.black12),
      ),
      child: Row(
        children: [
          if (isSelected)
            Icon(
              PhosphorIcons.crown(PhosphorIconsStyle.fill),
              size: 16,
              color: brandColor,
            ),
          if (isSelected) const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? brandColor : Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentThread(
      BuildContext context, {
        required String user,
        required String userImage,
        required String time,
        required String text,
        required String likes,
        String? image,
        bool isReply = false,
        String? replyTo,
        List<Widget>? replies,
      }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final textColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.white
        : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isReply) ...[
              const SizedBox(width: 15),
              Container(
                width: 2,
                margin: const EdgeInsets.only(right: 15, bottom: 10),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info
                  GestureDetector(
                    onTap: () => _showUserProfile(context, user, userImage),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: AssetImage(userImage),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          user,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          time,
                          style: TextStyle(
                            color: textColor.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Content Area
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (replyTo != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Icon(
                                  PhosphorIcons.arrowBendUpRight(),
                                  size: 14,
                                  color: textColor.withOpacity(0.4),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Replying to @$replyTo",
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.4),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          text,
                          style: const TextStyle(fontSize: 15, height: 1.4),
                        ),
                        if (image != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                image,
                                height: 180,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        // Actions
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                PhosphorIcons.arrowFatLinesUp(
                                  PhosphorIconsStyle.bold,
                                ),
                                size: 20,
                                color: textColor.withOpacity(0.6),
                              ),
                              onPressed: () {},
                            ),
                            Text(
                              likes,
                              style: TextStyle(
                                fontSize: 13,
                                color: textColor.withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                PhosphorIcons.arrowFatLineDown(
                                  PhosphorIconsStyle.bold,
                                ),
                                size: 20,
                                color: textColor.withOpacity(0.6),
                              ),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Reply",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: textColor.withOpacity(0.6),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              PhosphorIcons.dotsThreeVertical(),
                              size: 20,
                              color: textColor.withOpacity(0.4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Render Sub-replies recursively
                  if (replies != null) ...replies,
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
