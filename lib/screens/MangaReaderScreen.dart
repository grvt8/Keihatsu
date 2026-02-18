import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import '../services/sources_api.dart';
import '../components/Comments.dart';

class MangaReaderScreen extends StatefulWidget {
  final Manga manga;
  final List<Chapter> chapters;
  final int initialChapterIndex;

  const MangaReaderScreen({
    super.key,
    required this.manga,
    required this.chapters,
    required this.initialChapterIndex,
  });

  @override
  State<MangaReaderScreen> createState() => _MangaReaderScreenState();
}

class _MangaReaderScreenState extends State<MangaReaderScreen> {
  late int _currentChapterIndex;
  double _sliderValue = 1;
  bool _showControls = true;
  bool _isLoading = true;
  List<ReaderPage> _pages = [];
  final SourcesApi _sourcesApi = SourcesApi();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentChapterIndex = widget.initialChapterIndex;
    _loadPages();
    
    _scrollController.addListener(() {
      if (_pages.isNotEmpty) {
        // Simple heuristic to update slider based on scroll position
        // This can be improved by tracking individual item visibility
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        if (maxScroll > 0) {
          setState(() {
            _sliderValue = ((currentScroll / maxScroll) * (_pages.length - 1)).clamp(0, _pages.length - 1) + 1;
          });
        }
      }
    });
  }

  Future<void> _loadPages() async {
    setState(() {
      _isLoading = true;
      _pages = [];
    });

    try {
      final chapter = widget.chapters[_currentChapterIndex];
      final pages = await _sourcesApi.getPages(widget.manga.sourceId, chapter.id);
      setState(() {
        _pages = pages;
        _isLoading = false;
        _sliderValue = 1;
      });
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pages: $e')),
        );
      }
    }
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final currentChapter = widget.chapters[_currentChapterIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showControls = !_showControls),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _pages.isEmpty
                    ? const Center(child: Text("No pages found", style: TextStyle(color: Colors.white)))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _pages.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            _pages[index].imageUrl,
                            fit: BoxFit.fitWidth,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 400,
                                color: Colors.grey[900],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: brandColor.withOpacity(0.5),
                                  ),
                                ),
                              );
                            },
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
              child: Container(
                color: brandColor.withOpacity(0.9),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.manga.title,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                currentChapter.name,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
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
              child: Container(
                color: brandColor.withOpacity(0.9),
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
                              onPressed: _currentChapterIndex < widget.chapters.length - 1 
                                ? () {
                                    setState(() => _currentChapterIndex++);
                                    _loadPages();
                                  } 
                                : null,
                            ),
                            Text("${_sliderValue.toInt()}", style: const TextStyle(color: Colors.white)),
                            Expanded(
                              child: Slider(
                                value: _sliderValue,
                                min: 1,
                                max: _pages.isEmpty ? 1 : _pages.length.toDouble(),
                                activeColor: Colors.white,
                                inactiveColor: Colors.white24,
                                onChanged: (val) {
                                  setState(() => _sliderValue = val);
                                  // Jump to page on change
                                  // Implementation depends on height of images
                                },
                              ),
                            ),
                            Text("${_pages.length}", style: const TextStyle(color: Colors.white)),
                            IconButton(
                              icon: Icon(PhosphorIcons.caretDoubleRight(), color: Colors.white),
                              onPressed: _currentChapterIndex > 0 
                                ? () {
                                    setState(() => _currentChapterIndex--);
                                    _loadPages();
                                  } 
                                : null,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(PhosphorIcons.phoneSlash(), color: Colors.white),
                            Icon(PhosphorIcons.arrowsOut(), color: Colors.white),
                            Icon(PhosphorIcons.selectionBackground(), color: Colors.white),
                            Icon(PhosphorIcons.gear(), color: Colors.white),
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
              right: 20, bottom: 140,
              child: Container(
                decoration: BoxDecoration(
                  color: brandColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
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
}
