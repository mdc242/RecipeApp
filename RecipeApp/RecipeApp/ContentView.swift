//
//  ContentView.swift
//  RecipeApp
//
//  Created by Chase, Meadow D on 4/10/24.
//

import SwiftUI

struct Recipe: Identifiable {
    let id = UUID()
    let title: String
    let ingredients: [String]
    let instructions: [String]
}

struct ShoppingList {
    var ingredients: [String]
    
    mutating func addIngredient(_ ingredient: String) {
        ingredients.append(ingredient)
    }
    
    mutating func removeIngredient(at index: Int) {
        ingredients.remove(at: index)
    }
}

struct ContentView: View {
    @State private var recipes = [
        Recipe(title: "Pasta Carbonara", ingredients: ["1 lb. Spaghetti", "4 oz. Bacon", "2 Eggs", "2 oz. Parmesan cheese", "Black pepper"], instructions: ["Cook spaghetti al dente in large pot", "Fry bacon until crispy", "Mix eggs and parmesan cheese", "Combine spaghetti, bacon, and egg mixture in pot", "Season with black pepper and enjoy!"]),
        Recipe(title: "Chocolate Chip Cookies", ingredients: ["1 c. Butter", "1 c. Brown sugar", "1 c. White sugar", "2 Eggs", "2 tsp. Vanilla extract", "3 c. Flour", "1 tsp. Baking soda", "1 tsp. Salt", "2 c. Chocolate chips"], instructions: ["Cream together butter and sugars", "Add eggs and vanilla extract", "Mix in flour, baking soda, and salt", "Fold in chocolate chips", "Scoop onto baking sheet", "Bake at 350°F for 10-12 minutes and enjoy!"])
    ]
    
    @State private var isAddingRecipe = false
    @State private var title = ""
    @State private var ingredients = ""
    @State private var instructions = ""
    @State private var shoppingList = ShoppingList(ingredients: [])
    @State private var selectedTabIndex = 0
    
    var body: some View {
        
        TabView(selection: $selectedTabIndex) {
            NavigationView {
                VStack {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible())]) {
                            ForEach(recipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    RecipeCard(recipe: recipe)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Button(action: {
                        self.isAddingRecipe = true
                    }) {
                        Text("Add Your Own Recipe")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                            .padding()
                    }
                }
                
                .frame(maxWidth: .infinity, maxHeight: .infinity) // extends VStack across the frame
                .background(Color.white) // change color of VStack

                
                .navigationTitle("My Recipes")
                .sheet(isPresented: $isAddingRecipe) {
                    AddRecipeView(isPresented: self.$isAddingRecipe, recipes: self.$recipes, shoppingList: self.$shoppingList)
                }
            }
            .tag(0)
            
            NavigationView {
                VStack {
                    List {
                        ForEach(shoppingList.ingredients, id: \.self) { ingredient in
                            Text(ingredient)
                             
                        }
                        .onDelete(perform: deleteIngredient)
                    }
                    .listStyle(PlainListStyle())
                    
                    Button(action: {
                        // Save shopping list to wherever you want
                    }) {
                        Text("Save Shopping List")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding()
                    }
                }
                .navigationTitle("Shopping List")
            }
            .tag(1)
        }
    }
    
    private func deleteIngredient(at offsets: IndexSet) {
        shoppingList.ingredients.remove(atOffsets: offsets)
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.title)
                .font(.headline)
                .padding(.bottom, 4)
            
            Text("Ingredients: \(recipe.ingredients.joined(separator: ", "))")
                .frame(maxWidth: .infinity, alignment: .leading) // left align
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
      
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
       
      
    }
}

struct RecipeDetailView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(recipe.title)
                .font(.title)
                .padding(.bottom, 8)
            
            Text("Ingredients:")
                
                .font(.headline)
                .padding(.bottom, 4)
            ForEach(recipe.ingredients, id: \.self) { ingredient in
                Text("- \(ingredient)")
                    .padding(.bottom, 2)
                   
            }
            
            Divider()
            
            Text("Instructions:")
                .font(.headline)
                .padding(.top, 8)
                .padding(.bottom, 4)
            ForEach(recipe.instructions.indices, id: \.self) { index in
                Text("\(index + 1). \(recipe.instructions[index])")
                    .padding(.bottom, 2)
            }
        }
        .padding()
        .navigationTitle("Recipe") // Change the title to 'Recipe'
    }
}


struct AddRecipeView: View {
    @Binding var isPresented: Bool
    @Binding var recipes: [Recipe]
    @Binding var shoppingList: ShoppingList
    @State private var title = ""
    @State private var ingredients = ""
    @State private var instructions = ""
    
    var body: some View {
        VStack {
            Text("Add Recipe")
                .font(.title)
                .padding()
            
            TextField("Recipe Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Text("Ingredients:")
                .font(.headline)
                .padding(.bottom, 4)
            TextEditor(text: $ingredients)
                .frame(minHeight: 100)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding()
            
            Text("Instructions:")
                .font(.headline)
                .padding(.bottom, 4)
            TextEditor(text: $instructions)
                .frame(minHeight: 100)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding()
            
            Button(action: {
                saveRecipe()
            }) {
                Text("Save")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
    
    private func saveRecipe() {
        guard !title.isEmpty && !ingredients.isEmpty && !instructions.isEmpty else {
            return
        }
        
        let ingredientList = ingredients.components(separatedBy: "\n")
        let instructionList = instructions.components(separatedBy: "\n")
        
        let newRecipe = Recipe(title: title, ingredients: ingredientList, instructions: instructionList)
        
        recipes.append(newRecipe)
        
        isPresented = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}






