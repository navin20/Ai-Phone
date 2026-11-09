# AI Phone

AI Phone is an ongoing computer-vision project with a Flutter interface and a
Python backend. Development is happening in stages: the current prototype
captures video from the computer's webcam, detects objects with a YOLOv8 model,
and displays the annotated live stream in the Flutter app.

The current setup is intended for a desktop computer and a browser running on
that same computer. Using a phone's camera is a future step; mobile support is
not configured yet.

Future development may move the backend to a server and connect it to a
Raspberry Pi camera or another supported camera source. In that setup, the
Flutter app could view the server's processed video stream instead of relying
on the local computer's webcam.

## Project status and direction

The project is under active development. The current focus is getting the
computer-vision pipeline and Flutter interface working reliably in a browser
and on desktop before expanding to phones or remote camera hardware.

Possible next stages include:

- Improving the desktop and browser experience and handling camera or stream
  errors more clearly.
- Making the backend configurable for different cameras and deployment
  environments.
- Hosting the backend on a server so the Flutter app can connect over a
  network.
- Exploring a Raspberry Pi camera or another compatible camera as a video
  source.
- Adding mobile support, including phone-camera integration where appropriate.

These are future development goals, not features of the current prototype.

## How it works

1. The backend opens the computer's default webcam (camera index `0`).
2. The backend uses Ultralytics YOLOv8, loading its `yolov8n.pt` Nano
   pre-trained object-detection model, and runs detection on each captured
   frame. The Nano model is a relatively small general-purpose model suitable
   for trying this prototype.
3. FastAPI serves the annotated frames as an MJPEG stream at
   `http://localhost:8000/video_test`.
4. The Flutter app displays that stream.

## What the YOLO model does

YOLO stands for **You Only Look Once**. It is an object-detection model: it
processes each camera frame and predicts the locations and types of objects it
recognizes. The backend draws boxes and labels around those detections before
sending the frame to Flutter.

This project uses **YOLOv8 Nano** (`yolov8n.pt`), the small, fast variant of
Ultralytics' YOLOv8 model. The standard pretrained weights recognize common
objects from the COCO dataset, such as people, vehicles, and animals; they do
not recognize every possible object. Detection quality depends on the object,
lighting, camera, and processing hardware. Recognizing project-specific
objects would require training or obtaining a compatible custom model.

No `.env` file is needed for the current prototype. The stream URL and backend
settings are currently defined directly in the source code.

## Requirements

- Python 3.10 or newer
- Flutter SDK with Dart 3.8.1 or newer
- A webcam connected to the computer
- Google Chrome for browser mode
- Windows desktop build tools for the Windows desktop target (Visual Studio
  with the **Desktop development with C++** workload)

## Setup

Open two terminals in the project folder.

### 1. Set up and start the backend

In the first terminal, create a Python virtual environment and install the
backend packages:

```powershell
cd backend
py -m venv venv
.\venv\Scripts\activate
python -m pip install --upgrade pip
python -m pip install fastapi uvicorn ultralytics opencv-python
```

The project includes `backend/yolov8n.pt`. If that file is missing, Ultralytics
can download the official YOLOv8 Nano weights when you first load the model.
With the virtual environment activated and the terminal still in `backend`,
run:

```powershell
python -c "from ultralytics import YOLO; YOLO('yolov8n.pt')"
```

This requires an internet connection the first time. Keep the downloaded
`yolov8n.pt` in the `backend` directory, then start the server as shown below.
The model is loaded in `backend/main.py` by `YOLO("yolov8n.pt")`. To use
different weights, obtain a compatible model from Ultralytics and update that
model path; custom models may detect different classes.

Start the backend from the `backend` directory so it can find the model file:

```powershell
python main.py
```

Keep this terminal open while using the app. The backend uses the computer's
default webcam, so close other applications that may be using it.

### 2. Set up Flutter

In the second terminal:

```powershell
cd mobile
flutter doctor
flutter pub get
```

Resolve any missing Flutter or platform dependencies reported by `flutter doctor`
before launching.

### 3. Run in a browser

From the `mobile` directory, with the backend still running, start the Flutter
web app:

```powershell
flutter run -d chrome
```

The browser and backend must run on the same computer because the app currently
connects to `localhost:8000`.

### 4. Run as a Windows desktop app

From the `mobile` directory, enable the Windows desktop target if needed, then
launch the app:

```powershell
flutter config --enable-windows-desktop
flutter devices
flutter run -d windows
```

The backend must remain running in its separate terminal.

## Troubleshooting

- **The stream is blank or does not load:** make sure `python main.py` is
  running and that `http://localhost:8000/video_test` is reachable from the
  same computer.
- **The camera does not open:** check OS camera permissions, connect a webcam,
  and close other apps using it. The backend currently only tries camera index
  `0`.
- **The model file cannot be found:** start the backend from the `backend`
  directory and check that `yolov8n.pt` is present there.
- **Flutter cannot find Chrome or Windows:** run `flutter doctor`, install the
  missing platform tools, and check available targets with `flutter devices`.
- **Testing from a phone:** this is not supported by the current setup. The
  app uses `localhost`, and the backend reads the computer's webcam rather
  than the phone camera. Mobile support will need a reachable backend address
  and phone-camera integration. A future server-hosted backend could also
  process video from a Raspberry Pi camera or another supported camera source.

## Project structure

```text
backend/
  main.py       FastAPI MJPEG stream and YOLO computer-vision processing
  yolov8n.pt    YOLOv8 model weights
mobile/
  lib/main.dart Flutter app that displays the MJPEG stream
```