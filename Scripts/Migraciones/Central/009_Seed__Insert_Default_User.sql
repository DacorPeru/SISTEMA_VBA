USE SISGIPAT;
GO
SET NOCOUNT ON;

IF OBJECT_ID('dbo.cen_usr','U') IS NULL
  THROW 51020, 'Falta dbo.cen_usr. Ejecuta 004_Tables__Create_cen_usr.sql.', 1;
IF OBJECT_ID('dbo.sp_cen_usr_upsert','P') IS NULL
  THROW 51022, 'Falta dbo.sp_cen_usr_upsert. Ejecuta 008_Procedures__sp_cen_usr_upsert.sql.', 1;

DECLARE @email NVARCHAR(320)=N'admin@sisgipat.com';
DECLARE @pwd   NVARCHAR(4000)=N'Admin';

DECLARE @tipo_doc_codigo CHAR(3)='DNI';
DECLARE @tipo_doc_id SMALLINT=(SELECT tipo_doc_id FROM dbo.cat_tipo_doc WHERE codigo=@tipo_doc_codigo AND estado='ACTIVO');

EXEC dbo.sp_cen_usr_upsert
  @email=@email,
  @nombres=N'GESMER BIULIER',
  @ape_paterno=N'REYES',
  @ape_materno=N'EUSTAQUIO',
  @tipo_doc_id=@tipo_doc_id,
  @nro_doc=N'00000000',
  @pwd_plain=@pwd,
  @est='ACTIVO',
  @iter=120000;

DECLARE @login INT;
EXEC @login = dbo.sp_cen_login @email=@email, @pwd_plain=@pwd;
IF @login=1 PRINT 'Login exitoso' ELSE PRINT 'Credenciales incorrectas';
GO
