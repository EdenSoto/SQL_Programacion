--=======================================================
--Curso:SQL 3 
--Tema:Tarea 6
--Alumno:Soto S,Eden Persi
--Profesor:Julio Enrique Flores Manco
--Fecha:29/03/2022 
--=======================================================
/*						TAREA SESION 6				
En marketperu crear un trigger que permita ingresar un detalle de 
venta. Se debe verificar si hay stock suficiente y si el producto no 
esta descontinuado para realizar la venta. (tarea)
*/
use MarketPERU
go


--Crear trigger
sp_help guia_detalle
go

create trigger tr_insert_venta
on GUIA_DETALLE
after insert
as
declare @stockA smallint,@descont bit, @cant smallint
select @stockA = P.StockActual, @descont = P.Descontinuado ,@cant=I.Cantidad
from PRODUCTO P ,inserted I
where P.IdProducto = I.IdProducto

if (@stockA=0 or @descont=1 or @stockA<@cant)
	begin
		print 'No hay stock o esta descontinuado'
		rollback tran
	end
else
	begin
		update PRODUCTO
		set StockActual= StockActual -I.Cantidad
		from inserted I
		where PRODUCTO.IdProducto = I.IdProducto
		print 'Base de Datos actualizada'
	End
go
/*DROP TRIGGER IF EXISTS tr_insert_venta
go*/

select *from GUIA where IdGuia =109
select *from GUIA_DETALLE where IdGuia =109
select *from PRODUCTO where IdProducto = 99
go
sp_help GUIA_DETALLE
go
INSERT INTO GUIA 
VALUES(109,2,'20220401','ALIAGA S, JEREMIAS')
GO
select *from GUIA where IdGuia =109
select *from GUIA_DETALLE where IdGuia =109
select *from PRODUCTO where IdProducto = 99
go

INSERT INTO GUIA_DETALLE 
VALUES(109,99,2.5,60)
GO
select *from GUIA where IdGuia =109
select *from GUIA_DETALLE where IdGuia =109
select *from PRODUCTO where IdProducto = 99
go

--Cuando no hay stock
select *from PRODUCTO where IdProducto = 20
go
update PRODUCTO set StockActual=50
where IdProducto=20
go
select *from PRODUCTO where IdProducto = 20
go

INSERT INTO GUIA_DETALLE 
VALUES(109,20,2.5,60)
GO
--Cuando producto descontunuado
select *from PRODUCTO where IdProducto = 20
go
update PRODUCTO set Descontinuado=1,StockActual=200
where IdProducto=20
go
select *from PRODUCTO where IdProducto = 20
go

INSERT INTO GUIA_DETALLE 
VALUES(109,20,2.5,60)
GO



/*
CREAR UNA FUNCIÓN QUE RESUELVA UNA ECUACIÓN DE SEGUNDO GRADO. 
SOLO PARA RESULTADOS REALES. 
USAR LA ECUACION GENERAL DE LA EC DE 2DO GRADO
*/

use EduTec
go
create function  fn_EcuaSenGradoX1
	(@a real, @b real ,@c real) --> VARIABLES
	 returns real --TIPO DE DATO A DEVOLVER

begin
	declare @x real
	declare @y real
	declare @dis real
	set @dis = SQRT(@b*@b-4*@a*@c )        
	set @x = (-@b + @dis )/(2*@a)
	set @y = (-@b - @dis )/(2*@a)
	RETURN @x 
END
GO

create function  fn_EcuaSenGradoX2
	(@a real, @b real ,@c real) --> VARIABLES
	 returns real --TIPO DE DATO A DEVOLVER

begin
	declare @x real
	declare @y real
	declare @dis real
	set @dis = SQRT(@b*@b-4*@a*@c )        
	set @y = (-@b - @dis )/(2*@a)
	RETURN @y
END
GO
/*drop function dbo.fn_EcuaSenGradoX1
go
drop function dbo.fn_EcuaSenGradoX2
go
*/

Print dbo.fn_EcuaSenGradoX1(3,7,-10)
GO
Print dbo.fn_EcuaSenGradoX2(3,7,-10)
GO