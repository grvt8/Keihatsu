import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../components/MainNavigationBar.dart';
import '../models/local_models.dart';
import '../services/sources_repository.dart';
import '../theme_provider.dart';
import '../providers/auth_provider.dart';

class ExtensionsScreen extends StatefulWidget {
  const ExtensionsScreen({super.key});

  @override
  State<ExtensionsScreen> createState() => _ExtensionsScreenState();
}

class _ExtensionsScreenState extends State<ExtensionsScreen> {
  final int _currentIndex = 3;
  late Future<List<LocalSource>> _sourcesFuture;

  @override
  void initState() {
    super.initState();
    _loadSources();
  }

  void _loadSources({bool forceRefresh = false}) {
    final repo = Provider.of<SourcesRepository>(context, listen: false);
    setState(() {
      _sourcesFuture = repo.getSources(forceRefresh: forceRefresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color cardColor = isDarkMode ? Colors.white10 : Colors.white.withOpacity(0.5);
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
            textStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 24),
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
                  Icon(PhosphorIcons.warningCircle(), size: 48, color: Colors.red),
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
          
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: sources.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final source = sources[index];
              return _buildSourceCard(source, brandColor, textColor, cardColor, repo);
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

  Widget _buildSourceCard(LocalSource source, Color brandColor, Color textColor, Color cardColor, SourcesRepository repo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: source.enabled ? cardColor : cardColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Pin Icon
          IconButton(
            onPressed: () async {
              await repo.pinSource(source.sourceId, !source.pinned);
              _loadSources();
            },
            icon: Icon(
              source.pinned ? PhosphorIcons.pushPin(PhosphorIconsStyle.fill) : PhosphorIcons.pushPin(),
              color: source.pinned ? brandColor : textColor.withOpacity(0.3),
              size: 20,
            ),
          ),
          
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: brandColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: source.iconLocalPath != null
                  ? Image.file(
                      File(source.iconLocalPath!),
                      fit: BoxFit.cover,
                      color: source.enabled ? null : Colors.grey,
                      colorBlendMode: source.enabled ? null : BlendMode.saturation,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(PhosphorIcons.puzzlePiece(), color: brandColor),
                    )
                  : Icon(PhosphorIcons.puzzlePiece(), color: brandColor),
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
                    color: source.enabled ? textColor : textColor.withOpacity(0.4),
                  ),
                ),
                Text(
                  '${source.lang.toUpperCase()} • ${source.baseUrl}',
                  style: TextStyle(
                    fontSize: 12,
                    color: source.enabled ? textColor.withOpacity(0.6) : textColor.withOpacity(0.2),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: source.enabled,
            activeColor: brandColor,
            onChanged: (val) async {
              await repo.toggleSource(source.sourceId, val);
              _loadSources();
            },
          ),
        ],
      ),
    );
  }
}
