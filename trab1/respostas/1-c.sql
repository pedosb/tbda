SELECT COUNT(*)
   FROM ipdw_respostas r
   INNER JOIN ipdw_semestre s
   ON r.semestre_id = s.semestre_id
   WHERE s.ano_lectivo = '2008/2009' 
      AND semestre = '1S';
