select * from ipdw_semestre;
select * from ipdw_semestre where semestre_id = '21';
select * from ipdw_respostas where semestre_id = '21';
--- 1.a. ---------------------------------------------------------
select count(*) from ipdw_respostas where semestre_id = '21';
select total_respostas from ipdw_semestre s where s.semestre_id = '21'; -- ??



select * from ipdw_disciplina where disciplina_id = '1237';
--- 1.b. ---------------------------------------------------------
select count(*) from ipdw_respostas where disciplina_id = '1237';



select * from ipdw_semestre;
select * from ipdw_semestre where ano_lectivo = '2008/2009' and semestre = '1S';
select semestre_id from ipdw_semestre where ano_lectivo = '2008/2009' and semestre = '1S';
select *
from ipdw_respostas r
inner join ipdw_semestre s
on r.semestre_id = s.semestre_id
where s.ano_lectivo = '2008/2009' 
and semestre = '1S';
--- 1.c. ---------------------------------------------------------
select count(*)
from ipdw_respostas r
inner join ipdw_semestre s
on r.semestre_id = s.semestre_id
where s.ano_lectivo = '2008/2009' 
and semestre = '1S';



select *
from ipdw_respostas r
inner join ipdw_disciplina d
on r.disciplina_id = d.disciplina_id
where d.sigla = 'FPRO';
--- 2.a. ---------------------------------------------------------
select avg(r.resposta)
from ipdw_respostas r
inner join ipdw_disciplina d
on r.disciplina_id = d.disciplina_id
where d.sigla = 'FPRO';



select disciplina_id, count(semestre_id) counter, avg(resposta) average
from ipdw_respostas
where semestre_id = '21'
group by disciplina_id
having count(semestre_id) > 300
order by average desc;

select *
from (
  select disciplina_id, count(semestre_id) counter, avg(resposta) average
  from ipdw_respostas
  where semestre_id = '21'
  group by disciplina_id
  having count(semestre_id) > 300
  order by average desc) 
where rownum = 1;
--- 2.b. ---------------------------------------------------------
select temp.disciplina_id, sigla
from
  (select disciplina_id, count(semestre_id) counter, avg(resposta) average
  from ipdw_respostas
  where semestre_id = '21'
  group by disciplina_id
  having count(semestre_id) > 300
  order by average desc) temp
inner join ipdw_disciplina
on temp.disciplina_id = ipdw_disciplina.disciplina_id
where rownum = 1;



--- 2.c. ---------------------------------------------------------
-- : (



--- 3.a.i -------------------------------------------------------
select disciplina_id
from ipdw_disciplina
where disciplina_id not in
  (select distinct disciplina_id
  from ipdw_respostas);
--- 3.a.ii. ------------------------------------------------------
select /*+RULE*/ disciplina_id
from ipdw_disciplina
where disciplina_id not in 
  (select distinct disciplina_id
  from ipdw_respostas);



--- 3.b.i. -------------------------------------------------------
select d.disciplina_id
from ipdw_disciplina d
left outer join ipdw_respostas r
on d.disciplina_id = r.disciplina_id
where r.disciplina_id is null;
--- 3.b.ii. -------------------------------------------------------
select /*+RULE*/ d.disciplina_id
from ipdw_disciplina d
left outer join ipdw_respostas r
on d.disciplina_id = r.disciplina_id
where r.disciplina_id is null;



--- 4.a. ---------------------------------------------------------



/* 
select disciplina_id, pergunta_id, count(pergunta_id) count
from ipdw_respostas
where semestre_id = '21'
group by disciplina_id, pergunta_id;
*/
--- 4.b. ---------------------------------------------------------

