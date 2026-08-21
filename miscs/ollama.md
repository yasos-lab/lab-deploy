## LLM (chat)
Qwen3 4B (ollama pull qwen3:4b) — best comfort/quality balance on 8 threads of Zen3, snappy responses, good enough reasoning for daily use.
If you want a second, lighter one for quick/simple tasks: Phi-4-mini (ollama pull phi4-mini) — fastest of the bunch.
Skip anything 8B+ as your main driver — it'll work but feel noticeably laggier per response.
## Embeddings (RAG)
nomic-embed-text (ollama pull nomic-embed-text) — 274MB, fast, this is the one to just use and not think about.
## Speech-to-Text
whisper.cpp with the base model — good accuracy/speed tradeoff on CPU, transcribes close to real-time. Use OpenWebUI's built-in local Whisper and just set the model to base (or small if you don't mind a couple extra seconds of lag).
## Text-to-Speech
Kokoro-82M via Kokoro-FastAPI (ghcr.io/remsky/kokoro-fastapi-cpu) — tiny, fast on CPU, genuinely good voice quality. Point OpenWebUI/LibreChat's TTS engine at its OpenAI-compatible endpoint.

