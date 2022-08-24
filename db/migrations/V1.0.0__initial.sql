-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler version: 0.9.4
-- PostgreSQL version: 13.0
-- Project Site: pgmodeler.io
-- Model Author: ---
-- -- object: wastesoil_admin | type: ROLE --
-- -- DROP ROLE IF EXISTS wastesoil_admin;
-- CREATE ROLE wastesoil_admin WITH ;
-- -- ddl-end --
-- 

-- Database creation must be performed outside a multi lined SQL file. 
-- These commands were put in this file only as a convenience.
-- 
-- -- object: wastesoil | type: DATABASE --
-- -- DROP DATABASE IF EXISTS wastesoil;
-- CREATE DATABASE wastesoil;
-- -- ddl-end --
-- 

-- -- object: wastesoil | type: SCHEMA --
-- -- DROP SCHEMA IF EXISTS wastesoil CASCADE;
-- CREATE SCHEMA wastesoil;
-- -- ddl-end --
-- ALTER SCHEMA wastesoil OWNER TO postgres;
-- -- ddl-end --
-- 
SET search_path TO pg_catalog,public,wastesoil;
-- ddl-end --

-- object: wastesoil.soil | type: TABLE --
-- DROP TABLE IF EXISTS wastesoil.soil CASCADE;
CREATE TABLE wastesoil.soil (
	id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	quantity integer NOT NULL,
	available_quantity integer NOT NULL,
	availability_start date NOT NULL,
	availability_end date NOT NULL,
	source_soil_id bigint,
	soil_type_code text NOT NULL,
	site_id bigint NOT NULL,
	CONSTRAINT soil_pk PRIMARY KEY (id)
);
-- ddl-end --
ALTER TABLE wastesoil.soil OWNER TO wastesoil_admin;
-- ddl-end --

-- object: wastesoil.deficit | type: TABLE --
-- DROP TABLE IF EXISTS wastesoil.deficit CASCADE;
CREATE TABLE wastesoil.deficit (
	id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	quantity integer NOT NULL,
	missing_quantity integer NOT NULL,
	deficit_start date NOT NULL,
	deficit_end date NOT NULL,
	site_id bigint NOT NULL,
	soil_type_code text NOT NULL,
	CONSTRAINT deficit_pk PRIMARY KEY (id)
);
-- ddl-end --
ALTER TABLE wastesoil.deficit OWNER TO wastesoil_admin;
-- ddl-end --

-- -- object: postgis | type: EXTENSION --
-- -- DROP EXTENSION IF EXISTS postgis CASCADE;
-- CREATE EXTENSION postgis
-- WITH SCHEMA wastesoil;
-- -- ddl-end --
-- 
-- object: wastesoil.soil_type | type: TABLE --
-- DROP TABLE IF EXISTS wastesoil.soil_type CASCADE;
CREATE TABLE wastesoil.soil_type (
	code text NOT NULL,
	description text NOT NULL,
	CONSTRAINT soil_type_pk PRIMARY KEY (code)
);
-- ddl-end --
ALTER TABLE wastesoil.soil_type OWNER TO wastesoil_admin;
-- ddl-end --

-- object: source_soil_fk | type: CONSTRAINT --
-- ALTER TABLE wastesoil.soil DROP CONSTRAINT IF EXISTS source_soil_fk CASCADE;
ALTER TABLE wastesoil.soil ADD CONSTRAINT source_soil_fk FOREIGN KEY (source_soil_id)
REFERENCES wastesoil.soil (id) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: wastesoil.site | type: TABLE --
-- DROP TABLE IF EXISTS wastesoil.site CASCADE;
CREATE TABLE wastesoil.site (
	id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	name text NOT NULL,
	geom geometry(POLYGON, 3857) NOT NULL,
	CONSTRAINT site_pk PRIMARY KEY (id)
);
-- ddl-end --
ALTER TABLE wastesoil.site OWNER TO wastesoil_admin;
-- ddl-end --

-- object: site_fk | type: CONSTRAINT --
-- ALTER TABLE wastesoil.deficit DROP CONSTRAINT IF EXISTS site_fk CASCADE;
ALTER TABLE wastesoil.deficit ADD CONSTRAINT site_fk FOREIGN KEY (site_id)
REFERENCES wastesoil.site (id) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: soil_type_fk | type: CONSTRAINT --
-- ALTER TABLE wastesoil.soil DROP CONSTRAINT IF EXISTS soil_type_fk CASCADE;
ALTER TABLE wastesoil.soil ADD CONSTRAINT soil_type_fk FOREIGN KEY (soil_type_code)
REFERENCES wastesoil.soil_type (code) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: soil_type_fk | type: CONSTRAINT --
-- ALTER TABLE wastesoil.deficit DROP CONSTRAINT IF EXISTS soil_type_fk CASCADE;
ALTER TABLE wastesoil.deficit ADD CONSTRAINT soil_type_fk FOREIGN KEY (soil_type_code)
REFERENCES wastesoil.soil_type (code) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: wastesoil.transport | type: TABLE --
-- DROP TABLE IF EXISTS wastesoil.transport CASCADE;
CREATE TABLE wastesoil.transport (
	id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	source_soil_id bigint NOT NULL,
	target_soil_id bigint NOT NULL,
	quantity integer NOT NULL,
	date date,
	CONSTRAINT transfer_pk PRIMARY KEY (id)
);
-- ddl-end --
ALTER TABLE wastesoil.transport OWNER TO wastesoil_admin;
-- ddl-end --

-- object: soil_fk | type: CONSTRAINT --
-- ALTER TABLE wastesoil.transport DROP CONSTRAINT IF EXISTS soil_fk CASCADE;
ALTER TABLE wastesoil.transport ADD CONSTRAINT soil_fk FOREIGN KEY (source_soil_id)
REFERENCES wastesoil.soil (id) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: soil_fk1 | type: CONSTRAINT --
-- ALTER TABLE wastesoil.transport DROP CONSTRAINT IF EXISTS soil_fk1 CASCADE;
ALTER TABLE wastesoil.transport ADD CONSTRAINT soil_fk1 FOREIGN KEY (target_soil_id)
REFERENCES wastesoil.soil (id) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: wastesoil.usage | type: TABLE --
-- DROP TABLE IF EXISTS wastesoil.usage CASCADE;
CREATE TABLE wastesoil.usage (
	id smallint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	quantity integer NOT NULL,
	date date,
	soil_id bigint NOT NULL,
	deficit_id bigint NOT NULL,
	CONSTRAINT usage_pk PRIMARY KEY (id)
);
-- ddl-end --
ALTER TABLE wastesoil.usage OWNER TO wastesoil_admin;
-- ddl-end --

-- object: soil_fk | type: CONSTRAINT --
-- ALTER TABLE wastesoil.usage DROP CONSTRAINT IF EXISTS soil_fk CASCADE;
ALTER TABLE wastesoil.usage ADD CONSTRAINT soil_fk FOREIGN KEY (soil_id)
REFERENCES wastesoil.soil (id) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: deficit_fk | type: CONSTRAINT --
-- ALTER TABLE wastesoil.usage DROP CONSTRAINT IF EXISTS deficit_fk CASCADE;
ALTER TABLE wastesoil.usage ADD CONSTRAINT deficit_fk FOREIGN KEY (deficit_id)
REFERENCES wastesoil.deficit (id) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: site_fk | type: CONSTRAINT --
-- ALTER TABLE wastesoil.soil DROP CONSTRAINT IF EXISTS site_fk CASCADE;
ALTER TABLE wastesoil.soil ADD CONSTRAINT site_fk FOREIGN KEY (site_id)
REFERENCES wastesoil.site (id) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: wastesoil.process | type: TABLE --
-- DROP TABLE IF EXISTS wastesoil.process CASCADE;
CREATE TABLE wastesoil.process (
	id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ,
	material_soil_id bigint NOT NULL,
	material_quantity integer NOT NULL,
	product_soil_id bigint NOT NULL,
	product_quantity integer NOT NULL,
	date date,
	CONSTRAINT process_pk PRIMARY KEY (id)
);
-- ddl-end --
ALTER TABLE wastesoil.process OWNER TO wastesoil_admin;
-- ddl-end --

-- object: material_soil_fk | type: CONSTRAINT --
-- ALTER TABLE wastesoil.process DROP CONSTRAINT IF EXISTS material_soil_fk CASCADE;
ALTER TABLE wastesoil.process ADD CONSTRAINT material_soil_fk FOREIGN KEY (material_soil_id)
REFERENCES wastesoil.soil (id) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: product_soil_fk | type: CONSTRAINT --
-- ALTER TABLE wastesoil.process DROP CONSTRAINT IF EXISTS product_soil_fk CASCADE;
ALTER TABLE wastesoil.process ADD CONSTRAINT product_soil_fk FOREIGN KEY (product_soil_id)
REFERENCES wastesoil.soil (id) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --
