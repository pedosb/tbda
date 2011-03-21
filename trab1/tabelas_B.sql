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


