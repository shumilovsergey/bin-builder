[[ <- Назад ]](/README.md)

## Описание sync_shumilov_builds.sh

Скрипт предназначен для загрузки рецептов сборки бинарников из публичного репозитория

При запуске скрипт:

1. Находит корень ВАШЕГО текущего git-репозитория.
2. Создаёт (или переписывает) каталог shumilov_builds.
3. Скачивает только содержимое каталога builds из публичного репозитория.
4. Копирует рецепты в shumilov_builds (вместе с RULES.md).
5. Не изменяет и не затрагивает остальные каталоги ВАШЕГО репозитория.

Бинарников в публичном репозитории нет — только рецепты. Собирайте на своём железе:

```bash
cd shumilov_builds/<bin> && docker compose build && docker compose run --rm build
```


## Быстрый запуск

Перейдите в СВОЙ репозиторий и запустите

```bash
curl -fsSL https://raw.githubusercontent.com/shumilovsergey/bin-builder/refs/heads/main/tools/sync_shumilov_builds.sh | bash
```
