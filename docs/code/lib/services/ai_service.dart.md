# ai_service.dart

- Path: lib/services/ai_service.dart
- Purpose: Wraps the Google Generative AI client to parse a color recipe from an image (Gemini 1.5 Flash), returning structured JSON data for components.
- Public API
  - Classes:
    - `AIService`: `importRecipeFromImage(imageData)` returns a `Map<String, dynamic>` with `components`.
- Key dependencies: `google_generative_ai` (GenerativeModel), `SettingsService` (API key, enabled flag).
- Data flow & state
  - Inputs: JPEG image bytes; settings for API key and enablement.
  - Outputs: Parsed JSON-like map with `components` (best-effort); throws on invalid or missing data.
  - Providers/Streams watched: Not applicable.
- Rendering/Side effects: Network call to Gemini; JSON parsing/cleanup from model response.
- Invariants & caveats: Requires `isGeminiApiEnabled` and non-empty API key; response text may include code fences → cleaned before `jsonDecode`; schema TODO noted for later integration.
- Extension points: Map to domain models; add retries/timeouts; support more models or prompts.
- Tests referencing this file: Not applicable
- Last reviewed: 2025-10-28
