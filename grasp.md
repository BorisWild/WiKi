**GRASP** (General Responsibility Assignment Software Patterns) — это набор принципов для распределения обязанностей между классами и объектами в объектно-ориентированном программировании. Хотя JavaScript — язык **мультипарадигменный** (ООП + функциональный), эти принципы можно адаптировать. Разберем ключевые паттерны GRASP на примерах JS.

---

### **1. Creator (Создатель)**  
**Принцип:** Объект, который создает другой объект, должен иметь для этого логическое основание (например, содержит, агрегирует или владеет им).  
**Пример в JS:**  
```javascript
class ShoppingCart {
  constructor() {
    this.items = [];
  }

  addItem(product, quantity) {
    const item = new OrderItem(product, quantity); // Cart создаёт OrderItem
    this.items.push(item);
  }
}

class OrderItem {
  constructor(product, quantity) {
    this.product = product;
    this.quantity = quantity;
  }
}
```
**Ключевое:**  
- `ShoppingCart` создает `OrderItem`, так как управляет коллекцией товаров.

---

### **2. Information Expert (Информационный эксперт)**  
**Принцип:** Ответственность должна быть назначена объекту, который владеет необходимыми данными.  
**Пример:**  
```javascript
class User {
  constructor(name, email) {
    this.name = name;
    this.email = email;
  }

  // Эксперт по данным пользователя: валидация email
  validateEmail() {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(this.email);
  }
}

const user = new User("Alice", "alice@example.com");
console.log(user.validateEmail()); // true
```
**Ключевое:**  
- Класс `User` проверяет свой email, так как хранит эти данные.

---

### **3. Controller (Контроллер)**  
**Принцип:** Ответственность за обработку системных событий (например, HTTP-запросов) делегируется отдельному классу.  
**Пример (Express.js):**  
```javascript
// Контроллер для работы с пользователями
class UserController {
  static getUser(req, res) {
    const userId = req.params.id;
    // Логика получения пользователя из БД
    res.json({ id: userId, name: "Alice" });
  }

  static createUser(req, res) {
    const userData = req.body;
    // Логика сохранения пользователя
    res.status(201).json(userData);
  }
}

// Роуты Express
app.get("/users/:id", UserController.getUser);
app.post("/users", UserController.createUser);
```
**Ключевое:**  
- `UserController` обрабатывает запросы, изолируя логику от маршрутов.

---

### **4. Low Coupling (Слабая связанность)**  
**Принцип:** Минимизация зависимостей между классами/модулями.  
**Пример:**  
```javascript
// Модуль для работы с API
class ApiService {
  static fetchData(url) {
    return fetch(url).then((res) => res.json());
  }
}

// Модуль для отображения данных
class DataRenderer {
  static render(data) {
    console.log("Rendered data:", data);
  }
}

// Использование
ApiService.fetchData("https://api.example.com/data")
  .then(DataRenderer.render);
```
**Ключевое:**  
- `ApiService` и `DataRenderer` не зависят друг от друга — взаимодействие через интерфейс.

---

### **5. High Cohesion (Высокая связность)**  
**Принцип:** Класс/модуль должен решать одну задачу.  
**Пример:**  
```javascript
// Класс для математических операций
class MathUtils {
  static add(a, b) { return a + b; }
  static multiply(a, b) { return a * b; }
}

// Класс для форматирования строк
class StringFormatter {
  static capitalize(str) { return str.toUpperCase(); }
}
```
**Ключевое:**  
- Разделение математики и форматирования строк для ясности.

---

### **6. Polymorphism (Полиморфизм)**  
**Принцип:** Использование интерфейсов для обработки разных типов объектов.  
**Пример:**  
```javascript
class PaymentMethod {
  pay(amount) {
    throw new Error("Метод pay должен быть реализован");
  }
}

class CreditCard extends PaymentMethod {
  pay(amount) {
    console.log(`Оплата ${amount} кредитной картой`);
  }
}

class PayPal extends PaymentMethod {
  pay(amount) {
    console.log(`Оплата ${amount} через PayPal`);
  }
}

// Общая обработка платежей
function processPayment(paymentMethod, amount) {
  paymentMethod.pay(amount);
}

const card = new CreditCard();
const paypal = new PayPal();

processPayment(card, 100);   // "Оплата 100 кредитной картой"
processPayment(paypal, 50); // "Оплата 50 через PayPal"
```
**Ключевое:**  
- Разные классы реализуют метод `pay`, но вызываются через общий интерфейс.

---

### **7. Pure Fabrication (Чистая выдумка)**  
**Принцип:** Создание искусственных классов для решения технических задач (например, логирование).  
**Пример:**  
```javascript
class Logger {
  static log(message) {
    console.log(`[LOG]: ${message}`);
  }

  static error(message) {
    console.error(`[ERROR]: ${message}`);
  }
}

// Использование в других классах
class UserService {
  saveUser(user) {
    try {
      // Логика сохранения
      Logger.log("User saved");
    } catch (e) {
      Logger.error(e.message);
    }
  }
}
```
**Ключевое:**  
- `Logger` не имеет отношения к бизнес-логике, но помогает в технических аспектах.

---

### **8. Indirection (Посредник)**  
**Принцип:** Использование промежуточного объекта для снижения связанности.  
**Пример (Event Bus):**  
```javascript
class EventBus {
  constructor() {
    this.listeners = {};
  }

  on(event, callback) {
    if (!this.listeners[event]) this.listeners[event] = [];
    this.listeners[event].push(callback);
  }

  emit(event, data) {
    if (this.listeners[event]) {
      this.listeners[event].forEach((callback) => callback(data));
    }
  }
}

// Компоненты взаимодействуют через EventBus, а не напрямую
const bus = new EventBus();

bus.on("userCreated", (user) => {
  console.log("Отправка приветственного письма:", user.email);
});

// Где-то в другом месте
bus.emit("userCreated", { email: "alice@example.com" });
```
**Ключевое:**  
- `EventBus` уменьшает прямые зависимости между компонентами.

---

### **Итог: GRASP в JavaScript**  
- **Гибкость JS** позволяет применять GRASP через классы, модули, функции и паттерны.  
- **Акцент на SOLID+GRASP** помогает создавать поддерживаемый код даже в прототипном стиле.  
- **Примеры использования:**  
  - Контроллеры в Express.  
  - Сервисы для бизнес-логики.  
  - Утилиты для технических задач (Logger, EventBus).  

GRASP в JavaScript — это не строгие правила, а рекомендации для улучшения архитектуры, особенно в крупных проектах.
