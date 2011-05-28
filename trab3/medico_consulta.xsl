<xsl:stylesheet version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

   <xsl:template match="/clinica">
      <html>
         <body>
            <ul>
               <xsl:for-each select="medico">
                  <li>
                     <h3><xsl:value-of select="nome"/></h3>
                     <table border="2">
                        <tr bgcolor="#9acd32">
                           <th>Dia</th>
                           <th>Hora inicio</th>
                           <th>Nome doente</th>
                           <th>Relatório</th>
                        </tr>
                        <xsl:for-each select="agenda">
                           <xsl:for-each select="consulta">
                              <tr>
                                 <xsl:if test="position() = 1">
                                    <td>
                                       <xsl:attribute name="rowspan">
                                          <xsl:value-of select="count(following-sibling::consulta)+1"/>
                                       </xsl:attribute>
                                       <xsl:value-of select="preceding-sibling::dia"/>
                                    </td>
                                 </xsl:if>
                                 <td align="center"><xsl:value-of select="hora_inicio"/></td>
                                 <td>
                                    <xsl:variable name="codd" select="@DOENTE"/>
                                    <xsl:value-of select="/clinica/doente[@CODD=$codd]/nome"/>
                                 </td>
                                 <td><xsl:value-of select="relatorio"/></td>
                              </tr>
                           </xsl:for-each>
                        </xsl:for-each>
                     </table>
                  </li>
               </xsl:for-each>
            </ul>
         </body>
      </html>
   </xsl:template>
</xsl:stylesheet>
