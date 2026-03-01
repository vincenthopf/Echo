# Changelog

## v0.1.2

### Updated AI & Transcription Models

- Updated AI Enhancement models to the latest versions (Feb 2026) across all providers
- Replaced Scribe v1 with Scribe v2 — ElevenLabs' #1 ranked STT model with 2.3% WER
- Updated Gemini transcription models to 3.1 Pro and 3 Flash
- Removed deprecated AI Enhancement providers (Cerebras, Groq, Mistral, ElevenLabs, Deepgram) to simplify the provider list

### Improved Local Model Selection

- Removed low-accuracy local models (tiny, base, small, medium) to reduce clutter
- Existing users on removed models are automatically migrated to Large v3 Turbo (Quantized)
- Updated default recommended model to Large v3 Turbo (Quantized) for the best balance of speed and accuracy

## v0.1.1

### Privacy-First Usage Analytics

Echo now includes anonymous usage analytics to help us understand how the app is used and where to focus improvements. Your privacy remains our top priority:

- **Fully anonymous** — no personal data, no transcription content, no identifying information is ever collected
- **Opt-out anytime** — toggle off in Settings > Privacy Controls > "Share Anonymous Usage Data"
- **On-device first** — analytics are batched locally and sent in small groups, never in real-time
- **No third-party tracking** — no ads, no profiling, no data sold to anyone

What we track (anonymously):

- Onboarding completion rates — so we can make setup smoother
- Transcription usage patterns — which engines and models are popular, how long recordings typically last
- Feature adoption — which features are being used so we can prioritize what matters
- App lifecycle events — install, update, and launch to understand retention

### Universal Binary

Echo now runs natively on both Apple Silicon and Intel Macs.
