import 'package:flutter/material.dart';

class RecipeManagementScreen extends StatefulWidget {
  const RecipeManagementScreen({Key? key}) : super(key: key);

  @override
  _RecipeManagementScreenState createState() => _RecipeManagementScreenState();
}

class _RecipeManagementScreenState extends State<RecipeManagementScreen> {
  bool isMyRecipes = true; // Mặc định là "Công thức của tôi"
  List<Map<String, String>> recipes = []; // Danh sách công thức
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    recipes = _getMyRecipes(); // Mặc định hiển thị "Công thức của tôi"
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = recipes
        .where((recipe) => recipe['name']!
            .toLowerCase()
            .contains(searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý công thức',
          style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green[700]),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm công thức...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),
          // Nút chuyển đổi "Công thức của tôi" và "Gợi ý công thức"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMyRecipes ? Colors.green[700] : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      isMyRecipes = true;
                      recipes = _getMyRecipes();
                    });
                  },
                  child: const Text('Công thức của tôi'),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !isMyRecipes ? Colors.green[700] : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      isMyRecipes = false;
                      recipes = _getSuggestedRecipes();
                    });
                  },
                  child: const Text('Gợi ý công thức'),
                ),
              ],
            ),
          ),
          // Danh sách công thức hoặc thông điệp "Danh sách trống"
          Expanded(
            child: filteredRecipes.isEmpty
                ? Center(
                    child: Text(
                      'Danh sách trống. Nhấn + để thêm công thức.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showRecipeDetails(context, recipe);
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                        image: DecorationImage(
                                          image: AssetImage(recipe['image'] ?? 'assets/recipe_placeholder.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      recipe['name']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/edit-recipe',
                                      arguments: recipe,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      recipes.remove(recipe);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () {
          Navigator.pushNamed(context, '/create-recipe');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Hàm giả lập dữ liệu "Công thức của tôi"
  List<Map<String, String>> _getMyRecipes() {
    return [
      {'name': 'Bánh mì trứng', 'image': 'assets/recipe1.png'},
      {'name': 'Cơm chiên', 'image': 'assets/recipe2.png'},
    ];
  }

  // Hàm giả lập dữ liệu "Gợi ý công thức"
  List<Map<String, String>> _getSuggestedRecipes() {
    return [
      {'name': 'Salad rau củ', 'image': 'assets/recipe3.png'},
      {'name': 'Canh chua cá', 'image': 'assets/recipe4.png'},
    ];
  }

  // Hiển thị thông tin chi tiết công thức
  void _showRecipeDetails(BuildContext context, Map<String, String> recipe) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(recipe['name']!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(recipe['image'] ?? 'assets/recipe_placeholder.png'),
              const SizedBox(height: 10),
              const Text(
                'Thông tin chi tiết về công thức sẽ hiển thị ở đây.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}
