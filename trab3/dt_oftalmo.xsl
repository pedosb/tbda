<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

 <xsl:template match="/clinica">
  <html>
   <body>
    <table border="2" align="center">
     <tr bgcolor="#9acd32">
      <th>Nome</th>
      <th>Data de nascimento</th>
     </tr>
     <xsl:for-each select="medico[especialidade='Oftalmologia']">
      <tr>
       <td><xsl:value-of select="nome"/></td>
       <td align="center"><xsl:value-of select="data_nasce"/></td>
      </tr>
     </xsl:for-each>
    </table>
   </body>
  </html>
 </xsl:template>
</xsl:stylesheet>
