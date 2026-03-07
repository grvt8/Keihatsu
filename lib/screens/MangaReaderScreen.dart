import 'dart:io';
import 'dart:async'; // Added
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import '../models/local_models.dart';
import '../services/manga_repository.dart';
import '../providers/auth_provider.dart'; // Added
import '../providers/comments_provider.dart'; // Added
import '../components/Comments.dart';
import '../components/CustomBackButton.dart';

class MangaReaderScreen extends StatefulWidget {
  final Manga manga;
  final List<dynamic> chapters; // Can be List<Chapter> or List<LocalChapter>
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
  List<dynamic> _pages = []; // List<ReaderPage> or List<LocalPage>
  final ScrollController _scrollController = ScrollController();
  int _currentPageIndex = 0;

  // History tracking
  Timer? _debounceTimer;
  final Stopwatch _readingTimer = Stopwatch();
  LocalManga? _localManga;

  @override
  void initState() {
    super.initState();
    _readingTimer.start();
    _currentChapterIndex = widget.initialChapterIndex;
    _loadLocalManga();
    _loadPages();

    _scrollController.addListener(() {
      if (_pages.isNotEmpty) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        if (maxScroll > 0) {
          final pageIndex = ((currentScroll / maxScroll) * (_pages.length - 1))
              .clamp(0, _pages.length - 1);
          setState(() {
            _sliderValue = pageIndex + 1;
          });

          _debounceSaveProgress(pageIndex.round());
        }
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _saveProgress(_currentPageIndex);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalManga() async {
    final repo = Provider.of<MangaRepository>(context, listen: false);
    // Ensure we have a local manga record to attach history to
    _localManga = await repo.getMangaDetails(
      widget.manga.sourceId,
      widget.manga.id,
    );
  }

  void _debounceSaveProgress(int pageIndex) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(seconds: 3), () {
      _saveProgress(pageIndex);
    });
  }

  Future<void> _saveProgress(int pageIndex) async {
    if (!mounted || _localManga == null) return;
    try {
      final repo = Provider.of<MangaRepository>(context, listen: false);
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final chapter = widget.chapters[_currentChapterIndex];
      final chapterId = chapter is Chapter
          ? chapter.id
          : (chapter as LocalChapter).chapterId;

      final isRead = _pages.isNotEmpty && pageIndex >= _pages.length - 1;

      final readingTimeMs = _readingTimer.elapsedMilliseconds;
      _readingTimer.reset();

      await repo.updateReadingProgress(
        manga: _localManga!,
        chapterId: chapterId,
        pageIndex: pageIndex,
        token: auth.token,
        isRead: isRead,
        readingTimeMs: readingTimeMs,
      );

      // Update local object state to reflect change immediately in UI if needed
      if (chapter is LocalChapter && isRead) {
        chapter.isRead = true;
      }
    } catch (e) {
      print("Error saving progress: $e");
    }
  }

  Future<void> _loadPages() async {
    setState(() {
      _isLoading = true;
      _pages = [];
      _sliderValue = 1;
    });

    try {
      final repo = Provider.of<MangaRepository>(context, listen: false);
      final chapter = widget.chapters[_currentChapterIndex];
      final chapterId = chapter is Chapter
          ? chapter.id
          : (chapter as LocalChapter).chapterId;

      // Update history immediately on chapter load (page 0)
      if (_localManga != null) {
        _saveProgress(0);
      } else {
        // Retry after short delay if localManga not loaded yet
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _localManga != null) _saveProgress(0);
        });
      }

      // Try local first
      final localPages = await repo.getChapterPages(chapterId);
      bool useLocal = false;

      if (localPages.isNotEmpty) {
        // Verify files actually exist
        if (localPages.first.imageLocalPath != null) {
          final file = File(localPages.first.imageLocalPath!);
          if (await file.exists()) {
            useLocal = true;
          }
        }
      }

      if (useLocal) {
        setState(() {
          _pages = localPages;
          _isLoading = false;
        });
      } else {
        // Fallback to API if not downloaded
        final remotePages = await repo.api.getPages(
          widget.manga.sourceId,
          chapterId,
        );
        setState(() {
          _pages = remotePages;
          _isLoading = false;
        });
      }

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading pages: $e')));
      }
    }
  }

  bool _hasPreviousChapter() {
    return _currentChapterIndex < widget.chapters.length - 1;
  }

  bool _hasNextChapter() {
    return _currentChapterIndex > 0;
  }

  void _goToPreviousChapter() {
    setState(() => _currentChapterIndex++);
    _loadPages();
  }

  void _goToNextChapter() {
    setState(() => _currentChapterIndex--);
    _loadPages();
  }

  void _scrollToPage(int pageIndex) {
    if (_pages.isEmpty || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    // Approximate scroll position
    final targetOffset = (pageIndex / (_pages.length - 1)) * maxScroll;
    _scrollController.jumpTo(targetOffset);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final currentChapter = widget.chapters[_currentChapterIndex];
    final chapterName = currentChapter is Chapter
        ? currentChapter.name
        : (currentChapter as LocalChapter).name;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showControls = !_showControls),
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
                : _pages.isEmpty
                ? const Center(
              child: Text(
                "No pages found",
                style: TextStyle(color: Colors.white),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                ImageProvider imageProvider;

                if (page is LocalPage && page.imageLocalPath != null) {
                  imageProvider = FileImage(File(page.imageLocalPath!));
                } else {
                  final url = page is LocalPage
                      ? page.imageRemoteUrl
                      : page.imageUrl;
                  imageProvider = NetworkImage(url);
                }

                return Image(
                  image: imageProvider,
                  fit: BoxFit.fitWidth,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 400,
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white24,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 400,
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white24,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.9),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const CustomBackButton(),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.manga.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                chapterName,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (_showControls)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChapterButton(
                      icon: PhosphorIcons.skipBack(PhosphorIconsStyle.fill),
                      onPressed: _hasPreviousChapter()
                          ? _goToPreviousChapter
                          : null,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "${_sliderValue.toInt()}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 6,
                                  activeTrackColor: brandColor,
                                  inactiveTrackColor: Colors.white.withOpacity(
                                    0.2,
                                  ),
                                  thumbColor: brandColor,
                                  thumbShape: VerticalBarThumbShape(
                                    color: brandColor,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 12,
                                  ),
                                  trackShape:
                                  const RoundedRectSliderTrackShape(),
                                ),
                                child: Slider(
                                  value: _sliderValue,
                                  min: 1,
                                  max: _pages.isEmpty
                                      ? 1
                                      : _pages.length.toDouble(),
                                  divisions: _pages.isEmpty
                                      ? 1
                                      : _pages.length - 1,
                                  onChanged: (val) {
                                    setState(() => _sliderValue = val);
                                    _scrollToPage(val.toInt() - 1);
                                  },
                                ),
                              ),
                            ),
                            Text(
                              "${_pages.length}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    _buildChapterButton(
                      icon: PhosphorIcons.skipForward(PhosphorIconsStyle.fill),
                      onPressed: _hasNextChapter() ? _goToNextChapter : null,
                    ),
                  ],
                ),
              ),
            ),

          if (_showControls)
            Positioned(
              right: 16,
              bottom: 100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        (currentChapter is LocalChapter &&
                            currentChapter.isBookmarked)
                            ? PhosphorIcons.bookmarkSimple(
                          PhosphorIconsStyle.fill,
                        )
                            : PhosphorIcons.bookmarkSimple(),
                        color:
                        (currentChapter is LocalChapter &&
                            currentChapter.isBookmarked)
                            ? Colors.green
                            : Colors.white,
                      ),
                      onPressed: () async {
                        if (currentChapter is LocalChapter) {
                          final repo = Provider.of<MangaRepository>(
                            context,
                            listen: false,
                          );
                          final auth = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          await repo.toggleChapterBookmark(
                            currentChapter,
                            !currentChapter.isBookmarked,
                            token: auth.token,
                          );
                          setState(() {});
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: Icon(
                        PhosphorIcons.chatCircle(),
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => DraggableScrollableSheet(
                            initialChildSize: 0.6,
                            minChildSize: 0.4,
                            maxChildSize: 0.95,
                            builder: (context, scrollController) {
                              final currentChapter =
                              widget.chapters[_currentChapterIndex];
                              final chapterId = currentChapter is Chapter
                                  ? currentChapter.id
                                  : (currentChapter as LocalChapter).chapterId;

                              return ChangeNotifierProvider(
                                create: (_) => CommentsProvider(),
                                child: CommentsBottomSheet(
                                  scrollController: scrollController,
                                  currentChapterIndex: _currentChapterIndex,
                                  mangaId: widget.manga.id,
                                  chapterId: chapterId,
                                  chapters: widget.chapters,
                                  onChapterChange: (index) {
                                    setState(() {
                                      _currentChapterIndex = index;
                                    });
                                    _loadPages();
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChapterButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        disabledColor: Colors.white24,
      ),
    );
  }
}

class VerticalBarThumbShape extends SliderComponentShape {
  final double width;
  final double height;
  final Color color;

  const VerticalBarThumbShape({
    this.width = 4.0,
    this.height = 24.0,
    this.color = const Color(0xFF34D399),
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(width, height);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: height),
      const Radius.circular(2.0),
    );

    canvas.drawRRect(rRect, paint);
  }
}
