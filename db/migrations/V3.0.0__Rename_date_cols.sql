ALTER TABLE wastesoil.soil RENAME COLUMN availability_start TO date_start;
ALTER TABLE wastesoil.soil RENAME COLUMN availability_end TO date_end;

ALTER TABLE wastesoil.deficit RENAME COLUMN deficit_start TO date_start;
ALTER TABLE wastesoil.deficit RENAME COLUMN deficit_end TO date_end;
