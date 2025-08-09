USE lesteban25

CREATE TABLE dbo.t_tipo_producto (
    id INT IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
);

CREATE TABLE dbo.t_marca (
    id INT IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
);

CREATE TABLE dbo.t_producto (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(25) NOT NULL,
    precio NUMERIC(15, 2) NULL,
    id_tipo_producto INT NOT NULL,
    marca_id INT NOT NULL,
    CONSTRAINT FK_producto_tipo_producto FOREIGN KEY (id_tipo_producto) REFERENCES dbo.t_tipo_producto(id),
    CONSTRAINT FK_producto_marca FOREIGN KEY (marca_id) REFERENCES dbo.t_marca(id)
);


-- Creación de índices:

-- Relación entre producto y su tipo
CREATE NONCLUSTERED INDEX IX_producto_id_tipo_producto ON dbo.t_producto (id_tipo_producto);

-- Relación entre producto y su marca
CREATE NONCLUSTERED INDEX IX_producto_marca_id ON dbo.t_producto (marca_id);


-- Dummy data

-- Seteamos primero los seriales a 0 por las dudas.
DBCC CHECKIDENT ('dbo.t_producto', RESEED, 0);
DBCC CHECKIDENT ('dbo.t_marca', RESEED, 0);
DBCC CHECKIDENT ('dbo.t_tipo_producto', RESEED, 0);


INSERT INTO dbo.t_tipo_producto (descripcion) VALUES
('Electrónica'), 
('Ropa'), 
('Hogar y Jardín'), 
('Alimentos y Bebidas'), 
('Juguetes'),
('Deportes'), 
('Libros y Papelería'), 
('Mascotas'), 
('Herramientas'), 
('Belleza y Cuidado Personal');

INSERT INTO dbo.t_marca (descripcion) VALUES
('TecnoMundo'), ('VisteBien'), ('CasaFácil'), ('Delicias S.A.'), ('GlobalCorp'),
('Sportiva'), ('Letras Vivas'), ('MundoAnimal'), ('Ferrex'), ('BellaPiel'),
('GamerZone'), ('AudioPro'), ('ChefMaestro'), ('EcoVida'), ('Infantiles'),
('Aventura Extrema'), ('OfiTech'), ('DulceHogar'), ('MotorPlus'), ('Saludable');

INSERT INTO dbo.t_producto (descripcion, precio, id_tipo_producto, marca_id) VALUES
-- Productos 1-10
('Smartphone X1', 899990.50, 1, 1), 
('Remera Estampada', 25500.00, 2, 2), 
('Lámpara de Escritorio', 32000.75, 3, 3),
('Galletitas de Chocolate', 1850.00, 4, 4), 
('Laptop Pro', 1850000.00, 1, 5), 
('Jean Clásico', 48000.00, 2, 2),
('Auto a Fricción', 12500.99, 5, 15), 
('Café Molido 500g', 8900.00, 4, 4), 
('Teclado USB', 21800.00, 1, 3),
('Almohada Viscoelástica', 35000.00, 3, 18),
-- Productos 11-20
('Balón de Fútbol', 29900.00, 6, 6), 
('Set de Mancuernas 5kg', 45000.00, 6, 16), 
('Botella de Agua 1L', 15000.00, 6, 6),
('Yoga Mat', 25500.50, 6, 20), 
('Novela de Misterio', 22000.00, 7, 7), 
('Cuaderno Universitario', 8500.00, 7, 17),
('Resaltadores Pastel x6', 9900.00, 7, 17), 
('Agenda 2025', 18000.00, 7, 7), 
('Alimento para Perro 15kg', 85000.00, 8, 8),
('Rascador para Gato', 42000.00, 8, 8),
-- Productos 21-30
('Correa Paseo Retráctil', 19500.00, 8, 18), 
('Juguete Hueso Goma', 9800.00, 8, 8),
('Set de Destornilladores', 38000.00, 9, 9), 
('Taladro Percutor 500W', 95000.00, 9, 9), 
('Caja de Herramientas', 55000.00, 9, 19),
('Cinta Métrica 5m', 12000.00, 9, 9), 
('Crema Hidratante Facial', 28000.00, 10, 10), 
('Protector Solar FPS 50', 25000.00, 10, 20),
('Set de Maquillaje', 49900.00, 10, 10), 
('Shampoo Orgánico', 19900.00, 10, 20),
-- Productos 31-40
('Monitor Gamer 24"', 450000.00, 1, 11),
('Auriculares Inalámbricos', 95000.00, 1, 12), 
('Buzo con Capucha', 65000.00, 2, 6), 
('Zapatillas Urbanas', 89000.00, 2, 16),
('Juego de Sábanas Queen', 58000.00, 3, 18), 
('Batidora de Mano', 42000.00, 3, 13), 
('Snack de Frutos Secos', 6500.00, 4, 20),
('Jugo de Naranja 1.5L', 3200.00, 4, 4), 
('Muñeca Articulada', 29500.00, 5, 15), 
('Mouse Ergonómico', 35000.00, 1, 17),
-- Productos 41-50
('Pantalón de Jogging', 49500.00, 2, 6), 
('Taza de Cerámica', 9900.00, 3, 18), 
('Aceite para Motor', 25000.00, 9, 19),
('Vela Aromática', 14000.00, 3, 10), 
('Libro de Cocina Vegana', 32000.00, 7, 20), 
('Pelota de Tenis x3', 11000.00, 6, 6),
('Comida para Gato 3kg', 25000.00, 8, 8), 
('Martillo', 18000.00, 9, 9), 
('Máscara de Pestañas', 16500.00, 10, 10),
('Silla de Oficina', 180000.00, 3, 17);

-- Visualización general de datos

SELECT * FROM dbo.t_tipo_producto;
SELECT * FROM dbo.t_marca;
SELECT * FROM dbo.t_producto;

-- Consulta JOIN de las 3 Tablas

SELECT
    p.id_producto,
    p.descripcion AS producto,
    p.precio,
    tp.descripcion AS tipo_de_producto,
    m.descripcion AS marca
FROM
    dbo.t_producto AS p
INNER JOIN
    dbo.t_tipo_producto AS tp ON p.id_tipo_producto = tp.id
INNER JOIN
    dbo.t_marca AS m ON p.marca_id = m.id
ORDER BY
    p.id_producto;

/*
producto				precio		tipo_de_producto	id_producto	 marca
----------------------------------------------------------------------------------
Smartphone X1	        899990.50	Electrónica			1			 TecnoMundo
Remera Estampada	    25500.00	Ropa				2			 VisteBien
Lámpara de Escritorio	32000.75	Hogar y Jardín		3			 CasaFácil
Galletitas de Chocolate	1850.00		Alimentos y Bebidas	4			 Delicias S.A.
Laptop Pro	            1850000.00	Electrónica			5			 GlobalCorp
...						...			...					...			 ...
*/


