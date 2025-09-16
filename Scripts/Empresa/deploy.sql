-- Ejecuta este archivo en SSMS con SQLCMD Mode habilitado (Query > SQLCMD Mode)
-- Antes de ejecutar, asegúrate de estar CONECTADO a la BD de la EMPRESA deseada.
:r .\tables\usuarios.sql
:r .\tables\roles.sql
:r .\tables\usuario_rol.sql
:r .\procs\sp_login.sql
:r .\procs\sp_usuario_crear.sql
:r .\procs\sp_usuario_cambiar_clave.sql
:r .\procs\sp_usuario_asignar_rol.sql
:r .\procs\sp_usuario_quitar_rol.sql
:r .\seed\seed_roles.sql
PRINT 'EMPRESA desplegada correctamente';
