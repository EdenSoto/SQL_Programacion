--=======================================================
--Curso:SQL 3 
--Tema:Tarea 2
--Alumno:Soto S,Eden Persi
--Profesor:Julio Enrique Flores Manco
--Fecha:19/03/2022 
--=======================================================

/* Crear un SP que presente el monto total de ventas 
por tienda por autor.De debe mostrar el Nombre la Tienda y 
Los Apellidos y Nombres de los Autores(BD Pubs)*/

use pubs
go
/*Presentar ==>Nombre la Tienda,Los Apellidos y Nombres de los Autores  
				y monto total de ventas
--Tablas a usar ==>stores(stor_name) sales titles (Price) titleauthor authors(au_lname,au_fname)
*/

select*
from		stores	ST
inner join	sales	SA  on	ST.stor_id =SA.stor_id
inner join	titles	T	on	SA.title_id =T.title_id
inner join	titleauthor	TI	on	T.title_id=TI.title_id
inner join	authors	A	on	TI.au_id=A.au_id
go

select
	ST.stor_name				as [Nombre la Tienda],
	A.au_fname +' , '+ A.au_lname		as [Apellidos y Nombres de los Autores],
	sum(SA.qty*T.price)				as Monto
from		stores	ST
inner join	sales	SA  on	ST.stor_id =SA.stor_id
inner join	titles	T	on	SA.title_id =T.title_id
inner join	titleauthor	TI	on	T.title_id=TI.title_id
inner join	authors	A	on	TI.au_id=A.au_id
group by ST.stor_name,A.au_lname,A.au_fname
order by 1,2,3
go
--creando ps

create procedure MontoTiendaAutor
as
select
	ST.stor_name				as [Nombre la Tienda],
	A.au_fname +' , '+ A.au_lname		as [Apellidos y Nombres de los Autores],
	sum(SA.qty*T.price)				as Monto
from		stores	ST
inner join	sales	SA  on	ST.stor_id =SA.stor_id
inner join	titles	T	on	SA.title_id =T.title_id
inner join	titleauthor	TI	on	T.title_id=TI.title_id
inner join	authors	A	on	TI.au_id=A.au_id
group by ST.stor_name,A.au_lname,A.au_fname
order by 1,2,3
go

exec MontoTiendaAutor
go


