
-- ==========================================
-- ACTIVIDAD SUMATIVA SEMANA 3
-- ASIGNATURA: CONSULTA DE BASES DE DATOS
-- ALUMNO: NICOLAS OLIVARES
-- ==========================================


-- ==========================================
-- CASO 1: ANALISIS DE PROPIEDADES
-- ==========================================

-- Comprobacion de los datos de propiedades
SELECT *
FROM propiedad;

-- Agrupacion inicial por tipo de propiedad
SELECT
    id_tipo_propiedad,
    COUNT(*) AS cantidad_propiedades,
    MAX(valor_arriendo) AS arriendo_maximo,
    MIN(valor_arriendo) AS arriendo_minimo,
    ROUND(AVG(valor_arriendo), 0) AS arriendo_promedio,
    SUM(NVL(valor_gasto_comun, 0)) AS total_gasto_comun
FROM propiedad
GROUP BY id_tipo_propiedad
ORDER BY id_tipo_propiedad;

-- Comprobacion de los tipos de propiedad
SELECT *
FROM tipo_propiedad;

-- SOLUCION FINAL CASO 1
SELECT
    t.desc_tipo_propiedad AS tipo_propiedad,
    COUNT(*) AS cantidad_propiedades,
    MAX(p.valor_arriendo) AS arriendo_maximo,
    MIN(p.valor_arriendo) AS arriendo_minimo,
    ROUND(AVG(p.valor_arriendo), 0) AS arriendo_promedio,
    CASE
        WHEN MAX(p.valor_arriendo) > 1000000
        THEN 'PREMIUM'
        ELSE 'ESTÁNDAR'
    END AS clasificacion,
    SUM(NVL(p.valor_gasto_comun, 0)) AS total_gasto_comun
FROM propiedad p
JOIN tipo_propiedad t
    ON p.id_tipo_propiedad = t.id_tipo_propiedad
GROUP BY t.desc_tipo_propiedad
HAVING SUM(NVL(p.valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY total_gasto_comun DESC;



-- ==========================================
-- CASO 2: ANALISIS DE ANTIGUEDAD DE EMPLEADOS
-- ==========================================

-- Comprobacion de los datos de empleados
SELECT *
FROM empleado;

-- Primera consulta: filtrar por categoria y sucursal
SELECT
    nombre_emp,
    appaterno_emp,
    sueldo_emp,
    fecing_emp,
    id_categoria_emp,
    id_sucursal
FROM empleado
WHERE id_categoria_emp = 3
  AND id_sucursal <> &CODIGO_SUCURSAL
ORDER BY sueldo_emp DESC;

-- SOLUCION FINAL CASO 2
SELECT
    UPPER(nombre_emp || ' ' || appaterno_emp)
        AS "Nombre Empleado",

    TO_CHAR(
        sueldo_emp,
        'FML999G999G999',
        'NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''$'''
    ) AS "Sueldo con Formato",

    CASE
        WHEN sueldo_emp > 2000000 THEN 'ALTO'
        ELSE 'MEDIO'
    END AS "Clasificación Sueldo",

    TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12)
        AS "Años Antigüedad",

    CASE
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) > 20
        THEN 'Corresponde bono 15%: $' ||
             TO_CHAR(
                 ROUND(sueldo_emp * 0.15),
                 'FM999G999G999'
             )

        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) >= 11
        THEN 'Corresponde bono 10%: $' ||
             TO_CHAR(
                 ROUND(sueldo_emp * 0.10),
                 'FM999G999G999'
             )

        ELSE 'Corresponde bono 5%: $' ||
             TO_CHAR(
                 ROUND(sueldo_emp * 0.05),
                 'FM999G999G999'
             )
    END AS "BONO"

FROM empleado
WHERE id_categoria_emp = 3
  AND id_sucursal <> &CODIGO_SUCURSAL
  AND MONTHS_BETWEEN(SYSDATE, fecing_emp) > 60
ORDER BY sueldo_emp DESC;



-- ==========================================
-- CASO 3: CLASIFICACION DE CLIENTES POR RENTA
-- ==========================================

-- Comprobacion de los datos de clientes
SELECT *
FROM cliente;

-- Comprobacion de las columnas de la tabla cliente
SELECT column_name
FROM user_tab_columns
WHERE table_name = 'CLIENTE'
ORDER BY column_id;

-- SOLUCION FINAL CASO 3
SELECT
    CASE
        WHEN renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN renta_cli >= 600000 THEN 'ALTA'
        WHEN renta_cli >= 300000 THEN 'MEDIA'
        ELSE 'BAJA'
    END AS clasificacion_renta,

    COUNT(*) AS cantidad_clientes,

    ROUND(AVG(renta_cli), 0) AS renta_promedio,

    CASE
        WHEN COUNT(fonofijo_cli) + COUNT(celular_cli) = 0
        THEN 'Clientes sin Teléfono'
        ELSE 'Clientes con Teléfono'
    END AS estado_telefono

FROM cliente

GROUP BY
    CASE
        WHEN renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN renta_cli >= 600000 THEN 'ALTA'
        WHEN renta_cli >= 300000 THEN 'MEDIA'
        ELSE 'BAJA'
    END

HAVING AVG(renta_cli) > 200000

ORDER BY renta_promedio DESC;

-- ==========================================
-- FIN DE LA ACTIVIDAD SUMATIVA SEMANA 3
-- ==========================================
