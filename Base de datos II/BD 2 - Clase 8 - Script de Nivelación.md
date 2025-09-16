#clase_8

# Script de nivelación

## Estructura y datos

![[Pasted image 20250914185050.png]]
![[BD2_Clase8_ScriptNivelacion.sql]]
```sql
/* =========================================================
Script de nivelación:
   RESET + CLONADO de la BD de la clase "practica_clase" → [TU PROPIA BD] (ej: "lesteban25")
   - Limpia por completo la base de datos (tablas, FKs, vistas, SPs…)
   - Copia tablas + datos (SELECT INTO)
   - Crea PK/FK/Índices
============================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;

USE [lesteban25]; -- <---------- Reemplazar por tu BD personal
GO

BEGIN TRY
  BEGIN TRAN;

  /* =======================================================
     0) RESET TOTAL: Drop de objetos de la BD
     ======================================================= */

  DECLARE @sql NVARCHAR(MAX);

  -- Drop FKs
  SELECT @sql = STRING_AGG('ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) 
           + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) 
           + ' DROP CONSTRAINT ' + QUOTENAME(name) + ';', CHAR(10))
  FROM sys.foreign_keys;
  IF @sql IS NOT NULL EXEC sp_executesql @sql;

  -- Drop tablas
  SELECT @sql = STRING_AGG('DROP TABLE ' + QUOTENAME(SCHEMA_NAME(schema_id)) 
           + '.' + QUOTENAME(name) + ';', CHAR(10))
  FROM sys.tables;
  IF @sql IS NOT NULL EXEC sp_executesql @sql;

  -- Drop vistas
  SELECT @sql = STRING_AGG('DROP VIEW ' + QUOTENAME(SCHEMA_NAME(schema_id)) 
           + '.' + QUOTENAME(name) + ';', CHAR(10))
  FROM sys.views;
  IF @sql IS NOT NULL EXEC sp_executesql @sql;

  -- Drop SPs
  SELECT @sql = STRING_AGG('DROP PROCEDURE ' + QUOTENAME(SCHEMA_NAME(schema_id)) 
           + '.' + QUOTENAME(name) + ';', CHAR(10))
  FROM sys.procedures;
  IF @sql IS NOT NULL EXEC sp_executesql @sql;

  -- Drop funciones escalares / tabla
  SELECT @sql = STRING_AGG('DROP FUNCTION ' + QUOTENAME(SCHEMA_NAME(schema_id)) 
           + '.' + QUOTENAME(name) + ';', CHAR(10))
  FROM sys.objects
  WHERE type IN ('FN','IF','TF');
  IF @sql IS NOT NULL EXEC sp_executesql @sql;

  PRINT 'Base de datos limpiada correctamente.';

  /* =======================================================
     1) Clonado de tablas y datos desde practica_clase
     ======================================================= */

  -- SELECT INTO crea las tablas con mismo tipo e IDENTITY
  SELECT * INTO dbo.t_tipo_entidad   FROM practica_clase.dbo.t_tipo_entidad;
  SELECT * INTO dbo.t_estado         FROM practica_clase.dbo.t_estado;
  SELECT * INTO dbo.t_provincia      FROM practica_clase.dbo.t_provincia;
  SELECT * INTO dbo.t_partido        FROM practica_clase.dbo.t_partido;
  SELECT * INTO dbo.t_localidad      FROM practica_clase.dbo.t_localidad;
  SELECT * INTO dbo.t_empresa        FROM practica_clase.dbo.t_empresa;
  SELECT * INTO dbo.t_domicilio      FROM practica_clase.dbo.t_domicilio;
  SELECT * INTO dbo.t_contacto       FROM practica_clase.dbo.t_contacto;
  SELECT * INTO dbo.t_marca          FROM practica_clase.dbo.t_marca;
  SELECT * INTO dbo.t_tipo_producto  FROM practica_clase.dbo.t_tipo_producto;
  SELECT * INTO dbo.t_producto       FROM practica_clase.dbo.t_producto;
  SELECT * INTO dbo.t_moneda         FROM practica_clase.dbo.t_moneda;
  SELECT * INTO dbo.t_sucursal       FROM practica_clase.dbo.t_sucursal;
  SELECT * INTO dbo.t_sistema        FROM practica_clase.dbo.t_sistema;

  /* =======================================================
     2) Recreación de PK/FK/Índices
     ======================================================= */

  -- PKs
  ALTER TABLE dbo.t_tipo_entidad  ADD CONSTRAINT PK_t_tipo_entidad  PRIMARY KEY (id_tipo_entidad);
  ALTER TABLE dbo.t_estado        ADD CONSTRAINT PK_t_estado        PRIMARY KEY (id_estado);
  ALTER TABLE dbo.t_provincia     ADD CONSTRAINT PK_t_provincia     PRIMARY KEY (id_provincia);
  ALTER TABLE dbo.t_partido       ADD CONSTRAINT PK_t_partido       PRIMARY KEY (id_partido);
  ALTER TABLE dbo.t_localidad     ADD CONSTRAINT PK_t_localidad     PRIMARY KEY (id_localidad);
  ALTER TABLE dbo.t_empresa       ADD CONSTRAINT PK_t_empresa       PRIMARY KEY (id_empresa);
  ALTER TABLE dbo.t_domicilio     ADD CONSTRAINT PK_t_domicilio     PRIMARY KEY (id_domicilio);
  ALTER TABLE dbo.t_contacto      ADD CONSTRAINT PK_t_contacto      PRIMARY KEY (id_contacto);
  ALTER TABLE dbo.t_marca         ADD CONSTRAINT pk_t_marca_id_marca PRIMARY KEY (id_marca);
  ALTER TABLE dbo.t_tipo_producto ADD CONSTRAINT pk_t_tipo_producto_id_tipo_producto PRIMARY KEY (id_tipo_producto);

  -- FKs principales
  ALTER TABLE dbo.t_partido   ADD CONSTRAINT FK_partido_provincia       FOREIGN KEY (id_provincia) REFERENCES dbo.t_provincia(id_provincia);
  ALTER TABLE dbo.t_localidad ADD CONSTRAINT FK_localidad_partido       FOREIGN KEY (id_partido) REFERENCES dbo.t_partido(id_partido);
  ALTER TABLE dbo.t_empresa   ADD CONSTRAINT FK_empresa_tipo_entidad    FOREIGN KEY (id_tipo_entidad) REFERENCES dbo.t_tipo_entidad(id_tipo_entidad);
  ALTER TABLE dbo.t_empresa   ADD CONSTRAINT FK_empresa_provincia       FOREIGN KEY (id_provincia) REFERENCES dbo.t_provincia(id_provincia);
  ALTER TABLE dbo.t_empresa   ADD CONSTRAINT FK_empresa_estado          FOREIGN KEY (id_estado) REFERENCES dbo.t_estado(id_estado);
  ALTER TABLE dbo.t_domicilio ADD CONSTRAINT FK_domicilio_empresa       FOREIGN KEY (id_empresa) REFERENCES dbo.t_empresa(id_empresa);
  ALTER TABLE dbo.t_domicilio ADD CONSTRAINT FK_domicilio_localidad     FOREIGN KEY (id_localidad) REFERENCES dbo.t_localidad(id_localidad);
  ALTER TABLE dbo.t_contacto  ADD CONSTRAINT FK_contacto_empresa        FOREIGN KEY (id_empresa) REFERENCES dbo.t_empresa(id_empresa);
  ALTER TABLE dbo.t_producto  ADD CONSTRAINT FK_producto_tipo_producto  FOREIGN KEY (id_tipo_producto) REFERENCES dbo.t_tipo_producto(id_tipo_producto);
  ALTER TABLE dbo.t_producto  ADD CONSTRAINT FK_producto_marca          FOREIGN KEY (id_marca) REFERENCES dbo.t_marca(id_marca);

  -- Índices para optimizar joins
  CREATE INDEX IX_partido_id_provincia        ON dbo.t_partido(id_provincia);
  CREATE INDEX IX_localidad_id_partido        ON dbo.t_localidad(id_partido);
  CREATE INDEX IX_empresa_id_tipo_entidad     ON dbo.t_empresa(id_tipo_entidad);
  CREATE INDEX IX_empresa_id_provincia        ON dbo.t_empresa(id_provincia);
  CREATE INDEX IX_empresa_id_estado           ON dbo.t_empresa(id_estado);
  CREATE INDEX IX_domicilio_id_empresa        ON dbo.t_domicilio(id_empresa);
  CREATE INDEX IX_domicilio_id_localidad      ON dbo.t_domicilio(id_localidad);
  CREATE INDEX IX_contacto_id_empresa         ON dbo.t_contacto(id_empresa);
  CREATE INDEX IX_producto_id_tipo_producto   ON dbo.t_producto(id_tipo_producto);
  CREATE INDEX IX_producto_id_marca           ON dbo.t_producto(id_marca);

  COMMIT TRAN;
  PRINT 'Base reinicializada y clonada correctamente.';
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK TRAN;
  THROW;
END CATCH
GO
```


## Nivelación de Stored Procedures

sdn_sp_listar_empresa_v02.sql
```sql
/********************************************************************
Nombre      : sdn_sp_listar_empresa
Autor       : [Tu Nombre]
Fecha       : 2025-09-09
Descripción : Lista las empresas filtradas por código de entidad
Parámetros  : @par_codigo_entidad, @debug, @status
Retorno     : 0 = Éxito, -1 = Error
*********************************************************************/
CREATE OR ALTER PROCEDURE sdn_sp_listar_empresa_v02
    @par_codigo_entidad INT = NULL,
    @debug CHAR(1) = 'N',
    @status INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @var_cod_entidad_rowcount INT,
            @error_message NVARCHAR(4000)

    -- Inicializar estado
    SET @status = 0

    IF @debug = 'S'
        PRINT 'Iniciando sdn_sp_listar_empresa...'

    BEGIN TRY
        /* Validación: existe el código entidad */
        SELECT @var_cod_entidad_rowcount = COUNT(*)
        FROM dbo.t_tipo_entidad
        WHERE codigo_entidad = @par_codigo_entidad

        IF @var_cod_entidad_rowcount <> 1 
        BEGIN
            IF @debug = 'S'
                PRINT 'No existe el código entidad proporcionado.'

            SET @status = -1
            RAISERROR('No existe código Entidad. Revisar código antes de ejecutar.', 14, 1)
            RETURN @status
        END
        ELSE
        BEGIN
            IF @debug = 'S'
                PRINT 'Código entidad válido. Ejecutando query final...'
        END

        /* Ejecución de consulta principal */
        SELECT 
            emp.razon_social, 
            emp.cuit
        FROM dbo.t_empresa emp
        INNER JOIN dbo.t_tipo_entidad te 
            ON emp.id_tipo_entidad = te.id_tipo_entidad
        WHERE te.codigo_entidad = @par_codigo_entidad
        ORDER BY emp.razon_social

        -- Éxito
        SET @status = 0
    END TRY
    BEGIN CATCH
        SET @status = ERROR_NUMBER()
        SET @error_message = ERROR_MESSAGE()

        IF @debug = 'S'
            PRINT 'Error capturado en TRY...CATCH'

        RAISERROR(@error_message, 16, 1)
    END CATCH
END
```

sp_listar_emp_x_tipo.sql
```sql
create procedure sp_listar_emp_x_tipo
@par_codigo_entidad int null,
@debug varchar(1)
as
/*declaracion de variables*/
Declare @status int
Declare @tipo_entidad_return varchar(3)
select @status = 0

/* controlar el codigo de parametro codigo entidad */
declare @var_cod_entidad_rowcount int

select @var_cod_entidad_rowcount = count(*)
from dbo.t_tipo_entidad
Where codigo_entidad = @par_codigo_entidad

If @var_cod_entidad_rowcount <> 1 
Begin
	if @debug = 'S' 
	   print 'no existe codigo entidad'

	Select @tipo_entidad_return = 'ALL'
End
else
   if @debug = 'S' 
      print 'existe codigo entidad'

/*ejecucion de query final*/

If @tipo_entidad_return = 'ALL'

        SELECT 
            emp.razon_social,
            emp.cuit,
            te.codigo_entidad
        FROM dbo.t_empresa emp
        INNER JOIN dbo.t_tipo_entidad te
            ON emp.id_tipo_entidad = te.id_tipo_entidad
        ORDER BY emp.razon_social;
Else
        SELECT 
            emp.razon_social,
            emp.cuit,
            te.codigo_entidad
        FROM dbo.t_empresa emp
        INNER JOIN dbo.t_tipo_entidad te
            ON emp.id_tipo_entidad = te.id_tipo_entidad
        WHERE te.codigo_entidad = @par_codigo_entidad
        ORDER BY emp.razon_social;

Return @status 

```

#### Llamadas de SPs:

```sql
DECLARE @RC int
DECLARE @par_codigo_entidad int
DECLARE @debug varchar(1)
-- TODO: Set parameter values here.
select @par_codigo_entidad = 5000, @debug = 'S'
EXECUTE @RC = [dbo].[sp_listar_emp_x_tipo] 
   @par_codigo_entidad
  ,@debug
```

```sql
DECLARE @RC int
DECLARE @par_codigo_entidad int
DECLARE @debug char(1)
DECLARE @status int
select @par_codigo_entidad = 21, @debug = 'S',  @status = 0
-- TODO: Set parameter values here.
EXECUTE @RC = [dbo].[sdn_sp_listar_empresa_v02] 
   @par_codigo_entidad
  ,@debug
  ,@status OUTPUT
```