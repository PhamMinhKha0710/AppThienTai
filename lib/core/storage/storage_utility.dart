import 'package:get_storage/get_storage.dart';

/// Lớp MinhLocalStorage là wrapper của GetStorage,
/// giúp quản lý dữ liệu local theo mô hình Singleton
class MinhLocalStorage {

  /// Biến static giữ instance duy nhất của class (Singleton)
  static MinhLocalStorage? _instance ;

  /// Biến nội bộ để thao tác với GetStorage
  late final _storage;

  /// Factory constructor đảm bảo chỉ có 1 instance tồn tại
  factory MinhLocalStorage.instance() {
    _instance ??= MinhLocalStorage._internal(); // nếu chưa có thì tạo mới
    return _instance!;
  }

  /// Constructor private (chỉ dùng nội bộ)
  MinhLocalStorage._internal();

  /// Hàm khởi tạo bất đồng bộ, bắt buộc gọi trước khi dùng
  /// [bucketName] là tên "hộp" (bucket) lưu dữ liệu
  static Future<void> init(String bucketName) async {
    // Bắt buộc init bucket trước khi dùng
    await GetStorage.init(bucketName);
    _instance = MinhLocalStorage._internal();

    // Tạo storage cho bucket vừa khởi tạo
    _instance!._storage = GetStorage(bucketName);
  }

  /// Lưu dữ liệu (tương tự writeData, chỉ khác tên hàm)
  Future<void> saveData<T>(String key, T value) async {
    await _storage.write(key, value);
  }

  /// Ghi dữ liệu với key-value
  Future<void> writeData<T>(String key, T value) async {
    await _storage.write(key, value);
  }

  /// Đọc dữ liệu từ key (trả về null nếu không có)
  T? readData<T>(String key) {
    return _storage.read<T>(key);
  }

  /// Xoá 1 item theo key
  Future<void> removeData(String key) async {
    await _storage.remove(key);
  }

  /// Xoá toàn bộ dữ liệu trong storage
  Future<void> clearAll() async {
    await _storage.erase();
  }
}











