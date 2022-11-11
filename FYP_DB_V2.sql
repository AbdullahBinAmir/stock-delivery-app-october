--create database Backend_FYP_DB

--use Backend_FYP_DB

create table UserAccount (
	id int not null identity(1,1) primary key,
	name varchar(30),
	city varchar(30),
	address varchar(100),
	mobile_no varchar(15),
	email varchar(100),
	password varchar(20),
	image varchar(100),
	roles varchar(30),
	account_status varchar(30)
)

create table UserAuthentication(
	id int not null identity(1,1) primary key,
	user_id int ,--foreign key references UserAccount(id),
	approval_date varchar(30),
	action varchar(50) -- Allow / Block
)


create table VendorProduct(
	id int not null identity(1,1) primary key,
	name varchar(30),
	description varchar(150),
	qty_in_carton int,
	total_cartons int,
	--warranty_months int,
	saleprice_per_carton int,
	category varchar(50),
	company_name varchar(100),
	threshold int,
	image varchar(200),
	vendor_id int ,--foreign key references UserAccount(id)
)

create table batch_production(
	batch_no int not null identity(1,1) primary key,
	no_of_cartons int,
	mfg_date varchar(25),
	expiry_date varchar(25),
	vendor_productid int ,--foreign key references VendorProduct(id)
)

create table VendorDistributor (
	id int not null identity(1,1) primary key,
	distributor_status varchar(50),
	security_amount int,
	vendor_id int ,--foreign key references UserAccount(id),
	distributor_id int ,--foreign key references UserAccount(id)
)

create table UserOrder(
	id int not null identity(1,1) primary key,
	order_status varchar(25), -- pending / active / on the way / delivered
	order_type varchar(25), -- cash / credit
	order_state int,  -- 0 / 1
	total_amount int,
	order_place_date varchar(30),
	order_deliver_date varchar(30),
	seller_id int ,--foreign key references UserAccount(id), -- vendor / distributor
	buyer_id int ,--foreign key references UserAccount(id) -- distribuor / shopkeeper
)

insert into UserOrder values ('delivered','credit',0,1000,'10/12/2022','10/18/2022',1,2)
select * from UserOrder
truncate table UserOrder

create table OrderDetail(
	 id int not null identity(1,1) primary key,
	 order_id int ,--foreign key references UserOrder(id),
	 qty_ordred int,
	 batch_no int ,--foreign key references batch_production(batch_no),
	 product_id int,  -- vendor products / distributor products
)


create table Payment(
	id int not null identity(1,1) primary key,
	paid_amount int,
	payment_date varchar(30),
	payment_type varchar(30),-- cash / credit
	order_id int ,--foreign key references UserOrder(id) 
)
insert into Payment values(500,'10/18/2022','credit',1)
select * from Payment
truncate table Payment

--an after insert trigger will be called after every payemnt,
-- will add all the payments and compare with total amount of order, if equals order_state will be 1 else 0.

create table DistributorProduct(
	id int not null identity(1,1) primary key,
	saleprice_for_shopkeeper int,
	product_id int ,--foreign key references VendorProduct(id),
	distributor_id int ,--foreign key references UserAccount(id)
)

create table DistributorProductDetails(
	id int not null identity(1,1) primary key,
	no_of_cartons int,
	batch_no int ,--foreign key references batch_production(batch_no),
	dproduct_id int ,--foreign key references DistributorProduct(id),
)



create table ProviderList(
	id int not null identity(1,1) primary key,
	seller_id int ,--foreign key references UserAccount(id), -- vendor / distributor
	buyer_id int ,--foreign key references UserAccount(id) -- shopkeeper
)

create table Rating(
	id int not null identity(1,1) primary key,
	no_of_stars int,
	reviewer_id int ,--foreign key references UserAccount(id),
	reciever_id int ,--foreign key references UserAccount(id)
)

create table BlockUser(
	id int not null identity(1,1) primary key,
	seller_id int ,--foreign key references UserAccount(id),
	buyer_id int ,--foreign key references UserAccount(id)
)


--Trigger for Order_Payments

CREATE TRIGGER update_status ON Payment
AFTER INSERT
AS
BEGIN
DECLARE @id INT
set @id=  (select order_id from inserted)
DECLARE @amtPaid INT
set @amtPaid= (select SUM(paid_amount) from Payment where order_id=@id)
DECLARE @total INT
set @total= (select total_amount from UserOrder where id=@id)
if(@amtPaid=@total)
begin
UPDATE UserOrder
SET order_state = 1
WHERE id = @id;
end
END

CREATE TRIGGER update_total_cartons ON batch_production
AFTER INSERT
AS
BEGIN
DECLARE @id INT
set @id=  (select vendor_productid from inserted)
DECLARE @total INT
set @total= (select SUM(no_of_cartons) from batch_production where vendor_productid=@id)
UPDATE VendorProduct
SET total_cartons = @total
WHERE id = @id;
END

