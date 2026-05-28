// app.js
import { db } from './firebase-config.js';
import { collection, getDocs } from "https://www.gstatic.com/firebasejs/9.22.0/firebase-firestore.js";

async function loadProducts() {
    const grid = document.querySelector('.products-grid');
    const querySnapshot = await getDocs(collection(db, "products"));
    
    grid.innerHTML = ''; // Очищаем примеры
    
    querySnapshot.forEach((doc) => {
        const product = doc.data();
        grid.innerHTML += `
            <div class="product-card">
                <div class="product-image">IMG</div>
                <div class="product-title">${product.title}</div>
                <div class="card-bottom">
                    <div class="product-price">${product.price} ₽</div>
                    <button class="buy-btn" onclick="addToCart('${doc.id}', '${product.title}', ${product.price})">
                        В корзину
                    </button>
                </div>
            </div>
        `;
    });
}

loadProducts();
