import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../components/MainNavigationBar.dart';
import '../models/source.dart';
import '../services/sources_api.dart';
import '../theme_provider.dart';
import '../providers/auth_provider.dart';

class ExtensionsScreen extends StatefulWidget {
  const ExtensionsScreen({super.key});

  @override
  State<ExtensionsScreen> createState() => _ExtensionsScreenState();
}

class _ExtensionsScreenState extends State<ExtensionsScreen> {
  final int _currentIndex = 3;
  late Future<List<Source>> _sourcesFuture;
  final SourcesApi _sourcesApi = SourcesApi();

  @override
  void initState() {
    super.initState();
    _sourcesFuture = _sourcesApi.getSources();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final brandColor = themeProvider.brandColor;
    final bgColor = themeProvider.effectiveBgColor;
    final bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color cardColor = isDarkMode ? Colors.white10 : Colors.white.withOpacity(0.5);

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
            onPressed: () {
              setState(() {
                _sourcesFuture = _sourcesApi.getSources();
              });
            },
            icon: Icon(PhosphorIcons.arrowsClockwise(), color: textColor),
          ),
        ],
      ),
      body: FutureBuilder<List<Source>>(
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
                    onPressed: () {
                      setState(() {
                        _sourcesFuture = _sourcesApi.getSources();
                      });
                    },
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
              return _buildSourceCard(source, brandColor, textColor, cardColor, authProvider);
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

  Widget _buildSourceCard(Source source, Color brandColor, Color textColor, Color cardColor, AuthProvider authProvider) {
    final pref = authProvider.preferences?.sourcePreferences[source.id];
    final isEnabled = pref?.enabled ?? true;
    final isPinned = pref?.pinned ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEnabled ? cardColor : cardColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Pin Icon
          IconButton(
            onPressed: () {
              authProvider.updateSourcePreference(source.id, pinned: !isPinned);
            },
            icon: Icon(
              isPinned ? PhosphorIcons.pushPin(PhosphorIconsStyle.fill) : PhosphorIcons.pushPin(),
              color: isPinned ? brandColor : textColor.withOpacity(0.3),
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
              child: source.iconUrl != null
                  ? Image.network(
                      source.iconUrl!,
                      fit: BoxFit.cover,
                      color: isEnabled ? null : Colors.grey,
                      colorBlendMode: isEnabled ? null : BlendMode.saturation,
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
                    color: isEnabled ? textColor : textColor.withOpacity(0.4),
                  ),
                ),
                Text(
                  '${source.lang.toUpperCase()} • ${source.baseUrl}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isEnabled ? textColor.withOpacity(0.6) : textColor.withOpacity(0.2),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            activeColor: brandColor,
            onChanged: (val) {
              authProvider.updateSourcePreference(source.id, enabled: val);
            },
          ),
        ],
      ),
    );
  }
}
