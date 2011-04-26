DROP TYPE CATEGORIA FORCE;
DROP TYPE S_CATEGORIA FORCE;
DROP TYPE PERIODO FORCE;
DROP TYPE REPETICAO FORCE;
DROP TYPE TELEFONE FORCE;
DROP TYPE S_TELEFONE FORCE;
DROP TYPE MORADA FORCE;
DROP TYPE S_MORADA FORCE;
DROP TYPE TOPICO FORCE;
DROP TYPE S_TOPICO FORCE;
DROP TYPE CONTATO FORCE;
DROP TYPE CALENDARIO FORCE;
DROP TYPE TAREFA FORCE;
DROP TYPE MEMO FORCE;
DROP TABLE topicos;
DROP TABLE categorias;

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
CREATE OR REPLACE TYPE TAREFA UNDER TOPICO(
    fim       TIMESTAMP
  , completo  VARCHAR2(1)
  , conteudo  VARCHAR2(255)
);
------------------MEMO------------------------------------
CREATE OR REPLACE TYPE MEMO UNDER TOPICO(
  conteudo VARCHAR2(255)
);
----------------------------------------------------------

---------------------TABELAS------------------------------
CREATE TABLE categorias OF CATEGORIA;

CREATE TABLE topicos OF TOPICO
NESTED TABLE categorias STORE AS categorias_nested
NESTED TABLE referencias STORE AS referencias_nested;


DROP TABLE topicos;
----------------------------------------------------------

--###################INSERT's#############################
---------------------CATEGORIAS---------------------------
INSERT INTO categorias VALUES ('FEUP', NULL);
  INSERT INTO categorias VALUES ('SRSI', (SELECT REF(cc) FROM categorias cc WHERE nome = 'FEUP'));
  INSERT INTO categorias VALUES ('TBDA', (SELECT REF(cc) FROM categorias cc WHERE nome = 'FEUP'));
INSERT INTO categorias VALUES ('Casa', NULL);
  INSERT INTO categorias VALUES ('Supermercado', (SELECT REF(cc) FROM categorias cc WHERE nome = 'Casa'));
  INSERT INTO categorias VALUES ('Outros', (SELECT REF(cc) FROM categorias cc WHERE nome = 'Casa'));
INSERT INTO categorias VALUES ('Trabalho', NULL);

SELECT * FROM categorias;
delete from categorias;

----------------CONTATOS--------------------------------
INSERT INTO topicos VALUES (CONTATO( 
    'João' -- titulo
  , TIMESTAMP '2010-10-15 12:30:00' -- alteracao
  , S_CATEGORIA((SELECT REF(cc) FROM categorias cc WHERE cc.nome = 'Trabalho'),
                 (SELECT REF(cc) FROM categorias cc WHERE cc.nome = 'FEUP')) -- categorias
  , NULL -- referencias
  , 'João Abreu' -- nome
  , NULL -- Telefone
  , NULL -- Morada
  , 'ja@example.com' -- email
  , 'http://www.exemple.com/ja' -- url
));
INSERT INTO topicos VALUES (CONTATO( 
    'Maria' -- titulo
  , TIMESTAMP '2010-10-15 12:30:00' -- alteracao
  , S_CATEGORIA((SELECT REF(cc) FROM categorias cc WHERE cc.nome = 'FEUP')) -- categorias
  , NULL -- referencias
  , 'Maria Joana' -- nome
  , NULL -- Telefone
  , NULL -- Morada
  , 'mj@example.com' -- email
  , 'http://www.exemple.com/mj' -- url
));
----------------TAREFAS---------------------------------
INSERT INTO topicos VALUES (TAREFA(
    'Comprar papel' -- titulo
  , TIMESTAMP '2010-10-15 12:30:00' -- alteracao
  , S_CATEGORIA((SELECT REF(cc) FROM categorias cc WHERE cc.nome = 'Supermercado')) -- categorias
  , S_TOPICO(  (SELECT REF(t) FROM topicos t WHERE titulo = 'João')
             , (SELECT REF(t) FROM topicos t WHERE titulo = 'Maria')) -- referencias
  , TIMESTAMP '2010-10-20 12:30:00'
  , 'N'
  , NULL
));
INSERT INTO topicos VALUES (TAREFA(
    'Pagar aluguel' -- titulo
  , TIMESTAMP '2010-10-15 12:30:00' -- alteracao
  , S_CATEGORIA((SELECT REF(cc) FROM categorias cc WHERE cc.nome = 'Outros')) -- categorias
  , NULL -- referencias
  , TIMESTAMP '2010-10-20 12:30:00' 
  , 'N'
  , NULL
));
INSERT INTO topicos VALUES (TAREFA(
    'Checar correspondencia' -- titulo
  , TIMESTAMP '2010-10-15 12:30:00' -- alteracao
  , S_CATEGORIA((SELECT REF(cc) FROM categorias cc WHERE cc.nome = 'Casa')) -- categorias
  , NULL -- referencias
  , TIMESTAMP '2010-10-20 12:30:00' 
  , 'N'
  , NULL
));
----------------MEMO------------------------------
INSERT INTO topicos VALUES (MEMO(
    'Tipo' -- titulo
  , TIMESTAMP '2010-10-15 12:30:00' -- alteracao
  , S_CATEGORIA((SELECT REF(cc) FROM categorias cc WHERE cc.nome = 'Casa')) -- categorias
  , NULL -- referencias
  , 'Para usar o tipo set em uma tabela tem que usar nested table'
));
----------------CALENDARIO------------------------
INSERT INTO topicos VALUES (CALENDARIO(
    'Trabalho TBDA' -- titulo
  , TIMESTAMP '2010-10-15 12:30:00' -- alteracao
  , S_CATEGORIA((SELECT REF(cc) FROM categorias cc WHERE cc.nome = 'TBDA')) -- categorias
  , S_TOPICO((SELECT REF(t) FROM topicos t WHERE titulo = 'Tipo'),
             (SELECT REF(t) FROM topicos t WHERE titulo = 'Maria'))
  , PERIODO(TIMESTAMP '2010-01-29 00:00:00', TIMESTAMP '2010-01-29 03:00:00')
  , NULL
));
INSERT INTO topicos VALUES (CALENDARIO(
    'Trabalho SRSI' -- titulo
  , TIMESTAMP '2010-10-15 12:30:00' -- alteracao
  , S_CATEGORIA((SELECT REF(cc) FROM categorias cc WHERE cc.nome = 'SRSI')) -- categorias
  , S_TOPICO((SELECT REF(t) FROM topicos t WHERE titulo = 'João'))
  , PERIODO(TIMESTAMP '2010-01-29 01:00:00', TIMESTAMP '2010-01-29 05:00:00')
  , NULL
));
INSERT INTO topicos VALUES (CALENDARIO(
    'Aula TBDA' -- titulo
  , TIMESTAMP '2010-10-15 12:30:00' -- alteracao
  , S_CATEGORIA((SELECT REF(cc) FROM categorias cc WHERE cc.nome = 'TBDA')) -- categorias
  , NULL
  , PERIODO(TIMESTAMP '2010-01-30 00:00:00', TIMESTAMP '2010-01-30 06:00:00')
  , NULL
));
-------------------------------------------------------------------------------------

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
  
select type(t) from topicos t;

---------------------QUESTÃO 1------------------------------------
select co ntop, nome categoria, ut.type_name aplicacao
from
  (select count(value(ca)) co, value(ca).nome nome, sys_typeid(value(t)) sysid
  from topicos t, table(t.categorias) ca
  --where value(t) is of (calendario)
  group by value(ca).nome, sys_typeid(value(t)))
inner join user_types ut
on ut.typeid = sysid and ut.supertype_name = 'TOPICO'
order by categoria;
-- Porque o sys_typeid não é unico?
-- Como agrupar por tipo?
select * from user_types;

---------------------QUESTÃO 2------------------------------------
select titulo
from topicos t, table(t.referencias) r 
where deref(value(r)) is of (contato)
group by t.titulo
having count(titulo) > 1;
--Tem como identifiar uma instancia (um id PK do modelo relacional)

---------------------QUESTÃO 3------------------------------------
--Colocar granularidade no periodo.
----------------------------------------------------------

---------------------QUESTÃO 4------------------------------------
select t.titulo, sys_typeid(deref(value(r)))
from topicos t, table(t.referencias) r
group by t.titulo, sys_typeid(deref(value(r)))
having count(t.titulo) > 1;

select ca.nome,ca.pai from categorias ca;

with pai as (select ref(ca) from categorias ca where pai = null),
   filho as (select * from categorias where pai != null)
select * from pai, filho
where filho.pai = pai;

select max(l) from (
select LEVEL l
from categorias ca
--start with pai = null 
connect by prior pai = ref(ca));

select *
from categorias ca
start with pai = null 
connect by prior ca.pai = ref(ca);

select ca.pai.pai.pai.pai.pai from categorias ca;

select value(ca), ca.pai from categorias ca;

select codigo, nome 
from divisao
start with pai is null
connect by prior codigo=pai

CREATE TABLE t (
  t TIMESTAMP);
DROP TABLE t;
  
INSERT INTO t VALUES (TIMESTAMP '2010-10-15 12:30:00');

SELECT * from T;