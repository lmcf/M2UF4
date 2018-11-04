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

-- PRUEBAS
-- Prueba de validar_dni en este caso está bien el dni
insert into persona values ('11111111A',1,
('Jose','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'));

-- En los siguientes casos está mal
insert into persona values ('1111111AA',1,
('Jose','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'));

insert into persona values ('11111A',1,
('Jose','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'));

--Creamos tipo Hotel
create type hotel_ob as (
	nombre_hotel varchar(30),
	habitaciones int,
	Calle varchar(30),
    Numero int,
    Codigo_postal int
);

-- Sequence para id_hotel
create sequence id_hotel_sequence
  start 1
  increment 1;

-- Sequence para id_hotel
create table hotel(
    id_hotel serial primary key,
    hoteles hotel_ob[]
);

-- Vemos como ha quedado la tabla
\d hotel

-- Insert prueba hoteles
-- FALLA
insert into hotel values(
    nextval('id_hotel_sequence'),
    ARRAY["('Hillton', 200, 'La calle', 2, 4)"]
);

-- Creamos el tipo ciudad
create type ciudad_ob as (
	Nombre_ciudad varchar(40),
	Descripcion varchar(100),
	Pais varchar(40)
);

-- Sequence para id_ciudad
create sequence id_ciudad_sequence
  start 1
  increment 1;

--Creamos tabla Ciudad
create table ciudad (
	id_ciudad serial primary key,
	ciudad ciudad_ob
)with oids;

-- Vemos como ha quedado la tabla
\d ciudad

-- PRUEBAS

-- Insertamos una fila en ciudad
insert into ciudad values(
nextval('id_ciudad_sequence'),
('Barcelona','Una ciudad Bonita','Spain'));

insert into ciudad values(
nextval('id_ciudad_sequence'),
('Madrid','Una ciudad Bonita','Spain'));

-- Vemos como se inserta bien y se incrementa el id_ciudad
select * from ciudad;

-- Tabla para guardar los viajes de cada persona
-- Sequence para id_viaje
create sequence id_viaje_sequence
  start 1
  increment 1;

-- Creamos la tabla viaje que hereda de persona
create table viaje (
    id_viaje serial primary key,
    id_ciudad int
) inherits (persona);

-- Vemos como ha quedado la tabla
\d viaje

-- PRUEBAS
-- Insertamos un viaje junto a los datos de su persona y el id de la ciudad
insert into viaje values ('11111111A',1,
('Jose','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'),
nextval('id_viaje_sequence'),1);

-- Otros viajes
insert into viaje values ('00000000A',1,
('Marc','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'),
nextval('id_viaje_sequence'),2);

insert into viaje values ('00000000A',1,
('Marc','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'),
nextval('id_viaje_sequence'),2);

-- Comprobamos que si ponemos mal el dni no deja insertar
insert into viaje values ('111111A',1,
('Jose','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'),
nextval('id_viaje_sequence'),1);

-- Vemos que datos hay en viaje
select * from viaje;



-- Gestion de eliminaciones

-- JUEGO DE CONSULTAS

-- Aqui vemos que Jose De Prueba ha ido a Barcelona 1 vez
select v.*,c.ciudad from viaje v
join ciudad c on c.id_ciudad=v.id_ciudad
where v.dni = '11111111A';

-- Aqui vemos que Marc De Prueba ha ido a Madrid 2 veces
select v.*,c.ciudad from viaje v
join ciudad c on c.id_ciudad=v.id_ciudad
where v.dni = '00000000A';

-- Tareas
-- Tabla con inherits
-- Gestionar eliminaciones on update y on delete