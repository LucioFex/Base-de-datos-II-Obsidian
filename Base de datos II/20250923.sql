CREATE TABLE [t_anio_academico]
(
 [id_anio_academico] Int IDENTITY NOT NULL,
 [descripcion] Varchar(150) NULL
)

ALTER TABLE [t_anio_academico] ADD CONSTRAINT [PK_t_anio_academico] PRIMARY KEY ([id_anio_academico])

CREATE TABLE [t_llamado]
(
 [id_llamado] Int IDENTITY NOT NULL,
 [num_llamado] Int NOT NULL,
 [periodo] Int NOT NULL,
 [nombre] Varchar(150) NULL,
 [fecha_inicio] Date NULL,
 [fecha_fin] Date NULL,
 [id_turno] Int NULL
)

go
-- Add keys for table t_llamado
ALTER TABLE [t_llamado] ADD CONSTRAINT [PK_t_llamado] PRIMARY KEY ([id_llamado])

go

-- Table t_turno
CREATE TABLE [t_turno]
(
 [id_turno] Int IDENTITY NOT NULL,
 [examen] Int NOT NULL,
 [periodo] Int NOT NULL,
 [nombre] Varchar(150) NULL,
 [fecha_inicio] Date NULL,
 [fecha_fin] Date NULL,
 [fecha_publicacion_mesas] Date NULL,
 [fecha_inactivacion] Date NULL,
 llamado int ,
 [id_anio_academico] Int NULL
)go

-- Add keys for table t_turno
ALTER TABLE [t_turno] ADD CONSTRAINT [PK_t_turno] PRIMARY KEY ([id_turno])
go


/*-- poblar datos de tablas  --*/


insert into dbo.t_anio_academico(descripcion)
select distinct anio_academico
FROM [practica_clase].[dbo].[turnos_examen]
order by 1


select *
from dbo.t_anio_academico

INSERT INTO [dbo].[t_turno]([examen],[periodo],[nombre],[fecha_inicio],[fecha_fin],
							[fecha_publicacion_mesas],[fecha_inactivacion],[id_anio_academico],llamado)
select turno_examen, 
	   turno_examen_periodo,
	   turno_examen_nombre,
	   cast (turno_examen_fecha_inicio as date) as fecha_inicio,
	   cast(turno_examen_fecha_fin as date) as fecha_fin,
	   cast(turno_examen_fecha_publicacion_mesas as date) as fecha_publicacion_mesas,
	   cast(turno_examen_fecha_inactivacion as date) as fecha_inactivacion,
	   id_anio_academico,
	   llamado
from practica_clase.dbo.turnos_examen, t_anio_academico
where cast(practica_clase.dbo.turnos_examen.anio_academico as varchar(10)) = t_anio_academico.descripcion



insert into dbo.t_llamado(num_llamado,periodo,nombre,fecha_inicio,fecha_fin, id_turno)
select  
    te.llamado,
    te.llamado_periodo,
    te.llamado_nombre,
    CAST(te.llamado_fecha_inicio AS DATE),
    CAST(te.llamado_fecha_fin AS DATE),
    tt.id_turno
FROM [practica_clase].[dbo].[turnos_examen] AS te, [dbo].[t_turno] AS tt
WHERE te.[turno_examen] = tt.[examen]
    AND te.[llamado] = tt.[llamado];
