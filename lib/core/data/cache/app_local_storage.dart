import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

mixin AppLocalStoreMixin {
  R? read<R>(String key, {R? defaultValue});
  void write<W>({required String key, required W value});
  void delete(String key);
  void deleteAll();
}

class AppLocalStorage with AppLocalStoreMixin {
  AppLocalStorage._();
  static final _boxKey = 'app_preferences';
  static final _instance = AppLocalStorage._();

  factory AppLocalStorage.instance() => _instance;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);
    // Hive.registerAdapters(); // Will be implemented when needed
    await Hive.openBox(_boxKey);
  }

  @override
  R? read<R>(String key, {R? defaultValue}) {
    try {
      return Hive.box(_boxKey).get(key, defaultValue: defaultValue) as R;
    } catch (e) {
      if (defaultValue != null) return defaultValue as R;
      return null;
    }
  }

  @override
  void write<W>({required String key, required W value}) {
    Hive.box(_boxKey).put(key, value);
  }

  @override
  void delete(String key) {
    Hive.box(_boxKey).delete(key);
  }

  @override
  void deleteAll() {
    Hive.box(_boxKey).deleteFromDisk();
  }
}
