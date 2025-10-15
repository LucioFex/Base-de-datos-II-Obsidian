#clase_12

# Intro

![[Pasted image 20251014184705.png]]

---
# Ejercicios

![[Pasted image 20251014185147.png]]

![[Pasted image 20251014190529.png]]

---


#### Modelo de trigger
```sql
CREATE TRIGGER trg_delete_<tabla>
ON <tabla>
INSTEAD OF DELETE
AS
BEGIN
	-- control de dato a borrar
    IF EXISTS (
    
    )
    BEGIN
        RAISERROR('No se puede eliminar xxxxxxxxxxxx.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    DELETE FROM <tabla>
    WHERE id_<tabla> =  id_<deleted> ;
END
```


---



![[Pasted image 20251014201109.png]]


```sql
-- Bloquea la eliminación de provincias con partidos asociados
CREATE OR ALTER TRIGGER dbo.le_trg_t_provincia_INSTEADDELETE_BloqueoConPartidos
ON dbo.t_provincia
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH provs_con_partidos AS (
        SELECT d.id_provincia, COUNT(*) AS cant
        FROM deleted d
        JOIN dbo.t_partido pr ON pr.id_provincia = d.id_provincia
        GROUP BY d.id_provincia
    )
    IF EXISTS (SELECT 1 FROM provs_con_partidos)
    BEGIN
        -- Lista todas las provincias en el lote que tienen partidos
        DECLARE @prov NVARCHAR(4000) =
            (SELECT STRING_AGG(CONCAT(N'''', p.descripcion, N''' (', pc.cant, N' partido/s)'), N', ')
             FROM provs_con_partidos pc
             JOIN dbo.t_provincia p ON p.id_provincia = pc.id_provincia);

        ;THROW 51020,
               CONCAT(N'No se puede eliminar la provincia ', @prov,
                      N' porque tiene partidos asociados.'), 1;
    END

    -- Si no hay asociaciones, se permite la baja
    DELETE p
    FROM dbo.t_provincia p
    JOIN deleted d ON d.id_provincia = p.id_provincia;
END
GO
```

---

