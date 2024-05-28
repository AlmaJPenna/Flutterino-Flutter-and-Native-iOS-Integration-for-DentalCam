# Flutterino-Flutter-and-Native-iOS-Integration-for-DentalCam

## Overview
Flutterino is a sophisticated application developed using Flutter for the user interface and Objective-C for native iOS integration. The primary purpose of this app is to facilitate a Wi-Fi connection between the application and a device called DentalCam. Flutterino enables users to capture and save video frames and photos from the DentalCam's camera, as well as record videos.

## Key Features
- **Wi-Fi Connectivity:** Establishes a connection with the DentalCam device via Wi-Fi.
- **Frame Capture:** Captures video frames from the DentalCam's camera.
- **Video Recording:** Records videos using the DentalCam's camera.
- **Photo and Video Saving:** Locally saves captured photos and videos.
- **Permission Management:** Handles necessary permissions for camera and storage access.
- **Gallery Integration:** Saves images and videos directly to the device's gallery.

## Technologies Used
- **Flutter:** Utilized for developing the user interface and managing application functionalities.
- **Objective-C:** Employed for native iOS integration, including camera management and capture operations.
- **Dart:** Programming language used with Flutter.
- **iOS SDK:** Leveraged for integration with native iOS functionalities.
- **Libraries Used:**
  - `path_provider`: Manages file storage paths.
  - `gallery_saver`: Saves images and videos to the gallery.
  - `permission_handler`: Manages app permissions.

## Technical Details
### Main File (`main.dart`)
- Initializes the Flutter application.
- Manages the user interface.
- Implements logic for saving photos and videos.
- Controls permissions.

### Native Files (`AppDelegate.m`, `CameraView.m`, `ViewController.m`)
- Integrates the camera using Objective-C.
- Manages capture and recording operations.
- Implements a native interface for camera usage with Flutter.

#### AppDelegate.m
- Sets up the main entry point for the iOS application.
- Registers plugins and initializes the CameraView.

#### CameraView.m
- Defines the CameraView class which handles the camera preview and capture functionality.
- Manages the video recording setup and execution.

#### ViewController.m
- Implements the view controller that interfaces with the camera.
- Handles user interactions and camera operations.

## Use Case
The application is designed for use in the dental field, where professionals can use the DentalCam device to capture high-quality images and videos of patients' dental conditions, allowing for accurate documentation and improved diagnosis.

## Target Audience
- Dental professionals.
- Dental clinics and practices.
- Healthcare institutions requiring detailed visual documentation of dental conditions.

---

For further details or inquiries, please contact the project maintainer.

## License
BSD 3-Clause License

