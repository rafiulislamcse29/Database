-- Query 1: JOIN
-- Requirement: Retrieve booking information along with Customer name and Vehicle name.
select b.booking_id, u.name as customer_name, v.name as vehicle_name, b.start_date as start_date, b.end_date as end_date, b.status as status
from bookings b
inner join users u on b.user_id = u.user_id
inner join vehicles v on b.vehicle_id = v.vehicle_id

  
-- Query 2: EXISTS
-- Requirement: Find all vehicles that have never been booked.
SELECT *
FROM Vehicles v
WHERE NOT EXISTS (
    SELECT 1 
    FROM Bookings b 
    WHERE b.vehicle_id = v.vehicle_id
);


-- Query 3: WHERE
-- Requirement: Retrieve all available vehicles of a specific type (e.g. cars).
select *
from vehicles
where type='car' and status ='available'


-- Query 4: GROUP BY and HAVING
-- Requirement: Find the total number of bookings for each vehicle and display only those vehicles that have more than 2 bookings.
select v.name as vehicle_name, count(*) as total_bookings
from vehicles v
inner join bookings b on v.vehicle_id= b.vehicle_id
GROUP BY v.vehicle_id
having  count(*) > 2;
