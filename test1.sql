-- Eliminamos la base de datos si existe
drop database if exists agenciadeviajes;
-- Creamos la base de datos
create database agenciadeviajes;
-- Vemos la tabla estamos usando para comprobar que se ha creado bien
\c agenciadeviajes;

-- Creamos un tipo para la direccion completa
create type direccion_ob as (
    Calle varchar(30),
    Numero int,
    Piso varchar(4),
    Puerta varchar(4),
    Codigo_postal int,
    Ciudad varchar(20),
    Pais varchar(20)
);

-- Creamos un tipo para el nombre completo
create type nombre_ob as (
    Nombre varchar(30),
    Primer_apellido varchar(30),
    Segundo_apellido varchar(30)
);

-- Creamos un dominio para validar el dni
create domain validar_dni as varchar(9)
check(
   value ~ '(\d{8})([-]?)([A-Z]{1})'
);

-- Creamos el tipo persona que contiene los dos tipos anteriores
create type persona_ob as (
	dni validar_dni,
	Num_viajes int,
    Nombre_completo nombre_ob,
    Direccion_postal direccion_ob
);

-- Creamos la tabla a partir de un tipo
create table persona of persona_ob (
    primary key (dni)
) with oids;

-- Vemos como ha quedado la tabla
\d persona

-- Insert para probar
insert into persona values ('11111111A',1,('Jose','De','Prueba'),('Calle la calle',420,'2','4',07034,'Barcelona','Spain'));

-- Tipo direccion Hotel
create type direccion_hotel_ob as (
    Calle varchar(30),
    Numero int,
    Codigo_postal int
);

--Creamos tipo Hotel
create type hotel_ob as (
    id_hotel int,
	nombre_hotel varchar(30),
	habitaciones int,
	direcion_hotel direccion_hotel_ob
);

-- Creamos el tipo ciudad
create type ciudad_ob as (
	Nombre_ciudad varchar(40),
	Descripcion varchar(100),
	Pais varchar(40),
	Hoteles hotel_ob[]
);

-- Sequence para id_ciudad
create sequence id_ciudad_sequence
  start 1000
  increment 1;

-- Sequence para id_hotel
create sequence id_hotel_sequence
  start 1000
  increment 1;

--Creamos tabla Ciudad
create table ciudad (
	id_ciudad serial,
	ciudad ciudad_ob
)with oids;

-- Insertamos una fila en ciudad
insert into ciudad values(
nextval('id_ciudad_sequence'),
('Barcelona','Una ciudad Bonita','Spain',
ARRAY[(nextval('id_hotel_sequence'),'Hillton',200,
('La calle',2,4))]));

insert into ciudad values(
nextval('id_ciudad_sequence'),
('Barcelona','Una ciudad Bonita','Spain',
ARRAY[(nextval("id_hotel_sequence"),"Hillton",200,
("La calle",2,4))]));


-- Tareas
-- Tabla con inherits
-- Gestionar eliminaciones on update y on delete