drop table ipdw_disciplina;
drop table ipdw_pergunta;
drop table ipdw_semestre;
drop table ipdw_respostas;

create table ipdw_disciplina as (select * from gtd2.ipdw_disciplina);
create table ipdw_pergunta as (select * from gtd2.ipdw_pergunta);
create table ipdw_semestre as (select * from gtd2.ipdw_semestre);
create table ipdw_respostas as (select * from gtd2.ipdw_respostas);


alter table ipdw_disciplina
add constraint disciplina_pk
  primary key (disciplina_id);

alter table ipdw_pergunta
add constraint pergunta_pk
  primary key (pergunta_id);

alter table ipdw_semestre
add constraint semestre_pk
  primary key (semestre_id);


alter table ipdw_respostas
add constraint semestre_fk
  foreign key (semestre_id)
  references ipdw_semestre(semestre_id);
  
alter table ipdw_respostas
add constraint pergunta_fk
  foreign key (pergunta_id)
  references ipdw_pergunta(pergunta_id);

alter table ipdw_respostas
add constraint disciplina_fk
  foreign key (disciplina_id)
  references ipdw_disciplina(disciplina_id);


select * from user_indexes;
drop index respostas_semestre_idx;
drop index respostas_disciplina_idx;
drop index disciplina_sigla_idx;

-- 1-a 1-c 2-b 2-c 4-i 4-ii
create index respostas_semestre_idx on ipdw_respostas(semestre_id);
-- 1-b 2-a 2-b 3-a-i 3-a-ii 3-b-i 3-b-ii 4-i
create index respostas_disciplina_idx on ipdw_respostas(disciplina_id);
-- 2-b
create index respostas_pergunta_idx on ipdw_respostas(pergunta_id);
-- 4-i 4-ii
create index respostas_resposta_idx on ipdw_respostas(resposta);
-- 2-a
create index disciplina_sigla_idx on ipdw_disciplina(sigla);
-- 2-c
create index pergunta_nome_idx on ipdw_pergunta(nome);


