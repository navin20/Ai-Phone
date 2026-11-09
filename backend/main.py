from fastapi import FastAPI,Request
from fastapi.responses import StreamingResponse
from ultralytics import YOLO
import cv2

app = FastAPI()

image_path = cv2.VideoCapture(0)
model = YOLO("yolov8n.pt")


def generate_model():
    while True:
        success, frame = image_path.read()
        if not success:
            image_path.set(cv2.CAP_PROP_POS_FRAMES, 0)
            continue
            
        results = model(frame, verbose=False)
        annotated_image = results[0].plot()
        
        ret, buffer = cv2.imencode(".jpg", annotated_image)
        if not ret:
            continue
            
        yield (
            b"--frame\r\n"
            b"Content-Type: image/jpeg\r\n\r\n"
            + buffer.tobytes()
            + b"\r\n"
        )
@app.get("/video_test")
def video(request:Request):
    return StreamingResponse(
        generate_model(),
        media_type="multipart/x-mixed-replace; boundary=frame",
    )

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000, reload=False)
