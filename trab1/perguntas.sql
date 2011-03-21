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



select count(*)
from ipdw_respostas
where semestre_id = '1'; -- 42961 rows
select count(*)
from ipdw_respostas
where semestre_id = '21'; -- 351671 rows

select semestre_id, count(semestre_id) cnt
from ipdw_respostas
group by semestre_id;

select semestre_id, disciplina_id, count(semestre_id) cnt
from ipdw_respostas
group by semestre_id, disciplina_id;

select semestre_id, disciplina_id, count(semestre_id) cnt
from ipdw_respostas
group by semestre_id, disciplina_id;

select semestre_id, disciplina_id, count(semestre_id) cnt
from ipdw_respostas
group by semestre_id, disciplina_id
having count(semestre_id) > 300;

select semestre_id, disciplina_id, count(semestre_id) counter, avg(resposta) average
from ipdw_respostas
group by semestre_id, disciplina_id
having count(semestre_id) > 300;

