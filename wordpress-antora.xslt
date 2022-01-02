<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
  xmlns:excerpt="http://wordpress.org/export/1.2/excerpt/"
  xmlns:content="http://purl.org/rss/1.0/modules/content/"
  xmlns:wfw="http://wellformedweb.org/CommentAPI/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:wp="http://wordpress.org/export/1.2/"
  xmlns:a="http://drostan.org/wordpress-antora"
  expand-text="yes"
  exclude-result-prefixes="#all">
  
  <xsl:output omit-xml-declaration="true"/>
  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode name="nav" on-no-match="deep-skip"/>
  
  <xsl:import href="lib-wordpress-asciidoc.xslt"/>
 
  <!-- create a file path+name for the item, to go under export/modules/ROOT/pages/ 
    in my case, I have links in the form example.com/2020/12/my-title/
    and I have specified indexify in the playbook,
    so the filename should be generated as 2020/12/my-title.adoc
  -->
  <xsl:function name="a:post_filename">
    <xsl:param name="item"/>
    <xsl:text>{$item/link=>replace('^.*//[^/]+/(.+)/$', '$1')}.adoc</xsl:text>
  </xsl:function>
  
  <xsl:template match="channel">
    <xsl:result-document method="text" href="export/antora.yml">
<xsl:text>name: ROOT
title: {title}
version: ~
nav:
- modules/ROOT/nav.adoc
asciidoc:
  attributes:
    page-wp-export-date: '{pubDate}'
</xsl:text>
    </xsl:result-document>
    
    <xsl:result-document method="text" href="playbook-wordpress-export.yml">
<xsl:text>site:
  title: {title}
  url: {link}
  
urls:
  html_extension_style: indexify

output:
  clean: true

content:
  sources:
  - url: .
    start_paths: 
    - export/
    - docs/
  
ui:
  bundle:
    url: https://gitlab.com/antora/antora-ui-default/-/jobs/artifacts/HEAD/raw/build/ui-bundle.zip?job=bundle-stable
    snapshot: true
  supplemental_files: supplemental-ui
  
antora:
  extensions:
  - require: '@antora/lunr-extension'
  
asciidoc:
  attributes:
    page-pagination: true
    hide-uri-scheme@: true
    experimental: true
</xsl:text>
    </xsl:result-document>
    
    <xsl:apply-templates/>
    
    <xsl:result-document format="adoc" href="export/modules/ROOT/nav.adoc">
      <xsl:apply-templates mode="nav">
        <xsl:sort select="link"/>
      </xsl:apply-templates>
    </xsl:result-document>

    <xsl:result-document format="adoc" href="export/modules/ROOT/pages/index.adoc">= Wordpress export to Antora

include::wordpress-antora::partial$blog-index-page-hints.adoc[]
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="item[wp:post_type='post' and wp:status='publish']" mode="nav">
    <xsl:text>*** xref:{a:post_filename(.)}[]&#xA;</xsl:text>
  </xsl:template>
    
  <xsl:template match="item[wp:post_type='post' and wp:status='publish']">
    <xsl:result-document format="adoc" 
      href="export/modules/ROOT/pages/{a:post_filename(.)}">= {title}
<xsl:if test="dc:creator!=''">{dc:creator}
</xsl:if>:page-wp-post_id: {wp:post_id}
:page-wp-link: {link}
:page-date: {wp:post_date}
:keywords: {string-join(category, ', ')}

<xsl:try>
  <xsl:sequence>
    <xsl:apply-templates select="parse-xml(a:html_content(content:encoded))" mode="wordpress-asciidoc"/>
    <xsl:message>Processed: {link}</xsl:message>
  </xsl:sequence>
  <xsl:catch>
    <xsl:message>Cannot parse, included verbatim: {link}</xsl:message>
CAUTION:: unable to process content, source included verbatim

++++
{content:encoded}
++++
  </xsl:catch>
</xsl:try>
    </xsl:result-document>
    
    <xsl:result-document method="xml" href="export/modules/ROOT/pages/{a:post_filename(.)}.xml">
      <xsl:try>
        <xsl:sequence select="parse-xml(a:html_content(content:encoded))/body"/>
        <xsl:catch>
          <xsl:text>Cannot parse: {link}</xsl:text>
        </xsl:catch>
      </xsl:try>
    </xsl:result-document>
  </xsl:template>
</xsl:stylesheet>
