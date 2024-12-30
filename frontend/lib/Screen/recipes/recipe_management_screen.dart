import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/recipe_model.dart';
import '../../Providers/recipe_provider.dart';
import 'recipe_detail_popup.dart'; // Import Popup
import 'edit_recipe_screen.dart'; // Import the Edit screen

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().getRecipes();
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
                    Expanded(
                      child: recipe.imageLink != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                recipe.imageLink!,
                                width: double.infinity,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.image,
                                  size: 60,
                                  color: Colors.grey,
                                ),
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
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (showMyRecipes) // Chỉ hiển thị nút Edit/Delete khi ở "Công thức của tôi"
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
                              listen: false,
                            );
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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green[700],
        centerTitle: true,
        title: const Text(
          'Quản lý công thức',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Tăng kích thước icon add
          if (showMyRecipes)
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/create-recipe');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(), // Thanh tìm kiếm
          _buildToggleButtons(), // Nút toggle Công thức của tôi vs Gợi ý
          const SizedBox(height: 20),
          Consumer<RecipeProvider>(
            builder: (context, recipeProvider, child) {
              final recipes = showMyRecipes
                  ? recipeProvider.recipes
                  : recipeProvider.suggestedRecipes;
              final filteredRecipes = recipes.where((recipe) {
                return recipe.name
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase());
              }).toList();

              return Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1,
                  ),
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];
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
                            builder: (context) =>
                                RecipeDetailPopup(recipeItem: recipe),
                          );
                        },
                        child: Stack(
                          children: [
                            // Ảnh và tên recipe
                            Column(
                              children: [
                                Expanded(
                                  child: recipe.imageLink != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            recipe.imageLink!,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                              Icons.image,
                                              size: 60,
                                              color: Colors.grey,
                                            ),
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
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            // Icon edit/delete
                            if (showMyRecipes)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white70, // Màu nền mờ
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditRecipeScreen(
                                                      recipe: recipe),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          final recipeProvider =
                                              Provider.of<RecipeProvider>(
                                            context,
                                            listen: false,
                                          );
                                          recipeProvider
                                              .deleteRecipe(recipe.id);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      // Bỏ hoặc ẩn FloatingActionButton
    );
  }
}
