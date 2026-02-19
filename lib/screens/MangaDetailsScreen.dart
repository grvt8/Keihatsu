import 'package:flutter/material.dart';
import 'package:keihatsu/components/CustomBackButton.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme_provider.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import '../services/sources_api.dart';
import '../providers/library_provider.dart';
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
  late Future<Manga> _mangaDetailsFuture;
  late Future<List<Chapter>> _chaptersFuture;
  final SourcesApi _sourcesApi = SourcesApi();
  bool _showAllChapters = false;
  late AnimationController _arrowController;
  late Future<List<Manga>> _recommendedMangaFuture;

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

    _mangaDetailsFuture = _sourcesApi.getMangaDetails(widget.manga.sourceId, widget.manga.id);
    _chaptersFuture = _sourcesApi.getChapters(widget.manga.sourceId, widget.manga.id);
    _recommendedMangaFuture = _sourcesApi.getMangaList(widget.manga.sourceId, 'popular').then((p) => p.mangas);

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
    final libraryProvider = Provider.of<LibraryProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final Color cardColor = isDarkMode ? Colors.white10 : Colors.white.withOpacity(0.7);
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final bool isInLibrary = libraryProvider.isInLibrary(widget.manga.id, widget.manga.sourceId);

    return Scaffold(
      backgroundColor: bgColor,
      body: FutureBuilder<Manga>(
        future: _mangaDetailsFuture,
        initialData: widget.manga,
        builder: (context, mangaSnapshot) {
          final manga = mangaSnapshot.data ?? widget.manga;

          return Stack(
            children: [
              // Background Blurred/Darkened Image
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 350,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        manga.thumbnailUrl,
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
                            manga.title,
                            style: GoogleFonts.hennyPenny(
                              textStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          )
                        : null,
                    actions: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.download, color: Colors.white)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list, color: Colors.white)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.white)),
                    ],
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
                              // Foreground Manga Cover
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
                                  child: Image.network(
                                    manga.thumbnailUrl,
                                    height: 180,
                                    width: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 180,
                                      width: 120,
                                      color: Colors.grey,
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      manga.title,
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
                                    _buildInfoRow(PhosphorIcons.user(), manga.author ?? "Unknown"),
                                    const SizedBox(height: 4),
                                    _buildInfoRow(PhosphorIcons.pencilLine(), manga.artist ?? "Unknown"),
                                    const SizedBox(height: 4),
                                    _buildInfoRow(PhosphorIcons.clock(), "${manga.status ?? "Ongoing"} • ${manga.sourceId}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildActionButton(
                                isInLibrary ? PhosphorIcons.bookBookmark(PhosphorIconsStyle.fill) : PhosphorIcons.bookBookmark(),
                                isInLibrary ? "In library" : "Add to library",
                                brandColor,
                                onTap: () => libraryProvider.toggleLibrary(manga),
                              ),
                              _buildActionButton(PhosphorIcons.hourglassHigh(), "Syncing", isDarkMode ? Colors.white70 : Colors.black54),
                              _buildActionButton(PhosphorIcons.arrowsClockwise(), "Tracking", isDarkMode ? Colors.white70 : Colors.black54),
                              _buildActionButton(PhosphorIcons.globe(), "WebView", isDarkMode ? Colors.white70 : Colors.black54),
                            ],
                          ),
                          const SizedBox(height: 25),

                          // Box for Tags and Description
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Scrollable Tags
                                if (manga.genres != null && manga.genres!.isNotEmpty)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: manga.genres!.map((genre) => Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: _buildTag("# ${genre.toUpperCase()}", brandColor, textColor),
                                      )).toList(),
                                    ),
                                  ),
                                const SizedBox(height: 15),
                                // Description
                                Text(
                                  manga.description ?? "No description available.",
                                  style: TextStyle(color: textColor.withOpacity(0.9), height: 1.4),
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 15),
                                Divider(color: textColor.withOpacity(0.1)),
                                const SizedBox(height: 10),
                                // Chapters Future Builder
                                FutureBuilder<List<Chapter>>(
                                  future: _chaptersFuture,
                                  builder: (context, chaptersSnapshot) {
                                    final chapterCount = chaptersSnapshot.hasData ? chaptersSnapshot.data!.length : "...";
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "$chapterCount Chapters",
                                              style: GoogleFonts.delius(
                                                textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                                              ),
                                            ),
                                            const Text("Tap to see all", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                          ],
                                        ),
                                        const Icon(Icons.chevron_right, color: Colors.grey),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Chapters Preview Box
                          FutureBuilder<List<Chapter>>(
                            future: _chaptersFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  height: 100,
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(color: brandColor),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        const Text("Error loading chapters"),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _chaptersFuture = _sourcesApi.getChapters(widget.manga.sourceId, widget.manga.id);
                                            });
                                          },
                                          child: const Text("Retry"),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }
                              final chapters = snapshot.data ?? [];
                              final displayedChapters = _showAllChapters ? chapters : chapters.take(3).toList();

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text("${chapters.length}", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                                            const SizedBox(width: 5),
                                            Text("Chapters", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text("More", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                            const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ...displayedChapters.asMap().entries.map(
                                      (entry) => _buildChapterTile(context, chapters, entry.key, brandColor, textColor),
                                    ),
                                    if (!_showAllChapters && chapters.length > 3)
                                      GestureDetector(
                                        onTap: () => setState(() => _showAllChapters = true),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: AnimatedBuilder(
                                            animation: _arrowController,
                                            builder: (context, child) {
                                              return Transform.translate(
                                                offset: Offset(0, 5 * _arrowController.value),
                                                child: Icon(
                                                  Icons.keyboard_double_arrow_down_rounded,
                                                  color: brandColor,
                                                  size: 30,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // "You may also like" Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("You may also like", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                                    Row(
                                      children: [
                                        const Text("More", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                        Icon(PhosphorIcons.caretRight(), color: Colors.grey, size: 16),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                SizedBox(
                                  height: 200,
                                  child: FutureBuilder<List<Manga>>(
                                    future: _recommendedMangaFuture,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                                      final recommendations = snapshot.data!.where((m) => m.id != widget.manga.id).take(6).toList();
                                      return ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: recommendations.length,
                                        itemBuilder: (context, index) {
                                          final recommendation = recommendations[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 15),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => MangaDetailsScreen(manga: recommendation),
                                                  ),
                                                );
                                              },
                                              child: SizedBox(
                                                width: 100,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(8),
                                                      child: Image.network(
                                                        recommendation.thumbnailUrl,
                                                        width: 100,
                                                        height: 140,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      recommendation.title,
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Floating Bottom Bar
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildBottomIconButton(Icons.download, Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FutureBuilder<List<Chapter>>(
                          future: _chaptersFuture,
                          builder: (context, snapshot) {
                            final chapters = snapshot.data;
                            return GestureDetector(
                              onTap: (chapters != null && chapters.isNotEmpty) ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MangaReaderScreen(
                                      manga: manga,
                                      chapters: chapters,
                                      initialChapterIndex: chapters.length - 1,
                                    ),
                                  ),
                                );
                              } : null,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: (chapters != null && chapters.isNotEmpty) ? Colors.grey.shade400 : Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Read now",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildBottomIconButton(Icons.check, Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomIconButton(IconData icon, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildInfoRow(PhosphorIconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              shadows: [
                Shadow(blurRadius: 5.0, color: Colors.black, offset: Offset(1.0, 1.0)),
              ],
            ),
          ),
        ),
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
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildChapterTile(BuildContext context, List<Chapter> chapters, int index, Color brandColor, Color textColor) {
    final chapter = chapters[index];
    final dateStr = DateFormat('MM/dd/yy').format(DateTime.fromMillisecondsSinceEpoch(chapter.dateUpload));
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaReaderScreen(
              manga: widget.manga,
              chapters: chapters,
              initialChapterIndex: index,
            ),
          ),
        );
      },
      leading: Icon(PhosphorIcons.circle(PhosphorIconsStyle.fill), size: 10, color: brandColor),
      title: Text(chapter.name, style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
      subtitle: Text(dateStr, style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6))),
      trailing: IconButton(
        icon: const Icon(Icons.download, color: Colors.grey),
        onPressed: () {},
      ),
    );
  }
}
