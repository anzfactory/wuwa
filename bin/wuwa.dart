import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'models/character.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addOption(
      'build',
      abbr: 'b',
      help: 'Build Project for dictionary or github pages (ex. dic | pages)'
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart wuwa.dart <flags> [arguments]');
  print(argParser.usage);
}

class Assets {
  static File get charactersFile => File('assets/characters.txt');
}

class Output {
  static File get googleDic => File('build/dictionary.txt');
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    
    if (results.wasParsed('build')) {
      final type = results['build'];
      switch (type) {
        case 'dic':
          _buildGoogleDictionary();
          break;
        case 'pages':
          _buildPages();
          break;
        default:
          throw Exception('unknown build type $type');
      }
    }
    print('finish');
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}

void _buildGoogleDictionary() async {
  final assetFile = Assets.charactersFile;
  final list = await assetFile.readAsLines();
  final outputFile = Output.googleDic;
  await outputFile.create(recursive: true);
  final sink = outputFile.openWrite();
  sink.write(list.map((line){
    return Character.fromString(line).toTextForGoogleDic();
  }).join('\n'));
  sink.writeln(); // Google日本語入力は最後に空行いれないと最後の単語をインポートしてくれない
  await sink.flush();
  await sink.close();
}

void _buildPages() async {
  final assetFile = Assets.charactersFile;
  final list = await assetFile.readAsLines();
  final outputFile = File('docs/output.json');
  outputFile.createSync(recursive: true);
  final sink = outputFile.openWrite();
  final List<Character> fooList = [];
  for (final line in list) {
    fooList.add(Character.fromString(line));
  }
  sink.write(jsonEncode(fooList));
  await sink.flush();
  await sink.close();
}