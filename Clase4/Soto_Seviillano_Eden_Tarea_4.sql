--=======================================================
--Curso:SQL 3 
--Tema:Tarea 4
--Alumno:Soto S,Eden Persi
--Profesor:Julio Enrique Flores Manco
--Fecha:24/03/2022 
--=======================================================

/* Tarea: Crear un sp con varios parametros de entrada y salida
  en las cuatro bd de prueba que tenemos de ensayo */

------------------------EduTec-------------------------------
/* En EduTec; En un SP,
Presentar el monto pagado por el curso y el promedio obtenido nota parcial y final, apartir del codigo de alumno y codigo de curso */

--Entradas==>Codigo de alumno y codigo de curso
--Salida ===>Proemdio , nota parcial y final y monto pagado
use EduTec
go
select*from CursoProgramado
go

select
*
from		Alumno		A
inner join	Matricula	M on	A.IdAlumno=M.IdAlumno
inner join	CursoProgramado	CP	on	M.IdCursoProg=CP.IdCursoProg
inner join	Curso		C	on	CP.IdCurso=C.IdCurso
inner join	Tarifa		T	on	C.IdTarifa=T.IdTarifa
go

select
	A.IdAlumno,
	C.IdCurso,
	M.ExaParcial,
	M.ExaFinal,
	M.Promedio,
	T.PreTarifa
from		Alumno		A
inner join	Matricula	M on	A.IdAlumno=M.IdAlumno
inner join	CursoProgramado	CP	on	M.IdCursoProg=CP.IdCursoProg
inner join	Curso		C	on	CP.IdCurso=C.IdCurso
inner join	Tarifa		T	on	C.IdTarifa=T.IdTarifa
group by A.IdAlumno,C.IdCurso,M.ExaParcial,M.ExaFinal,M.Promedio,T.PreTarifa
having A.IdAlumno='A0007' and C.IdCurso='C001'
go
--A0007		C001	7	9	8	200.00
sp_help Tarifa
go
create procedure spu_NotasyMontoDeAlumnoCu
	@cod	char(5),
	@codC	char(4),
	@par	real output,
	@fin	real output,
	@pro	real output,
	@tar	money output
As
select
	@cod = A.IdAlumno,
	@codC=C.IdCurso,
	@par=M.ExaParcial ,
	@fin=M.ExaFinal ,
	@pro=M.Promedio ,
	@tar=T.PreTarifa 
from		Alumno		A
inner join	Matricula	M on	A.IdAlumno=M.IdAlumno
inner join	CursoProgramado	CP	on	M.IdCursoProg=CP.IdCursoProg
inner join	Curso		C	on	CP.IdCurso=C.IdCurso
inner join	Tarifa		T	on	C.IdTarifa=T.IdTarifa
group by A.IdAlumno,C.IdCurso,M.ExaParcial,M.ExaFinal,M.Promedio,T.PreTarifa
having A.IdAlumno=@cod and C.IdCurso=@codC
go
/*DROP PROCEDURE [spu_NotasyMontoDeAlumnoCu];  
GO*/  
--probando sp
--A0007		C001	7	9	8	200.00
 declare @par real,@fin	real,@pro real,@tar	money
 exec spu_NotasyMontoDeAlumnoCu 'A0007','C001', @par output,@fin output,@pro output,@tar output
 select 
 	@par as Parcial,
	@fin as Final,
	@pro as Promedio,
	@tar as [Costo Curso]
 go
 --A0012		C002	12	14	13	250.00
 declare @par real,@fin	real,@pro real,@tar	money
 exec spu_NotasyMontoDeAlumnoCu 'A0012','C002', @par output,@fin output,@pro output,@tar output
 select 
	@par as Parcial,
	@fin as Final,
	@pro as Promedio,
	@tar as [Costo Curso]
 go

------------------------MarkerPERU-------------------------------
/* En MarkerPERU; En un SP,
Presentar el stock actual de un producto categoria con su respectivo proveedor apartir 
de IdProducto e IdProveedor*/

--Entradas==>IdGuia  IdProducto
--Salida ===Stock actual, categoria y Idproveedor proveedor
use MarketPERU
go
select*from GUIA_DETALLE
go

select
*
from		GUIA_DETALLE		G
inner join	PRODUCTO	P on	G.IdProducto=P.IdProducto
inner join	CATEGORIA	C	on	P.IdCategoria=C.IdCategoria
inner join	PROVEEDOR	PR	on	P.IdProveedor=PR.IdProveedor
order by 2,3
go

select
	G.IdGuia,
	G.IdProducto,
	P.StockActual,
	C.Categoria,
	PR.IdProveedor,
	PR.Representante
from		GUIA_DETALLE		G
inner join	PRODUCTO	P on	G.IdProducto=P.IdProducto
inner join	CATEGORIA	C	on	P.IdCategoria=C.IdCategoria
inner join	PROVEEDOR	PR	on	P.IdProveedor=PR.IdProveedor
group by G.IdGuia,G.IdProducto,P.StockActual,C.Categoria,PR.IdProveedor,PR.Representante
--having G.IdGuia=1 and G.IdProducto=10
go
--1	10	900	Golosinas	15	Felices arsenino, jose

sp_help PRODUCTO
go
create procedure spu_verStockProv
	@idg	Int,
	@idpr	int,
	@stock	smallint output,
	@cat	varchar(20) output,
	@idp	int output,
	@re		varchar(30) output
As
select
	@idg=G.IdGuia,
	@idpr=G.IdProducto,
	@stock=P.StockActual,
	@cat=C.Categoria,
	@idp=PR.IdProveedor,
	@re=PR.Representante
from		GUIA_DETALLE		G
inner join	PRODUCTO	P on	G.IdProducto=P.IdProducto
inner join	CATEGORIA	C	on	P.IdCategoria=C.IdCategoria
inner join	PROVEEDOR	PR	on	P.IdProveedor=PR.IdProveedor
group by G.IdGuia,G.IdProducto,P.StockActual,C.Categoria,PR.IdProveedor,PR.Representante
having G.IdGuia=@idg and G.IdProducto=@idpr
go
/*DROP PROCEDURE [spu_verStockProv];  
GO*/  
--probando sp
--1	10	900	Golosinas	15	Felices arsenino, jose
 declare @stock	smallint,@cat	varchar(20),@idp	int,@re		varchar(30)
 exec spu_verStockProv 1,10, @stock output,@cat output,@idp output,@re	 output
 select 
 	@stock as [Stock actual],
	@cat as categoria,
	@idp as Idproveedor,
	@re as Representantre
 go
 -- 8	29	80	EMBUTIDOS	4	ALVARADO VERTIZ, FERNANDO
 declare @stock	smallint,@cat	varchar(20),@idp	int,@re		varchar(30)
 exec spu_verStockProv 8,29, @stock output,@cat output,@idp output,@re	 output
 select 
 	@stock as [Stock actual],
	@cat as categoria,
	@idp as Idproveedor,
	@re as Representantre
 go
------------------------Northwind-------------------------------
/* En Northwind; En un SP,
Presentar tenga 
como parámetro de entrada el código de un producto
y que devuelva en parámetros de salida 
	el nombre del producto, 
	el nombre del proveedor,	
	la cantidad total vendida, y 
	el monto total vendido.  */

use Northwind
go
select 
	*
from		Suppliers			S
inner join	Products			P	on S.SupplierID=P.SupplierID
inner join	[Order Details]		OD	on P.ProductID=OD.ProductID
go

select
	P.ProductID,
	P.ProductName,
	S.CompanyName,
	OD.UnitPrice,
	sum(OD.UnitPrice*OD.Quantity * (1- OD.Discount))
from		Suppliers			S
inner join	Products			P	on S.SupplierID=P.SupplierID
inner join	[Order Details]		OD	on P.ProductID=OD.ProductID
group by P.ProductID, P.ProductName, S.CompanyName,OD.UnitPrice
go

select 
	P.ProductID,
	P.ProductName,
	S.CompanyName,
	sum(OD.Quantity),
	round(sum(OD.Quantity * OD.UnitPrice * ( 1 - OD.Discount)),2)
from		Suppliers			S
inner join	Products			P	on S.SupplierID=P.SupplierID
inner join	[Order Details]		OD	on P.ProductID=OD.ProductID
group by P.ProductID, P.ProductName, S.CompanyName
go




select 
	P.ProductID,
	P.ProductName,
	S.CompanyName,
	sum(OD.Quantity),
	round(sum(OD.Quantity * OD.UnitPrice * ( 1 - OD.Discount)),2)
from		Suppliers			S
inner join	Products			P	on S.SupplierID=P.SupplierID
inner join	[Order Details]		OD	on P.ProductID=OD.ProductID
group by P.ProductID, P.ProductName, S.CompanyName
having P.ProductID = 3
go


--3	Aniseed Syrup	Exotic Liquids	328	3044

-- convirtiendo sp
sp_help SUPPLIERS
GO

create procedure spu_ProVen
	@cp		int, 
	@nprod	varchar(40) output, 	
	@nprove	varchar(40) output,  	
	@can	int			output, 
	@monto	money		output
as
SELECT 
	@cp		= P.ProductID,			
	@nprod	= P.ProductName,
	@nprove	= S.CompanyName, 
	@can	= sum(OD.Quantity),
	@monto  =round(sum(OD.Quantity * OD.UnitPrice * ( 1 - OD.Discount)),2)
from		Suppliers			S
inner join	Products			P	on S.SupplierID=P.SupplierID
inner join	[Order Details]		OD	on P.ProductID=OD.ProductID
group by P.ProductID, P.ProductName, S.CompanyName
having P.ProductID = @cp
go
-- probando sp
--3	Aniseed Syrup	Exotic Liquids	328	3044
declare @nprod	varchar(40),@nprove varchar(40),@pv Money,@can int,@monto money
exec spu_ProVen 3,@nprod output,@nprove output, @can output, @monto output
select 	@nprod, 	@nprove, 	@can, 	@monto
go

--6 Grandma's Boysenberry Spread	Grandma Kelly's Homestead	301	7137.00
declare @nprod	varchar(40),@nprove varchar(40),@pv Money,@can int,@monto money
exec spu_ProVen 6,@nprod output,@nprove output, @can output, @monto output
select 	@nprod, 	@nprove, 	@can, 	@monto
go

------------------------pubs-------------------------------
/*Crear un SP en Pubs, que, 
al entregarle el codigo de un libro, presente	nombre del libro , 
cantidad vendida y precio correspondiente a dicho libro */

use pubs
go
select*from sales
go

select
*
from		sales		S
inner join	titles	T on	S.title_id=T.title_id
go

select
	T.title_id,
	T.title,
	sum(S.qty),
	sum(S.qty * T.price)
from		sales		S
inner join	titles	T on	S.title_id=T.title_id
group by T.title_id,T.title
go
--MC3021	The Gourmet Microwave	40	119.60

sp_help titles
go
--crear sp
create procedure spu_InLib
	@idT	varchar(6),
	@ti		varchar(80) output,
	@can	int output,
	@mon	money output
As
select
	@idT=T.title_id,
	@ti=T.title,
	@can=sum(S.qty),
	@mon=sum(S.qty * T.price)
from		sales		S
inner join	titles	T on	S.title_id=T.title_id
group by T.title_id,T.title
having T.title_id=@idT
go
/*DROP PROCEDURE [spu_InLib];  
GO*/  
--probando sp
--PS2106	Life Without Fear	25	175.00
 declare @ti varchar(80),@can	int,@mon money
 exec spu_InLib 'PS2106', @ti output,@can output,@mon output
 select 
 	@ti as [Nombre libro],
	@can as [CAntidad vendida],
	@mon as Monto
 go


--MC3021	The Gourmet Microwave	40	119.60
 declare @ti varchar(80),@can	int,@mon money
 exec spu_InLib 'MC3021', @ti output,@can output,@mon output
 select 
 	@ti as [Nombre libro],
	@can as [CAntidad vendida],
	@mon as Monto
 go
