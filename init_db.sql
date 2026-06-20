-- ==============================================================================
-- БАЗА ДАННЫХ ДЛЯ ФОТОСТУДИИ (PostgreSQL)
-- Спринт 1: Таблицы, связи, индексы, представления, хранимые функции
-- ==============================================================================

BEGIN; -- Запускаем транзакцию для безопасного создания схемы

-- 1. Таблица ролей (Администратор, Менеджер, Клиент)
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255)
);

-- Вставляем базовые роли
INSERT INTO roles (name, description) VALUES 
('admin', 'Администратор системы'),
('manager', 'Менеджер студии'),
('client', 'Клиент (заказчик)');

-- 2. Таблица пользователей
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    role_id INT REFERENCES roles(id) ON DELETE RESTRICT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL, -- Для хранения bcrypt хеша
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Таблица залов (помещений фотостудии)
CREATE TABLE halls (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    hourly_rate DECIMAL(10, 2) NOT NULL, -- Стоимость часа аренды
    area_sqm INT,                        -- Площадь зала (кв. м)
    is_active BOOLEAN DEFAULT TRUE       -- Доступен ли зал для брони
);

-- 4. Таблица оборудования (камеры, свет, фоны)
CREATE TABLE equipment (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    hourly_rate DECIMAL(10, 2) NOT NULL, -- Стоимость часа аренды единицы оборудования
    total_quantity INT NOT NULL DEFAULT 1 -- Общее количество в студии
);

-- 5. Таблица бронирований (Связывает пользователя и зал)
CREATE TABLE bookings (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    hall_id INT REFERENCES halls(id) ON DELETE RESTRICT,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    total_price DECIMAL(10, 2), -- Итоговая цена (рассчитывается функцией)
    status VARCHAR(20) DEFAULT 'pending', -- Статусы: pending, confirmed, cancelled
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_time_range CHECK (end_time > start_time) -- Проверка: конец позже начала
);

-- 6. Таблица связи "Бронирование - Оборудование" (Многие-ко-Многим)
CREATE TABLE booking_equipment (
    booking_id INT REFERENCES bookings(id) ON DELETE CASCADE,
    equipment_id INT REFERENCES equipment(id) ON DELETE CASCADE,
    quantity INT NOT NULL DEFAULT 1, -- Сколько единиц оборудования взяли
    PRIMARY KEY (booking_id, equipment_id)
);

-- ==============================================================================
-- ИНДЕКСЫ ДЛЯ ОПТИМИЗАЦИИ ЗАПРОСОВ (По требованию ТЗ)
-- ==============================================================================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_hall_id ON bookings(hall_id);
CREATE INDEX idx_bookings_time_range ON bookings(start_time, end_time);
CREATE INDEX idx_bookings_status ON bookings(status);

-- ==============================================================================
-- ПРЕДСТАВЛЕНИЯ (VIEWS)
-- ==============================================================================

-- Представление 1: «Активные бронирования» (Для дашборда администратора)
CREATE VIEW view_active_bookings AS
SELECT 
    b.id AS booking_id, 
    u.first_name || ' ' || COALESCE(u.last_name, '') AS client_name,
    u.phone AS client_phone,
    h.name AS hall_name, 
    b.start_time, 
    b.end_time, 
    b.status,
    b.total_price
FROM bookings b
JOIN users u ON b.user_id = u.id
JOIN halls h ON b.hall_id = h.id
WHERE b.status IN ('pending', 'confirmed') 
  AND b.end_time >= CURRENT_TIMESTAMP
ORDER BY b.start_time ASC;

-- Представление 2: «Отчёт по загрузке залов» (Аналитика выручки и часов)
CREATE VIEW view_halls_load_report AS
SELECT 
    h.name AS hall_name,
    COUNT(b.id) AS total_bookings_count,
    ROUND(SUM(EXTRACT(EPOCH FROM (b.end_time - b.start_time))/3600), 2) AS total_hours_booked,
    SUM(b.total_price) AS total_revenue
FROM halls h
LEFT JOIN bookings b ON h.id = b.hall_id AND b.status = 'confirmed'
GROUP BY h.id, h.name
ORDER BY total_revenue DESC NULLS LAST;

-- ==============================================================================
-- ХРАНИМАЯ ФУНКЦИЯ (PL/pgSQL)
-- Расчёт стоимости брони с учётом динамических скидок (скидка за долгую аренду)
-- ==============================================================================
CREATE OR REPLACE FUNCTION calculate_booking_cost(p_booking_id INT)
RETURNS DECIMAL AS $$
DECLARE
    v_hours DECIMAL;
    v_hall_rate DECIMAL;
    v_equipment_cost DECIMAL := 0;
    v_total DECIMAL;
    v_discount_multiplier DECIMAL := 1.0;
BEGIN
    -- 1. Получаем длительность в часах и ставку зала
    SELECT 
        EXTRACT(EPOCH FROM (end_time - start_time))/3600, 
        h.hourly_rate
    INTO v_hours, v_hall_rate
    FROM bookings b
    JOIN halls h ON b.hall_id = h.id
    WHERE b.id = p_booking_id;

    -- Если бронь не найдена, возвращаем 0
    IF v_hours IS NULL THEN
        RETURN 0;
    END IF;

    -- 2. Считаем стоимость доп. оборудования за час аренды
    SELECT COALESCE(SUM(e.hourly_rate * be.quantity), 0)
    INTO v_equipment_cost
    FROM booking_equipment be
    JOIN equipment e ON be.equipment_id = e.id
    WHERE be.booking_id = p_booking_id;

    -- 3. Базовая стоимость = (Цена зала + Цена оборудования) * Часы
    v_total := (v_hall_rate + v_equipment_cost) * v_hours;

    -- 4. Применяем бизнес-логику динамических скидок
    -- Если аренда от 8 часов - скидка 20%
    -- Если аренда от 4 часов - скидка 10%
    IF v_hours >= 8 THEN
        v_discount_multiplier := 0.8; 
    ELSIF v_hours >= 4 THEN
        v_discount_multiplier := 0.9; 
    END IF;

    -- 5. Возвращаем округленный результат
    RETURN ROUND(v_total * v_discount_multiplier, 2);
END;
$$ LANGUAGE plpgsql;

COMMIT; -- Успешно фиксируем изменения в БД
