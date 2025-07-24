import 'dart:io';

import 'package:derpibooru_score_observer/image.dart';
import 'package:derpibooru_score_observer/image_repository.dart';
import 'package:gsheets/gsheets.dart';

class DerpibooruScoreObserver {
  DerpibooruScoreObserver({
    required ImageRepository imageRepository,
    this.interval = 10,
    required this.credentials,
    required this.tableId,
    this.oneColumn = false,
  }) : _imageRepository = imageRepository;

  /// Репозиторий изображений из Derpibooru
  final ImageRepository _imageRepository;

  /// Интервал между запросами (в секундах)
  final int interval;

  /// Данные для подключения к Google Sheets API
  final dynamic credentials;

  /// ID таблицы в Google Sheets
  final String tableId;

  /// Отображать ли все изображения в одной колонке
  final bool oneColumn;

  /// Запуск цикла обновления изображений в таблице
  Future<void> start() async {
    while (true) {
      await updateTable();
      await _wait();
    }
  }

  /// Отображение списка изображений в консоли без обновления в таблице
  Future<void> showImages() async {
    // Получение списка изображений
    final images = await _imageRepository.getImages();

    // Отображение списка изображений в консоли
    _printImages(images);
  }

  /// Обновление изображений в таблице + отображение в консоли
  Future<void> updateTable() async {
    // Получение списка изображений
    final images = await _imageRepository.getImages();

    // Отображение списка изображений в консоли
    _printImages(images);

    // Подключение к Гугл таблице
    final gsheets = GSheets(credentials);
    final spreadsheet = await gsheets.spreadsheet(tableId);
    final table = spreadsheet.worksheetByIndex(0)!;

    // Получение ссылок из колонки ссылок
    List<String> links = await table.values.column(9);

    // Проход по списку изображений
    for (var image in images) {
      // Поиск строки с изображением
      int rowId = links.indexWhere((link) => link.contains('${image.id}')) + 1;

      // Если строка с ссылкой не найдена
      if (rowId == 0) {
        print('Не найдена строка с ссылкой на изображение ${image.id}');
        return;
      }

      try {
        // Обновление информации
        table.values.insertRow(rowId, [
          image.faves,
          image.upvotes,
          image.downvotes,
        ], fromColumn: 5);
      } catch (e) {
        print(
          'Не удалось обновить значения в таблице в строке $rowId (imageId = ${image.id})\n$e',
        );
      }
    }
  }

  /// Запуск цикла ожидания следующего запроса
  Future<void> _wait() async {
    print('\n');
    for (var i = 0; i < interval; i++) {
      await Future.delayed(Duration(seconds: 1));
      stdout.write('\rОбновление через: $i/$interval');
    }
  }

  /// Выполнение команд для очистки консоли
  void _clearConsole() {
    // print(Process.runSync("cls", [], runInShell: true).stdout);
    // print(Process.runSync("clear", [], runInShell: true).stdout);
    print("\x1B[2J\x1B[0;0H");
  }

  /// Отображение списка изображений в консоли
  void _printImages(List<Image> images) {
    // Разделитель между изображениями в одной строке
    const divider = '   ║   ';

    // Получение количества колонок терминала (длины)
    late final int columns;
    try {
      columns = stdout.terminalColumns;
    } catch (_) {
      columns = 0;
    }

    _clearConsole();

    String line = ''; // Строка информации об изображении
    int imagesInLine = 1; // Кол-во изображений, которое будет в одной строке
    for (var image in images) {
      line += image.generateLine(); // Создание строки с информацией

      // Если можно уместить в строку ещё одно изображение
      if (!oneColumn &&
          (line.length + (line.length / imagesInLine) + divider.length <
              columns)) {
        line += divider;
        imagesInLine++;
      } else {
        print(line);
        line = '';
        imagesInLine = 1;
      }
    }
    if (line != '') print(line);

    print(
      '\n\n'
      'Обновлено: ${DateTime.now().toString().split('.')[0]}',
    );
  }
}
