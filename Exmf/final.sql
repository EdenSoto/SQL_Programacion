--=======================================================
--Curso:SQL 3 
--Tema:Examen Final
--Alumno:Soto S,Eden Persi
--Profesor:Julio Enrique Flores Manco

--=======================================================

/*Con el BD PUBS crear un índice lógico que permita ver a 
los libros ordenados por editorial y por tipo.
Solución
*/
use pubs
go

select*from titles
go

select title, pub_id,type from titles
order by pub_id,type
go
--==>pub_id, type

create nonclustered index TipEdit
	on titles(pub_id,type)
go

exec sp_helpindex titles
go

select title, pub_id,type from titles
order by pub_id,type
go

/*Con el BD Northwind crear un SP que muestre los cinco 
productos más vendidos en un intervalo de fechas determinado*/

use Northwind
go
select*
from			Orders		O	
inner join	[Order Details]	OD	on	O.OrderID = OD.OrderID
inner join Products			P	on	OD.ProductID = P.ProductID
where O.OrderDate BETWEEN '19970101' AND '19970331'
group by OD.ProductID, P.ProductName
go

select top 5  with ties --Con empates
	OD.ProductID, 
	P.ProductName,
    sum(OD.Quantity ) as Productos
from			Orders		O	
inner join	[Order Details]	OD	on	O.OrderID = OD.OrderID
inner join Products			P	on	OD.ProductID = P.ProductID
where O.OrderDate BETWEEN '19970101' AND '19970331'
group by OD.ProductID, P.ProductName
order by 3 desc
go

-- creando sp
create procedure top5Venta
as
select top 5  with ties --Con empates
	OD.ProductID, 
	P.ProductName,
    sum(OD.Quantity ) as Productos
from			Orders		O	
inner join	[Order Details]	OD	on	O.OrderID = OD.OrderID
inner join Products			P	on	OD.ProductID = P.ProductID
where O.OrderDate BETWEEN '19970101' AND '19970331'
group by OD.ProductID, P.ProductName
order by 3 desc
go

--Probando sp
exec top5Venta
go



/*Crear un store procedure en MarketPeru que al ingresar un 
detalle de compra actualice en forma automática el stock del 
producto comprado. 
Para probar el store procedure debe ingresar primero una nueva
compra, y luego ingresar un detalle de la nueva compra utilizando 
el store procedure que se ha creado.
*/

--Tablas:ORDEN ==>IdOrden, fechaOrden Fecha Fechaentrada
--		

use MarketPERU
go
sp_help ORDEN_DETALLE
go
create procedure spu_Ingresar_Pedido
	@idOrden int,
	@idproducto int,
	@cantidadS smallint
as
	declare @precio		money
	declare @desc		bit
	declare @canti		smallint
	select 	 @precio = PrecioProveedor  from PRODUCTO 
	where IdProducto = @idproducto
	declare @stock smallint
if (@idOrden is null) or (@idproducto is null) or (@cantidadS is null)  
	begin
		print 'VALOR NULO' 
		return 1 
    end
if not exists (select IdProducto from PRODUCTO
				           where IdProducto = @idproducto) 
	begin
		print 'EL PRODUCTO NO EXISTE'
		return 2
	end
if not exists (select IdOrden from ORDEN where IdOrden=@idOrden)
	begin
		print 'LA ORDEN NO EXISTE'
		return 3
	end
select 
	@stock = StockActual, @desc = Descontinuado 
from PRODUCTO where IdProducto = @idproducto
if @desc = 1
	begin
		print 'EL PRODUCTO ESTÁ DISCONTINUADO'
		return 4
	end
begin tran
	update PRODUCTO set StockActual = StockActual + @cantidadS
		where IdProducto=@idproducto
	insert into ORDEN_DETALLE(IdOrden,IdProducto,PrecioCompra,CantidadSolicitada)
	values(@idOrden, @idproducto, @precio, @cantidadS)
if @@ERROR <> 0
	begin
		print 'ERROR EN LA BD'
		rollback tran
		return 5
	end
commit tran
	return 0
go
--

sp_help spu_Ingresar_Pedido
go
select * from ORDEN
go
sp_help ORDEN
go
insert into ORDEN values(19,'20220404','20220405')
GO
select * from ORDEN where IdOrden = 19
select * from ORDEN_DETALLE where IdOrden = 19
go
--Probando SP:

update PRODUCTO set StockActual=190 where IdProducto = 1 
go
select * from PRODUCTO where IdProducto=1 
-- STOCK = 190
declare @ret int
exec @ret = spu_Ingresar_Pedido 19,1,60
select @ret
go
select * from PRODUCTO where IdProducto=1 
select * from ORDEN_DETALLE where IdOrden=19
go
-- Ahora el stock esta en 250( se le aumentó 60 )

-- Con un Producto descontinuado
select * from PRODUCTO where IdProducto=138  
go
-- El stock actual del producto 138 es 256
-- Le cambiamos el valor a Descontinuado a 1
update PRODUCTO SET Descontinuado=1 WHERE IdProducto = 138  
GO
select * from PRODUCTO where IdProducto=138  
GO
declare @ret int
exec @ret = spu_Ingresar_Pedido 19,138,50
select @ret
go

-- orden no existe

declare @ret int
exec @ret = spu_Ingresar_Pedido 20,138,50
select @ret
go

-- producto no existe

declare @ret int
exec @ret = spu_Ingresar_Pedido 19,500,50
select @ret
go


/*Crear un Trigger en la Base de Datos Northwind 
que controle que no se cambie el nombre de un Proveedor.*/

use Northwind
go

select*from Shippers
go 

create trigger TR_UPDATE_Proveedor
on shippers
after update
as
if ( select count(*)
	from inserted I, deleted D
	where I.CompanyName = D.CompanyName ) = 0
begin
	print 'NO SE PUEDE MODIFICAR EL NOMBRE DEL PROVEEEDOR'
	rollback tran
end
else
	print 'DATOS ACTUALIZADOS SATISFACTORIAMENTE.'	
go
-- Probar el desencadenante
select * from shippers where ShipperID = 2
go
UPDATE shippers	 set CompanyName = 'Nuevo nombre' 
WHERE ShipperID = 2
GO

/*En la bd Northwind crear un Trigger que al momento de 
ingresar un Detalle de pedido (Tabla Order Details) 
verifique si el stock (UnitsInStock) del Producto vendido
(de la Tabla de Productos) después de realizar la venta 
será menor o igual al stock mínimo establecido (ReorderLevel); 
si así fuera presentar un mensaje de advertencia que el  
stock se encuentra por debajo del mínimo establecido.
*/

use Northwind
go

--Crear trigger
select*from [Order Details]
go
sp_help [Order Details]
go

create trigger tr_insert_venta
on [Order Details]
after insert
as
declare @Stock smallint,@Can smallint
select @stock = P.UnitsInStock ,@can=I.Quantity
from Products P ,inserted I
where P.ProductID = I.ProductID

if @Stock < @Can
	begin
		print 'No hay suficiente Stock para realizar la venta'
		rollback tran
	end
else
	begin
		update Products
		set UnitsInStock= UnitsInStock -@Can
		from inserted I
		where Products.ProductID = I.ProductID
		print 'Base de Datos actualizada'
	End
go

create trigger BajoStock
on Products
after update
as
declare @Stock smallint,@StMin smallint
select @Stock = P.UnitsInStock, @StMin=P.UnitsOnOrder
from Products P, inserted I
where P.ProductID=I.ProductID
 if @Stock < @StMin
	  	 begin
		 print 'El producto esta por debajo del Stock minimo'
 end
go

select*from Products 
go

--1	Chai	1	1	10 boxes x 20 bags	18.00	39	0	10	0

select*from Orders
go
sp_help orders
go

insert into Orders(CustomerID,EmployeeID,OrderDate) 
			Values('RICSU',5,'20220405')
go



select*from Orders where OrderID=11079
select*from [Order Details] where OrderID=11079
go

/*select*from [Order Details]
go
sp_help [Order Details]
go
select*from Products where ProductID = 1
go*/

insert into [Order Details] values(11079,1,18,10,0)
go
--1	Chai	1	1	10 boxes x 20 bags	18.00	39	0	10	0
select*from [Order Details] where OrderID=11079
go
select*from Products where ProductID = 1
go
--el stock bajo de 39 a 29 por el pedido de 10 unidades


--Pedido más alto del stock

--2	Chang	1	1	24 - 12 oz bottles	19.00	17	40	25	0
insert into [Order Details] values(11079,2,18,60,0)
go

select*from [Order Details] where OrderID=11079
go
select*from Products where ProductID = 2
go


--hasta el limite se stock
insert into [Order Details] values(11079,2,18,40,0)
go

select*from [Order Details] where OrderID=11079
go
select*from Products where ProductID = 2
go
