import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/local_models.dart';

class ExtensionImage extends StatelessWidget {
  const ExtensionImage({
    super.key,
    required this.source,
    this.isEnabled = true,
    this.size = 50,
    this.borderRadius = 10,
  });

  final LocalSource source;
  final bool isEnabled;
  final double size;
  final double borderRadius;

  static const Map<String, String> _bundledImages = {
    'atsumaru': 'images/extensions/atsumaru.png',
    'batcave': 'images/extensions/batcave.png',
    'manhuatop': 'images/extensions/manhuatop.jpeg',
    'weebcentral': 'images/extensions/weebcentral.png',
    'mangafire': 'images/extensions/mangafire.png',
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imagePath = _bundledImages[source.sourceId.toLowerCase()];

    Widget image;
    if (imagePath != null) {
      image = Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(colorScheme),
      );
    } else if (source.iconLocalPath case final localPath?) {
      image = Image.file(
        File(localPath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(colorScheme),
      );
    } else if (source.iconUrl case final iconUrl?) {
      image = Image.network(
        iconUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(colorScheme),
      );
    } else {
      image = _fallback(colorScheme);
    }

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.4),
      ),
      child: image,
    );

    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: isEnabled
            ? content
            : ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.saturation,
                ),
                child: content,
              ),
      ),
    );
  }

  Widget _fallback(ColorScheme colorScheme) {
    return Center(
      child: Icon(
        PhosphorIcons.puzzlePiece(),
        color: colorScheme.primary,
        size: size * 0.48,
      ),
    );
  }
}
