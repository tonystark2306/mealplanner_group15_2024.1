import 'package:flutter/material.dart';
import '../../Models/fridge/fridge_item_model.dart';

class FridgeItemDetailScreen extends StatelessWidget {
  final FridgeItem fridgeItem;

  const FridgeItemDetailScreen({super.key, required this.fridgeItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Chi tiết thực phẩm',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: fridgeItem.image.isNotEmpty
                      ? Image.network(
                          fridgeItem.image,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 100,
                        ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Tên thực phẩm', fridgeItem.name),
                _buildDetailRow(
                  'Ngày hết hạn',
                  fridgeItem.expirationDate.toLocal().toString().split(' ')[0],
                ),
                _buildDetailRow(
                  'Số lượng',
                  '${fridgeItem.quantity} ${fridgeItem.unit}',
                ),
                _buildDetailRow('Loại', fridgeItem.type.isNotEmpty ? fridgeItem.type : 'Không xác định'),
                _buildDetailRow(
                  'Danh mục',
                  fridgeItem.category.isNotEmpty
                      ? fridgeItem.category.join(', ')
                      : 'Không có danh mục',
                ),
                _buildDetailRow(
                  'Ghi chú',
                  fridgeItem.notes.isNotEmpty ? fridgeItem.notes : 'Không có ghi chú',
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Hàm hỗ trợ hiển thị từng dòng thông tin
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
