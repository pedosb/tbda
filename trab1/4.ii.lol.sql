SELECT disciplina_id, sigla
FROM ipdw_disciplina
INNER JOIN 
  (SELECT disciplina_id disciplina_id_com_5
  FROM
    (SELECT disciplina_id, COUNT(*) num_resp_com_5
    FROM 
      (SELECT DISTINCT disciplina_id, pergunta_id
      FROM ipdw_respostas
      WHERE resposta  = 5
      AND semestre_id = 21)
    GROUP BY disciplina_id)
  WHERE num_resp_com_5 =
    (SELECT COUNT(pergunta_id)
    FROM 
      (SELECT DISTINCT pergunta_id
      FROM ipdw_respostas
      WHERE semestre_id = 21)))
ON disciplina_id_com_5 = disciplina_id;
