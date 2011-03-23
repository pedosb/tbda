SELECT disciplina_id
FROM ipdw_disciplina
WHERE disciplina_id NOT IN
  (SELECT DISTINCT disciplina_id
  FROM ipdw_respostas);
