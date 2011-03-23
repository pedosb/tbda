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
      INNER JOIN
        (SELECT disciplina_id disciplina_id_2, COUNT(*) num_perg
        FROM 
          (SELECT DISTINCT pergunta_id, disciplina_id
          FROM ipdw_respostas
          WHERE semestre_id = 21)
        GROUP BY disciplina_id)
      ON disciplina_id_2 = disciplina_id
      AND num_perg = num_resp_com_5)
ON disciplina_id_com_5 = disciplina_id;




