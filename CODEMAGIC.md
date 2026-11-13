# CodeMagic — как собрать IPA

## 1. Что уже лежит в репозитории

- `codemagic.yaml` — два workflow:
  - **ios-ipa** — с подписью (нужен твой .p12 + mobileprovision в CodeMagic)
  - **ios-unsigned** — без подписи (потом подпишешь в GBox)
- `OgonekApp.xcodeproj` — проект Xcode
- `exportOptions.plist`

## 2. Залей на GitHub

```bash
cd OgonekApp
git init
git add .
git commit -m "Ogonek app + codemagic"
git branch -M main
git remote add origin https://github.com/ТВОЙ_ЮЗЕР/ogonek.git
git push -u origin main
```

## 3. В CodeMagic

1. **Add application** → выбери репозиторий
2. Обнови страницу / нажми **Check for configuration file**
3. Должен появиться workflow из `codemagic.yaml`

### Вариант A — подпись в CodeMagic (рекомендуется)

1. Teams → **Code signing identities**
2. Загрузи:
   - Certificate (`.p12`) + пароль
   - Provisioning Profile (`.mobileprovision`)
3. Bundle ID профиля должен быть `com.ogonek.app` (или поменяй в yaml и в Xcode)
4. Запусти workflow **Ogonek IPA**
5. Скачай `.ipa` из Artifacts

### Вариант B — без подписи → GBox

1. Запусти workflow **Ogonek Unsigned (for GBox)**
2. Скачай IPA
3. В GBox Fun подпиши своим сертификатом и поставь

## 4. Если снова «No configuration file»

- Файл должен лежать **в корне репозитория**: `codemagic.yaml` (не внутри папки)
- Ветка `main` (или та, что выбрана в CodeMagic)
- После push нажми кнопку обновления в правом верхнем углу

## 5. Bundle ID

Сейчас: `com.ogonek.app`  

Если твой provisioning profile на другой ID — поменяй в:
- `OgonekApp.xcodeproj/project.pbxproj` → `PRODUCT_BUNDLE_IDENTIFIER`
- `codemagic.yaml` → `BUNDLE_ID` / `bundle_identifier`
