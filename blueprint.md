# Blueprint: PDF Forge App

## Overview

This document outlines the design, features, and development plan for the PDF Forge application. The goal is to create a modern, intuitive, and feature-rich tool for creating and managing PDF documents from images, with a strong focus on user experience and visual appeal.

---

## 1. Core Functionality

The application provides the following core features:

- **Image Acquisition:**
    - **Pick from Gallery:** Users can select multiple images from their device's gallery.
    - **Scan Document:** Users can use the device's camera to scan documents, which are then added as images. This feature is available on mobile platforms (Android).
- **Image Editing:**
    - **Cropping:**  Users can crop images to select the desired area.
    - **Reordering:** A drag-and-drop interface allows users to reorder images before creating the PDF.
- **PDF Creation:**
    - Generate a single PDF document from the selected and ordered images.
    - Users can name the PDF file before saving.
- **PDF Library:**
    - **View and Manage:** A library displays all previously created PDF documents.
    - **Actions:** Users can open, share, print, or delete PDFs directly from the library.
    - **Persistence:** The library's state is saved across application sessions.
- **Theme Customization:**
    - **Light/Dark Mode:** A theme toggle allows users to switch between light and dark modes.
    - **System Theme:** Users can also set the theme to follow the system's setting.
- **Navigation:**
    - **Back Button:** A back button is implemented in the `AboutScreen` to navigate back to the home screen.

---

## 2. Design and UX

- **Modern UI:** The application uses Material Design 3 for a modern and visually appealing interface.
- **Custom Theming:**
    - **Color Scheme:** A harmonious color palette is generated from a seed color.
    - **Typography:** Custom fonts are used for a professional look and feel (e.g., Oswald for headers, Roboto for body).
- **Intuitive Navigation:** The app uses `go_router` for a clear and predictable navigation flow.
- **User-Friendly Screens:**
    - **Home Screen:** An engaging landing page with clear calls to action.
    - **PDF Library:** A clean and organized list of PDFs using `Card` widgets.
    - **Image Editing:** An intuitive drag-and-drop grid for reordering images.
    - **About Screen:** A simple and informative screen about the application.
    - **Image Display Screen:**
        - Displays selected images in a grid.
        - Allows users to add more images by choosing between scanning a document or picking from the gallery.
        - Includes actions to edit, delete, and create a PDF from the images.

---

## 3. Current Task: Fix Camera Functionality and Enhance Image Display Screen

- **Problem:** The camera was not opening when the 'Scan Document' option was selected.
- **Solution:**
    - Added the `CAMERA` permission to the `AndroidManifest.xml` file for the Android platform.
    - Identified that the `cunning_document_scanner` package is not supported on the web, which is expected behavior.
- **Enhancement:**
    - Added the same image source selection (scan or gallery) to the `ImageDisplayScreen` to allow users to add more images to their current session.
