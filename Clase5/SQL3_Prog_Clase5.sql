/*
SQL 3 -  Sesión 5

Viernes 25 de Marzo del 2022

7 pm 

*/
--********************************************
/* Crear un SP en Northwind, 
que permita ingresar un detalle de pedido 
 para probar debera crear un nuevo pedido(sin detalles)
luego verificar el SP para los detalles del nuevo pedido
-La existencia del producto y pedido
-Verificar el stock del producto que se va a vender. 
Debe ser mayor o igual que la cantidad que se desea vender
-Verificar si el producto esta continuado, 
si es contrario no se puede vender el producto 
-Si se cumplen las condiciones crear el detalle
-Actualizar la tabla de productos para el stock vendido*/ 




USE Northwind
GO
SP_HELP spu_IngresarDetallePedido
GO 

CREATE PROCEDURE spu_IngresarDetallePedido
	@orderid INT, 
	@productid INT, 
	@quantity SMALLINT, 
	@discount REAL 
AS
DECLARE @unitprice MONEY
SELECT @unitprice = UnitPrice FROM Products 
	WHERE ProductID = @productid

IF (@orderid IS NULL)  OR (@productid IS NULL)	OR 
    (@quantity IS NULL) OR (@discount IS NULL)
	BEGIN
		PRINT 'VALOR NULO'
		RETURN 1
	END
IF NOT EXISTS(SELECT ProductID FROM Products 
				WHERE ProductID = @productid)
	BEGIN
		PRINT 'ESTE PRODUCTO NO EXISTE'
		RETURN 2
	END
IF NOT EXISTS(SELECT OrderID FROM Orders 
              WHERE OrderID = @orderid)
	BEGIN
		PRINT 'ESTE PEDIDO NO EXISTE'
		RETURN 3
	END
IF (SELECT UnitsInStock FROM Products 
		WHERE ProductID=@productid) < @quantity
	BEGIN
		PRINT 'LA CANTIDAD INGRESADA ES MAYOR AL STOCK'
		RETURN 4
	END
IF (SELECT Discontinued FROM Products 
		WHERE ProductID = @productid) = 1
	BEGIN
		PRINT 'EL PRODUCTO ESTA DESCONTINUADO'
		RETURN 5
	END
	BEGIN TRAN
		UPDATE Products SET UnitsInStock = UnitsInStock - @quantity 
		                      WHERE ProductID = @productid
		INSERT INTO [Order Details] (OrderID,ProductID,UnitPrice,Quantity,Discount)
			VALUES (@orderid,@productid,@unitprice,@quantity,@discount)
		IF @@ERROR <> 0
		BEGIN
			PRINT 'ERROR EN LA BD'
			ROLLBACK TRAN
			RETURN 6
		END
	COMMIT TRAN
	RETURN 0
GO
--Probando el SP

SP_HELP spu_IngresarDetallePedido
GO 


SELECT * FROM orders
GO
EXEC SP_HELP orders
GO
INSERT INTO Orders (CustomerID, EmployeeID)
						VALUES('ALFKI',1)
GO
SELECT * FROM orders
GO
SELECT * FROM [ORDER DETAILS] WHERE OrderID=11078
SELECT * FROM Products WHERE ProductID = 10
GO
--PROBANDO EL PROCEDIMIENTO
DECLARE @OD INT
EXEC @OD = spu_IngresarDetallePedido 11078,10,11,0
SELECT @OD
GO
SELECT * FROM Products WHERE ProductID = 10
SELECT * FROM [Order Details] WHERE OrderID = 11078
GO
-- Probar con los errores planeados.
--

-- USANDO EL SP spu_IngresarDetallePedido
-- CUANDO NO HAY STOCK SUFICIENTE
SELECT * FROM Products WHERE ProductID = 20  
GO
-- El producto 20 tiene actualmente un SOTCK = 40
SELECT * FROM Orders WHERE  OrderID = 11078
GO
SELECT * FROM [Order Details] WHERE  OrderID = 11078
GO
DECLARE @OD INT
EXEC @OD = spu_IngresarDetallePedido 11078,20,60,0
SELECT @OD
GO

-- CUANDO UN PRODUCTO ESTA DESCONTINUADO

SELECT * FROM Products WHERE Discontinued=1
GO
SELECT * FROM Products WHERE ProductID = 9
GO

--El producto 9 tiene un Stock = 29, pero esta con discontinued =1

DECLARE @OD INT
EXEC @OD = spu_IngresarDetallePedido 11078,9,10,0
SELECT @OD
GO
SELECT * FROM [Order Details] WHERE  OrderID = 11078
GO

/* CREAR EN MARKETPERU UN SP 
QUE PERMITA INGRESAR UN 
    DETALLE DE VENTA */

USE MarketPERU
GO
SP_HELP GUIA_DETALLE
GO
CREATE PROCEDURE spu_inserta_deta_guia
	@idguia INT,
	@idproducto INT,
	@cantidad SMALLINT
AS
	DECLARE @precio	MONEY
	DECLARE @desc		BIT
	SELECT	@precio = PrecioProveedor  FROM PRODUCTO 
										WHERE IdProducto = @idproducto
	DECLARE @stock SMALLINT
IF (@idguia IS NULL) OR (@idproducto IS NULL) OR (@cantidad IS NULL)  
	BEGIN
		PRINT 'VALOR NULO' 
		RETURN 1 
    END
IF NOT EXISTS (SELECT IdProducto FROM PRODUCTO
				           WHERE IdProducto = @idproducto) 
	BEGIN
		PRINT 'EL PRODUCTO NO EXISTE'
		RETURN 2
	END
IF NOT EXISTS (SELECT IdGuia FROM Guia WHERE IdGuia=@idguia)
	BEGIN
		PRINT 'LA GUIA NO EXISTE'
		RETURN 3
	END
SELECT 
	@stock = StockActual, @desc = Descontinuado 
FROM PRODUCTO WHERE IdProducto = @idproducto
IF @cantidad > @stock
	BEGIN
		PRINT 'LA CANTIDAD INGRESADA ES MAYOR AL STOCK'
		RETURN 4
	END
IF @desc = 1
	BEGIN
		PRINT 'EL PRODUCTO ESTÁ DISCONTINUADO'
		RETURN 5
	END
BEGIN TRAN
	UPDATE PRODUCTO SET StockActual = StockActual - @cantidad
		WHERE IdProducto=@idproducto
	INSERT INTO GUIA_DETALLE
	VALUES(@idguia, @idproducto, @precio, @cantidad)
IF @@ERROR <> 0
	BEGIN
		PRINT 'ERROR EN LA BD'
		ROLLBACK TRAN
		RETURN 6
	END
COMMIT TRAN
	RETURN 0
GO
--

SP_HELP spu_inserta_deta_guia
GO
SELECT * FROM GUIA
GO
SP_HELP GUIA
GO
INSERT INTO GUIA 
VALUES(108,2,'20191125','ALIAGA VIDAL, JEREMIAS')
GO
SELECT * FROM GUIA WHERE IdGuia = 108
SELECT * FROM GUIA_DETALLE WHERE IdGuia = 108
GO
--Probando SP:
SELECT * FROM PRODUCTO WHERE IdProducto=1 
-- STOCK = 200
DECLARE @ret INT
EXEC @ret = spu_inserta_deta_guia 108,1,10
SELECT @ret
GO
SELECT * FROM PRODUCTO WHERE IdProducto=1 
SELECT * FROM GUIA_DETALLE WHERE idguia=108
GO
-- Ahora el stock esta en 190 ( se le resto 10 )
-- Hay un detalle para la guia 108

-- Prueba con una cantidad mayor al Stock 
SELECT * FROM PRODUCTO WHERE IdProducto=30  
GO
-- El stock actual del producto 30 es 100
DECLARE @ret INT
EXEC @ret = spu_inserta_deta_guia 108,30,101
SELECT @ret
GO

SELECT * FROM PRODUCTO WHERE IdProducto=30 
SELECT * FROM GUIA_DETALLE WHERE idguia=108
GO



-- Con un Producto descontinuado
SELECT * FROM PRODUCTO WHERE IdProducto=138  
GO
-- El stock actual del producto 138 es 256
-- Le cambiamos el valor a Descontinuado a 1
UPDATE PRODUCTO SET Descontinuado=1 WHERE IdProducto = 138  
GO
SELECT * FROM PRODUCTO WHERE IdProducto=138  
GO

DECLARE @ret INT
EXEC @ret = spu_inserta_deta_guia 108,138,50
SELECT @ret
GO

/*  Tarea para la siguiente Sesion:
Crear un store procedure en MarketPeru que al ingresar un detalle de 
compra actualice en forma automática el stock del producto comprado. 
Para probar el store procedure debe ingresar primero una nueva compra, 
y luego ingresar un detalle de la nueva compra utilizando el 
store procedure que se ha creado.*/





--===============================================

/* 				     TRIGGERS                                                             */

-- Este demo1 debe ejecutar paso a paso, batch por batch

-- Establecer la base de datos
USE MASTER
GO
DROP DATABASE EduTec
GO
-- VOLVER A INSTALAR EDUTEC

USE EDUTEC
GO
-- Paso 01 Creación de un desencadenante AFTER para INSERT
CREATE TRIGGER TR_INSERT_CURSO
ON CURSO
AFTER INSERT
AS
PRINT 'SE HA EJECUTADO TRIGGER AFTER DE INSERT'
GO
-- Paso 02 Probar el trigger
SELECT * FROM Curso
GO
-- Con una clave duplicada:
INSERT CURSO VALUES( 'C001','A','MICROSOFT WORD')
GO
SELECT * FROM Curso
GO
-- Paso 03 Probar el trigger Con un clave nueva
INSERT CURSO VALUES( 'C902','A','MICROSOFT WORD')
GO
SELECT * FROM CURSO
GO
-- Paso 04  Eliminar el trigger
DROP TRIGGER tr_insert_curso
GO
-- Paso 05 Creación de un desencadenante INSTEAD OF para INSERT
CREATE TRIGGER tr_insert_curso
ON curso
INSTEAD OF INSERT
AS
PRINT 'Se ha ejecutado Triger INSTEAD OF de INSERT'
GO
-- Paso 06 Probar el trigger   Con una clave duplicada:
SELECT * FROM CURSO
GO
INSERT curso VALUES( 'C005','A','Microsoft Word')
GO
SELECT * FROM CURSO
GO
-- Paso 07 Probar el trigger   Con una clave nueva
INSERT CURSO VALUES( 'C111','A','Microsoft Word')
GO
SELECT * FROM CURSO
GO
-- Paso 08 
-- Modificando el desencadenante INSTEAD OF para INSERT
ALTER TRIGGER tr_insert_curso
ON CURSO
INSTEAD OF INSERT
AS
PRINT 'SE HA EJECUTADO TRIGER INSTEAD OF DE INSERT'
PRINT 'EL CONTENIDO DE LA TABLA INSERTED ES:'
SELECT * FROM INSERTED
GO
-- Paso 09 Probar el trigger Con una clave duplicada:
INSERT CURSO VALUES( 'C003','A','MICROSOFT WORD')
GO
SELECT * FROM CURSO
GO
-- Paso 10 Probar el trigger Con una clave nueva
INSERT CURSO VALUES( 'C333','A','MICROSOFT WORD')
GO
SELECT * FROM CURSO
GO
SELECT * FROM INSERTED
GO
-- Paso 11 Modificando el desencadenante INSTEAD OF para INSERT
ALTER TRIGGER tr_insert_curso
ON curso
INSTEAD OF INSERT
AS
PRINT 'Se ha ejecutado Triger INSTEAD OF de INSERT'
PRINT 'El contenido de la tabla inserted es:'
SELECT * FROM inserted
INSERT INTO curso SELECT * FROM inserted
GO
-- Paso 12 Probar el trigger   Con una clave duplicada:
INSERT CURSO VALUES( 'C003','A','MICROSOFT WORD')
GO
SELECT * FROM CURSO
GO
-- Paso 13 Probar el trigger  Con una clave nueva
INSERT curso VALUES( 'C502','A','Microsoft Excel')
go
SELECT * FROM CURSO
GO
-- Paso 14  Eliminar el desencadenante
Drop trigger tr_insert_curso
GO
-- Paso 15 Trigger que cancela una Transacción
CREATE TRIGGER tr_insert_curso
ON curso
AFTER INSERT
AS
PRINT 'SE HA EJECUTADO TRIGER AFTER DE INSERT'
SELECT * FROM INSERTED
PRINT 'SE CANCELA LA INSERCIÓN'
ROLLBACK TRAN
GO
-- Paso 16 Probar el trigger Con una clave duplicada
INSERT CURSO VALUES( 'C002','A','MICROSOFT ACCESS')
GO
SELECT * FROM CURSO
GO
-- Paso 16 B Probar el trigger Con una clave nueva
INSERT CURSO VALUES( 'C222','A','MICROSOFT ACCESS')
GO
SELECT * FROM CURSO
GO
-- Paso 17 Eliminar el desencadenante
DROP TRIGGER tr_insert_curso
GO
--



--
--
--
--
--
--
--



-- Este demo2 debe ejecutar paso a paso, batch por batch
-- Establecer la base de datos
USE edutec
GO
