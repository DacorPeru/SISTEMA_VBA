USE SISGIPAT;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* ============================================================
   Fallback KDF COMPATIBLE con versión anterior (NO PBKDF2)
   - Mantiene el mismo algoritmo (incluye BINARY_CHECKSUM+XOR).
   - Úsalo solo para bootstrap; luego migra a DLL PBKDF2.
   ============================================================ */
CREATE OR ALTER FUNCTION dbo.fn_pbkdf2_sha256
(
    @pwd  NVARCHAR(4000),
    @salt VARBINARY(16),
    @iter INT
)
RETURNS VARBINARY(32)
WITH SCHEMABINDING
AS
BEGIN
    IF @pwd IS NULL OR @salt IS NULL OR @iter IS NULL OR @iter < 1
        RETURN NULL;

    DECLARE @i   INT = 0;
    DECLARE @acc VARBINARY(32) = 0x;
    DECLARE @cur VARBINARY(32) = 0x;

    -- Semilla inicial
    SET @cur = HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), @pwd) + @salt);
    SET @acc = @cur;

    -- Bucle con mezcla (compatibilidad)
    WHILE @i < @iter - 1
    BEGIN
        SET @cur = HASHBYTES('SHA2_256', @cur);
        SET @acc = CONVERT(VARBINARY(32),
                 CAST(BINARY_CHECKSUM(@acc) ^ BINARY_CHECKSUM(@cur) AS VARBINARY(32)));
        SET @i += 1;
    END

    RETURN HASHBYTES('SHA2_256', @acc);
END
GO

/* Seguridad: no exponer a PUBLIC. Ejecútala solo desde SPs de bootstrap. */
DENY EXECUTE ON OBJECT::dbo.fn_pbkdf2_sha256 TO PUBLIC;
GO
