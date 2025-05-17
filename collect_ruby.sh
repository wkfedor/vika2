#!/bin/bash

# Путь к финальному файлу
output_file="project_combined.txt"

# Удаляем файл, если он уже существует
rm -f "$output_file"

# Список исключений
excluded_dirs=("vendor")

# Функция для проверки на вхождение в список исключений
is_excluded() {
    for dir in "${excluded_dirs[@]}"; do
        # Проверяем, начинается ли путь с одного из исключенных директорий
        if [[ "$1" == "./$dir/"* || "$1" == "./$dir" || "$1" == "$dir/" ]]; then
            return 0
        fi
    done
    return 1
}

# Рекурсивно обходим все файлы в проекте
find . -type f -name '*.rb' | while read -r file; do
    if is_excluded "$file"; then
        echo "Пропускаем: $file"
        continue
    fi
    # Добавляем путь к файлу
    echo "### $file" >> "$output_file"
    # Добавляем содержимое файла
    cat "$file" >> "$output_file"
    # Добавляем разделитель
    echo -e "\n# # # # # # # # # # # # # # # # # # # #\n" >> "$output_file"
done

echo "Скопированные файлы в $output_file"
