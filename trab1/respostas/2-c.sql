SELECT resultado.disciplina_id, ipdw_disciplina.sigla
  FROM (SELECT ipdw_respostas.disciplina_id, avg(resposta)
    FROM ipdw_respostas
    WHERE semestre_id = '21' AND
      pergunta_id = (SELECT pergunta_id FROM ipdw_pergunta WHERE nome = 'Apreciação Global')
    GROUP BY ipdw_respostas.disciplina_id
    HAVING count(id) > 100 AND
      (AVG(resposta)-0.1) > (SELECT AVG(resposta)
          FROM ipdw_respostas
          WHERE semestre_id = '21' AND
            pergunta_id = (SELECT pergunta_id
	       FROM ipdw_pergunta WHERE nome = 'Apreciação Global')
          HAVING COUNT(id) > 100)) resultado
  INNER JOIN ipdw_disciplina
  ON ipdw_disciplina.disciplina_id = resultado.disciplina_id;
