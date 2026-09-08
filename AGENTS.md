# AGENTS.md — MİRAS · культурно-исторический гид по Турции (офлайн, Android)

Репозиторий: `D:\Projects\2RK`. Flutter-приложение лежит в `miras/`. Поддерживаемые языки UI: **RU / TR / EN**. Все фото — офлайн-ассеты `miras/assets/images/`, лицензии и авторы — в `miras/assets/images/manifest.json`.

## Железные правила

1. **Любая команда — только с явным timeout** (у bash-инструмента параметр `timeout` в мс). Зависаний не допускать: Flutter/Gradle — от 300 000 мс, vision — от 120 000 мс.
2. **Логирование.** Скрипты пишут логи в `logs/` (папка в git не попадает). В приложении — `lib/core/logger.dart`, тег `MIRAS` (виден в `adb logcat -s MIRAS`).
3. **Гейты качества.** После любых изменений кода из папки `miras/` обязаны проходить `flutter analyze` (0 issues) и `flutter test` (all green). Красное не коммитим и не собираем.
4. **Секреты.** В репозиторий не попадает ничего секретного: ключи, токены, пароли, `*.jks`, `*.keystore`, `key.properties`, `.env*`, `local.properties`. Перед каждым push — скан (см. ниже).
5. Коммиты и push — только по явному запросу владельца.

## Команды (из корня репо)

| Действие | Команда | Timeout, мс |
|---|---|---|
| Анализ | `flutter analyze` (workdir `miras/`) | 300000 |
| Тесты | `flutter test` (workdir `miras/`) | 600000 |
| Сборка debug APK | `flutter build apk --debug` (workdir `miras/`) | 900000 |
| Скачать фото | `scripts/fetch_images.ps1` | 900000 |
| Проверить фото зрением | `scripts/verify_images.ps1` | 1800000 |
| Смоук на телефоне | `scripts/device_smoke.ps1` | 900000 |

adb: `D:\Android\Sdk\platform-tools\adb.exe`. Устройство владельца: Xiaomi 23113RKC6G (vermeer), Android 16, 1440×3200. Логи приложения ищи строкой: `adb logcat -d | Select-String MIRAS` (debugPrint пишет под тегом `flutter`, тег `MIRAS` — внутри текста).

Смоук `device_smoke.ps1` водит приложение координатными тапами (экран 1440×3200): семантика Flutter не видна `uiautomator` без активной a11y-службы, поэтому текстовый поиск узлов не работает. Перед прогоном: телефон должен быть разблокирован, держи экран: `svc power stayon usb`; при уснувшем экране — `input keyevent 224` + свайп-разблокировка (ПИН adb не обходит).

## Анти-зависание — железные меры

1. **Таймаут на всё.** Любая команда bash-инструменту — только с явным `timeout`. Flutter/Gradle ≥ 300 000 мс, vision ≥ 120 000 мс, лёгкие проверки 15 000–60 000 мс. Команд без таймаута не существует.
2. **Батчи вместо марафонов.** Переборы (vision по N файлам, обработка множества объектов) — порциями по 3–5 (`-Only`, `-Max`), каждая порция — отдельный вызов со своим таймаутом. Один вызов ≤ 10 минут.
3. **Инкрементальность.** Длинные скрипты хранят состояние в `logs/*state*.json` и при перезапуске пропускают уже обработанное. Перезапуск всегда дешевле ожидания.
4. **Процесс-гигиена.** Перед повторным запуском vision — проверить и убить зависшее: `Get-Process mcp-cli,pwsh -EA SilentlyContinue | Stop-Process -Force` (только свои!). После таймаута джоб обязан убиваться `Stop-Job -Force`.
5. **vision — только через Start-Job** с `Wait-Job -Timeout 90..150`. Таймаут → `Stop-Job`, вердикт `UNKNOWN`, идём дальше. Ни один mcp-cli не вызывается напрямую в длинной цепочке.
6. **Формат вывода mcp-cli:** ответ модели — В КОНЦЕ вывода, после десятка строк `[zai-vision] … INFO`. Первая строка почти всегда служебная — парсить с конца. Ошибки — строки `Error:`.
7. **`File not found` от vision** = файла нет или путь не forward slashes: перед вызовом `Test-Path`, конвертация JPEG→PNG ≤1400 px (PNG <5MB).
8. **PowerShell:** в функциях, возвращающих значения, запрещён pass-through вывод (`Tee-Object` и т.п. — утекает в `return`). Лог — `Write-Host` + `Add-Content`.
9. **Ретраи и вежливость:** HTTP 429 → пауза 15–30 с (Wikimedia), между API-запросами ≥ 2–3 с. Не долбить подряд.
10. **Если вызов всё же завис:** следующий шаг всегда — проверить процессы, убить, перезапустить с меньшим батчем. Не ждать чуда.

## Сборка (Gradle/Kotlin) — гигиена

1. **Особенность машины:** Pub Cache лежит на `C:`, проекты — на `D:`. Инкрементальная компиляция Kotlin падает на разных корнях дисков (`this and base files have different roots`), поэтому в `miras/android/gradle.properties` обязано стоять `kotlin.incremental=false`. Не удалять эту строку.
2. **Перед повторной сборкой после фейла:** проверить и убить зависшие демоны: `Get-Process java,kotlin-daemon,gradle -EA SilentlyContinue | Stop-Process -Force` (только свои процессы сборки).
3. **Ошибки инкрементальных кэшей Kotlin** (`Could not close incremental caches`) → `flutter clean` в `miras/`, затем повтор сборки.
4. **Максимум 2 попытки сборки подряд**, каждая — отдельным вызовом с timeout 900 000 мс. После второй неудачи — стоп и разбор лога, никаких вечных ретраев.
5. Один вызов инструмента ≤ 10 минут: длинные шаги (clean → build → тесты) — по отдельности, не одной цепочкой.

## Vision: MCP-сервер zai-vision (GLM-4.6V через ZAI)

Сервер настроен глобально (`~/.config/opencode/opencode.json`) и доступен из ЛЮБОГО проекта — ничего ставить и настраивать не надо.

### Способ 1 — opencode-агент
Инструменты `analyze_image` и др. подхватываются автоматически в сессии. Когда владелец говорит «посмотри картинку» — вызывай `analyze_image` и пересылай вердикт. Отвечать «не вижу картинки» запрещено.

### Способ 2 — из bash/скриптов
```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
mcp-cli call zai-vision analyze_image '{"image_source":"C:/abs/path/img.png","prompt":"What is here? Reply in Russian."}'
```

- JSON — в одинарных кавычках, путь — только forward slashes
- timeout **120000+ мс** (GLM думает 15–60 с)
- только **PNG <5MB** (BMP сначала конвертируй через PIL)
- Инструменты: `analyze_image`, `extract_text_from_screenshot`, `diagnose_error_screenshot`, `understand_technical_diagram`, `analyze_data_visualization`, `ui_diff_check`, `ui_to_artifact`, `analyze_video`. Полный список: `mcp-cli -d`

### Если не работает

| Симптом | Фикс |
|---|---|
| `mcp-cli not found` | PATH-фикс из блока выше |
| Connect timeout к `api.z.ai` | транзитный блэкаут, retry через пару минут |
| `429` | перегрев квоты — снизить параллелизм и повторы |
| Вывод — только строки `INFO`, ответа нет | ответ всегда В КОНЦЕ вывода — парсить с конца; если процесс висит — убить `mcp-cli` и перезапустить батч |
| `File not found` | PNG не существует или путь не forward slashes: `Test-Path` + конвертация JPEG→PNG ≤1400 px |

## Скан секретов перед push

```powershell
git ls-files | Select-String -Pattern '\.(jks|keystore|env|pem|key)$'
rg -n -i "(api[_-]?key|secret|token|password)\s*[:=]" --glob '!*.lock' --glob '!AGENTS.md'
```
Любые совпадения разбираются вручную до push.

## Структура репозитория

```
AGENTS.md            правила агентов (этот файл)
README.md            описание проекта
scripts/             fetch_images.ps1, verify_images.ps1, device_smoke.ps1
logs/                логи скриптов (gitignored)
miras/               Flutter-приложение
  lib/data/sites.dart     19 объектов: имена/описания RU+TR+EN, эры, UNESCO, pride-факты
  lib/l10n/strings.dart   словари RU/TR/EN
  lib/core/               theme.dart (бирюза+золото, изникская решётка, меандр), logger.dart
  lib/ui/screens/         home, gallery, detail, sources
  test/                   компонентные (widget) и unit-тесты — гейт перед сборкой
  assets/images/          фото (Wikimedia Commons, CC BY-SA / PD) + manifest.json
```
