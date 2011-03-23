SELECT /*+RULE*/ d.disciplina_id
FROM ipdw_disciplina d
LEFT OUTER JOIN ipdw_respostas r
ON d.disciplina_id = r.disciplina_id
WHERE r.disciplina_id IS NULL;
