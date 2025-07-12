/// Объект изображения Derpibooru
class Image {
  /// ID изображения
  final int id;

  /// Количество лайков минус количество дизлайков
  final int score;

  /// Количество избранных
  final int faves;

  /// Количество лайков
  final int upvotes;

  /// Количество дизлайков
  final int downvotes;

  /// Нижняя граница доверительного интервала Вильсона
  final double wilsonScore;

  /// Дата создания изображения
  final DateTime createdAt;

  Image({
    required this.id,
    required this.score,
    required this.faves,
    required this.upvotes,
    required this.downvotes,
    required this.wilsonScore,
    required this.createdAt,
  });

  /// Возвращает [String] с информацией о количестве избранных, лайках и дизлайках изображения
  String generateLine() {
    final line = StringBuffer();
    line.write('$id: ');
    line.write('$score ${' ' * (4 - score.toString().length)}');
    line.write('(★ $faves ${' ' * (3 - faves.toString().length)}');
    line.write(' | ↑ $upvotes ${' ' * (3 - upvotes.toString().length)}');
    line.write(' | ↓ $downvotes ${' ' * (3 - downvotes.toString().length)})');
    return line.toString();
  }
}
