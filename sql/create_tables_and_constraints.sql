
/*=========================================================
            SECTION 2 : ENTITY CREATION
            Create Required Tables
=========================================================*/


/*---------------------------------------------------------
    CUSTOMER TABLE
---------------------------------------------------------*/

create table Customers(
	customer_id serial primary key,
	name varchar(50) not null,
	email varchar(50) unique not null,
	phone varchar(50) unique,
	password varchar(16) not null,
	address varchar(100) not null,
	created_at timestamp default now()
);


/*---------------------------------------------------------
    DELIVERY PARTNER TABLE
---------------------------------------------------------*/

create table DeliveryPartners(
	partner_id serial primary key,
	name varchar(100) not null,
	phone varchar(50) not null,
	vehicle_type varchar(50) not null,
	
	availability_status varchar(50) 
	default 'available'
	
);


/*---------------------------------------------------------
    RESTAURANT TABLE
---------------------------------------------------------*/

create table Restaurants(
	restaurant_id serial primary key,
	
	restaurant_name varchar(100)
	not null,
	
	location varchar(100)
	not null,
	
	phone varchar(50)
	not null,
	
	rating decimal(10,2)
	default 0,
	
	opening_time time not null,
	closing_time time not null
);


/*---------------------------------------------------------
    FOOD ITEMS TABLE
---------------------------------------------------------*/

create table FoodItems(
	food_id serial primary key,
	
	restaurant_id int,
	
	food_name varchar(100)
	not null,
	
	category varchar(100)
	not null,
	
	price decimal(10,2)
	not null
	check(price >0),
	
	availability boolean
	default True,

	constraint fk_restaurant_id
	FOREIGN key (restaurant_id)
	REFERENCES restaurants(restaurant_id)
);


/*---------------------------------------------------------
    ORDERS TABLE
---------------------------------------------------------*/

create table Orders(
	order_id serial primary key,
	
	customer_id int,
	
	partner_id int,
	
	order_date timestamp
	default now(),
	
	total_amount decimal(10,2)
	default 0
	not null
	check(total_amount >=0),
	
	status varchar(20)
	default 'placed'
	
	check(
		status in(
			'placed',
			'preparing',
			'out_for_delivery',
			'delivered',
			'cancelled'
		)
	),

	constraint fk_customer_id
	FOREIGN key (customer_id)
	REFERENCES customers(customer_id),
		
	CONSTRAINT fk_partner_id
	FOREIGN key (partner_id)
	REFERENCES DeliveryPartners(partner_id)

);


/*---------------------------------------------------------
    ORDER ITEMS TABLE
---------------------------------------------------------*/

create table OrderItems(
	order_item_id serial primary key,
	
	order_id int,
	
	food_id int,
	
	quantity int 
	default 0
	not null
	check(quantity>0),
	
	subtotal decimal(10,2)
	default 0
	not null
	check (subtotal >0),

	constraint fk_order_id
	FOREIGN key (order_id)
	REFERENCES orders(order_id),
	
	constraint fk_food_id
	FOREIGN key (food_id)
	REFERENCES fooditems(food_id)
);


/*---------------------------------------------------------
    PAYMENTS TABLE
---------------------------------------------------------*/

create table Payments(
	payment_id serial primary key,
	
	order_id int,
	
	amount decimal
	not null
	check(amount>0),
	
	payment_method varchar(50)
	not null,
	
	payment_status varchar(50)
	default 'pending'
	
	CHECK(
		payment_status IN(
			'pending',
			'completed',
			'failed',
			'refunded'
		)
	),
	
	payment_date timestamp
	default now(),

	constraint fk_order_id
	FOREIGN key (order_id)
	REFERENCES orders(order_id)
);


/*---------------------------------------------------------
    ORDER STATUS HISTORY TABLE
---------------------------------------------------------*/

create table order_status_history(
	history_id serial primary key,
	
	order_id int not null
	REFERENCES orders(order_id),
	
	old_status text not null,
	
	new_status text not null,
	
	changed_at timestamptz
	default now()
);

