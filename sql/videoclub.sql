create schema videoclub;

SET search_path TO videoclub;

create table generos (
	id_genero serial primary key,
	nombre varchar(50) not null unique
);

create table directores (
	id_director serial primary key,
	nombre varchar(100) not null unique
);

create table peliculas (
	id_pelicula serial primary key,
	id_genero integer not null references generos(id_genero),
	id_director integer not null references directores(id_director),
	titulo varchar(100) not null,
	sinopsis text not null
);

create table copias (
	id_copia serial primary key,
	id_pelicula integer not null references peliculas(id_pelicula)
);


create table socios (
	id_socio serial primary key,
	nombre varchar(50) not null,
	apellidos varchar (100) not null,
	fecha_nacimiento date not null,
	telefono varchar(20) not null,
	num_identificacion varchar(20) not null unique,
	calle varchar(100),
	numero varchar(10),
	piso varchar(10),
	codigo_postal varchar(10)
);

create table prestamos (
	id_prestamo serial primary key,
	id_socio integer not null references socios(id_socio),
	id_copia integer not null references copias(id_copia),
	fecha_prestamo date not null,
	fecha_devolucion date
);


CREATE TABLE tmp_videoclub (
    id_copia integer,
    fecha_alquiler date,
    fecha_devolucion date,
    dni varchar(50),
    nombre varchar(50),
    apellido_1 varchar(50),
    apellido_2 varchar(50),
    email varchar(80),
    telefono varchar(20),
    codigo_postal varchar(10),
    fecha_nacimiento date,
    numero varchar(10),
    piso varchar(10),
    letra varchar(10),
    calle varchar(100),
    extension varchar(50),
    titulo varchar(100),
    genero varchar(50),
    sinopsis text,
    director varchar(100)
);

insert into generos (nombre)
select distinct genero from tmp_videoclub;

insert into directores (nombre)
select distinct director from tmp_videoclub;


insert into peliculas (id_genero, id_director, titulo, sinopsis)
select distinct
	g.id_genero,
	d.id_director,
	t.titulo,
	t.sinopsis
from tmp_videoclub t
join generos g on t.genero = g.nombre
join directores d on t.director = d.nombre;


insert into copias (id_copia, id_pelicula)
select distinct t.id_copia, p.id_pelicula
from tmp_videoclub t
join peliculas p on t.titulo = p.titulo;

insert into socios (nombre, apellidos, fecha_nacimiento, telefono, num_identificacion, calle, numero, piso, codigo_postal)
select distinct
	t.nombre,
	t.apellido_1 || ' ' || t.apellido_2,
	t.fecha_nacimiento,
	t.telefono,
	t.dni,
	t.calle,
	t.numero,
	t.piso,
	t.codigo_postal
from tmp_videoclub t;


insert into prestamos (id_socio, id_copia, fecha_prestamo, fecha_devolucion)
select s.id_socio, t.id_copia, t.fecha_alquiler, t.fecha_devolucion
from tmp_videoclub t
join socios s on t.dni = s.num_identificacion;




drop table tmp_videoclub;



select p.titulo, count(c.id_copia) as copias_disponibles
from peliculas p
join copias c on p.id_pelicula = c.id_pelicula
left join prestamos pr on c.id_copia = pr.id_copia
	and pr.fecha_devolucion is null
where pr.id_prestamo is null
group by p.titulo;


