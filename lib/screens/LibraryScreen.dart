import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../components/MainNavigationBar.dart';
import '../models/manga.dart';
import '../providers/library_provider.dart';
import '../theme_provider.dart';
import 'MangaDetailsScreen.dart';

enum DisplayMode { grid2, grid3, grid4, list }

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
  DisplayMode _displayMode = DisplayMode.grid3;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDisplaySettings() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final bgColor = themeProvider.effectiveBgColor;
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Display Mode",
                    style: GoogleFonts.denkOne(
                      textStyle: TextStyle(fontSize: 20, color: textColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDisplayOption(
                    context,
                    "2x2 Grid",
                    PhosphorIcons.squaresFour(),
                    DisplayMode.grid2,
                    setModalState,
                  ),
                  _buildDisplayOption(
                    context,
                    "3x3 Grid",
                    PhosphorIcons.squaresFour(),
                    DisplayMode.grid3,
                    setModalState,
                  ),
                  _buildDisplayOption(
                    context,
                    "4x4 Grid",
                    PhosphorIcons.gridFour(),
                    DisplayMode.grid4,
                    setModalState,
                  ),
                  _buildDisplayOption(
                    context,
                    "List View",
                    PhosphorIcons.listBullets(),
                    DisplayMode.list,
                    setModalState,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDisplayOption(
    BuildContext context,
    String title,
    PhosphorIconData icon,
    DisplayMode mode,
    StateSetter setModalState,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isSelected = _displayMode == mode;
    final brandColor = themeProvider.brandColor;
    final textColor = themeProvider.themeMode == ThemeMode.dark ? Colors.white : Colors.black87;

    return ListTile(
      onTap: () {
        setState(() {
          _displayMode = mode;
        });
        setModalState(() {});
        Navigator.pop(context);
      },
      leading: Icon(icon, color: isSelected ? brandColor : textColor.withOpacity(0.6)),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? brandColor : textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_circle, color: brandColor) : null,
    );
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
          IconButton(
            onPressed: _showDisplaySettings,
            icon: Icon(PhosphorIcons.funnel(), color: textColor),
          ),
          IconButton(onPressed: () {}, icon: Icon(PhosphorIcons.bell(), color: textColor)),
        ],
      ),
      body: libraryProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: brandColor))
          : libraryProvider.library.isEmpty
              ? _buildEmptyState(textColor)
              : filteredLibrary.isEmpty
                  ? _buildNoResultsState(textColor)
                  : _buildLibraryContent(filteredLibrary, brandColor, textColor),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentIndex,
        brandColor: brandColor,
      ),
    );
  }

  Widget _buildLibraryContent(List<Manga> mangas, Color brandColor, Color textColor) {
    if (_displayMode == DisplayMode.list) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: mangas.length,
        itemBuilder: (context, index) {
          return _buildMangaListItem(context, mangas[index], brandColor, textColor);
        },
      );
    }

    int crossAxisCount = 3;
    if (_displayMode == DisplayMode.grid2) crossAxisCount = 2;
    if (_displayMode == DisplayMode.grid4) crossAxisCount = 4;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: mangas.length,
      itemBuilder: (context, index) {
        final manga = mangas[index];
        return _buildMangaGridItem(context, manga, brandColor);
      },
    );
  }

  Widget _buildChapterBadge(String chapter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF8DE19C), // Light green like the reference image
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        chapter,
        style: GoogleFonts.denkOne(
          textStyle: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMangaListItem(BuildContext context, Manga manga, Color brandColor, Color textColor) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaDetailsScreen(manga: manga),
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 50,
              height: 75,
              child: Image.network(
                manga.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.broken_image, color: Colors.white54, size: 20),
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            left: 4,
            child: _buildChapterBadge("109"), // Placeholder chapter number
          ),
        ],
      ),
      title: Text(
        manga.title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        manga.author ?? "Unknown Author",
        style: TextStyle(
          color: textColor.withOpacity(0.5),
          fontSize: 13,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: brandColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "24 Ch.",
          style: TextStyle(
            color: brandColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
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
              top: 8,
              left: 8,
              child: _buildChapterBadge("109"), // Placeholder chapter number
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
