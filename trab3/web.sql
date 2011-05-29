create table medico as select * from gtd2.medico;
create table doente as select * from gtd2.doente;
create table agenda as select * from gtd2.agenda;
create table consulta as select * from gtd2.consulta;

select xmlelement("clinica", xmlelement("medico", xmlattributes(medico.codm as codm),
              xmlelement("nome", null, medico.nome),
              xmlelement("especialidade", null, medico.especialidade)))
from medico
inner join agenda on
agenda.codm = medico.codm;

create or replace
procedure clinica
is
do xmltype;
me xmltype;
re clob;
begin
select xmlagg(xmlelement("medico", xmlattributes(medico.codm),
  (select xmlagg(xmlelement("agenda",
  xmlelement("hora_inicio", null, hora_inicio),
      (select xmlagg(xmlelement("consulta",
      xmlelement("preco", null, consulta.preco)))
      from consulta where consulta.nagenda = agenda.nagenda)
  )) from agenda where codm = medico.codm)))
into me
from medico;

select xmlagg(xmlelement("doente", xmlelement("nome", null, doente.nome)))
into do
from doente;
select xmlelement("nome", do, me).getclobval() into re from dual;
htp.p(re);
end;

SELECT XMLConcat(XMLSequenceType(
                   XMLType('<PartNo>1236</PartNo>'), 
                   XMLType('<PartName>Widget</PartName>'),
                   XMLType('<PartPrice>29.99</PartPrice>'))).getClobVal()
  as "RESULT"
  from dual;
  
select * from dummy;

select xmlelement("clinica",
xmlagg(xmlelement("medico", xmlattributes(medico.codm),
  (select xmlagg(xmlelement("agenda",
  xmlelement("hora_inicio", null, hora_inicio),
      (select xmlagg(xmlelement("consulta",
      xmlelement("preco", null, consulta.preco)))
      from consulta where consulta.nagenda = agenda.nagenda)
  )) from agenda where codm = medico.codm))) as clinica,
  xmlagg(
  (select xmlagg(xmlelement("nome", null, doente.nome)) from doente)
  )
  )
from medico;

  (select (xmlagg(xmlelement("doente", xmlattributes(doente.codd),
  xmlelement("nome", null, doente.nome)))) from doente))

select xmlelement("medico", xmlelement("medico", xmlattributes(medico.codm),
  (select xmlagg(xmlelement("agenda",
  xmlelement("hora_inicio", null, hora_inicio),
      (select xmlagg(xmlelement("consulta",
      xmlelement("preco", null, consulta.preco)))
      from consulta where consulta.nagenda = agenda.nagenda)
  )) from agenda where codm = medico.codm)),
  (select xmlagg(xmlelement(nome, null, cliente.nome)) from cliente)
  )
from medico;

select xmlelement("medico", xmlattributes(medico.codm),
  (select xmlagg(xmlelement("agenda",
  xmlelement("hora_inicio", null, hora_inicio)
  )) from agenda)
  )
from medico;

select * from doente;

select xmlelement("nome",
  xmlelement("medico", null, nome),
  (select (xmlelement("medico", null, nome)) from cliente)
  )
from medico;

select xmlelement("clinica",
xmlagg(xmlelement("medico", xmlattributes(medico.codm),
  (select xmlagg(xmlelement("agenda",
  xmlelement("hora_inicio", null, hora_inicio),
      (select xmlagg(xmlelement("consulta",
      xmlelement("preco", null, consulta.preco)))
      from consulta where consulta.nagenda = agenda.nagenda)
  )) from agenda where codm = medico.codm))) as clinica,
  (select (xmlagg(xmlelement("cliente", xmlattributes(cliente.codc),
  xmlelement("nome", null, cliente.nome)))) from cliente))
from medico;

select * from medico;

SELECT XMLAgg(XMLElement("Dev", 
                         XMLAttributes(dev AS "id", dev_total AS "total"),
                         devname) 
              order by dev) 
  FROM tab1 dev_total;