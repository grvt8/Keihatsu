import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../components/MainNavigationBar.dart';
import '../models/manga.dart';
import '../services/sources_api.dart';
import '../theme_provider.dart';
import 'MangaDetailsScreen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final int _currentIndex = 1;
  late Future<MangasPage> _mangaFuture;
  final SourcesApi _sourcesApi = SourcesApi();
  
  // For now, let's fetch from a default source (e.g., 'manhuatop') to populate the library
  final String _defaultSourceId = 'manhuatop';

  @override
  void initState() {
    super.initState();
    _mangaFuture = _sourcesApi.getMangaList(_defaultSourceId, 'popular');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Library',
          style: GoogleFonts.hennyPenny(
            textStyle: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.magnifyingGlass(), color: textColor)),
          IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.funnel(), color: textColor)),
          IconButton(
            onPressed: () {
              setState(() {
                _mangaFuture = _sourcesApi.getMangaList(_defaultSourceId, 'popular');
              });
            },
            icon: Icon(PhosphorIcons.arrowsClockwise(), color: textColor),
          ),
        ],
      ),
      body: FutureBuilder<MangasPage>(
        future: _mangaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: brandColor));
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIcons.warningCircle(), size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load library'),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _mangaFuture = _sourcesApi.getMangaList(_defaultSourceId, 'popular');
                      });
                    },
                    child: Text('Retry', style: TextStyle(color: brandColor)),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.mangas.isEmpty) {
            return Center(child: Text('Your library is empty', style: TextStyle(color: textColor.withOpacity(0.6))));
          }

          final mangas = snapshot.data!.mangas;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: mangas.length,
            itemBuilder: (context, index) {
              final manga = mangas[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MangaDetailsScreen(manga: manga),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      // Manga Cover
                      Positioned.fill(
                        child: Image.network(
                          manga.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.broken_image, color: Colors.white54),
                          ),
                        ),
                      ),
                      // Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Update Badge
                      Positioned(
                        top: 5,
                        left: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: brandColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "NEW",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Title
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Text(
                          manga.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentIndex,
        brandColor: brandColor,
      ),
    );
  }
}
