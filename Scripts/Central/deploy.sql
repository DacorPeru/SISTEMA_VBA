-- Ejecuta este archivo en SSMS con SQLCMD Mode habilitado (Query > SQLCMD Mode)
:r .\00-create-db.sql
:r .\tables\superadmins.sql
:r .\tables\empresas.sql
:r .\procs\sp_superadmin_crear.sql
:r .\procs\sp_superadmin_cambiar_clave.sql
:r .\procs\sp_superadmin_login.sql
:r .\procs\sp_empresas_listar.sql
:r .\procs\sp_empresa_upsert.sql
:r .\procs\sp_empresa_cambiar_estado.sql
:r .\seed\seed_superadmin.sql
PRINT 'CENTRAL desplegado correctamente';
