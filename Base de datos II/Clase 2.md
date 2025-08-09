#clase_2

# Estándares SDN (ejemplo de la empresa del profe)

![[Pasted image 20250805191720.png]]

![[Pasted image 20250805192023.png]]

Notas:
- 1. Nomenclatura General
	- El profe usa prefijos por propietario de bd

---


![[Pasted image 20250805195942.png]]
![[Pasted image 20250805200021.png]]

![[Pasted image 20250805200347.png]]
![[Pasted image 20250805202106.png]]

```sql
USE lesteban25;

CREATE TABLE dbo.t_producto(
    id_producto INT IDENTITY(1,1) NOT NULL,
    descripcion VARCHAR(25)
);


CREATE UNIQUE NONCLUSTERED INDEX idx_t_producto_id_producto
ON dbo.t_producto (id_producto);

INSERT INTO t_producto (descripcion) VALUES
('Mouse óptico'),
('Teclado gamer'),
('Monitor 24 pulgadas'),
('Notebook 15.6"'),
('Disco SSD 512GB'),
('Memoria RAM 8GB'),
('Gabinete ATX'),
('Placa de video 4GB'),
('Fuente 600W'),
('Cámara web HD'),
('Micrófono USB'),
('Auriculares gamer'),
('Switch HDMI'),
('Cable VGA'),
('Impresora multifunción'),
('Scanner portátil'),
('Pendrive 64GB'),
('Router inalámbrico'),
('Smartphone Android'),
('Tablet 10 pulgadas');

SELECT * FROM dbo.t_producto;
```

---

```sql
drop table dbo.t_producto

create table dbo.t_producto(
    id_producto integer identity(1,1) not null,
    descripcion varchar(25) not null,
    precio numeric(15,2) null
)

-- creando indice principal
-- create index idx_producto_id_producto on dbo.t_producto(id_producto)

-- puede existir mas de uno
create  nonclustered index idx_producto_precio on dbo.t_producto(id_producto)

-- se crea uno si o si
create clustered index idx_producto_id_producto on dbo.t_producto(id_product
```

---

![[Pasted image 20250805203111.png]]

![[Pasted image 20250805203124.png]]

---

![[Pasted image 20250805211616.png]]

![[Pasted image 20250805215902.png]]

---

![[Pasted image 20250805221201.png]]

![[Pasted image 20250805221214.png]]
![[Pasted image 20250805221255.png]]
# ![[Resolución actividad de la clase 2]]

