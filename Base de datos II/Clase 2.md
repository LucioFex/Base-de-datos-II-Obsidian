#clase_2


# Estándares SDN

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


