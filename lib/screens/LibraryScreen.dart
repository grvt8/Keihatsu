import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../components/MainNavigationBar.dart';
import '../models/manga.dart';
import '../providers/library_provider.dart';
import '../providers/auth_provider.dart';
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

  // Filter settings
  bool _filterDownloaded = false;
  bool _filterUnread = false;
  bool _filterStarted = false;
  bool _filterBookmarked = false;
  bool _filterCompleted = false;

  // Mock overlay settings for UI
  bool _showDownloaded = true;
  bool _showUnread = true;
  bool _showLocalSource = true;
  bool _showLanguage = true;
  bool _showContinueButton = false;
  bool _showCategoryTabs = true;
  bool _showItemCount = true;

  late TabController _categoryTabController;

  @override
  void initState() {
    super.initState();
    final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
    _categoryTabController = TabController(length: libraryProvider.categories.length, vsync: this);
    
    // Fetch initial data
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      libraryProvider.fetchLibrary(authProvider.token!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryTabController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
    final brandColor = themeProvider.brandColor;
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black87;
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.effectiveBgColor,
        title: Text("Add Category", style: GoogleFonts.denkOne(color: textColor)),
        content: TextField(
          controller: categoryController,
          autofocus: true,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: "Category name",
            hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: brandColor)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final name = categoryController.text.trim();
              if (name.isNotEmpty && authProvider.token != null) {
                try {
                  await libraryProvider.addCategory(authProvider.token!, name);
                  if (mounted) {
                    setState(() {
                      _categoryTabController = TabController(
                        length: libraryProvider.categories.length,
                        vsync: this,
                      );
                    });
                    Navigator.pop(context);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              }
            },
            child: Text("Add", style: TextStyle(color: brandColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDisplaySettings() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DefaultTabController(
          length: 3,
          initialIndex: 0,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TabBar(
                      indicatorColor: brandColor,
                      labelColor: brandColor,
                      unselectedLabelColor: textColor.withOpacity(0.6),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: GoogleFonts.denkOne(fontSize: 16),
                      tabs: const [
                        Tab(text: "Filter"),
                        Tab(text: "Sort"),
                        Tab(text: "Display"),
                      ],
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    SizedBox(
                      height: 450,
                      child: TabBarView(
                        children: [
                          _buildFilterTab(brandColor, textColor, setModalState),
                          _buildSortTab(brandColor, textColor, setModalState),
                          _buildDisplayTab(brandColor, textColor, setModalState),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterTab(Color brandColor, Color textColor, StateSetter setModalState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildToggle("Downloaded", _filterDownloaded, brandColor, textColor, (val) {
            setState(() => _filterDownloaded = val);
            setModalState(() {});
          }),
          _buildToggle("Unread", _filterUnread, brandColor, textColor, (val) {
            setState(() => _filterUnread = val);
            setModalState(() {});
          }),
          _buildToggle("Started", _filterStarted, brandColor, textColor, (val) {
            setState(() => _filterStarted = val);
            setModalState(() {});
          }),
          _buildToggle("Bookmarked", _filterBookmarked, brandColor, textColor, (val) {
            setState(() => _filterBookmarked = val);
            setModalState(() {});
          }),
          _buildToggle("Completed", _filterCompleted, brandColor, textColor, (val) {
            setState(() => _filterCompleted = val);
            setModalState(() {});
          }),
        ],
      ),
    );
  }

  Widget _buildSortTab(Color brandColor, Color textColor, StateSetter setModalState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildToggle("Alphabetically", false, brandColor, textColor, (val) {}),
          _buildToggle("Total chapters", false, brandColor, textColor, (val) {}),
          _buildToggle("Last read", true, brandColor, textColor, (val) {}),
          _buildToggle("Last updated", false, brandColor, textColor, (val) {}),
          _buildToggle("Unread count", false, brandColor, textColor, (val) {}),
          _buildToggle("Latest chapter", false, brandColor, textColor, (val) {}),
          _buildToggle("Date fetched", false, brandColor, textColor, (val) {}),
          _buildToggle("Date added", false, brandColor, textColor, (val) {}),
        ],
      ),
    );
  }

  Widget _buildDisplayTab(Color brandColor, Color textColor, StateSetter setModalState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(textColor, "Display mode"),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip("Compact grid", DisplayStyle.compact, brandColor, textColor, setModalState),
              _buildChoiceChip("Comfortable grid", DisplayStyle.comfortable, brandColor, textColor, setModalState),
              _buildChoiceChip("Cover-only grid", DisplayStyle.coverOnly, brandColor, textColor, setModalState),
              _buildChoiceChip("List", DisplayStyle.list, brandColor, textColor, setModalState),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle(textColor, "Items per row"),
              Text(
                "$_itemsPerRow",
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: brandColor,
              inactiveTrackColor: brandColor.withOpacity(0.2),
              thumbColor: brandColor,
              overlayColor: brandColor.withOpacity(0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: _itemsPerRow.toDouble(),
              min: 2,
              max: 6,
              divisions: 4,
              onChanged: (val) {
                setState(() => _itemsPerRow = val.toInt());
                setModalState(() {});
              },
            ),
          ),
          const SizedBox(height: 25),
          _buildSectionTitle(textColor, "Overlay"),
          _buildToggle("Downloaded chapters", _showDownloaded, brandColor, textColor, (val) {
            setState(() => _showDownloaded = val);
            setModalState(() {});
          }),
          _buildToggle("Unread chapters", _showUnread, brandColor, textColor, (val) {
            setState(() => _showUnread = val);
            setModalState(() {});
          }),
          _buildToggle("Local source", _showLocalSource, brandColor, textColor, (val) {
            setState(() => _showLocalSource = val);
            setModalState(() {});
          }),
          _buildToggle("Language", _showLanguage, brandColor, textColor, (val) {
            setState(() => _showLanguage = val);
            setModalState(() {});
          }),
          _buildToggle("Continue reading button", _showContinueButton, brandColor, textColor, (val) {
            setState(() => _showContinueButton = val);
            setModalState(() {});
          }),
          const SizedBox(height: 25),
          _buildSectionTitle(textColor, "Tabs"),
          _buildToggle("Show category tabs", _showCategoryTabs, brandColor, textColor, (val) {
            setState(() => _showCategoryTabs = val);
            setModalState(() {});
          }),
          _buildToggle("Show number of items", _showItemCount, brandColor, textColor, (val) {
            setState(() => _showItemCount = val);
            setModalState(() {});
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(Color textColor, String title) {
    return Text(
      title,
      style: GoogleFonts.dynaPuff(
        textStyle: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, DisplayStyle style, Color brandColor, Color textColor, StateSetter setModalState) {
    final isSelected = _displayStyle == style;
    return GestureDetector(
      onTap: () {
        setState(() => _displayStyle = style);
        setModalState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? brandColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? brandColor : textColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool value, Color brandColor, Color textColor, Function(bool) onChanged) {
    return ListTile(
      title: Text(label, style: TextStyle(color: textColor, fontSize: 16)),
      contentPadding: EdgeInsets.zero,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: brandColor,
        activeTrackColor: brandColor.withOpacity(0.5),
      ),
      dense: true,
      visualDensity: VisualDensity.compact,
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

    // Re-initialize TabController if categories length changed
    if (_categoryTabController.length != libraryProvider.categories.length) {
      _categoryTabController.dispose();
      _categoryTabController = TabController(length: libraryProvider.categories.length, vsync: this);
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

        bottom: _showCategoryTabs && libraryProvider.categories.isNotEmpty
            ? TabBar(
                controller: _categoryTabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: brandColor,
                labelColor: brandColor,
                unselectedLabelColor: textColor.withOpacity(0.5),
                tabs: libraryProvider.categories.map((cat) {
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat,
                          style: TextStyle(fontFamily: 'Delius', color: textColor, fontWeight: FontWeight.bold),
                        ),
                        if (_showItemCount) ...[
                          const SizedBox(width: 4),
                          Text(
                            "(${filteredLibrary.length})", // Simplified count for now
                            style: TextStyle(fontSize: 15, color: brandColor),
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
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = "";
                  _searchController.clear();
                }
              });
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: textColor),
          ),
          IconButton(
            onPressed: _showDisplaySettings,
            icon: Icon(Icons.filter_alt_rounded, color: textColor),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications, color: textColor)),
        ],
      ),
      body: libraryProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: brandColor))
          : libraryProvider.library.isEmpty
              ? _buildEmptyState(textColor)
              : filteredLibrary.isEmpty
                  ? _buildNoResultsState(textColor)
                  : _showCategoryTabs
                      ? TabBarView(
                          controller: _categoryTabController,
                          children: libraryProvider.categories.map((cat) => _buildLibraryContent(filteredLibrary, brandColor, textColor)).toList(),
                        )
                      : _buildLibraryContent(filteredLibrary, brandColor, textColor),
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

  Widget _buildLibraryContent(List<Manga> mangas, Color brandColor, Color textColor) {
    if (_displayStyle == DisplayStyle.list) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: mangas.length,
        itemBuilder: (context, index) {
          return _buildMangaListItem(context, mangas[index], brandColor, textColor);
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _itemsPerRow,
        childAspectRatio: _displayStyle == DisplayStyle.comfortable ? 0.6 : 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: mangas.length,
      itemBuilder: (context, index) {
        final manga = mangas[index];
        return _buildMangaGridItem(context, manga, brandColor, textColor);
      },
    );
  }

  Widget _buildBadgeRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showUnread) ...[
          _buildSingleBadge("41", const Color(0xFFFFB3B3)),
          const SizedBox(width: 2),
        ],
        if (_showDownloaded) ...[
          _buildSingleBadge("225", const Color(0xFF8DE19C)),
          const SizedBox(width: 2),
        ],
        if (_showLanguage)
          _buildSingleBadge("EN", const Color(0xFFFFD067)),
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
      leading: ClipRRect(
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
      trailing: _buildBadgeRow(),
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

  Widget _buildMangaGridItem(BuildContext context, Manga manga, Color brandColor, Color textColor) {
    final bool isComfortable = _displayStyle == DisplayStyle.comfortable;

    return GestureDetector(
      onTap: () {
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
                    child: Image.network(
                      manga.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.broken_image, color: Colors.white54),
                      ),
                    ),
                  ),
                  if (!isComfortable && _displayStyle != DisplayStyle.coverOnly)
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
                    child: _buildBadgeRow(),
                  ),
                  if (!isComfortable && _displayStyle != DisplayStyle.coverOnly)
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
          ),
          if (isComfortable)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 2, right: 2),
              child: Text(
                manga.title,
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
}
