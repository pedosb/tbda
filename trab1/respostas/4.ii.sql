SELECT disciplina_id FROM (
  SELECT disciplina, COUNT(disciplina) num_resp_com_5
    FROM (SELECT DISTINCT pergunta_id, disciplina_id
      FROM ipdw_respostas
      WHERE resposta  = 5 AND
        semesetre_id = 21)
  GROUP BY disciplina)
  WHERE
  num_resp_com_5 = (SELECT COUNT(pergunta_id)
    FROM (SELECT DISTINCT pergunta_id
        FROM ipdw_respostas
        WHERE semestre_id = 21));
