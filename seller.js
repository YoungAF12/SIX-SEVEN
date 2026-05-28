// seller.js

// Ждем, пока загрузится весь HTML
document.addEventListener('DOMContentLoaded', () => {
    
    const addProductForm = document.getElementById('addProductForm');

    if (addProductForm) {
        addProductForm.addEventListener('submit', function(event) {
            // Останавливаем стандартную перезагрузку страницы при отправке формы
            event.preventDefault();

            // Собираем данные из инпутов
            const newProduct = {
                title: document.getElementById('productName').value,
                type: document.getElementById('productType').value,
                hiddenData: document.getElementById('hiddenContent').value,
                price: parseFloat(document.getElementById('productPrice').value),
                createdAt: new Date().toISOString()
            };

            // Выводим результат в консоль браузера (F12)
            console.log("Новый товар готов к отправке в базу данных:", newProduct);

            // Визуальное подтверждение для пользователя
            alert(`Товар "${newProduct.title}" успешно создан за ${newProduct.price} ₽! (Данные в консоли)`);

            // Очищаем форму после успешного добавления
            addProductForm.reset();
        });
    }
});
