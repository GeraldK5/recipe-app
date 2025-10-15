# Recipe App

A Flutter-based recipe application that allows users to browse meal categories, search for recipes, view detailed meal information, and manage their favorite meals.

# Link to apk below

https://drive.google.com/file/d/1c3eirOGt6QwkhP9BEQhVbSMhBfcbt7__/view?usp=sharing

## Features

- 🍽️ Browse meals by categories
- 🔍 Search functionality with debouncing
- 📋 Detailed meal information with ingredients and instructions
- ❤️ Favorite meals management with local storage
- 📱 Responsive UI with smooth animations
- 🌐 Real-time data from TheMealDB API

## Screenshots

*Add screenshots of your app here*

## Setup Instructions

### Prerequisites

- Flutter SDK ^3.9.0
- Dart SDK (comes with Flutter)
- Android Studio / VS Code with Flutter extensions
- Android device/emulator or iOS device/simulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repository-url>
   cd recipe_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Dependencies

The app uses the following main dependencies:

- `get: ^4.7.2` - State management and navigation
- `http: ^1.5.0` - HTTP requests for API calls
- `shared_preferences: ^2.5.3` - Local storage for favorites
- `cupertino_icons: ^1.0.8` - iOS-style icons

## Architecture Decisions

### 1. Architecture Pattern: MVC (Model-View-Controller)

**Rationale**: Chosen MVC architecture for its simplicity and clear separation of concerns:
- **Models**: Data structures for API responses (`category_model.dart`, `meal_model.dart`, `meal_detail_model.dart`)
- **Views**: UI screens and widgets (`overview.dart`, `searchpage.dart`, `meal_detail_bottom_sheet.dart`)
- **Controllers**: Business logic and state management (`category_controller.dart`, `meal_controller.dart`, `favorites_controller.dart`)

### 2. State Management: GetX

**Rationale**: Selected GetX for state management because:
- Lightweight and performant for small to medium applications
- Simple reactive programming with `.obs` observables
- Built-in dependency injection with `Get.put()`
- Minimal boilerplate code
- Excellent for rapid development

**Alternative considered**: Provider or Bloc were considered but deemed overkill for this app's complexity.

### 3. Local Storage: SharedPreferences

**Rationale**: Used SharedPreferences for storing favorite meals because:
- Simple key-value storage perfect for user preferences
- Built-in Flutter support
- Persistent across app restarts
- JSON encoding/decoding for storing meal ID lists

### 4. Folder Structure

```
lib/
├── controllers/          # GetX controllers for state management
│   ├── category_controller.dart
│   ├── meal_controller.dart
│   ├── meal_detail_controller.dart
│   └── favorites_controller.dart
├── models/              # Data models
│   ├── category_model.dart
│   ├── meal_model.dart
│   └── meal_detail_model.dart
├── views/               # UI screens
│   ├── home.dart
│   ├── overview.dart
│   ├── searchpage.dart
│   └── splash_screen.dart
├── widgets/             # Reusable UI components
│   ├── helper.dart
│   └── meal_detail_bottom_sheet.dart
├── apis.dart           # API endpoint definitions
├── constants.dart      # App constants and colors
└── main.dart          # App entry point
```

**Rationale**: Clear separation by functionality makes the codebase maintainable and scalable.

## API Integration

The app integrates with [TheMealDB API](https://www.themealdb.com/api.php) for:
- Fetching meal categories
- Loading meals by category
- Searching meals
- Getting detailed meal information

## Key Features Implementation

### 1. Category Browsing
- Horizontal scrollable category list
- Visual selection feedback
- Automatic meal loading on category selection

### 2. Search Functionality
- Debounced search input (500ms delay)
- Real-time results display
- Integration with meal detail navigation

### 3. Favorites Management
- Toggle favorite status with visual feedback
- Persistent storage using SharedPreferences
- Reactive UI updates across all screens

### 4. Meal Details
- Bottom sheet modal with full recipe information
- Ingredient list with measurements
- Step-by-step cooking instructions
- Favorite toggle functionality

## Time Spent

**Total Development Time: 4 hours**

Breakdown:
- Initial setup and API integration: 1 hour
- UI implementation and styling: 1.5 hours
- Search functionality and navigation: 1 hour
- Favorites feature with SharedPreferences: 30 minutes

## Assumptions and Tradeoffs

### Assumptions
1. **Internet Connectivity**: The app assumes reliable internet connection for API calls
2. **API Reliability**: TheMealDB API is assumed to be consistently available
3. **Image Loading**: All meal images from the API are assumed to be accessible
4. **Data Format**: API response format is assumed to remain consistent

### Tradeoffs
1. **Caching Strategy**: 
   - **Choice**: Simple in-memory caching in controllers
   - **Tradeoff**: Better performance vs. memory usage
   - **Alternative**: Could implement persistent caching with local database

2. **State Management Complexity**:
   - **Choice**: GetX for simplicity
   - **Tradeoff**: Learning curve vs. development speed
   - **Alternative**: More robust solutions like Bloc for larger apps

3. **Error Handling**:
   - **Choice**: Basic error display with retry options
   - **Tradeoff**: User experience vs. development time
   - **Enhancement**: Could add more sophisticated error handling

4. **Offline Support**:
   - **Choice**: No offline functionality
   - **Tradeoff**: App simplicity vs. offline usability
   - **Enhancement**: Could cache favorite meal details locally

## Future Enhancements

- [ ] Offline mode with local database
- [ ] User authentication and cloud sync
- [ ] Recipe ratings and reviews
- [ ] Shopping list generation
- [ ] Meal planning calendar
- [ ] Social sharing features
- [ ] Advanced filtering options

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or suggestions, please contact [your-email@example.com] or create an issue in the repository.

---

**Built with ❤️ using Flutter**
