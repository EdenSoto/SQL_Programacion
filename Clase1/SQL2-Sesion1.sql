USE EDUTEC2
GO
-- VERIFICAR LOS INDICES 
EXEC SP_HELPINDEX ALUMNO
GO
SELECT * FROM ALUMNO
GO
SP_HELPCONSTRAINT ALUMNO
GO
/*DROP  Database EDUTEC2
go
*/
--INGRESANDO REGISTROS DE PRUEBA
INSERT INTO ALUMNO(IdAlumno,ApeAlumno,NomAlumno) 
                        VALUES('A0040','GUERRERO','CHRISTIAN')
GO
SELECT * FROM ALUMNO
GO
INSERT INTO ALUMNO(IdAlumno,ApeAlumno,NomAlumno) 
                        VALUES('A0035','MEDINA','JAIME')
GO
SELECT * FROM ALUMNO
GO
-- CREANDO UN INDICE FISICO
CREATE CLUSTERED INDEX PKALUMNO	ON ALUMNO(IdAlumno)
GO
-- COMPROBANDO LA CREACION DEL INDICE
EXEC SP_HELPINDEX ALUMNO
GO
SELECT * FROM ALUMNO
GO
--El indice fisico no asegura de por si la unicidad de datos 
INSERT INTO ALUMNO(IdAlumno,ApeAlumno,NomAlumno) 
                         VALUES('A0035','GOMEZ','JAVIER')
GO
SELECT * FROM ALUMNO
GO
--Se compruban dos registros con los mismos datos en IdAlumno
-- Para que el indice admitas datos unicos usamos UNIQUE
CREATE UNIQUE CLUSTERED INDEX PKALUMNO 	
ON ALUMNO(IdAlumno)
GO
/*
Msg 1913, Level 16, State 1, Line 1
The operation failed because an index or statistics with name 'PKALUMNO' already exists on table 'ALUMNO'.
*/
--No se puede crear el indice por que ya existe; 
-- Tampoco se puede crear otro indice fisico por solo se admite uno solo
CREATE UNIQUE CLUSTERED INDEX PKALUMNO2 ON ALUMNO(IdAlumno)
GO
/*
Msg 1902, Level 16, State 3, Line 1
Cannot create more than one clustered index on table 'ALUMNO'. Drop the existing clustered index 'PKALUMNO' before creating another.
*/

-- Pasamos a eliminar el indice fisico PKALUMNO
DROP INDEX ALUMNO.PKALUMNO
GO
EXEC SP_HELPINDEX ALUMNO
GO
--Ahora si intentamos crear el indice fisico con UNIQUE
CREATE UNIQUE CLUSTERED INDEX PKALUMNO ON ALUMNO(IdAlumno)
GO
/*
Msg 1505, Level 16, State 1, Line 1
CREATE UNIQUE INDEX terminated because a duplicate key was found for object name 'dbo.Alumno' and index name 'PKALUMNO'.  The duplicate key value is (A0035).
The statement has been terminated.
*/
--Nos da error por que existen dos registros con los mismos datos en IdAlumno (GOMEZ y Cardenas en el codigo A0035)
-- y esto contradice a UNIQUE
SELECT * FROM ALUMNO WHERE IdAlumno='A0035'
GO
--Prodemos a eliminar uno de los dos; en este caso a GOMEZ
DELETE FROM ALUMNO WHERE IdAlumno='A0035' AND ApeAlumno='GOMEZ' 
GO
SELECT * FROM ALUMNO 
GO
--Ahora si procedemos a crear el indice fisico UNIQUE
CREATE UNIQUE CLUSTERED INDEX PKALUMNO	ON ALUMNO(IdAlumno)
GO
SP_HELPINDEX ALUMNO
GO
SELECT * FROM ALUMNO
GO
INSERT INTO ALUMNO(IdAlumno,ApeAlumno,NomAlumno)
						VALUES('a0035','Martini','Heidi')
GO
/*
Msg 1505, Level 16, State 1, Line 1
CREATE UNIQUE INDEX terminated because a duplicate key was found for object name 'dbo.Alumno' and index name 'PKALUMNO'.  The duplicate key value is (A0035).
The statement has been terminated.
*/
--Ya no se puede repetir el valor del campo criterio del indice

-- VERIFICAR LOS INDICES EN EL Object Explorer/../Databases/EDUTEC2/Tables/dbo.Alumno/Indexes...
EXEC SP_HELPCONSTRAINT ALUMNO
GO
--EL INDICE FISICO UNIQUE NO ES CLAVE PRIMARIA
--UNA CLAVE PRIMARIA SI CREA UN INDICE FISICO
ALTER TABLE MATRICULA	ADD FOREIGN KEY(IDALUMNO)	
REFERENCES ALUMNO
GO
/*
Msg 1773, Level 16, State 0, Line 1
Foreign key 'FK__Matricula__IdAlu__08EA5793' has implicit reference to object 'ALUMNO' which does not have a primary key defined on it.
Msg 1750, Level 16, State 0, Line 1
Could not create constraint. See previous errors.
*/
SP_HELPCONSTRAINT ALUMNO
GO
ALTER TABLE ALUMNO	ADD PRIMARY KEY (IDALUMNO)
GO
SP_HELPCONSTRAINT ALUMNO
GO
SP_HELPINDEX ALUMNO
GO
--AHORA QUE YA EXISTE LA PK EN ALUMNO, YA PODEMOS REFENCIAR EN MATRICULA UNA CLAVE FORANEA
ALTER TABLE MATRICULA ADD FOREIGN KEY(IDALUMNO) 
REFERENCES ALUMNO
GO
SP_HELPCONSTRAINT MATRICULA
GO
--Command(s) completed successfully.
SP_HELPCONSTRAINT ALUMNO
GO

-- Crear un Diagrama de la Base de datos actual para observar las tablas relacionadas


--OBSERVANDO EL FACTOR DE LLENADO

SELECT * FROM SYSINDEXES
GO
SELECT NAME,ORIGFILLFACTOR 
FROM SYSINDEXES WHERE NAME = 'PKALUMNO'
GO
--ALTERANDO EL FILLFACTOR CON EL INDICE FISICO EXISTENTE
CREATE UNIQUE CLUSTERED INDEX PKALUMNO ON ALUMNO(IDALUMNO)
	WITH DROP_EXISTING, 
	FILLFACTOR = 90
GO
-- REGORGANIZA LAS PAGINAS DE HOJA, QUITA LA FRAGMENTACION Y VUELVE A CALCULAR LAS ESTADISTICAS DE INDICES
SELECT NAME,ORIGFILLFACTOR FROM SYSINDEXES 
WHERE NAME = 'PKALUMNO'
GO
CREATE UNIQUE CLUSTERED INDEX PKALUMNO ON ALUMNO(IDALUMNO)
	WITH DROP_EXISTING, FILLFACTOR=80
GO
SELECT NAME,ORIGFILLFACTOR FROM SYSINDEXES 
WHERE NAME = 'PKALUMNO'
GO
/*
Establecer en la base de datos Northwind un mecanismo que optimice el tiempo 
de ingresos de registros en la tabla de los Clientes (CUSTOMERS)
*/
 USE Northwind
 GO
 SELECT * FROM Customers
 GO
SP_HELPINDEX CUSTOMERS
GO
SELECT NAME, ORIGFILLFACTOR
FROM SYSINDEXES WHERE NAME = 'PK_CUSTOMERS'
GO

CREATE UNIQUE CLUSTERED INDEX PK_CUSTOMERS ON CUSTOMERS(CUSTOMERID)
    WITH DROP_EXISTING,
	FILLFACTOR = 80
GO

 SP_HELPINDEX CUSTOMERS
 GO
 -- PK_Customers	
 SELECT NAME,ORIGFILLFACTOR FROM SYSINDEXES 
 WHERE NAME = 'PK_Customers'
GO
--Clase 2
use EDUTEC2
go
EXEC SP_HELPINDEX ALUMNO
go
