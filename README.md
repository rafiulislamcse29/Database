# Vehicle Rental System - SQL Queries

---

## 🎯 Objectives
- Design an ERD with 1:1, 1:Many, and Many:1 relationships
- Understand primary keys and foreign keys
- Write SQL queries using JOIN, EXISTS, and WHERE clauses
- Implement business logic through database constraints

---

---
## 📌 Project Overview
This database system manages:
- Users (Admins and Customers)
- Vehicles (Cars, Bikes, Trucks)
- Bookings (Rental transactions with start and end dates)

It ensures data integrity and enforces relationships between users, vehicles, and bookings.
---


## Part 2: SQL Queries

### CREATE DATABASE


### CREATE Users TABLE

```ts
create type user_role as enum ('Admin', 'Customer')
create table users(
    user_id serial PRIMARY key,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(250) UNIQUE NOT null,
    password VARCHAR(255),
    phone VARCHAR(20),
    role user_role NOT NULL
);
```

### INSERT Users

```ts
INSERT INTO Users (user_id, name, email, phone, role) VALUES
(1, 'Alice', 'alice@example.com', '1234567890', 'Customer'),
(2, 'Bob', 'bob@example.com', '0987654321', 'Admin'),
(3, 'Charlie', 'charlie@example.com', '1122334455', 'Customer');
```

### Users Table

| user_id | name    | email               | phone      | role     |
| :------ | :------ | :------------------ | :--------- | :------- |
| 1       | Alice   | alice@example.com   | 1234567890 | Customer |
| 2       | Bob     | bob@example.com     | 0987654321 | Admin    |
| 3       | Charlie | charlie@example.com | 1122334455 | Customer |

### CREATE Vehicles TABLE

```ts
create type vehicle_type as enum ('car', 'bike', 'truck');
create type vehicle_status as enum ('available', 'rented', 'maintenance');
create table vehicles(
    vehicle_id serial PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type vehicle_type NOT NULL,
    model VARCHAR(50),
    registration_number VARCHAR(250) UNIQUE NOT NULL,
    rental_price DECIMAL(10) NOT NULL check (rental_price > 0),
    availability_status vehicle_status NOT NULL
);
```

### INSERT Vehicles

```ts
INSERT INTO Vehicles (vehicle_id, name, type, model, registration_number, rental_price, status) VALUES
(1, 'Toyota Corolla', 'car', '2022', 'ABC-123', 50, 'available'),
(2, 'Honda Civic', 'car', '2021', 'DEF-456', 60, 'rented'),
(3, 'Yamaha R15', 'bike', '2023', 'GHI-789', 30, 'available'),
(4, 'Ford F-150', 'truck', '2020', 'JKL-012', 100, 'maintenance');
```


### Vehicles Table

| vehicle_id | name           | type  | model | registration_number | rental_price | status      |
| :--------- | :------------- | :---- | :---- | :------------------ | :----------- | :---------- |
| 1          | Toyota Corolla | car   | 2022  | ABC-123             | 50           | available   |
| 2          | Honda Civic    | car   | 2021  | DEF-456             | 60           | rented      |
| 3          | Yamaha R15     | bike  | 2023  | GHI-789             | 30           | available   |
| 4          | Ford F-150     | truck | 2020  | JKL-012             | 100          | maintenance |

### CREATE Bookings TABLE

```ts
create type booking_type as enum ('pending', 'confirmed', 'completed', 'cancelled');
create table bookings(
    booking_id serial PRIMARY key,
    user_id int not NULL,
    vehicle_id int not null,
    start_date DATE not null,
    end_date DATE not null,
    booking_status booking_type not null DEFAULT 'pending',
    total_cost DECIMAL(10) not null,
    constraint fk_booking_user FOREIGN KEY (user_id) REFERENCES users(user_id) on delete CASCADE,
    constraint fk_booking_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) on delete CASCADE,
    constraint fk_booking_dates check (end_date >= start_date)
);
```

### INSERT Bookings

```ts
INSERT INTO Bookings (booking_id, user_id, vehicle_id, start_date, end_date, status, total_cost) VALUES
(1, 1, 2, '2023-10-01', '2023-10-05', 'completed', 240),
(2, 1, 2, '2023-11-01', '2023-11-03', 'completed', 120),
(3, 3, 2, '2023-12-01', '2023-12-02', 'confirmed', 60),
(4, 1, 1, '2023-12-10', '2023-12-12', 'pending', 100);
```


### Bookings Table

| booking_id | user_id | vehicle_id | start_date | end_date   | status    | total_cost |
| :--------- | :------ | :--------- | :--------- | :--------- | :-------- | :--------- |
| 1          | 1       | 2          | 2023-10-01 | 2023-10-05 | completed | 240        |
| 2          | 1       | 2          | 2023-11-01 | 2023-11-03 | completed | 120        |
| 3          | 3       | 2          | 2023-12-01 | 2023-12-02 | confirmed | 60         |
| 4          | 1       | 1          | 2023-12-10 | 2023-12-12 | pending   | 100        |

---

## Expected Query Results

### Query 1: JOIN

**Requirement**: Retrieve booking information along with Customer name and Vehicle name.

```ts
select b.booking_id, u.name as customer_name, v.name as vehicle_name, b.start_date as start_date, b.end_date as end_date, b.status as status
from bookings b
inner join users u on b.user_id = u.user_id
inner join vehicles v on b.vehicle_id = v.vehicle_id
```

**Expected Output**:
| booking_id | customer_name | vehicle_name | start_date | end_date | status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Alice | Honda Civic | 2023-10-01 | 2023-10-05 | completed |
| 2 | Alice | Honda Civic | 2023-11-01 | 2023-11-03 | completed |
| 3 | Charlie | Honda Civic | 2023-12-01 | 2023-12-02 | confirmed |
| 4 | Alice | Toyota Corolla | 2023-12-10 | 2023-12-12 | pending |

---

### Query 2: EXISTS

**Requirement**: Find all vehicles that have never been booked.

```ts
SELECT *
FROM Vehicles v
WHERE NOT EXISTS (
    SELECT 1 
    FROM Bookings b 
    WHERE b.vehicle_id = v.vehicle_id
);
```

**Expected Output**:
| vehicle_id | name | type | model | registration_number | rental_price | status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 3 | Yamaha R15 | bike | 2023 | GHI-789 | 30 | available |
| 4 | Ford F-150 | truck | 2020 | JKL-012 | 100 | maintenance |

---

### Query 3: WHERE

**Requirement**: Retrieve all available vehicles of a specific type (e.g. cars).

```ts
select *
from vehicles
where type='car' and status ='available'
```

**Expected Output**:
| vehicle_id | name | type | model | registration_number | rental_price | status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Toyota Corolla | car | 2022 | ABC-123 | 50 | available |

---

### Query 4: GROUP BY and HAVING

**Requirement**: Find the total number of bookings for each vehicle and display only those vehicles that have more than 2 bookings.

```ts
select v.name as vehicle_name, count(*) as total_bookings
from vehicles v
inner join bookings b on v.vehicle_id= b.vehicle_id
GROUP BY v.vehicle_id
having  count(*) > 2;
```

**Expected Output**:
| vehicle_name | total_bookings |
| :--- | :--- |
| Honda Civic | 3 |

---
