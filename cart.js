// cart.js

// Загружаем корзину из памяти браузера или создаем пустой массив
let cart = JSON.parse(localStorage.getItem('nexus_cart')) || [];

// Функция добавления товара
function addToCart(id, title, price) {
    // Проверяем, есть ли уже товар в корзине (чтобы не купить два одинаковых ключа)
    const existingItem = cart.find(item => item.id === id);
    if (existingItem) {
        alert('Этот товар уже добавлен в корзину!');
        return;
    }

    // Добавляем новый товар
    cart.push({ id, title, price });
    saveCart();
    updateCartUI();
    
    // Анимация плавающей кнопки корзины
    const cartBtn = document.getElementById('cartBtn');
    if (cartBtn) {
        cartBtn.style.transform = 'scale(1.2)';
        setTimeout(() => cartBtn.style.transform = 'scale(1)', 200);
    }
}

// Функция сохранения в localStorage
function saveCart() {
    localStorage.setItem('nexus_cart', JSON.stringify(cart));
}

// Функция обновления счетчика на всех страницах
function updateCartUI() {
    const cartCountElement = document.getElementById('cartCount');
    if (cartCountElement) {
        cartCountElement.textContent = cart.length;
        // Если товаров 0, прячем красный кружок
        cartCountElement.style.display = cart.length > 0 ? 'flex' : 'none';
    }
}

// Функция очистки корзины (понадобится после оплаты)
function clearCart() {
    cart = [];
    saveCart();
    updateCartUI();
}

// Запускаем обновление интерфейса при загрузке страницы
document.addEventListener('DOMContentLoaded', () => {
    updateCartUI();
    
    // Клик по плавающей корзине перенаправляет на оформление заказа
    const cartBtn = document.getElementById('cartBtn');
    if (cartBtn) {
        cartBtn.addEventListener('click', () => {
            if (cart.length === 0) {
                alert('Сначала добавьте товары в корзину!');
            } else {
                window.location.href = 'checkout.html';
            }
        });
    }
});
