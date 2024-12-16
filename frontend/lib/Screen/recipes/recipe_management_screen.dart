import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/recipe_model.dart';
import '../../Providers/recipe_provider.dart';
import 'recipe_detail_popup.dart'; // Import Popup
import 'edit_recipe_screen.dart'; // Nhớ import màn hình Edit

class RecipeManagementScreen extends StatefulWidget {
  const RecipeManagementScreen({super.key});

  @override
  State<RecipeManagementScreen> createState() => _RecipeManagementScreenState();
}

class _RecipeManagementScreenState extends State<RecipeManagementScreen> {
  TextEditingController searchController = TextEditingController();
  bool showMyRecipes = true;

  void toggleView() {
    setState(() {
      showMyRecipes = !showMyRecipes;
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          labelText: 'Tìm kiếm công thức',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: const Icon(Icons.search),
        ),
        onChanged: (text) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              showMyRecipes =
                  true; // Đánh dấu nút 'Công thức của tôi' là active
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: showMyRecipes
                ? Colors.green[700]
                : Colors.grey[400], // Nếu showMyRecipes là true, nút sẽ active
            foregroundColor: showMyRecipes
                ? Colors.white
                : Colors.black, // Màu chữ sáng khi active, tối khi không active
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: const Text('Công thức của tôi'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              showMyRecipes = false; // Đánh dấu nút 'Gợi ý công thức' là active
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: !showMyRecipes
                ? Colors.green[700]
                : Colors.grey[400], // Nếu showMyRecipes là false, nút sẽ active
            foregroundColor: !showMyRecipes
                ? Colors.white
                : Colors.black, // Màu chữ sáng khi active, tối khi không active
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: const Text('Gợi ý công thức'),
        ),
      ],
    );
  }

  Widget _buildRecipeGrid(List<RecipeItem> recipes) {
    if (recipes.isEmpty) {
      return const Center(
        child: Text('Không có công thức nào'),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Hiển thị 2 công thức mỗi dòng
        crossAxisSpacing: 8.0, // Khoảng cách giữa các cột
        mainAxisSpacing: 8.0, // Khoảng cách giữa các hàng
        childAspectRatio:
            1, // Điều chỉnh tỉ lệ của mỗi ô (giảm tỉ lệ để mỗi item nhỏ hơn)
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          // ignore: deprecated_member_use
          shadowColor: Colors.black.withOpacity(0.2),
          child: GestureDetector(
            onTap: () {
              // Hiển thị thông tin công thức khi click
              showDialog(
                context: context,
                builder: (context) => RecipeDetailPopup(recipe: recipe),
              );
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: recipe.imagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                recipe.imagePath!,
                                width: double.infinity,
                                height: 100, // Giảm chiều cao hình ảnh
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.image,
                              size: 60, color: Colors.grey),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        recipe.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14), // Kích thước font tên nhỏ hơn
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditRecipeScreen(recipe: recipe),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          final recipeProvider = Provider.of<RecipeProvider>(
                              context,
                              listen: false);
                          recipeProvider.deleteRecipe(recipe.id);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý công thức',
          style:
              TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green[700]),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildToggleButtons(),
          // Sử dụng Consumer để lắng nghe thay đổi từ RecipeProvider
          Consumer<RecipeProvider>(
            builder: (context, recipeProvider, child) {
              final filteredRecipes = recipeProvider.recipes
                  .where((recipe) => recipe.name
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase()))
                  .toList();
              return Expanded(
                child: _buildRecipeGrid(filteredRecipes),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () {
          Navigator.pushNamed(context, '/create-recipe');
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
