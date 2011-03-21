-- select * from all_tables;
-- select * from all_tables where owner = 'GTD2';

drop table ipdw_disciplina;
drop table ipdw_pergunta;
drop table ipdw_semestre;
drop table ipdw_respostas;

create table ipdw_disciplina as (select * from gtd2.ipdw_disciplina);
create table ipdw_pergunta as (select * from gtd2.ipdw_pergunta);
create table ipdw_semestre as (select * from gtd2.ipdw_semestre);
create table ipdw_respostas as (select * from gtd2.ipdw_respostas);
