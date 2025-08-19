#clase_3

En esta clase descargamos Toad Data Modeler.
![[Pasted image 20250812184557.png]]

Ejs de SDN
![[Pasted image 20250812184645.png]]
![[Pasted image 20250812184650.png]]


---

![[Pasted image 20250812185521.png]]

![[Pasted image 20250812185526.png]]

![[Pasted image 20250812185833.png]]

![[Pasted image 20250812190001.png]]

![[Pasted image 20250812190359.png]]

![[Pasted image 20250812191036.png]]

![[Pasted image 20250812191442.png]]

```sql
Select *
From dbo.t_producto
/* agrego columna  */
ALTER TABLE dbo.t_producto
ADD estado CHAR(1) NULL   
-- A Activo
-- B Baja
/*actualizo datos de columna nueva*/
UPDATE t_Producto 
SET estado = 'A' 
WHERE estado IS NULL 
/* creamos restriccion default sobre la columna nueva */
ALTER TABLE t_producto
ADD CONSTRAINT estado_activo DEFAULT 'A'
FOR estado
USE [practica_clase]
GO
INSERT INTO dbo.t_producto(descripcion,precio,id_tipo_producto,id_marca)
VALUES('SSD 1Tera',40000,2,5)
/* agrego columna fecha */
ALTER TABLE dbo.t_producto
ADD fecha datetime NULL   
UPDATE dbo.t_producto 
SET fecha = getdate()
WHERE fecha IS NULL 
select *
From dbo.t_producto 
UPDATE dbo.t_producto 
SET fecha = dateadd(day, -7, fecha)
Where id_producto <> 26
```

```sql
/* creamos restriccion default sobre la columna nueva */
ALTER TABLE t_producto
ADD CONSTRAINT fecha_default DEFAULT getdate()
FOR fecha
INSERT INTO dbo.t_producto(descripcion,precio,id_tipo_producto,id_marca)
VALUES('HDD 2Tera',60000,2,5)
```

---

![[Pasted image 20250812194258.png]]

![[Pasted image 20250812200118.png]]

![[Pasted image 20250812200206.png]]

![[Pasted image 20250812200503.png]]

![[Pasted image 20250812201456.png]]

![[Pasted image 20250812203224.png]]

---

```sql
Select m.descripcion as marca, 
	Max(precio) as maximo,  Min(precio) as minimo , AVG(precio) as promedio, 
	Count(*) as cantidad, Sum(precio) as sumar
From dbo.t_producto p, 
	dbo.t_tipo_producto tp, 
	dbo.t_marca m
Where 
	p.id_tipo_producto = tp.id_tipo_producto
	and p.id_marca = m.id_marca
group by m.descripcion
order by 1 asc
```

```sql
Select m.descripcion as marca, 
	Max(precio) as maximo,  Min(precio) as minimo , AVG(precio) as promedio, 
	Count(*) as cantidad, Sum(precio) as sumar
From dbo.t_producto p, 
	dbo.t_tipo_producto tp, 
	dbo.t_marca m
Where 
	p.id_tipo_producto = tp.id_tipo_producto
	and p.id_marca = m.id_marca
group by m.descripcion
order by 1 asc
Select m.descripcion as marca, 
	Count(*) as cantidad
From dbo.t_producto p, 
	dbo.t_tipo_producto tp, 
	dbo.t_marca m
Where 
	p.id_tipo_producto = tp.id_tipo_producto
	and p.id_marca = m.id_marca
group by m.descripcion
having Count(*) > 3
order by 2 asc
```

---

# Práctica


![[Pasted image 20250812211412.png]]

```sql
create view vw_producto_detalle
as
Select p.id_producto, p.descripcion as producto, 
       p.precio, tp.descripcion as tipo_producto, m.descripcion as marca
From dbo.t_producto p, 
	dbo.t_tipo_producto tp, 
	dbo.t_marca m
Where 
	p.id_tipo_producto = tp.id_tipo_producto
	and p.id_marca = m.id_marca
Select *
From vw_producto_detalle
```

---

Toad
![[Pasted image 20250812215511.png]]

![[Pasted image 20250812215534.png]]


---

Para la próxima clase, va a revisar nuestras bases de datos para ver los datos que tenemos cargados, y ver las tablas creadas de hoy.

Quiere que tengamos:
- Las tablas
- Las vistas


![[Pasted image 20250812215743.png]]

![[Pasted image 20250812215810.png]]


---

```sql
Select m.descripcion as marca, 
	Max(precio) as maximo,  Min(precio) as minimo , AVG(precio) as promedio, 
	Count(*) as cantidad, Sum(precio) as sumar
From dbo.t_producto p, 
	dbo.t_tipo_producto tp, 
	dbo.t_marca m
Where 
	p.id_tipo_producto = tp.id_tipo_producto
	and p.id_marca = m.id_marca
group by m.descripcion
order by 1 asc
```

```sql
Select m.descripcion as marca, 
	Count(*) as cantidad
From dbo.t_producto p, 
	dbo.t_tipo_producto tp, 
	dbo.t_marca m
Where 
	p.id_tipo_producto = tp.id_tipo_producto
	and p.id_marca = m.id_marca
group by m.descripcion
having Count(*) > 3
order by 2 asc
```

```sql
Select * , 
		(
		Select descripcion 
		From dbo.t_tipo_producto tp
		Where 
			p.id_tipo_producto = tp.id_tipo_producto
		) as tipo_prod_subconsulta
From dbo.t_producto p 
Select p.*, tp.descripcion as tipo_prod
From 
	dbo.t_producto p ,
	dbo.t_tipo_producto tp
Where 
	p.id_tipo_producto = tp.id_tipo_producto
```

```sql
create view vw_producto_detalle
as
Select p.id_producto, p.descripcion as producto, 
       p.precio, tp.descripcion as tipo_producto, m.descripcion as marca
From dbo.t_producto p, 
	dbo.t_tipo_producto tp, 
	dbo.t_marca m
Where 
	p.id_tipo_producto = tp.id_tipo_producto
	and p.id_marca = m.id_marca
Select *
From vw_producto_detalle
```


[[Resolución actividad de la clase 3]]