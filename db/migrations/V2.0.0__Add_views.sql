CREATE VIEW wastesoil.v_transport AS
SELECT
  tr.id,
  src.site_id source_site_id,
  tr.source_soil_id,
  tgt.site_id target_site_id,
  tr.target_soil_id,
  tr.date,
  tr.quantity
FROM
  wastesoil.transport tr
  JOIN wastesoil.soil src
    ON tr.source_soil_id = src.id
  JOIN wastesoil.soil tgt
    ON tr.target_soil_id = tgt.id
;


CREATE VIEW wastesoil.v_process AS
SELECT
  pr.id,
  mat.site_id,
  mat.id material_soil_id,
  mat.soil_type_code material_soil_type_code,
  pr.material_quantity,
  prod.id product_soil_id,
  prod.soil_type_code product_soil_type_code,
  pr.product_quantity,
  pr.date
FROM
  wastesoil.process pr
  JOIN wastesoil.soil mat
    ON pr.material_soil_id = mat.id
  JOIN wastesoil.soil prod
    ON pr.product_soil_id = prod.id
;