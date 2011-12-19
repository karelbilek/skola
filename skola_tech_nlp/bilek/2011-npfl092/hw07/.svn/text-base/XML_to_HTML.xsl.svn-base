<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="corpus">
    <html>
      <head>SUPERKORPUS</head>
      <body>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="sentence">
    <div class="veta">
        <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="token">
    <span class="token">
        <xsl:value-of select="form"/> 
        <sub>(<xsl:value-of select="lemma"/> / <xsl:value-of select="@pos"/>)</sub>
    </span>
  </xsl:template>

  </xsl:stylesheet>
