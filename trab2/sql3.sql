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
DROP TABLE TOPICOS;
DROP TABLE CATEGORIAS;

------------------CATEGORIA-------------------------------
CREATE OR REPLACE TYPE CATEGORIA AS OBJECT(
  nome    VARCHAR(25),
  pai     REF CATEGORIA
);
CREATE OR REPLACE TYPE S_CATEGORIA AS TABLE OF REF CATEGORIA;
----------------------------------------------------------

------------------PERIODO---------------------------------
CREATE OR REPLACE TYPE PERIODO AS OBJECT(
  inicio  TIMESTAMP,
  fim     TIMESTAMP
);
----------------------------------------------------------

------------------REPETICAO-------------------------------
CREATE OR REPLACE TYPE REPETICAO AS OBJECT(
  frequencia  VARCHAR2(7), --CHECK ( frequencia IN ('dia', 'semana', 'mês', 'ano'))
  p           PERIODO
);
----------------------------------------------------------

------------------TELEFONE--------------------------------
CREATE OR REPLACE TYPE TELEFONE AS OBJECT(
  numero  VARCHAR2(25)
);
CREATE OR REPLACE TYPE S_TELEFONE AS TABLE OF TELEFONE;
----------------------------------------------------------

------------------MORADA----------------------------------
CREATE OR REPLACE TYPE MORADA AS OBJECT(
  rua     VARCHAR2(100),
  cidade  VARCHAR2(50)
);
CREATE OR REPLACE TYPE S_MORADA AS TABLE OF MORADA;
----------------------------------------------------------

------------------TOPICO----------------------------------
CREATE OR REPLACE TYPE TOPICO AS OBJECT(
  titulo      VARCHAR2(25),
  alteracao   TIMESTAMP,
  categorias  S_CATEGORIA,
  referencias S_TOPICO
) NOT FINAL;
  
CREATE OR REPLACE TYPE S_TOPICO AS TABLE OF REF TOPICO;
----------------------------------------------------------

------------------CONTATO---------------------------------
CREATE OR REPLACE TYPE CONTATO UNDER TOPICO(
  nome      VARCHAR2(100),
  telefones S_TELEFONE,
  moradas   S_MORADA,
  email     VARCHAR2(100),
  url       VARCHAR2(200)
);
----------------------------------------------------------

-------------------CALENDARIO-----------------------------
CREATE OR REPLACE TYPE CALENDARIO UNDER TOPICO(
  p PERIODO,
  r REPETICAO
);
----------------------------------------------------------

------------------TAREFA----------------------------------
CREATE OR REPLACE TYPE TAREFA UNDER TOPICO(
  fim       TIMESTAMP,
  completo  VARCHAR2(1),
  conteudo  VARCHAR2(255)
);
----------------------------------------------------------

------------------MEMO------------------------------------
CREATE OR REPLACE TYPE MEMO UNDER TOPICO(
  conteudo VARCHAR2(255)
);
----------------------------------------------------------

------------------TABELAS---------------------------------
CREATE TABLE CATEGORIAS OF CATEGORIA;

CREATE TABLE TOPICOS OF TOPICO
NESTED TABLE CATEGORIAS STORE AS categorias_nested
NESTED TABLE referencias STORE AS referencias_nested;
----------------------------------------------------------

--################INSERTs#################################
------------------CATEGORIAS------------------------------
INSERT INTO CATEGORIAS VALUES ('FEUP', NULL);
INSERT INTO CATEGORIAS VALUES ('SRSI', (SELECT REF(cc) FROM CATEGORIAS cc WHERE nome = 'FEUP'));
INSERT INTO CATEGORIAS VALUES ('TBDA', (SELECT REF(cc) FROM CATEGORIAS cc WHERE nome = 'FEUP'));
INSERT INTO CATEGORIAS VALUES ('Casa', NULL);
INSERT INTO CATEGORIAS VALUES ('Supermercado', (SELECT REF(cc) FROM CATEGORIAS cc WHERE nome = 'Casa'));
INSERT INTO CATEGORIAS VALUES ('Outros', (SELECT REF(cc) FROM CATEGORIAS cc WHERE nome = 'Casa'));
INSERT INTO CATEGORIAS VALUES ('Trabalho', NULL);

SELECT * FROM CATEGORIAS;
DELETE FROM CATEGORIAS;
----------------------------------------------------------

------------------CONTATOS--------------------------------
INSERT INTO TOPICOS VALUES (CONTATO( 
  'João', -- titulo
  TIMESTAMP '2010-10-15 12:30:00', -- alteracao
  S_CATEGORIA((SELECT REF(cc) FROM CATEGORIAS cc WHERE cc.nome = 'Trabalho'),
    (SELECT REF(cc) FROM CATEGORIAS cc WHERE cc.nome = 'FEUP')), -- categorias
  NULL, -- referencias
  'João Abreu', -- nome
  NULL, -- Telefone
  NULL, -- Morada
  'ja@example.com', -- email
  'http://www.exemple.com/ja' -- url
));
INSERT INTO TOPICOS VALUES (CONTATO( 
  'Maria', -- titulo
  TIMESTAMP '2010-10-15 12:30:00', -- alteracao
  S_CATEGORIA((SELECT REF(cc) FROM CATEGORIAS cc WHERE cc.nome = 'FEUP')), -- categorias
  NULL, -- referencias
  'Maria Joana', -- nome
  NULL, -- Telefone
  NULL, -- Morada
  'mj@example.com', -- email
  'http://www.exemple.com/mj' -- url
));
----------------------------------------------------------

------------------TAREFAS---------------------------------
INSERT INTO TOPICOS VALUES (TAREFA(
  'Comprar papel', -- titulo
  TIMESTAMP '2010-10-15 12:30:00', -- alteracao
  S_CATEGORIA((SELECT REF(cc) FROM CATEGORIAS cc WHERE cc.nome = 'Supermercado')), -- categorias
  S_TOPICO((SELECT REF(t) FROM TOPICOS t WHERE titulo = 'João'), 
    (SELECT REF(t) FROM TOPICOS t WHERE titulo = 'Maria')), -- referencias
  TIMESTAMP '2010-10-20 12:30:00',
  'N',
  NULL
));
INSERT INTO TOPICOS VALUES (TAREFA(
  'Pagar aluguel', -- titulo
  TIMESTAMP '2010-10-15 12:30:00', -- alteracao
  S_CATEGORIA((SELECT REF(cc) FROM CATEGORIAS cc WHERE cc.nome = 'Outros')), -- categorias
  NULL, -- referencias
  TIMESTAMP '2010-10-20 12:30:00', 
  'N',
  NULL
));
INSERT INTO TOPICOS VALUES (TAREFA(
  'Checar correspondencia', -- titulo
  TIMESTAMP '2010-10-15 12:30:00', -- alteracao
  S_CATEGORIA((SELECT REF(cc) FROM CATEGORIAS cc WHERE cc.nome = 'Casa')), -- categorias
  NULL, -- referencias
  TIMESTAMP '2010-10-20 12:30:00', 
  'N',
  NULL
));
----------------------------------------------------------

------------------MEMO------------------------------------
INSERT INTO TOPICOS VALUES (MEMO(
  'Tipo' -- titulo
  TIMESTAMP '2010-10-15 12:30:00', -- alteracao
  S_CATEGORIA((SELECT REF(cc) FROM CATEGORIAS cc WHERE cc.nome = 'Casa')), -- categorias
  NULL, -- referencias
  'Para usar o tipo set em uma tabela tem que usar nested table',
));
----------------------------------------------------------

------------------CALENDARIO------------------------------
INSERT INTO TOPICOS VALUES (CALENDARIO(
  'Trabalho TBDA', -- titulo
  TIMESTAMP '2010-10-15 12:30:00', -- alteracao
  S_CATEGORIA((SELECT REF(cc) FROM CATEGORIAS cc WHERE cc.nome = 'TBDA')), -- categorias
  S_TOPICO((SELECT REF(t) FROM TOPICOS t WHERE titulo = 'Tipo'),
    (SELECT REF(t) FROM TOPICOS t WHERE titulo = 'Maria')),
  PERIODO(TIMESTAMP '2010-01-29 00:00:00', TIMESTAMP '2010-01-29 03:00:00'),
  NULL
));
INSERT INTO TOPICOS VALUES (CALENDARIO(
  'Trabalho SRSI', -- titulo
  TIMESTAMP '2010-10-15 12:30:00', -- alteracao
  S_CATEGORIA((SELECT REF(cc) FROM CATEGORIAS cc WHERE cc.nome = 'SRSI')), -- categorias
  S_TOPICO((SELECT REF(t) FROM TOPICOS t WHERE titulo = 'João')),
  PERIODO(TIMESTAMP '2010-01-29 01:00:00', TIMESTAMP '2010-01-29 05:00:00'),
  NULL
));
INSERT INTO TOPICOS VALUES (CALENDARIO(
  'Aula TBDA', -- titulo
  TIMESTAMP '2010-10-15 12:30:00' -- alteracao
  S_CATEGORIA((SELECT REF(cc) FROM CATEGORIAS cc WHERE cc.nome = 'TBDA')), -- categorias
  NULL,
  PERIODO(TIMESTAMP '2010-01-30 00:00:00', TIMESTAMP '2010-01-30 06:00:00'),
  NULL
));
----------------------------------------------------------


--################INTERROGACOES###########################
------------------QUESTÃO 1-------------------------------
SELECT co ntop, nome CATEGORIA, ut.type_name aplicacao
FROM
  (SELECT COUNT(VALUE(ca)) co, VALUE(ca).nome nome, sys_typeid(VALUE(t)) sysid
  FROM TOPICOS t, TABLE(t.categorias) ca
  --where value(t) is of (calendario)
  GROUP BY VALUE(ca).nome, sys_typeid(VALUE(t)))
INNER JOIN user_types ut
ON ut.typeid = sysid AND ut.supertype_name = 'TOPICO'
ORDER BY categoria;
-- Porque o sys_typeid não é unico?
-- Como agrupar por tipo?
SELECT * FROM user_types;
----------------------------------------------------------

------------------QUESTÃO 2-------------------------------
SELECT titulo
FROM TOPICOS t, TABLE(t.referencias) r 
WHERE DEREF(VALUE(r)) IS OF (contato)
GROUP BY t.titulo
HAVING COUNT(titulo) > 1;
--Tem como identifiar uma instancia (um id PK do modelo relacional)
----------------------------------------------------------

------------------QUESTÃO 3-------------------------------
--Colocar granularidade no periodo.
----------------------------------------------------------

------------------QUESTÃO 4-------------------------------
SELECT t.titulo, sys_typeid(DEREF(VALUE(r)))
FROM TOPICOS t, TABLE(t.referencias) r
GROUP BY t.titulo, sys_typeid(DEREF(VALUE(r)))
HAVING COUNT(t.titulo) > 1;

SELECT ca.nome, ca.pai FROM CATEGORIAS ca;

WITH pai AS (SELECT REF(ca) FROM CATEGORIAS ca WHERE pai = null),
   filho AS (SELECT * FROM categorias WHERE pai != NULL)
SELECT * FROM pai, filho
WHERE filho.pai = pai;

SELECT MAX(L) FROM (
SELECT LEVEL l
FROM CATEGORIAS ca
--START WITH pai = NULL 
CONNECT BY PRIOR pai = REF(ca));

SELECT *
FROM CATEGORIAS ca
START WITH pai = NULL 
CONNECT BY PRIOR ca.pai = REF(ca);

SELECT ca.pai.pai.pai.pai.pai FROM categorias ca;

SELECT VALUE(ca), ca.pai FROM categorias ca;

SELECT codigo, nome 
FROM DIVISAO
START WITH pai IS NULL
CONNECT BY PRIOR codigo=pai

CREATE TABLE t (t TIMESTAMP);
DROP TABLE t;  
INSERT INTO t VALUES (TIMESTAMP '2010-10-15 12:30:00');
SELECT * FROM T;


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
  --dbms_output.put_line('Atividades:');
  FOR i IN atis.FIRST .. atis.LAST LOOP
    imprime_atividade(atis(i));
  END LOOP;
END;

-- Teste impressao
SET SERVEROUTPUT ON;
DECLARE
  ati ATIVIDADE;
  atis ATIVIDADES;
BEGIN
  ati := ATIVIDADE(1,2);
  atis := ATIVIDADES(ati, ATIVIDADE(3,4));
  imprime_atividades(atis);
END;

-- Exemplo de extracao de timestamps
SET SERVEROUTPUT ON;
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
  return EXTRACT(HOUR FROM t) * 3600 + EXTRACT(MINUTE FROM t) * 60 + EXTRACT(SECOND FROM t);
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

-- Teste atividades iguais
SET SERVEROUTPUT ON;
DECLARE
  ati1 ATIVIDADE;
  ati2 ATIVIDADE;
  ati3 ATIVIDADE;
BEGIN
  ati1 := ATIVIDADE(1,2);
  ati2 := ATIVIDADE(1,2);
  ati3 := ATIVIDADE(3,4);
  dbms_output.put_line('Iguais:' || atividades_iguais(ati1, ati2));
  dbms_output.put_line('Diferentes:' || atividades_iguais(ati1, ati3));
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
    IF unis.COUNT != 0 THEN
      FOR j IN unis.FIRST .. unis.LAST LOOP
        IF atividades_iguais(atis(i), unis(j)) = 1 THEN
          f := 0;
        END IF;
      END LOOP;
    END IF;
    IF f = 1 THEN
      unis.EXTEND;
      unis(unis.LAST) := atis(i);
    END IF;
  END LOOP;
  RETURN unis;
END;

-- Teste atividades unicas
SET SERVEROUTPUT ON;
DECLARE
  atis ATIVIDADES;
  unis ATIVIDADES;
BEGIN
  atis := ATIVIDADES(ATIVIDADE(1,2), ATIVIDADE(2,3), ATIVIDADE(1,2));
  dbms_output.put_line('Original');
  imprime_atividades(atis);
  unis := atividades_unicas(atis);
  dbms_output.put_line('Unicas');
  imprime_atividades(unis);
END;

CREATE OR REPLACE FUNCTION parte_atividade
  (ati IN ATIVIDADE, p IN INTEGER)
RETURN ATIVIDADES
IS
  ati1 ATIVIDADE;
  ati2 ATIVIDADE;
BEGIN
  IF p < ati(1) OR ati(2) < p THEN
    RETURN ATIVIDADES(ati);
  ELSE
    ati1 := ATIVIDADE(ati(1), p);
    ati2 := ATIVIDADE(p, ati(2));
    RETURN ATIVIDADES(ati1, ati2);
  END IF;
END;

-- Teste parte atividades
SET SERVEROUTPUT ON;
DECLARE
  ati ATIVIDADE;
  atis ATIVIDADES;
BEGIN
  ati := ATIVIDADE(1, 10);
  dbms_output.put_line('Atividade');
  imprime_atividade(ati);
  atis := parte_atividade(ati, 4);
  dbms_output.put_line('Atividades');
  imprime_atividades(atis);
END;


CREATE OR REPLACE FUNCTION remove_atividade
  (in_atis IN ATIVIDADES, ati IN ATIVIDADE)
RETURN ATIVIDADES
is
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

SET SERVEROUTPUT ON;
DECLARE
  novo_atis ATIVIDADES;
BEGIN
  novo_atis := remove_atividade(atividades(atividade(1,2), atividade(1,3)), atividade(1,2));
  dbms_output.put_line(novo_atis.COUNT);
  IF NOVO_ATIS.COUNT > 0 THEN
    FOR i IN novo_atis.FIRST .. novo_atis.LAST LOOP
      If novo_atis.EXISTS(i) THEN
        dbms_output.put_line(novo_atis(i)(1) || ',' || novo_atis(i)(2));
      END IF;
    END LOOP;
  END IF;
END;

CREATE OR REPLACE FUNCTION pegar_atividade
  --Assume que o mês e ano do periodo são iguais
  (dia IN INTEGER, p IN periodo)
RETURN ATIVIDADES
IS
  atis atividades;
  dia_inicio INTEGER;
  nova_data VARCHAR(19);
BEGIN
  dia_inicio := EXTRACT(DAY FROM p.inicio);
  IF dia = dia_inicio AND dia = EXTRACT(DAY FROM p.fim) THEN
    RETURN atividades(atividade(timestamp_para_inteiro(p.inicio), timestamp_para_inteiro(p.fim)));
  ELSE
    IF dia = dia_inicio THEN
      nova_data := '2010-' || EXTRACT(MONTH FROM p.inicio) || '-' || (dia+1) || ' 00:00:00';
      --TODO: não regorna nada (não adianta recursividade já que o dia é passado
      RETURN conc_atividades(atividades(atividade(timestamp_para_inteiro(p.inicio), 86400)),
                             pegar_atividade(dia, periodo(CAST(TO_DATE(nova_data,'YYYY-MM-DD HH24:MI:SS') AS TIMESTAMP) , p.fim)));
    END IF;
  END IF;
  RETURN atividades();
END;

CREATE OR REPLACE FUNCTION conc_atividades
  (atis1 ATIVIDADES, atis2 ATIVIDADES)
RETURN ATIVIDADES
IS
  new_atis atividades;
BEGIN
  new_atis := atis1;
  IF atis2.COUNT > 0 THEN
    FOR i in atis2.FIRST .. atis2.LAST LOOP
      If atis2.EXISTS(i) THEN
        new_atis.EXTEND;
        new_atis(new_atis.LAST) := atis2(i);
      END IF;
    END LOOP;
  END IF;
  RETURN new_atis;
END;

CREATE OR REPLACE FUNCTION calcular_tempo
  -- Funciona para periodos dentro do mesmo mês
  (dia INTEGER, ps S_PERIODO)
RETURN INTEGER
Is
  atis ATIVIDADES;
  natis ATIVIDADES;
  att ATIVIDADE;
  tempo NUMERIC;
  i INTEGER;
BEGIN
  atis := ATIVIDADES();
  FOR j In ps.FIRST .. ps.LAST LOOP
    atis := conc_atividades(atis, pegar_atividade(dia, ps(j)));
  END LOOP;
  IF atis.COUNT < 1 THEN
    RETURN 0;
  END if;
  i := 1;
  LOOP
    EXIT WHEN i > atis.LAST;
    --dbms_output.put_line('i '||i||' count '||atis(i)(1));
    att := atis(i);
    natis := atis;
--    dbms_output.put_line('debug');
--    imprime_atividades(natis);
    FOR j IN atis.FIRST .. atis.LAST LOOP    
      IF atis(j)(1) < att(1) AND atis(j)(2) > att(1) THEN
        natis := remove_atividade(natis, atis(j));
        natis := conc_atividades(natis, parte_atividade(atis(j), att(1)));
      END IF;
      IF atis(j)(1) < att(2) AND atis(j)(2) > att(2) THEN
        natis := remove_atividade(natis, atis(j));
        natis := conc_atividades(natis, parte_atividade(atis(j), att(2)));
      END IF;
    END LOOP;
    atis := natis;
    i := i+1;
  END LOOP;
  
  i := 1;
  LOOP
    EXIT WHEN i > atis.LAST;
    att := atis(i);
    natis := atis;
    FOR j IN atis.FIRST .. atis.LAST LOOP
      IF atis(j)(1) > att(1) AND atis(j)(2) < att(2) THEN
        natis := remove_atividade(natis, atis(j));
      END IF;
    END LOOP;
    atis := atividades_unicas(natis);
    i := i+1;
  END LOOP;
  --atis := atividades_unicas(atis);
  --imprime_atividades(atis);
  tempo := 0;
  FOR j in atis.FIRST .. atis.LAST LOOP
    tempo := tempo + atis(j)(2) - atis(j)(1);
  END LOOP;
  RETURN tempo;
END;

SET SERVEROUTPUT ON;
DECLARE
  atis atividades;
  ps s_periodo;
BEGIN
  --SELECT t.periodo INTO ps FROM TOPICOS t WHERE VALUE(t) IS OF CALENDARIO;
  dbms_output.put_line(calcular_tempo(1, s_periodo(
    periodo(TIMESTAMP '2010-10-01 00:00:02', TIMESTAMP '2010-10-01 00:00:06'),
    periodo(TIMESTAMP '2010-10-01 00:00:07', TIMESTAMP '2010-10-01 00:00:09'),
    periodo(TIMESTAMP '2010-10-01 00:00:01', TIMESTAMP '2010-10-01 00:00:04'))));
  --dbms_output.put_line(cast(to_date('2010-10-2 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AS TIMESTAMP));
  --imprime_atividades(pegar_atividade(1, PERIODO(TIMESTAMP '2010-10-01 00:00:01', TIMESTAMP '2010-10-02 00:00:01')));
  --atis := ATIVIDADES(ATIVIDADE(1,2));
  --imprime_atividades(atis);
  --atis := conc_atividades(atis, ATIVIDADES(ATIVIDADE(3,4)));
  --imprime_atividades(atis);
END;

SET SERVEROUTPUT ON;
CREATE OR REPLACE FUNCTION pegar_dia_mais_ocupado
  (mes IN INTEGER, ano IN INTEGER)
RETURN INTEGER
IS
  ps S_PERIODO;
  top TOPICO;
  dia INTEGER;
  tempo_max INTEGER;
  data_atual DATE;
  TYPE SLOT_MES IS VARRAY(31) OF INTEGER;
  sm SLOT_MES;
  CURSOR cur IS
    SELECT VALUE(t) FROM TOPICOS t WHERE VALUE(t) IS OF (CALENDARIO);
BEGIN
  sm := slot_mes();
  ps := s_periodo();
  OPEN cur;
  LOOP
    FETCH cur INTO top;
    EXIT WHEN cur%notfound;
    ps.EXTEND;
    ps(ps.LAST) := TREAT(top AS CALENDARIO).p;
  END LOOP;
  data_atual := to_date(ano || '-' || mes || '-1','YYYY-MM-DD');
  LOOP
    EXIT WHEN mes != EXTRACT(MONTH FROM data_atual);
    dia := EXTRACT(DAY FROM data_atual);
    sm.EXTEND;
    sm(sm.LAST) := calcular_tempo(dia, ps);
    data_atual := data_atual + INTERVAL '1' DAY;
  END LOOP;
  tempo_max := 0;
  FOR i In sm.FIRST .. sm.LAST LOOP
    IF sm(i) > tempo_max THEN
      dia := i;
      tempo_max := sm(i);
    END IF;
  END LOOP;
  RETURN dia;
END;

SET SERVEROUTPUT ON;
DECLARE
  d TIMESTAMP;
  atis ATIVIDADES;
  TYPE slot_mes IS VARRAY(31) OF INTEGER;
  sm slot_mes;
Begin
  dbms_output.put_line(pegar_dia_mais_ocupado(1, 2010));
  --d := TIMESTAMP '2010-10-2 23:00:00';
  --dbms_output.put_line(d + INTERVAL '1' DAY);
END;

CREATE OR REPLACE FUNCTION conc_periodos
  (p1 S_PERIODO, p2 S_PERIODO)
RETURN S_PERIODO
Is
  new_ps S_PERIODO;
BEGIN
  new_ps := p1;
  IF P2.COUNT > 0 THEN
    FOR i in p2.first .. p2.LAST LOOP
      IF p2.EXISTS(i) THEN
        new_ps.EXTEND;
        new_ps(new_ps.LAST) := p2(i);
      END IF;
    END LOOP;
  END IF;
  RETURN new_ps;
END;

CREATE OR REPLACE FUNCTION normalizar_periodo
  (p PERIODO)
RETURN s_periodo
IS
  ano_inicial INTEGER;
  ultimo_dia TIMESTAMP;
  mes_inicial INTEGER;
  ultimo_dia_mes TIMESTAMP;
  dia_inicial INTEGER;
  ultima_hora TIMESTAMP;
BEGIN
  ano_inicial := EXTRACT(YEAR FROM p.inicio);
  IF ano_inicial != EXTRACT(YEAR FROM p.fim) THEN
    dbms_output.put_line(ano_inicial);
    ultimo_dia := CAST(to_date(ano_inicial || 
      '-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS') AS TIMESTAMP);
    dbms_output.put_line(ano_inicial);
    RETURN conc_periodos(normalizar_periodo(PERIODO(p.inicio, ultimo_dia)),
      normalizar_periodo(PERIODO(ultimo_dia + INTERVAL '1' SECOND, p.fim)));
      
  end if;
  mes_inicial := EXTRACT(MONTH FROM p.inicio);
  IF mes_inicial != EXTRACT(MONTH FROM p.fim) THEN
    ultimo_dia_mes := CAST(last_day(to_date(ano_inicial || '-' || mes_inicial ||
      '-3 23:59:59', 'YYYY-MM-DD HH24:MI:SS')) AS TIMESTAMP);
    RETURN conc_periodos(normalizar_periodo(PERIODO(p.inicio, ultimo_dia_mes)),
      normalizar_periodo(PERIODO(ultimo_dia_mes + INTERVAL '1' SECOND, p.fim)));
      
  END IF;
  dia_inicial := EXTRACT(DAY FROM p.inicio);
  IF dia_inicial != EXTRACT(DAY FROM p.fim) THEN
    ultima_hora := CAST(to_date(ano_inicial || '-' || mes_inicial || '-' ||
      dia_inicial || ' 23:59:59', 'YYYY-MM-DD HH24:MI:SS') AS TIMESTAMP);
    RETURN conc_periodos(S_PERIODO(PERIODO(p.inicio, ultima_hora)),
      normalizar_periodo(PERIODO(ultima_hora + INTERVAL '1' SECOND, p.fim)));
  END IF;
  RETURN S_PERIODO(p);
END;

CREATE OR REPLACE PROCEDURE imprime_periodo
  (p IN S_PERIODO)
IS
BEGIN
  FOR i IN p.FIRST .. p.LAST LOOP
    dbms_output.put_line(p(i).inicio || ', ' || p(i).fim);
  END LOOP;
END;

set SERVEROUTPUT on;
begin
  --dbms_output.put_line(CAST ('2010-12-12 23:59:59' AS TIMESTAMP));
  imprime_periodo(normalizar_periodo(
    PERIODO(timestamp '2010-10-01 00:00:02', TIMESTAMP '2010-11-01 00:00:06')));
END;
