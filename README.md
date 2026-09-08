# MİRAS — культурно-исторический гид по Турции

Офлайн-приложение для Android: 19 достопримечательностей Турции — от древнейшего храма планеты Гёбекли-Тепе до мраморных колоннад Сиде и Аныткабира. Языки интерфейса: **Русский / Türkçe / English**.

- **Стек:** Flutter 3.35 (Dart 3.9), без сети в рантайме — все фото и шрифты в ассетах.
- **Фото:** Wikimedia Commons (CC BY-SA / Public Domain), атрибуция — в приложении (экран «Источники») и в `miras/assets/images/manifest.json`.
- **Тесты:** unit + component (widget) — `flutter test` обязателен перед сборкой.

## Сборка

```powershell
cd miras
flutter pub get
flutter test
flutter build apk --debug
# → miras/build/app/outputs/flutter-apk/app-debug.apk
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## Скрипты

| Скрипт | Назначение |
|---|---|
| `scripts/fetch_images.ps1` | скачать фото с Wikimedia Commons в ассеты + manifest.json |
| `scripts/verify_images.ps1` | проверить фото зрением (zai-vision MCP) |
| `scripts/device_smoke.ps1` | смоук-тест на подключённом телефоне (adb + скриншоты) |

Правила работы агентов — в [AGENTS.md](AGENTS.md).
