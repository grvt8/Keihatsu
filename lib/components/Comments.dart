import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../theme_provider.dart';
import 'UserProfileSheet.dart';
import '../providers/auth_provider.dart';
import '../providers/comments_provider.dart';
import '../models/comment.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CommentsBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  final int currentChapterIndex;
  final String mangaId;
  final String chapterId;

  const CommentsBottomSheet({
    super.key,
    required this.scrollController,
    required this.currentChapterIndex,
    required this.mangaId,
    required this.chapterId,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isFocused = false;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });

    // Fetch comments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<CommentsProvider>(
        context,
        listen: false,
      ).fetchComments(widget.mangaId, widget.chapterId, auth.token);
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (mounted) {
      setState(() {
        _isOnline = !result.contains(ConnectivityResult.none);
      });
    }
  }

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

  Future<void> _pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
      // Ensure focus to show expanded state
      if (!_isFocused) {
        _focusNode.requestFocus();
      }
    }
  }

  Future<void> _handlePostComment() async {
    if (_commentController.text.trim().isEmpty && _selectedImages.isEmpty)
      return;

    final content = _commentController.text;
    final images = List<String>.from(_selectedImages.map((e) => e.path));

    _commentController.clear();
    setState(() {
      _selectedImages = [];
    });
    _focusNode.unfocus();

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final commentsProvider = Provider.of<CommentsProvider>(
        context,
        listen: false,
      );
      await commentsProvider.postComment(
        widget.mangaId,
        widget.chapterId,
        content,
        auth.token!,
        imagePaths: images,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to post comment: $e")));
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _commentController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final commentsProvider = Provider.of<CommentsProvider>(context);
    final user = authProvider.user;

    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    ImageProvider userAvatar;
    if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
      userAvatar = NetworkImage(user!.avatarUrl!);
    } else {
      userAvatar = const AssetImage("images/user3.jpeg");
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: widget.scrollController,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildNavButton(
                              context,
                              PhosphorIcons.caretLeft(),
                              "Episode ${widget.currentChapterIndex + 262}",
                            ),
                            _buildNavButton(
                              context,
                              PhosphorIcons.caretRight(),
                              "Episode ${widget.currentChapterIndex + 264}",
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
                          "Comments on Episode ${widget.currentChapterIndex + 263}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
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
                        // Threaded Comment List
                        if (commentsProvider.isLoading)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (commentsProvider.error != null)
                          Center(child: Text(commentsProvider.error!))
                        else if (commentsProvider.comments.isEmpty)
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 40),
                                  Icon(
                                    PhosphorIcons.chatTeardropDots(
                                      PhosphorIconsStyle.fill,
                                    ),
                                    size: 64,
                                    color: textColor.withOpacity(0.2),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Be the first to comment",
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.6),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...commentsProvider.comments.map(
                                  (comment) =>
                                  _buildCommentThread(context, comment: comment),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Input Area
            _buildInputArea(
              context,
              bgColor,
              textColor,
              userAvatar,
              brandColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(
      BuildContext context,
      Color bgColor,
      Color textColor,
      ImageProvider userAvatar,
      Color brandColor,
      ) {
    if (!_isOnline) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(top: BorderSide(color: textColor.withOpacity(0.1))),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.wifiSlash(),
                color: textColor.withOpacity(0.5),
              ),
              const SizedBox(width: 10),
              Text(
                "Go online to comment",
                style: TextStyle(color: textColor.withOpacity(0.5)),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: textColor.withOpacity(0.1))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: _isFocused
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                CircleAvatar(radius: 18, backgroundImage: userAvatar),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: !_isFocused
                        ? BoxDecoration(
                      color: textColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    )
                        : null,
                    constraints: _isFocused
                        ? const BoxConstraints(maxHeight: 120)
                        : const BoxConstraints(minHeight: 45),
                    child: TextField(
                      focusNode: _focusNode,
                      controller: _commentController,
                      maxLines: null,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: "Add comments...",
                        hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                        border: InputBorder.none,
                        contentPadding: !_isFocused
                            ? const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        )
                            : EdgeInsets.zero,
                        isDense: true,
                        suffixIcon: !_isFocused
                            ? GestureDetector(
                          onTap: _pickImage,
                          child: Icon(
                            PhosphorIcons.image(),
                            color: textColor.withOpacity(0.6),
                            size: 24,
                          ),
                        )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isFocused) ...[
              const SizedBox(height: 12),
              if (_selectedImages.isNotEmpty)
                Container(
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_selectedImages[index].path),
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: _buildActionIcon(PhosphorIcons.image(), textColor),
                  ),
                  const SizedBox(width: 20),
                  const Spacer(),
                  GestureDetector(
                    onTap: _handlePostComment,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.shade400, // Brand-like color
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        PhosphorIcons.arrowUp(PhosphorIconsStyle.bold),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, {double size = 24}) {
    return Icon(icon, color: color.withOpacity(0.6), size: size);
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
        required Comment comment,
        bool isReply = false,
      }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final commentsProvider = Provider.of<CommentsProvider>(
      context,
      listen: false,
    );

    final textColor = themeProvider.themeMode == ThemeMode.dark
        ? Colors.white
        : Colors.black87;

    final user = comment.user?.username ?? "Unknown";
    final userImage = comment.user?.avatarUrl ?? "images/user3.jpeg";
    final time = _formatTime(comment.createdAt);
    final text = comment.content;
    final likes = comment.upvotes.toString();

    // Check if user voted
    final userVote = comment.votes?.isNotEmpty == true
        ? comment.votes!.first.type
        : null;
    final isLiked = userVote == 'UPVOTE';
    final isDisliked = userVote == 'DOWNVOTE';

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
                          backgroundImage: userImage.startsWith('http')
                              ? NetworkImage(userImage)
                              : AssetImage(userImage) as ImageProvider,
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
                        Text(
                          text,
                          style: const TextStyle(fontSize: 15, height: 1.4),
                        ),
                        if (comment.images.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: SizedBox(
                              height: 180,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: comment.images.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        comment.images[index],
                                        height: 180,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        // Actions
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isLiked
                                    ? PhosphorIcons.arrowFatLinesUp(
                                  PhosphorIconsStyle.fill,
                                )
                                    : PhosphorIcons.arrowFatLinesUp(
                                  PhosphorIconsStyle.bold,
                                ),
                                size: 20,
                                color: isLiked
                                    ? Colors.orange
                                    : textColor.withOpacity(0.6),
                              ),
                              onPressed: () {
                                if (auth.token != null) {
                                  commentsProvider.voteComment(
                                    comment.id,
                                    'UPVOTE',
                                    auth.token!,
                                    widget.mangaId,
                                    widget.chapterId,
                                  );
                                }
                              },
                            ),
                            Text(
                              likes,
                              style: TextStyle(
                                fontSize: 13,
                                color: isLiked
                                    ? Colors.orange
                                    : textColor.withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isDisliked
                                    ? PhosphorIcons.arrowFatLineDown(
                                  PhosphorIconsStyle.fill,
                                )
                                    : PhosphorIcons.arrowFatLineDown(
                                  PhosphorIconsStyle.bold,
                                ),
                                size: 20,
                                color: isDisliked
                                    ? Colors.blue
                                    : textColor.withOpacity(0.6),
                              ),
                              onPressed: () {
                                if (auth.token != null) {
                                  commentsProvider.voteComment(
                                    comment.id,
                                    'DOWNVOTE',
                                    auth.token!,
                                    widget.mangaId,
                                    widget.chapterId,
                                  );
                                }
                              },
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
                        // Collapsed Replies Indicator
                        if (comment.replies.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 1,
                                  color: textColor.withOpacity(0.2),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "View ${comment.replies.length} replies",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textColor.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  PhosphorIcons.caretDown(),
                                  size: 14,
                                  color: textColor.withOpacity(0.6),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Render Sub-replies recursively
                  if (comment.replies.isNotEmpty)
                    ...comment.replies.map(
                          (reply) => _buildCommentThread(
                        context,
                        comment: reply,
                        isReply: true,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
