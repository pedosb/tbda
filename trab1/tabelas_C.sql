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


/*
ALTER TABLE ipdw_respostas DROP CONSTRAINT semestre_fk;
ALTER TABLE ipdw_respostas DROP CONSTRAINT pergunta_fk;
ALTER TABLE ipdw_respostas DROP CONSTRAINT disciplina_fk;
*/
ALTER TABLE ipdw_respostas ADD CONSTRAINT semestre_fk
FOREIGN KEY (semestre_id) REFERENCES ipdw_semestre(semestre_id);
  
ALTER TABLE ipdw_respostas ADD CONSTRAINT pergunta_fk
FOREIGN KEY (pergunta_id) REFERENCES ipdw_pergunta(pergunta_id);

ALTER TABLE ipdw_respostas ADD CONSTRAINT disciplina_fk
FOREIGN KEY (disciplina_id) REFERENCES ipdw_disciplina(disciplina_id);


/*
SELECT * FROM user_indexes;
DROP INDEX respostas_semestre_idx;
DROP INDEX respostas_disciplina_idx;
DROP INDEX respostas_pergunta_idx;
DROP INDEX respostas_resposta_idx;
DROP INDEX disciplina_sigla_idx;
DROP INDEX pergunta_nome_idx;
*/

-- 1-a 1-c 2-b 2-c 4-i 4-ii
CREATE INDEX respostas_semestre_idx ON ipdw_respostas(semestre_id);
-- 1-b 2-a 2-b 3-a-i 3-a-ii 3-b-i 3-b-ii 4-i
CREATE INDEX respostas_disciplina_idx ON ipdw_respostas(disciplina_id);
-- 2-b
CREATE INDEX respostas_pergunta_idx ON ipdw_respostas(pergunta_id);
-- 4-i 4-ii
CREATE INDEX respostas_resposta_idx ON ipdw_respostas(resposta);
-- 2-a
CREATE INDEX disciplina_sigla_idx ON ipdw_disciplina(sigla);
-- 2-c
CREATE INDEX pergunta_nome_idx ON ipdw_pergunta(nome);


