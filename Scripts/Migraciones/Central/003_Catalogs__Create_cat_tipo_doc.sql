USE SISGIPAT;
GO

IF OBJECT_ID('dbo.cat_tipo_doc','U') IS NULL
BEGIN
  CREATE TABLE dbo.cat_tipo_doc(
    tipo_doc_id    SMALLINT IDENTITY(1,1) PRIMARY KEY,
    codigo         CHAR(3)      NOT NULL,
    nombre         NVARCHAR(100) NOT NULL,
    longitud_min   TINYINT      NULL,
    longitud_max   TINYINT      NULL,
    solo_numeros   BIT          NULL,
    estado         VARCHAR(20)  NOT NULL CONSTRAINT DF_cat_tipo_doc_estado DEFAULT('ACTIVO'),
    f_cre          DATETIME2(7) NOT NULL CONSTRAINT DF_cat_tipo_doc_fcre DEFAULT(SYSDATETIME())
  );

  CREATE UNIQUE INDEX UQ_cat_tipo_doc_codigo ON dbo.cat_tipo_doc(codigo);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.cat_tipo_doc WHERE codigo='CE')
  INSERT dbo.cat_tipo_doc(codigo,nombre,longitud_min,longitud_max,solo_numeros) VALUES('CE','Carnet de Extranjería',9,12,0);
IF NOT EXISTS (SELECT 1 FROM dbo.cat_tipo_doc WHERE codigo='DNI')
  INSERT dbo.cat_tipo_doc(codigo,nombre,longitud_min,longitud_max,solo_numeros) VALUES('DNI','Documento Nacional de Identidad',8,8,1);
IF NOT EXISTS (SELECT 1 FROM dbo.cat_tipo_doc WHERE codigo='OTR')
  INSERT dbo.cat_tipo_doc(codigo,nombre) VALUES('OTR','Otro');
IF NOT EXISTS (SELECT 1 FROM dbo.cat_tipo_doc WHERE codigo='PAS')
  INSERT dbo.cat_tipo_doc(codigo,nombre,longitud_min,longitud_max,solo_numeros) VALUES('PAS','Pasaporte',6,15,0);
IF NOT EXISTS (SELECT 1 FROM dbo.cat_tipo_doc WHERE codigo='RUC')
  INSERT dbo.cat_tipo_doc(codigo,nombre,longitud_min,longitud_max,solo_numeros) VALUES('RUC','Registro Único de Contribuyentes',11,11,1);
GO
