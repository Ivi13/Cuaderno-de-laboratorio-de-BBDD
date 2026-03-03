create database if not exists Joins character set utf8mb4 collate utf8mb4_unicode_ci;

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
CONSTRAINT FK_tabla_autor FOREIGN KEY(id_autor) REFERENCES autores(id_autor),
CONSTRAINT FK_tabla_editorial FOREIGN KEY(id_editorial) REFERENCES editoriales(id_editorial)
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
CONSTRAINT FK_tabla_usuario FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario),
CONSTRAINT FK_tabla_libro FOREIGN KEY(id_libro) REFERENCES libros(id_libro)
);

-- Tabla de valoraciones
CREATE TABLE valoraciones (
id_valoracion INT AUTO_INCREMENT PRIMARY KEY,
id_usuario INT,
id_libro INT,
puntuacion INT,
comentario TEXT,
fecha_valoracion DATE,
CONSTRAINT FK_tabla_usuario FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario),
CONSTRAINT FK_tabla_libro FOREIGN KEY(id_libro) REFERENCES libros(id_libro)
);

-- Tabla de multas
CREATE TABLE multas (
id_multa INT AUTO_INCREMENT PRIMARY KEY,
id_prestamo INT,
importe DECIMAL(6,2),
pagada BOOLEAN,
CONSTRAINT FK_tabla_prestamo FOREIGN KEY(id_prestamo) REFERENCES prestamos(id_prestamo)
);

-- Préstamos con usuario y libro
SELECT u.nombre_usuario,l.titulo,p.fecha_prestamo FROM prestamos p INNER JOIN usuarios u ON p.id_usuario=u.id_usuario INNER JOIN libros l ON p.id_libro=l.id_libro;

-- Libros con su autor
SELECT l.titulo,a.nombre_autor FROM libros l INNER JOIN autores a ON l.id_autor=a.id_autor;

-- Valoraciones indicando usuario y libro
SELECT u.nombre_usuario,l.titulo,v.puntuacion FROM valoraciones v INNER JOIN usuarios u ON v.id_usuario=u.id_usuario INNER JOIN libros l ON v.id_libro=l.id_libro;

-- Préstamos con multa
SELECT u.nombre_usuario,l.titulo,m.importe FROM prestamos p INNER JOIN usuarios u ON p.id_usuario=u.id_usuario INNER JOIN libros l ON p.id_libro=l.id_libro INNER JOIN multas m ON p.id_prestamo=m.id_prestamo WHERE m.pagada=FALSE;

-- Libros con autor y editorial
SELECT l.titulo,a.nombre_autor,e.nombre_editorial FROM libros l INNER JOIN autores a ON l.id_autor=a.id_autor INNER JOIN editoriales e ON l.id_editorial=e.id_editorial;

-- Préstamos activos
SELECT u.nombre_usuario,p.fecha_prestamo FROM prestamos p INNER JOIN usuarios u ON p.id_usuario=u.id_usuario WHERE p.devuelto=FALSE;

-- Autores españoles con libros
SELECT a.nombre_autor,l.titulo FROM autores a INNER JOIN libros l ON a.id_autor=l.id_autor WHERE a.nacionalidad='Español';

-- Valoraciones de 5 estrellas
SELECT l.titulo,u.nombre_usuario FROM valoraciones v INNER JOIN libros l ON v.id_libro=l.id_libro INNER JOIN usuarios u ON v.id_usuario=u.id_usuario WHERE v.puntuacion=5;

-- Libros posteriores al año 2000
SELECT l.titulo,a.nombre_autor FROM libros l INNER JOIN autores a ON l.id_autor=a.id_autor WHERE l.anio_publicacion>2000;

-- Préstamos de noviembre 2024
SELECT u.nombre_usuario,l.titulo FROM prestamos p INNER JOIN usuarios u ON p.id_usuario=u.id_usuario INNER JOIN libros l ON p.id_libro=l.id_libro WHERE p.fecha_prestamo BETWEEN '2024-11-01' AND '2024-11-30';

-- Usuarios con número de préstamos (incluidos 0)
SELECT u.nombre_usuario,COUNT(p.id_prestamo) FROM usuarios u LEFT JOIN prestamos p ON u.id_usuario=p.id_usuario GROUP BY u.id_usuario;

-- Usuarios sin préstamos
SELECT u.nombre_usuario FROM usuarios u LEFT JOIN prestamos p ON u.id_usuario=p.id_usuario WHERE p.id_prestamo IS NULL;

-- Libros con número de préstamos
SELECT l.titulo,COUNT(p.id_prestamo) FROM libros l LEFT JOIN prestamos p ON l.id_libro=p.id_libro GROUP BY l.id_libro;

-- Libros nunca prestados
SELECT l.titulo FROM libros l LEFT JOIN prestamos p ON l.id_libro=p.id_libro WHERE p.id_prestamo IS NULL;

-- Autores con número de libros
SELECT a.nombre_autor,COUNT(l.id_libro) FROM autores a LEFT JOIN libros l ON a.id_autor=l.id_autor GROUP BY a.id_autor;

-- Usuarios con deuda total
SELECT u.nombre_usuario,COALESCE(SUM(m.importe),0) FROM usuarios u LEFT JOIN prestamos p ON u.id_usuario=p.id_usuario LEFT JOIN multas m ON p.id_prestamo=m.id_prestamo AND m.pagada=FALSE GROUP BY u.id_usuario;

-- Autores sin libros
SELECT a.nombre_autor FROM autores a LEFT JOIN libros l ON a.id_autor=l.id_autor WHERE l.id_libro IS NULL;

-- Libros con puntuación media
SELECT l.titulo,AVG(v.puntuacion) FROM libros l LEFT JOIN valoraciones v ON l.id_libro=v.id_libro GROUP BY l.id_libro;

-- Usuarios con préstamos activos y días prestados
SELECT u.nombre_usuario,DATEDIFF(CURDATE(),p.fecha_prestamo) FROM usuarios u LEFT JOIN prestamos p ON u.id_usuario=p.id_usuario AND p.devuelto=FALSE WHERE p.id_prestamo IS NOT NULL;

-- Libros con nº valoraciones y préstamos
SELECT l.titulo,COUNT(DISTINCT v.id_valoracion),COUNT(DISTINCT p.id_prestamo) FROM libros l LEFT JOIN valoraciones v ON l.id_libro=v.id_libro LEFT JOIN prestamos p ON l.id_libro=p.id_libro GROUP BY l.id_libro;

-- Top 5 usuarios con más préstamos
SELECT u.nombre_usuario,COUNT(*) total,SUM(p.devuelto=FALSE) activos,SUM(p.devuelto=TRUE) devueltos FROM usuarios u INNER JOIN prestamos p ON u.id_usuario=p.id_usuario GROUP BY u.id_usuario ORDER BY total DESC LIMIT 5;

-- Autores mejor valorados (mín. 3 valoraciones)
SELECT a.nombre_autor,AVG(v.puntuacion) FROM autores a INNER JOIN libros l ON a.id_autor=l.id_autor INNER JOIN valoraciones v ON l.id_libro=v.id_libro GROUP BY a.id_autor HAVING COUNT(v.id_valoracion)>=3;

-- Libros más populares del último mes
SELECT l.titulo,COUNT(p.id_prestamo) FROM prestamos p INNER JOIN libros l ON p.id_libro=l.id_libro WHERE p.fecha_prestamo>=DATE_SUB(CURDATE(),INTERVAL 1 MONTH) GROUP BY l.id_libro;

-- Usuarios morosos (>10€)
SELECT u.nombre_usuario,SUM(m.importe) FROM usuarios u INNER JOIN prestamos p ON u.id_usuario=p.id_usuario INNER JOIN multas m ON p.id_prestamo=m.id_prestamo WHERE m.pagada=FALSE GROUP BY u.id_usuario HAVING SUM(m.importe)>10;

-- Libros con valoraciones contradictorias
SELECT l.titulo FROM libros l INNER JOIN valoraciones v ON l.id_libro=v.id_libro GROUP BY l.id_libro HAVING SUM(v.puntuacion=5)>0 AND SUM(v.puntuacion<=2)>0;

-- Parejas de usuarios que leyeron los mismos libros
SELECT DISTINCT u1.nombre_usuario,u2.nombre_usuario FROM prestamos p1 INNER JOIN prestamos p2 ON p1.id_libro=p2.id_libro AND p1.id_usuario<p2.id_usuario INNER JOIN usuarios u1 ON p1.id_usuario=u1.id_usuario INNER JOIN usuarios u2 ON p2.id_usuario=u2.id_usuario;

-- Informe mensual (préstamos, valoraciones, multas)
SELECT DATE_FORMAT(fecha_prestamo,'%Y-%m'),COUNT(*) FROM prestamos GROUP BY 1;

-- Libros olvidados de autores populares
SELECT l.titulo FROM libros l INNER JOIN (SELECT id_autor FROM libros GROUP BY id_autor HAVING COUNT(*)>=3) a ON l.id_autor=a.id_autor LEFT JOIN prestamos p ON l.id_libro=p.id_libro WHERE p.id_prestamo IS NULL;

-- Dashboard completo de un usuario
SELECT u.nombre_usuario,COUNT(DISTINCT p.id_prestamo),COUNT(DISTINCT v.id_valoracion),SUM(m.importe) FROM usuarios u LEFT JOIN prestamos p ON u.id_usuario=p.id_usuario LEFT JOIN valoraciones v ON u.id_usuario=v.id_usuario LEFT JOIN multas m ON p.id_prestamo=m.id_prestamo GROUP BY u.id_usuario;

-- Afinidad de usuarios por valoraciones comunes
SELECT v1.id_usuario,v2.id_usuario,COUNT(*) FROM valoraciones v1 INNER JOIN valoraciones v2 ON v1.id_libro=v2.id_libro AND v1.id_usuario<v2.id_usuario GROUP BY v1.id_usuario,v2.id_usuario HAVING COUNT(*)>=3;

-- Ranking eficiencia libro (valoración/préstamos)
SELECT l.titulo,AVG(v.puntuacion)/COUNT(p.id_prestamo) FROM libros l LEFT JOIN valoraciones v ON l.id_libro=v.id_libro LEFT JOIN prestamos p ON l.id_libro=p.id_libro GROUP BY l.id_libro;

-- Préstamos sospechosos (fechas solapadas)
SELECT p1.id_libro FROM prestamos p1 INNER JOIN prestamos p2 ON p1.id_libro=p2.id_libro AND p1.id_usuario<>p2.id_usuario AND p1.fecha_prestamo<=p2.fecha_devolucion AND p2.fecha_prestamo<=p1.fecha_devolucion;

-- Reporte ejecutivo general
SELECT COUNT(*) AS prestamos,(SELECT COUNT(*) FROM usuarios) usuarios,(SELECT COUNT(*) FROM libros) libros FROM prestamos;
