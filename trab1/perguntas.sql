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

--- 2.b. ---------------------------------------------------------
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
-- : |
select pergunta_id from ipdw_pergunta where nome = 'Apreciação Global';
select disciplina_id, pergunta_id, count(id)
  from ipdw_respostas
  where semestre_id = 21 --and pergunta_id = (select pergunta_id from ipdw_pergunta where nome = 'Apreciação Global')
  group by disciplina_id, pergunta_id
  having count(id) > 300;

select resultado.disciplina_id, ipdw_disciplina.sigla from (
  select ipdw_respostas.disciplina_id, avg(resposta)
    from
      ipdw_respostas
    where
      semestre_id = '21' and
      pergunta_id = (select pergunta_id from ipdw_pergunta where nome = 'Apreciação Global')
    group by
      ipdw_respostas.disciplina_id
    having
      count(id) > 100 and
      (avg(resposta)-0.1) > (
        select avg(resposta)--, count(id)--, disciplina_id
          from
            ipdw_respostas
          where
            semestre_id = '21' and
            pergunta_id = (select pergunta_id from ipdw_pergunta where nome = 'Apreciação Global')
      --group by disciplina_id
          having
          count(id) > 100)) resultado
  inner join
    ipdw_disciplina
  on
    ipdw_disciplina.disciplina_id = resultado.disciplina_id;

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

select disciplina_id from (
  select disciplina, count(disciplina) num_resp_com_5 from (
    select distinct pergunta_id, disciplina_id
      from
        ipdw_respostas
      where
        resposta  = 5 and
        semesetre_id = 21)
    group by disciplina)
  where
  num_resp_com_5 = (select count(pergunta_id)
    from (
      select distinct pergunta_id
        from ipdw_respostas
        where semestre_id = 21));

--Rascunho
select with_5.disciplina_id, ipdw_pergunta.pergunta_id from
  ipdw_pergunta
  --,ipdw_respostas
  left join 
  (select disciplina_id, pergunta_id
    from ipdw_respostas
    where semestre_id = '21' and resposta = 5
    group by disciplina_id, pergunta_id)  with_5
  on
    ipdw_pergunta.pergunta_id = with_5.pergunta_id
  --where disciplina_id = null
  --group by ipdw_pergunta.pergunta_id;
  group by with_5.disciplina_id, ipdw_pergunta.pergunta_id
  --having disciplina_id = null
  --and
  --  ipdw_respostas.disciplina_id = with_5.disciplina_id
  --where with_5.pergunta_id = null;
  --group by ipdw_respostas.disciplina_id;
;
select disciplina_id, pergunta_id, count(pergunta_id) count
from ipdw_respostas
where semestre_id = '21' and resposta = 5
group by disciplina_id, pergunta_id;

-- O QUIZ_ID "é o aluno"
select * from ipdw_respostas where quiz_id = 20325 and pergunta_id = 73;
--- 4.b. ---------------------------------------------------------

create table disciplina (id integer);
drop table pergunta;
create table pergunta (id integer);
drop table respostas;
create table respostas (
id integer,
pergunta integer,
disciplina integer,
resposta integer);

insert into disciplina (id) values (1);
insert into disciplina (id) values (2);
insert into disciplina (id) values (3);

insert into pergunta values (1);
insert into pergunta values (2);

--insert into pergunta values (null);
--delete from pergunta where id is null;
--select * from pergunta where id = null;

insert into respostas values (1,1,1,5);
insert into respostas values (2,1,2,5);
insert into respostas values (3,1,3,5);

insert into respostas values (4,2,1,4);
insert into respostas values (5,2,2,5);
insert into respostas values (6,2,3,3);

insert into respostas values (7,1,1,2);
insert into respostas values (8,2,2,3);
insert into respostas values (9,1,3,5);

select * from respostas;

select with_5.disciplina with_5_disciplina_id, p_d.pi pergunta_id, p_d.di disciplina_id
from 
(select disciplina.id di, pergunta.id pi
from
pergunta cross join
disciplina
group by disciplina.id, pergunta.id) p_d
left join
(select id, pergunta, disciplina
from
respostas
where
resposta = 5) with_5
on
with_5.pergunta = p_d.pi and
with_5.disciplina = p_d.di
where with_5.disciplina is null
group by with_5.disciplina, p_d.pi, p_d.di;

having with_5.disciplina = null;


group by with_5.disciplina, p_d.pi;

-- http://www.dba-oracle.com/t_garmany_9_sql_cross_join.htm
select disciplina.id, pergunta.id
from
pergunta cross join
disciplina
group by disciplina.id, pergunta.id;

select id, pergunta, disciplina
from
respostas
where
resposta = 5;

select disciplina from (
select disciplina, count(disciplina) sum_5 from (
select distinct pergunta, disciplina
from
respostas
where
resposta = 5)
group by disciplina)
where
sum_5 = (select count(id)
      from pergunta);
select * from pergunta;

select count(pergunta_id)
from (
select distinct pergunta_id
from ipdw_respostas
where semestre_id = 21);
select * from ipdw_respostas;

