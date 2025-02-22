# Детекция мошенничества и анализ транзакций в SQL

## 📌 Описание проекта
Этот проект предназначен для анализа транзакций клиентов с использованием SQL. Включает запросы для выявления аномалий, анализа тенденций и обнаружения потенциального мошенничества.

## 🔍 Функциональность

### 1. Общая сумма транзакций клиентов за последние 6 месяцев
Запрос вычисляет общую сумму транзакций каждого клиента за последние 6 месяцев.
```sql
SELECT
    customer_id, 
    SUM(amount)
FROM transactions
WHERE transaction_date >= (SELECT MAX(transaction_date) FROM transactions) - INTERVAL '6 months'
GROUP BY 1;
```

### 2. Топ-5 клиентов по количеству транзакций
Этот запрос определяет 5 клиентов с наибольшим количеством транзакций.
```sql
SELECT
    customer_id, 
    COUNT(transaction_id),
    RANK() OVER(ORDER BY COUNT(transaction_id) DESC) AS rnk
FROM transactions
GROUP BY 1
LIMIT 5;
```

### 3. Выявление клиентов с ростом транзакций на 20% и более (месяц к месяцу)
Этот запрос анализирует месячные изменения транзакционных сумм.
```sql
WITH cte AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', transaction_date) AS month,
        SUM(amount) AS total
    FROM transactions
    GROUP BY 1, 2
)
SELECT
    a.customer_id, a.month, a.total,
    (a.total - b.total) * 1.0 / b.total * 100 AS percentage
FROM cte a
INNER JOIN cte b ON a.customer_id = b.customer_id AND a.month = b.month + INTERVAL '1 month'
WHERE (a.total - b.total) * 1.0 / b.total * 100 > 20;
```

### 4. Средняя сумма кредитов клиентов
Этот запрос рассчитывает среднюю сумму кредитов, взятых клиентами.
```sql
SELECT
    customer_id, 
    AVG(loan_amount)
FROM loans
GROUP BY 1;
```

### 5. Обнаружение подозрительных транзакций (большие суммы за короткий период)
Этот запрос ищет случаи, когда клиент совершил две крупные транзакции в течение 1 дня.
```sql
WITH cte AS (
    SELECT
        customer_id, 
        loan_amount, 
        start_date, 
        LAG(start_date) OVER(PARTITION BY customer_id ORDER BY start_date) AS prev_transaction_date, 
        LAG(loan_amount) OVER(PARTITION BY customer_id ORDER BY start_date) AS prev_amount
    FROM loans
)
SELECT *
FROM cte
WHERE loan_amount > 50000 AND prev_amount > 50000
AND start_date - prev_transaction_date <= 1;
```

## 🚀 Как использовать
1. Разверните базу данных PostgreSQL.
2. Импортируйте данные о транзакциях и кредитах.
3. Запустите SQL-запросы для анализа и обнаружения аномалий.

## 📁 Структура данных

### Таблица `transactions`
| Поле             | Тип данных  | Описание                        |
|------------------|------------|---------------------------------|
| transaction_id   | SERIAL     | Уникальный идентификатор       |
| customer_id      | INT        | Идентификатор клиента          |
| transaction_date | TIMESTAMP  | Дата и время транзакции        |
| amount          | DECIMAL    | Сумма транзакции               |

### Таблица `loans`
| Поле         | Тип данных  | Описание                            |
|-------------|------------|------------------------------------|
| customer_id | INT        | Идентификатор клиента              |
| loan_type   | TEXT       | Тип кредита (личный, ипотечный)    |
| loan_amount | DECIMAL    | Сумма кредита                      |
| interest_rate | DECIMAL  | Процентная ставка                  |
| loan_term   | INT        | Срок кредита (в месяцах)           |
| start_date  | DATE       | Дата начала кредита                |

## 🛠 Требования
- PostgreSQL 12+
- SQL-запросы
- Набор данных о транзакциях и кредитах

## 📜 Лицензия
Свободное использование и модификация.

## ✉️ Контакты
Если у вас есть вопросы, пишите мне!

