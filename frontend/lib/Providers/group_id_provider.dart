import 'package:shared_preferences/shared_preferences.dart';

class GroupIdProvider {
  // Lưu danh sách tất cả các groupId
  static Future<void> saveGroupIds(List<String> groupIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('groupIds', groupIds);
  }

  // Lấy danh sách tất cả các groupId
  static Future<List<String>> getGroupIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('groupIds') ?? [];
  }

  // Lưu groupId được chọn
  static Future<void> saveSelectedGroupId(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedGroupId', groupId);
  }

  // Lấy groupId được chọn
  static Future<String?> getSelectedGroupId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedGroupId');
  }

  // Xóa groupId được chọn
  static Future<void> clearSelectedGroupId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedGroupId');
  }
}
