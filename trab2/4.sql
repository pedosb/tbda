SELECT t.titulo, sys_typeid(DEREF(VALUE(r)))
FROM TOPICOS t, TABLE(t.referencias) r
GROUP BY t.titulo, sys_typeid(DEREF(VALUE(r)))
HAVING COUNT(t.titulo) = 4;
