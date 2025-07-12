import 'package:derpibooru_score_observer/derpibooru_score_observer.dart';
import 'package:derpibooru_score_observer/image_repository.dart';
import 'package:dotenv/dotenv.dart';

Future<void> main(List<String> args) async {
  final env = DotEnv()..load(['../.env']);
  env.isEveryDefined([
    'type',
    'project_id',
    'private_key_id',
    'private_key',
    'client_email',
    'client_id',
    'auth_uri',
    'token_uri',
    'auth_provider_x509_cert_url',
    'client_x509_cert_url',
    'universe_domain',
    'table_id',
  ]);

  final observer = DerpibooruScoreObserver(
    imageRepository: ImageRepository(),
    interval: 60 * 5,
    oneColumn: true,
    credentials: {
      'type': env['type']!,
      'project_id': env['project_id']!,
      'private_key_id': env['private_key_id']!,
      'private_key': env['private_key']!.replaceAll(r'\n', '\n'),
      'client_email': env['client_email']!,
      'client_id': env['client_id']!,
      'auth_uri': env['auth_uri']!,
      'token_uri': env['token_uri']!,
      'auth_provider_x509_cert_url': env['auth_provider_x509_cert_url']!,
      'client_x509_cert_url': env['client_x509_cert_url']!,
      'universe_domain': env['universe_domain']!,
    },
    tableId: env['table_id']!,
  );
  observer.start();
}
