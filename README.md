## Тестовое задание:
- Необходимо разработать простое приложение для ведения списка дел (ToDo List) с
возможностью добавления, редактирования, удаления задач.

## Требования:  
1. Список задач:  
   - Отображение списка задач на главном экране.  
   - Задача должна содержать название, описание, дату создания и статус (выполнена/не
выполнена).
  Возможность добавления новой задачи.
   - Возможность редактирования существующей задачи.
   - Возможность удаления задачи.
   - Возможность поиска по задачам.
1. Загрузка списка задач из dummyjson api: https://dummyjson.com/todos. При первом
запуске приложение должно загрузить список задач из указанного json api.
1. Многопоточность:
   - Обработка создания, загрузки, редактирования, удаления и поиска задач должна
выполняться в фоновом потоке с использованием GCD или NSOperation.
   - Интерфейс не должен блокироваться при выполнении операций.
1. CoreData:
    - Данные о задачах должны сохраняться в CoreData.
   - Приложение должно корректно восстанавливать данные при повторном запуске.
2. Используйте систему контроля версий GIT для разработки.
3. Напишите юнит-тесты для основных компонентов приложения
4. Необходимо убедиться, что проект открывается на Xcode 15


![Пример изображения](https://github.com/ssgushyonka/try/blob/main/2025-02-03%2022.05.50.jpg?raw=true)
