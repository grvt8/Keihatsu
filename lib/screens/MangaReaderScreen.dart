import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../components/Comments.dart';

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
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 1.0,
          builder: (_, scrollController) {
            return CommentsBottomSheet(
              scrollController: scrollController,
              currentChapterIndex: _currentChapterIndex,
            );
          },
        );
      },
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
                                max: pages.isEmpty ? 1 : pages.length.toDouble(),
                                activeColor: brandColor,
                                inactiveColor: Colors.white24,
                                onChanged: (val) => setState(() => _sliderValue = val),
                              ),
                            ),
                            Text("${pages.length}", style: const TextStyle(color: Colors.white)),
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
              child: _buildGlassBox(
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
