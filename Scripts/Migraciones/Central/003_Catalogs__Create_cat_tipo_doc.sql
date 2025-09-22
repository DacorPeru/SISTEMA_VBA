-- Trabajamos dentro de la BD central
USE SISGIPAT;
GO

-- Crea el catálogo de tipos de documento si no existe (idempotente)
IF OBJECT_ID('dbo.cat_tipo_doc','U') IS NULL
BEGIN
    CREATE TABLE dbo.cat_tipo_doc(
        -- Clave surrogate pequeña (suficiente para un catálogo corto)
        tipo_doc_id  SMALLINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_cat_tipo_doc PRIMARY KEY,

        -- Clave natural de 3 caracteres fijos (DNI, CE, PAS, RUC, OTR)
        codigo       CHAR(3)       NOT NULL,

        -- Nombre descriptivo (Unicode para acentos, eñes)
        nombre       NVARCHAR(100) NOT NULL,

        -- Reglas opcionales de longitud para validar números de documento
        longitud_min TINYINT       NULL,
        longitud_max TINYINT       NULL,

        -- Si el documento admite solo dígitos (p.ej., DNI/RUC = 1)
        solo_numeros BIT           NULL,

        -- Estado funcional con default 'ACTIVO'
        estado       VARCHAR(20)   NOT NULL CONSTRAINT DF_cat_tipo_doc_est DEFAULT('ACTIVO'),

        -- Fecha de creación de alta precisión (100ns)
        f_cre        DATETIME2(7)  NOT NULL CONSTRAINT DF_cat_tipo_doc_fcre DEFAULT(SYSDATETIME())
    );

    -- Índice único por la clave natural: evita códigos duplicados
    CREATE UNIQUE INDEX UX_cat_tipo_doc_codigo ON dbo.cat_tipo_doc(codigo);
END
GO

/* Semilla idempotente + sincronización condicionada:
   - Inserta registros que falten.
   - Si algún código ya existe pero cambiaste nombre/longitud/solo_numeros, los actualiza.
*/
MERGE dbo.cat_tipo_doc AS t
USING (VALUES
  ('DNI', N'Documento Nacional de Identidad', 8,  8,  1),
  ('CE' , N'Carnet de Extranjería',           9,  12, 0),
  ('PAS', N'Pasaporte',                       6,  15, 0),
  ('RUC', N'Registro Único de Contribuyentes',11, 11, 1), -- << añadido: RUC (11 dígitos, solo numérico)
  ('OTR', N'Otro',                            NULL,NULL,NULL)
) AS s(codigo, nombre, longitud_min, longitud_max, solo_numeros)
ON t.codigo = s.codigo
WHEN MATCHED
     AND (ISNULL(t.nombre, N'')            <> s.nombre
       OR ISNULL(t.longitud_min, 255)      <> ISNULL(s.longitud_min, 255)
       OR ISNULL(t.longitud_max, 255)      <> ISNULL(s.longitud_max, 255)
       OR ISNULL(t.solo_numeros, 2)        <> ISNULL(s.solo_numeros, 2))
THEN UPDATE
     SET t.nombre        = s.nombre,
         t.longitud_min  = s.longitud_min,
         t.longitud_max  = s.longitud_max,
         t.solo_numeros  = s.solo_numeros
WHEN NOT MATCHED BY TARGET THEN
  INSERT (codigo, nombre, longitud_min, longitud_max, solo_numeros)
  VALUES (s.codigo, s.nombre, s.longitud_min, s.longitud_max, s.solo_numeros);
GO
