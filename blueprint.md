# Blueprint: PDF Genius App

## 1. Overview

This document provides a detailed blueprint of the **PDF Genius** application. It outlines the project's purpose, features, design principles, and technical architecture. This file serves as a single source of truth for the application's current state and future development plans.

---

## 2. Style, Design, and Features (Version 2.1.0)

This section documents all features and design choices implemented in the application.

### 2.1. Core Purpose

The application is a utility tool designed to convert multiple images into a single, shareable PDF document. It prioritizes a simple, intuitive workflow and cross-platform compatibility.

### 2.2. Visual Design & Theming

*   **App Name**: The application is branded as **PDF Genius**.
*   **Aesthetic**: Modern, clean, and professional.
*   **Layout**: A multi-screen structure with declarative routing.
*   **Color Scheme**: Implements Material 3 with `ColorScheme.fromSeed` and supports both Light and Dark modes.
*   **Typography**: Uses `google_fonts` for a clear visual hierarchy.
*   **Iconography**: Uses modern, consistent `outlined` Material Design icons.
*   **Debug Banner**: The "Debug" mode banner has been removed.

### 2.3. Core Features

1.  **Stateful Navigation & Session Awareness**:
    *   Users can freely navigate between the home and editor screens while preserving the current image selection.
    *   The Home Screen now features a **conditional "Continue Editing" button** in the `AppBar` that only appears if there is an active session, providing an intuitive way to return to the editor.

2.  **Session Persistence**: Automatically saves and reloads the user's session across app restarts.

3.  **Image Management**: 
    *   Users can select, reorder (drag-and-drop), and delete images.
    *   An "Add More Images" button is available on the editor screen.

4.  **PDF Generation**: Compiles images into a PDF with a custom filename and opens a native share sheet.

5.  **About Screen**: Displays app information, version, and copyright details.

6.  **Robust Error Handling**: Gracefully handles errors during PDF creation without crashing the app.

### 2.4. Platform-Specific Configuration

*   **Android**: Includes the `INTERNET` permission in `AndroidManifest.xml`.

### 2.5. Architecture

*   **Navigation**: **`go_router`** is used for declarative, URL-based routing (`/`, `/editor`, `/about`). This provides a robust and predictable navigation structure.
*   **State Management**: `flutter_bloc` (`ImageCubit`) manages the application state for image data.
*   **UI Reactivity**: The UI, particularly the `AppBar` on the home screen, reacts to the state of the `ImageCubit` to conditionally display relevant controls.
*   **Route Protection**: A `redirect` is implemented in the router to automatically send users to the home screen if they attempt to access the editor without any selected images.
*   **Service Layer**: Logic is separated into services (`PdfService`, `SessionService`).

---

## 3. Current Plan & Action Steps

**Status:** Completed

### Plan: Implement Smart Session Navigation

1.  **[Done] Add Conditional "Continue Editing" Button**:
    *   **Problem**: After navigating back to the home screen, there was no way to return to the active editing session, causing user confusion.
    *   **Action**: Added a `BlocBuilder` to the `AppBar` of the `HomeScreen`.
    *   **Action**: This builder conditionally adds an `IconButton` (`Icons.edit_document`) that, when pressed, navigates the user back to the editor screen using `context.go('/editor')`.
    *   **Result**: The application now provides a clear and intuitive way for users to resume their work, significantly improving the user experience.

2.  **[Done] Refine New Session Logic**:
    *   **Action**: Updated the "Start New Session" button on the home screen to explicitly clear any pre-existing images before picking new ones.
    *   **Result**: This ensures that starting a new session is a clean and predictable action.
