--================================================================
--	EJEMPLO DE UNA TRANSACCION QUE CONTROLA
--		 UN PROCESO DE VENTA
--================================================================

USE Master
GO

--***********************************
-- Crear la base de datos WILSON_MARKET 
--   ( debe existir la carpeta Data en la unidad E:\ ) 
--***********************************
USE MASTER
GO
CREATE DATABASE WILSON_MARKET
ON PRIMARY
( NAME = 'WILSON_MARKET_Data',
   FILENAME = 'D:\FIEE_DATA\WILSON_MARKET_Data.mdf',
   SIZE = 5,
   MAXSIZE = 200,
   FILEGROWTH = 1 )
LOG ON
( NAME = 'WILSON_MARKET_Log',
   FILENAME = 'D:\FIEE_DATA\WILSON_MARKET_Log.ndf',
   SIZE = 1MB,
   MAXSIZE = 100MB,
   FILEGROWTH = 1MB )
GO


USE WILSON_MARKET
GO

--****************************
-- Crear la tabla PRODUCTO
--****************************

CREATE TABLE PRODUCTO
  (
    ProCodigo 	INT IDENTITY(1,1) NOT NULL, 
    ProNombre 	VARCHAR(50) NOT NULL,
    ProPrecio 	DECIMAL(10,2) NOT NULL,
    ProStock 	INT NOT NULL
  )
GO

 
--******************************************************
-- Modificar la tabla para crear el PK (Primary key)
--******************************************************

ALTER TABLE PRODUCTO
    ADD CONSTRAINT pkProCodigo PRIMARY KEY (ProCodigo)
GO

--*******************************************
-- Modificar la tabla para crear un CHECK
--*******************************************

ALTER TABLE PRODUCTO
    ADD CONSTRAINT ckProStock CHECK (ProStock >= 0)
GO

--***********************************
-- Crear la tabla FACTURA
--***********************************

CREATE TABLE FACTURA
  (
    FacNumero 			INT IDENTITY(1,1) NOT NULL, 
    FacFecha 			DATETIME NOT NULL,
    FacRazonSocial 	VARCHAR(50) NOT NULL,
	 FacRUC				CHAR(11) NOT NULL
  )
GO

--************************************************************
-- Modificar la tabla para crear el PK (Primary key)
--************************************************************

ALTER TABLE FACTURA
    ADD CONSTRAINT pkFacNumero PRIMARY KEY (FacNumero)
GO

--*******************************************
-- Modificar la tabla para crear un DEFAULT
--*******************************************

ALTER TABLE FACTURA
    ADD CONSTRAINT dfFacFecha DEFAULT GetDate() FOR FacFecha
GO

 
--*******************************************
-- Modificar la tabla para crear un CHECK
--*******************************************

ALTER TABLE FACTURA
   ADD CONSTRAINT ckFacRUC 
	CHECK 
	(FacRUC Like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
GO


--***********************************
-- Crear la Tabla DETALLE
--***********************************

CREATE TABLE DETALLE
  (
    FacNumero		INT NOT NULL, 
    ProCodigo		INT NOT NULL,
    DetPrecio 		DECIMAL(10,2) NOT NULL,
    DetCantidad 	INT NOT NULL
  )
GO

--************************************************************
-- Modificar la tabla para crear el PK (Primary key)
--************************************************************

ALTER TABLE DETALLE
    ADD CONSTRAINT pk_DETALLE PRIMARY KEY (FacNumero, ProCodigo)
GO

--*******************************************
-- Modificar la tabla para crear un CHECK
--*******************************************

ALTER TABLE DETALLE
   ADD CONSTRAINT ckDetCantidad CHECK (DetCantidad > 0)
GO

--********************************************************
-- Modificar la tabla para crear los FK (Foreign Key)
--********************************************************

ALTER TABLE DETALLE
		ADD CONSTRAINT fk_FacNumero 
		FOREIGN KEY (FacNumero) REFERENCES FACTURA
GO

ALTER TABLE DETALLE
      ADD CONSTRAINT fk_ProCodigo 
		FOREIGN KEY (ProCodigo) REFERENCES PRODUCTO
GO


Use WILSON_MARKET
GO

--**************************************************
-- Agregar registros de ejemplo a la tabla PRODUCTO
--**************************************************
INSERT Producto (ProNombre, ProPrecio, ProStock) Values('Monitor',150,100)
INSERT Producto (ProNombre, ProPrecio, ProStock) Values('Mouse',10,100)
INSERT Producto (ProNombre, ProPrecio, ProStock) Values('Disco Duro',80,100)
INSERT Producto (ProNombre, ProPrecio, ProStock) Values('Teclado',15,100)
INSERT Producto (ProNombre, ProPrecio, ProStock) Values('CD-ROM',80,100)
INSERT Producto (ProNombre, ProPrecio, ProStock) Values('Diskettera',19,100)
INSERT Producto (ProNombre, ProPrecio, ProStock) Values('Impresora',90,100)
INSERT Producto (ProNombre, ProPrecio, ProStock) Values('Parlantes',30,100)
GO

--********************************************
-- Mostrar los registros de las tablas 
--********************************************
SELECT * FROM PRODUCTO
SELECT * FROM FACTURA
SELECT * FROM DETALLE
GO
USE WILSON_MARKET
GO
--****************************************
-- Creando el Procedimiento Almacenado 
-- para guardar la FACTURA, guardar los detalles y 
-- actualizar el stock en la tabla producto
--****************************************

CREATE PROCEDURE usp_Venta
@FacNumero 	 INT  OUTPUT,      @FacRazonSocial 	VARCHAR(50), 
@FacRUC         CHAR(11),      @Detalle	        VARCHAR(500)
AS
	SET NOCOUNT ON	
		
	BEGIN TRANSACTION 

	DECLARE @varError INT, @varRegAfec INT, @varCASO INT
	DECLARE @ProCodigo INT, @DetPrecio DECIMAL(10,2), @DetCantidad INT

INSERT INTO FACTURA (FacRazonSocial, FacRUC) 
             VALUES (@FacRazonSocial, @FacRUC)

SELECT @varError = @@ERROR, @varRegAFec = @@ROWCOUNT, @varCASO = 1
	IF @varError<>0 OR @varRegAfec = 0
		GOTO MensajeError

	SET @FacNumero = @@IDENTITY

	WHILE LEN(@Detalle) > 0        -- AQUI EMPIEZA EL BUCLE HASTA QUE @Detalle SEA CERO OSEA QUE YA NO HAYA DETALLES
	  BEGIN
		 SET @ProCodigo = CONVERT(INT, LEFT(@Detalle, CHARINDEX(',',@Detalle,1) - 1))
		 SET @Detalle = RIGHT(@Detalle, LEN(@Detalle) - CHARINDEX(',',@Detalle,1))

		 IF CHARINDEX(',',@Detalle,1) = 0 
			BEGIN
				SET @DetCantidad = CONVERT(INT, @Detalle)
				SET @Detalle = ''
			END
		 ELSE
			BEGIN
				SET @DetCantidad = CONVERT(INT, LEFT(@Detalle, CHARINDEX(',',@Detalle,1) - 1))
				SET @Detalle = RIGHT(@Detalle, LEN(@Detalle) - CHARINDEX(',',@Detalle,1))
			END

SELECT @DetPrecio = ProPrecio FROM PRODUCTO 
WHERE ProCodigo = @ProCodigo 

SELECT @varError = @@ERROR, @varRegAFec = @@ROWCOUNT, @varCASO = 2

		IF @varError<>0 OR @varRegAfec = 0
			GOTO MensajeError

INSERT INTO DETALLE 
	VALUES (@FacNumero, @ProCodigo, @DetPrecio, @DetCantidad)

SELECT @varError = @@ERROR, @varRegAFec = @@ROWCOUNT, @varCASO = 3

IF @varError<>0 OR @varRegAfec = 0    GOTO MensajeError
			
UPDATE PRODUCTO SET ProStock = ProStock - @DetCantidad 
   						WHERE ProCodigo = @ProCodigo			
SELECT @varError = @@ERROR, @varRegAFec = @@ROWCOUNT, @varCASO = 4

IF @varError<>0 OR @varRegAfec = 0    GOTO MensajeError

END	--  AQUI SE REGRESA AL PRINCIPIO DEL BUCLE
	
-- GUARDAR LA TRANSACCION ACTUAL
COMMIT TRANSACTION
	RETURN 0
	
MensajeError:
	-- CANCELAR LA TRANSACCION ACTUAL
      ROLLBACK TRANSACTION
            IF @varCASO = 1
		RAISERROR('ERROR: Al insertar la cabecera de la FACTURA',16,1)
	IF @varCASO = 2
		RAISERROR('ERROR: Al Seleccionar un PRODUCTO',16,1)
	IF @varCASO = 3
		RAISERROR('ERROR: Al insertar un detalle de la FACTURA',16,1)
	IF @varCASO = 4
		RAISERROR('ERROR: Al actualizar un PRODUCTO',16,1)

      SET @FacNumero = 0
	 RETURN 1
GO
 
--****************************************
-- PROBANDO el Procedimiento Almacenado 
--****************************************

-- LAS TABLAS ANTES DE APLICAR EL STORE

 

DECLARE @Numero INT 
EXEC usp_Venta 
	@FacNumero 		 = @Numero OUTPUT,
	@FacRazonSocial =	'PERUDEV',
	@FacRUC 			 =	'12345678900',
	@Detalle			 =	'2,4,5,2,8,3'   
SELECT @Numero AS FacNumero
GO
-- LAS TABLAS DESPUES DE APLICAR EL STORE
SELECT * FROM FACTURA
SELECT * FROM DETALLE
SELECT * FROM PRODUCTO
GO

-----------------------------------------------------------------------------------------------------------
--Prueba con un error en el cod de un producto:

DECLARE @Numero INT 
EXECUTE usp_Venta @Numero OUTPUT,'XXXXX','44445556672','1,2,3,4,11,6'   
 SELECT @Numero AS FacNumero
GO
/*
Servidor: mensaje 50000, nivel 16, estado 1, procedimiento usp_Venta, línea 70
ERROR: Al Seleccionar un PRODUCTO

(1 filas afectadas)
*/
-----------------------------------------------------------------------------------------------------------

DECLARE @Numero INT 
EXECUTE usp_Venta @Numero OUTPUT,'GLORIA','12345678901','1,1,2,1,5,99'   
SELECT @Numero AS FacNumero
GO
SELECT * FROM FACTURA
SELECT * FROM DETALLE
SELECT * FROM PRODUCTO
GO
/*

Servidor: mensaje 2627, nivel 14, estado 1, procedimiento usp_Venta, línea 45
Infracción de la restricción PRIMARY KEY 'pk_DETALLE'. No se puede insertar una clave duplicada en el objeto 'DETALLE'.
Servidor: mensaje 50000, nivel 16, estado 1, procedimiento usp_Venta, línea 72
ERROR: Al insertar un detalle de la FACTURA
Se terminó la instrucción.

(1 filas afectadas)



*/
-----------------------------------------------------------------------------------------------------------


-- PROBANDO LAS FUNCIONES APLICADAS

SELECT '1,M,3,4,P,6,9,3' AS  [CADENA='1,M,3,4,P,6,9,3']
SELECT LEN('1,M,3,4,P,6,9,3') AS [LEN('1,M,3,4,P,6,9,3')]
SELECT CHARINDEX('P','1,M,3,4,P,6,9,3',1) AS [CHARINDEX('P','1,M,3,4,P,6,9,3',1)]
--CHARINDEX   Devuelve la posición inicial de la expresión especificada en una cadena de caracteres. 
--Sintaxis    CHARINDEX ( expression1 , expression2 [ , start_location ] ) 
/*
Argumentos
expression1     Es una expresión que contiene la secuencia de caracteres que se desea buscar. 
                expression1 es una expresión del tipo de cadenas cortas de caracteres.
expression2     Es una expresión, normalmente una columna, en la que se busca la cadena especificada. 
                expression2 es de la categoría del tipo de datos cadena de caracteres.
start_location   Es la posición del carácter de expression2 en el que se empieza la búsqueda de expression1. 
                 Si no se especifica start_location, es un número negativo o es cero, 
                 la búsqueda empieza al principio de la cadena expression2.
*/

SELECT CHARINDEX('P','1,p,3,4,P,6,9,3',4)

SELECT LEN('1,M,3,4,P,6,9,3') - CHARINDEX('P','1,M,3,4,P,6,9,3',1)AS [LEN('1,M,3,4,P,6,9,3') - CHARINDEX('P','1,M,3,4,P,6,9,3',1)]
SELECT RIGHT('1,M,3,4,P,6,9,3',LEN('1,M,3,4,P,6,9,3') - CHARINDEX('P','1,M,3,4,P,6,9,3',1)) AS [RIGHT('1,M,3,4,P,6,9,3',LEN('1,M,3,4,P,6,9,3') - CHARINDEX('P','1,M,3,4,P,6,9,3',1))]
GO

--==============================================

SET NOCOUNT ON
SELECT * FROM PRODUCTO
GO
SET NOCOUNT OFF
GO
SELECT * FROM PRODUCTO
GO