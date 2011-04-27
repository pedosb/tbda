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
  , fim     timestamp);
CREATE OR REPLACE TYPE S_PERIODO AS TABLE OF PERIODO NOT NULL;
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


CREATE OR REPLACE TYPE ATIVIDADE IS VARRAY (2) OF INTEGER NOT NULL;
CREATE OR REPLACE TYPE ATIVIDADES IS TABLE OF ATIVIDADE NOT NULL;

DROP TYPE ATIVIDADES FORCE;
DROP TYPE ATIVIDADE FORCE;

CREATE OR REPLACE PROCEDURE imprime_atividade
  (ati ATIVIDADE)
IS
BEGIN
  dbms_output.put_line('[' || ati(1) || ',' || ati(2) || ']');
END;

CREATE OR REPLACE PROCEDURE imprime_atividades
  (atis ATIVIDADES)
IS
BEGIN
  FOR i IN atis.FIRST .. atis.LAST LOOP
    imprime_atividade(atis(i));
  END LOOP;
END;

-- Teste impressao
set serveroutput on;
DECLARE
  ati ATIVIDADE;
  atis ATIVIDADES;
BEGIN
  ati := ATIVIDADE(1,2);
  atis := ATIVIDADES(ati, ATIVIDADE(3,4));
  imprime_atividades(atis);
END;

-- Exemplo de extracao de timestamps
set serveroutput on;
DECLARE
  t TIMESTAMP;
  y INTEGER;
  m INTEGER;
  d INTEGER;
  h INTEGER;
  mi INTEGER;
  s INTEGER;
BEGIN
  t := TIMESTAMP '2010-10-15 12:30:00';
  y := EXTRACT(year FROM t);
  m := EXTRACT(month FROM t);
  d := EXTRACT(day FROM t);
  h := EXTRACT(hour FROM t);
  mi := EXTRACT(minute FROM t);
  s := EXTRACT(second FROM t);
  dbms_output.put_line(y || '/' || m || '/' || d || ' ' || h || ':' || mi || ':' || s);
END;

CREATE OR REPLACE FUNCTION timestamp_para_inteiro
  (t TIMESTAMP)
RETURN INTEGER
IS
BEGIN
  return EXTRACT(hour FROM t) * 3600 + EXTRACT(minute FROM t) * 60 + EXTRACT(second FROM t);
END;

CREATE OR REPLACE FUNCTION atividades_iguais
  (ati1 IN ATIVIDADE, ati2 ATIVIDADE)
RETURN INTEGER
IS
BEGIN
  IF ati1(1) = ati2(1) AND ati1(2) = ati2(2) THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;
END;

CREATE OR REPLACE FUNCTION atividades_unicas
  (atis IN ATIVIDADES)
RETURN ATIVIDADES
IS
  unis ATIVIDADES;
  f INTEGER;
BEGIN
  unis := ATIVIDADES();
  FOR i IN atis.FIRST .. atis.LAST LOOP
    f := 1;
    FOR j IN unis.FIRST .. unis.LAST LOOP
      IF atividades_iguais(atis(i), unis(j)) = 1 THEN
        f := 0;
      END IF;
    END LOOP;
    IF f = 1 THEN
      unis.extend;
      unis(unis.LAST) := atis(i);
    END IF;
  END LOOP;
  RETURN unis;
END;

-- Teste atividades unicas
DECLARE

BEGIN

END;

CREATE OR REPLACE FUNCTION remove_atividade
  (in_atis IN ATIVIDADES, ati IN ATIVIDADE)
RETURN ATIVIDADES
IS
atis ATIVIDADES;
BEGIN
  atis := ATIVIDADES();
  FOR i IN in_atis.FIRST .. in_atis.LAST LOOP
    IF in_atis(i)(1) != ati(1) OR in_atis(i)(2) != ati(2) THEN
      atis.extend;
      atis(atis.LAST) := in_atis(i);
    END IF;
  END LOOP;
  RETURN atis;
END;

set serveroutput on;
DECLARE
novo_atis ATIVIDADES;
BEGIN
novo_atis := remove_atividade(atividades(atividade(1,2), atividade(1,3)), atividade(1,2));
dbms_output.put_line(novo_atis.count);
if novo_atis.count > 0 then
  for i in novo_atis.FIRST..novo_atis.LAST loop
    if novo_atis.exists(i) then
      dbms_output.put_line(novo_atis(i)(1) || ',' || novo_atis(i)(2));
    end if;
  end loop;
end if;
END;

create or replace function pegar_atividade
  --Assume que o mês e ano do periodo são iguais
  (dia in integer, p in periodo)
  RETURN ATIVIDADES
IS
  atis atividades;
  dia_inicio integer;
  nova_data VARCHAR(19);
begin
  dia_inicio := extract(day from p.inicio);
  if dia = dia_inicio and dia = extract(day from p.fim) then
    return atividades(atividade(timestamp_para_inteiro(p.inicio), timestamp_para_inteiro(p.fim)));
  else
    if dia = dia_inicio then
      nova_data := '2010-' || extract(month from p.inicio) || '-' || (dia+1) || ' 00:00:00';
      return conc_atividades(atividades(atividade(timestamp_para_inteiro(p.inicio), 86400)),
                             pegar_atividade(dia+1, periodo(cast(TO_DATE(nova_data,'YYYY-MM-DD HH24:MI:SS') as timestamp) , p.fim)));
    end if;
  END IF;
END;

create or replace function conc_atividades
  (atis1 atividades, atis2 atividades)
  return atividades
is
  new_atis atividades;
begin
  new_atis := atis1;
  for i in atis2.first..atis2.last loop
    if atis2.exists(i) then
      new_atis.extend;
      new_atis(new_atis.LAST) := atis2(i);
    END IF;
  end loop;
  RETURN new_atis;
END;

create or replace function calcular_tempo
  -- Funciona para periodos dentro do mesmo mês
  (dia intenger, ps s_periodo)
  return integer
is
atis ATIVIDADES;
begin
  atis := ATIVIDADES();
  for i in ps.first..ps.last loop
    atis := conc_atividades(atis, pegar_atividade(dia, ps(i)));
  end loop;
  
  
  atis := atividades_unicas(atis);
end;

SET SERVEROUTPUT ON;
DECLARE
  atis ATIVIDADES;
begin
  --dbms_output.put_line(cast(to_date('2010-10-2 00:00:00', 'YYYY-MM-DD HH24:MI:SS') as timestamp));
  imprime_atividades(pegar_atividade(1, periodo(timestamp '2010-10-01 00:00:01', timestamp '2010-10-02 00:00:01')));
  --atis := atividades(atividade(1,2));
  --imprime_atividades(atis);
  --atis := conc_atividades(atis, ATIVIDADES(ATIVIDADE(3,4)));
  --imprime_atividades(atis);
END;