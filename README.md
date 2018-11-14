# Snuze
## Assuming Flutter is Installed
    1. Names with hyphens are considered invalid module names in dart, so change the snuze-app folder's name to be snuze_app.
    2. Delete the snuze_app/ios/Flutter folder. This may be unnecessary - a test is needed.
    3. With the snuze_app folder as your pwd run `flutter packages get`, then run `flutter create -i swift .` to recreate missing files inside the current folder.
    4. Create a .env.dart file in the lib folder with necessary environment variables.
        -FIREBASE_API_KEY
    5. Run `flutter packages pub run build_runner build` to build json serializable models.
    6. Run pod install from the ios directory.
    6. Run using xcode/android studio using the xcworkspace file not xcproj because we're using cocoapods.