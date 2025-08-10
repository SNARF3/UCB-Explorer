
# **Flutter Application Setup Guide UCB - Explorer**

## 📋 Prerequisites  
- **Flutter SDK** (version ≥3.0.0)  
  ```bash
  flutter --version  # Verify installation
  ```
- **Dart SDK** (bundled with Flutter)  
- **IDE**: Android Studio/Xcode (for emulators) or VS Code (with Flutter/Dart extensions)  
- **Device**: Physical device (USB debugging enabled) or emulator (Android/iOS)  

---

## 🚀 **Run the App**  
### **1. Clone the Repository**  
```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

### **2. Install Dependencies**  
```bash
flutter pub get
```

### **3. Run on Device/Emulator**  
- **Android**:  
  ```bash
  flutter run -d android  # or use device ID
  ```
- **iOS**:  
  ```bash
  flutter run -d ios
  ```
- **Web**:  
  ```bash
  flutter run -d chrome
  ```

---

## 🔧 **Additional Commands**  
| Command | Description |  
|---------|-------------|  
| `flutter doctor` | Check environment setup |  
| `flutter clean` | Clear build artifacts |  
| `flutter pub upgrade` | Update dependencies |  
| `flutter build apk` | Generate release APK |  

---

## ⚠️ **Troubleshooting**  
- **Emulator Issues**:  
  ```bash
  flutter emulators --launch Pixel_5_API_33
  ```
- **Missing Dependencies**:  
  ```bash
  flutter doctor --android-licenses
  ```
- **Cache Problems**:  
  ```bash
  flutter clean && flutter pub get
  ```

---

## 🌐 **Debugging**  
- **VS Code**: Use `F5` with the Dart debugger.    
