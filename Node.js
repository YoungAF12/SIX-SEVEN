const express = require('express');
const app = express();
app.use(express.json());

// Имитация создания заказа и генерации QR-кода СБП
app.post('/api/orders/create', async (req, res) => {
    const { buyer_id, product_id, price } = req.body;
    
    // В реальности здесь запрос к API банка (например, ЮKassa или Тинькофф) для СБП
    const mockupQrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=SBP_PAYMENT_MOCKUP_${Date.now()}`;
    
    // Логика сохранения в БД со статусом 'pending'
    const order = { id: 1, buyer_id, product_id, amount: price, status: 'pending', qr: mockupQrUrl };
    
    res.json({ message: "Заказ создан, ожидайте оплату", order });
});

// Имитация вебхука от банка об успешной оплате
app.post('/api/payments/webhook', async (req, res) => {
    const { order_id, payment_status } = req.body;

    if (payment_status === 'success') {
        // 1. Меняем статус заказа на 'paid_frozen' (деньги удержаны сайтом)
        // 2. Пытаемся отправить товар на email покупателя (используя nodemailer)
        const itemDelivered = simulateEmailDelivery(); 

        if (itemDelivered) {
            // Товар выдан: переводим деньги продавцу
            // UPDATE orders SET status = 'completed' WHERE id = order_id;
            // UPDATE users SET balance = balance + order.amount WHERE id = seller_id;
            res.json({ status: 'completed', message: "Товар выдан, деньги зачислены продавцу" });
        } else {
            // Ошибка выдачи товара: деньги остаются замороженными
            // UPDATE orders SET status = 'paid_frozen' WHERE id = order_id;
            res.json({ status: 'frozen', message: "Ошибка выдачи товара. Деньги заморожены. Обратитесь в поддержку." });
        }
    }
});

function simulateEmailDelivery() {
    // В реальности здесь логика отправки скрытого содержимого (hidden_content) на email
    return Math.random() > 0.2; // 80% шанс успешной доставки
}
