SELECT disciplina_id, sigla
FROM ipdw_disciplina
INNER JOIN
  (SELECT DISTINCT disciplina_id disciplina_id_com_5
  FROM ipdw_respostas
  WHERE disciplina_id NOT IN
    (SELECT disciplina_id_sem_5
    FROM
      (SELECT DISTINCT disciplina_id disciplina_id_sem_5,
        pergunta_id pergunta_id_sem_5
      FROM ipdw_respostas
      WHERE resposta != 5
      AND semestre_id = 21)
    LEFT OUTER JOIN
      (SELECT DISTINCT disciplina_id disciplina_id_com_5,
        pergunta_id pergunta_id_com_5
      FROM ipdw_respostas
      WHERE resposta = 5
      AND semestre_id = 21)
    ON disciplina_id_sem_5 = disciplina_id_com_5
    AND pergunta_id_sem_5 = pergunta_id_com_5
    WHERE disciplina_id_com_5 IS NULL)
  AND semestre_id = 21
  ORDER BY disciplina_id)
ON disciplina_id = disciplina_id_com_5;
