import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../components/MainNavigationBar.dart';
import '../components/LibraryDisplaySettingsSheet.dart';
import '../models/local_models.dart';
import '../models/manga.dart';
import '../providers/offline_library_provider.dart';
import '../providers/auth_provider.dart';
import '../theme_provider.dart';
import 'MangaDetailsScreen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with TickerProviderStateMixin {
  final int _currentIndex = 1;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late TabController _categoryTabController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<OfflineLibraryProvider>(
      context,
      listen: false,
    );
    _categoryTabController = TabController(
      length: provider.categories.isEmpty ? 1 : provider.categories.length + 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryTabController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final offlineLibrary = Provider.of<OfflineLibraryProvider>(
      context,
      listen: false,
    );
    final brandColor = themeProvider.brandColor;
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black87;
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.effectiveBgColor,
        title: Text(
          "Add Category",
          style: GoogleFonts.denkOne(color: textColor),
        ),
        content: TextField(
          controller: categoryController,
          autofocus: true,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: "Category name",
            hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: brandColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final name = categoryController.text.trim();
              if (name.isNotEmpty) {
                try {
                  await offlineLibrary.libraryRepo.createCategory(name);
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              }
            },
            child: Text(
              "Add",
              style: TextStyle(color: brandColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDisplaySettings() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final bgColor = themeProvider.effectiveBgColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return const LibraryDisplaySettingsSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final offlineLibrary = Provider.of<OfflineLibraryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final prefs = authProvider.preferences;

    final categories = [
      "Default",
      ...offlineLibrary.categories.map((c) => c.name),
    ];
    if (_categoryTabController.length != categories.length) {
      _categoryTabController.dispose();
      _categoryTabController = TabController(
        length: categories.length,
        vsync: this,
      );
    }

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
          onChanged: (value) => offlineLibrary.updateFilters(
            offlineLibrary.filterState.copyWith(search: value),
          ),
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
        bottom: (prefs?.tabsShowCategories ?? true) && categories.isNotEmpty
            ? TabBar(
          controller: _categoryTabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: brandColor,
          labelColor: brandColor,
          unselectedLabelColor: textColor.withOpacity(0.5),
          tabs: categories.map((cat) {
            final categoryCount = offlineLibrary
                .getLibraryForCategory(cat)
                .length;
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cat,
                    style: const TextStyle(
                      fontFamily: 'Delius',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (prefs?.tabsShowItemCount ?? true) ...[
                    const SizedBox(width: 4),
                    Text(
                      "($categoryCount)",
                      style: TextStyle(fontSize: 12, color: brandColor),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        )
            : null,
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _isSearching = !_isSearching);
              if (!_isSearching) {
                offlineLibrary.updateFilters(
                  offlineLibrary.filterState.copyWith(search: ""),
                );
                _searchController.clear();
              }
            },
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: textColor,
            ),
          ),
          IconButton(
            onPressed: _showDisplaySettings,
            icon: Icon(Icons.filter_alt_rounded, color: textColor),
          ),
          IconButton(
            onPressed: () => offlineLibrary.refresh(true),
            icon: Icon(Icons.refresh, color: textColor),
          ),
        ],
      ),
      body: offlineLibrary.isLoading
          ? Center(child: CircularProgressIndicator(color: brandColor))
          : offlineLibrary.library.isEmpty
          ? _buildEmptyState(textColor)
          : TabBarView(
        controller: _categoryTabController,
        children: categories.map((cat) {
          final entries = offlineLibrary.getLibraryForCategory(cat);
          return _buildLibraryContent(
            entries,
            brandColor,
            textColor,
            prefs,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: brandColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentIndex,
        brandColor: brandColor,
      ),
    );
  }

  Widget _buildLibraryContent(
      List<LocalLibraryEntry> entries,
      Color brandColor,
      Color textColor,
      dynamic prefs,
      ) {
    final displayMode = prefs?.categoriesDisplayMode ?? 'comfortable grid';

    if (displayMode == 'list') {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return _buildMangaListItem(
            context,
            entries[index],
            brandColor,
            textColor,
            prefs,
          );
        },
      );
    }

    double aspectRatio = 0.65;
    if (displayMode == 'compact grid') aspectRatio = 0.7;
    if (displayMode == 'cover grid') aspectRatio = 0.6;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: prefs?.libraryItemsPerRow ?? 3,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildMangaGridItem(
          context,
          entry,
          brandColor,
          textColor,
          prefs,
          displayMode,
        );
      },
    );
  }

  Widget _buildBadgeRow(LocalLibraryEntry entry, dynamic prefs) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if ((prefs?.overlayShowUnread ?? true) && entry.unreadCount > 0) ...[
          _buildSingleBadge("${entry.unreadCount}", const Color(0xFFFFB3B3)),
          const SizedBox(width: 2),
        ],
        if ((prefs?.overlayShowDownloaded ?? true) &&
            entry.downloadedCount > 0) ...[
          _buildSingleBadge(
            "${entry.downloadedCount}",
            const Color(0xFF8DE19C),
          ),
          const SizedBox(width: 2),
        ],
      ],
    );
  }

  Widget _buildSingleBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.denkOne(
          textStyle: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMangaListItem(
      BuildContext context,
      LocalLibraryEntry entry,
      Color brandColor,
      Color textColor,
      dynamic prefs,
      ) {
    return ListTile(
      onTap: () {
        final manga = Manga(
          id: entry.mangaId,
          sourceId: entry.sourceId,
          title: entry.title,
          thumbnailUrl: entry.thumbnailUrl ?? "",
          url: "",
          author: entry.author,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaDetailsScreen(manga: manga),
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 50,
          height: 75,
          child: entry.thumbnailUrl != null
              ? Image.network(entry.thumbnailUrl!, fit: BoxFit.cover)
              : Container(color: Colors.grey),
        ),
      ),
      title: Text(
        entry.title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        entry.author ?? "Unknown Author",
        style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 13),
      ),
      trailing: _buildBadgeRow(entry, prefs),
    );
  }

  Widget _buildMangaGridItem(
      BuildContext context,
      LocalLibraryEntry entry,
      Color brandColor,
      Color textColor,
      dynamic prefs,
      String displayMode,
      ) {
    final bool showTitle = displayMode != 'cover grid';

    return GestureDetector(
      onTap: () {
        final manga = Manga(
          id: entry.mangaId,
          sourceId: entry.sourceId,
          title: entry.title,
          thumbnailUrl: entry.thumbnailUrl ?? "",
          url: "",
          author: entry.author,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaDetailsScreen(manga: manga),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: entry.thumbnailUrl != null
                        ? Image.network(entry.thumbnailUrl!, fit: BoxFit.cover)
                        : Container(color: Colors.grey),
                  ),
                  if (displayMode == 'compact grid')
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
                    child: _buildBadgeRow(entry, prefs),
                  ),
                  if (displayMode == 'compact grid')
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        entry.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (displayMode == 'comfortable grid')
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 2, right: 2),
              child: Text(
                entry.title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.library_books, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'Your library is empty',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
