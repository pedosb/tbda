DROP TABLE ipdw_respostas;
DROP TABLE ipdw_disciplina;
DROP TABLE ipdw_pergunta;
DROP TABLE ipdw_semestre;


CREATE TABLE ipdw_disciplina AS (SELECT * FROM gtd2.ipdw_disciplina);
CREATE TABLE ipdw_pergunta AS (SELECT * FROM gtd2.ipdw_pergunta);
CREATE TABLE ipdw_semestre AS (SELECT * FROM gtd2.ipdw_semestre);
CREATE TABLE ipdw_respostas AS (SELECT * FROM gtd2.ipdw_respostas);


ALTER TABLE ipdw_disciplina ADD CONSTRAINT disciplina_pk
PRIMARY KEY (disciplina_id);

ALTER TABLE ipdw_pergunta ADD CONSTRAINT pergunta_pk
PRIMARY KEY (pergunta_id);

ALTER TABLE ipdw_semestre ADD CONSTRAINT semestre_pk
PRIMARY KEY (semestre_id);


ALTER TABLE ipdw_respostas ADD CONSTRAINT semestre_fk
FOREIGN KEY (semestre_id) REFERENCES ipdw_semestre(semestre_id);
  
ALTER TABLE ipdw_respostas ADD CONSTRAINT pergunta_fk
FOREIGN KEY (pergunta_id) REFERENCES ipdw_pergunta(pergunta_id);

ALTER TABLE ipdw_respostas ADD CONSTRAINT disciplina_fk
FOREIGN KEY (disciplina_id) REFERENCES ipdw_disciplina(disciplina_id);


