import 'dart:io';
import 'package:flutter/material.dart';
import 'package:keihatsu/components/CustomBackButton.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme_provider.dart';
import '../providers/auth_provider.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import '../models/local_models.dart';
import '../services/manga_repository.dart';
import '../providers/offline_library_provider.dart';
import 'MangaReaderScreen.dart';

class MangaDetailsScreen extends StatefulWidget {
  final Manga manga;

  const MangaDetailsScreen({super.key, required this.manga});

  @override
  State<MangaDetailsScreen> createState() => _MangaDetailsScreenState();
}

class _MangaDetailsScreenState extends State<MangaDetailsScreen> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _showTitle = false;
  late Future<LocalManga?> _mangaDetailsFuture;
  late Future<List<LocalChapter>> _chaptersFuture;
  bool _showAllChapters = false;
  late AnimationController _arrowController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 100) {
        if (!_showTitle) setState(() => _showTitle = true);
      } else {
        if (_showTitle) setState(() => _showTitle = false);
      }
    });

    final repo = Provider.of<MangaRepository>(context, listen: false);
    _mangaDetailsFuture = repo.getMangaDetails(widget.manga.sourceId, widget.manga.id);
    _chaptersFuture = repo.getChapters(widget.manga.sourceId, widget.manga.id);

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final offlineLibrary = Provider.of<OfflineLibraryProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final Color cardColor = isDarkMode ? Colors.white10 : Colors.white.withOpacity(0.7);
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final bool isInLibrary = offlineLibrary.isInLibrary(widget.manga.id, widget.manga.sourceId);

    return Scaffold(
      backgroundColor: bgColor,
      body: FutureBuilder<LocalManga?>(
        future: _mangaDetailsFuture,
        builder: (context, mangaSnapshot) {
          final manga = mangaSnapshot.data;
          final displayTitle = manga?.title ?? widget.manga.title;
          final displayThumb = manga?.thumbnailLocalPath != null 
              ? FileImage(File(manga!.thumbnailLocalPath!)) as ImageProvider
              : NetworkImage(widget.manga.thumbnailUrl);

          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 350,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image(
                        image: displayThumb,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: bgColor),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              bgColor,
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    backgroundColor: _showTitle ? Colors.black : Colors.transparent,
                    elevation: 0,
                    pinned: true,
                    leading: const CustomBackButton(),
                    title: _showTitle
                        ? Text(
                            displayTitle,
                            style: GoogleFonts.hennyPenny(
                              textStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          )
                        : null,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image(
                                    image: displayThumb,
                                    height: 180,
                                    width: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayTitle,
                                      style: GoogleFonts.hennyPenny(
                                        textStyle: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 10.0,
                                              color: Colors.black,
                                              offset: Offset(2.0, 2.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(PhosphorIcons.user(), manga?.author ?? "Unknown"),
                                    const SizedBox(height: 4),
                                    _buildInfoRow(PhosphorIcons.clock(), "${manga?.status ?? "Ongoing"} • ${widget.manga.sourceId}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildActionButton(
                                isInLibrary ? PhosphorIcons.bookBookmark(PhosphorIconsStyle.fill) : PhosphorIcons.bookBookmark(),
                                isInLibrary ? "In library" : "Add to library",
                                brandColor,
                                onTap: () => offlineLibrary.toggleLibrary(widget.manga),
                              ),
                              _buildActionButton(PhosphorIcons.hourglassHigh(), "Syncing", isDarkMode ? Colors.white70 : Colors.black54),
                              _buildActionButton(PhosphorIcons.arrowsClockwise(), "Tracking", isDarkMode ? Colors.white70 : Colors.black54),
                              _buildActionButton(PhosphorIcons.globe(), "WebView", isDarkMode ? Colors.white70 : Colors.black54),
                            ],
                          ),
                          const SizedBox(height: 25),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (manga?.genres != null)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: manga!.genres!.map((genre) => Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: _buildTag("# ${genre.toUpperCase()}", brandColor, textColor),
                                      )).toList(),
                                    ),
                                  ),
                                const SizedBox(height: 15),
                                Text(
                                  manga?.description ?? "No description available.",
                                  style: TextStyle(color: textColor.withOpacity(0.9), height: 1.4),
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          FutureBuilder<List<LocalChapter>>(
                            future: _chaptersFuture,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                              final chapters = snapshot.data!;
                              final displayedChapters = _showAllChapters ? chapters : chapters.take(3).toList();

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("${chapters.length} Chapters", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                                        const Icon(Icons.chevron_right, color: Colors.grey),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ...displayedChapters.map((ch) => _buildChapterTile(context, ch, brandColor, textColor)),
                                    if (!_showAllChapters && chapters.length > 3)
                                      GestureDetector(
                                        onTap: () => setState(() => _showAllChapters = true),
                                        child: Icon(Icons.keyboard_double_arrow_down_rounded, color: brandColor, size: 30),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(PhosphorIconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 5),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white))),
      ],
    );
  }

  Widget _buildActionButton(PhosphorIconData icon, String label, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color brandColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.1)),
      ),
      child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildChapterTile(BuildContext context, LocalChapter chapter, Color brandColor, Color textColor) {
    final offlineLibrary = Provider.of<OfflineLibraryProvider>(context);
    final dateStr = DateFormat('MM/dd/yy').format(DateTime.fromMillisecondsSinceEpoch(chapter.dateUpload));
    final isDownloading = offlineLibrary.downloadingIds.contains(chapter.chapterId);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(PhosphorIcons.circle(PhosphorIconsStyle.fill), size: 10, color: brandColor),
      title: Text(chapter.name, style: TextStyle(color: textColor)),
      subtitle: Text(dateStr, style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6))),
      trailing: IconButton(
        icon: isDownloading 
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: brandColor))
            : Icon(chapter.downloaded ? Icons.check_circle : PhosphorIcons.downloadSimple(), color: chapter.downloaded ? Colors.green : Colors.grey),
        onPressed: (isDownloading || chapter.downloaded) ? null : () => offlineLibrary.downloadChapter(chapter.sourceId, chapter.mangaId, chapter.chapterId),
      ),
      onTap: () {
        // Navigate to reader using local data if available
      },
    );
  }
}
