import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../components/MainNavigationBar.dart';
import '../models/local_models.dart';
import '../models/manga.dart';
import '../providers/offline_library_provider.dart';
import '../theme_provider.dart';
import 'MangaDetailsScreen.dart';

enum DisplayStyle { compact, comfortable, coverOnly, list }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with TickerProviderStateMixin {
  final int _currentIndex = 1;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  DisplayStyle _displayStyle = DisplayStyle.comfortable;
  int _itemsPerRow = 3;

  late TabController _categoryTabController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<OfflineLibraryProvider>(context, listen: false);
    _categoryTabController = TabController(
      length: provider.categories.isEmpty ? 1 : provider.categories.length + 1, 
      vsync: this
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final offlineLibrary = Provider.of<OfflineLibraryProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    final filteredLibrary = offlineLibrary.library.where((entry) {
      return entry.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final categories = ["All", ...offlineLibrary.categories.map((c) => c.name)];
    if (_categoryTabController.length != categories.length) {
      _categoryTabController.dispose();
      _categoryTabController = TabController(length: categories.length, vsync: this);
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
                decoration: const InputDecoration(hintText: 'Search library...', border: InputBorder.none),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : Text('Library', style: GoogleFonts.hennyPenny(textStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
        bottom: TabBar(
          controller: _categoryTabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: brandColor,
          labelColor: brandColor,
          unselectedLabelColor: textColor.withOpacity(0.5),
          tabs: categories.map((cat) => Tab(text: cat)).toList(),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isSearching = !_isSearching),
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: textColor),
          ),
          IconButton(onPressed: () => offlineLibrary.refresh(true), icon: Icon(Icons.refresh, color: textColor)),
        ],
      ),
      body: offlineLibrary.isLoading
          ? Center(child: CircularProgressIndicator(color: brandColor))
          : offlineLibrary.library.isEmpty
              ? _buildEmptyState(textColor)
              : TabBarView(
                  controller: _categoryTabController,
                  children: categories.map((cat) => _buildLibraryContent(filteredLibrary, brandColor, textColor)).toList(),
                ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentIndex,
        brandColor: brandColor,
      ),
    );
  }

  Widget _buildLibraryContent(List<LocalLibraryEntry> entries, Color brandColor, Color textColor) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _itemsPerRow,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildMangaGridItem(context, entry, brandColor, textColor);
      },
    );
  }

  Widget _buildMangaGridItem(BuildContext context, LocalLibraryEntry entry, Color brandColor, Color textColor) {
    return GestureDetector(
      onTap: () {
        // Convert LocalLibraryEntry back to Manga model or fetch LocalManga
        final manga = Manga(
          id: entry.mangaId,
          sourceId: entry.sourceId,
          title: entry.title,
          thumbnailUrl: entry.thumbnailUrl ?? "",
          url: "", // Not stored in entry
          author: entry.author,
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => MangaDetailsScreen(manga: manga)));
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
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: brandColor, borderRadius: BorderRadius.circular(4)),
                      child: Text(entry.sourceId, style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(entry.title, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
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
          Text('Your library is empty', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
