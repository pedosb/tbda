SELECT AVG(r.resposta)
   FROM ipdw_respostas r
   INNER JOIN ipdw_disciplina d
   ON r.disciplina_id = d.disciplina_id
   WHERE d.sigla = 'FPRO';
