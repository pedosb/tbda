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
INSERT INTO topicos VALUES (CONTATO( 
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
----- BUH ----
------------------TAREFAS---------------------------------
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
  , s_topico((select ref(t) from topicos t where titulo = 'João'))
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
INSERT INTO topicos VALUES (CALENDARIO(
    'Trabalho TBDA' -- titulo
  , TIMESTAMP '2010-10-15 12:30:00' -- alteracao
  , S_CATEGORIA((SELECT REF(cc) FROM categorias cc WHERE cc.nome = 'TBDA')) -- categorias
  , S_TOPICO((SELECT REF(t) FROM topicos t WHERE titulo = 'Tipo'),
             (select ref(t) from topicos t where titulo = 'Maria'))
  , periodo(timestamp '2009-10-30 06:00:00', timestamp '2009-10-30 20:00:00')
  , repeticao('mensal', periodo(timestamp '2010-01-01 06:00:00', timestamp '2010-02-01 20:00:00'))
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
  --dbms_output.put_line('Atividades:');
  FOR i IN atis.FIRST .. atis.LAST LOOP
    imprime_atividade(atis(i));
  END LOOP;
END;

-- Teste impressao
SET serveroutput ON;
DECLARE
  ati ATIVIDADE;
  atis ATIVIDADES;
BEGIN
  ati := ATIVIDADE(1,2);
  atis := ATIVIDADES(ati, ATIVIDADE(3,4));
  imprime_atividades(atis);
END;

-- Exemplo de extracao de timestamps
SET serveroutput ON;
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

-- Teste atividades iguais
SET serveroutput ON;
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
    IF unis.count != 0 THEN
      FOR j IN unis.FIRST .. unis.LAST LOOP
        IF atividades_iguais(atis(i), unis(j)) = 1 THEN
          f := 0;
        END IF;
      END LOOP;
    END IF;
    IF f = 1 THEN
      unis.extend;
      unis(unis.LAST) := atis(i);
    END IF;
  END LOOP;
  RETURN unis;
END;

-- Teste atividades unicas
SET serveroutput ON;
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
SET serveroutput ON;
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
      --TODO: não regorna nada (não adianta recursividade já que o dia é passado
      return conc_atividades(atividades(atividade(timestamp_para_inteiro(p.inicio), 86400)),
                             pegar_atividade(dia, periodo(cast(TO_DATE(nova_data,'YYYY-MM-DD HH24:MI:SS') as timestamp) , p.fim)));
    end if;
  end if;
  return atividades();
END;

create or replace function conc_atividades
  (atis1 atividades, atis2 atividades)
  return atividades
is
  new_atis atividades;
begin
  new_atis := atis1;
  if atis2.count > 0 then
    for i in atis2.first..atis2.last loop
      if atis2.exists(i) then
        new_atis.extend;
        new_atis(new_atis.LAST) := atis2(i);
      END IF;
    end loop;
  end if;
  RETURN new_atis;
END;

create or replace function calcular_tempo
  -- Funciona para periodos dentro do mesmo mês
  (dia integer, ps s_periodo)
  return integer
is
atis atividades;
natis atividades;
att atividade;
tempo numeric;
i integer;
begin
  atis := ATIVIDADES();
  for j in ps.first..ps.last loop
    atis := conc_atividades(atis, pegar_atividade(dia, ps(j)));
  end loop;
  if atis.count < 1 then
    return 0;
  end if;
  i := 1;
  loop
    exit when i > atis.last;
    --dbms_output.put_line('i '||i||' count '||atis(i)(1));
    att := atis(i);
    natis := atis;
--    dbms_output.put_line('debug');
--    imprime_atividades(natis);
    for j in atis.first..atis.last loop    
      if atis(j)(1) < att(1) and atis(j)(2) > att(1) then
        natis := remove_atividade(natis, atis(j));
        natis := conc_atividades(natis, parte_atividade(atis(j), att(1)));
      end if;
      if atis(j)(1) < att(2) and atis(j)(2) > att(2) then
        natis := remove_atividade(natis, atis(j));
        natis := conc_atividades(natis, parte_atividade(atis(j), att(2)));
      end if;
    end loop;
    atis := natis;
    i := i+1;
  end loop;
  
  i := 1;
  loop
    exit when i > atis.last;
    att := atis(i);
    natis := atis;
    for j in atis.first..atis.last loop
      if atis(j)(1) > att(1) and atis(j)(2) < att(2) then
        natis := remove_atividade(natis, atis(j));
      end if;
    end loop;
    atis := atividades_unicas(natis);
    i := i+1;
  end loop;
  --atis := atividades_unicas(atis);
  --imprime_atividades(atis);
  tempo := 0;
  for j in atis.first..atis.last loop
    tempo := tempo + atis(j)(2) - atis(j)(1);
  end loop;
  return tempo;
end;

SET SERVEROUTPUT ON;
DECLARE
  atis atividades;
  ps s_periodo;
begin
  --select t.periodo into ps from topicos t where value(t) is of calendario;
  dbms_output.put_line(calcular_tempo(1, s_periodo(periodo(timestamp '2010-10-01 00:00:02',
                                                           timestamp '2010-10-01 00:00:06'),
                                                  periodo(timestamp '2010-10-01 00:00:07',
                                                           timestamp '2010-10-01 00:00:09'),
                                                  periodo(timestamp '2010-10-01 00:00:01',
                                                           timestamp '2010-10-01 00:00:04'))));
  --dbms_output.put_line(cast(to_date('2010-10-2 00:00:00', 'YYYY-MM-DD HH24:MI:SS') as timestamp));
  --imprime_atividades(pegar_atividade(1, periodo(timestamp '2010-10-01 00:00:01', timestamp '2010-10-02 00:00:01')));
  --atis := atividades(atividade(1,2));
  --imprime_atividades(atis);
  --atis := conc_atividades(atis, ATIVIDADES(ATIVIDADE(3,4)));
  --imprime_atividades(atis);
END;

set serveroutput on;
create or replace function pegar_dia_mais_ocupado
  (mes in integer, ano in integer)
  return integer
is
  ps s_periodo;
  top topico;
  dia integer;
  tempo_max integer;
  data_atual date;
  type slot_mes is varray (31) of integer;
  sm slot_mes;
  cursor cur is
    select value(t) from topicos t where value(t) is of (calendario);
  cal calendario;
  psm s_periodo;
begin
  sm := slot_mes();
  ps := s_periodo();
  open cur;
  loop
    fetch cur into top;
    exit when cur%notfound;
    cal := treat(top as calendario);
    psm := expandir_periodo(cal.p, cal.r);
    for i in psm.first..psm.last loop
      ps := conc_periodos(ps, normalizar_periodo(psm(i)));
    end loop;
    imprime_periodo(ps);
  end loop;
  data_atual := to_date(ano || '-' || mes || '-1','YYYY-MM-DD');
  loop
    exit when mes != extract(month from data_atual);
    dia := extract(day from data_atual);
    sm.extend;
    sm(sm.last) := calcular_tempo(dia, ps);
    data_atual := data_atual + interval '1' day;
  end loop;
  tempo_max := 0;
  for i in sm.first..sm.last loop
    if sm(i) > tempo_max then
      dia := i;
      tempo_max := sm(i);
    end if;
  end loop;
  return dia;
end;

SET SERVEROUTPUT ON;
declare
d timestamp;
atis atividades;
type slot_mes is varray (31) of integer;
sm slot_mes;
begin
  dbms_output.put_line(pegar_dia_mais_ocupado(1, 2010));
  --d := timestamp '2010-10-2 23:00:00';
  --dbms_output.put_line(d + interval '1' day);
end;

create or replace function conc_periodos
  (p1 s_periodo, p2 s_periodo)
  return s_periodo
is
  new_ps s_periodo;
begin
  new_ps := p1;
  if p2.count > 0 then
    for i in p2.first..p2.last loop
      if p2.exists(i) then
        new_ps.extend;
        new_ps(new_ps.LAST) := p2(i);
      END IF;
    end loop;
  end if;
  return new_ps;
END;

create or replace function normalizar_periodo
  (p periodo)
  return s_periodo
is
ano_inicial integer;
ultimo_dia timestamp;
mes_inicial integer;
ultimo_dia_mes timestamp;
dia_inicial integer;
ultima_hora timestamp;
begin
  ano_inicial := extract(year from p.inicio);
  if ano_inicial != extract(year from p.fim) then
    dbms_output.put_line(ano_inicial);
    ultimo_dia := cast(to_date(ano_inicial || '-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS') as timestamp);
    dbms_output.put_line(ano_inicial);
    return conc_periodos(normalizar_periodo(periodo(p.inicio,
                                           ultimo_dia)),
                         normalizar_periodo(periodo(ultimo_dia + interval '1' second,
                                                    p.fim)));
  end if;
  mes_inicial := extract(month from p.inicio);
  if mes_inicial != extract(month from p.fim) then
    ultimo_dia_mes := cast( last_day(to_date(ano_inicial || '-' || mes_inicial || '-3 23:59:59', 'YYYY-MM-DD HH24:MI:SS')) as timestamp);
    return conc_periodos(normalizar_periodo(periodo(p.inicio, ultimo_dia_mes)),
                         normalizar_periodo(periodo(ultimo_dia_mes + interval '1' second,
                                                    p.fim)));
  end if;
  dia_inicial := extract(day from p.inicio);
  if dia_inicial != extract(day from p.fim) then
    ultima_hora := cast(to_date(ano_inicial || '-' || mes_inicial || '-' || dia_inicial || ' 23:59:59', 'YYYY-MM-DD HH24:MI:SS') as timestamp);
    return conc_periodos(s_periodo(periodo(p.inicio, ultima_hora)),
                         normalizar_periodo(periodo(ultima_hora + interval '1' second,
                                                    p.fim)));
  end if;
  return s_periodo(p);
end;

create or replace procedure imprime_periodo
  (p in s_periodo)
is
begin
  for i in p.first..p.last loop
    dbms_output.put_line(p(i).inicio || ', ' || p(i).fim);
  end loop;
end;

create or replace function expandir_periodo
  (p periodo, r repeticao)
  return s_periodo
is
passou integer;
idata timestamp;
fdata timestamp;
interd interval day(1) to second;
interm interval year to month;
ps s_periodo;
begin
  ps := s_periodo(p);
  if r.frequencia = 'diario' then
    interd := interval '1' day;
  elsif r.frequencia = 'semanal' then
    interd := interval '7' day;
  elsif r.frequencia = 'mensal' then
    interm := interval '0-1' year to month;
  elsif r.frequencia = 'anual' then
    interm := interval '1-0' year to month;
  else
    return ps;
  end if;
  idata := p.inicio;
  fdata := p.fim;
  loop
    if interd is null then
      passou := 0;
      begin
        idata := idata + interm;
        passou := 1;
        fdata := fdata + interm;
      exception
        when others then
          if passou = 1 then
            idata := idata + interm;
          else
            idata := idata + 2 * interm;
          end if;
          fdata := fdata + 2 * interm;
      end;
    else
      passou := 0;
      begin
        idata := idata + interd;
        passou := 1;
        fdata := fdata + interd;
      exception
        when others then
          if passou = 1 then
            idata := idata + interd;
          else
            idata := idata + 2 * interd;
          end if;
          fdata := fdata + 2 * interd;
      end;
    end if;
    exit when idata > r.p.fim;
    if idata > r.p.inicio and fdata < r.p.fim then
      ps := conc_periodos(ps, s_periodo(periodo(idata, fdata)));
    end if;
  end loop;
  return ps;
end;

set serveroutput on;
declare
i interval year to month;
begin
  i := interval '0-1' year to month;
  --imprime_periodo(expandir_periodo(periodo(timestamp '2010-10-01 00:01:02',
  --                                           timestamp '2010-10-01 00:03:06'),
  --                                 repeticao('semanal',
  --                                           periodo(timestamp '2009-10-30 00:00:02',
  --                                           timestamp '2011-12-04 00:00:06'))));
  dbms_output.put_line(timestamp'2010-01-31 23:59:59' + i);
  --imprime_periodo(normalizar_periodo(periodo(timestamp '2010-10-01 00:00:02',
  --                                           timestamp '2010-11-01 00:00:06')));
end;