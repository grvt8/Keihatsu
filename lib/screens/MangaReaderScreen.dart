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
import '../components/Comments.dart';

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

  // History tracking
  Timer? _debounceTimer;
  LocalManga? _localManga;

  @override
  void initState() {
    super.initState();
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

      await repo.updateReadingProgress(
        manga: _localManga!,
        chapterId: chapterId,
        pageIndex: pageIndex,
        token: auth.token,
        isRead: isRead,
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

      if (localPages.isNotEmpty) {
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
                color: brandColor.withOpacity(0.9),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
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
              bottom: 0,
              left: 0,
              right: 0,
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
                              icon: Icon(
                                PhosphorIcons.caretDoubleLeft(),
                                color: Colors.white,
                              ),
                              onPressed:
                              _currentChapterIndex <
                                  widget.chapters.length - 1
                                  ? () {
                                setState(() => _currentChapterIndex++);
                                _loadPages();
                              }
                                  : null,
                            ),
                            Text(
                              "${_sliderValue.toInt()}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Expanded(
                              child: Slider(
                                value: _sliderValue,
                                min: 1,
                                max: _pages.isEmpty
                                    ? 1
                                    : _pages.length.toDouble(),
                                activeColor: Colors.white,
                                inactiveColor: Colors.white24,
                                onChanged: (val) =>
                                    setState(() => _sliderValue = val),
                              ),
                            ),
                            Text(
                              "${_pages.length}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            IconButton(
                              icon: Icon(
                                PhosphorIcons.caretDoubleRight(),
                                color: Colors.white,
                              ),
                              onPressed: _currentChapterIndex > 0
                                  ? () {
                                setState(() => _currentChapterIndex--);
                                _loadPages();
                              }
                                  : null,
                            ),
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
                          builder: (context) => CommentsBottomSheet(
                            scrollController: _scrollController,
                            currentChapterIndex: _currentChapterIndex,
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
}
