import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê báo cáo'),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle('Thống kê nhanh'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatisticCard('Tổng mua', '30 món', Icons.shopping_cart, Colors.blue),
                _buildStatisticCard('Tiêu thụ', '25 món', Icons.fastfood, Colors.green),
                _buildStatisticCard('Lãng phí', '5 món', Icons.delete, Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            _buildTitle('Biểu đồ thống kê'),
            const SizedBox(height: 10),
            _buildPlaceholderChart(),
            const SizedBox(height: 20),
            _buildTitle('Chi tiết báo cáo'),
            const SizedBox(height: 10),
            _buildReportDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatisticCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  // Replacing the pie chart with a simple placeholder (you can add any custom widget here)
  Widget _buildPlaceholderChart() {
    return Container(
      height: 200,
      color: Colors.grey[200], // Placeholder color
      child: const Center(
        child: Text(
          'Biểu đồ thống kê ở đây', // Placeholder text
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildReportDetails() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Ngày bắt đầu:', '01/12/2024'),
            const Divider(),
            _buildDetailRow('Ngày kết thúc:', '08/12/2024'),
            const Divider(),
            _buildDetailRow('Món mua nhiều nhất:', 'Cá hồi (10 lần)'),
            const Divider(),
            _buildDetailRow('Món ít tiêu thụ nhất:', 'Sữa chua (2 lần)'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
