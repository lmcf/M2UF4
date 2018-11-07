---------------------------------------------
--CREACION DE LA BASE DE DATOS Y SUS TABLAS--
---------------------------------------------

-- Eliminamos la base de datos si existe
drop database if exists agenciadeviajes;
-- Creamos la base de datos
create database agenciadeviajes;

-- Vemos la tabla estamos usando para comprobar que se ha creado bien
\c agenciadeviajes;

-- CREACION TABLA PERSONA

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


-- CREACION TABLA HOTEL

-- Creamos tipo Hotel
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

-- Creamos la tabla hotel
create table hotel(
    id_hotel serial primary key,
    hoteles hotel_ob
);

-- CREACION TABLA CIUDAD

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

-- CREACION TABLA VIAJE

-- Sequence para id_viaje
create sequence id_viaje_sequence
  start 1
  increment 1;


-- Funcion para incrementar el contador de viajes por persona y cambiar el campo de todos las filas de esa persona
create or replace function incrementar_numero_viajes(dni_in varchar(9))
returns integer as
$body$
declare
num int := (select count(dni) from viaje where dni = dni_in);
begin
    if num = 0 then
        return 1;
    else
        update viaje set Num_viajes = num+1 where dni = dni_in;
        return num+1;
    end if;
end;
$body$
language 'plpgsql';

-- Creamos la tabla viaje que hereda de persona
create table viaje (
    id_viaje serial primary key,
    id_ciudad int,
    comprado boolean default false
) inherits (persona);

-- Gestion de eliminaciones

-----------
--PRUEBAS--
-----------

-- PRUEBAS TABLA PERSONA
-- Vemos como ha quedado la tabla persona
\d persona

-- Pruebas del domain check validar_dni

-- Bien
insert into persona values ('11111111A',1,
('Jose','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'));

insert into persona values ('22222222A',1,
('Jose','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'));

insert into persona values ('33333333A',1,
('Jose','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'));

insert into persona values ('44444444A',1,
('Jose','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'));

-- Mal
-- Dni invalido
insert into persona values ('1111111AA',1,
('Jose','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'));

insert into persona values ('11111A',1,
('Jose','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'));

-- Dni repetido
insert into persona values ('11111111A',1,
('Jose','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'));

insert into persona values ('22222222A',1,
('Jose','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'));

-- Vemos la tabla persona
select * from persona;

-- PRUEBAS TABLA HOTEL

-- Vemos como ha quedado la tabla hotel
\d hotel

-- Inserts de prueba hoteles
insert into hotel values(
    nextval('id_hotel_sequence'),
    ('Hillton', 200, 'La calle', 2, 4)
);

insert into hotel values(
    nextval('id_hotel_sequence'),
    ('Hotel Vela', 20, 'La calle', 2, 4)
);

insert into hotel values(
    nextval('id_hotel_sequence'),
    ('Hotel Safa', 30, 'La calle', 2, 4)
);

insert into hotel values(
    nextval('id_hotel_sequence'),
    ('El Hotel', 10, 'La calle', 2, 4)
);

-- Vemos la tabla hotel
select * from hotel;

-- PRUEBAS TABLA CIUDAD

-- Vemos como ha quedado la tabla ciudad
\d ciudad

-- Insertamos unas fila en ciudad

insert into ciudad values(
nextval('id_ciudad_sequence'),
('Barcelona','Una ciudad Bonita','Spain'));

insert into ciudad values(
nextval('id_ciudad_sequence'),
('Madrid','Una ciudad Bonita','Spain'));

insert into ciudad values(
nextval('id_ciudad_sequence'),
('Elche','Una ciudad Bonita','Spain'));

insert into ciudad values(
nextval('id_ciudad_sequence'),
('Valencia','Una ciudad Bonita','Spain'));

-- Vemos la tabla ciudad
select * from ciudad;

-- PRUEBAS TABLA VIAJE

-- Vemos como ha quedado la tabla viaje
\d viaje

-- Insertamos un viaje junto a los datos de su persona y el id de la ciudad
-- Aqui vemos que le metemos 3 viajes entonces en la tabla cada insert 
insert into viaje values ('11111111A',(incrementar_numero_viajes('11111111A')),
('Marc','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'),
nextval('id_viaje_sequence'),2,default);

insert into viaje values ('11111111A',(incrementar_numero_viajes('11111111A')),
('Marc','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'),
nextval('id_viaje_sequence'),2,default);

insert into viaje values ('11111111A',(incrementar_numero_viajes('11111111A')),
('Marc','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'),
nextval('id_viaje_sequence'),2,default);

-- Otros viajes
insert into viaje values ('22222222A',(incrementar_numero_viajes('22222222A')),
('Marc','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'),
nextval('id_viaje_sequence'),2,default);

insert into viaje values ('22222222A',(incrementar_numero_viajes('22222222A')),
('Marc','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'),
nextval('id_viaje_sequence'),2,default);

insert into viaje values ('33333333A',(incrementar_numero_viajes('33333333A')),
('Marc','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'),
nextval('id_viaje_sequence'),2,default);

-- Comprobamos que si ponemos mal el dni no deja insertar
insert into viaje values ('111111A',(incrementar_numero_viajes('111111A')),
('Jose','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'),
nextval('id_viaje_sequence'),1,default);

-- Vemos la tabla viaje
select * from viaje;

----------------------
--JUEGO DE CONSULTAS--
----------------------

-- PRUEBA COMPRA DE UN VIAJE

-- Reserva de un viaje
insert into viaje values ('11114444A',(incrementar_numero_viajes('111111A')),
('Jose','De','Prueba'),
('Calle la calle',420,'2','4',07034,'Barcelona','Spain'),
nextval('id_viaje_sequence'),1,default);

select 'Viaje reservado correctamente' as info;

-- Ver el viajes reservado
select v.id_viaje, (c.ciudad).Nombre_ciudad, v.dni, v.comprado
from viaje v
join ciudad c on c.id_ciudad=v.id_ciudad
where v.dni = '11114444A';

-- Comprar el viaje reservado

update viaje set comprado = true where id_viaje = 7;

select 'Viaje comprado correctamente' as info;

-- Ver viajes comprados
select 'Viajes comprados' as info;

select v.id_viaje, (c.ciudad).Nombre_ciudad, v.dni, v.comprado
from viaje v
join ciudad c on c.id_ciudad=v.id_ciudad
where v.dni = '11114444A' and v.comprado is true;

----------
--TAREAS--
----------
-- Gestionar eliminaciones on update y on delete
-- on delete bajar el número de viajes hechos por x persona
-- Usar un array
-- Acabar diagrama ER
