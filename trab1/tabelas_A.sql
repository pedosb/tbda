DROP TABLE ipdw_respostas;
DROP TABLE ipdw_disciplina;
DROP TABLE ipdw_pergunta;
DROP TABLE ipdw_semestre;


CREATE TABLE ipdw_disciplina AS (SELECT * FROM gtd2.ipdw_disciplina);
CREATE TABLE ipdw_pergunta AS (SELECT * FROM gtd2.ipdw_pergunta);
CREATE TABLE ipdw_semestre AS (SELECT * FROM gtd2.ipdw_semestre);
CREATE TABLE ipdw_respostas AS (SELECT * FROM gtd2.ipdw_respostas);
