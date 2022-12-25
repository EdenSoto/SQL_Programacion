/*
Triggers secuenciales
*/



--
--

--*************************************************************************************

/*
En la bd MarketPeru crear un Trigger que al momento de ingresar 
Detalle de venta verifique si el stock después de realizar la venta 
será menor o igual al stock mínimo establecido; 
si así fuera presentar un mensaje 
de advertencia que el e stock se encuentra 
por debajo del mínimo establecido.
*/
USE MASTER
GO
DROP DATABASE MarketPERU
GO
/*

Crear nuevamente la BD con el Script que peoporciono el docente anteriormente.

*/

USE MarketPERU
GO
CREATE TRIGGER tr_verMin
ON GUIA_DETALLE
AFTER INSERT
AS
DECLARE @Stock SMALLINT, @Can SMALLINT
SELECT @Stock = P.StockActual, @Can = I.Cantidad
FROM PRODUCTO P, Inserted I
	WHERE P.IdProducto = I.IdProducto
IF @Stock < @Can
	BEGIN
		PRINT 'No hay suficiente Stock para realizar la venta'
		ROLLBACK TRAN
	END
ELSE
	BEGIN
		UPDATE PRODUCTO 
		SET StockActual = StockActual - @Can
		FROM Inserted I
		WHERE PRODUCTO.IdProducto = I.IdProducto
	 END
GO

CREATE TRIGGER BajoStock
ON PRODUCTO
AFTER UPDATE
AS
DECLARE @Stock SMALLINT,@StMin SMALLINT
SELECT @Stock = P.StockActual, @StMin=P.StockMinimo
FROM PRODUCTO P, inserted I
WHERE P.IdProducto=I.IdProducto
 IF @Stock < @StMin
	  		     BEGIN
				 PRINT 'El producto esta por debajo del Stock minimo'
 END
GO

SELECT * FROM PRODUCTO WHERE IdProducto = 1
GO

--																	Precio   StkAc    StkMin        Descont
-- CARAMELOS BASTON VIENA ARCOR  1.50        200			50	           0
SELECT * FROM GUIA
GO
SP_HELP GUIA
GO
INSERT INTO GUIA VALUES (108,2,GETDATE(),'ALIAGA VIDAL, JEREMIAS')
GO
SELECT * FROM GUIA WHERE IdGuia=108
SELECT * FROM GUIA_DETALLE WHERE IdGuia=108
GO
-- IdGuia=108  ;  IdProducto=1 ; PrecioVenta=1.5 ; Cantidad=260 
INSERT INTO GUIA_DETALLE VALUES (108,1,1.5,260)
GO
SELECT * FROM PRODUCTO WHERE IdProducto = 1
GO
-- 260 es mayor que el stock actual que es 200, por lo tanto no se puede vender
/*
No hay suficiente Stock para realizar la venta
Mens. 3609, Nivel 16, Estado 1, Línea 197
La transacción terminó en el desencadenador. Se anuló el lote.
*/
--Ahora tratamos de vender 160 unidades, lo cuales menor que elstock actual que es 200; 
-- si se podra vender, pero el stock actual quedara en 40 
-- 40 es menos que 50 que es el Stock minimo. 
-- Luego saldra una advertencia que se encuentran debajo del minimo permitido
SELECT * FROM GUIA_DETALLE WHERE IdGuia=108
GO

--																	Precio   StkAc    StkMin        Descont
-- CARAMELOS BASTON VIENA ARCOR  1.50        200			50	           0

INSERT INTO GUIA_DETALLE VALUES (108,1,1.5,160)
GO

-- verificando como quedaron las tablas

SELECT * FROM GUIA_DETALLE WHERE IdGuia=108
GO
SELECT * FROM PRODUCTO WHERE IdProducto = 1
GO

--
--


