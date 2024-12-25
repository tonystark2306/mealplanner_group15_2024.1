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
    // Fetch recipes from the provider (server call)
    Provider.of<RecipeProvider>(context, listen: false).getRecipes();
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
                      child: recipe.image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                recipe.image!,
                                width: double.infinity,
                                height: 100,
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
                            fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (showMyRecipes) // Only show edit and delete buttons when "My Recipes"
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
          // Adding some space between sections
          SizedBox(height: 20),
          Consumer<RecipeProvider>(
            builder: (context, recipeProvider, child) {
              // Filter recipes based on showMyRecipes state
              final recipes = showMyRecipes
                  ? recipeProvider.recipes
                  : recipeProvider.suggestedRecipes;

              // Filter by search query
              final filteredRecipes = recipes.where((recipe) {
                return recipe.name
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase());
              }).toList();

              return Expanded(
                child: _buildRecipeGrid(filteredRecipes),
              );
            },
          ),
        ],
      ),
      floatingActionButton: showMyRecipes // Show FAB only for "My Recipes"
          ? FloatingActionButton(
              backgroundColor: Colors.green[700],
              onPressed: () {
                Navigator.pushNamed(context, '/create-recipe');
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : null, // No FAB for "Suggested Recipes"
    );
  }
}
