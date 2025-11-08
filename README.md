# Анализ данных командриовок сотрудников - Вариант 10

Практическая работа: консолидация и аналитическая обработка данных с использованием Docker Compose, Jupyter Lab и PostgreSQL.

Дисциплина: Анализ больших данных и рыночных тенденций

Направление: Бизнес-информатика (магистратура)

Вариант 10

ФИО студента: Кузнецов Артем Игоревич

ФИО преподователя: Босенко Тимур Муртазович

## Цель
Рассчитать общую сумму командировочных расходов для каждого отдела на основе консолидации данных из трёх источников

## Источники данных
- employees.csv — данные о сотрудниках (employee_id, name, department)
- trips.xlsx — данные о командировках (employee_id, city, days)
- allowances.json — нормативы суточных расходов по городам (city, daily_allowance)



## ️ Архитектура

- **Docker Compose v2** для оркестрации контейнеров
- **Jupyter Lab** для анализа данных и визуализации
- **PostgreSQL 15** для хранения и обработки данных
- **Python** с библиотеками: pandas, numpy, matplotlib, seaborn, plotly

##  Требования

- Ubuntu 20+ 
- Docker и Docker Compose v2 (см. [dockerhelp.md](dockerhelp.md) для установки)
- Python 3.8+
- Свободные порты: 8888 (Jupyter), 5432 (PostgreSQL)

##  Запуск на Ubuntu 20+

### 1. Подготовка системы

```bash
# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Python и pip (если не установлены)
sudo apt install python3 python3-pip -y

# Установка библиотек для генерации данных
pip3 install pandas numpy openpyxl
```

**Установка Docker:** Если Docker не установлен, следуйте инструкциям в [dockerhelp.md](dockerhelp.md)

### 2. Клонирование проекта

```bash
git clone <repository-url>
cd pw_03
```

### 3. Генерация тестовых данных

```bash
python3 data_generator.py
```

**Если возникает ошибка с папкой 'data':**
```bash
# Создать папку вручную и повторить
mkdir -p data
chmod 755 data
python3 data_generator.py
```

### 4. Запуск Docker Compose

```bash
sudo docker compose up -d
```

Или используйте готовый скрипт:
```bash
chmod +x start.sh
./start.sh
```

### 5. Доступ к сервисам

- **Jupyter Lab**: http://loscalhost:8888 (без пароля)
- **PostgreSQL**: localhost:5432
  - База данных: `employees_analytics`
  - Пользователь: `analyst`
  - Пароль: `analyst123`

### 6. Выполнение анализа

1. Откройте браузер и перейдите на http://localhost:8888
2. Перейдите в папку `work/notebooks`
3. Откройте `employees_analysis.ipynb`
4. Выполните все ячейки последовательно (Shift+Enter)

##  Структура проекта

```
programmETL/
├── docker-compose.yml          # Конфигурация Docker Compose
├── Dockerfile                  # Образ Jupyter с библиотеками
├── data_generator.py          # Генератор тестовых данных
├── README.md                  # Документация
├── sql/
│   └── 01_init_schema.sql     # SQL схема для PostgreSQL
├── notebooks/
│   └── employees_analysis.ipynb # Основной анализ
└── data/
    ├── employees_companies.csv          # Данные авиакомпаний
    ├── trips.xlsx           # Данные рейсов
    └── expenses.json           # Данные билетов
```

##  Этапы анализа

1. **Загрузка данных** из CSV, Excel и JSON файлов
2. **Предварительная обработка** и аудит данных
3. **Очистка данных** и приведение к единому формату
4. **Консолидация данных** через JOIN операции
5. **Feature Engineering** - создание производных признаков
6. **Расчет выручки** и спроса для каждого города и тарифа
7. **Визуализация результатов** с помощью matplotlib, seaborn, plotly
8. **Формирование выводов** и рекомендаций

##  Визуализации

- Столбчатая диаграмма выручки по городам
- Круговая диаграмма долей тарифов
- Сравнительный анализ количества поездок и среднего чека
- Интерактивные графики с Plotly
- Тепловая карта активности заказов по часам и дням недели

## ️ База данных PostgreSQL

Автоматически создается схема с таблицами:
- `drivers` - авиакомпании
- `rides` - рейсы
- `customers` - билеты
- `employees_revenue` - представление для расчета выручки

##  Результаты

Все результаты сохраняются в папке `data/`:
- consolidated_employees_data.csv - консолидированные данные
- employees_revenue_summary.csv - итоговая выручка по городам и тарифам
- monthly_demand_analysis.csv - анализ спроса по месяцам

## ️ Управление контейнерами

```bash
# Запуск сервисов
sudo docker compose up -d

# Просмотр статуса
sudo docker compose ps

# Просмотр логов
sudo docker compose logs -f

# Остановка сервисов
sudo docker compose down

# Полная очистка (включая данные)
sudo docker compose down -v

# Пересборка образов
sudo docker compose build --no-cache
sudo docker compose up -d
```

##  Подключение к PostgreSQL

import psycopg2
import pandas as pd

# Параметры подключения
conn_params = {
    'host': 'localhost',
    'database': 'employees_analytics',
    'user': 'analyst',
    'password': 'analyst123',
    'port': 5432
}

# Подключение и выполнение запросов
conn = psycopg2.connect(**conn_params)
df = pd.read_sql("SELECT * FROM employees_revenue", conn)
```

##  Основные выводы

- Лидер рынка — «Эконом Такси» с общей прибылью 25,2 млн руб. Компания занимает 28,9% рынка — абсолютный лидер по прибыльности.

- Топ-3 по прибыли:
1 место: Эконом Такси — 25,2 млн руб.
2 место: Ночной Маршрут — 20,1 млн руб.
3 место: Такси Быстро — 16,3 млн руб.
Вместе они генерируют 66,6% всей прибыли рынка. 
- Наименее прибыльная компания — «Бизнес Такси». Прибыль: 11,7 млн руб. (13,4% рынка) — на 55% меньше, чем у лидера. 
- Средняя прибыль на компанию — ~17,4 млн руб. Только две компании («Эконом Такси» и «Ночной Маршрут») превышают этот показатель.
Прибыльность не всегда зависит от количества поездок. Например, «Такси Быстро» имеет высокую среднюю цену поездки (670 руб.), что компенсирует меньший объём поездок по сравнению с «Городской Такси».


##  Устранение неполадок

### Порт уже занят
```bash
# Найти процесс на порту 8888
sudo netstat -tulpn | grep :8888

# Остановить все Docker контейнеры
sudo docker stop $(sudo docker ps -aq)
```

### Проблемы с Docker
```bash
# Пересборка образов
sudo docker compose build --no-cache
sudo docker compose up -d

# Очистка Docker системы
sudo docker system prune -a
```

### Ошибки подключения к PostgreSQL
```bash
# Проверка статуса контейнера
sudo docker compose ps

# Просмотр логов PostgreSQL
sudo docker compose logs postgres

# Подключение к контейнеру PostgreSQL
sudo docker compose exec postgres psql -U analyst -d airline_analytics
```

##  Авторы

Практическая работа выполнена в рамках курса "Программные средства консолидации данных" МГПУ.

##  Лицензия

Проект создан в образовательных целях.

