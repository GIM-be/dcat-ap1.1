<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:spdx="http://spdx.org/rdf/terms#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:adms="http://www.w3.org/ns/adms#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:schema="http://schema.org/"
                xmlns:locn="http://www.w3.org/ns/locn#"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-dcat-ap="http://geonetwork-opensource.org/xsl/functions/profiles/dcat-ap"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:java="java:org.fao.geonet.util.XslUtil"
                extension-element-prefixes="saxon"
                version="2.0"
                exclude-result-prefixes="#all">
  <!-- Tell the XSL processor to output XML. -->
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:output name="default-serialize-mode" indent="no"
              omit-xml-declaration="yes"/>
  <!-- =================================================================   -->
  <xsl:include href="layout/utility-fn.xsl"/>
  <xsl:variable name="serviceUrl" select="/root/env/siteURL"/>
  <xsl:variable name="env" select="/root/env"/>
  <xsl:variable name="iso2letterLanguageCode" select="lower-case(java:twoCharLangCode(/root/gui/language))"/>
  <xsl:variable name="port">
    <xsl:choose>
      <xsl:when test="$env/system/server/protocol = 'https'">
        <xsl:value-of select="$env/system/server/securePort"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$env/system/server/port"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="resourcePrefix" select="$env/metadata/resourceIdentifierPrefix"/>
  <xsl:variable name="url"
                select="concat($env/system/server/protocol, '://',
                          $env/system/server/host,
                          if ($port='80') then '' else concat(':', $port),
                          /root/gui/url)"/>

  <xsl:template match="/root">
    <xsl:apply-templates select="//rdf:RDF"/>
  </xsl:template>
  <!-- =================================================================  -->
  <xsl:template match="@*|node()[name(.)!= 'root']">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  <!-- ================================================================= -->
  <xsl:template match="dcat:Catalog" priority="10">
    <dcat:Catalog>
      <xsl:choose>
        <xsl:when test="not(@rdf:about) or @rdf:about=''">
          <xsl:attribute name="rdf:about">
            <xsl:value-of select="concat($resourcePrefix,'/catalogs/',$env/system/site/siteId)"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="@*"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when
          test="(not(dct:title) or dct:title='') and (not(dct:description) or dct:description='') and not(foaf:homepage)">
          <dct:title xml:lang="{$iso2letterLanguageCode}">
            <xsl:value-of select="$env/system/site/name"/>
          </dct:title>
          <dct:description xml:lang="{$iso2letterLanguageCode}">
            <xsl:value-of select="$env/system/site/name"/>(<xsl:value-of select="$env/system/site/organization"/>)
          </dct:description>
          <dct:publisher>
            <foaf:Agent rdf:about="{$resourcePrefix}/organizations/{encode-for-uri($env/system/site/organization)}">
              <foaf:name xml:lang="{$iso2letterLanguageCode}">
                <xsl:value-of select="$env/system/site/organization"></xsl:value-of>
              </foaf:name>
            </foaf:Agent>
          </dct:publisher>
          <foaf:homepage>
            <foaf:Document rdf:about="{$url}">
              <foaf:name xml:lang="{$iso2letterLanguageCode}">
                <xsl:value-of select="$env/system/site/name"/>
              </foaf:name>
            </foaf:Document>
          </foaf:homepage>
          <xsl:for-each select="/root/gui/thesaurus/thesauri/thesaurus">
            <dcat:themeTaxonomy>
              <skos:ConceptScheme rdf:about="{$resourcePrefix}/registries/vocabularies/{key}">
                <dct:title xml:lang="{$iso2letterLanguageCode}">
                  <xsl:value-of select="title"/>
                </dct:title>
                <foaf:isPrimaryTopicOf><xsl:value-of select="$url"/>/srv/eng/thesaurus.download?ref=<xsl:value-of
                  select="key"/>
                </foaf:isPrimaryTopicOf>
              </skos:ConceptScheme>
            </dcat:themeTaxonomy>
          </xsl:for-each>

          <xsl:apply-templates
            select="node()[not(name(.) = 'dct:title' or name(.) = 'dct:description' or name(.) = 'foaf:homepage' or name(.) = 'dct:publisher' or name(.) = 'dcat:themeTaxonomy')]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates
            select="node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </dcat:Catalog>
  </xsl:template>
  <!-- ================================================================= -->
  <xsl:template match="dcat:Dataset" priority="10">
    <dcat:Dataset>
      <xsl:apply-templates select="@*[not(name(.) = 'rdf:about')]"/>
      <xsl:variable name="rdfAbout"
                    select="replace(@rdf:about,'([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}){1}',/root/env/uuid)"/>
      <xsl:attribute name="rdf:about" select="$rdfAbout"/>
      <dct:identifier>
        <xsl:value-of select="/root/env/uuid"/>
      </dct:identifier>
      <!--
            When duplicate, do not copy any dct:identifier otherwise copy all dct:identifier elements except the first.
            We could use position() to check the position of the next dct:identifier elements,
            but when schema change and dct:identifier is not the first element in the dcat:Dataset sequence anymore,
            the next will continue to work.
          -->
      <xsl:if test="/root/env/id!=''">
        <xsl:for-each select="dct:identifier">
          <xsl:variable name="previousIdentifierSiblingsCount"
                        select="count(preceding-sibling::*[name(.) = 'dct:identifier'])"/>
          <xsl:if test="$previousIdentifierSiblingsCount>0">
            <xsl:apply-templates select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
      <xsl:apply-templates select="node()[not(name(.) = 'dct:identifier')]"/>
    </dcat:Dataset>
  </xsl:template>

  <xsl:template match="dcat:Dataset/dct:title" priority="10">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="/root/env/id!=''">
        <xsl:value-of select="."/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Fill empty element and update existing with resourceType -->
  <xsl:template
    match="foaf:Agent/dct:type|dcat:theme|dct:accrualPeriodicity|dct:language|dcat:Dataset/dct:type|dct:format|dcat:mediaType|adms:status|dct:LicenseDocument/dct:type|dct:accessRights"
    priority="10">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="inScheme" select="gn-fn-dcat-ap:getInSchemeURIByElementName(name(.),name(..))"/>
      <xsl:variable name="rdfType" select="gn-fn-dcat-ap:getRdfTypeByElementName(name(.),name(..))"/>
      <xsl:choose>
        <xsl:when test="count(*)=0 or count(skos:Concept/*[name(.)='skos:prefLabel'])=0">
          <skos:Concept>
            <xsl:if test="$rdfType!=''">
              <rdf:type rdf:resource="{$rdfType}"/>
            </xsl:if>
            <skos:prefLabel xml:lang="nl"/>
            <skos:prefLabel xml:lang="en"/>
            <skos:prefLabel xml:lang="fr"/>
            <skos:prefLabel xml:lang="de"/>
            <skos:inScheme rdf:resource="{$inScheme}"/>
          </skos:Concept>
        </xsl:when>
        <xsl:otherwise>

          <!-- remove rdf:about attribute if empty -->
          <xsl:choose>
            <xsl:when test="normalize-space(skos:Concept/@rdf:about) = ''">
              <skos:Concept>
                <xsl:if test="$rdfType!=''">
                  <rdf:type rdf:resource="{$rdfType}"/>
                </xsl:if>
                <xsl:for-each select="skos:Concept/*[name(.)='skos:prefLabel']">
                  <xsl:copy-of select="."/>
                </xsl:for-each>
                <skos:inScheme rdf:resource="{$inScheme}"/>
              </skos:Concept>
            </xsl:when>
            <xsl:otherwise>
              <skos:Concept rdf:about="{skos:Concept/@rdf:about}">
                <xsl:if test="$rdfType!=''">
                  <rdf:type rdf:resource="{$rdfType}"/>
                </xsl:if>
                <xsl:for-each select="skos:Concept/*[name(.)='skos:prefLabel']">
                  <xsl:copy-of select="."/>
                </xsl:for-each>
                <skos:inScheme rdf:resource="{$inScheme}"/>
              </skos:Concept>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!-- Fix value for attribute -->
  <xsl:template match="rdf:Statement/rdf:object" priority="10">
    <xsl:copy>
      <xsl:copy-of select="@*[not(name()='rdf:datatype')]"/>
      <xsl:attribute name="rdf:datatype">xs:dateTime</xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <!-- Fix value for attribute -->
  <xsl:template match="dct:issued|dct:modified|schema:startDate|schema:endDate" priority="10">
    <xsl:copy>
      <xsl:copy-of select="@*[not(name()='rdf:datatype')]"/>
      <xsl:attribute name="rdf:datatype">
        <xsl:if test="not(contains(lower-case(.),'t'))">http://www.w3.org/2001/XMLSchema#date</xsl:if>
        <xsl:if test="contains(lower-case(.),'t')">http://www.w3.org/2001/XMLSchema#dateTime</xsl:if>
      </xsl:attribute>
      <xsl:value-of select="."/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="dct:Location" priority="10">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="coverage">
        <xsl:choose>
          <xsl:when test="count(locn:geometry[ends-with(@rdf:datatype,'#wktLiteral')])>0">
            <xsl:value-of select="locn:geometry[ends-with(@rdf:datatype,'#wktLiteral')][1]"/>
          </xsl:when>
          <xsl:when test="count(locn:geometry[ends-with(@rdf:datatype,'#gmlLiteral')])>0">
            <xsl:value-of select="locn:geometry[ends-with(@rdf:datatype,'#gmlLiteral')][1]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="locn:geometry[1]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="n" select="substring-after($coverage,'North ')"/>
      <xsl:if test="string-length($n)=0">
        <xsl:copy-of select="node()"/>
      </xsl:if>
      <xsl:if test="string-length($n)>0">
        <xsl:variable name="north" select="substring-before($n,',')"/>
        <xsl:variable name="s" select="substring-after($coverage,'South ')"/>
        <xsl:variable name="south" select="substring-before($s,',')"/>
        <xsl:variable name="e" select="substring-after($coverage,'East ')"/>
        <xsl:variable name="east" select="substring-before($e,',')"/>
        <xsl:variable name="w" select="substring-after($coverage,'West ')"/>
        <xsl:variable name="west" select="if (contains($w, '. '))
		                                      then substring-before($w,'. ') else $w"/>
        <xsl:variable name="place" select="substring-after($coverage,'. ')"/>
        <xsl:variable name="isValid" select="number($west) and number($east) and number($south) and number($north)"/>
        <xsl:if test="$isValid">
          <xsl:variable name="wktLiteral"
                        select="concat('POLYGON ((',$west,' ',$south,',',$west,' ',$north,',',$east,' ',$north,',', $east,' ', $south,',', $west,' ',$south,'))')"/>
          <xsl:variable name="gmlLiteral"
                        select="concat('&lt;gml:Polygon&gt;&lt;gml:exterior&gt;&lt;gml:LinearRing&gt;&lt;gml:posList&gt;',$south,' ',$west,' ',$north,' ', $west, ' ', $north, ' ', $east, ' ', $south, ' ', $east,' ', $south, ' ', $west, '&lt;/gml:posList&gt;&lt;/gml:LinearRing&gt;&lt;/gml:exterior&gt;&lt;/gml:Polygon&gt;')"/>
          <xsl:element name="locn:geometry">
            <xsl:attribute name="rdf:datatype">http://www.opengis.net/ont/geosparql#wktLiteral</xsl:attribute>
            <xsl:value-of select="$wktLiteral"/>
          </xsl:element>
          <xsl:element name="locn:geometry">
            <xsl:attribute name="rdf:datatype">http://www.opengis.net/ont/geosparql#gmlLiteral</xsl:attribute>
            <xsl:value-of select="$gmlLiteral"/>
          </xsl:element>
        </xsl:if>
        <xsl:if test="not($isValid)">
          <xsl:element name="locn:geometry">
            <xsl:attribute name="rdf:datatype">http://www.opengis.net/ont/geosparql#wktLiteral</xsl:attribute>
          </xsl:element>
          <xsl:element name="locn:geometry">
            <xsl:attribute name="rdf:datatype">http://www.opengis.net/ont/geosparql#gmlLiteral</xsl:attribute>
          </xsl:element>
        </xsl:if>
        <xsl:apply-templates select="node()[not(name(.) = 'locn:geometry')]"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Ignore all empty rdf:about -->
  <xsl:template match="@rdf:about[normalize-space() = '']|@rdf:datatype[normalize-space() = '']" priority="10"/>

  <!-- Remove non numeric byteSize and format scientific notation to decimal -->
  <xsl:template match="dcat:byteSize" priority="10">
    <xsl:if test="string(number(.)) != 'NaN'">
      <xsl:copy>
        <xsl:choose>
          <xsl:when test="matches(string(.), '^\-?[\d\.,]*[Ee][+\-]*\d*$')">
            <xsl:value-of select="format-number(number(.), '#0.#############')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
