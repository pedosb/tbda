SELECT temp.disciplina_id, sigla
FROM
  (SELECT disciplina_id, COUNT(semestre_id) counter, AVG(resposta) average
  FROM ipdw_respostas
  WHERE semestre_id = '21'
  GROUP BY disciplina_id
  HAVING count(semestre_id) > 300
  ORDER BY average DESC) temp
INNER JOIN ipdw_disciplina
ON temp.disciplina_id = ipdw_disciplina.disciplina_id
WHERE ROWNUM = 1;
