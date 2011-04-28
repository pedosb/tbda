SELECT co ntop, nome categoria, ut.type_name aplicacao
FROM
  (SELECT COUNT(VALUE(ca)) co, VALUE(ca).nome nome, SYS_TYPEID(VALUE(t)) sysid
  FROM TOPICOS t, TABLE(t.categorias) ca
  GROUP BY VALUE(ca).nome, SYS_TYPEID(VALUE(t)))
INNER JOIN USER_TYPES ut
ON ut.typeid = SYSID AND ut.supertype_name = 'TOPICO'
ORDER BY categoria;
