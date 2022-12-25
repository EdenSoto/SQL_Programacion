USE MASTER
GO
CREATE DATABASE EDUTEC2
GO
USE EDUTEC2
GO
-- Creación de las Tablas 
-- -----------------------------------------

CREATE TABLE Alumno (
       IdAlumno             char(5) NOT NULL,
       ApeAlumno            varchar(30) NOT NULL,
       NomAlumno            varchar(30) NOT NULL,
       DirAlumno            varchar(50) NULL,
       TelAlumno            varchar(12) NULL,
       EmailAlumno          varchar(50) NULL
)
go

CREATE TABLE Ciclo (
       IdCiclo              char(7) NOT NULL,
       FecInicio            datetime NULL,
       FecTermino           datetime NULL
)
go
CREATE TABLE Curso (
       IdCurso              char(4) NOT NULL,
       IdTarifa             char(1) NOT NULL,
       NomCurso             varchar(50) NOT NULL
)
go
CREATE TABLE CursoProgramado (
       IdCursoProg          int IDENTITY,
       IdCurso              char(4) NOT NULL,
       IdCiclo              char(7) NOT NULL,
       IdProfesor           char(4) NULL,
       Vacantes             tinyint NOT NULL DEFAULT 20,
       PreCursoProg         money NOT NULL,
       Horario              varchar(24) NOT NULL,
       Activo               bit DEFAULT 1,
       Matriculados         tinyint NOT NULL DEFAULT 0
)
go
CREATE TABLE Empleado (
       IdEmpleado           char(6) NOT NULL,
       Password             char(6) NOT NULL,
       ApeEmpleado          varchar(30) NOT NULL,
       NomEmpleado          varchar(30) NOT NULL,
       Cargo                varchar(25) NOT NULL,
       DirEmpleado          varchar(50) NULL,
       TelEmpleado          varchar(12) NULL,
       EmailEmpleado        varchar(50) NULL
)
go
CREATE TABLE Matricula (
       IdCursoProg          int NOT NULL,
       IdAlumno             char(5) NOT NULL,
       FecMatricula         datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
       ExaParcial           real NULL,
       ExaFinal             real NULL,
       Promedio             real NULL,
       Subsanacion          bit DEFAULT 0,
       ExaSub               real NULL
)
go
CREATE TABLE Parametro (
       Campo                varchar(10) NOT NULL,
       Contador             int NOT NULL
)
go
CREATE TABLE Profesor (
       IdProfesor           char(4) NOT NULL,
       ApeProfesor          varchar(30) NOT NULL,
       NomProfesor          varchar(30) NOT NULL,
       DirProfesor          varchar(50) NULL,
       TelProfesor          varchar(12) NULL,
       EmailProfesor        varchar(50) NULL
)
go
CREATE TABLE Tarifa (
       IdTarifa             char(1) NOT NULL,
       PreTarifa            money NOT NULL,
       Descripcion          varchar(50) NULL
)
go
