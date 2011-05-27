create or replace
procedure clinica
is
do xmltype;
me xmltype;
re clob;
begin
select xmlagg(xmlelement("medico",
  xmlattributes('m' || medico.codm as codm),
  xmlelement("nome", medico.nome),
  (select xmlagg(xmlelement("agenda",
    xmlelement("dia", agenda.dia),
    xmlelement("hora_inicio", agenda.hora_inicio),
    (select xmlagg(xmlelement("consulta",
      xmlattributes(consulta.situacao, 'd' || consulta.codd as doente),
      xmlelement("hora_inicio", consulta.hora),
      xmlelement("preco", consulta.preco),
      xmlelement("relatorio", consulta.relatorio)))
    from consulta where consulta.nagenda = agenda.nagenda),
    xmlelement("no_doentes", agenda.no_doentes)
  )) from agenda where codm = medico.codm),
  xmlelement("nif", medico.nif),
  xmlelement("morada", medico.morada),
  xmlelement("cod_postal", medico.cod_postal),
  xmlelement("telefone", medico.telefone),
  xmlelement("data_nasce", medico.data_nasce),
  xmlelement("especialidade", medico.especialidade)
))
into me
from medico;

select xmlagg(xmlelement("doente",
  xmlattributes('d' || doente.codd as codd),
  xmlelement("nome", doente.nome),
  xmlelement("nif", doente.nif),
  xmlelement("morada", doente.morada),
  xmlelement("cod_postal", doente.cod_postal),
  xmlelement("telefone", doente.telefone),
  xmlelement("data_nasce", doente.data_nasce),
  xmlelement("profissao", doente.profissao)
))
into do
from doente;

select xmlroot(
  xmlelement("clinica", me, do),
    version '1.0', standalone yes).getclobval()
into re
from dual;

htp.p(re);
end;