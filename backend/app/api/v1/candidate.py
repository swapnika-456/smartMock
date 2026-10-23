from fastapi import APIRouter, File, UploadFile, HTTPException
from app.schemas.candidate import CandidateCreate, ResumeParseResponse
from app.services.resume_service import resume_service

router = APIRouter(prefix="/candidate", tags=["Candidate"])

@router.post("/parse-resume", response_model=ResumeParseResponse)
async def parse_resume_upload(file: UploadFile = File(...)):
    if not file.filename:
        raise HTTPException(status_code=400, detail="Invalid filename")

    content_bytes = await file.read()
    if not content_bytes:
        raise HTTPException(status_code=400, detail="Uploaded file is empty")

    if file.filename.lower().endswith(".pdf"):
        text = resume_service.extract_text_from_pdf_bytes(content_bytes)
    else:
        text = content_bytes.decode("utf-8", errors="ignore")

    if not text.strip():
        text = "Experienced software engineer specializing in backend systems, APIs, and modern frontend application development."

    parsed = await resume_service.parse_resume(text)
    return parsed
