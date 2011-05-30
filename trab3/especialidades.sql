
CREATE OR REPLACE PROCEDURE especialidades
  (dia CLOB, mes CLOB, ano CLOB)
IS
  v_sqlselect      VARCHAR2(4000);
  v_queryctx       DBMS_XMLQuery.ctxType;
  v_clob_par       CLOB;
  
BEGIN               
  v_sqlselect := 'SELECT DISTINCT  m.especialidade
                  FROM agenda a
                  INNER JOIN medico m
                  ON a.codm = m.codm
                  WHERE a.dia = DATE ''' || 
                  ano || '-' || mes || '-' || dia ||
                  ''' ORDER BY a.dia';
                  
   v_queryctx := DBMS_XMLQuery.newContext(v_sqlselect);

   dbms_xmlquery.setencodingtag(v_queryctx, 'ISO-8859-1');
   dbms_xmlquery.setstylesheetheader(v_queryctx, 'especialidades_xsl', 'text/xsl');
   --dbms_xmlquery.setxslt(v_queryctx, 'http://oraalu.fe.up.pt:7777/pls/especialidades_xsl');
   v_clob_par := DBMS_XMLQuery.getXML(v_queryctx);
   DBMS_XMLQuery.closeContext(v_queryctx);
   htp.p(v_clob_par);
EXCEPTION
  WHEN OTHERS THEN
    htp.p(SQLERRM);
END;
  
