SELECT MAX(l) profundidade
FROM 
  (SELECT LEVEL l
  FROM CATEGORIAS ca
  CONNECT BY PRIOR pai = REF(CA));
