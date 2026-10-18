# How to Run Kompass

Follow these steps to pull the project and run it on your local machine.

## Prerequisites

1. **Git**: Ensure you have [Git installed](https://git-scm.com/downloads).
2. **Flutter SDK**: Ensure you have Flutter installed. You can verify this by running `flutter doctor` in your terminal.
3. **IDE**: Android Studio or VS Code with the Flutter and Dart extensions installed.
4. **Google Chrome**: For running the app on the web (Primary).
5. *(Optional)* **Android Device**: An Android emulator or a physical device if you wish to run the mobile version.

## Setup Instructions

### 1. Clone the Repository
Open your terminal or command prompt and run:
```bash
git clone https://github.com/MohdFer/Kompass.git
```

### 2. Navigate to the App Directory
The main Flutter application code is located inside the `kompass` folder:
```bash
cd Kompass/kompass
```

### 3. Install Dependencies
Run the following command to fetch all the required packages:
```bash
flutter pub get
```

### 4. Run the App
To run the application in Google Chrome (recommended for quick testing):
```bash
flutter run -d chrome
```

*(Optional)* If you want to run it on an Android device or emulator instead, make sure it is connected/running and simply use:
```bash
flutter run
```

---

**Note on Firebase:** 
The Firebase configuration files (`firebase_options.dart` and `google-services.json`) are already included in this repository to make testing easier. You do not need to set up a new Firebase project; the app will automatically connect to the existing project backend!
