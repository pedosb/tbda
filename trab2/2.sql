SELECT titulo
FROM TOPICOS t, TABLE(t.referencias) r 
WHERE DEREF(VALUE(r)) IS OF (CONTATO)
GROUP BY t.titulo
HAVING COUNT(titulo) > 1;
