import 'package:localstorage/localstorage.dart';

// class MainHelper {
Future<String?> getToken() async {
  final LocalStorage storage = new LocalStorage('my_data.json');
  await storage.ready;
  return await storage.getItem('token');
}
// }
