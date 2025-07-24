import 'package:derpibooru_score_observer/image.dart';
import 'package:dio/dio.dart';

class ImageRepository {
  final String? apiKey;

  ImageRepository({this.apiKey});

  final _dio = Dio();

  /// Возвращает список изображений из Derpibooru на первой странице ([perPage] указывает количество изображений на одной странице). Если [filterByCurrentDate] = true, то возвращаются только изображений, которым меньше 1 дня ([image.createdAt] < dayAgo)
  Future<List<Image>> getImages({
    int perPage = 24,
    bool filterByCurrentDate = true,
  }) async {
    try {
      final res = await _dio.get(
        'https://derpibooru.org/api/v1/json/search/images',
        queryParameters: {
          'q': 'artist:jjsh',
          'per_page': perPage,
          'key': apiKey,
        },
      );
      if (res.data == null) {
        print('Data is null');
        return [];
      }

      final images = (res.data['images'] as List)
          .map(
            (imageRaw) => Image(
              id: imageRaw['id'] as int,
              score: imageRaw['score'] as int,
              faves: imageRaw['faves'] as int,
              upvotes: imageRaw['upvotes'] as int,
              downvotes: imageRaw['downvotes'] as int,
              wilsonScore: double.parse(imageRaw['wilson_score'].toString()),
              createdAt: DateTime.parse(imageRaw['created_at']),
            ),
          )
          .toList();

      if (filterByCurrentDate) {
        var dayAgo = DateTime.now().subtract(Duration(days: 1));
        images.removeWhere((image) => image.createdAt.isBefore(dayAgo));
      }

      return images;
    } catch (e) {
      print(
        'Ошибка получения данных с сервера: '
        '$e',
      );
      // rethrow;
      return [];
    }
  }
}
