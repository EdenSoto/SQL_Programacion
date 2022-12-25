/*
SQL 3 - Sesión 3 


*/


-- Procedimientos Almacenados 
-- con parametros que recibe: 
-- (Paramentros de Entrada)
--==================================================
USE Pruebas
GO
SP_HELP CLIENTES
GO
SELECT * FROM Clientes
GO
CREATE PROCEDURE Agregarclientes
(	@xcod			INT, 
	@xnombre	CHAR(30),
	@xciudad	VARCHAR(15),
	@xtelefono	VARCHAR(8) = '000-0000' )
AS
INSERT INTO CLIENTES 
 VALUES(@xcod,@xnombre,@xciudad,@xtelefono)
SELECT * FROM CLIENTES
GO
--EJECUCION
SELECT * FROM CLIENTES
GO
EXEC Agregarclientes
GO
EXEC Agregarclientes 8
GO
EXEC Agregarclientes 6,'Pedro Perez','Huaraz','4568741'
GO

EXEC Agregarclientes 7,'Vilma Perez','Huaraz'
GO

SELECT*FROM CLIENTES
GO
--
--
--Crear un SP en la BD Edutec que permita ingresar un profesor
--si se omitiera el dato de la direccion,su valor predeterminado
--sera Lima
USE EduTec
GO
SP_HELP PROFESOR
GO
SELECT * FROM Profesor
GO
CREATE PROCEDURE AgregarProfesor	
(	@cod					CHAR(4),							
	@ape					VARCHAR(30),
	@Nomprofesor	VARCHAR(30),	
	@tel						VARCHAR(12),
	@email				VARCHAR(50),				
	@dirprof				VARCHAR(50) = 'LIMA'	)
AS
INSERT INTO Profesor
(IdProfesor, ApeProfesor, NomProfesor,	TelProfesor,	EmailProfesor, DirProfesor)
VALUES 
(@cod, @ape, @Nomprofesor, @tel, @email, @dirprof	)
SELECT * FROM Profesor
GO
SELECT * FROM PROFESOR
GO
EXEC AgregarProfesor 
'P050','ARIAS','MARIBEL','5447781','abcd@yahoo.es','SAN ISIDRO'
GO
EXEC AgregarProfesor 
'P060','VILLALOBOS','EDITA','4667731','edita@yahoo.es'
GO
/*EN LA bd NORTHWIND, CREAR UNA SP QUE PERMITA INGRESAR 
UN PROVEEDOR. CONSIDERAR PARA EL DATO DEL PAIS, 
COMO VALOR PREDETERMINADO A PERU.
USAR SOLO LOS DATOS QUE SON INDISPENSABLES                                        */
USE Northwind
GO
select*from Suppliers
go
sp_help suppliers
go

create procedure AgregarProveedor
(@Nom nvarchar(40),@pais nvarchar(15)='Peru')
as
insert into Suppliers
(CompanyName,Country)
values
(@Nom,@pais)
select*from Suppliers
go
  ---

  CREATE PROCEDURE AgregarProveedor	
(	@compa				NVARCHAR(80),							
	@count				NVARCHAR(30) = 'PERU')
AS
INSERT INTO SUPPLIERS
(CompanyName,Country)
VALUES 
(@compa, @count)
SELECT * FROM SUPPLIERS
GO

---


create procedure IngresarProveedor
(@cname nvarchar(40),@country nvarchar(15)='Peru')
as
INSERT INTO SUPPLIERS (CompanyName, Country)
VALUES 
(@cname, @country)


---



SELECT * FROM Suppliers
GO
SP_HELP SUPPLIERS
GO

--- SOLUCIÓN

CREATE PROCEDURE INGRESAR_PROVEEDOR
	@CompanyName		NVARCHAR(40),
	@Country					NVARCHAR(15) = 'PERU'
AS
INSERT INTO Suppliers (CompanyName,Country)
					     VALUES(@CompanyName,@Country)
SELECT * FROM Suppliers
GO

EXEC INGRESAR_PROVEEDOR 'ALFA'
GO
EXEC INGRESAR_PROVEEDOR 'HOME CENTER','CHILE'
GO



/*
	EJERCICIO
Crear un Sp en MarketPERU, 
para ingresar un nuevo Local.
Con todos sus datos.
Si no se especificara el Distrito, 
el sistema asumira "Independencia"
*/
--
USE MarketPERU
GO
SP_HELP LOCAL
GO

---
use MarketPERU
go
sp_help LOCAL;

select * from LOCAL
go
create proc sp_IngresaLocal
@IdLocal int,
@Direccion varchar(60),
@Telefono varchar(15),
@Fax varchar(15),
@Distrito varchar(20) = 'Independencia'
as
insert into LOCAL (IdLocal, Direccion, Telefono, Fax,Distrito)
values(@IdLocal,@Direccion,@Telefono,@Fax,@Distrito);

exec sp_IngresaLocal 6,	'AV. ESPAÑA', '775448','123456';

SELECT * FROM LOCAL
GO

---


--  Uso del Valor de Retorno 
-- (RETURN VALUE)
USE Pruebas
GO
SELECT * FROM CLIENTES
GO


CREATE PROCEDURE ClienteRepetido
	@xcod INT 
AS
IF (SELECT COUNT(*) FROM CLIENTES WHERE Cod_cli = @xcod) > 1
	RETURN 1
ELSE
	RETURN 2
GO
--EJECUCION
EXEC ClienteRepetido
go

EXEC ClienteRepetido 3
go
DECLARE @Existe INT
EXEC @Existe = ClienteRepetido 3
GO

select * from Clientes
go
DECLARE @Existe INT
EXEC @Existe = ClienteRepetido 6
SELECT @Existe
GO

DECLARE @Existe INT
EXEC @Existe = ClienteRepetido 2
SELECT @Existe
GO

--CREAR UN SP EN LA BD MARKETPERU QUE VERIFIQUE 
-- MEDIANTE UN RETURN VALUE
-- SI EL STOCK DEL PRODUCTO ESTA 
-- POR DEBAJO DEL MINIMO PERMITIDO.

USE MarketPERU
GO
SELECT 
IdProducto,Nombre,StockActual,StockMinimo 
FROM PRODUCTO
GO
SELECT 
IdProducto,Nombre,StockActual,StockMinimo 
FROM PRODUCTO WHERE StockActual < StockMinimo
GO
SP_HELP PRODUCTO
GO
CREATE PROCEDURE spu_VerificaMin
@cod INT
AS
IF 
(SELECT StockActual  FROM PRODUCTO WHERE IdProducto = @cod ) 
	< 
(SELECT StockMinimo FROM PRODUCTO WHERE IdProducto = @cod ) 
	RETURN 4
ELSE
	RETURN 5
GO
-- PROBANDO EL SP
DECLARE @X INT
EXEC @X  = spu_VerificaMin 26
SELECT @X
GO
SELECT 
IdProducto,Nombre,StockActual,StockMinimo 
FROM PRODUCTO WHERE IdProducto = 26
GO
-- OTRO CASO
DECLARE @X INT
EXEC @X  = spu_VerificaMin 27
SELECT @X
GO
-- VERIFICANDO
SELECT IdProducto,Nombre,StockActual,StockMinimo 
FROM PRODUCTO WHERE IdProducto = 27
GO
/*****************************
En MarketPeru crear un SP que verifique si el stock de un producto 
esta por debajo de una cantidad determinada, para saber si se puede
 vender a no el producto.  
Usar un RETURN Value. */
USE MarketPERU
GO
SELECT * FROM PRODUCTO
GO
CREATE PROCEDURE spu_VerificaCantidad
	@cp INT, @Can INT  
AS
IF 
(SELECT StockActual FROM PRODUCTO WHERE IdProducto=@cp) < @Can
   	RETURN 7
ELSE
	RETURN 2
GO
-- PROBANDO EL SP
SELECT * FROM PRODUCTO WHERE IdProducto = 10
GO
DECLARE @x INT
EXEC @x = spu_VerificaCantidad 10,800
PRINT @x
GO
-- OTRA PRUEBA
DECLARE @x INT
EXEC @x = spu_VerificaCantidad 10,901
PRINT @x
GO

DECLARE @x INT
EXEC @x = spu_VerificaCantidad 10,900
PRINT @x
GO


--******
--CON PARAMETROS DE ENTRADA Y SALIDA (QUE RECIBE Y DEVUELVE)
USE Pruebas
GO
SP_HELP CLIENTES
GO
CREATE PROCEDURE buscarCliente
	@xcod INT,
	@xnombre CHAR(30) OUTPUT
AS
SELECT @xnombre = nombre FROM CLIENTES
WHERE Cod_cli=@xcod
GO
--PROBANDO EN EJECUCION
DECLARE @xnom CHAR(30)
EXEC buscarCliente 2, @xnom OUTPUT
SELECT @xnom
GO

-- ORO CASO
DECLARE @xnom CHAR(30)
EXEC buscarCliente 5, @xnom OUTPUT
SELECT @xnom
GO

/*Crear un Sp en Pubs que al ingresarle 
   el codigo de un libro, 
   devuelva el Titulo del mismo.             */
USE PUBS
GO
SP_HELP TITLES
GO
CREATE PROCEDURE BUSCAR_LIBRO
	@xcod			VARCHAR(6),
	@xnombre	VARCHAR(80) OUTPUT
AS
	SELECT @xnombre = title FROM titles
	WHERE title_id = @xcod
GO
--PROBANDO EL SP
SELECT * FROM titles WHERE title_id='BU2075'
go
DECLARE @xnom VARCHAR(80)
EXEC BUSCAR_LIBRO 'BU2075',@xnom OUTPUT
SELECT @xnom
GO
SELECT * FROM titles
GO



--   PC9999

DECLARE @xnom VARCHAR(80)
EXEC BUSCAR_LIBRO 'PC9999',@xnom OUTPUT
SELECT @xnom
GO

declare @xnom varchar(80)
exec buscar_libro 'pc1035',@xnom output
select @xnom
go


/*CREAR EN MARKETPERU UN SP QUE DEVUELVA EL NOMBRE 
DE UN PRODUCTO, CUANDO SE LE ENTREGUE EL CODIGO DEL
 PRODUCTO COMO DATO DE ENTRADA */

USE MarketPERU
GO
SP_HELP PRODUCTO
GO
CREATE PROCEDURE BuscarProducto
	@cod INT,
	@nombre VARCHAR(40) OUTPUT
AS
SELECT @nombre = nombre FROM PRODUCTO
WHERE idproducto = @cod
GO
-- PROBANDO EL SP
DECLARE @n VARCHAR(40)
EXEC BuscarProducto 60, @n OUTPUT
SELECT @n
GO
DECLARE @n VARCHAR(40)
EXEC BuscarProducto 106, @n OUTPUT
SELECT @n
GO
SELECT *FROM PRODUCTO
GO


--====================================================
/* Crear un SP en Marketperu, que al entregarle el codigo 
de un producto, devuelva el nombre del producto y 
el nombre del Proveedor.    */

USE MarketPERU
GO
SELECT 
	*
FROM		PRODUCTO		P
INNER JOIN	PROVEEDOR	PV ON P.IdProveedor=PV.IdProveedor
GO

SELECT 
	P.IdProducto, 
	P.nombre, 
	PV.nombre
FROM			    PRODUCTO		P
INNER JOIN	PROVEEDOR	PV ON P.IdProveedor=PV.IdProveedor
GO

SELECT 
	P.IdProducto,	
	p.nombre,
	PV.nombre
FROM			PRODUCTO	P
INNER JOIN	PROVEEDOR PV ON P.IdProveedor=PV.IdProveedor
WHERE P.IdProducto = 5
GO

-- 5	CHUPETES LOLY AMBROSOLI	        DISTRIBUIDORA DE GOLOSINAS FENIX
-- Convirtiendo la Consulta en SP

CREATE PROCEDURE spu_buscaprod
	@cp   INT,		
	@npd VARCHAR(40) OUTPUT, 
	@pv   VARCHAR(40) OUTPUT
AS
SELECT @npd = P.nombre, @pv = PV.nombre
FROM 				PRODUCTO		P
INNER JOIN	PROVEEDOR	PV ON P.IdProveedor=PV.IdProveedor
WHERE P.IdProducto = @cp
GO
-- Probando el SP
DECLARE @X VARCHAR(40), @Y VARCHAR(40)
EXEC spu_buscaprod 75, @X OUTPUT, @Y OUTPUT
SELECT @X, @Y
GO
DECLARE @X VARCHAR(40), @Y VARCHAR(40)
EXEC spu_buscaprod 5, @X OUTPUT, @Y OUTPUT
SELECT @X, @Y
GO

/*Crear un SP en la bd PUBS, que al ingresarle el 
codigo de un libro presente: 
el nombre  del libro y el nombre de la editorial */
USE PUBS
GO
sp_help publishers
go
sp_help titles
go
--CONSULTA

SELECT 
*
FROM		titles		T
INNER JOIN	publishers	P	ON T.pub_id=P.pub_id
GO


SELECT 
	T.title_id,
	T.title,
	P.pub_name
FROM				titles			T
INNER JOIN	publishers	P	ON T.pub_id=P.pub_id
GO

SELECT 
	T.title_id,
	T.title,
	P.pub_name
FROM		titles		T
INNER JOIN	publishers	P	ON T.pub_id=P.pub_id
WHERE T.title_id = 'BU1032'
GO
-- BU1032	
-- The Busy Executive's Database Guide	
-- Algodata Infosystems
CREATE PROCEDURE BUSCA_LIBRO
	@cod				varchar(6),
	@nomlibro		varchar(80) OUTPUT,
	@nomedit		varchar(40) OUTPUT
AS
	SELECT 
		@nomlibro=T.title, 
		@nomedit=P.pub_name
	FROM			  titles		  T
	INNER JOIN publishers P 	ON T.pub_id=P.pub_id
	WHERE T.title_id=@cod
GO


DECLARE @X VARCHAR(80)
DECLARE @y VARCHAR(40)
EXEC BUSCA_LIBRO 'BU1032', @X OUTPUT, @y OUTPUT 
SELECT @X, @y
GO

DECLARE @X VARCHAR(80)
DECLARE @y VARCHAR(40)
EXEC BUSCA_LIBRO 'bu2075',@X OUTPUT, @y OUTPUT 
SELECT @X, @y
GO

SELECT * FROM titles
GO

-- MC2222
DECLARE @X VARCHAR(80)
DECLARE @y VARCHAR(40)
EXEC BUSCA_LIBRO 'MC2222',@X OUTPUT, @y OUTPUT 
SELECT @X, @y
GO

/*Crear un SP que al entregarle 
el codigo de un libro devuelva, 
El titulo del libro, 
los apellidos y nombres del autor
*/


USE PUBS
GO
SELECT 
T.title_id, T.title, A.au_lname, A.au_fname
FROM		ITLES			T
INNER JOIN	TITLEAUTHOR		TA	ON T.title_id = TA.title_id
INNER JOIN	AUTHORS			A   ON  TA.au_id = A.au_id
GO
SELECT 
	T.title_id, 
	T.title, 
	A.au_lname, 
	A.au_fname
FROM		TITLES		T
INNER JOIN TITLEAUTHOR	TA	ON T.title_id = TA.title_id
INNER JOIN AUTHORS		A   ON TA.au_id = A.au_id
WHERE T.title_id ='PC1035'
GO

--- TAREA terminar el sp Correspondiente


--Todo presentarlo en unArchivo de Word


