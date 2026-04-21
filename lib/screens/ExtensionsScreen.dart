import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../components/MainNavigationBar.dart';
import '../models/local_models.dart';
import '../services/sources_repository.dart';
import '../theme_provider.dart';

class ExtensionsScreen extends StatefulWidget {
  const ExtensionsScreen({super.key});

  @override
  State<ExtensionsScreen> createState() => _ExtensionsScreenState();
}

class _ExtensionsScreenState extends State<ExtensionsScreen> {
  final int _currentIndex = 3;
  late Future<List<LocalSource>> _sourcesFuture;
  String _searchQuery = '';

  static const String _availableSourceId = 'manhuatop';

  @override
  void initState() {
    super.initState();
    _loadSources();
  }

  void _loadSources({bool forceRefresh = false}) {
    final repo = Provider.of<SourcesRepository>(context, listen: false);
    setState(() {
      _sourcesFuture = _loadAndNormalizeSources(
        repo,
        forceRefresh: forceRefresh,
      );
    });
  }

  Future<List<LocalSource>> _loadAndNormalizeSources(
      SourcesRepository repo, {
        bool forceRefresh = false,
      }) async {
    final sources = await repo.getSources(forceRefresh: forceRefresh);

    for (final source in sources) {
      if (source.sourceId.toLowerCase() != _availableSourceId &&
          source.enabled) {
        await repo.toggleSource(source.sourceId, false);
      }
    }

    return repo.getSources();
  }

  Future<void> _handleSourceToggle(
      SourcesRepository repo,
      LocalSource source,
      bool value,
      ) async {
    final isAvailable = source.sourceId.toLowerCase() == _availableSourceId;

    if (!isAvailable) {
      if (value && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Coming soon')));
      }

      if (source.enabled) {
        await repo.toggleSource(source.sourceId, false);
        _loadSources();
      }
      return;
    }

    await repo.toggleSource(source.sourceId, value);
    _loadSources();
  }

  Widget _buildFallbackIcon(LocalSource source, Color brandColor) {
    if (source.iconLocalPath != null) {
      return Image.file(
        File(source.iconLocalPath!),
        fit: BoxFit.cover,
        color:
        source.sourceId.toLowerCase() == _availableSourceId &&
            source.enabled
            ? null
            : Colors.grey,
        colorBlendMode:
        source.sourceId.toLowerCase() == _availableSourceId &&
            source.enabled
            ? null
            : BlendMode.saturation,
        errorBuilder: (context, error, stackTrace) =>
            Icon(PhosphorIcons.puzzlePiece(), color: brandColor),
      );
    } else if (source.iconUrl != null) {
      return Image.network(
        source.iconUrl!,
        fit: BoxFit.cover,
        color:
        source.sourceId.toLowerCase() == _availableSourceId &&
            source.enabled
            ? null
            : Colors.grey,
        colorBlendMode:
        source.sourceId.toLowerCase() == _availableSourceId &&
            source.enabled
            ? null
            : BlendMode.saturation,
        errorBuilder: (context, error, stackTrace) =>
            Icon(PhosphorIcons.puzzlePiece(), color: brandColor),
      );
    } else {
      return Icon(PhosphorIcons.puzzlePiece(), color: brandColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color cardColor = isDarkMode
        ? Colors.white10
        : Colors.white.withOpacity(0.5);
    final repo = Provider.of<SourcesRepository>(context, listen: false);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Extensions',
          style: GoogleFonts.hennyPenny(
            textStyle: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _loadSources(forceRefresh: true),
            icon: Icon(PhosphorIcons.arrowsClockwise(), color: textColor),
          ),
        ],
      ),
      body: FutureBuilder<List<LocalSource>>(
        future: _sourcesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: brandColor));
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.warningCircle(),
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load extensions',
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () => _loadSources(),
                    child: Text('Retry', style: TextStyle(color: brandColor)),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No extensions found',
                style: TextStyle(color: textColor.withOpacity(0.6)),
              ),
            );
          }

          final sources = snapshot.data!;
          final filteredSources = sources.where((source) {
            if (_searchQuery.trim().isEmpty) {
              return true;
            }

            final query = _searchQuery.toLowerCase();
            return source.name.toLowerCase().contains(query) ||
                source.sourceId.toLowerCase().contains(query) ||
                source.baseUrl.toLowerCase().contains(query);
          }).toList();

          if (filteredSources.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSearchField(brandColor, textColor, cardColor),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'No extensions match your search',
                    style: TextStyle(color: textColor.withOpacity(0.6)),
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: filteredSources.length + 1,
            separatorBuilder: (context, index) =>
                SizedBox(height: index == 0 ? 20 : 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildSearchField(brandColor, textColor, cardColor);
              }

              final source = filteredSources[index - 1];
              return _buildSourceCard(
                source,
                brandColor,
                textColor,
                cardColor,
                repo,
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

  Widget _buildSearchField(Color brandColor, Color textColor, Color cardColor) {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      style: TextStyle(color: textColor),
      cursorColor: brandColor,
      decoration: InputDecoration(
        hintText: 'Search extensions',
        hintStyle: TextStyle(color: textColor.withOpacity(0.45)),
        prefixIcon: Icon(
          PhosphorIcons.magnifyingGlass(),
          color: textColor.withOpacity(0.45),
        ),
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: brandColor.withOpacity(0.35)),
        ),
      ),
    );
  }

  Widget _buildSourceCard(
      LocalSource source,
      Color brandColor,
      Color textColor,
      Color cardColor,
      SourcesRepository repo,
      ) {
    final isAvailable = source.sourceId.toLowerCase() == _availableSourceId;
    final isEnabled = isAvailable && source.enabled;

    // Map of source IDs to local image assets
    final Map<String, String> extensionImages = {
      'atsumaru': 'images/extensions/atsumaru.png',
      'batcave': 'images/extensions/batcave.png',
      'manhuatop': 'images/extensions/manhuatop.jpeg',
      'weebcentral': 'images/extensions/weebcentral.png',
      'mangafire': 'images/extensions/mangafire.png',
    };

    final imagePath = extensionImages[source.sourceId.toLowerCase()];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEnabled ? cardColor : cardColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: brandColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imagePath != null
                  ? Image.asset(
                imagePath,
                fit: BoxFit.cover,
                color: isEnabled ? null : Colors.grey,
                colorBlendMode: isEnabled ? null : BlendMode.saturation,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackIcon(source, brandColor),
              )
                  : _buildFallbackIcon(source, brandColor),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isEnabled ? textColor : textColor.withOpacity(0.4),
                  ),
                ),
                Text(
                  '${source.lang.toUpperCase()} • ${source.baseUrl}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isEnabled
                        ? textColor.withOpacity(0.6)
                        : textColor.withOpacity(0.2),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  isAvailable ? 'Available now' : 'Coming soon',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isAvailable
                        ? brandColor
                        : textColor.withOpacity(0.35),
                  ),
                ),
              ],
            ),
          ),
          // Pin Icon moved beside the toggles
          IconButton(
            onPressed: () async {
              await repo.pinSource(source.sourceId, !source.pinned);
              _loadSources();
            },
            icon: Icon(
              source.pinned
                  ? PhosphorIcons.pushPin(PhosphorIconsStyle.fill)
                  : PhosphorIcons.pushPin(),
              color: source.pinned ? brandColor : textColor.withOpacity(0.3),
              size: 20,
            ),
          ),
          Switch(
            value: isEnabled,
            activeColor: brandColor,
            onChanged: (val) async {
              await _handleSourceToggle(repo, source, val);
            },
          ),
        ],
      ),
    );
  }
}
