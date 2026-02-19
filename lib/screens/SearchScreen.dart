import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../models/manga.dart';
import '../models/source.dart';
import '../services/sources_api.dart';
import '../theme_provider.dart';
import 'MangaDetailsScreen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SourcesApi _sourcesApi = SourcesApi();
  
  List<Source> _sources = [];
  Map<String, List<Manga>> _results = {};
  Map<String, bool> _loadingSources = {};
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadSources();
  }

  Future<void> _loadSources() async {
    try {
      final sources = await _sourcesApi.getSources();
      setState(() {
        _sources = sources;
      });
    } catch (e) {
      debugPrint('Error loading sources: $e');
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;

    setState(() {
      _results = {};
      _loadingSources = {for (var s in _sources) s.id: true};
      _hasSearched = true;
    });

    for (var source in _sources) {
      _sourcesApi.getMangaList(source.id, 'search', q: query).then((page) {
        if (mounted) {
          setState(() {
            if (page.mangas.isNotEmpty) {
              _results[source.name] = page.mangas;
            }
            _loadingSources[source.id] = false;
          });
        }
      }).catchError((e) {
        if (mounted) {
          setState(() {
            _loadingSources[source.id] = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color cardColor = isDarkMode ? Colors.white10 : Colors.white.withOpacity(0.5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: 'Search manga...',
            hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            onPressed: () => _performSearch(_searchController.text),
            icon: Icon(PhosphorIcons.magnifyingGlass(), color: textColor),
          ),
        ],
      ),
      body: !_hasSearched
          ? _buildEmptyState(textColor)
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                if (_loadingSources.values.any((loading) => loading))
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator(color: brandColor)),
                  ),
                ..._results.entries.map((entry) => _buildSourceSection(
                      entry.key,
                      entry.value,
                      brandColor,
                      textColor,
                      cardColor,
                    )),
                if (!_loadingSources.values.any((loading) => loading) && _results.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text('No results found', style: TextStyle(color: textColor.withOpacity(0.5))),
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
          Icon(PhosphorIcons.magnifyingGlass(), size: 80, color: textColor.withOpacity(0.1)),
          const SizedBox(height: 20),
          Text(
            'Search across all sources',
            style: GoogleFonts.delius(
              textStyle: TextStyle(color: textColor.withOpacity(0.4), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSection(String sourceName, List<Manga> mangas, Color brandColor, Color textColor, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            sourceName,
            style: GoogleFonts.hennyPenny(
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: brandColor),
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: mangas.length,
            itemBuilder: (context, index) {
              final manga = mangas[index];
              return _buildMangaCard(context, manga, brandColor, textColor, cardColor);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMangaCard(BuildContext context, Manga manga, Color brandColor, Color textColor, Color cardColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MangaDetailsScreen(manga: manga)),
        );
      },
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  manga.thumbnailUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.broken_image, color: Colors.white54),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                manga.title,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
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
