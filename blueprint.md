
# Blueprint: Image to PDF Converter

## Overview

A Flutter application designed to convert multiple images selected by the user into a single, shareable PDF document. The application will be built following clean architecture principles to ensure scalability and maintainability.

## Architecture & Design

The project is structured using a clean architecture approach, separating the code into three main layers:

*   **`lib/ui`**: This directory holds all the UI components of the application. This includes screens, widgets, and anything related to how the application is presented to the user.
*   **`lib/business_logic`**: This layer contains the application's business rules and state management. It acts as an intermediary between the UI and the services, handling user interactions and data flow.
*   **`lib/services`**: This directory is responsible for all external interactions and low-level implementations. This includes picking images from the device's gallery, the logic for creating the PDF file from image data, and saving/sharing the file.

### Dependencies

The following packages have been added to `pubspec.yaml` to facilitate the required functionalities:

*   **`image_picker`**: To allow users to select images from their device's gallery.
*   **`pdf`**: A powerful library to create and write PDF documents in Dart.
*   **`path_provider`**: To find the correct local path to store the generated PDF file.
*   **`printing`**: To enable sharing, printing, and previewing the created PDF document.

## Current Plan

1.  **Project Scaffolding**:
    *   [x] Create a clean architecture folder structure: `ui`, `business_logic`, `services`.
    *   [x] Add required dependencies to `pubspec.yaml`: `pdf`, `image_picker`, `path_provider`, `printing`.
    *   [x] Create this `blueprint.md` file to document the project plan and architecture.

2.  **Next Steps**:
    *   Implement the UI for the main screen, including a button to pick images.
    *   Implement the image picking functionality using the `image_picker` service.
    *   Develop the business logic to manage the list of selected images.
    *   Implement the PDF creation service to convert the selected images into a PDF file.
    *   Add functionality to preview and share the generated PDF.
