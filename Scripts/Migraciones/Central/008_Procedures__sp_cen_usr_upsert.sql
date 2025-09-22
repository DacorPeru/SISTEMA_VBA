USE SISGIPAT;
GO

-- (1) Asegura las columnas (idempotente)
IF COL_LENGTH('dbo.cen_usr','must_change_pwd') IS NULL
  ALTER TABLE dbo.cen_usr ADD must_change_pwd BIT NOT NULL
      CONSTRAINT DF_cen_usr_mcp DEFAULT(1) WITH VALUES;
IF COL_LENGTH('dbo.cen_usr','kdf_alg') IS NULL
  ALTER TABLE dbo.cen_usr ADD kdf_alg VARCHAR(32) NOT NULL
      CONSTRAINT DF_cen_usr_kdf DEFAULT('TSQL_STRETCH') WITH VALUES;
GO  -- 🔴 MUY IMPORTANTE este GO antes de crear el proc

-- (2) Compila limpio el procedimiento (drop + create en lotes separados)
IF OBJECT_ID('dbo.sp_cen_usr_upsert','P') IS NOT NULL
  DROP PROCEDURE dbo.sp_cen_usr_upsert;
GO

CREATE PROCEDURE dbo.sp_cen_usr_upsert
  @email NVARCHAR(320),
  @nombres NVARCHAR(100)=NULL,
  @ape_paterno NVARCHAR(100)=NULL,
  @ape_materno NVARCHAR(100)=NULL,
  @tipo_doc_codigo CHAR(3)=NULL,
  @tipo_doc_id SMALLINT=NULL,
  @nro_doc NVARCHAR(20)=NULL,
  @pwd_plain NVARCHAR(4000)=NULL,
  @est VARCHAR(20)='ACTIVO',
  @iter INT=120000
AS
BEGIN
  SET NOCOUNT ON;

  IF @iter IS NULL OR @iter < 100000 SET @iter = 100000;

  IF @tipo_doc_id IS NULL AND @tipo_doc_codigo IS NOT NULL
    SELECT @tipo_doc_id = tipo_doc_id
    FROM dbo.cat_tipo_doc
    WHERE codigo=@tipo_doc_codigo AND estado='ACTIVO';

  IF NOT EXISTS(SELECT 1 FROM dbo.cen_usr WHERE email=@email)
  BEGIN
    DECLARE @salt VARBINARY(16)=CRYPT_GEN_RANDOM(16);
    IF @pwd_plain IS NULL SET @pwd_plain=N'Admin123!';

    INSERT dbo.cen_usr(email,nombres,ape_paterno,ape_materno,tipo_doc_id,nro_doc,est,salt,[hash],[iter])
    VALUES(@email,@nombres,@ape_paterno,@ape_materno,@tipo_doc_id,@nro_doc,@est,@salt,
           dbo.fn_pbkdf2_sha256(@pwd_plain,@salt,@iter),@iter);

    UPDATE dbo.cen_usr SET must_change_pwd=1,kdf_alg='TSQL_STRETCH' WHERE email=@email;
  END
  ELSE
  BEGIN
    UPDATE dbo.cen_usr
      SET nombres=COALESCE(@nombres,nombres),
          ape_paterno=COALESCE(@ape_paterno,ape_paterno),
          ape_materno=COALESCE(@ape_materno,ape_materno),
          tipo_doc_id=COALESCE(@tipo_doc_id,tipo_doc_id),
          nro_doc=COALESCE(@nro_doc,nro_doc),
          est=@est
    WHERE email=@email;

    IF @pwd_plain IS NOT NULL
    BEGIN
      DECLARE @salt2 VARBINARY(16)=CRYPT_GEN_RANDOM(16);
      UPDATE dbo.cen_usr
         SET salt=@salt2,
             [hash]=dbo.fn_pbkdf2_sha256(@pwd_plain,@salt2,[iter]),
             must_change_pwd=0,
             kdf_alg='TSQL_STRETCH'
       WHERE email=@email;
    END
  END
END
GO
