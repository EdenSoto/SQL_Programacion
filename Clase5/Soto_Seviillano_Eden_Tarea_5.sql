--=======================================================
--Curso:SQL 3 
--Tema:Tarea 5
--Alumno:Soto S,Eden Persi
--Profesor:Julio Enrique Flores Manco
--Fecha:26/03/2022 
--=======================================================

/*  Tarea para la siguiente Sesion:
Crear un store procedure en MarketPeru que al ingresar un detalle de 
compra actualice en forma automática el stock del producto comprado. 
Para probar el store procedure debe ingresar primero una nueva compra, 
y luego ingresar un detalle de la nueva compra utilizando el 
store procedure que se ha creado.*/

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
	SELECT	 @precio = PrecioProveedor  FROM PRODUCTO 
	WHERE IdProducto = @idproducto
	DECLARE @stock SMALLINT
IF (@idOrden IS NULL) OR (@idproducto IS NULL) OR (@cantidadS IS NULL)  
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
IF NOT EXISTS (SELECT IdOrden FROM ORDEN WHERE IdOrden=@idOrden)
	BEGIN
		PRINT 'LA ORDEN NO EXISTE'
		RETURN 3
	END
SELECT 
	@stock = StockActual, @desc = Descontinuado 
FROM PRODUCTO WHERE IdProducto = @idproducto
IF @desc = 1
	BEGIN
		PRINT 'EL PRODUCTO ESTÁ DISCONTINUADO'
		RETURN 4
	END
BEGIN TRAN
	UPDATE PRODUCTO SET StockActual = StockActual + @cantidadS
		WHERE IdProducto=@idproducto
	INSERT INTO ORDEN_DETALLE(IdOrden,IdProducto,PrecioCompra,CantidadSolicitada)
	VALUES(@idOrden, @idproducto, @precio, @cantidadS)
IF @@ERROR <> 0
	BEGIN
		PRINT 'ERROR EN LA BD'
		ROLLBACK TRAN
		RETURN 5
	END
COMMIT TRAN
	RETURN 0
GO
--

SP_HELP spu_Ingresar_Pedido
GO
SELECT * FROM ORDEN
GO
SP_HELP ORDEN
GO
INSERT INTO ORDEN VALUES(19,'20220328','20220329')
GO
SELECT * FROM ORDEN WHERE IdOrden = 19
SELECT * FROM ORDEN_DETALLE WHERE IdOrden = 19
GO
--Probando SP:
SELECT * FROM PRODUCTO WHERE IdProducto=1 
-- STOCK = 190
DECLARE @ret INT
EXEC @ret = spu_Ingresar_Pedido 19,1,60
SELECT @ret
GO
SELECT * FROM PRODUCTO WHERE IdProducto=1 
SELECT * FROM ORDEN_DETALLE WHERE IdOrden=19
GO
-- Ahora el stock esta en 250( se le aumentó 60 )
-- Hay un detalle para la guia 19

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
EXEC @ret = spu_Ingresar_Pedido 19,138,50
SELECT @ret
GO