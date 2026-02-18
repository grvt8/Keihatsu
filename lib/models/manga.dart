import 'dart:convert';

class Manga {
  final String id;
  final String url;
  final String title;
  final String thumbnailUrl;
  final String? description;
  final String? author;
  final String? artist;
  final String? status;
  final List<String>? genres;
  final String sourceId;

  Manga({
    required this.id,
    required this.url,
    required this.title,
    required this.thumbnailUrl,
    this.description,
    this.author,
    this.artist,
    this.status,
    this.genres,
    required this.sourceId,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    return Manga(
      id: json['id'],
      url: json['url'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      description: json['description'],
      author: json['author'],
      artist: json['artist'],
      status: json['status'],
      genres: json['genres'] != null ? List<String>.from(json['genres']) : null,
      sourceId: json['sourceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'author': author,
      'artist': artist,
      'status': status,
      'genres': genres,
      'sourceId': sourceId,
    };
  }
}

class MangasPage {
  final List<Manga> mangas;
  final bool hasNextPage;

  MangasPage({required this.mangas, required this.hasNextPage});

  factory MangasPage.fromJson(Map<String, dynamic> json) {
    return MangasPage(
      mangas: (json['mangas'] as List).map((m) => Manga.fromJson(m)).toList(),
      hasNextPage: json['hasNextPage'],
    );
  }
}
