CREATE DATABASE dbtest
GO

USE dbtest;
GO

CREATE TABLE carreras(
	id int primary key identity(1, 1),
	nombre nvarchar(60) not null,
	precio numeric(18, 2)
)
GO

INSERT carreras(nombre, precio) VALUES('ISI', 250)