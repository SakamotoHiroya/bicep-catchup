# main.py

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

class EchoRequest(BaseModel):
    text: str

class EchoResponse(BaseModel):
    echo: str

@app.post("/echo", response_model=EchoResponse)
async def echo(req: EchoRequest):
    """
    リクエストボディで受け取った text をそのまま返すエンドポイント
    """
    if not req.text:
        raise HTTPException(status_code=400, detail="text が空です")
    return EchoResponse(echo=req.text)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True  # 開発時にファイル変更を自動反映
    )