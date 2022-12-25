
USE master
GO
CREATE DATABASE Ventas05
ON PRIMARY
(NAME =  Ventas05_Dat, FILENAME='D:\FIEE_DATA\Ventas05.mdf', 
 SIZE = 5MB, MAXSIZE = 200, FILEGROWTH = 1 )
LOG ON
(NAME = Ventas05_Log, FILENAME ='D:\FIEE_DATA\Ventas05_Log.ldf',
 SIZE = 1MB, MAXSIZE = 200, FILEGROWTH= 1MB)
GO
USE Ventas05
GO
Create Table Factura
(
FacNum int identity(1,1) Not Null Primary Key,
FacFecha datetime Default getdate(),
FacCliente varchar(50)
)
GO

Create Table Detalle
(
FacNum int NOt Null,
ProCod char(5) NOt Null,
Precio money,
Cantidad int
)
GO
ALTER TABLE Detalle
	ADD PRIMARY KEY(FacNum,ProCod)
GO

Create Table Producto
(
ProCod char(5) primary key,
ProNom varchar(50),
ProPrecio money,
ProStock int
)
GO


ALTER TABLE Detalle
	ADD FOREIGN KEY(ProCod)
	REFERENCES Producto
GO

ALTER TABLE Detalle
	ADD FOREIGN KEY(FacNum)
	REFERENCES Factura
GO

INSERT INTO Producto VALUES('P0001','LECHE GLORIA',90,500)
INSERT INTO Producto VALUES('P0002','ACEITE COCINERO',50,500)
INSERT INTO Producto VALUES('P0003','ARROZ LA PAISANA',125,500)
INSERT INTO Producto VALUES('P0004','AZUCAR RUBIA',110,500)
GO
SELECT * FROM PRODUCTO
SELECT * FROM Factura
SELECT * FROM Detalle
GO

--CREACION DE LOS PROCEDIMIENTOS ALMACENADOS


USE Ventas05
GO

CREATE PROCEDURE usp_Insertar_Factura
	@FacNum int output,
	@FacCliente varchar(50)
AS
	Insert Into Factura(FacCliente) Values(@FacCliente)
	Set @FacNum=@@Identity
GO

CREATE PROCEDURE usp_Insertar_Detalle
	@FacNum int,
	@ProCod varchar(5),
	@Precio money,
	@Cantidad int
AS
	Insert Into Detalle Values(@FacNum,@ProCod,@Precio,@Cantidad)
	
GO

CREATE PROCEDURE usp_Descuenta_Stock
	@CodigoP char(5),@Pedido Integer
AS
	UPDATE Producto SET ProStock=ProStock - @Pedido
	WHERE ProCod = @CodigoP
GO
SELECT * FROM Producto
SELECT * FROM Factura
SELECT * FROM Detalle
GO