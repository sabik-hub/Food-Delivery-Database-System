
/*=========================================================
            SECTION 9 : ANALYTICS LAYER
=========================================================*/


/*---------------------------------------------------------
    ANALYTICS 1 : MOST ACTIVE CUSTOMERS

    Purpose:
    Displays customers with highest
    number of orders
---------------------------------------------------------*/

select
	customer_id,
	count(*) total_orders
	
from orders

group by customer_id

order by total_orders desc;



/*---------------------------------------------------------
    ANALYTICS 2 : MOST ACTIVE DELIVERY PARTNERS

    Purpose:
    Displays partners with highest
    completed deliveries
---------------------------------------------------------*/

select
	d.name,
	count(o.order_id) Finished_orders
	
from deliverypartners d

join orders o 
on d.partner_id = o.partner_id

where o.status = 'delivered'

group by d.name

order by finished_orders desc;



/*---------------------------------------------------------
    ANALYTICS 3 : ORDER STATUS DISTRIBUTION

    Purpose:
    Shows count of each order status
---------------------------------------------------------*/

select
	status,
	count(*) counts

from orders

group by status

order by counts desc;



/*---------------------------------------------------------
    ANALYTICS 4 : PAYMENT SUCCESS RATE

    Purpose:
    Displays payment statistics
---------------------------------------------------------*/

select
	payment_status,
	count(*) counts 

from payments

group by payment_status

order by counts desc;



/*---------------------------------------------------------
    ANALYTICS 5 : DAILY SALES TREND

    Purpose:
    Displays daily revenue trend
---------------------------------------------------------*/

select
	date(order_date) as day,
	sum(total_amount) as revenue

from orders

group by date(order_date)

order by day;
