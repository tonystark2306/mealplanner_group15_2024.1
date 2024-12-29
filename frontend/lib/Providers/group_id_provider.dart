import 'package:shared_preferences/shared_preferences.dart';

class GroupIdProvider {
  // Hàm lưu selectedGroupId
  static Future<void> saveSelectedGroupId(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedGroupId', groupId);
  }

  // Hàm lấy selectedGroupId
  static Future<String?> getSelectedGroupId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedGroupId');
  }
}
