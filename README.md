# 42Summaries

42Summaries is a macOS application that transcribes audio and video files, then generates concise summaries using Ollama.

## Features

- Transcribe audio files
- Convert video files to audio for transcription
- Generate summaries using Ollama
- User-friendly SwiftUI interface

## Requirements

- macOS 15.0+
- Xcode 16.0+
- Swift 6.0+

## Installation

1. Clone the repository
2. Open the project in Xcode
3. Build and run the application

## Usage

1. Launch 42Summaries
2. Select an audio or video file
3. Wait for transcription to complete
4. View the generated summary

## Project Structure

- Models: Data models
- Views: SwiftUI views
- ViewModels: View models (MVVM architecture)
- Services: Audio/video processing and Ollama integration
- Utilities: Helper functions and extensions

## Dependencies

- AVFoundation framework
- Speech framework

## Current Tasks

### Swift UI
1. [x] Design the main window layout
   - Plan the overall structure of your main window
   - Decide on a sidebar or tab-based navigation (if needed)

2. [X] Create a file selection view
   - Design a view for users to select audio or video files
   - Include a button or drag-and-drop area for file selection
   - Display the selected file's name and type

3. [X] Implement a transcription progress view
   - Create a view to show transcription progress
   - Include a progress bar or indicator
   - Display status messages (e.g., "Transcribing...", "Completed")

4. [ ] Design a summary display view
   - Create a view to show the generated summary
   - Include options for formatting or styling the summary text
   - Consider adding copy or export functionality

5. [ ] Implement settings or preferences view
   - Design a view for app settings (if needed)
   - Include options like output format, summary length, etc.

6. [ ] Create a toolbar
   - Design a toolbar with relevant actions (e.g., start transcription, clear, save)
   - Include icons and labels for each action

7. [ ] Implement error and notification views
   - Design views for displaying errors or important notifications
   - Create alert or toast-style messages for user feedback

8. [ ] Develop a loading or processing overlay
   - Create a view to overlay the main interface during long operations
   - Include an animation or progress indicator

9. [ ] Design an about or help view
   - Create a view with information about the app and how to use it
   - Include version information and any necessary credits

10. [ ] Implement dark mode support
    - Ensure all views adapt properly to both light and dark modes
    - Define color schemes that work well in both modes

11. [ ] Create custom UI components (if needed)
    - Design any custom buttons, sliders, or other UI elements specific to your app

12. [ ] Implement accessibility features
    - Add proper labeling for VoiceOver support
    - Ensure sufficient color contrast and text sizing options

13. [ ] Design responsive layouts
    - Ensure your views adapt to different window sizes
    - Implement proper scaling for text and UI elements

14. [ ] Create app icon and launch screen
    - Design an app icon that represents 42Summaries
    - Create a simple, elegant launch screen
