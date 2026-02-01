/*
Autor: Gabriel Alejandro García Angulo
Fecha: 26/11/2025
Descripción: Script T-SQL para crear la BD "Calificaciones" según el modelo ER.
Incluye: creación de BD, tablas (Estudiante, Asignatura, Grupo), PK, FK, CHECK, UNIQUE,
DEFAULTs, control de transacciones, manejo básico de errores e inserción de datos de prueba.
*/

/*
Resumen de atributos:
Estudiante
 - cif       nchar(8)    PK    NOT NULL
 - nombres   nvarchar(40)       NOT NULL
 - apellidos nvarchar(30)       NOT NULL
 - sexo      bit               NOT NULL  (0/1)
 - ingreso   smallint          NOT NULL  (año de ingreso)
 - tipoBeca  nvarchar(15)      NOT NULL  (catálogo libre con CHECK)

Asignatura
 - codigo    nvarchar(10)  PK   NOT NULL
 - nombre    nvarchar(40)       NOT NULL  UNIQUE
 - semestre  tinyint           NOT NULL
 - creditos  tinyint           NOT NULL

Grupo (tabla unión Estudiante ? Asignatura)
 - calificacion tinyint       NOT NULL DEFAULT 0
 - codAsignatura nvarchar(10) NOT NULL  FK -> Asignatura(codigo)
 - cif          nchar(8)      NOT NULL  FK -> Estudiante(cif)

Justificación de diseño:
 - Grupo se mantiene como tabla de relación (sin PK) para representar N:M (inscripciones).
 - Las FK usan ON DELETE NO ACTION / ON UPDATE NO ACTION para evitar borrados/actualizaciones
   automáticas que puedan eliminar notas sin control administrativo.
*/

USE master;
GO

-- Verifica si la base de datos "Calificaciones" existe.
-- Si existe, la pone en modo de un solo usuario para evitar conflictos,
-- revierte transacciones pendientes y luego elimina la base de datos.
IF DB_ID(N'Calificaciones') IS NOT NULL
BEGIN
    ALTER DATABASE Calificaciones SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
    DROP DATABASE Calificaciones;
END
GO

CREATE DATABASE Calificaciones
CONTAINMENT = NONE
ON PRIMARY
(
    NAME = Calificaciones_Data,
    FILENAME = 'C:\DATABASES\Calificaciones_Data.mdf',
    SIZE = 50MB,
    MAXSIZE = 5GB,
    FILEGROWTH = 10MB
)
LOG ON
(
    NAME = Calificaciones_Log,
    FILENAME = 'C:\DATABASES\Calificaciones_Log.ldf',
    SIZE = 20MB,
    MAXSIZE = 2GB,
    FILEGROWTH = 10MB
)
COLLATE Modern_Spanish_CI_AS;
GO

USE Calificaciones;
GO

IF OBJECT_ID(N'Estudiante') IS NOT NULL
    DROP TABLE Estudiante;
GO

/*Creación de tabla Estudiante*/
CREATE TABLE Estudiante
(
    cif nchar(8) NOT NULL,
    CONSTRAINT PK_Estudiante PRIMARY KEY(cif),

    nombres nvarchar(40) NOT NULL,
    apellidos nvarchar(30) NOT NULL,

    sexo bit NOT NULL,
    CONSTRAINT CHK_Estudiante_Sexo CHECK (sexo IN (0,1)),

    ingreso smallint NOT NULL,
    CONSTRAINT CHK_Estudiante_Ingreso CHECK (ingreso BETWEEN 1900 AND 2100),

    tipoBeca nvarchar(15) NOT NULL,
    CONSTRAINT CHK_Estudiante_TipoBeca CHECK (
        tipoBeca IN (
            'Deportiva',
            'Cultural',
            'Academica',
            'Beca Total',
            '50%',
            '40%'
        )
    )
);
GO

IF OBJECT_ID(N'Asignatura') IS NOT NULL
    DROP TABLE Asignatura;
GO

/*Creación de tabla Asignatura*/
CREATE TABLE Asignatura
(
    codigo nvarchar(10) NOT NULL,
    CONSTRAINT PK_Asignatura PRIMARY KEY(codigo),

    nombre nvarchar(40) NOT NULL,
    CONSTRAINT UQ_Asignatura_Nombre UNIQUE (nombre),

    semestre tinyint NOT NULL,
    CONSTRAINT CHK_Asignatura_Semestre CHECK (semestre BETWEEN 1 AND 12),

    creditos tinyint NOT NULL,
    CONSTRAINT CHK_Asignatura_Creditos CHECK (creditos BETWEEN 1 AND 30)
);
GO

IF OBJECT_ID(N'Grupo') IS NOT NULL
    DROP TABLE Grupo;
GO

/*Creación de tabla Grupo*/
/* Nota: las FK se declaran con ON DELETE NO ACTION / ON UPDATE NO ACTION
   porque no queremos borrar o actualizar calificaciones automáticamente cuando
   se borra/actualiza un estudiante o asignatura; preferimos control administrativo. */
CREATE TABLE Grupo
(
    calificacion tinyint NOT NULL DEFAULT 0,
    codAsignatura nvarchar(10) NOT NULL,
    cif nchar(8) NOT NULL,

    CONSTRAINT CHK_Grupo_Calificacion CHECK (calificacion BETWEEN 0 AND 100),

    CONSTRAINT FK_Asignatura_Grupo FOREIGN KEY (codAsignatura)
        REFERENCES Asignatura (codigo) ON DELETE NO ACTION ON UPDATE NO ACTION,

    CONSTRAINT FK_Grupo_Estudiante FOREIGN KEY (cif)
        REFERENCES Estudiante (cif) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO

-- Inserciones de prueba (transaccional)
BEGIN TRY
    BEGIN TRANSACTION;

    ------------------------------------------------
    -- INSERTS (50 ESTUDIANTES)
    ------------------------------------------------
    INSERT INTO Estudiante(cif,nombres,apellidos,sexo,ingreso,tipoBeca)
    VALUES
    ('00000001','Est01 Nombre','Est01 Apellido',1,2024,'Deportiva'),
    ('00000002','Est02 Nombre','Est02 Apellido',0,2024,'50%'),
    ('00000003','Est03 Nombre','Est03 Apellido',1,2024,'40%'),
    ('00000004','Est04 Nombre','Est04 Apellido',0,2024,'Deportiva'),
    ('00000005','Est05 Nombre','Est05 Apellido',1,2024,'Beca Total'),
    ('00000006','Est06 Nombre','Est06 Apellido',0,2024,'Deportiva'),
    ('00000007','Est07 Nombre','Est07 Apellido',1,2024,'Academica'),
    ('00000008','Est08 Nombre','Est08 Apellido',0,2024,'Cultural'),
    ('00000009','Est09 Nombre','Est09 Apellido',1,2024,'Deportiva'),
    ('00000010','Est10 Nombre','Est10 Apellido',0,2024,'Academica'),
    ('00000011','Est11 Nombre','Est11 Apellido',1,2023,'Cultural'),
    ('00000012','Est12 Nombre','Est12 Apellido',0,2023,'Deportiva'),
    ('00000013','Est13 Nombre','Est13 Apellido',1,2023,'Academica'),
    ('00000014','Est14 Nombre','Est14 Apellido',0,2023,'Cultural'),
    ('00000015','Est15 Nombre','Est15 Apellido',1,2023,'Deportiva'),
    ('00000016','Est16 Nombre','Est16 Apellido',0,2023,'Academica'),
    ('00000017','Est17 Nombre','Est17 Apellido',1,2023,'Cultural'),
    ('00000018','Est18 Nombre','Est18 Apellido',0,2023,'Deportiva'),
    ('00000019','Est19 Nombre','Est19 Apellido',1,2023,'Academica'),
    ('00000020','Est20 Nombre','Est20 Apellido',0,2023,'Cultural'),
    ('00000021','Est21 Nombre','Est21 Apellido',1,2022,'Academica'),
    ('00000022','Est22 Nombre','Est22 Apellido',0,2022,'Cultural'),
    ('00000023','Est23 Nombre','Est23 Apellido',1,2022,'Deportiva'),
    ('00000024','Est24 Nombre','Est24 Apellido',0,2022,'Academica'),
    ('00000025','Est25 Nombre','Est25 Apellido',1,2022,'Cultural'),
    ('00000026','Est26 Nombre','Est26 Apellido',0,2022,'Deportiva'),
    ('00000027','Est27 Nombre','Est27 Apellido',1,2022,'Academica'),
    ('00000028','Est28 Nombre','Est28 Apellido',0,2022,'Cultural'),
    ('00000029','Est29 Nombre','Est29 Apellido',1,2022,'Deportiva'),
    ('00000030','Est30 Nombre','Est30 Apellido',0,2022,'Academica'),
    ('00000031','Est31 Nombre','Est31 Apellido',1,2021,'Cultural'),
    ('00000032','Est32 Nombre','Est32 Apellido',0,2021,'Deportiva'),
    ('00000033','Est33 Nombre','Est33 Apellido',1,2021,'Academica'),
    ('00000034','Est34 Nombre','Est34 Apellido',0,2021,'Cultural'),
    ('00000035','Est35 Nombre','Est35 Apellido',1,2021,'Deportiva'),
    ('00000036','Est36 Nombre','Est36 Apellido',0,2021,'Academica'),
    ('00000037','Est37 Nombre','Est37 Apellido',1,2021,'Cultural'),
    ('00000038','Est38 Nombre','Est38 Apellido',0,2021,'Deportiva'),
    ('00000039','Est39 Nombre','Est39 Apellido',1,2021,'Academica'),
    ('00000040','Est40 Nombre','Est40 Apellido',0,2021,'Cultural'),
    ('00000041','Est41 Nombre','Est41 Apellido',1,2020,'Deportiva'),
    ('00000042','Est42 Nombre','Est42 Apellido',0,2020,'Academica'),
    ('00000043','Est43 Nombre','Est43 Apellido',1,2020,'Cultural'),
    ('00000044','Est44 Nombre','Est44 Apellido',0,2020,'Deportiva'),
    ('00000045','Est45 Nombre','Est45 Apellido',1,2020,'Academica'),
    ('00000046','Est46 Nombre','Est46 Apellido',0,2020,'Cultural'),
    ('00000047','Est47 Nombre','Est47 Apellido',1,2020,'Deportiva'),
    ('00000048','Est48 Nombre','Est48 Apellido',0,2020,'Academica'),
    ('00000049','Est49 Nombre','Est49 Apellido',1,2020,'Cultural'),
    ('00000050','Est50 Nombre','Est50 Apellido',0,2020,'Deportiva');

    ------------------------------------------------
    -- INSERTAR 10 ASIGNATURAS
    ------------------------------------------------
    INSERT INTO Asignatura(codigo,nombre,creditos,semestre)
    VALUES
    ('SIS-101','Fundamentos BD',4,1),
    ('SIS-102','Programación I',5,1),
    ('SIS-103','Matemáticas I',4,1),
    ('SIS-201','Programación II',5,2),
    ('SIS-202','Álgebra Lineal',5,2),
    ('SIS-203','Estadística',4,2),
    ('SIS-301','Redes I',4,3),
    ('SIS-302','Análisis Sistemas',4,3),
    ('SIS-401','Ingeniería Software',5,4),
    ('SIS-402','Redes II',5,4);

    ------------------------------------------------
    -- INSERTAR 500 CALIFICACIONES
    -- 50 estudiantes × 10 asignaturas
    ------------------------------------------------
    INSERT INTO Grupo(cif,codAsignatura,calificacion)
    SELECT 
        E.cif,
        A.codigo,
        ABS(CHECKSUM(NEWID())) % 101  -- calificación aleatoria 0-100
    FROM Estudiante E
    CROSS JOIN Asignatura A;
    -- (Esto genera exactamente 50 × 10 = 500 registros)

    ------------------------------------------------

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'Error al ejecutar el script:';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

-- Prueba controlada: intento de insertar con FK inexistente (debe fallar)
BEGIN TRY
    INSERT INTO Grupo(cif,codAsignatura,calificacion)
    VALUES ('99999999','XXX-000',85);  -- cif y asignatura que no existen
    PRINT 'Error de FK no detectado (esto no debería imprimirse)';
END TRY
BEGIN CATCH
    PRINT 'Prueba FK: error capturado (esperado):';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

-- Ver resultados (controles y consultas JOIN para verificar estructura)
SELECT COUNT(*) AS TotalEstudiantes FROM Estudiante;
SELECT COUNT(*) AS TotalAsignaturas FROM Asignatura;
SELECT COUNT(*) AS TotalGrupo FROM Grupo;
GO

-- Mostrar contenido completo
SELECT * FROM Estudiante ORDER BY cif;
SELECT * FROM Asignatura ORDER BY codigo;
SELECT * FROM Grupo ORDER BY codAsignatura, cif;
GO

-- Consultas demostrativas JOIN / agregaciones

-- 1) Calificaciones por estudiante (detalle)
SELECT E.cif,
       E.nombres + ' ' + E.apellidos AS Estudiante,
       A.codigo,
       A.nombre AS Asignatura,
       G.calificacion
FROM Estudiante E
JOIN Grupo G ON E.cif = G.cif
JOIN Asignatura A ON G.codAsignatura = A.codigo
ORDER BY E.cif, A.codigo;
GO

-- 2) Promedio por estudiante
SELECT E.cif,
       E.nombres + ' ' + E.apellidos AS Estudiante,
       AVG(CAST(G.calificacion AS DECIMAL(5,2))) AS Promedio
FROM Estudiante E
JOIN Grupo G ON E.cif = G.cif
GROUP BY E.cif, E.nombres, E.apellidos
ORDER BY Promedio DESC;
GO

-- 3) Promedio por asignatura
SELECT A.codigo,
       A.nombre,
       AVG(CAST(G.calificacion AS DECIMAL(5,2))) AS PromedioAsignatura
FROM Asignatura A
JOIN Grupo G ON A.codigo = G.codAsignatura
GROUP BY A.codigo, A.nombre
ORDER BY A.codigo;
GO
