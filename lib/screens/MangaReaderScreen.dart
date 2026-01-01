import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class MangaReaderScreen extends StatefulWidget {
  final String title;
  const MangaReaderScreen({super.key, required this.title});

  @override
  State<MangaReaderScreen> createState() => _MangaReaderScreenState();
}

class _MangaReaderScreenState extends State<MangaReaderScreen> {
  int _currentChapterIndex = 0;
  double _sliderValue = 1;
  bool _showControls = true;
  List<dynamic> _chaptersData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChaptersJson();
  }

  Future<void> _loadChaptersJson() async {
    final String response = await rootBundle.loadString('lib/data/chapters.json');
    final data = await json.decode(response);
    setState(() {
      _chaptersData = data['chapters'];
      _isLoading = false;
    });
  }

  List<String> _getPageImages() {
    if (_chaptersData.isEmpty) return [];
    final chapter = _chaptersData[_currentChapterIndex];
    final String folder = chapter['folder'];
    final List<dynamic> pages = chapter['pages'];

    return pages.map((page) => "manwhaChps/$folder/$page").toList();
  }

  void _showCommentsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          builder: (_, scrollController) {
            return _buildCommentsView(scrollController);
          },
        );
      },
    );
  }

  Widget _buildCommentsView(ScrollController scrollController) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
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
            width: 40, height: 5,
            decoration: BoxDecoration(color: textColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavButton(PhosphorIcons.arrowLeft(), "Episode ${_currentChapterIndex + 262}"),
                    _buildNavButton(PhosphorIcons.arrowRight(), "Episode ${_currentChapterIndex + 264}", isRight: true),
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
                  "Comments on Episode ${_currentChapterIndex + 263}",
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
                  user: "xHyphem",
                  time: "1 month ago",
                  text: "Bro really pulled out the strap 🤣",
                  likes: "52",
                  image: "images/player.jpg",
                  replies: [
                    _buildCommentItem(
                      user: "Raiuga",
                      time: "1 month ago",
                      text: "His hiding it",
                      likes: "8",
                      isNested: true,
                    ),
                    _buildCommentItem(
                      user: "nasa",
                      time: "1 month ago",
                      text: "Yeah but why tho",
                      likes: "4",
                      isNested: true,
                      replyTo: "Raiuga",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(PhosphorIconData icon, String label, {bool isRight = false}) {
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
          Text(label, style: TextStyle(color: isSelected ? brandColor : Colors.black54, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCommentItem({
    required String user,
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
                    CircleAvatar(radius: 12, backgroundImage: const AssetImage('images/user1.jpeg')),
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
                        Text("Replying to @$replyTo", style: TextStyle(color: textColor.withOpacity(0.4), fontSize: 12, fontStyle: FontStyle.italic)),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final pages = _getPageImages();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showControls = !_showControls),
            child: ListView.builder(
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  pages[index],
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 400,
                    color: Colors.grey[900],
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.white24)),
                  ),
                );
              },
            ),
          ),

          if (_showControls)
            Positioned(
              top: 0, left: 0, right: 0,
              child: _buildGlassBox(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                              Text("Chapter ${_chaptersData[_currentChapterIndex]['id']}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(icon: Icon(PhosphorIcons.bookmark(), color: Colors.white), onPressed: () {}),
                        IconButton(icon: Icon(PhosphorIcons.dotsThreeVertical(), color: Colors.white), onPressed: () {}),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (_showControls)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _buildGlassBox(
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(PhosphorIcons.caretDoubleLeft(), color: Colors.white),
                              onPressed: _currentChapterIndex > 0 ? () => setState(() => _currentChapterIndex--) : null,
                            ),
                            Text("${_sliderValue.toInt()}", style: const TextStyle(color: Colors.white)),
                            Expanded(
                              child: Slider(
                                value: _sliderValue,
                                min: 1,
                                max: _getPageImages().length.toDouble(),
                                activeColor: brandColor,
                                inactiveColor: Colors.white24,
                                onChanged: (val) => setState(() => _sliderValue = val),
                              ),
                            ),
                            Text("${_getPageImages().length}", style: const TextStyle(color: Colors.white)),
                            IconButton(
                              icon: Icon(PhosphorIcons.caretDoubleRight(), color: Colors.white),
                              onPressed: _currentChapterIndex < _chaptersData.length - 1 ? () => setState(() => _currentChapterIndex++) : null,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(PhosphorIcons.phoneSlash(), color: Colors.white70),
                            Icon(PhosphorIcons.arrowsOut(), color: Colors.white70),
                            Icon(PhosphorIcons.selectionBackground(), color: Colors.white70),
                            Icon(PhosphorIcons.gear(), color: Colors.white70),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (_showControls)
            Positioned(
              right: 20, bottom: 120,
              child: Column(
                children: [
                  _buildGlassBox(
                    borderRadius: BorderRadius.circular(30),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          IconButton(icon: Icon(PhosphorIcons.bookmarkSimple(), color: Colors.white), onPressed: () {}),
                          const SizedBox(height: 10),
                          IconButton(icon: Icon(PhosphorIcons.chatCircleText(), color: Colors.white), onPressed: _showCommentsBottomSheet),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlassBox({required Widget child, BorderRadius? borderRadius}) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: borderRadius,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}
