import 'package:get_storage/get_storage.dart';

class LocalStoreService {
  final GetStorage _storage = GetStorage();

  /// Read data from storage
  Future<T?> read<T>(String key) async {
    return _storage.read<T>(key);
  }

  /// Write data to storage
  Future<void> write<T>(String key, T value) async {
    await _storage.write(key, value);
  }

  /// Delete data from storage
  Future<void> delete(String key) async {
    await _storage.remove(key);
  }

  /// Clear all data from storage
  Future<void> clear() async {
    await _storage.erase();
  }
}
