import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/recipe_model.dart';
import '../../Providers/recipe_provider.dart';
import 'recipe_detail_popup.dart';
import 'edit_recipe_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecipeManagementScreen extends StatefulWidget {
  const RecipeManagementScreen({super.key});

  @override
  State<RecipeManagementScreen> createState() => _RecipeManagementScreenState();
}

class _RecipeManagementScreenState extends State<RecipeManagementScreen> {
  TextEditingController searchController = TextEditingController();
  bool showMyRecipes = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecipes();
    });
  }

  Future<void> _loadRecipes() async {
    setState(() => isLoading = true);
    await context.read<RecipeProvider>().getRecipes();
    setState(() => isLoading = false);
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
              showMyRecipes = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                showMyRecipes ? Colors.green[700] : Colors.grey[400],
            foregroundColor: showMyRecipes ? Colors.white : Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: const Text('Công thức của tôi'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              showMyRecipes = false;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                !showMyRecipes ? Colors.green[700] : Colors.grey[400],
            foregroundColor: !showMyRecipes ? Colors.white : Colors.black,
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
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.2),
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => RecipeDetailPopup(recipeItem: recipe),
              );
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    // Ảnh
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10)),
                        child: CachedNetworkImage(
                          imageUrl: recipe.imageLink ?? '',
                          fit: BoxFit.cover, // Đảm bảo ảnh khớp với khung
                          width: double.infinity,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                    // Tên công thức
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        recipe.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Nút edit/delete chỉ cho "Công thức của tôi"
                if (showMyRecipes)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditRecipeScreen(recipe: recipe),
                              ),
                            );
                            // Không gọi _loadRecipes() ở đây để tránh duplicate.
                            // Provider đã tự gọi getRecipes() khi updateRecipe thành công.
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
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        automaticallyImplyLeading: false,
        actions: [
          // Chỉ cho thêm recipe khi đang ở tab "Công thức của tôi"
          if (showMyRecipes)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              iconSize: 30,
              onPressed: () async {
                // Điều hướng sang màn hình tạo recipe
                await Navigator.pushNamed(context, '/create-recipe');
                // Không gọi _loadRecipes() ở đây để tránh trùng lặp.
                // Provider.addRecipe() sẽ gọi getRecipes() sau khi thêm thành công.
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildToggleButtons(),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Consumer<RecipeProvider>(
                    builder: (context, recipeProvider, child) {
                      final recipes = showMyRecipes
                          ? recipeProvider.recipes
                          : recipeProvider.suggestedRecipes;
                      final filteredRecipes = recipes.where((recipe) {
                        return recipe.name
                            .toLowerCase()
                            .contains(searchController.text.toLowerCase());
                      }).toList();
                      return _buildRecipeGrid(filteredRecipes);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
