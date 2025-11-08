-- Схема для варианта 25: Службы такси, Поездки, Расходы

-- Таблица служб такси
CREATE TABLE IF NOT EXISTS taxi_companies (
    taxi_company_id SERIAL PRIMARY KEY,
    company_code VARCHAR(20) UNIQUE,
    company_name VARCHAR(150) NOT NULL,
    country VARCHAR(50),
    founded_year INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица агрегированных поездок (может быть по дням/месяцам)
CREATE TABLE IF NOT EXISTS trips (
    trip_id SERIAL PRIMARY KEY,
    taxi_company_id INTEGER REFERENCES taxi_companies(taxi_company_id),
    period_date DATE, -- период (например дата или начало периода)
    trips_count INTEGER CHECK (trips_count >= 0),
    avg_trip_price DECIMAL(10,2) CHECK (avg_trip_price >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица расходов
CREATE TABLE IF NOT EXISTS expenses (
    expense_id SERIAL PRIMARY KEY,
    taxi_company_id INTEGER REFERENCES taxi_companies(taxi_company_id),
    period_date DATE,
    fuel_cost DECIMAL(12,2) DEFAULT 0 CHECK (fuel_cost >= 0),
    maintenance_cost DECIMAL(12,2) DEFAULT 0 CHECK (maintenance_cost >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_trips_taxi_company ON trips(taxi_company_id);
CREATE INDEX IF NOT EXISTS idx_expenses_taxi_company ON expenses(taxi_company_id);
CREATE INDEX IF NOT EXISTS idx_trips_period ON trips(period_date);
CREATE INDEX IF NOT EXISTS idx_expenses_period ON expenses(period_date);

-- Представление для расчёта прибыли (aggr по компании и периоду)
CREATE OR REPLACE VIEW taxi_profit AS
SELECT
    tc.taxi_company_id,
    tc.company_name,
    COALESCE(t.period_date, e.period_date) AS period_date,
    COALESCE(SUM(t.trips_count), 0) AS total_trips,
    CASE WHEN COALESCE(SUM(t.trips_count),0) = 0 THEN 0
         ELSE ROUND(SUM(t.trips_count * t.avg_trip_price)::numeric, 2) END AS revenue,
    ROUND(COALESCE(SUM(e.fuel_cost),0) + COALESCE(SUM(e.maintenance_cost),0), 2) AS expenses,
    ROUND(COALESCE(SUM(t.trips_count * t.avg_trip_price),0) - (COALESCE(SUM(e.fuel_cost),0) + COALESCE(SUM(e.maintenance_cost),0)), 2) AS net_profit
FROM taxi_companies tc
LEFT JOIN trips t ON tc.taxi_company_id = t.taxi_company_id
LEFT JOIN expenses e ON tc.taxi_company_id = e.taxi_company_id
-- группируем по компании и периоду (если нужны суммарные по всем периодам — можно агрегировать отдельно)
GROUP BY tc.taxi_company_id, tc.company_name, COALESCE(t.period_date, e.period_date)
ORDER BY net_profit DESC NULLS LAST;
