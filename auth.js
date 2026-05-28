// auth.js

document.addEventListener('DOMContentLoaded', () => {

    // --- ЛОГИКА СТРАНИЦЫ ВХОДА ---
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        loginForm.addEventListener('submit', (e) => {
            e.preventDefault(); // Останавливаем перезагрузку
            
            const email = document.getElementById('loginEmail').value;
            const password = document.getElementById('loginPassword').value;

            console.log("Попытка входа:", { email, password });
            
            // Заглушка: имитация успешного входа
            alert(`Добро пожаловать, ${email}! Перенаправление на главную...`);
            window.location.href = 'index.html'; // Перекидываем на главную после "успешного" входа
        });
    }

    // --- ЛОГИКА СТРАНИЦЫ РЕГИСТРАЦИИ ---
    const registerForm = document.getElementById('registerForm');
    if (registerForm) {
        registerForm.addEventListener('submit', (e) => {
            e.preventDefault();

            const username = document.getElementById('regUsername').value;
            const email = document.getElementById('regEmail').value;
            const password = document.getElementById('regPassword').value;
            const confirmPassword = document.getElementById('regConfirmPassword').value;

            // Проверка: совпадают ли пароли?
            if (password !== confirmPassword) {
                alert("Ошибка: Пароли не совпадают!");
                return; // Останавливаем выполнение функции
            }

            console.log("Новый пользователь:", { username, email, password });

            // Заглушка: имитация успешной регистрации
            alert(`Аккаунт ${username} успешно создан! Теперь вы можете войти.`);
            window.location.href = 'login.html'; // Перекидываем на страницу входа
        });
    }

});
