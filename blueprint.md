# Blueprint: PDF Genius

## Overview

PDF Genius is a mobile application designed to allow users to quickly and easily create high-quality PDF documents from their images. The application focuses on an intuitive workflow, from image selection and editing to the final PDF generation.

## Current Plan

The project is in a stable state. The current objective is to address user-requested features and improvements while maintaining application stability and adhering to established engineering best practices.

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
*   **Back Navigation Warning**: A confirmation dialog is implemented on the `ImageDisplayScreen` to prevent accidental loss of the current image session when the user attempts to navigate back.

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
*   **Responsive Watermark**: On the image display screen, the "PDF Genius" watermark is fully responsive. It dynamically scales its font size based on the screen width, ensuring it is visually balanced and legible on all device sizes, from small phones to large tablets.
*   **Intuitive Icons**: The icon for creating a PDF has been replaced with a custom-built composite icon (`Image -> Arrow -> Document`) to visually represent the conversion process, enhancing user understanding.

## Recent Development Activity

### 1. Back Navigation Safety (Robust Implementation)

*   **Objective**: Add a confirmation dialog on the `ImageDisplayScreen` to prevent users from accidentally losing their current image session.
*   **Challenge & Resolution**:
    *   **Initial Attempt**: The first implementation introduced a `PopScope` widget that conflicted with an existing `BlocListener` responsible for navigation. This conflict created an infinite redirect loop (`ERR_TOO_MANY_REDIRECTS`), a critical stability issue.
    *   **Engineering Decision**: The error was immediately addressed by redesigning the navigation logic. The `BlocListener` was identified as the source of the conflict and was removed.
    *   **Final Solution**: A single, unified function, `_handleNavigationBack`, was created to manage all back navigation events (system gesture and `AppBar` button). This function now explicitly controls the workflow:
        1.  Display a confirmation dialog.
        2.  Upon user confirmation, clear the image state (`ImageCubit`).
        3.  **Then, and only then,** perform a single, explicit navigation back to the home screen (`context.go('/')`).
*   **Outcome**: This robust solution completely eliminates the redirect loop and provides a safe, predictable user experience, fully aligning with our core principle of application stability.

### 2. Responsive Watermark

*   **Objective**: The "PDF Genius" watermark on the `ImageDisplayScreen` had a fixed font size, causing it to appear too large on small screens and too small on larger ones.
*   **Action Taken**: The `LayoutBuilder` widget was implemented to make the watermark responsive.
*   **Implementation**: The `fontSize` of the watermark is now calculated dynamically as a percentage of the available screen width (`constraints.maxWidth * 0.2`).
*   **Outcome**: The watermark now scales gracefully across all device sizes, significantly improving the visual polish and user experience of the application.

### 3. Web Compatibility for Image Cropper (Reverted)

*   **Objective**: An attempt was made to enable the image cropping and rotation functionality on the web platform.
*   **Outcome**: The changes led to persistent errors and dependency conflicts within the web environment.
*   **Decision**: To maintain absolute stability, all related changes were reverted. The application remains fully functional with the known limitation that image editing is not supported on the web.

## Code Status

The codebase is **stable and free of compilation errors**. All critical issues have been resolved. Remaining warnings (`deprecated_member_use`, `unused_import`) are documented as low-priority technical debt and do not affect current functionality.
