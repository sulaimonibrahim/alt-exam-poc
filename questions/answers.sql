-- To answer this question, I am joining the events, orders, and products tables. This approach allows us to identify the product that has been ordered the most in successfully checked out orders. 
--First is inner-joining the products table with the events table using their maching id/key, then joining the events table with the orders.
SELECT 
p.id as product_id,
p.name as product_name,
COUNT(*) as num_times_in_successful_orders
FROM alt_school.events as e
join alt_school.products as p on e.event_data->>'item_id' = p.id::text
join alt_school.orders as o on e.customer_id = o.customer_id
WHERE e.event_data->>'event_type' = 'add_to_cart'
AND o.status = 'success'
group by p.id, p.name
order BY num_times_in_successful_orders desc
LIMIT 1;


-- To answer this question, firstly, i need location from the customers table, and price from the product table. These are then joined with the remaining tables based on their maching columns or key. 
SELECT 
o.customer_id,
c.location,
SUM(p.price) as total_spend
FROM alt_school.orders as o
JOIN alt_school.customers as c on o.customer_id = c.customer_id
JOIN alt_school.events as e on o.customer_id = e.customer_id
JOIN alt_school.products as p on (e.event_data->>'item_id')::TEXT = p.id::TEXT
WHERE o.status = 'success'
GROUP BY o.customer_id, c.location
ORDER BY total_spend DESC
LIMIT 5;


-- To get the most common country/location where the most common checkout occured, I considered the key event_type where it is checkout in the events table and where the status is success in the alt_school.order table. Coupled with the location column from the customer table.
select 
c.location,
COUNT(*) AS checkout_count
from alt_school.events as e
join alt_school.customers as c on e.customer_id = c.customer_id
join alt_school.orders as o on e.customer_id = o.customer_id
WHERE e.event_data->>'event_type' = 'checkout'
AND o.status = 'success'
group by c.location
order bycheckout_count desc
LIMIT 1;


-- I understand that abandonment in this case to be the act of adding and removing from carts in the event_type. In that case, I used the event timestamp of that clause as the abandonment timestamp.
SELECT 
e.customer_id,
COUNT(*) AS num_events
FROM alt_school.events AS e
JOIN (SELECT customer_id,
MAX(event_timestamp) AS abandonment_time
FROM alt_school.events
WHERE 
(event_data->>'event_type') in ('add_to_cart', 'remove_from_cart')
GROUP BY customer_id
) AS abandoned_carts ON e.customer_id = abandoned_carts.customer_id
WHERE (e.event_data->>'event_type') IN ('add_to_cart', 'remove_from_cart')
AND e.event_timestamp < abandoned_carts.abandonment_time
GROUP BY e.customer_id;


-- Here I used the event_type key from the events table where the event_type is visit, and the status is success from the orderS table. Joining both tables with the matching columns.
SELECT 
round(AVG(num_visits)::numeric, 2) AS average_visits
FROM (SELECT e.customer_id,COUNT(*) AS num_visits
FROM alt_school.events AS e
join 
alt_school.orders AS o ON e.customer_id = o.customer_id
WHERE e.event_data->>'event_type' = 'visit'
AND o.status = 'success'
group by
e.customer_id
) AS visit_counts;