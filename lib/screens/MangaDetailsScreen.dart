import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme_provider.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import '../services/sources_api.dart';
import 'MangaReaderScreen.dart';

class MangaDetailsScreen extends StatefulWidget {
  final Manga manga;

  const MangaDetailsScreen({super.key, required this.manga});

  @override
  State<MangaDetailsScreen> createState() => _MangaDetailsScreenState();
}

class _MangaDetailsScreenState extends State<MangaDetailsScreen> {
  late ScrollController _scrollController;
  bool _showTitle = false;
  late Future<Manga> _mangaDetailsFuture;
  late Future<List<Chapter>> _chaptersFuture;
  final SourcesApi _sourcesApi = SourcesApi();

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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final Color cardColor = isDarkMode ? Colors.white10 : Colors.white.withOpacity(0.7);
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: FutureBuilder<Manga>(
        future: _mangaDetailsFuture,
        initialData: widget.manga, // Show initial data while fetching more details
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
                    leading: IconButton(
                      icon: Icon(PhosphorIcons.arrowLeft(), color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: _showTitle
                        ? Text(
                            manga.title,
                            style: GoogleFonts.hennyPenny(
                              textStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          )
                        : null,
                    actions: [
                      IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.downloadSimple(), color: Colors.white)),
                      IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.funnel(), color: Colors.white)),
                      IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.dotsThreeVertical(), color: Colors.white)),
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
                              _buildActionButton(PhosphorIcons.bookBookmark(PhosphorIconsStyle.fill), "In library", brandColor),
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
                                        Icon(PhosphorIcons.caretRight(), color: Colors.grey),
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
                                return Text("Error loading chapters", style: TextStyle(color: textColor));
                              }
                              final chapters = snapshot.data ?? [];
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
                                            Icon(PhosphorIcons.caretRight(), color: Colors.grey, size: 16),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ...chapters.take(3).map((chapter) => _buildChapterTile(context, chapter, brandColor, textColor)),
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
                      _buildBottomIconButton(PhosphorIcons.downloadSimple(), Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Open reader with first or last chapter
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(
                              child: Text(
                                "Read now",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildBottomIconButton(PhosphorIcons.check(), Colors.white),
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

  Widget _buildBottomIconButton(PhosphorIconData icon, Color color) {
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

  Widget _buildActionButton(PhosphorIconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
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

  Widget _buildChapterTile(BuildContext context, Chapter chapter, Color brandColor, Color textColor) {
    final dateStr = DateFormat('MM/dd/yy').format(DateTime.fromMillisecondsSinceEpoch(chapter.dateUpload));
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaReaderScreen(title: chapter.name),
          ),
        );
      },
      leading: Icon(PhosphorIcons.circle(PhosphorIconsStyle.fill), size: 10, color: brandColor),
      title: Text(chapter.name, style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
      subtitle: Text(dateStr, style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6))),
      trailing: IconButton(
        icon: Icon(PhosphorIcons.downloadSimple(), color: textColor.withOpacity(0.4)),
        onPressed: () {},
      ),
    );
  }
}
