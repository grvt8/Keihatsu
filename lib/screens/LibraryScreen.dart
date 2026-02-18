import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../components/MainNavigationBar.dart';
import '../models/manga.dart';
import '../providers/library_provider.dart';
import '../theme_provider.dart';
import 'MangaDetailsScreen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final int _currentIndex = 1;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final libraryProvider = Provider.of<LibraryProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    final filteredLibrary = libraryProvider.library.where((manga) {
      return manga.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Search library...',
                  hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Text(
                'Library',
                style: GoogleFonts.hennyPenny(
                  textStyle: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = "";
                  _searchController.clear();
                }
              });
            },
            icon: Icon(_isSearching ? Icons.close : PhosphorIcons.magnifyingGlass(), color: textColor),
          ),
          IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.funnel(), color: textColor)),
          IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.bell(), color: textColor)),
        ],
      ),
      body: libraryProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: brandColor))
          : libraryProvider.library.isEmpty
              ? _buildEmptyState(textColor)
              : filteredLibrary.isEmpty
                  ? _buildNoResultsState(textColor)
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: filteredLibrary.length,
                      itemBuilder: (context, index) {
                        final manga = filteredLibrary[index];
                        return _buildMangaGridItem(context, manga, brandColor);
                      },
                    ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentIndex,
        brandColor: brandColor,
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/libraryDefault.png',
            width: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            'Your library is empty',
            style: GoogleFonts.delius(
              textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add manga from extensions to see them here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(Color textColor) {
    return Center(
      child: Text(
        'No matches found in library',
        style: TextStyle(color: textColor.withOpacity(0.5)),
      ),
    );
  }

  Widget _buildMangaGridItem(BuildContext context, Manga manga, Color brandColor) {
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
  }
}
