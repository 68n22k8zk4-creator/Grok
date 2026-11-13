# Как открыть проект в Xcode

Самый надёжный способ (рекомендуется):

1. Открой Xcode → **File → New → Project**
2. Выбери **iOS → App**
3. Product Name: `OgonekApp`
4. Interface: **SwiftUI**, Language: **Swift**
5. Сними галочку Include Tests
6. Сохрани проект куда удобно

7. Удали стандартные файлы ContentView.swift и OgonekAppApp.swift из проекта (Move to Trash)

8. Перетащи **всю папку** `OgonekApp/` (из этого архива) в навигатор Xcode:
   - галочка **Copy items if needed**
   - **Create groups**
   - Target: OgonekApp

9. Добавь Widget Extension (опционально):
   - File → New → Target → Widget Extension
   - Name: WidgetExtension
   - Замени сгенерированный код на файлы из папки WidgetExtension/

10. В Signing & Capabilities выбери свою команду и Bundle ID.

11. Build & Run на симуляторе или устройстве.

---

Альтернатива: если у тебя уже есть Mac с Xcode — можно создать пустой проект и просто скопировать все `.swift` файлы в нужные группы.

Для CodeMagic / GitHub:
- Залей содержимое папки OgonekApp на GitHub
- В CodeMagic укажи scheme после создания .xcodeproj локально и коммита
