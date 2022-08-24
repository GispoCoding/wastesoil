
ALTER TABLE wastesoil.soil ALTER COLUMN available_quantity DROP NOT NULL;
-- ddl-end --
ALTER TABLE wastesoil.soil ALTER COLUMN availability_start DROP NOT NULL;
-- ddl-end --
ALTER TABLE wastesoil.soil ALTER COLUMN availability_end DROP NOT NULL;
-- ddl-end --
ALTER TABLE wastesoil.deficit ALTER COLUMN missing_quantity DROP NOT NULL;
-- ddl-end --
ALTER TABLE wastesoil.deficit ALTER COLUMN deficit_start DROP NOT NULL;
-- ddl-end --
ALTER TABLE wastesoil.deficit ALTER COLUMN deficit_end DROP NOT NULL;
-- ddl-end --
