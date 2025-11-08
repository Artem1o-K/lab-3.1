""" Генератор тестовых данных для варианта 10: Командировочные расходы по отделам """
import pandas as pd
import numpy as np
import json
import os
import random

np.random.seed(42)
random.seed(42)

def generate_employees_data():
    """Сотрудники: employee_id, name, department"""
    departments = ["IT", "HR", "Finance", "Marketing", "Sales", "Logistics", "R&D"]
    employees = []
    for i in range(1, 51):  # 50 сотрудников
        employees.append({
            "employee_id": f"E{i:03d}",
            "name": f"Сотрудник {i}",
            "department": random.choice(departments)
        })
    df = pd.DataFrame(employees)
    df.to_csv('data/employees.csv', index=False, encoding='utf-8')
    print("✓ Файл employees.csv создан")
    return employees

def generate_trips_data(employees):
    """Командировки: employee_id, city, days"""
    cities = ["Москва", "Санкт-Петербург", "Казань", "Екатеринбург", "Новосибирск", "Сочи", "Владивосток"]
    trips = []
    for i in range(200):  # 200 командировок
        emp = random.choice(employees)
        city = random.choice(cities)
        days = random.randint(1, 14)
        trips.append({
            "employee_id": emp["employee_id"],
            "city": city,
            "days": days
        })
    df = pd.DataFrame(trips)
    df.to_excel('data/trips.xlsx', index=False)
    print("✓ Файл trips.xlsx создан")
    return trips

def generate_allowances_data():
    """Нормативы: city, daily_allowance"""
    allowances = [
        {"city": "Москва", "daily_allowance": 1000},
        {"city": "Санкт-Петербург", "daily_allowance": 900},
        {"city": "Казань", "daily_allowance": 800},
        {"city": "Екатеринбург", "daily_allowance": 850},
        {"city": "Новосибирск", "daily_allowance": 750},
        {"city": "Сочи", "daily_allowance": 1200},
        {"city": "Владивосток", "daily_allowance": 1100}
    ]
    with open('data/allowances.json', 'w', encoding='utf-8') as f:
        json.dump(allowances, f, ensure_ascii=False, indent=2)
    print("✓ Файл allowances.json создан")
    return allowances

def main():
    print("Генерация тестовых данных по командировкам...")
    print("=" * 50)
    if not os.path.exists('data'):
        os.makedirs('data')
        print("✓ Создана папка 'data'")
    
    employees = generate_employees_data()
    trips = generate_trips_data(employees)
    allowances = generate_allowances_data()
    
    print("=" * 50)
    print(f"Сгенерировано:")
    print(f"- Сотрудников: {len(employees)}")
    print(f"- Командировок: {len(trips)}")
    print(f"- Городов с нормативами: {len(allowances)}")
    print("\nВсе файлы сохранены в папке 'data/'")

if __name__ == "__main__":
    main()