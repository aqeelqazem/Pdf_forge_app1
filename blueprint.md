# Blueprint: PDF Genius

## Overview

PDF Genius is a mobile application designed to allow users to quickly and easily create high-quality PDF documents from their images. The application focuses on an intuitive workflow, from image selection and editing to the final PDF generation.

## Current Plan: Implement Theme Switcher (Day/Night Mode)

**Objective:** Add an icon on the main screen to allow the user to instantly switch between light (day) and dark (night) mode.

**Specific Requirements:**
1.  **Toggle Icon:** Place an `IconButton` in the `AppBar` of the main screen.
2.  **Light Theme Color:** The light mode must use a "light sky blue" color (`lightBlue`) as the primary basis for the color palette (`seedColor`).

**Technical Action Plan:**
1.  **Add `provider`**: Integrate the `provider` package for theme state management. (Already completed).
2.  **Create `ThemeProvider`**: Develop a `ThemeProvider` class that extends `ChangeNotifier` to handle the current theme state (`ThemeMode`) and notify listeners of changes.
3.  **Integrate into `main.dart`**: Wrap the main application (`MyApp`) with a `ChangeNotifierProvider` to make the `ThemeProvider` available throughout the widget tree.
4.  **Define Themes**:
    *   **Light Theme:** Create a `ThemeData` using `ColorScheme.fromSeed` with `Colors.lightBlue` as the `seedColor`.
    *   **Dark Theme:** Create a dark `ThemeData` to maintain visual consistency.
5.  **Update UI**:
    *   Consume the `ThemeProvider` in `MyApp` to apply the selected theme (`theme`, `darkTheme`, `themeMode`).
    *   Add the `IconButton` in the `AppBar` of `HomeScreen` that, when pressed, calls the method to change the theme in the `ThemeProvider`.

## Implemented Features

### Core Functionality

*   **Image Selection**: Users can select multiple images from their device's gallery.
*   **Centralized State Management**: Uses `ImageCubit` (based on `flutter_bloc`) to manage the state of selected images.
*   **Preview and Reorder**: An `ImageDisplayScreen` shows selected images in a grid where users can:
    *   Reorder images by dragging them.
    *   Delete individual images.
    *   Add more images to the current session.
    *   Clear all images to start a new session.
*   **PDF Generation with Correct Order**: Users can create a PDF document from the selected images. The system now ensures that the order of pages in the PDF exactly matches the user-defined order.
*   **PDF Sharing**: After creating a PDF, users have the option to instantly share it via the device's native options.
*   **Robust Navigation**: Uses `go_router` for navigation, with automatic redirects for a smooth user experience.
*   **Session Persistence**: The app automatically saves the session state (selected images and their order), allowing users to continue where they left off.

### Advanced Integrated Image Editor

*   **Integrated Editing**: The editing functionality has been completely redesigned for a superior user experience. Instead of an external tool, the image editor is now an integral part of the editing screen.
*   **Package Used**: Replaced `image_cropper` with `crop_your_image`, which allows embedding the editor directly into the UI.
*   **Editing Interface**:
    *   **Active Crop Viewer**: The main image is displayed with an active crop box overlay, allowing the user to adjust the crop area in real-time.
    *   **Thumbnail Strip**: The thumbnail strip at the bottom is maintained for quick navigation between session images.
*   **Editing Tools**:
    *   **Crop**: The user can apply the crop directly by pressing an "Apply Crop" button, and the image updates in place.
    *   **Rotate**: Buttons are provided to instantly rotate the image left and right.
*   **Non-Destructive Workflow**: As before, modifications do not alter the original files. Changes are saved as new image data (`Uint8List`) within the application's state.

### Theme and Style

*   **General Theme**: The app uses `ThemeData` with `ColorScheme.fromSeed` for a modern and consistent color scheme. The primary color is `Colors.blueGrey`.
*   **Dark/Light Mode**: Full support for both modes, with a button on the "About" screen to toggle.
*   **Typography**: Uses the `google_fonts` package with the "Roboto" font for clean and legible typography.

## Recent Development Activity

### Web Compatibility for Image Cropper (Reverted)

*   **Objective**: An attempt was made to enable the image cropping and rotation functionality on the web platform, where it was previously non-functional.
*   **Actions Taken**:
    1.  The `image_cropper_for_web` package was added as a dependency to provide web-specific implementation.
    2.  The necessary JavaScript (`cropper.min.js`) and CSS (`cropper.min.css`) files were linked in `web/index.html` as required by the package documentation.
*   **Outcome**: Despite these changes and multiple debugging steps (including a full application restart), the error persisted on the web platform. The root cause appears to be a deeper, more subtle conflict within the web environment dependencies rather than an implementation error.
*   **Decision**: In adherence to the core principle of prioritizing application stability, the decision was made to **revert all related changes**. The `image_cropper_for_web` package was removed, and `web/index.html` was restored to its previous state. The application is now back in its fully stable condition, with the known limitation that image cropping does not function on the web. This was deemed the wisest course of action to avoid introducing instability for a non-critical feature.

## Code Status

The codebase is now **stable and free of compilation errors**. All critical issues that prevented the application from running have been addressed, including the image ordering bug. The remaining warnings (`deprecated_member_use`, `unused_import`) have been reviewed and determined not to affect the current functionality, although addressing them in future iterations is recommended to maintain long-term code quality.
