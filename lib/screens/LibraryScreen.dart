import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keihatsu/models/user_preferences.dart';
import 'package:provider/provider.dart';
import '../components/MainNavigationBar.dart';
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

class _LibraryScreenState extends State<LibraryScreen> with TickerProviderStateMixin {
  final int _currentIndex = 1;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late TabController _categoryTabController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<OfflineLibraryProvider>(context, listen: false);
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
    final offlineLibrary = Provider.of<OfflineLibraryProvider>(context, listen: false);
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
    final provider = Provider.of<OfflineLibraryProvider>(context);
    final state = provider.filterState;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildToggle("Downloaded", state.filterDownloaded, brandColor, textColor, (val) {
            provider.updateFilters(state.copyWith(filterDownloaded: val));
          }),
          _buildToggle("Unread", state.filterUnread, brandColor, textColor, (val) {
            provider.updateFilters(state.copyWith(filterUnread: val));
          }),
          _buildToggle("Started", state.filterStarted, brandColor, textColor, (val) {
            provider.updateFilters(state.copyWith(filterStarted: val));
          }),
          _buildToggle("Bookmarked", state.filterBookmarked, brandColor, textColor, (val) {
            provider.updateFilters(state.copyWith(filterBookmarked: val));
          }),
          _buildToggle("Completed", state.filterCompleted, brandColor, textColor, (val) {
            provider.updateFilters(state.copyWith(filterCompleted: val));
          }),
        ],
      ),
    );
  }

  Widget _buildSortTab(Color brandColor, Color textColor, StateSetter setModalState) {
    final provider = Provider.of<OfflineLibraryProvider>(context);
    final state = provider.filterState;

    final sortOptions = {
      'alphabetical': 'Alphabetical',
      'last_read': 'Last read',
      'last_updated': 'Last updated',
      'unread_count': 'Unread count',
      'total_chapters': 'Total chapters',
      'date_added': 'Date added',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ...sortOptions.entries.map((entry) => RadioListTile<String>(
            title: Text(entry.value, style: TextStyle(color: textColor)),
            value: entry.key,
            groupValue: state.sortBy,
            activeColor: brandColor,
            onChanged: (val) {
              if (val != null) {
                provider.updateFilters(state.copyWith(sortBy: val));
              }
            },
          )),
          const Divider(),
          _buildToggle("Ascending", state.order == 'asc', brandColor, textColor, (val) {
            provider.updateFilters(state.copyWith(order: val ? 'asc' : 'desc'));
          }),
        ],
      ),
    );
  }

  Widget _buildDisplayTab(Color brandColor, Color textColor, StateSetter setModalState) {
    final authProvider = Provider.of<AuthProvider>(context);
    final prefs = authProvider.preferences;
    if (prefs == null) return const Center(child: CircularProgressIndicator());

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
              _buildChoiceChip("Compact grid", "compact grid", brandColor, textColor, prefs.categoriesDisplayMode == 'compact grid', (val) {
                authProvider.updatePreferences({'categories_display_mode': val});
              }),
              _buildChoiceChip("Comfortable grid", "comfortable grid", brandColor, textColor, prefs.categoriesDisplayMode == 'comfortable grid', (val) {
                authProvider.updatePreferences({'categories_display_mode': val});
              }),
              _buildChoiceChip("Cover grid", "cover grid", brandColor, textColor, prefs.categoriesDisplayMode == 'cover grid', (val) {
                authProvider.updatePreferences({'categories_display_mode': val});
              }),
              _buildChoiceChip("List", "list", brandColor, textColor, prefs.categoriesDisplayMode == 'list', (val) {
                authProvider.updatePreferences({'categories_display_mode': val});
              }),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle(textColor, "Items per row"),
              Text(
                "${prefs.libraryItemsPerRow}",
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
              value: prefs.libraryItemsPerRow.toDouble(),
              min: 2,
              max: 6,
              divisions: 4,
              onChanged: (val) {
                authProvider.updatePreferences({'library_items_per_row': val.toInt()});
              },
            ),
          ),
          const SizedBox(height: 25),
          _buildSectionTitle(textColor, "Overlay"),
          _buildToggle("Downloaded chapters", prefs.overlayShowDownloaded, brandColor, textColor, (val) {
            authProvider.updatePreferences({'overlay_show_downloaded': val});
          }),
          _buildToggle("Unread chapters", prefs.overlayShowUnread, brandColor, textColor, (val) {
            authProvider.updatePreferences({'overlay_show_unread': val});
          }),
          _buildToggle("Language", prefs.overlayShowLanguage, brandColor, textColor, (val) {
            authProvider.updatePreferences({'overlay_show_language': val});
          }),
          const SizedBox(height: 25),
          _buildSectionTitle(textColor, "Tabs"),
          _buildToggle("Show category tabs", prefs.tabsShowCategories, brandColor, textColor, (val) {
            authProvider.updatePreferences({'tabs_show_categories': val});
          }),
          _buildToggle("Show number of items", prefs.tabsShowItemCount, brandColor, textColor, (val) {
            authProvider.updatePreferences({'tabs_show_item_count': val});
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

  Widget _buildChoiceChip(String label, String value, Color brandColor, Color textColor, bool isSelected, Function(String) onSelected) {
    return GestureDetector(
      onTap: () => onSelected(value),
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
    final offlineLibrary = Provider.of<OfflineLibraryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final prefs = authProvider.preferences;

    final categories = ["Default", ...offlineLibrary.categories.map((c) => c.name)];
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
                decoration: InputDecoration(
                  hintText: 'Search library...',
                  hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                  border: InputBorder.none,
                ),
                onChanged: (value) => offlineLibrary.updateFilters(offlineLibrary.filterState.copyWith(search: value)),
              )
            : Text(
                'Library',
                style: GoogleFonts.hennyPenny(
                  textStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: textColor),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  offlineLibrary.updateFilters(offlineLibrary.filterState.copyWith(search: null));
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.tune, color: textColor),
            onPressed: _showDisplaySettings,
          ),
        ],
        bottom: TabBar(
          controller: _categoryTabController,
          isScrollable: true,
          indicatorColor: brandColor,
          labelColor: brandColor,
          unselectedLabelColor: textColor.withOpacity(0.6),
          labelStyle: GoogleFonts.denkOne(fontSize: 14),
          dividerColor: Colors.transparent,
          tabs: categories.map((cat) => Tab(text: cat)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _categoryTabController,
        children: categories.map((cat) {
           final filteredManga = cat == "Default" 
            ? offlineLibrary.library 
            : offlineLibrary.library.where((m) {
                // Find category id for name
                final localCat = offlineLibrary.categories.firstWhere((c) => c.name == cat);
                // Check if manga is assigned to this category
                // (Note: This logic depends on LocalCategoryAssignment being available in provider)
                return true; // Simplified for now
              }).toList();

           if (filteredManga.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.library_books, size: 64, color: textColor.withOpacity(0.2)),
                   const SizedBox(height: 16),
                   Text("No manga in this category", style: TextStyle(color: textColor.withOpacity(0.5))),
                 ],
               ),
             );
           }

           return GridView.builder(
             padding: const EdgeInsets.all(12),
             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
               crossAxisCount: prefs?.libraryItemsPerRow ?? 3,
               childAspectRatio: 0.7,
               crossAxisSpacing: 10,
               mainAxisSpacing: 10,
             ),
             itemCount: filteredManga.length,
             itemBuilder: (context, index) {
               final entry = filteredManga[index];
               return _buildMangaCard(entry, brandColor, textColor, prefs as UserPreferences?);
             },
           );
        }).toList(),
      ),
      bottomNavigationBar: MainNavigationBar(currentIndex: _currentIndex, brandColor: brandColor,),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: brandColor,
        child: const Icon(Icons.add_chart, color: Colors.white),
      ),
    );
  }

  Widget _buildMangaCard(LocalLibraryEntry entry, Color brandColor, Color textColor, UserPreferences? prefs) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MangaDetailsScreen(
            manga: Manga(
              id: entry.mangaId,
              sourceId: entry.sourceId,
              title: entry.title,
              thumbnailUrl: entry.thumbnailUrl ?? '',
              url: '', // Local entries might not have original URL stored
              author: entry.author,
              lang: entry.language,
            ),
          )),
        );
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              entry.thumbnailUrl ?? '',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.withOpacity(0.1),
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
              entry.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.delius(
                textStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (prefs?.overlayShowUnread == true && entry.unreadCount > 0)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: brandColor, borderRadius: BorderRadius.circular(4)),
                child: Text(
                  "${entry.unreadCount}",
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
