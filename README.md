# BRD Generator

A Flutter application that generates Business Requirements Documents (BRD) using OpenAI's GPT models.

## Features

- Generate comprehensive BRD documents using AI
- Save and manage generated documents
- View documents with Markdown rendering
- Export documents to the device storage

## Setup

1. Clone this repository
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Run the application:
   ```
   flutter run
   ```

## Using the Application

### Setting up your OpenAI API Key

1. Get an API key from [OpenAI Platform](https://platform.openai.com/api-keys)
2. In the app, tap the key icon in the top-right corner
3. Enter your OpenAI API key and save

### Creating a BRD Document

1. Tap the + button on the home screen
2. Enter a title for your document
3. Provide a detailed project description
4. Tap "Generate BRD" and wait for the AI to create your document
5. Review the generated content
6. Tap "Save Document" to store it

### Viewing and Managing Documents

- All saved documents are displayed on the home screen
- Tap on a document to view its content
- Use the export button to save a copy to your device
- Use the delete button to remove a document

## Requirements

- Flutter 3.0.0 or higher
- Dart 2.17.0 or higher
- OpenAI API key

## Dependencies

- http: For API requests
- dart_openai: For OpenAI integration
- shared_preferences: For local storage
- flutter_markdown: For rendering Markdown content
- path_provider: For file system operations
