// firebase-config.js
import { initializeApp } from "https://www.gstatic.com/firebasejs/9.22.0/firebase-app.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/9.22.0/firebase-firestore.js";

const firebaseConfig = {
    apiKey: "ТВОЙ_API_KEY",
    authDomain: "твой-проект.firebaseapp.com",
    projectId: "твой-проект",
    storageBucket: "твой-проект.appspot.com",
    messagingSenderId: "1234567890",
    appId: "1:1234567890:web:abcd1234"
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
