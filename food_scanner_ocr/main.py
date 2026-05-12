from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import easyocr
import base64
import numpy as np
import cv2
import re

app = FastAPI(title="AI Food Scanner OCR Service")

# Initialize EasyOCR reader (downloads model on first run)
# gpu=False ensures compatibility on all machines, but is slower.
print("Initializing EasyOCR Model...")
reader = easyocr.Reader(['en'], gpu=False)
print("EasyOCR Model Ready!")

class ImagePayload(BaseModel):
    image: str # Base64 encoded image string

def decode_base64_image(base64_string: str) -> np.ndarray:
    try:
        # Strip data URL prefix if present
        if ',' in base64_string:
            base64_string = base64_string.split(',')[1]
        
        img_data = base64.b64decode(base64_string)
        nparr = np.frombuffer(img_data, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        return img
    except Exception as e:
        raise ValueError(f"Failed to decode base64 image: {str(e)}")

@app.post("/ocr/extract")
async def extract_text(payload: ImagePayload):
    try:
        # Decode image
        img = decode_base64_image(payload.image)
        
        # Preprocessing: Convert to grayscale and increase contrast for better OCR
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        # Apply CLAHE (Contrast Limited Adaptive Histogram Equalization)
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
        enhanced_img = clahe.apply(gray)
        
        # Run EasyOCR
        # detail=0 returns only the text strings, not bounding boxes
        results = reader.readtext(enhanced_img, detail=0)
        
        # Basic parsing: combine text, then split by commas or newlines 
        # to simulate ingredient separation.
        full_text = " ".join(results)
        
        # Split by comma or newlines to get rough ingredient list
        raw_ingredients = [i.strip() for i in re.split(r'[,\\n]+', full_text) if len(i.strip()) > 2]
        
        return {"ingredients": raw_ingredients, "raw_text": full_text}
        
    except ValueError as ve:
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OCR Processing failed: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=7860)  # 7860 = Hugging Face Spaces port
