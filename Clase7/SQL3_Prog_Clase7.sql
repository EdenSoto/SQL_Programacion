/*
SQL 3 -  Sesión 7

Miercoles 30 de Marzo del 2022

7 pm 

*/
--********************************************


SP_HELP Volumen 
GO 


-----    PARA LA PROXIMA CLASE  7 ........


SP_HELPTEXT Volumen 
GO 
--------------
/*
En una Nueva Base de Datos Crear una 
	Función que Calcule el Subtotal, otra 
	Función que Calcule el Descuento aplicado y otra 
	Función que Calcule el Monto pagado.
Crear una Tabla con los campos: 
	NroFactura, 
	IdProducto, 
	Cantidad, 
	PreUniVen, 
	Porc_Desc, 
	Subtotal, 
	Descuento, 
	MontoPagado.
Usar las Funciones en la Declaración de los campos para que se llenen los
 campos Subtotal, Descuento, MontoPagado al ingresar un nuevo registro.  */
USE MASTER
GO
DROP DATABASE  BD_Ventas
GO
CREATE DATABASE BD_Ventas
GO
USE BD_Ventas
GO
CREATE FUNCTION Fn_SubTotal    
( @Cant INT, @Precio MONEY) 
	RETURNS MONEY  
AS 
BEGIN 
RETURN ( @Cant * @Precio) 
END
GO
CREATE FUNCTION Fn_Desc    
( @Cant INT, @Precio MONEY, @Desc MONEY) 
	RETURNS MONEY  
AS 
BEGIN 
RETURN ( @Cant * @Precio * @Desc) 
END
GO

CREATE FUNCTION Fn_MonP    
( @Cant INT, @Precio MONEY, @Desc MONEY) 
	RETURNS MONEY  
AS 
BEGIN 
RETURN ( @Cant * @Precio * ( 1 - @Desc )) 
END
GO

 --A continuación, es posible utilizar esta función en 
 --cualquier parte en la que se permita
 --como en una columna calculada de una tabla: 

CREATE TABLE Detalle_Factura 
(	NroFactura	int PRIMARY KEY, 
	IdProducto		int, 
	Cantidad			int, 
	PreUniVen		MONEY, 
	Porc_Desc		decimal(4,2),     
	Subtotal			AS (  dbo.Fn_SubTotal(Cantidad,PreUniVen)  ) ,
	Descuento		AS ( dbo.Fn_Desc(Cantidad,PreUniVen,Porc_Desc) ),
	MontoPagado AS ( dbo.Fn_MonP(Cantidad,PreUniVen,Porc_Desc) )
)
GO
 SELECT * FROM Detalle_Factura
 GO
 /*Ingresamos un registro en Detalle_Factura con los siguientes datos:
		NroFactura = 1
		IdProducto =  1 
		Cantidad		= 10 
		PreUniVen	= 4 
		Porc_Desc	= 0.25
 */
INSERT INTO Detalle_Factura VALUES(1,1,10,4,0.25) 
GO
 SELECT * FROM Detalle_Factura
 GO


--FUNCIONES EN LÍNEA 

--Las funciones en línea definidas por el usuario son un subconjunto de funciones  --definidas por el usuario que devuelven un tipo de datos table 
--Ejemplo 4 
USE PUBS 
GO 
/*drop function dbo.VentasPorTienda 
go*/
CREATE FUNCTION VentasPorTienda 
( @CodTienda VarChar(30) ) 
RETURNS TABLE 
AS 
RETURN ( SELECT
				ST.Stor_name										AS Tienda,
				CONVERT(CHAR(12),S.ord_date,103)					AS Fecha,
				T.Title												AS Libro,
				S.qty												AS Cantidad 
FROM				Titles T 
INNER JOIN	Sales S     ON T.Title_Id = S.Title_Id 
INNER JOIN	Stores ST ON S.Stor_Id = ST.Stor_Id  
WHERE S.Stor_Id = @CodTienda )  
GO 

-- Codigos de tiendas: 6380 7066 7067 7131 7896 8042 
SELECT * FROM VentasPorTienda('7131') 
GO 

SELECT * FROM VentasPorTienda('6380') 
GO 

SELECT * FROM VentasPorTienda('8042') 
GO 



============================================================ 
--Ejemplo 5 

USE NORTHWIND 
GO 
SELECT * FROM Customers ORDER BY Region 
GO 

CREATE VIEW v_Clientes_WA AS 
SELECT CustomerID, CompanyName 
FROM Customers 
WHERE Region = 'WA' 
GO 

SELECT * FROM v_Clientes_WA 
GO 

-- Como las vistas no admiten parámetros en las condiciones de búsqueda especificadas en la cláusula WHERE, 
 
-- no se puede generalizar el procedimiento 

CREATE FUNCTION fn_ClientesPorRegion 
( @Region nvarchar(30) ) 
RETURNS table 
AS 
RETURN ( 
        SELECT CustomerID, CompanyName         
		FROM Northwind.dbo.Customers         
		WHERE Region = @Region 
) 
GO 

-- Probando la funcion 
SELECT * 
FROM fn_ClientesPorRegion ('SP') 
GO 

SELECT * 
FROM fn_ClientesPorRegion ('OR') 
GO 

--============================================================= 

--UNA FUNCION EN LINEA GENERA UNA TABLA ACTUALIZABLE

--Ejemplo 6 

USE EduTec 
GO 

SELECT * FROM MATRICULA 
GO 

CREATE FUNCTION fn_Notas2 
   ( @Alumno Char(5),@CodCursoP Int) 
RETURNS table 
AS 
RETURN ( 
Select IdAlumno,ExaParcial,ExaFinal,ExaSub,Promedio   
From  Matricula 
Where IdAlumno = @Alumno AND IdCursoProg=@CodCursoP 
) 
GO 

SELECT * FROM fn_Notas2('A0001',1) 
GO 
UPDATE fn_Notas2('A0001',1) 
SET Promedio = 20
GO
SELECT * FROM fn_Notas2('A0001',1) 
GO

--
--


