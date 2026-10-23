from fastapi import APIRouter, Response, HTTPException
from pydantic import BaseModel
from app.services.openai_service import openai_service

router = APIRouter(prefix="/tts", tags=["Voice"])

class TTSRequest(BaseModel):
    text: str

@router.post("/speak")
async def generate_speech_audio(req: TTSRequest):
    if not req.text:
        raise HTTPException(status_code=400, detail="Text cannot be empty")

    audio_bytes = await openai_service.generate_speech(req.text)
    if not audio_bytes:
        # Return 204 or light empty sound if no OpenAI voice available
        return Response(content=b"", media_type="audio/mpeg", status_code=200)

    return Response(content=audio_bytes, media_type="audio/mpeg")
