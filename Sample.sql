Create type Insertseller as table
(
sellernationalid nvarchar(12),
sellername nvarchar(50),
sellersurname nvarchar(50),
sellerphonenumber nvarchar(50)
)
go
Create type Insertbuyer as table
(
buyernationalid nvarchar(12),
buyername nvarchar(50),
buyersurname nvarchar(50),
buyerphonenumber nvarchar(50)
)
go
Create type Insertordermaster as table
(
sellernationalid nvarchar(12),
buyernationalid nvarchar(12),
totalprice money,
totaldiscount money,
purchasedate date,
purchasetime time
)
go
create type Insertorderdetail1 as table
(

productid int,
quantity int,
finalprice money,
finaldiscount money
)
go
Create type Insertproduct1 as table
(

productname nvarchar(50),
unitprice money,
discount money,
productimage image null
)
go
Create type Updateseller as table
(
sellernationalid nvarchar(12),
sellername nvarchar(50),
sellersurname nvarchar(50),
sellerphonenumber nvarchar(50)
)
go
Create type Updatebuyer as table
(
buyernationalid nvarchar(12),
buyername nvarchar(50),
buyersurname nvarchar(50),
buyerphonenumber nvarchar(50)
)
go
create type updaeteordermaster as table
(
orderid int,
sellernationalid nvarchar(12),
buyernationalid nvarchar(12),
totalprice money,
totaldiscount money,
purchasedate date,
purchasetime time
)
go
create type updateorderdetail as table
(
orderid int,
productid int,
quantity int,
finalprice money,
finaldiscount money
)
go
create type updateproduct as table
(
productid int,
productname nvarchar(50),
unitprice money,
discount money,
productimage image null
)
go
alter PROCEDURE dbo.Insertseller
   @Insertseller Insertseller Readonly
AS
begin tran
begin try
insert into seller(Sellernationalid,Sellername,Sellersurname,Sellerphonenumber) 
Select * from @Insertseller
commit tran

End try
begin catch
rollback tran
End catch
    
RETURN 0 
go
alter PROCEDURE dbo.Insertorder
   @Insertordermaster Insertordermaster Readonly,
    @Insertorderdetail Insertorderdetail1 readonly
    
AS
    begin tran
	declare @orderid int
	declare @productid int
	declare @quantity int
	declare @unitprice money
	declare @discount money
	begin try
	declare Insertorderdetail cursor for select od.productid,od.quantity From @Insertorderdetail od
	Insert into OrderMaster(Sellernationalid,Buyernationalid,Purchasedate,Purchasetime,Totalprice,Totaldiscount)
	Select om.Sellernationalid,om.Buyernationalid,om.Purchasedate,om.Purchasetime,om.Totalprice,om.Totaldiscount From @Insertordermaster om
	set @orderid=scope_identity()
	open Insertorderdetail
	Fetch next from Insertorderdetail into @productid,@quantity
	while(@@FETCH_STATUS=0)
	begin
	set @unitprice=(select p.Unitprice 
	from OrderDetail od  right join  Product p
	on od.Productid=od.Productid
	where od.Orderid=@orderid)
	set @discount=(select p.discount 
	from OrderDetail od  right join  Product p
	on od.Productid=od.Productid
	where od.Orderid=@orderid)	
	Insert into OrderDetail(orderid,Productid,Quantity,Finalprice,Finaldiscount)
    values(@orderid,@productid,@quantity,@unitprice*@quantity,@discount*@quantity)
	Fetch next from Insertorderdetail into @productid,@quantity
	end
	commit tran
	close Insertorderdetail
	deallocate Insertorderdetail
	End try
	begin catch
	rollback tran
	End catch
RETURN 0 
go
alter PROCEDURE dbo.Insertproduct
  @InsertProduct Insertproduct1 readonly 
AS
declare @eror nvarchar(50)
    begin tran
	begin try
	Insert into Product
	Select inp.productname,inp.unitprice,inp.discount,inp.productimage From @InsertProduct inp
	set @eror='products are Inserted'
	commit tran
	end try
	
	begin catch
	rollback tran
	set @eror='Please try again'
	end catch
RETURN 0 
go
alter PROCEDURE dbo.Insertbuyer
  @Insertbuyer Insertbuyer readonly   
AS
 declare @eror nvarchar(50)
    begin tran

	begin try
	Insert into Buyer
	Select B.Buyernationalnumber,B.Buyername,B.Buyersurname,B.Buyerphonenumber From Buyer B
	commit tran
	set @eror='buyers are inserted'
	end try
	begin catch
	rollback tran
	set @eror='Please try again'
	end catch
RETURN 0 
go
alter PROCEDURE dbo.updateseller
  @updateseller updateseller readonly 
AS
declare @sellernationalid nvarchar(12)
declare @sellername nvarchar(50)
declare @sellersurname nvarchar(50)
declare @sellerphonenumber nvarchar(50)
declare @eror nvarchar(50)
declare updateseller cursor for select * From Seller
    begin tran
	begin try
	open updateseller
	fetch next from updateseller into @sellernationalid,@sellername,@sellersurname,@sellerphonenumber
	while(@@FETCH_STATUS = 0)
	begin
	update Seller 
	set Sellername=@sellername,Sellersurname=@sellersurname,Sellerphonenumber=@sellerphonenumber
	Where Sellernationalid=@sellernationalid
	fetch next from updateseller into @sellernationalid,@sellername,@sellersurname,@sellerphonenumber
	end
	commit tran 
	set @eror='update is done'
	end try
	begin catch
	rollback tran
	set @eror='Please try again'
	end catch
RETURN 0 

go
alter PROCEDURE dbo.Updatebuyer
 @Updatebuyer updatebuyer readonly 
AS

declare @buyernationalid nvarchar(12)
declare @buyername nvarchar(50)
declare @buyersurname nvarchar(50)
declare @buyerphonenumber nvarchar(50)
declare @eror nvarchar(50)

declare updatebuyer cursor for select * From Buyer
    begin tran
	begin try
	open updateseller
	fetch next from updatebuyer into @buyernationalid,@buyername,@buyersurname,@buyerphonenumber
	while(@@FETCH_STATUS = 0)
	begin
	update Seller 
	set Sellername=@buyername,Sellersurname=@buyersurname,@buyerphonenumber=@buyerphonenumber
	Where @buyernationalid=@buyernationalid
	fetch next from updatebuyer into @buyernationalid,@buyername,@buyersurname,@buyerphonenumber
	end
	commit tran 
	set @eror='update is done'
	end try
	begin catch
	rollback tran
	set @eror='Please try again'
	end catch
    
RETURN 0 
go
alter PROCEDURE dbo.Updateordermaster
   @Updateorderdetail updateorderdetail readonly
AS
   begin tran
   declare updateorderdetail cursor for select uod.Productid,uod.Quantity from @Updateorderdetail uod
   declare @productid int
   declare @quantity int
   declare @unitprice money
   declare @discount money
   declare @error nvarchar(50)
   begin try
   open updateorderdetail
   Fetch next from updateorderdetail into @productid,@quantity
   while(@@FETCH_STATUS=0)
   begin
      set @unitprice=(select p.Unitprice From product P left join orderdetail od
   on p.productid=od.productid
   where p.productid=od.productid)
   set @discount=(select p.discount From product P left join orderdetail od
   on p.productid=od.productid
   where p.productid=od.productid)
   update OrderDetail 
   set Productid=@productid,Quantity=@quantity,Finalprice=@quantity*@unitprice,Finaldiscount=@quantity*@discount
   Fetch next from updateorderdetail into @productid,@quantity
   end
   close updateorderdetail
   deallocate updateorderdetail
   set @error='your orders are updated '
   commit tran
   end try
   begin catch
   set @error='Try again'
   rollback tran
   end catch
RETURN 0