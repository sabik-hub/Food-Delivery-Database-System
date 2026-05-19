

/*=========================================================
            SECTION 6 : BUSINESS LOGIC LAYER
=========================================================*/



/*---------------------------------------------------------
    MODULE 1 : ORDER SERVICE

    Purpose:
    Creates new order and returns order id
---------------------------------------------------------*/

CREATE OR REPLACE PROCEDURE place_order(
	p_customer_id int,
	inout v_order_id int
)

LANGUAGE plpgsql

AS $$

BEGIN

	insert into orders(
		customer_id
	)
	
	values(
		p_customer_id
	)
	
	RETURNING order_id
	into v_order_id;

END;

$$;


/*---------------------------------------------------------
    MODULE 2 : ORDER ITEM SERVICE

    Purpose:
    Adds food items into customer orders
---------------------------------------------------------*/

create or replace procedure add_order_item(
	p_order_id int,
	p_food_id int,
	p_quantity int
)

LANGUAGE plpgsql

AS $$

BEGIN 

	insert into orderitems(
		order_id,
		food_id,
		quantity
	)
	values (
		p_order_id,
		p_food_id,
		p_quantity
	);

END;

$$;


/*---------------------------------------------------------
    MODULE 3 : DELIVERY SERVICE

    Purpose:
    Automatically assigns available
    delivery partners to orders
---------------------------------------------------------*/

create or replace procedure assign_partner(
	p_order_id int
)

LANGUAGE plpgsql

AS $$

DECLARE 
	v_partner_id int;

BEGIN

	select partner_id 
	
	into v_partner_id
	
	from deliverypartners
	
	where availability_status = 'available'
	
	order by partner_id
	
	limit 1;

	if v_partner_id is null then 
	
		raise exception
		'No delivery partner avalilable';
	
	end if;
	
	
	update orders
	
	set partner_id = v_partner_id
	
	where order_id = p_order_id;

	
	update deliverypartners
	
	set availability_status = 'busy'
	
	where partner_id = v_partner_id;

END;

$$;


/*---------------------------------------------------------
    MODULE 4 : PAYMENT SERVICE

    Purpose:
    Creates payment record based on
    order total amount
---------------------------------------------------------*/

create or replace procedure process_payment(
	p_order_id int,
	p_method text
)

LANGUAGE plpgsql

AS $$

Declare
	v_amount numeric;
	
BEGIN

	select total_amount

	into v_amount
	
	from orders
	
	where order_id = p_order_id;

	
	Insert into payments(
		order_id,
		amount,
		payment_method,
		payment_status,
		payment_date
	)
	
	values(
		p_order_id,
		v_amount,
		p_method,
		'pending',
		now()
	);

END;

$$;


/*---------------------------------------------------------
    MODULE 5 : ORDER STATUS SERVICE

    Purpose:
    Updates order status during
    delivery workflow
---------------------------------------------------------*/

create or replace PROCEDURE update_order_status(
	p_order_id int, 
	p_status text
)

LANGUAGE plpgsql
As $$

BEGIN

	update orders
	
	set status = p_status
	
	where order_id = p_order_id;

end;

$$;

