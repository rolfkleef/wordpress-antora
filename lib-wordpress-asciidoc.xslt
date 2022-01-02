<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
  xmlns:a="http://drostan.org/wordpress-antora"
  expand-text="yes">

  <!-- Transform an input string into a more XML-ish snippet for fn:parse-xml():
    * Enclose in <body>...</body>
    * Replace some HTML entities into XML equivalents
  -->
  <xsl:function name="a:html_content">
    <xsl:param name="input"/>
    {'&lt;body&gt;' || $input
    =>replace('&amp;nbsp;', '&#160;')
    =>replace('&amp;ldquo;', '&#8220;')
    =>replace('&amp;rdquo;', '&#8221;')
    =>replace('&amp;', '&amp;amp;')
    || '&lt;/body&gt;'}
  </xsl:function>

  <xsl:mode name="wordpress-asciidoc" on-no-match="shallow-copy"/>

  <xsl:template mode="wordpress-asciidoc" match="body">
    <xsl:apply-templates mode="html-asciidoc"/>
  </xsl:template>

  <xsl:template mode="wordpress-asciidoc" match="a">
    <xsl:text>{@href}[{text()}]</xsl:text>
  </xsl:template>
</xsl:stylesheet>
