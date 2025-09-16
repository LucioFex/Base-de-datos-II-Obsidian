#clase_9

![[Pasted image 20250916192957.png]]

---

```sql


Drop PROCEDURE dbo.sp_insert_empresa


CREATE PROCEDURE dbo.sp_insert_empresa
    @par_razon_social         VARCHAR(250),
    @par_cuit                 BIGINT,
    @par_fecha_cierre         VARCHAR(5),
    @par_fecha_inscripcion    DATETIME,
    @par_id_tipo_entidad      INT,
    @par_id_provincia         INT,
    @debug                CHAR(1) = 'N' -- Mensaje de depuración (S/N)
as
/*-------- defecto -------------------
id_estado = 1 .. Activa
enfalta = 0 (no esta en falta)
tipo_cod_entidad = al valor ingresado en id_tipo_entidad

--------------------------------------*/
/*
razon social = no caracteres especiales y minimo 3 caracteres
cuit = 11 digitos y tiene que empezar si o si con 30 o 33 o 34
           no exista un cuit ya dado de alta

Fecha Cierre = fijo de 5 caracteres con el formato  DD/MM  - x eje 1 de Enero es 01/01
nro de serie = se calcula con el ultimo nro de serie + 1 entregado x tipo entidad y provincia

*/
BEGIN
    SET NOCOUNT ON;
    DECLARE @status INT = 0;

	/* validaciones de tipo de parametros ingresados */
	-- @par_razon_social   minimo 3 caracteres 
  	Declare @len_empresa int
	Select @len_empresa = len(@par_razon_social)
	IF @len_empresa < 3
		Begin
			IF @debug = 'S'
			BEGIN
				PRINT 'Error EL Nombre o razon social debe contener al menos 3 caracteres';
			END
			select @status = -1
			Return @status
		End

    -- @par_cuit  valido que cuit no exista 
	IF EXISTS (
				Select 1
				From dbo.t_empresa
				Where cuit = @par_cuit
			  )
	Begin
		IF @debug = 'S'
		BEGIN
			PRINT 'Ya existe una empresa con ese CUIT';
		END	
		select @status = -1
		Return @status

	End

	/*insert */

	/*control del insert catch */

    RETURN @status;
END


DECLARE @RC int
DECLARE @par_razon_social varchar(250)
DECLARE @par_cuit bigint
DECLARE @par_fecha_cierre varchar(5)
DECLARE @par_fecha_inscripcion datetime
DECLARE @par_id_tipo_entidad int
DECLARE @par_id_provincia int
DECLARE @debug char(1)

-- TODO: Set parameter values here.
Select @par_razon_social = 'La Nueva Empresa'
Select @par_cuit = 30552733211
Select @par_fecha_cierre = ''
Select @par_fecha_inscripcion = getdate()
Select @par_id_tipo_entidad = 1   /* cooperativa */
Select @par_id_provincia = 1       /* Buenos Aires  */
Select @debug = 'S'

EXECUTE @RC = [dbo].[sp_insert_empresa] 
   @par_razon_social
  ,@par_cuit
  ,@par_fecha_cierre
  ,@par_fecha_inscripcion
  ,@par_id_tipo_entidad
  ,@par_id_provincia
  ,@debug 
```