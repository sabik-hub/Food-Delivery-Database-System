
/*=========================================================
            SECTION 7 : TRIGGER FUNCTIONS
=========================================================*/


/*---------------------------------------------------------
    FUNCTION 1 : CALCULATE SUBTOTAL

    Purpose:
    Automatically calculates subtotal
    based on quantity and food price
---------------------------------------------------------*/

CREATE OR REPLACE FUNCTION 
calculate_subtotal()

RETURNS TRIGGER

LANGUAGE plpgsql

AS $$

declare 
	v_price numeric;
	
BEGIN

	select price
	
	into v_price
	
	from fooditems
	
	where food_id = new.food_id;
	
    
	NEW.subtotal :=
		NEW.quantity * v_price;
		
	
    RETURN NEW;
	
END;

$$;


/*---------------------------------------------------------
    FUNCTION 2 : UPDATE ORDER TOTAL

    Purpose:
    Recalculates order total whenever
    order items are inserted, updated
    or deleted
---------------------------------------------------------*/
CREATE OR REPLACE FUNCTION
update_order_total()

RETURNS TRIGGER

LANGUAGE plpgsql

AS $$

declare 
	v_order_id int;
	
BEGIN
	v_order_id := COALESCE(
		new.order_id,
		old.order_id
	);
	
    
	UPDATE orders
    
	SET total_amount = (
        SELECT
		COALESCE(
			SUM(subtotal),
			0
		)
        
		FROM orderitems
        
		WHERE order_id = v_order_id
    )
	
    WHERE order_id = v_order_id;

    
	RETURN null;

END;

$$;


/*---------------------------------------------------------
    FUNCTION 3 : TRACK ORDER STATUS

    Purpose:
    Stores order status history
---------------------------------------------------------*/

CREATE OR REPLACE FUNCTION 
track_order_status()

RETURNS TRIGGER

LANGUAGE plpgsql

AS $$

BEGIN

    IF OLD.status
	IS DISTINCT FROM
	NEW.status
	
	THEN

        INSERT INTO
		order_status_history (
        
			order_id,
            old_status,
            new_status,
            changed_at
        )
		
        VALUES (
		
            OLD.order_id,
            OLD.status,
            NEW.status,
            NOW()
        );

    END IF;


    RETURN NEW;

END;

$$;


/*---------------------------------------------------------
    FUNCTION 4 : UPDATE PARTNER STATUS

    Purpose:
    Makes delivery partner available
    after order delivery
---------------------------------------------------------*/

CREATE OR REPLACE FUNCTION
update_partner_availability()

RETURNS TRIGGER

LANGUAGE plpgsql

AS $$

BEGIN

	IF NEW.status = 'delivered' 
	
	THEN
	
	    UPDATE 
		deliverypartners
	    SET
		availability_status = 'available'
	    
		WHERE
		partner_id = OLD.partner_id;
	
	END IF;
	
	RETURN NEW;

END;

$$;


/*---------------------------------------------------------
    FUNCTION 5 : UPDATE PAYMENT STATUS

    Purpose:
    Updates payment status based on
    delivery result
---------------------------------------------------------*/

CREATE OR REPLACE FUNCTION 
update_payment_status()

RETURNS TRIGGER

LANGUAGE plpgsql

AS $$

BEGIN

	IF NEW.status = 'delivered'
	
	THEN
	
	    UPDATE payments
	    
		SET payment_status = 'completed'
	    
		WHERE order_id = NEW.order_id;
	
	ELSIF NEW.status = 'cancelled' 
	
	THEN
	
	    UPDATE payments
	    
		SET payment_status = 'failed'
	    
		WHERE order_id = NEW.order_id;
	
	END IF;
	
	
	RETURN NEW;

END;

$$;



/*=========================================================
                SECTION 8 : TRIGGERS
=========================================================*/


/*---------------------------------------------------------
    Trigger : subtotal calculation
---------------------------------------------------------*/

CREATE TRIGGER trg_subtotal

BEFORE INSERT OR UPDATE

ON OrderItems

FOR EACH ROW

EXECUTE FUNCTION 
calculate_subtotal();


/*---------------------------------------------------------
    Trigger : Order Total Update
---------------------------------------------------------*/

CREATE TRIGGER trg_order_total

AFTER INSERT
OR UPDATE
OR DELETE

ON orderitems 

FOR EACH ROW

EXECUTE FUNCTION
update_order_total();


/*---------------------------------------------------------
    Trigger : Order Status Tracking
---------------------------------------------------------*/

CREATE TRIGGER 
trg_order_status_tracking

AFTER UPDATE OF status

ON orders

FOR EACH ROW

EXECUTE FUNCTION
track_order_status();


/*---------------------------------------------------------
    Trigger : Partner Availability
---------------------------------------------------------*/

CREATE TRIGGER
trg_partner_update

AFTER UPDATE OF status

ON orders

FOR EACH ROW

EXECUTE FUNCTION
update_partner_availability();


/*---------------------------------------------------------
    Trigger : Payment Status Update
---------------------------------------------------------*/

CREATE TRIGGER 
trg_payment_update

AFTER UPDATE OF status

ON orders

FOR EACH ROW

EXECUTE FUNCTION
update_payment_status();

