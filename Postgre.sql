-- Таблица пользователей (покупатели и продавцы)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(20) DEFAULT 'buyer', -- 'buyer', 'seller', 'admin'
    balance DECIMAL(10, 2) DEFAULT 0.00, -- Внутренние баллы/деньги
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица товаров
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    seller_id INT REFERENCES users(id),
    title VARCHAR(100) NOT NULL,
    description TEXT,
    product_type VARCHAR(50), -- 'key', 'account', 'software'
    hidden_content TEXT NOT NULL, -- То, что выдается после оплаты (сам ключ или ссылка)
    price DECIMAL(10, 2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- Таблица заказов (с системой Escrow / Заморозки)
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    buyer_id INT REFERENCES users(id),
    product_id INT REFERENCES products(id),
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'paid_frozen', 'completed', 'refunded'
    sbp_qr_code_url TEXT, -- Ссылка на сгенерированный QR код СБП
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
