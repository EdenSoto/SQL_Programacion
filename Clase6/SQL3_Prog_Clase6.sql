/*
SQL 3 -  Sesión 6

Lunes 28 de Marzo del 2022

7 pm 

*/
--********************************************


-- Este demo2 debe ejecutar paso a paso, 
-- batch por batch
-- Establecer la base de datos
USE edutec
GO  
-- Paso 01
-- Creación de un desencadenante
CREATE TRIGGER tr_insert_matricula
ON matricula
AFTER INSERT
AS
DECLARE @vacantes TINYINT, @activo BIT
SELECT @vacantes = CP.vacantes, @activo=CP.Activo 
FROM CursoProgramado CP, Inserted I
	WHERE CP.IdCursoProg = I.IdCursoProg
IF (@Vacantes = 0 OR @activo = 0)
	BEGIN
		PRINT 'No hay vacantes ó el curso ya no esta activo'
		ROLLBACK TRAN
	END
ELSE
	BEGIN
		UPDATE CursoProgramado 
		SET Vacantes = Vacantes - 1, Matriculados = Matriculados + 1
		FROM Inserted I
		WHERE CursoProgramado.IdCursoProg = I.IdCursoProg
		PRINT 'Base de Datos actualizada'
	END
GO

-- Paso 02 Probar el desencadenante cuando hay vacantes
SELECT * FROM CursoProgramado WHERE IdCursoProg = 1
SELECT * FROM matricula WHERE idcursoprog = 1
GO
INSERT INTO Matricula(IdCursoProg,IdAlumno,FecMatricula)
			             VALUES(1,'A0011','20220328')
GO
SELECT * FROM CursoProgramado WHERE IdCursoProg = 1
SELECT * FROM matricula WHERE idcursoprog = 1
GO
-- Paso 03 -- Probar el desencadenante cuando no hay vacantes
SELECT * FROM CursoProgramado WHERE IdCursoProg = 44
GO
UPDATE CursoProgramado	SET Vacantes = 0, Matriculados=20	
WHERE IdCursoProg = 44
GO
SELECT * FROM CursoProgramado WHERE IdCursoProg = 44
go
INSERT INTO Matricula(IdCursoProg, IdAlumno, FecMatricula)
	                  VALUES(44,'A0012','20220328')
GO
-- Paso 03b -- Probar el desencadenante cuando el curso no esta activo
SELECT * FROM CursoProgramado WHERE IdCursoProg = 43
GO
UPDATE CursoProgramado	SET Activo = 0 WHERE IdCursoProg = 43
GO
SELECT * FROM CursoProgramado WHERE IdCursoProg = 43
GO
-- el curso 43 ya no esta activo
INSERT INTO Matricula(IdCursoProg, IdAlumno, FecMatricula)
	                  VALUES(43,'A0013','20220328')
GO






/*						TAREA SESION 6
				
En marketperu crear un trigger que permita ingresar un detalle de 
venta. Se debe verificar si hay stock suficiente y si el producto no 
esta descontinuado para realizar la venta. (tarea)*/
--





-- Este demo3 debe ejecutar paso a paso, batch por batch
USE EDUTEC
GO
-- Paso 01 -- Creación de un desencadenante
CREATE TRIGGER tr_insert_alumno1
ON alumno
AFTER INSERT
AS
PRINT 'Primer desencadenante ejecutado'
GO
-- Paso 02 -- Probar el desencadenante
SELECT * FROM ALUMNO
GO
INSERT INTO Alumno(IdAlumno,ApeAlumno,NomAlumno)
					   VALUES('A9001','AGUILAR OLARTE','WALTER')
GO
SELECT * FROM ALUMNO
GO
-- Paso 03 -- Crear otro desencadenante
CREATE TRIGGER tr_insert_alumno2
ON ALUMNO
AFTER INSERT
AS
PRINT 'Segundo desencadenante ejecutado'
GO
-- Paso 04 -- Probar el desencadenante
INSERT INTO Alumno(IdAlumno,ApeAlumno,NomAlumno)
	                  VALUES('A9012','ARENAS MATA','FANNY ROCIO')
GO
SELECT * FROM ALUMNO
GO
-- Paso 05 -- Crear otro desencadenante
CREATE TRIGGER tr_insert_alumno3
ON ALUMNO
AFTER INSERT, UPDATE
AS
PRINT 'Tercer desencadenante ejecutado'
GO
-- Paso 06 -- Probar el desencadenante
INSERT INTO Alumno(IdAlumno,ApeAlumno,NomAlumno)
	                   VALUES('A9003','BRUNO SALAZAR','MILAGROS')
GO
SELECT * FROM ALUMNO
GO
-- Paso 07 -- Probar el desencadenante
UPDATE ALUMNO 	SET emailalumno = 'mbruno@uni.edu.pe'
	WHERE idalumno = 'A9003'
GO
SELECT * FROM ALUMNO
GO
-- Este demo4 debe ejecutar paso a paso, batch por batch
-- Establecer la base de datos
USE EDUTEC
GO
-- Paso 01-- Creación de un desencadenante
CREATE TRIGGER tr_update_alumno1
ON alumno
AFTER UPDATE
AS
IF UPDATE(Apealumno)
BEGIN
	PRINT 'No se puede modificar el apellido del alumno'
	ROLLBACK TRAN
END
GO
-- Paso 02 -- Probar el desencadenante
SELECT * FROM ALUMNO WHERE IDALUMNO = 'A0001'
GO
UPDATE alumno 	SET ApeAlumno = 'ROCA' 
    WHERE IdAlumno = 'A0001'
GO
select * from alumno where IdAlumno = 'A0001'
go
UPDATE alumno 	SET DirAlumno = 'Los Olivos' 
WHERE IdAlumno = 'A0001'
go
SELECT * FROM ALUMNO WHERE IdAlumno = 'A0001'
GO
-- Paso 03  -- Creación de un desencadenante
CREATE TRIGGER tr_update_alumno2
ON ALUMNO
AFTER UPDATE
AS
IF columns_updated() = 4
BEGIN
	PRINT 'No se puede modificar el nombre del alumno'
	ROLLBACK TRAN
END
GO
-- Paso 04 -- Probar el desencadenante
SELECT * FROM ALUMNO WHERE IdAlumno = 'A0001'
GO
UPDATE ALUMNO 	SET NomAlumno = 'OSCAR' 	
WHERE IdAlumno = 'A0001'
GO
SELECT * FROM alumno WHERE IdAlumno = 'A0001'
GO

-- Este demo5 debe ejecutar paso a paso, batch por batch

USE EDUTEC
GO
-- Paso 01
-- Creación de un desencadenante

CREATE TRIGGER TR_INSERT_PROFESOR
ON PROFESOR
AFTER INSERT
AS
IF ( SELECT COUNT(*) 
	FROM PROFESOR P, INSERTED I
	WHERE (P.APEPROFESOR = I.APEPROFESOR) AND
		(P.NOMPROFESOR = I.NOMPROFESOR) ) > 1
BEGIN
	PRINT 'EL PROFESOR YA SE ENCUENTRA REGISTRADO.'
	PRINT 'ACCIÓN CANCELADA'
	ROLLBACK TRAN
END
ELSE
	PRINT 'DATOS REGISTRADOS SATISFACTORIAMENTE.'
GO
-- Paso 02 -- Probar el desencadenante
SELECT * FROM PROFESOR WHERE IDPROFESOR = 'P001'
GO
INSERT INTO PROFESOR(IDPROFESOR,APEPROFESOR,NOMPROFESOR)
	                        VALUES('P800','VALENCIA MORALES','PEDRO HUGO')
GO
-- Paso 03-- Probar el desencadenante 
INSERT INTO PROFESOR(IDPROFESOR,APEPROFESOR,NOMPROFESOR)
	                         VALUES('P800','VALENCIA MORALES','LIDIA ROSA')
GO
select * from profesor
go

-- Paso 04-- Creación de un desencadenante
CREATE TRIGGER TR_UPDATE_PROFESOR
ON PROFESOR
AFTER UPDATE
AS
IF ( SELECT COUNT(*)
	FROM INSERTED I, DELETED D
	WHERE I.IDPROFESOR = D.IDPROFESOR ) = 0
BEGIN
	PRINT 'NO SE PUEDE MODIFICAR EL CÓDIGO DEL PROFESOR'
	ROLLBACK TRAN
END
ELSE
	PRINT 'DATOS ACTUALIZADOS SATISFACTORIAMENTE.'	
GO
-- Paso 05-- Probar el desencadenante
select * from profesor where Idprofesor = 'P042'
go
UPDATE PROFESOR	 SET IDPROFESOR = 'AAAA' 
WHERE IDPROFESOR = 'P042'
GO
-- Paso 06-- Probar el desencadenante
UPDATE PROFESOR 	SET TELPROFESOR = '7412399'
	WHERE IDPROFESOR = 'P042'
GO
SELECT * FROM PROFESOR WHERE IDPROFESOR = 'P042'
GO
-- EN PUBS CONTROLAR DE MANERA SIMILAR PARA QUE
-- NO SE PUEDA CAMBIAR EL TITULO DE UN LIBRO
USE PUBS
GO
CREATE TRIGGER TR_UPDATE_title
ON titles
AFTER UPDATE
AS
IF ( SELECT COUNT(*)
	FROM INSERTED I, DELETED D
	WHERE I.title = D.title ) = 0
BEGIN
	PRINT 'NO SE PUEDE MODIFICAR EL NOMBRE DEL LIBRO'
	ROLLBACK TRAN
END
ELSE
	PRINT 'DATOS ACTUALIZADOS SATISFACTORIAMENTE.'	
GO
SELECT * FROM TITLES
--PROBANDO EL DESECANDENANTE

select * from titles where title_id = 'BU1032'
go
-- The Busy Executive's Database Guide
UPDATE titles	 SET title = 'HHHHHHHH' 
WHERE title_id = 'BU1032'
GO
-- PROBANDO

UPDATE titles 	SET price=25  	WHERE title_id = 'BU1032'
GO
SELECT * FROM titles WHERE title_id = 'BU1032'
GO



USE Master
GO
DROP DATABASE Ejemplos
GO
CREATE DATABASE Ejemplos
ON PRIMARY
(NAME =  Ejemplos_Dat, FILENAME='D:\FIEE_DATA\Ejemplos_Dat.mdf', 
 SIZE = 5MB, MAXSIZE = 200, FILEGROWTH = 1 )
LOG ON
(NAME = Ejemplos_Log, FILENAME ='D:\FIEE_DATA\Ejemplos_Log.ldf',
 SIZE = 1MB, MAXSIZE = 200, FILEGROWTH= 1MB)
GO
USE Ejemplos
GO
CREATE TABLE Clientes
 (cod_cli		INT  					NOT NULL ,
  nombre 	CHAR(30) 			NOT NULL ,
  ciudad 		VARCHAR(15) 	NOT NULL ,
  telefono 	VARCHAR(8) 		NULL ) 
GO
INSERT INTO Clientes VALUES(1,'Valencia Morales','Lima',NULL)
INSERT INTO Clientes VALUES(2,'Coronel Castillo','Barcelona',NULL)
INSERT INTO Clientes VALUES(3,'Diaz Vilela','Cuzco',NULL)
INSERT INTO Clientes VALUES(4,'Matsukawa Maeda','Buenos Aires',NULL)
INSERT INTO Clientes VALUES(5,'Bustamante Gutierrez','Santiago',NULL)
INSERT INTO Clientes VALUES(6,'Henostroza Macedo','Trujillo',NULL)
INSERT INTO Clientes VALUES(7,'Flores Manco','Arequipa',NULL)
INSERT INTO Clientes VALUES(8,'Bardon Mayta','Caracas',NULL)
INSERT INTO Clientes VALUES(9,'Allauca Paucar','Huamanga',NULL)
INSERT INTO Clientes VALUES(10,'Serna Jherry','New York',NULL)
GO
Select * From Clientes
GO
CREATE TABLE CliBorrados
 (cod_cli		INT  		NOT NULL ,
  nombre 	CHAR(30) 		NOT NULL ,
  ciudad		VARCHAR(15) NOT NULL ,
  telefono 	VARCHAR(8) 		NULL ) 
GO
Select * From Clientes
Select * From CliBorrados
GO

CREATE TRIGGER tr_Copia_Borrados
ON Clientes FOR DELETE
AS
INSERT INTO CLIBORRADOS SELECT * FROM DELETED 
	SELECT * FROM CLIENTES
	SELECT * FROM CLIBORRADOS
GO
--Ejecución:
Select * From Clientes
Select * From CliBorrados
GO
Delete From Clientes Where cod_cli=2
GO
CREATE TRIGGER tr_Recupera_Borrado
ON CliBorrados FOR DELETE
AS
INSERT INTO Clientes SELECT * FROM deleted
Select * From Clientes
Select * From CliBorrados
GO
Delete From CliBorrados Where cod_cli=2
GO
--
--

--======================================================
/*Obteniendo Información de los Trigger:
Mostrar información de la lista de Triggers de la tabla.*/
USE Ejemplos
GO
EXEC SP_HELPTRIGGER Clientes
GO
--Mostrar información acerca de un objeto de la base de datos cualquiera de la tabla sysobjects.
EXEC SP_HELP tr_Copia_Borrados
GO
--Mostrar información del objeto del cual depende un Trigger.
EXEC SP_DEPENDS tr_Copia_Borrados
GO
--Mostrar información del texto que contiene un Trigger.
EXEC SP_HELPTEXT tr_Copia_Borrados
GO
--
--
--


/*  FUNCIONES definidas por el Administrador */
-- Establecer la Base de Datos
USE EduTec
GO
-- Crear la Función

CREATE FUNCTION fn_Prueba01
	(@N1 INT, @N2 INT) 
	RETURNS INT
BEGIN
	DECLARE @Suma INT
	SET @Suma = @N1 + @N2
	RETURN @Suma
END
GO
-- Probar la Función
Print dbo.fn_Prueba01(16,19)
GO
SELECT dbo.fn_Prueba01(16,19)
GO
DECLARE @x INT
SET @x = dbo.fn_Prueba01(2,8)
SELECT @x
GO
-- Tiene que referirse primero con dbo.   seguido del nombre de la Funcion
-- Una funcion solo se puede usar en la BD donde se creo
-- Para que una Funcion sea Publica debe crearse en la BD MODEL ; 
--  pero solo se podra usar en las Nuevas BD
USE Model
GO

CREATE FUNCTION fn_Prueba02
	(@N1 Int, @N2 Int) 
	RETURNS Int
BEGIN
	DECLARE @Suma Int
	SET @Suma = @N1 + @N2
	RETURN @Suma
END
GO
USE MASTER
GO

CREATE DATABASE Nueva_BD
GO
USE Nueva_BD
GO
Print dbo.fn_Prueba02(16,23)
GO
USE NORTHWIND
GO
Print dbo.fn_Prueba02(16,23)
GO
USE MASTER
GO
CREATE DATABASE Nueva_BD2
GO
USE Nueva_BD2
GO
Print dbo.fn_Prueba02(16,23)
GO
USE PUBS
GO
Print dbo.fn_Prueba02(16,23)
GO

USE MASTER
GO
DROP DATABASE Nueva_BD,  Nueva_BD2
GO
USE Model
GO
DROP FUNCTION fn_Prueba02
GO
/* CREAR UNA FUNCION QUE AL ENTREGARLE LOS TRES LADOS 
DE UN TRIANGULO, DEVUELVA EL AREA DE DICHO TRIANGULO  */
USE EDUTEC
GO
CREATE FUNCTION fn_Area
	(@N1 FLOAT, @N2 FLOAT ,@N3 FLOAT) --> VARIABLES
	RETURNS FLOAT --TIPO DE DATO A DEVOLVER
BEGIN
	DECLARE @area FLOAT
	DECLARE @pm FLOAT
	SET @pm =   @N2*@N2-4*@N1*@N3

	SET @area = SQRT(@pm*(@pm-@N1)*(@pm-@N2)*(@pm-@N3))
	RETURN @area
END
GO

Print dbo.fn_Area(3,4,5)
GO
--
--
/*
CREAR UNA FUNCIÓN QUE RESUELVA UNA ECUACIÓN DE SEGUNDO GRADO. 
SOLO PARA RESULTADOS REALES. 
USAR LA ECUACION GENERAL DE LA EC DE 2DO GRADO
*/
--
USE EduTec
GO
-- Crear la Función

CREATE FUNCTION fn_DateFormat
	(@indate DATETIME, @separator CHAR(1))
	RETURNS NCHAR(20)
AS
BEGIN
	RETURN 
		CONVERT(Nvarchar(20), DATEPART(dd,@indate))
		+ @separator
		+ CONVERT(Nvarchar(20), DATEPART(mm, @indate))
		+ @separator
		+ CONVERT(Nvarchar(20), DATEPART(yy, @indate))
END
GO
-- Probar la Función
SELECT GetDate()
GO

SELECT dbo.fn_DateFormat( GetDate(), ':' )
GO

SELECT dbo.fn_DateFormat( GetDate(), '/' )
GO
select * from Matricula
GO
SELECT 
	IdCursoProg,
	IdAlumno,
	dbo.fn_DateFormat( FecMatricula, '/' ) AS 'Fecha de Matricula' 
FROM Matricula
GO
--
use EDUTEC
GO

CREATE FUNCTION dbo.Cube
( @fNumber float) 
RETURNS float 
AS 
BEGIN RETURN(@fNumber * @fNumber * @fNumber) 
END 
GO
SELECT dbo.Cube(4) 
GO 

-- Ejemplo 2 

CREATE FUNCTION dbo.Factorial ( @iNumber int ) 
RETURNS INT 
AS 
BEGIN DECLARE @i int 
IF @iNumber <= 1 
	SET @i = 1 
ELSE 
	SET @i = @iNumber * dbo.Factorial( @iNumber - 1 ) 
RETURN (@i) 
END 
GO 

SELECT dbo.Factorial(4) 
GO 

-- Ejemplo 3 

CREATE FUNCTION Volumen    
	(@Largo decimal(4,1), @Ancho decimal(4,1), 
    @Altura decimal(4,1) ) 
	RETURNS decimal(12,3)  
AS 
BEGIN 
RETURN ( @Largo * @Ancho * @Altura ) 
END 
GO
 
--A continuación, es posible utilizar esta función en cualquier parte en la que se permita una expresión entera, --como en una columna calculada de una tabla: 
CREATE TABLE Bloque 
(	IdBloque int PRIMARY KEY, 
	Color		nchar(20), 
	Altura		decimal(4,1), 
	Largo		decimal(4,1), 
	Ancho		decimal(4,1),     
	Volume AS (  dbo.Volumen(Altura,Largo, Ancho)  ) 
)
GO
SELECT * FROM Bloque
GO
INSERT INTO Bloque VALUES(1,'AMARILLO',10,20,5) 
GO
 SELECT * FROM Bloque
 GO
 
SP_HELP Volumen 
GO 




-----    PARA LA PROXIMA CLASE  7 ........


SP_HELPTEXT Volumen 
GO 


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

 use master
 go

 USE MASTER
GO
--DROP DATABASE  BD_Ventas
--GO
CREATE DATABASE BD_Ventas
go
USE BD_Ventas
go

CREATE FUNCTION Fn_SubTotal    
( @Cant INT, @Precio MONEY) 
	RETURNS MONEY  
AS 
BEGIN 
RETURN ( @Cant * @Precio) 
END
go

CREATE FUNCTION Fn_MonP    
( @Cant INT, @Precio MONEY, @Desc MONEY) 
	RETURNS MONEY  
AS 
BEGIN 
RETURN ( @Cant * @Precio * ( 1 - @Desc )) 
END
go



INSERT INTO Detalle_Factura VALUES(1,1,10,4,0.25) 
GO

----
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
go

SELECT * FROM Detalle_Factura


use pubs
go

CREATE FUNCTION VentasPorTienda 
( @CodTienda VarChar(30) ) 
RETURNS TABLE 
AS 
RETURN ( SELECT
				ST.Stor_name										AS Tienda,
				CONVERT(CHAR(12),S.ord_date,103) AS Fecha,
				T.Title														AS Libro,
				S.qty														AS Cantidad 
FROM				Titles T 
INNER JOIN	Sales S     ON T.Title_Id = S.Title_Id 
INNER JOIN	Stores ST ON S.Stor_Id = ST.Stor_Id  
WHERE S.Stor_Id = @CodTienda )
go
SELECT * FROM VentasPorTienda('7131')
go
