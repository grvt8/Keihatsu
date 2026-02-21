class SourcePreference {
  final bool enabled;
  final bool pinned;

  SourcePreference({this.enabled = true, this.pinned = false});

  factory SourcePreference.fromJson(Map<String, dynamic> json) {
    return SourcePreference(
      enabled: json['enabled'] ?? true,
      pinned: json['pinned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'pinned': pinned,
    };
  }
}

class UserPreferences {
  final String? libraryDisplayStyle;
  final Map<String, SourcePreference> sourcePreferences;

  UserPreferences({
    this.libraryDisplayStyle,
    this.sourcePreferences = const {},
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> sourcePrefsJson = json['source_preferences'] ?? {};
    final Map<String, SourcePreference> sourcePrefs = {};
    
    sourcePrefsJson.forEach((key, value) {
      sourcePrefs[key] = SourcePreference.fromJson(value);
    });

    return UserPreferences(
      libraryDisplayStyle: json['library_display_style'],
      sourcePreferences: sourcePrefs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'library_display_style': libraryDisplayStyle,
      'source_preferences': sourcePreferences.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  UserPreferences copyWith({
    String? libraryDisplayStyle,
    Map<String, SourcePreference>? sourcePreferences,
  }) {
    return UserPreferences(
      libraryDisplayStyle: libraryDisplayStyle ?? this.libraryDisplayStyle,
      sourcePreferences: sourcePreferences ?? this.sourcePreferences,
    );
  }
}
