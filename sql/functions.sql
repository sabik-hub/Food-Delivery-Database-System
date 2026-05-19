
/*=========================================================
            SECTION 11 : UTILITY FUNCTIONS
=========================================================*/


/*---------------------------------------------------------
    FUNCTION : GET TOTAL ORDER AMOUNT

    Purpose:
    Returns total amount for order
---------------------------------------------------------*/

create or replace function 
get_total_order_amount(
	p_order_id int
)

returns numeric

LANGUAGE plpgsql

As $$

Declare
	v_total numeric;

BEGIN

	select total_amount 
	into v_total
	
	from orders
	
	where order_id = p_order_id;

	return v_total;

end;

$$;


/*---------------------------------------------------------
    Function Execution
---------------------------------------------------------*/

select 
get_total_order_amount(
	100001
);



/*---------------------------------------------------------
    FUNCTION : CUSTOMER ORDER COUNT

    Purpose:
    Returns total orders for customer
---------------------------------------------------------*/

create or replace function
customer_order_count(
	p_customer_id int
)

returns int

LANGUAGE plpgsql

As $$

Declare
	v_count int;

BEGIN

	select count(*)
	into v_count
	
	from orders
	
	where customer_id = p_customer_id;

	return v_count;

end;

$$;


/*---------------------------------------------------------
    Function Execution
---------------------------------------------------------*/

select
customer_order_count(
	1006
);



/*=========================================================
            SECTION 12 : WORKFLOW SIMULATION
=========================================================*/

Do $$ 

DECLARE 
	v_order_id int;
	
BEGIN

-- parameters (customer_Id,v_order_id)
	call place_order(1006,v_order_id);
	-- RAISE NOTICE 'Order ID: %', v_order_id;
=
-- Parameters (order_id,food_id,quantity)
	call add_order_item(v_order_id,3001,2);


-- parameter (order_id)
	call assign_partner(v_order_id);


-- Parameters (order_id,payment_method)
	call process_payment(v_order_id,'upi');


-- restaurant starts cooking
	CALL update_order_status(
    	v_order_id,
    'preparing'
	);

-- rider picked up order
	CALL update_order_status(
    	v_order_id,
    	'out_for_delivery'
	);

-- order delivered
	CALL update_order_status(
    	v_order_id,
    	'delivered'
	);


end $$;

