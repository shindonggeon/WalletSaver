# WalletSaver (소리 - Sori)

20대 사용자를 위한 소비 습관 관리 앱 **'소리(Sori)'** 프로젝트입니다.

## 프로젝트 구조

- `test0429/`: Flutter 프론트엔드 모바일 애플리케이션
- `ai_backend/`: FastAPI 기반 AI 금융 비서 백엔드 서버

---

## 실행 방법

### 1. 프론트엔드 (Flutter) 실행

이 프로젝트는 Flutter로 개발되었습니다. 실행 전 [Flutter SDK](https://docs.flutter.dev/get-started/install)가 설치되어 있어야 합니다.

1. `test0429` 폴더로 이동합니다.
   ```bash
   cd test0429
   ```
2. 필요한 패키지를 설치합니다.
   ```bash
   flutter pub get
   ```
3. 연결된 기기나 에뮬레이터에서 앱을 실행합니다.
   ```bash
   flutter run
   ```

### 2. 백엔드 (AI Backend) 실행

AI 기능(Gemini API 연동 등)을 처리하는 FastAPI 백엔드 서버입니다. 파이썬 3.8 이상이 필요합니다.

1. `ai_backend` 폴더로 이동합니다.
   ```bash
   cd ai_backend
   ```
2. 필요한 파이썬 패키지들을 설치합니다.
   ```bash
   pip install fastapi uvicorn python-dotenv google-genai pydantic
   ```
3. 환경 변수(`GEMINI_API_KEY`)를 설정합니다.
   `ai_backend` 폴더 내에 `.env` 파일을 생성하고 아래와 같이 발급받은 Gemini API 키를 입력합니다.
   ```env
   GEMINI_API_KEY=여러분의_제미나이_API_키
   ```
4. FastAPI 서버를 실행합니다.
   ```bash
   uvicorn main:app --reload
   ```
   서버가 실행되면 `http://localhost:8000`에서 백엔드 API가 구동됩니다.
