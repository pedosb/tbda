------------------CATEGORIA-------------------------------
CREATE OR REPLACE TYPE CATEGORIA AS OBJECT(
  nome    VARCHAR(25),
  pai     REF CATEGORIA);
CREATE OR REPLACE TYPE S_CATEGORIA AS TABLE OF REF CATEGORIA;
----------------------------------------------------------

-----------------PERIODO----------------------------------
CREATE OR REPLACE TYPE PERIODO AS OBJECT(
    inicio  TIMESTAMP
  , fim     TIMESTAMP);
----------------------------------------------------------

-----------------REPETICAO--------------------------------
CREATE OR REPLACE TYPE REPETICAO AS OBJECT(
    frequencia  VARCHAR2(7) --CHECK ( frequencia IN ('dia', 'semana', 'mês', 'ano'))
  , p     PERIODO);
----------------------------------------------------------

-----------------TELEFONE---------------------------------
CREATE OR REPLACE TYPE TELEFONE AS OBJECT(
    numero  VARCHAR2(25)
);
CREATE OR REPLACE TYPE S_TELEFONE AS TABLE OF TELEFONE;
----------------------------------------------------------

------------------MORADA----------------------------------
CREATE OR REPLACE TYPE MORADA AS OBJECT(
    rua     VARCHAR2(100)
  , cidade  VARCHAR2(50)
);
CREATE OR REPLACE TYPE S_MORADA AS TABLE OF MORADA;
----------------------------------------------------------

-------------------TOPICO---------------------------------
CREATE OR REPLACE TYPE TOPICO AS OBJECT(
    titulo      VARCHAR2(25)
  , alteracao   TIMESTAMP
  , categorias  S_CATEGORIA
  , referencias S_TOPICO
) NOT FINAL;
drop type topico force;
  
CREATE OR REPLACE TYPE S_TOPICO AS TABLE OF REF TOPICO;
drop type s_topico force;
-------------------CONTATO--------------------------------
CREATE OR REPLACE TYPE CONTATO UNDER TOPICO(
    nome      VARCHAR2(100)
  , telefones S_TELEFONE
  , moradas   S_MORADA
  , email     VARCHAR2(100)
  , url       VARCHAR2(200)
);
------------------CLANEDARIO------------------------------
CREATE OR REPLACE TYPE CALENDARIO UNDER TOPICO(
    p PERIODO
  , r REPETICAO
);
------------------TAREFA----------------------------------
CREATE OR REPLACE TYPE TAREFA AS OBJECT(
    fim       TIMESTAMP
  , completo  VARCHAR2(1)
  , conteudo  VARCHAR2(255)
);
------------------MEMO------------------------------------
CREATE OR REPLACE TYPE MEMO UNDER TOPICO(
  conteudo VARCHAR2(255)
  );
DROP TYPE MEMO;
----------------------------------------------------------

---------------------TABELAS------------------------------
CREATE TABLE categorias OF CATEGORIA;

CREATE TABLE topicos OF TOPICO
NESTED TABLE categorias STORE AS categorias_nested
NESTED TABLE referencias STORE AS referencias_nested;


DROP TABLE topicos;
----------------------------------------------------------


---------------------INSERT's-----------------------------
INSERT INTO topicos VALUES (CONTATO( 
    'João' -- titulo
  , TIMESTAMP '2010-10-15 12:30:00' -- alteracao
  , (S_CATEGORIA((SELECT Ref(cc) FROM categorias cc WHERE cc.nome = 'Trabalho'))) -- categorias
  , NULL -- referencias
  , 'João Abreu' -- nome
  , NULL -- Telefone
  , NULL -- Morada
  , 'ja@example.com' -- email
  , 'http://www.exemple.com/ja' -- url
));

select * from topicos;
update categorias set nome='TT' where nome = 'Trabalho';

INSERT INTO topicos VALUES (CONTATO( 
    'Maria' -- titulo
  , TIMESTAMP '2010-10-15 12:30:00' -- alteracao
  , NULL -- categorias
  , NULL -- referencias
  , 'Maria Joana' -- nome
  , NULL -- Telefone
  , NULL -- Morada
  , 'mj@example.com' -- email
  , 'http://www.exemple.com/mj' -- url
  ));
  
INSERT INTO topicos VALUES (CONTATO( 
     -- titulo
  , TIMESTAMP '2010-10-15 12:30:00' -- alteracao
  , NULL -- categorias
  , NULL -- referencias
  , -- nome
  , NULL -- Telefone
  , NULL -- Morada
  , '@example.com' -- email
  , 'http://www.exemple.com/' -- url
  ));
  
INSERT INTO categorias VALUES (
    'Casa',
    NULL);
    
INSERT INTO categorias VALUES (
    'Compras',
    (SELECT REF(cc) FROM categorias cc WHERE cc.nome = 'Casa')
);
    
INSERT INTO categorias VALUES (
    'Trabalho',
    NULL);
----------------------------------------------------------


CREATE TABLE t (
  t TIMESTAMP);
DROP TABLE t;
  
INSERT INTO t VALUES (TIMESTAMP '2010-10-15 12:30:00');

SELECT * from T;