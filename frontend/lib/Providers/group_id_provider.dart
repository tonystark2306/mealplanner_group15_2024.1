import 'package:shared_preferences/shared_preferences.dart';

class GroupIdProvider {
  // Hàm lưu selectedGroupId và selectedGroupName
  static Future<void> saveSelectedGroup(String groupId, String groupName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedGroupId', groupId);
    await prefs.setString('selectedGroupName', groupName);
  }

  // Hàm lấy selectedGroupId
  static Future<String?> getSelectedGroupId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedGroupId');
  }

  // Hàm lấy selectedGroupName
  static Future<String?> getSelectedGroupName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedGroupName');
  }
}
