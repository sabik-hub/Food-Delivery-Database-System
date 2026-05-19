
/*=========================================================
        SECTION 13 : PERFORMANCE OPTIMIZATION
=========================================================*/


/*---------------------------------------------------------
    Create Performance Indexes
---------------------------------------------------------*/

CREATE INDEX idx_orders_customer
ON orders(customer_id);

CREATE INDEX idx_orders_partner
ON orders(partner_id);

CREATE INDEX idx_orders_status
ON orders(status);

CREATE INDEX idx_orderitems_order
ON orderitems(order_id);

CREATE INDEX idx_orderitems_food
ON orderitems(food_id);

CREATE INDEX idx_fooditems_restaurant
ON fooditems(restaurant_id);

CREATE INDEX idx_payments_order
ON payments(order_id);

CREATE INDEX idx_history_order
ON order_status_history(order_id);



/*---------------------------------------------------------
    Query Performance Testing
---------------------------------------------------------*/

EXPLAIN ANALYZE
SELECT
	d.name,
	COUNT(o.order_id)
FROM deliverypartners d

JOIN orders o
ON d.partner_id=o.partner_id

WHERE o.status='delivered'

GROUP BY d.name;

