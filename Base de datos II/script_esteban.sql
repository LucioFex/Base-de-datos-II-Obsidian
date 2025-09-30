/* Luciano Esteban - BD 2 - Parcial 1 - TEMA:
SELECT TOP (1000) [persona]
      ,[apellido]
      ,[nombres]
      ,[apellido_nombres]
      ,[apellido_elegido]
      ,[nombres_elegido]
      ,[apellido_nombres_elegido]
      ,[sexo]
      ,[nacionalidad]
      ,[usuario]
      ,[documento]
      ,[nro_documento]
      ,[tipo_documento]
      ,[desc_tipo_documento]
      ,[tipo_nro_documento]
      ,[id_imagen]
  FROM [practica_clase].[dbo].[parcial_personas]
*/

USE lesteban25;

SELECT DISTINCT [nacionalidad]
  FROM [practica_clase].[dbo].[parcial_personas]

 -- Ejecutá conectado al servidor y con permisos sobre ambas BDs
IF OBJECT_ID('lesteban25.dbo.parcial_personas','U') IS NOT NULL
    DROP TABLE lesteban25.dbo.parcial_personas;
GO

-- Data types
SELECT 
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = 'dbo'
  AND c.TABLE_NAME = 'parcial_personas';


SELECT *
INTO lesteban25.dbo.parcial_personas
FROM practica_clase.dbo.parcial_personas;
GO

-- Verificación
SELECT origen  = COUNT(*) FROM practica_clase.dbo.parcial_personas; -- 6297
SELECT destino = COUNT(*) FROM lesteban25.dbo.parcial_personas;     -- 6297


---------   Migración   ---------

SELECT * FROM lesteban25.dbo.parcial_personas; 


-- Generación de tablas para la migración:


-- DROP en orden seguro si ya existen
IF OBJECT_ID('dbo.pbd_documento','U')      IS NOT NULL DROP TABLE dbo.pbd_documento;
IF OBJECT_ID('dbo.pbd_persona','U')        IS NOT NULL DROP TABLE dbo.pbd_persona;
IF OBJECT_ID('dbo.pbd_tipo_documento','U') IS NOT NULL DROP TABLE dbo.pbd_tipo_documento;
IF OBJECT_ID('dbo.pbd_nacionalidad','U')   IS NOT NULL DROP TABLE dbo.pbd_nacionalidad;
IF OBJECT_ID('dbo.pbd_sexo','U')           IS NOT NULL DROP TABLE dbo.pbd_sexo;

CREATE TABLE dbo.pbd_sexo
(
  sexo_id NCHAR(1) NOT NULL,              -- 'M' / 'F'
  descripcion NVARCHAR(20) NULL,
  CONSTRAINT pk_pbd_sexo PRIMARY KEY(sexo_id)
);

CREATE TABLE dbo.pbd_nacionalidad
(
  nacionalidad_id TINYINT NOT NULL,       -- fuente: tinyint
  descripcion NVARCHAR(100) NULL,
  CONSTRAINT pk_pbd_nacionalidad PRIMARY KEY(nacionalidad_id)
);

CREATE TABLE dbo.pbd_tipo_documento
(
  tipo_documento_id TINYINT NOT NULL,     -- fuente: tinyint
  codigo NVARCHAR(10) NULL,
  descripcion NVARCHAR(50) NULL,
  CONSTRAINT pk_pbd_tipo_documento PRIMARY KEY(tipo_documento_id)
);

CREATE TABLE dbo.pbd_persona
(
  persona_id SMALLINT NOT NULL,           -- fuente: smallint
  apellido NVARCHAR(150) NOT NULL,
  nombres  NVARCHAR(150) NOT NULL,
  apellido_elegido NVARCHAR(150) NULL,
  nombres_elegido  NVARCHAR(150) NULL,
  sexo_id NCHAR(1) NOT NULL,
  nacionalidad_id TINYINT NOT NULL,
  usuario_legacy NVARCHAR(50) NULL,       -- en fuente viene varchar
  id_imagen NVARCHAR(150) NULL,

  CONSTRAINT pk_pbd_persona PRIMARY KEY(persona_id),
  CONSTRAINT fk_pbd_persona_sexo
    FOREIGN KEY(sexo_id) REFERENCES dbo.pbd_sexo(sexo_id),
  CONSTRAINT fk_pbd_persona_nacionalidad
    FOREIGN KEY(nacionalidad_id) REFERENCES dbo.pbd_nacionalidad(nacionalidad_id)
);

CREATE TABLE dbo.pbd_documento
(
  persona_id SMALLINT NOT NULL,
  tipo_documento_id TINYINT NOT NULL,
  numero_documento BIGINT NOT NULL,       -- castea desde varchar de la fuente

  CONSTRAINT pk_pbd_documento PRIMARY KEY(persona_id, tipo_documento_id),
  CONSTRAINT fk_pbd_documento_persona
    FOREIGN KEY(persona_id) REFERENCES dbo.pbd_persona(persona_id),
  CONSTRAINT fk_pbd_documento_tipo
    FOREIGN KEY(tipo_documento_id) REFERENCES dbo.pbd_tipo_documento(tipo_documento_id)
);

-- Índices
CREATE INDEX idx_pbd_persona_apellido ON dbo.pbd_persona(apellido);
CREATE INDEX idx_pbd_persona_nombres  ON dbo.pbd_persona(nombres);
CREATE INDEX idx_pbd_documento_numero ON dbo.pbd_documento(numero_documento);
CREATE INDEX idx_pbd_documento_tipo   ON dbo.pbd_documento(tipo_documento_id);

-- Poblado de tablas a partir de "dbo.parcial_personas".

-- 1) Sexo
MERGE dbo.pbd_sexo AS tgt
USING (
  SELECT DISTINCT TRIM(CAST(sexo AS NCHAR(1))) AS sexo_id
  FROM practica_clase.dbo.parcial_personas
  WHERE sexo IS NOT NULL
) AS src
ON tgt.sexo_id = src.sexo_id
WHEN NOT MATCHED BY TARGET THEN
  INSERT(sexo_id, descripcion)
  VALUES(src.sexo_id, CASE src.sexo_id WHEN N'M' THEN N'Masculino' WHEN N'F' THEN N'Femenino' END);

-- 2) Nacionalidad
MERGE dbo.pbd_nacionalidad AS tgt
USING (
  SELECT DISTINCT CAST(nacionalidad AS TINYINT) AS nacionalidad_id
  FROM practica_clase.dbo.parcial_personas
  WHERE nacionalidad IS NOT NULL
) AS src
ON tgt.nacionalidad_id = src.nacionalidad_id
WHEN NOT MATCHED BY TARGET THEN
  INSERT(nacionalidad_id, descripcion)
  VALUES(src.nacionalidad_id, CONCAT(N'COD_', CONVERT(nvarchar(10), src.nacionalidad_id)));

-- 3) Tipo de documento
MERGE dbo.pbd_tipo_documento AS tgt
USING (
  SELECT DISTINCT
    CAST(tipo_documento AS TINYINT) AS tipo_documento_id,
    NULLIF(LTRIM(RTRIM(CAST(desc_tipo_documento AS NVARCHAR(50)))), N'') AS descripcion
  FROM practica_clase.dbo.parcial_personas
  WHERE tipo_documento IS NOT NULL
) AS src
ON tgt.tipo_documento_id = src.tipo_documento_id
WHEN NOT MATCHED BY TARGET THEN
  INSERT(tipo_documento_id, codigo, descripcion)
  VALUES(src.tipo_documento_id, CONVERT(nvarchar(10), src.tipo_documento_id), src.descripcion);

-- 4) Personas
MERGE dbo.pbd_persona AS tgt
USING (
  SELECT
    CAST(persona AS SMALLINT) AS persona_id,
    LTRIM(RTRIM(CAST(apellido AS NVARCHAR(150)))) AS apellido,
    LTRIM(RTRIM(CAST(nombres  AS NVARCHAR(150)))) AS nombres,
    NULLIF(LTRIM(RTRIM(CAST(apellido_elegido AS NVARCHAR(150)))), N'') AS apellido_elegido,
    NULLIF(LTRIM(RTRIM(CAST(nombres_elegido  AS NVARCHAR(150)))), N'') AS nombres_elegido,
    TRIM(CAST(sexo AS NCHAR(1))) AS sexo_id,
    CAST(nacionalidad AS TINYINT) AS nacionalidad_id,
    CAST(usuario AS NVARCHAR(50)) AS usuario_legacy,
    CAST(id_imagen AS NVARCHAR(150)) AS id_imagen
  FROM practica_clase.dbo.parcial_personas
) AS src
ON tgt.persona_id = src.persona_id
WHEN NOT MATCHED BY TARGET THEN
  INSERT(persona_id, apellido, nombres, apellido_elegido, nombres_elegido,
         sexo_id, nacionalidad_id, usuario_legacy, id_imagen)
  VALUES(src.persona_id, src.apellido, src.nombres, src.apellido_elegido, src.nombres_elegido,
         src.sexo_id, src.nacionalidad_id, src.usuario_legacy, src.id_imagen);

-- 5) Documentos (robusto ante vacíos)
;WITH src AS (
  SELECT
    CAST(persona AS SMALLINT) AS persona_id,
    CAST(tipo_documento AS TINYINT) AS tipo_documento_id,
    TRY_CAST(NULLIF(LTRIM(RTRIM(CAST(nro_documento AS VARCHAR(50)))), '') AS BIGINT) AS numero_documento
  FROM practica_clase.dbo.parcial_personas
),
src_ok AS (
  SELECT DISTINCT persona_id, tipo_documento_id, numero_documento
  FROM src
  WHERE tipo_documento_id IS NOT NULL AND numero_documento IS NOT NULL
)
MERGE dbo.pbd_documento AS tgt
USING src_ok AS s
ON (tgt.persona_id = s.persona_id AND tgt.tipo_documento_id = s.tipo_documento_id)
WHEN NOT MATCHED BY TARGET THEN
  INSERT(persona_id, tipo_documento_id, numero_documento)
  VALUES(s.persona_id, s.tipo_documento_id, s.numero_documento);


-- (Opcional de verificación rápida)
SELECT TOP 20 * FROM dbo.pbd_persona;
SELECT TOP 20 * FROM dbo.pbd_documento;
SELECT * FROM dbo.pbd_sexo;
SELECT * FROM dbo.pbd_tipo_documento;
SELECT * FROM dbo.pbd_nacionalidad;



-- Sección de queries (encapsuladas en Stored Procedures)

/*
SP 1) Listado unificado de personas (JOIN de 5 tablas)
Filtros: apellido/nombres (LIKE), solo con documento, TOP N
*/
CREATE OR ALTER PROCEDURE dbo.pbd_sp_listar_personas_full
    @apellido_like        NVARCHAR(100) = NULL,
    @nombres_like         NVARCHAR(100) = NULL,
    @solo_con_documento   BIT           = 0,
    @top                  INT           = 100
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH base AS (
        SELECT
            pe.persona_id,
            pe.apellido,
            pe.nombres,
            ISNULL(pe.apellido_elegido, pe.apellido) AS apellido_final,
            ISNULL(pe.nombres_elegido,  pe.nombres)  AS nombres_final,
            sx.sexo_id,
            sx.descripcion                           AS sexo_desc,
            na.nacionalidad_id,
            na.descripcion                           AS nacionalidad_desc,
            td.tipo_documento_id,
            td.descripcion                           AS tipo_documento_desc,
            d.numero_documento,
            CONCAT(ISNULL(td.descripcion,N''), N' ', ISNULL(CONVERT(nvarchar(20), d.numero_documento), N'')) AS documento_completo
        FROM dbo.pbd_persona                  AS pe
        INNER JOIN dbo.pbd_sexo               AS sx ON sx.sexo_id = pe.sexo_id
        INNER JOIN dbo.pbd_nacionalidad       AS na ON na.nacionalidad_id = pe.nacionalidad_id
        LEFT JOIN dbo.pbd_documento           AS d  ON d.persona_id = pe.persona_id
        LEFT JOIN dbo.pbd_tipo_documento      AS td ON td.tipo_documento_id = d.tipo_documento_id
        WHERE (@apellido_like IS NULL OR pe.apellido LIKE @apellido_like)
          AND (@nombres_like  IS NULL OR pe.nombres  LIKE @nombres_like)
          AND (@solo_con_documento = 0 OR d.numero_documento IS NOT NULL)
    )
    SELECT TOP (@top) *
    FROM base
    ORDER BY apellido_final, nombres_final, tipo_documento_id;
END
GO

/*
SP 2) Métrica: cantidad de personas por Sexo y Tipo Documento
(JOIN de 4 tablas) – opcional: solo con documento
*/
CREATE OR ALTER PROCEDURE dbo.pbd_sp_metricas_por_sexo_y_tipodoc
    @solo_con_documento BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        sx.descripcion                                                AS sexo_desc,
        ISNULL(td.descripcion, N'(Sin documento)')                    AS tipo_documento,
        COUNT(DISTINCT pe.persona_id)                                 AS cantidad_personas
    FROM dbo.pbd_persona pe
    INNER JOIN dbo.pbd_sexo sx
      ON sx.sexo_id = pe.sexo_id
    LEFT JOIN dbo.pbd_documento d
      ON d.persona_id = pe.persona_id
    LEFT JOIN dbo.pbd_tipo_documento td
      ON td.tipo_documento_id = d.tipo_documento_id
    WHERE (@solo_con_documento = 0 OR d.numero_documento IS NOT NULL)
    GROUP BY sx.descripcion, ISNULL(td.descripcion, N'(Sin documento)')
    ORDER BY sx.descripcion, tipo_documento;
END
GO

/* SP 3) Personas sin documento (JOIN de 4 tablas) */
CREATE OR ALTER PROCEDURE dbo.pbd_sp_personas_sin_documento
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        pe.persona_id,
        pe.apellido,
        pe.nombres,
        sx.descripcion AS sexo_desc,
        na.nacionalidad_id,
        na.descripcion AS nacionalidad_desc
    FROM dbo.pbd_persona pe
    INNER JOIN dbo.pbd_sexo sx
      ON sx.sexo_id = pe.sexo_id
    INNER JOIN dbo.pbd_nacionalidad na
      ON na.nacionalidad_id = pe.nacionalidad_id
    LEFT JOIN dbo.pbd_documento d
      ON d.persona_id = pe.persona_id
    WHERE d.persona_id IS NULL
    ORDER BY pe.apellido, pe.nombres;
END
GO

/*
SP 4) Top nacionalidades por personas con documento específico
(JOIN de 4 tablas). Por defecto: DNI (= 0).
*/
CREATE OR ALTER PROCEDURE dbo.pbd_sp_top_nacionalidades_con_doc
    @tipo_documento_id  TINYINT = 0,   -- 0 = DNI (según tu carga)
    @top                INT     = 10
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@top)
        na.nacionalidad_id,
        ISNULL(na.descripcion, CONCAT(N'COD_', CONVERT(nvarchar(10), na.nacionalidad_id))) AS nacionalidad_desc,
        COUNT(DISTINCT pe.persona_id) AS personas_con_documento
    FROM dbo.pbd_persona pe
    INNER JOIN dbo.pbd_nacionalidad na
      ON na.nacionalidad_id = pe.nacionalidad_id
    INNER JOIN dbo.pbd_documento d
      ON d.persona_id = pe.persona_id
    INNER JOIN dbo.pbd_tipo_documento td
      ON td.tipo_documento_id = d.tipo_documento_id
    WHERE td.tipo_documento_id = @tipo_documento_id
    GROUP BY na.nacionalidad_id, na.descripcion
    ORDER BY personas_con_documento DESC, na.nacionalidad_id;
END
GO


-- Ejecuciones de ejemplo:
EXEC dbo.pbd_sp_listar_personas_full @apellido_like = N'S%', @top = 50;
EXEC dbo.pbd_sp_metricas_por_sexo_y_tipodoc @solo_con_documento = 1;
EXEC dbo.pbd_sp_personas_sin_documento;
EXEC dbo.pbd_sp_top_nacionalidades_con_doc @tipo_documento_id = 0, @top = 10; -- DNI
