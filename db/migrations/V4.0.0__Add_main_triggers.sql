
CREATE OR REPLACE FUNCTION wastesoil.tr_any_biu_replace_null_dates_to_infinity()
  RETURNS trigger
  LANGUAGE 'plpgsql'
AS $$
BEGIN
  IF (NEW.date_end IS null) THEN
    NEW.date_end = 'infinity';
  END IF;
  IF (NEW.date_start IS null) THEN
    NEW.date_start = '-infinity';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER tr_soil_bi_replace_null_dates_to_infinity
    BEFORE INSERT OR UPDATE 
    ON wastesoil.soil
    FOR EACH ROW
    EXECUTE FUNCTION wastesoil.tr_any_biu_replace_null_dates_to_infinity();
    
CREATE TRIGGER tr_deficit_biu_replace_null_dates_to_infinity
    BEFORE INSERT OR UPDATE 
    ON wastesoil.deficit
    FOR EACH ROW
    EXECUTE FUNCTION wastesoil.tr_any_biu_replace_null_dates_to_infinity();
    
    
CREATE OR REPLACE FUNCTION wastesoil.tr_soil_bi_set_available()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $$
BEGIN
  NEW.available_quantity = new.quantity;
  RETURN NEW;
END;
$$;

CREATE TRIGGER tr_soil_bi_set_available
    BEFORE INSERT
    ON wastesoil.soil
    FOR EACH ROW
    EXECUTE FUNCTION wastesoil.tr_soil_bi_set_available();
    

CREATE OR REPLACE FUNCTION wastesoil.tr_deficit_bi_set_missing()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $$
BEGIN
  NEW.missing_quantity = new.quantity;
  RETURN NEW;
END;
$$;

CREATE TRIGGER tr_deficit_bi_set_missing
    BEFORE INSERT
    ON wastesoil.deficit
    FOR EACH ROW
    EXECUTE FUNCTION wastesoil.tr_deficit_bi_set_missing();
    
    

CREATE OR REPLACE FUNCTION wastesoil.count_available_quantity(
	s_id bigint)
    RETURNS numeric
    LANGUAGE 'sql'
AS $BODY$
select
  sum(quantity)
from (
  select id soil_id, quantity quantity from wastesoil.soil
  union all
  select source_soil_id soil_id, -1*quantity quantity from wastesoil.transport
  union all
  select material_soil_id soil_id, -1*material_quantity quantity from wastesoil.process
  union all
  select soil_id, -1*quantity quantity from wastesoil.usage
) quantities
where soil_id = s_id;
$BODY$;



CREATE OR REPLACE FUNCTION wastesoil.count_missing_quantity(
	d_id bigint)
    RETURNS numeric
    LANGUAGE 'sql'
AS $BODY$
select sum(quantity) from (
  select id deficit_id, quantity quantity from wastesoil.deficit
  union all
  select deficit_id, -1*quantity quantity from wastesoil.usage
) quantities
where deficit_id = d_id;
$BODY$;



CREATE OR REPLACE FUNCTION wastesoil.tr_deficit_au_update_missing()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
  missing_new wastesoil.deficit.missing_quantity%TYPE;
BEGIN
  IF (
    old.quantity IS DISTINCT FROM new.quantity
  ) THEN
    missing_new := wastesoil.count_missing_quantity(new.id);
    UPDATE wastesoil.deficit set missing_quantity = missing_new where id = new.id;
    new.missing_quantity = missing_new;
  END IF;
  RETURN new;
end;
$BODY$;


CREATE TRIGGER tr_deficit_au_update_missing
    AFTER UPDATE 
    ON wastesoil.deficit
    FOR EACH STATEMENT
    EXECUTE FUNCTION wastesoil.tr_deficit_au_update_missing();


CREATE OR REPLACE FUNCTION wastesoil.tr_soil_au_update_available()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
  available_new wastesoil.soil.available_quantity%TYPE;
BEGIN
  IF (
    old.quantity IS DISTINCT FROM new.quantity
  ) THEN
    available_new := wastesoil.count_available_quantity(new.id);
    UPDATE wastesoil.soil set available_quantity = available_new where id = new.id;
    new.available_quantity = available_new;
  END IF;
  RETURN new;
end;
$BODY$;


CREATE TRIGGER tr_soil_au_update_available
    AFTER UPDATE 
    ON wastesoil.soil
    FOR EACH ROW
    EXECUTE FUNCTION wastesoil.tr_soil_au_update_available();
    
    

CREATE OR REPLACE FUNCTION wastesoil.tr_usage_aiud_update_available_missing()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    IF (TG_OP = 'DELETE') THEN
      UPDATE wastesoil.soil
      SET available_quantity = wastesoil.count_available_quantity(id)
      WHERE id = OLD.soil_id;

      UPDATE wastesoil.deficit
      SET missing_quantity = wastesoil.count_missing_quantity(id)
      WHERE id = OLD.deficit_id;
      RETURN OLD;
    ELSIF (TG_OP = 'UPDATE' OR TG_OP = 'INSERT') THEN
        UPDATE wastesoil.soil
        SET available_quantity = wastesoil.count_available_quantity(id)
        WHERE id = NEW.soil_id;

        UPDATE wastesoil.deficit
        SET missing_quantity = wastesoil.count_missing_quantity(id)
        WHERE id = NEW.deficit_id;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$BODY$;

CREATE TRIGGER tr_usage_aiud_update_available_missing
    AFTER INSERT OR DELETE OR UPDATE 
    ON wastesoil.usage
    FOR EACH ROW
    EXECUTE FUNCTION wastesoil.tr_usage_aiud_update_available_missing();


CREATE OR REPLACE FUNCTION wastesoil.tr_v_transport_ii()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
  new_soil_id wastesoil.soil.id%TYPE;
  new_transport_id wastesoil.v_transport.id%TYPE;
  return_value wastesoil.v_transport%ROWTYPE;
begin
  INSERT INTO wastesoil.soil(
    site_id,
    soil_type_code,
    quantity,
    date_start,
    source_soil_id
  ) VALUES (
    new.target_site_id,
    (select soil_type_code from wastesoil.soil where id = new.source_soil_id),
    new.quantity,
    new.date,
    new.source_soil_id
  ) RETURNING id INTO new_soil_id;
	
  INSERT INTO wastesoil.transport (
    source_soil_id,
    target_soil_id,
    date,
    quantity
  ) VALUES (
    new.source_soil_id,
    new_soil_id,
    NEW.date,
    NEW.quantity
  ) RETURNING id INTO new_transport_id;
  
  SELECT * INTO return_value from wastesoil.v_transport where id = new_transport_id;
  RETURN return_value;
end;
$BODY$;


CREATE TRIGGER tr_v_transport_ii
    INSTEAD OF INSERT
    ON wastesoil.v_transport
    FOR EACH ROW
    EXECUTE FUNCTION wastesoil.tr_v_transport_ii();

