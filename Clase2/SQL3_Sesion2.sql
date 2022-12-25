use EDUTEC2
go
select*from Alumno
go
--creacio de indices no agrupados (nonclustered)(Logico)
exec sp_helpindex Alumno
go
select*from Alumno order by ApeAlumno
go
drop index alumno.apellido
go
create nonclustered index apellido
	on Alumno(apeAlumno)
go

drop index ALUMNO.NOMBRE
go
select*from Alumno order by NomAlumno
go
create nonclustered index Nombre
	on ALUMNO(NomAlumno)
go

exec sp_helpindex ALUMNO
go

select*From Alumno order by NomAlumno
go

exec sp_helpindex PROFESOR
go
create clustered index PKPROFESOR
	on PROFESOR(IDProfesor)
go
exec sp_helpindex PROFESOR
go

create nonclustered index APENOM
	on PROFESOR(ApeProfesor,NomProfesor)
go
exec sp_helpindex PROFESOR
go

create nonclustered index DIRAPE
	on PROFESOR(DirProfesor,ApeProfesor)
go
exec sp_helpindex PROFESOR
go
select*From Profesor order by DirProfesor,ApeProfesor
go

select DirProfesor,ApeProfesor from Profesor
order by DirProfesor,ApeProfesor
go




exec sp_helpindex EMPLEADO
go
create clustered index PKEMPLEADO --F�sico
	on EMPLEADO(IDEMPLEADO)
go
exec sp_helpindex EMPLEADO
go
create nonclustered index APELLIDOEMP   --L�gico
	on EMPLEADO(ApeEmpleado)
go
exec sp_helpindex EMPLEADO
go

select*from Empleado
go

create nonclustered index CARGOAPE      --L�gico
	on EMPLEADO(CARGO,ApeEmpleado)
go
exec sp_helpindex EMPLEADO
go

--Consulta cubierta
select Cargo,ApeEmpleado From Empleado
order by Cargo,ApeEmpleado
go
--Los Campos que se consultan forman el indice
--Eliminando indices
--Primero Los no agrupados
exec sp_helpindex EMPLEADO
go

Drop index Empleado.ApellidoEmp
go
exec sp_helpindex EMPLEADO
go
Drop index Empleado.CargoApe
go
exec sp_helpindex EMPLEADO
go
--Luego el agrupado
Drop index Empleado.PKEmpleado
go
exec sp_helpindex EMPLEADO
go


use Northwind
go
select*from Products
go
Exec sp_helpindex Products
go

--Presentar una lista de Productos mostrdos 
--El codigo de la categoria 
--El codigo del proveedor .y 
--el nombre del Producto.
--En ese mismo orden de la manera mas rapida posible

select CategoryId,SupplierId,ProductName From Products
order by CategoryId,SupplierId,ProductName
go

create nonclustered index catProvNom
	on Products(CategoryId,SupplierId,ProductName)
go
sp_helpindex Products
go

select CategoryId,SupplierId,ProductName From Products
order by CategoryId,SupplierId,ProductName
go
/*


Clase 2 

 
*/

/* LOTE O BATCH
Un proceso por lotes o batch es un conjunto 
de instrucciones SQL que se env�an al servidor 
y se ejecutan como un todo.*/

--Ejemplo:
USE EduTec
SELECT * FROM Tarifa
SELECT * FROM Curso
SELECT * FROM Alumno
GO
--
--Todas las instrucciones dentro de un proceso por lotes se analizan como una sola unidad.
Use EduTec
Select * From Tarifa
Select * Fom Curso
Select * From Alumno
Go
-- No se ejecuta ningun Select y se obtiene el siguiente mensaje de error de compilaci�n:
--SQL Server utiliza la resoluci�n de nombres de objetos  aplazada.
SELECT * FROM TARIFA
SELECT * FROM ALUMNO
SELECT * FROM CURSOS
SELECT * FROM PROFESOR
GO
--Se ejecuta el primer Select y 
--se obtiene el siguiente mensaje de error por el segundo Select:

--

--El �mbito de las variables locales (definidas por el usuario) est� limitado a un batch 
--y no es posible referirse a ellas despu�s del comando GO. 
--Por ejemplo si ejecutamos el siguiente batch:
DECLARE @MiMensaje VARCHAR(50)
SET @MiMensaje = 'FIEE - UNI'
GO
PRINT @MiMensaje
GO
--Obtenemos el siguiente mensaje de error:
/*
Msg 137, Level 15, State 2, Line 1
Must declare the scalar variable "@MiMensaje".
*/
--
DECLARE @MiMensaje VARCHAR(50)
SET @MiMensaje = 'FIM - UNI'
-- GO
PRINT		@MiMensaje
SELECT	@MiMensaje as ejemplo
GO
--Transacciones
--Una transacci�n es una secuencia de operaciones realizadas 
--como una sola unidad l�gica de trabajo.

--Una unidad l�gica de trabajo debe exhibir cuatro propiedades, 
--conocidas como propiedades ACID (atomicidad, coherencia, aislamiento y durabilidad), 
--para ser calificada como transacci�n.

--Atomicidad:
--Una transacci�n debe ser una unidad at�mica de trabajo, 
--tanto si se realizan todas sus modificaciones en los datos, 
--como si no se realiza ninguna de ellas.

--Coherencia:
--Cuando finaliza, una transacci�n debe dejar todos los datos en un estado coherente. 

--Aislamiento:
--Las modificaciones realizadas por transacciones simult�neas se deben aislar 
--de las modificaciones llevadas a cabo por otras transacciones simult�neas. 

--Durabilidad:
--Una vez concluida una transacci�n, sus efectos son permanentes en el sistema. 
--Las modificaciones persisten a�n en el caso de producirse un error del sistema. 



--Es responsabilidad de un sistema de base de datos corporativo como SQL Server proporcionar 
-- los mecanismos que aseguren la integridad f�sica de cada transacci�n.
 
--SQL Server proporciona: 

--Servicios de bloqueo que preservan el aislamiento de la transacci�n. 

--Servicios de registro que aseguran la durabilidad de la transacci�n. 
-- A�n en el caso de que falle el hardware del servidor, 
-- el sistema operativo o el propio SQL Server. 
-- SQL Server utiliza registros de transacciones, para que cuando nuevamente se reinicie, 
-- pueda deshacer autom�ticamente las transacciones incompletas en el momento 
-- en que se produjo el error en el sistema.  

--Caracter�sticas de administraci�n de transacciones que exigen la atomicidad y 
-- coherencia de la transacci�n.Una vez iniciada una transacci�n, 
-- debe concluirse correctamente o SQL Server 
-- deshar� todas las modificaciones de datos realizadas desde que se inici� la transacci�n. 

--En SQL Server funcionan tres tipos de transacciones:

	--Transacciones de confirmaci�n autom�tica

	--Transacciones expl�citas

	--Transacciones impl�citas


--Transacciones de Confirmaci�n Autom�tica

--Cada instrucci�n individual es una transacci�n. Ejemplo:
USE EduTec
GO
CREATE TABLE Demo07 
(	ColA INT PRIMARY KEY, 
	ColB CHAR(3))
GO

select* from  Demo07
go
INSERT INTO Demo07 VALUES (1, 'aaa')
INSERT INTO Demo07 VALUES (2, 'bbb')
INSERT INTO Demo07 VALUSE (3, 'ccc')  
INSERT INTO Demo07 VALUES (4, 'ddd')
GO

SELECT * FROM Demo07   /* No Retorna Filas */
GO
--
--Otro Ejemplo:
drop table Demo08
go
CREATE TABLE Demo08 
(	ColA INT		PRIMARY KEY, 
	ColB CHAR(3)							)
GO

INSERT INTO Demo08 VALUES (1, 'aaa')
INSERT INTO Demo08 VALUES (2, 'bbb')
INSERT INTO Demo08 VALUES (1, 'ccc') 
INSERT INTO Demo08 VALUES (3, 'ddd')
GO
SELECT * FROM Demo08   /* Retorno las Filas 1 , 2 y 3(4� INSERT) */
GO
DROP TABLE Demo08
GO
--Otro Ejemplo:
DROP TABLE Demo09
GO
CREATE TABLE Demo09 
(	ColA		INT		PRIMARY KEY,	
	ColB		CHAR(3)						)
GO
INSERT INTO Demo09 VALUES (1, 'aaa')
INSERT INTO Demo09 VALUES (2, 'bbb')
INSERT INTO Demo90 VALUES (3, 'ccc')  
INSERT INTO Demo09 VALUES (4, 'xxx')
GO
SELECT * FROM Demo09   /* Retorno las Filas 1 y 2 */
GO

USE MASTER
GO

--Transacciones Expl�citas

--Cada transacci�n se inicia expl�citamente con la instrucci�n BEGIN TRANSACTION 
-- y se termina expl�citamente con una instrucci�n COMMIT TRANSACTION o ROLLBACK TRANSACTION.

--BEGIN TRANSACTION

	--Marca el punto de inicio de una transacci�n expl�cita.

--COMMIT TRANSACTION o COMMIT WORK

	--Se utiliza para finalizar una transacci�n correctamente si no hubo errores. 
	--Todas las modificaciones de datos realizadas en la transacci�n se convierten en 
	--parte permanente de la base de datos. Los recursos mantenidos por la transacci�n 
	--se liberan.
--ROLLBACK TRANSACTION o ROLLBACK WORK

	--Se utiliza para eliminar una transacci�n en la que se encontraron errores. 
	--Se devuelven todos los datos que modifica la transacci�n al estado en que estaba 
	--al inicio de la transacci�n. Los recursos mantenidos por la transacci�n se liberan.

--Mientras que un batch es un concepto del lado del cliente, que controla cu�ntas  
--instrucciones se env�an al servidor SQL Server para procesarlas como una sola unidad; 
--una transacci�n es un concepto del lado del servidor que se encarga de determinar 
--cu�nto trabajo debe realizar el servidor SQL Server antes de considerar confirmados 
--los cambios. 

--Las transacciones y los procesos por lotes pueden tener una relaci�n de varios a varios. 
--Una �nica transacci�n puede estar distribuida en varios batch 
--(aunque es algo malo desde la perspectiva del rendimiento), 
--y un batch puede contener varias transacciones.

--Ejemplo:
USE EDUTEC
GO
SELECT * FROM Tarifa
SELECT * FROM Curso
GO
BEGIN TRAN
UPDATE Tarifa SET PreTarifa = PreTarifa * 2
GO
SELECT * FROM Tarifa
GO
INSERT INTO Curso VALUES( 'C900','C','PHP' )
GO
SELECT * FROM Tarifa
SELECT * FROM Curso
GO

COMMIT TRAN
GO
SELECT * FROM Tarifa
SELECT * FROM Curso
GO
DELETE FROM Curso WHERE IdCurso ='C900'
GO
UPDATE Tarifa Set PreTarifa = PreTarifa / 2
GO
SELECT * FROM Tarifa
SELECT * FROM Curso
GO

--Control de Errores
--Las transacciones de varias instrucciones deber�n comprobar los errores verificando 
--la variable @@Error despu�s de cada instrucci�n. Si se encuentra un error no fatal 
--y no se toma ninguna acci�n, el procesamiento pasar� a la siguiente instrucci�n. 
--Solo errores fatales provocan la cancelaci�n autom�tica del batch.

--Una consulta que no encuentra ninguna fila que satisfaga el criterio de la cl�usula 
-- WHERE o una instrucci�n UPDATE que no afecte a ninguna fila, no son errores y 
-- @@Error retorna 0 (lo que significa que ha habido error) en cualquiera de estos casos. 
--Si queremos comprobar que no existe ninguna fila afectada, debemos verificar el valor 
--de la variable @@RowCount.

--Los errores mas habituales son:
	--Falta de permisos sobre un objeto
	--Violaci�n de restricciones
	--Se encuentran duplicados al intentar actualizar o insertar una fila
	--Violaciones NOT NULL
	--Valor ilegal para el tipo de dato actual

--Analicemos el siguiente ejemplo:

Create Table TA( a CHAR(1) Primary Key )
GO
Create Table TB( b CHAR(1) REFERENCES TA )
GO
Create Table TC( c CHAR(1) )
GO
SELECT * FROM TA
SELECT * FROM TB
SELECT * FROM TC
GO
--
CREATE PROCEDURE Test1 
AS
    BEGIN TRAN
        INSERT TC VALUES( 'X' )
        INSERT TB VALUES( 'X' )  
    COMMIT TRAN
GO

EXECUTE Test1
GO
EXEC Test1
GO
Test1
GO

SELECT * FROM TA
SELECT * FROM TB
SELECT * FROM TC
GO
--Para que no falle la referencia
INSERT TA VALUES( 'X' )
GO
SELECT * FROM TA
SELECT * FROM TB
SELECT * FROM TC
GO
EXEC Test1
GO
SELECT * FROM TA
SELECT * FROM TB
SELECT * FROM TC
GO
EXEC Test1
GO
SELECT * FROM TA
SELECT * FROM TB
SELECT * FROM TC
GO

--Modificaci�n del Procedimiento:

CREATE PROCEDURE Test2
AS
    BEGIN TRAN
        INSERT TC VALUES( 'Y' )
        IF ( @@Error <> 0 ) GOTO on_error
        INSERT TB VALUES( 'Y' )  
        IF ( @@Error <> 0 ) GOTO on_error
    COMMIT TRAN
    RETURN (0)
on_error:
    ROLLBACK TRAN
    RETURN (1)
GO
Select * From TA
Select * From TB
Select * From TC
GO
Exec Test2
Go
Select * From TA
Select * From TB
Select * From TC
GO
--En TC no se agrego Y
INSERT INTO TA VALUES('Y')
GO
Select * From TA
Select * From TB
Select * From TC
GO
Exec Test2
Go
Select * From TA
Select * From TB
Select * From TC
GO
--
/*PROCEDIMIENTOS ALMACENADOS
Base de datos de prueba*/
USE MASTER
GO
DROP DATABASE  Pruebas
GO
CREATE DATABASE Pruebas
GO
USE Pruebas
GO

/*Tabla de ejemplo Clientes*/

CREATE TABLE Clientes (
	cod_cli   INT						NOT NULL ,
	nombre  CHAR(30)			NOT NULL ,
	ciudad   VARCHAR(15)		NOT NULL ,	
	telefono VARCHAR(8)		    NULL ) 
GO
SELECT * FROM Clientes
GO

--CLIENTES
insert into Clientes values(1,'Maria Euguren','Lima','3245876')
insert into Clientes values(2,'Alejandro Mezco Caballero','La Plata','4959554')
insert into Clientes values(3,'Daniela Velasquez Marquez','Arequipa','4791004')
insert into Clientes values(4,'Daniel Hacha Gonzales','Lima','4151004')
insert into Clientes values(5,'Jose Pe�a','Huaraz','4568741')
insert into Clientes values(6,'Pedro Perez','Huaraz','4568741')
GO
--Se comprueban los datos:
Select * from Clientes
GO
/*Ejemplos de Stored Procedure*/
--Sin Recibir ni Devolver par�metros:
CREATE PROCEDURE ListaClientes
AS
SELECT * FROM Clientes
GO
--Ejecuci�n:
EXEC ListaClientes
GO
/*Crear SP que presente una lista 
de los proveedores de la bd 
Northwind y el monto total 
de ventas correspondientes
a los productos relacionados 
con cada proveedor. */

USE Northwind
GO
SELECT 
S.CompanyName																				AS Proveedor, 
ROUND(SUM(OD.UnitPrice*OD.Quantity*(1-OD.DISCOUNT)),2)	AS [Monto de Ventas]
FROM				Suppliers			S
INNER JOIN	Products			P		ON	S.SupplierID = P.SupplierID
INNER JOIN	[Order Details]	OD	ON	P.ProductID =OD.ProductID
GROUP BY S.CompanyName
GO
CREATE PROCEDURE VentasProveedor
AS
SELECT 
S.CompanyName																				AS Proveedor, 
ROUND(SUM(OD.UnitPrice*OD.Quantity*(1-OD.DISCOUNT)),2)	AS [Monto de Ventas]
FROM				Suppliers			S
INNER JOIN	Products			P		ON	S.SupplierID = P.SupplierID
INNER JOIN	[Order Details]	OD	ON	P.ProductID =OD.ProductID
GROUP BY S.CompanyName
GO

EXEC VentasProveedor
GO
/* Crear un Sp que muestra el 
Monto total de ventas 
por region y por Categoria
Solo para las ventas realizadas 
en el primer Semestre del a�o 1997     
y ademas solo 
para las Regiones Norte y Sur*/
USE NORTHWIND
GO
SELECT
	R.RegionDescription, 
	C.CategoryName,
	ROUND(SUM(OD.UnitPrice*OD.Quantity*(1-OD.DISCOUNT)),2)  AS[Monto de Ventas]
FROM				Region							R
INNER JOIN	Territories						T		ON	R.RegionID	        = T.RegionID
INNER JOIN	EmployeeTerritories	ET	ON	T.TerritoryID        = ET.TerritoryID
INNER JOIN	Employees						E		ON	ET.EmployeeID	    = E.EmployeeID
INNER JOIN	Orders								O		ON	E.EmployeeID		= O.EmployeeID
INNER JOIN	[Order Details]				OD	ON	O.OrderID	            = OD.OrderID
INNER JOIN	Products						P		ON	OD.ProductID		= P.ProductID
INNER JOIN	Categories						C		ON	P.CategoryID		= C.CategoryID
WHERE O.OrderDate BETWEEN '19970101' AND '19970630' 
GROUP BY R.RegionDescription, C.Categoryname
HAVING R.RegionDescription IN ('Northern','Southern')
ORDER BY 1,2
GO
CREATE PROCEDURE Venta_Reg_Cate
AS
SELECT
	R.RegionDescription, 
	C.CategoryName,
	ROUND(SUM(OD.UnitPrice*OD.Quantity*(1-OD.DISCOUNT)),2)  AS[Monto de Ventas]
FROM				Region							R
INNER JOIN	Territories						T		ON	R.RegionID	        = T.RegionID
INNER JOIN	EmployeeTerritories	ET	ON	T.TerritoryID        = ET.TerritoryID
INNER JOIN	Employees						E		ON	ET.EmployeeID	    = E.EmployeeID
INNER JOIN	Orders								O		ON	E.EmployeeID		= O.EmployeeID
INNER JOIN	[Order Details]				OD	ON	O.OrderID	            = OD.OrderID
INNER JOIN	Products						P		ON	OD.ProductID		= P.ProductID
INNER JOIN	Categories						C		ON	P.CategoryID		= C.CategoryID
WHERE O.OrderDate BETWEEN '19970101' AND '19970630' 
GROUP BY R.RegionDescription, C.Categoryname
HAVING R.RegionDescription IN ('Northern','Southern')
ORDER BY 1,2
GO
EXEC Venta_Reg_Cate
GO

/* Crear un SP que presente 
el monto total de ventas 
por tienda por autor.
De debe mostrar el 
Nombre la Tienda y 
Los Apellidos y Nombres 
de los Autores
(BD Pubs)*/

use pubs
go

