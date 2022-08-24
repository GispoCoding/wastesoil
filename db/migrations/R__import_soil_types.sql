insert into wastesoil.soil_type(code, description) values
    ('AR','Angular rock'),
    ('GR','Gravel'),
    ('S', 'Sand')
on conflict do nothing;
