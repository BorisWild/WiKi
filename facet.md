Фасетный поиск (или фасетная навигация) — это метод фильтрации данных по нескольким независимым критериям (фасетам), позволяющий пользователям уточнять результаты поиска.

Примеры использования: интернет-магазины (фильтрация товаров по бренду, цене, категории), каталоги и т.д.

### Пример реализации в PostgreSQL
Допустим, у нас есть таблица `products`:

```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    brand VARCHAR(50),
    category VARCHAR(50),
    price NUMERIC
);

INSERT INTO products (name, brand, category, price) VALUES
('Phone X', 'Brand A', 'Electronics', 599),
('Phone Y', 'Brand B', 'Electronics', 399),
('Tablet Z', 'Brand A', 'Electronics', 299),
('Laptop', 'Brand C', 'Electronics', 999),
('Headphones', 'Brand B', 'Accessories', 99);
```

**Запрос для фасетного поиска** (фильтрует товары дешевле 1000 и возвращает фасеты по бренду, категории и ценовым диапазонам):

```sql
WITH filtered_products AS (
    SELECT * 
    FROM products 
    WHERE price < 1000 -- Общий фильтр
)
SELECT 
    -- Фасет по брендам
    (SELECT json_agg(json_build_object('brand', brand, 'count', count))
     FROM (
        SELECT brand, COUNT(*) AS count 
        FROM filtered_products 
        GROUP BY brand
     ) AS brands) AS brands_facet,
    
    -- Фасет по категориям
    (SELECT json_agg(json_build_object('category', category, 'count', count))
     FROM (
        SELECT category, COUNT(*) AS count 
        FROM filtered_products 
        GROUP BY category
     ) AS categories) AS categories_facet,
    
    -- Фасет по ценовым диапазонам
    (SELECT json_agg(json_build_object('price_range', price_range, 'count', count))
     FROM (
        SELECT 
            CASE
                WHEN price < 300 THEN '0-299'
                WHEN price BETWEEN 300 AND 600 THEN '300-600'
                ELSE '600+'
            END AS price_range,
            COUNT(*) AS count
        FROM filtered_products 
        GROUP BY price_range
     ) AS prices) AS price_facet;
```

**Результат** (в виде JSON):
```json
{
  "brands_facet": [
    {"brand": "Brand A", "count": 2},
    {"brand": "Brand B", "count": 2},
    {"brand": "Brand C", "count": 1}
  ],
  "categories_facet": [
    {"category": "Electronics", "count": 4},
    {"category": "Accessories", "count": 1}
  ],
  "price_facet": [
    {"price_range": "0-299", "count": 2},
    {"price_range": "300-600", "count": 2},
    {"price_range": "600+", "count": 1}
  ]
}
```

### Как это работает:
1. **CTE `filtered_products`** применяет общие условия фильтрации (например, `price < 1000`).
2. **Подзапросы** внутри `SELECT` группируют данные по брендам, категориям и ценовым диапазонам, используя отфильтрованные данные.
3. **Функции `json_agg` и `json_build_object`** форматируют результат в JSON для удобства обработки.

Этот подход позволяет централизованно управлять фильтрацией и легко добавлять новые фасеты.