CREATE DATABASE IF NOT EXISTS Joins
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE Joins;

-- Tabla de autores
CREATE TABLE autores (
    id_autor INT AUTO_INCREMENT PRIMARY KEY,
    nombre_autor VARCHAR(100),
    nacionalidad VARCHAR(50)
);

-- Tabla de editoriales
CREATE TABLE editoriales (
    id_editorial INT AUTO_INCREMENT PRIMARY KEY,
    nombre_editorial VARCHAR(100)
);

-- Tabla de libros
CREATE TABLE libros (
    id_libro INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150),
    anio_publicacion INT,
    id_autor INT,
    id_editorial INT,
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor),
    FOREIGN KEY (id_editorial) REFERENCES editoriales(id_editorial)
);

-- Tabla de usuarios
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre_usuario VARCHAR(100),
    email VARCHAR(100),
    fecha_registro DATE
);

-- Tabla de préstamos
CREATE TABLE prestamos (
    id_prestamo INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    id_libro INT,
    fecha_prestamo DATE,
    fecha_devolucion DATE,
    devuelto BOOLEAN,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_libro) REFERENCES libros(id_libro)
);

-- Tabla de valoraciones
CREATE TABLE valoraciones (
    id_valoracion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    id_libro INT,
    puntuacion INT,
    comentario TEXT,
    fecha_valoracion DATE,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_libro) REFERENCES libros(id_libro)
);

-- Tabla de multas
CREATE TABLE multas (
    id_multa INT AUTO_INCREMENT PRIMARY KEY,
    id_prestamo INT,
    importe DECIMAL(6,2),
    pagada BOOLEAN,
    FOREIGN KEY (id_prestamo) REFERENCES prestamos(id_prestamo)
);

-- Tabla de productos (ejemplo inicial)
CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre_producto VARCHAR(100),
    precio DECIMAL(8,2)
);

-- AUTORES

INSERT INTO autores (nombre_autor, nacionalidad) VALUES
('Gabriel García Márquez', 'Colombiana'),
('Isabel Allende', 'Chilena'),
('Jorge Luis Borges', 'Argentina'),
('Miguel de Cervantes', 'Española');

-- EDITORIALES


INSERT INTO editoriales (nombre_editorial) VALUES
('Editorial Sudamericana'),
('Planeta'),
('Penguin Random House'),
('Anagrama');

-- LIBROS

INSERT INTO libros (titulo, anio_publicacion, id_autor, id_editorial) VALUES
('Cien años de soledad', 1967, 1, 1),
('El amor en los tiempos del cólera', 1985, 1, 2),
('La casa de los espíritus', 1982, 2, 2),
('Ficciones', 1944, 3, 3),
('Don Quijote de la Mancha', 1605, 4, 4);

-- USUARIOS

INSERT INTO usuarios (nombre_usuario, email, fecha_registro) VALUES
('Ana Pérez', 'ana.perez@email.com', '2024-01-10'),
('Luis Gómez', 'luis.gomez@email.com', '2024-02-05'),
('María López', 'maria.lopez@email.com', '2024-03-12');

-- PRÉSTAMOS

INSERT INTO prestamos (id_usuario, id_libro, fecha_prestamo, fecha_devolucion, devuelto) VALUES
(1, 1, '2024-04-01', '2024-04-15', TRUE),
(2, 3, '2024-04-05', NULL, FALSE),
(3, 4, '2024-04-10', '2024-04-25', TRUE);

-- VALORACIONES

INSERT INTO valoraciones (id_usuario, id_libro, puntuacion, comentario, fecha_valoracion) VALUES
(1, 1, 5, 'Una obra maestra', '2024-04-20'),
(3, 4, 4, 'Muy interesante y profundo', '2024-04-26'),
(2, 3, 5, 'Excelente narrativa', '2024-04-18');

-- MULTAS

INSERT INTO multas (id_prestamo, importe, pagada) VALUES
(2, 5.50, FALSE);

-- PRODUCTOS

INSERT INTO productos (nombre_producto, precio) VALUES
('Marcapáginas', 2.50),
('Cuaderno', 4.90),
('Bolígrafo', 1.20);

-- Productos con precio mayor a 50
SELECT * FROM productos WHERE precio > 50;

-- Libros con su autor
SELECT l.titulo, a.nombre_autor FROM libros l INNER JOIN autores a ON l.id_autor = a.id_autor;

-- Préstamos con usuario
SELECT p.id_prestamo, u.nombre_usuario, p.fecha_prestamo FROM prestamos p INNER JOIN usuarios u ON p.id_usuario = u.id_usuario;

-- Libros con editorial
SELECT l.titulo, e.nombre_editorial, l.anio_publicacion FROM libros l INNER JOIN editoriales e ON l.id_editorial = e.id_editorial;

-- Préstamos con usuario y libro
SELECT u.nombre_usuario, l.titulo, p.fecha_prestamo FROM prestamos p INNER JOIN usuarios u ON p.id_usuario = u.id_usuario INNER JOIN libros l ON p.id_libro = l.id_libro;

-- Préstamos completos (usuario, libro, autor, editorial)
SELECT u.nombre_usuario, l.titulo, a.nombre_autor, e.nombre_editorial, p.fecha_prestamo FROM prestamos p INNER JOIN usuarios u ON p.id_usuario = u.id_usuario INNER JOIN libros l ON p.id_libro = l.id_libro INNER JOIN autores a ON l.id_autor = a.id_autor INNER JOIN editoriales e ON l.id_editorial = e.id_editorial;

-- Valoraciones con usuario y libro
SELECT u.nombre_usuario, l.titulo, v.puntuacion, v.comentario FROM valoraciones v INNER JOIN usuarios u ON v.id_usuario = u.id_usuario INNER JOIN libros l ON v.id_libro = l.id_libro;

-- Préstamos no devueltos
SELECT u.nombre_usuario, l.titulo, p.fecha_prestamo FROM prestamos p INNER JOIN usuarios u ON p.id_usuario = u.id_usuario INNER JOIN libros l ON p.id_libro = l.id_libro WHERE p.devuelto = FALSE;

-- Combinaciones de usuarios y libros
SELECT u.nombre_usuario, l.titulo FROM usuarios u CROSS JOIN libros l;

-- Libros del mismo autor
SELECT l1.titulo AS libro1, l2.titulo AS libro2, a.nombre_autor FROM libros l1 INNER JOIN libros l2 ON l1.id_autor = l2.id_autor AND l1.id_libro < l2.id_libro INNER JOIN autores a ON l1.id_autor = a.id_autor;

-- Usuarios que leyeron el mismo libro
SELECT DISTINCT u1.nombre_usuario AS usuario1, u2.nombre_usuario AS usuario2, l.titulo FROM prestamos p1 INNER JOIN prestamos p2 ON p1.id_libro = p2.id_libro AND p1.id_usuario < p2.id_usuario INNER JOIN usuarios u1 ON p1.id_usuario = u1.id_usuario INNER JOIN usuarios u2 ON p2.id_usuario = u2.id_usuario INNER JOIN libros l ON p1.id_libro = l.id_libro;

-- Número de préstamos por usuario
SELECT u.nombre_usuario, COUNT(p.id_prestamo) AS total_prestamos FROM usuarios u LEFT JOIN prestamos p ON u.id_usuario = p.id_usuario GROUP BY u.id_usuario;

-- Libros más prestados
SELECT l.titulo, COUNT(p.id_prestamo) AS veces_prestado FROM libros l LEFT JOIN prestamos p ON l.id_libro = p.id_libro GROUP BY l.id_libro HAVING COUNT(p.id_prestamo) > 0;

-- Autores con mejor puntuación media
SELECT a.nombre_autor, AVG(v.puntuacion) AS media FROM autores a INNER JOIN libros l ON a.id_autor = l.id_autor INNER JOIN valoraciones v ON l.id_libro = v.id_libro GROUP BY a.id_autor HAVING COUNT(v.id_valoracion) >= 3;

-- Ejercicio 1: Listar todos los préstamos mostrando nombre del usuario y título del libro
SELECT u.nombre_usuario, l.titulo, p.fecha_prestamo FROM prestamos p INNER JOIN usuarios u ON p.id_usuario = u.id_usuario INNER JOIN libros l ON p.id_libro = l.id_libro;

-- Ejercicio 2: Mostrar todos los libros con el nombre de su autor
SELECT l.titulo, a.nombre_autor FROM libros l INNER JOIN autores a ON l.id_autor = a.id_autor;

-- Ejercicio 3: Listar las valoraciones mostrando quién valoró qué libro
SELECT u.nombre_usuario, l.titulo, v.puntuacion FROM valoraciones v INNER JOIN usuarios u ON v.id_usuario = u.id_usuario INNER JOIN libros l ON v.id_libro = l.id_libro;

-- Ejercicio 4: Mostrar préstamos con multa pendiente, indicando usuario, libro e importe
SELECT u.nombre_usuario, l.titulo, m.importe FROM prestamos p INNER JOIN usuarios u ON p.id_usuario = u.id_usuario INNER JOIN libros l ON p.id_libro = l.id_libro INNER JOIN multas m ON p.id_prestamo = m.id_prestamo WHERE m.pagada = FALSE;

-- Ejercicio 5: Listar libros con su autor y editorial
SELECT l.titulo, a.nombre_autor, e.nombre_editorial FROM libros l INNER JOIN autores a ON l.id_autor = a.id_autor INNER JOIN editoriales e ON l.id_editorial = e.id_editorial;

-- Ejercicio 6: Mostrar préstamos activos (no devueltos) con nombre de usuario
SELECT u.nombre_usuario, p.fecha_prestamo FROM prestamos p INNER JOIN usuarios u ON p.id_usuario = u.id_usuario WHERE p.devuelto = FALSE;

-- Ejercicio 7: Listar autores españoles con sus libros
SELECT a.nombre_autor, l.titulo FROM autores a INNER JOIN libros l ON a.id_autor = l.id_autor WHERE a.nacionalidad = 'Español';

-- Ejercicio 8: Mostrar valoraciones de 5 estrellas con título del libro y nombre del usuario
SELECT l.titulo, u.nombre_usuario FROM valoraciones v INNER JOIN libros l ON v.id_libro = l.id_libro INNER JOIN usuarios u ON v.id_usuario = u.id_usuario WHERE v.puntuacion = 5;

-- Ejercicio 9: Listar libros publicados después de 2000 con su autor
SELECT l.titulo, a.nombre_autor FROM libros l INNER JOIN autores a ON l.id_autor = a.id_autor WHERE l.anio_publicacion > 2000;

-- Ejercicio 10: Mostrar préstamos de noviembre de 2024 con usuario y libro
SELECT u.nombre_usuario, l.titulo FROM prestamos p INNER JOIN usuarios u ON p.id_usuario = u.id_usuario INNER JOIN libros l ON p.id_libro = l.id_libro WHERE p.fecha_prestamo BETWEEN '2024-11-01' AND '2024-11-30';

-- Ejercicio 11: Listar todos los usuarios con el número de préstamos (incluso si es 0)
SELECT u.nombre_usuario, COUNT(p.id_prestamo) FROM usuarios u LEFT JOIN prestamos p ON u.id_usuario = p.id_usuario GROUP BY u.id_usuario;

-- Ejercicio 12: Encontrar usuarios que nunca han hecho un préstamo
SELECT u.nombre_usuario FROM usuarios u LEFT JOIN prestamos p ON u.id_usuario = p.id_usuario WHERE p.id_prestamo IS NULL;

-- Ejercicio 13: Mostrar todos los libros con el número de veces que han sido prestados
SELECT l.titulo, COUNT(p.id_prestamo) FROM libros l LEFT JOIN prestamos p ON l.id_libro = p.id_libro GROUP BY l.id_libro;

-- Ejercicio 14: Encontrar libros que nunca han sido prestados
SELECT l.titulo FROM libros l LEFT JOIN prestamos p ON l.id_libro = p.id_libro WHERE p.id_prestamo IS NULL;

-- Ejercicio 15: Listar todos los autores con el número de libros publicados
SELECT a.nombre_autor, COUNT(l.id_libro) FROM autores a LEFT JOIN libros l ON a.id_autor = l.id_autor GROUP BY a.id_autor;

-- Ejercicio 16: Mostrar todos los usuarios con su deuda total en multas (0 si no tienen)
SELECT u.nombre_usuario, COALESCE(SUM(m.importe),0) FROM usuarios u LEFT JOIN prestamos p ON u.id_usuario = p.id_usuario LEFT JOIN multas m ON p.id_prestamo = m.id_prestamo AND m.pagada = FALSE GROUP BY u.id_usuario;

-- Ejercicio 17: Encontrar autores que no tienen libros publicados
SELECT a.nombre_autor FROM autores a LEFT JOIN libros l ON a.id_autor = l.id_autor WHERE l.id_libro IS NULL;

-- Ejercicio 18: Listar todos los libros con su puntuación promedio (NULL si no tienen)
SELECT l.titulo, AVG(v.puntuacion) FROM libros l LEFT JOIN valoraciones v ON l.id_libro = v.id_libro GROUP BY l.id_libro;

-- Ejercicio 19: Mostrar usuarios con préstamos activos y días prestados
SELECT u.nombre_usuario, DATEDIFF(CURDATE(), p.fecha_prestamo) FROM usuarios u INNER JOIN prestamos p ON u.id_usuario = p.id_usuario WHERE p.devuelto = FALSE;

-- Ejercicio 20: Listar libros con número de valoraciones y préstamos
SELECT l.titulo, COUNT(DISTINCT v.id_valoracion), COUNT(DISTINCT p.id_prestamo) FROM libros l LEFT JOIN valoraciones v ON l.id_libro = v.id_libro LEFT JOIN prestamos p ON l.id_libro = p.id_libro GROUP BY l.id_libro;

-- Ejercicio 21: Top 5 usuarios con más préstamos (activos y devueltos)
SELECT u.nombre_usuario, COUNT(*) AS total, SUM(p.devuelto = FALSE) AS activos, SUM(p.devuelto = TRUE) AS devueltos FROM usuarios u INNER JOIN prestamos p ON u.id_usuario = p.id_usuario GROUP BY u.id_usuario ORDER BY total DESC LIMIT 5;

-- Ejercicio 22: Autores con mejor puntuación promedio (mínimo 3 valoraciones)
SELECT a.nombre_autor, AVG(v.puntuacion) FROM autores a INNER JOIN libros l ON a.id_autor = l.id_autor INNER JOIN valoraciones v ON l.id_libro = v.id_libro GROUP BY a.id_autor HAVING COUNT(v.id_valoracion) >= 3;

-- Ejercicio 23: Libros más populares del último mes
SELECT l.titulo, COUNT(p.id_prestamo) FROM prestamos p INNER JOIN libros l ON p.id_libro = l.id_libro WHERE p.fecha_prestamo >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH) GROUP BY l.id_libro;

-- Ejercicio 24: Usuarios morosos con deuda superior a 10€
SELECT u.nombre_usuario, SUM(m.importe) FROM usuarios u INNER JOIN prestamos p ON u.id_usuario = p.id_usuario INNER JOIN multas m ON p.id_prestamo = m.id_prestamo WHERE m.pagada = FALSE GROUP BY u.id_usuario HAVING SUM(m.importe) > 10;

-- Ejercicio 25: Libros con valoraciones contradictorias
SELECT l.titulo FROM libros l INNER JOIN valoraciones v ON l.id_libro = v.id_libro GROUP BY l.id_libro HAVING SUM(v.puntuacion = 5) > 0 AND SUM(v.puntuacion <= 2) > 0;

-- Ejercicio 26: Parejas de usuarios que prestaron los mismos libros
SELECT DISTINCT u1.nombre_usuario, u2.nombre_usuario FROM prestamos p1 INNER JOIN prestamos p2 ON p1.id_libro = p2.id_libro AND p1.id_usuario < p2.id_usuario INNER JOIN usuarios u1 ON p1.id_usuario = u1.id_usuario INNER JOIN usuarios u2 ON p2.id_usuario = u2.id_usuario;

-- Ejercicio 27: Informe mensual de préstamos
SELECT DATE_FORMAT(fecha_prestamo,'%Y-%m') AS mes, COUNT(*) FROM prestamos GROUP BY mes;

-- Ejercicio 28: Libros nunca prestados de autores con 3 o más libros
SELECT l.titulo FROM libros l INNER JOIN (SELECT id_autor FROM libros GROUP BY id_autor HAVING COUNT(*) >= 3) a ON l.id_autor = a.id_autor LEFT JOIN prestamos p ON l.id_libro = p.id_libro WHERE p.id_prestamo IS NULL;

-- Ejercicio 29: Dashboard completo por usuario
SELECT u.nombre_usuario, COUNT(DISTINCT p.id_prestamo), COUNT(DISTINCT v.id_valoracion), COALESCE(SUM(m.importe),0) FROM usuarios u LEFT JOIN prestamos p ON u.id_usuario = p.id_usuario LEFT JOIN valoraciones v ON u.id_usuario = v.id_usuario LEFT JOIN multas m ON p.id_prestamo = m.id_prestamo GROUP BY u.id_usuario;

-- Ejercicio 30: Afinidad de usuarios por valoraciones comunes
SELECT v1.id_usuario, v2.id_usuario, COUNT(*) FROM valoraciones v1 INNER JOIN valoraciones v2 ON v1.id_libro = v2.id_libro AND v1.id_usuario < v2.id_usuario GROUP BY v1.id_usuario, v2.id_usuario HAVING COUNT(*) >= 3;

-- Ejercicio 31: Ranking de eficiencia valoración/préstamos
SELECT l.titulo, AVG(v.puntuacion) / COUNT(p.id_prestamo) FROM libros l LEFT JOIN valoraciones v ON l.id_libro = v.id_libro LEFT JOIN prestamos p ON l.id_libro = p.id_libro GROUP BY l.id_libro;

-- Ejercicio 32: Detectar préstamos sospechosos
SELECT DISTINCT p1.id_libro FROM prestamos p1 INNER JOIN prestamos p2 ON p1.id_libro = p2.id_libro AND p1.id_usuario <> p2.id_usuario AND p1.fecha_prestamo <= p2.fecha_devolucion AND p2.fecha_prestamo <= p1.fecha_devolucion;

-- Ejercicio 33: Reporte ejecutivo general
SELECT COUNT(*) AS prestamos, (SELECT COUNT(*) FROM usuarios) AS usuarios, (SELECT COUNT(*) FROM libros) AS libros FROM prestamos;

-- DROP DATABASE Joins