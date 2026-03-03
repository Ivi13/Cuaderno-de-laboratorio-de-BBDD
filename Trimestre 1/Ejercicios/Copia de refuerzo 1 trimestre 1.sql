
create database if not exists TIENDA_ONLINE character set utf8mb4 collate utf8mb4_unicode_ci;

use TIENDA_ONLINE;

create table clientes (
id_cliente INT PRIMARY KEY,
nombre VARCHAR(50) NOT NULL,
ciudad VARCHAR(30) NOT NULL,
pais VARCHAR(30) NOT NULL
) ENGINE=InnoDB;

create table productos (
id_producto INT PRIMARY KEY,
nombre VARCHAR(50) NOT NULL,
precio Decimal(10,2) NOT NULL,
categoria VARCHAR(30) NOT NULL,
stock INT
) engine=InnoDB;

create table pedidos (
id_pedido INT PRIMARY KEY,
id_cliente Int NOT NULL,
fecha DATE NOT NULL,
total DECIMAL(10,2) NOT NULL,
constraint FK_tabla_pedidos FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
) engine=InnoDB;

create table detalle_pedidos (
id_detalle Int Primary key,
id_pedido Int Not null,
id_producto Int not null,
cantidad Int Not null,
precio_unitario Decimal(10,2) Not null,
constraint FK_tabla_pedido FOREIGN KEY (id_pedido) references pedidos(id_pedido),
constraint FK_tabla_producto Foreign key (id_producto) references productos(id_producto)
) engine=InnoDB;

CREATE TABLE empleados_jerarquia (
    id_empleado INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    id_supervisor INT,
    FOREIGN KEY (id_supervisor) REFERENCES empleados_jerarquia(id_empleado)
) ENGINE=InnoDB;

INSERT INTO empleados_jerarquia VALUES
(1, 'Director General', NULL),
(2, 'Gerente Ventas', 1),
(3, 'Gerente TI', 1),
(4, 'Vendedor A', 2),
(5, 'Vendedor B', 2),
(6, 'Programador A', 3),
(7, 'Programador B', 3);

INSERT INTO clientes VALUES 
(1, 'Ana García', 'Madrid', 'España'), 
(2, 'Luis Pérez', 'Barcelona', 'España'), 
(3, 'María López', 'Valencia', 'España'), 
(4, 'John Smith', 'London', 'UK'), 
(5, 'Sophie Martin', 'Paris', 'Francia'); 

INSERT INTO productos VALUES 
(1, 'Portátil HP', 899.99, 'Informática', 15), 
(2, 'Ratón Logitech', 25.50, 'Informática', 50), 
(3, 'Teclado Mecánico', 89.99, 'Informática', 30), 
(4, 'Monitor LG 24', 179.99, 'Informática', 20), 
(5, 'Webcam HD', 45.00, 'Informática', 25); 

INSERT INTO pedidos VALUES 
(1, 1, '2025-01-15', 925.49), 
(2, 2, '2025-01-20', 269.98), 
(3, 1, '2025-02-05', 45.00), 
(4, 3, '2025-02-10', 1079.98), 
(5, 4, '2025-02-15', 115.49);

INSERT INTO detalle_pedidos VALUES 
(1, 1, 1, 1, 899.99), 
(2, 1, 2, 1, 25.50), 
(3, 2, 3, 2, 89.99), 
(4, 2, 2, 2, 25.50), 
(5, 3, 5, 1, 45.00), 
(6, 4, 1, 1, 899.99), 
(7, 4, 4, 1, 179.99), 
(8, 5, 3, 1, 89.99), 
(9, 5, 2, 1, 25.50); 

-- Muestra los productos que cuestan más que el precio medio de todos los productos.
SELECT nombre, precio FROM productos WHERE precio > (SELECT AVG (precio) FROM productos); 

-- Saca el nombre del cliente que hizo el pedido más caro.
SELECT nombre FROM clientes WHERE id_cliente = (SELECT id_cliente FROM pedidos WHERE total = (SELECT MAX(total) FROM pedidos)); 

-- Lista los productos que tienen menos stock que el promedio del stock.
SELECT nombre, stock FROM productos WHERE stock < (SELECT AVG(stock) FROM productos); 

-- Muestra los clientes que viven en la misma ciudad que Ana García.
SELECT nombre, ciudad FROM clientes WHERE ciudad = (SELECT ciudad FROM clientes WHERE nombre = 'Ana García'); 

-- Muestra los clientes que tienen al menos un pedido.
SELECT nombre, ciudad FROM clientes WHERE id_cliente IN (SELECT id_cliente FROM pedidos); 

-- Muestra los productos que se han vendido (aparecen en detalle_pedidos).
SELECT nombre, precio FROM productos WHERE id_producto IN (SELECT DISTINCT id_producto FROM detalle_pedidos); 

-- Muestra los clientes que no han hecho ningún pedido.
SELECT nombre, pais FROM clientes WHERE id_cliente NOT IN (SELECT id_cliente FROM pedidos);

-- Muestra los clientes que sí tienen pedidos usando EXISTS.
SELECT nombre, ciudad FROM clientes C WHERE EXISTS (SELECT 1 FROM pedidos P WHERE P.id_cliente = C.id_cliente); 

-- Muestra los productos que nunca se han vendido.
SELECT nombre, stock FROM productos P WHERE NOT EXISTS (SELECT 1 FROM detalle_pedidos DP WHERE DP.id_producto = P.id_producto);

-- Clientes que compraron algún producto con precio unitario mayor de 100.
SELECT DISTINCT C.nombre, C.ciudad FROM clientes C WHERE EXISTS (SELECT 1 FROM pedidos P INNER JOIN detalle_pedidos DP ON P.id_pedido = DP.id_pedido WHERE P.id_cliente = C.id_cliente AND DP.precio_unitario > 100);

-- Muestra productos que cuestan más que algún producto con poco stock (<20).
SELECT nombre, precio, stock FROM productos WHERE precio > ANY (SELECT precio FROM productos WHERE stock < 20);

-- Clientes cuyo total supera algún pedido de clientes de Madrid.
SELECT C.nombre, P.total FROM clientes C INNER JOIN pedidos P ON C.id_cliente = P.id_cliente WHERE P.total > ANY (SELECT P2.total FROM pedidos P2 INNER JOIN clientes C2 ON P2.id_cliente = C2.id_cliente WHERE C2.ciudad = 'Madrid');

-- Productos que valen más que todos los productos con stock mayor a 30.
SELECT nombre, precio, stock FROM productos WHERE precio > ALL (SELECT precio FROM productos WHERE stock > 30 );

-- Muestra el pedido con el total más alto.
SELECT C.nombre, P.total FROM clientes C INNER JOIN pedidos P ON C.id_cliente = P.id_cliente WHERE P.total >= ALL (SELECT total FROM pedidos); 

-- Muestra cada producto junto a cuántas unidades se han vendido.
SELECT P.nombre, V.total_vendido FROM productos P INNER JOIN (SELECT id_producto, SUM(cantidad) AS total_vendido FROM detalle_pedidos GROUP BY id_producto) AS V ON P.id_producto = V.id_producto;

-- Clientes que han gastado más que el promedio de los pedidos.
SELECT C.nombre, G.gasto_total FROM clientes C INNER JOIN (SELECT id_cliente, SUM(total) AS gasto_total FROM pedidos GROUP BY id_cliente ) AS G ON C.id_cliente = G.id_cliente WHERE G.gasto_total > (SELECT AVG(total) FROM pedidos);

-- Top 3 productos más vendidos por cantidad.
SELECT P.nombre, P.categoria, V.unidades_vendidas FROM productos P INNER JOIN (SELECT id_producto, SUM(cantidad) AS unidades_vendidas FROM detalle_pedidos GROUP BY id_producto ORDER BY unidades_vendidas DESC LIMIT 3) AS V ON P.id_producto = V.id_producto ORDER BY V.unidades_vendidas DESC;

-- Muestra cuánto se ha vendido en España y cuánto en el resto de países.
SELECT 'España' AS origen, VE.total_españa AS total_ventas FROM (SELECT SUM(P.total) AS total_españa FROM pedidos P INNER JOIN clientes C ON P.id_cliente = C.id_cliente WHERE C.pais = 'España') AS VE UNION ALL SELECT 'Otros países' AS origen, VO.total_otros AS total_ventas FROM (SELECT SUM(P.total) AS total_otros FROM pedidos P INNER JOIN clientes C ON P.id_cliente = C.id_cliente WHERE C.pais != 'España') AS VO;

-- Muestra cada producto con el precio promedio de su propia categoría.
SELECT nombre, precio, categoria, (SELECT AVG(precio) FROM productos P2 WHERE P2.categoria = P1.categoria) AS precio_promedio_categoria FROM productos P1;

-- Muestra cada cliente con la cantidad de pedidos que ha hecho.
SELECT C.nombre, C.ciudad, (SELECT COUNT(*) FROM pedidos P WHERE P.id_cliente = C.id_cliente) AS num_pedidos FROM clientes C;

-- Compara el precio de cada producto con la media para decir si es caro o barato.
SELECT nombre, precio, ROUND(precio - (SELECT AVG(precio) FROM productos), 2) AS diferencia_promedio, CASE WHEN precio > (SELECT AVG(precio) FROM productos) THEN 'Caro' ELSE 'Económico' END AS clasificacion FROM productos;

-- Calcula qué porcentaje representa cada pedido respecto al total vendido.
SELECT P.id_pedido, P.total, ROUND((P.total * 100.0) / (SELECT SUM(total) FROM pedidos), 2) AS porcentaje_ventas FROM pedidos P ORDER BY porcentaje_ventas DESC;

-- Muestra productos cuyo precio es mayor que el promedio de su categoría.
SELECT P1.nombre, P1.precio, P1.categoria FROM productos P1 WHERE P1.precio > (SELECT AVG(P2.precio) FROM productos P2 WHERE P2.categoria = P1.categoria);

-- Pedidos cuyo total está por encima del promedio de lo que compra ese mismo cliente.
SELECT C.nombre, P1.id_pedido, P1.fecha, P1.total FROM clientes C INNER JOIN pedidos P1 ON C.id_cliente = P1.id_cliente WHERE P1.total > (SELECT AVG(P2.total) FROM pedidos P2 WHERE P2.id_cliente = P1.id_cliente);

-- Productos cuyo stock es menor que el stock promedio de su categoría.
SELECT P1.nombre, P1.stock, P1.categoria, (SELECT AVG(P2.stock) FROM productos P2 WHERE P2.categoria = P1.categoria) AS stock_promedio_categoria FROM productos P1 WHERE P1.stock < (SELECT AVG(P2.stock) FROM productos P2 WHERE P2.categoria = P1.categoria);

-- Muestra el pedido más reciente que ha hecho cada cliente.
SELECT C.nombre, P1.id_pedido, P1.fecha, P1.total FROM clientes C INNER JOIN pedidos P1 ON C.id_cliente = P1.id_cliente WHERE P1.fecha = (SELECT MAX(P2.fecha) FROM pedidos P2 WHERE P2.id_cliente = P1.id_cliente);

-- Muestra los productos más caros dentro de su categoría.
SELECT P1.nombre, P1.precio, P1.categoria FROM productos P1 WHERE P1.precio = (SELECT MAX(P2.precio) FROM productos P2 WHERE P2.categoria = P1.categoria);

-- Clientes que han comprado absolutamente todos los productos.
SELECT C.nombre FROM clientes C WHERE NOT EXISTS (SELECT 1 FROM productos P WHERE NOT EXISTS (SELECT 1 FROM pedidos PED INNER JOIN detalle_pedidos DP ON PED.id_pedido = DP.id_pedido WHERE PED.id_cliente = C.id_cliente AND DP.id_producto = P.id_producto));

-- Productos que solo han sido comprados por un único cliente distinto.
SELECT P.nombre, P.precio FROM productos P WHERE (SELECT COUNT(DISTINCT PED.id_cliente) FROM pedidos PED INNER JOIN detalle_pedidos DP ON PED.id_pedido = DP.id_pedido WHERE DP.id_producto = P.id_producto) = 1;

-- Muestra productos que valen más de 100.
SELECT nombre, precio FROM productos WHERE precio > 100;

-- Cliente que hizo el pedido más barato.
SELECT C.nombre FROM clientes C INNER JOIN pedidos P ON C.id_cliente = P.id_cliente WHERE P.total = (SELECT MIN(total) FROM pedidos);

-- Productos con precio menor que la media.
SELECT nombre, precio FROM productos WHERE precio < (SELECT AVG(precio)FROM productos);

-- Clientes sin pedidos.
SELECT nombre, pais FROM clientes WHERE id_cliente NOT IN (SELECT id_cliente FROM pedidos); 

-- Productos que no se han vendido nunca.
SELECT nombre, stock FROM productos P WHERE NOT EXISTS (SELECT 1 FROM detalle_pedidos DP WHERE DP.id_producto = P.id_producto);

-- Clientes que tienen pedidos con total mayor al promedio de todos los pedidos.
SELECT DISTINCT C.nombre, C.ciudad FROM clientes C INNER JOIN pedidos P ON C.id_cliente = P.id_cliente WHERE P.total > (SELECT AVG(total) FROM pedidos); 

-- Productos más caros que todos los productos con stock mayor a 30 (igual que antes).
SELECT nombre, precio, stock FROM productos WHERE precio > ALL (SELECT precio FROM productos WHERE stock > 30); 

-- Productos cuyo stock está por debajo del promedio de su categoría, mostrando el promedio redondeado.
SELECT P1.nombre, P1.stock, P1.categoria, (SELECT ROUND(AVG(P2.stock), 2) FROM productos P2 WHERE P2.categoria = P1.categoria) AS promedio_categoria FROM productos P1 WHERE P1.stock < (SELECT AVG(P2.stock) FROM productos P2 WHERE P2.categoria = P1.categoria);

-- Clientes que tienen más pedidos que la media de pedidos por cliente.
SELECT C.nombre, (SELECT COUNT(*) FROM pedidos P WHERE P.id_cliente = C.id_cliente) AS num_pedidos FROM clientes C WHERE (SELECT COUNT(*) FROM pedidos P WHERE P.id_cliente = C.id_cliente) > (SELECT AVG(pedidos_por_cliente) FROM (SELECT COUNT(*) AS pedidos_por_cliente FROM pedidos GROUP BY id_cliente) AS subquery); 

-- El segundo pedido más antiguo de cada cliente.
SELECT C.nombre, P1.fecha, P1.total FROM clientes C INNER JOIN pedidos P1 ON C.id_cliente = P1.id_cliente WHERE (SELECT COUNT(*) FROM pedidos P2 WHERE P2.id_cliente = P1.id_cliente AND P2.fecha < P1.fecha) = 1;

-- Clientes que han comprado el producto más caro.
SELECT DISTINCT C.nombre, C.ciudad FROM clientes C INNER JOIN pedidos P ON C.id_cliente = P.id_cliente INNER JOIN detalle_pedidos DP ON P.id_pedido = DP.id_pedido WHERE DP.id_producto = (SELECT id_producto FROM productos WHERE precio = (SELECT MAX(precio) FROM productos));

-- Ranking de productos por unidades vendidas.
SELECT P.nombre, (SELECT SUM(cantidad) FROM detalle_pedidos DP WHERE DP.id_producto = P.id_producto) AS unidades_vendidas,  (SELECT COUNT(*) + 1 FROM productos P2 WHERE (SELECT SUM(cantidad) FROM detalle_pedidos DP2 WHERE DP2.id_producto = P2.id_producto) > (SELECT SUM(cantidad) FROM detalle_pedidos DP3 WHERE DP3.id_producto = P.id_producto)) AS ranking FROM productos P WHERE EXISTS (SELECT 1 FROM detalle_pedidos DP WHERE DP.id_producto = P.id_producto) ORDER BY unidades_vendidas DESC;

-- Productos comprados solo por clientes de España.
SELECT P.nombre FROM productos P WHERE EXISTS (SELECT 1 FROM detalle_pedidos DP INNER JOIN pedidos PED ON DP.id_pedido = PED.id_pedido INNER JOIN clientes C ON PED.id_cliente = C.id_cliente WHERE DP.id_producto = P.id_producto) AND NOT EXISTS (SELECT 1 FROM detalle_pedidos DP INNER JOIN pedidos PED ON DP.id_pedido = PED.id_pedido INNER JOIN clientes C ON PED.id_cliente = C.id_cliente WHERE DP.id_producto = P.id_producto AND C.pais != 'España');

-- Clientes que están dentro del top 2 de mayores gastos.
SELECT C.nombre, (SELECT SUM(total) FROM pedidos P WHERE P.id_cliente = C.id_cliente) AS gasto_total FROM clientes C WHERE (SELECT SUM(total) FROM pedidos P WHERE P.id_cliente = C.id_cliente) >= (SELECT DISTINCT total_cliente FROM (SELECT id_cliente, SUM(total) AS total_cliente FROM pedidos GROUP BY id_cliente ORDER BY total_cliente DESC LIMIT 2) AS top_clientes ORDER BY total_cliente ASC LIMIT 1) ORDER BY gasto_total DESC;

-- Clientes que gastaron más que el promedio de todos los pedidos.
SELECT C.nombre, G.gasto_total FROM clientes C INNER JOIN (SELECT id_cliente, SUM(total) AS gasto_total FROM pedidos GROUP BY id_cliente) AS G ON C.id_cliente = G.id_cliente WHERE G.gasto_total > (SELECT AVG(total) FROM pedidos); 

-- CTE que calcula cuántas unidades e ingresos genera cada producto.
-- Luego agrupa por categoría para ver el total vendido por categoría.
-- Finalmente calcula el porcentaje que representa cada categoría respecto al total general.
-- Suma total de unidades e ingresos de todas las categorías.
-- Muestra categoría, sus ventas y el porcentaje que aporta.
WITH VentasPorProducto AS (SELECT id_producto, SUM(cantidad) AS unidades_vendidas, SUM(cantidad * precio_unitario) AS ingresos FROM detalle_pedidos GROUP BY id_producto), VentasPorCategoria AS (SELECT P.categoria, SUM(V.unidades_vendidas) AS total_unidades, SUM(V.ingresos) AS total_ingresos, COUNT(*) AS productos_vendidos FROM productos P INNER JOIN VentasPorProducto V ON P.id_producto = V.id_producto  GROUP BY P.categoria), TotalesGenerales AS (SELECT SUM(total_unidades) AS unidades_totales, SUM(total_ingresos) AS ingresos_totales FROM VentasPorCategoria) SELECT VC.categoria, VC.total_unidades, VC.total_ingresos, ROUND((VC.total_ingresos * 100.0) / TG.ingresos_totales, 2) AS porcentaje_ingresos FROM VentasPorCategoria VC CROSS JOIN TotalesGenerales TG ORDER BY VC.total_ingresos DESC;

-- CTE recursiva que genera los números del 1 al 10.
WITH RECURSIVE numeros AS (SELECT 1 AS n UNION ALL SELECT n + 1 From numeros WHERE n < 10) SELECT n FROM numeros;

-- CTE recursiva para mostrar la jerarquía de empleados.
-- Va formando la ruta de cada empleado desde el jefe principal.
-- Primer nivel: el jefe que no tiene supervisor.
-- Siguientes niveles: los empleados que dependen del anterior.
-- Muestra el organigrama con indentación.
WITH RECURSIVE jerarquia AS (SELECT id_empleado, nombre, id_supervisor, 0 AS nivel, CAST (nombre AS CHAR(200)) AS ruta FROM empleados_jerarquia WHERE id_supervisor IS NULL UNION ALL SELECT E.id_empleado, E.nombre, E.id_supervisor, J.nivel + 1, CONCAT (J.ruta, ' > ', E.nombre) FROM empleados_jerarquia E INNER JOIN jerarquia J ON E.id_supervisor = J.id_empleado) SELECT CONCAT (REPEAT (' ', nivel), nombre) AS organigrama, nivel, ruta FROM jerarquia ORDER BY ruta;

-- Explica el plan de ejecución para la consulta que busca clientes con pedidos.
EXPLAIN SELECT C.nombre FROM clientes C WHERE EXISTS (SELECT 1 FROM pedidos P WHERE P.id_cliente = C.id_cliente);

-- Crea un índice para acelerar las búsquedas por id_cliente en pedidos.
CREATE INDEX idx_pedidos_cliente ON pedidos(id_cliente);

-- Índice para mejorar las búsquedas y ordenamientos por fecha en pedidos.
CREATE INDEX idx_pedidos_fecha ON pedidos(fecha);

-- Índice para acelerar consultas sobre detalle_pedidos filtrando por id_pedido.
CREATE INDEX idx_detalle_pedido ON detalle_pedidos(id_pedido);

-- Índice para mejorar filtrado por id_producto en detalle_pedidos.
CREATE INDEX idx_detalle_producto ON detalle_pedidos(id_producto);

-- Índice para mejorar consultas por categoría en productos.
CREATE INDEX idx_productos_categoria ON productos(categoria);

-- Vuelve a mostrar el plan de ejecución ahora con índices creados.
EXPLAIN SELECT C.nombre FROM clientes C WHERE EXISTS (SELECT 1 FROM pedidos P WHERE P.id_cliente = C.id_cliente); 

-- CTE que calcula la primera compra (cohorte) de cada cliente.
-- Luego calcula compras posteriores y los meses desde la primera compra.
-- Sirve para un análisis de cohortes (retención).
-- Muestra cuántos clientes permanecen activos mes a mes y sus ingresos.
WITH PrimeraCompra AS (SELECT id_cliente, MIN(fecha) AS fecha_primera_compra, DATE_FORMAT(MIN(fecha), '%Y-%m') AS cohorte FROM pedidos GROUP BY id_cliente), ComprasPosterior AS (SELECT P.id_cliente, PC.cohorte, P.fecha, P.total, TIMESTAMPDIFF(MONTH, PC.fecha_primera_compra, P.fecha) AS meses_desde_primera  FROM pedidos P INNER JOIN PrimeraCompra PC ON P.id_cliente = PC.id_cliente) SELECT cohorte, meses_desde_primera, COUNT(DISTINCT id_cliente) AS clientes_activos, SUM(total) AS ingresos, ROUND(AVG(total), 2) AS ticket_promedio FROM ComprasPosterior GROUP BY cohorte, meses_desde_primera ORDER BY cohorte, meses_desde_primera;

-- Calcula hace cuántos días compró por última vez cada cliente.
-- Calcula también la frecuencia promedio entre compras.
-- Finalmente muestra cuáles clientes están en riesgo porque llevan mucho sin comprar.
-- Muestra clientes con riesgo de abandono.
WITH UltimaCompraCliente AS (SELECT id_cliente, MAX(fecha) AS fecha_ultima_compra, DATEDIFF(CURDATE(), MAX(fecha)) AS dias_sin_comprar FROM pedidos GROUP BY id_cliente), PromedioFrecuencia AS (SELECT id_cliente, AVG(dias_entre_compras) AS dias_promedio FROM (SELECT id_cliente, DATEDIFF(fecha, LAG(fecha) OVER (PARTITION BY id_cliente ORDER BY fecha)) AS dias_entre_compras FROM pedidos) AS Intervalos WHERE dias_entre_compras IS NOT NULL GROUP BY id_cliente) SELECT C.nombre, C.ciudad, UC.fecha_ultima_compra, UC.dias_sin_comprar, ROUND(PF.dias_promedio, 0) AS frecuencia_habitual, ROUND(UC.dias_sin_comprar / PF.dias_promedio, 2) AS ratio_riesgo FROM clientes C INNER JOIN UltimaCompraCliente UC ON C.id_cliente = UC.id_cliente LEFT JOIN PromedioFrecuencia PF ON C.id_cliente = PF.id_cliente WHERE UC.dias_sin_comprar > COALESCE(PF.dias_promedio * 2, 30) ORDER BY ratio_riesgo DESC;

-- Clasificación ABC de productos según ingresos.
-- A = más importantes, C = menos importantes.
WITH VentasProducto AS (SELECT P.id_producto, P.nombre, COALESCE (SUM(DP.cantidad * DP.precio_unitario), 0) AS ingresos FROM productos P LEFT JOIN detalle_pedidos DP ON P.id_producto = DP.id_producto GROUP BY P.id_producto, P.nombre), TotalIngresos AS (SELECT SUM(ingresos) AS total FROM VentasProducto), ProductosAcumulado AS (SELECT VP.nombre, VP.ingresos, ROUND((VP.ingresos * 100.0) / TI.total, 2) AS porcentaje_ingresos, ROUND(SUM(VP.ingresos) OVER (ORDER BY VP.ingresos DESC) * 100.0 / TI.total, 2) AS porcentaje_acumulado FROM VentasProducto VP CROSS JOIN TotalIngresos TI WHERE VP.ingresos > 0) SELECT nombre, ingresos, porcentaje_ingresos, porcentaje_acumulado, CASE WHEN porcentaje_acumulado <= 80 THEN 'A - Alta rotación' WHEN porcentaje_acumulado <= 95 THEN 'B - Media rotación' ELSE 'C - Baja rotación' END AS clasificacion_abc From ProductosAcumulado ORDER BY ingresos DESC;

-- Muestra pares de productos que se han comprado juntos en el mismo pedido.
-- Cuenta cuántas veces aparece cada pareja y las ordena por las más repetidas.
WITH ParesProductos AS (SELECT DP1.id_producto AS producto_a, DP2.id_producto AS producto_b, COUNT(DISTINCT DP1.id_pedido) AS veces_juntos FROM detalle_pedidos DP1 INNER JOIN detalle_pedidos DP2 ON DP1.id_pedido = DP2.id_pedido AND DP1.id_producto < DP2.id_producto GROUP BY DP1.id_producto, DP2.id_producto HAVING COUNT(DISTINCT DP1.id_pedido) >= 1 SELECT P1.nombre AS producto, P2.nombre AS recomendacion, PP.veces_juntos, ROUND((PP.veces_juntos, * 100.0) / (SELECT COUNT(DISTINCT id_pedido) FROM detalle_pedidos WHERE id_product = PP.producto_a), 2 ) AS porcentaje_conversion FROM ParesProductos PP INNER JOIN productos P1 ON PP.producto_a = P1.id_producto INNER JOIN productos P1 ON PP.producto_a = P1.id_producto INNER JOIN productos P2 ON PP.producto_b = P2.id_producto ORDER BY PP.veces_juntos, DESC, porcentaje_conversion DESC;

/*Ejercicio_1*/
SELECT nombre, precio FROM productos WHERE precio > (SELECT MIN(P2.precio) FROM productos P2 WHERE P2.categoria = 'Informatica');

/*Ejercicio_2*/
SELECT nombre FROM clientes WHERE id_cliente IN (SELECT id_cliente FROM pedidos GROUP BY id_cliente HAVING SUM(total) > 500);

/*Ejercicio_3*/
SELECT C.nombre FROM clientes C WHERE NOT EXISTS (SELECT 1 FROM productos P WHERE NOT EXISTS (SELECT 1 FROM detalle_pedidos DP INNER JOIN pedidos PED ON DP.id_pedido = PED.id_pedido WHERE PED.id_cliente = C.id_cliente AND DP.id_producto = P.id_producto));

/*Ejercicio_4*/
SELECT nombre, precio FROM productos WHERE precio > ALL (SELECT precio FROM productos WHERE stock < 20);

/*Ejercicio_5*/
SELECT C.nombre FROM clientes C WHERE EXISTS (SELECT 1 FROM pedidos P1 WHERE P1.id_cliente = C.id_cliente AND (SELECT COUNT(*) FROM pedidos P2 WHERE P2.id_cliente = C.id_cliente) > 1);

/*Ejercicio_6*/
SELECT P1.nombre, P1.precio, P1.categoria FROM productos P1 WHERE P1.precio > (SELECT AVG(P2.precio) FROM productos P2 WHERE P2.categoria = P1.categoria);

/*Ejercicio_7*/
SELECT C.nombre, P1.id_pedido, P1.fecha, P1.total FROM clientes C INNER JOIN pedidos P1 ON C.id_cliente = P1.id_cliente WHERE P1.total = (SELECT MAX(P2.total) FROM pedidos P2 WHERE P2.id_cliente = C.id_cliente);

/*Ejercicio_8*/
SELECT C.nombre FROM clientes C WHERE (SELECT COUNT(*) FROM pedidos P WHERE P.id_cliente = C.id_cliente) > (SELECT AVG(contador) FROM (SELECT COUNT(*) AS contador FROM pedidos GROUP BY id_cliente) AS subquery);

/*Ejercicio_9*/
SELECT P.nombre FROM productos P WHERE (SELECT COUNT(DISTINCT PED.id_cliente) FROM detalle_pedidos DP INNER JOIN pedidos PED ON DP.id_pedido = PED.id_pedido WHERE DP.id_producto = P.id_producto) > 1;

/*Ejercicio_10*/
SELECT C.nombre FROM clientes C WHERE NOT EXISTS (SELECT 1 FROM productos P WHERE NOT EXISTS (SELECT 1 FROM detalle_pedidos DP INNER JOIN pedidos PED ON DP.id_pedido = PED.id_pedido WHERE PED.id_cliente = C.id_cliente AND DP.id_producto = P.id_producto));

-- Drop database TIENDA_ONLINE
