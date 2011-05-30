create or replace procedure especialidades_xsl
is
begin
htp.p('<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

 <xsl:template match="/ROWSET">
  <html>
   <body>
    <ul>
     <xsl:for-each select="ROW">
      <li><xsl:value-of select="ESPECIALIDADE"/></li>
     </xsl:for-each>
    </ul>
   </body>
  </html>
 </xsl:template>
</xsl:stylesheet>');
end;