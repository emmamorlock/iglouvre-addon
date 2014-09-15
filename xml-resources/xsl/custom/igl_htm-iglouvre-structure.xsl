<?xml version="1.0" encoding="UTF-8"?>
<!--  -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:t="http://www.tei-c.org/ns/1.0"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   exclude-result-prefixes="t" version="2.0">

   <xsl:output method="xml" encoding="UTF-8"/>
   <!--
   -->
    <!--Create a key that indexes the msItem nodes by their @corresp attribute-->
    <xsl:key name="NUMTEXT" match="t:msItem" use="concat('#',@xml:id)"/>
    <!--Create a key that indexes the div texpart nodes by their @corresp attribute-->
    <xsl:key name="DIVLOC" match="t:div[@type= 'textpart']" use="descendant-or-self::t:milestone/@corresp"/>
    <!-- 
   -->
    <xsl:template name="iglouvre-structure">
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="//t:titleStmt/t:title/text()">
                    <xsl:if test="//t:publicationStmt/t:idno[@type='filename']/text()">
                        <xsl:value-of select="substring(//t:publicationStmt/t:idno[@type='filename'],5)"/>
                        <xsl:text>. </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="//t:titleStmt/t:title"/>
                </xsl:when>
                <xsl:when test="//t:sourceDesc//t:bibl/text()">
                    <xsl:value-of select="//t:sourceDesc//t:bibl"/>
                </xsl:when>
                <xsl:when test="//t:idno[@type='filename']/text()">
                    <xsl:value-of select="//t:idno[@type='filename']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>EpiDoc example output, Iglouvre style</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <html>
            <head>
                <title>
                    <xsl:value-of select="$title"/>
                </title>
                <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
                <!-- Found in htm-tpl-cssandscripts.xsl -->
                <xsl:call-template name="css-script"/>
            </head>
            <body>
                <h1>
                    <xsl:value-of select="$title"/>
                </h1>
                <p>header : <xsl:apply-templates select="t:teiHeader"/></p>
                <p>Editeur scientifique : <xsl:for-each select="//t:titleStmt/t:respStmt[t:resp ='Editeur scientifique']">
                    <xsl:apply-templates select="t:persName"/>
                </xsl:for-each></p>
                <p>infos projet : <xsl:apply-templates select="t:publicationStmt"/></p>
                <div>
                    <h2>Lemme</h2>
                    <h3>Description :</h3>
                    <xsl:if test="//t:msName">
                        <p>
                            <xsl:text>[msName] : </xsl:text>
                            <xsl:apply-templates select="//t:msName"/>
                            <xsl:text>.</xsl:text>
                        </p>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="//t:support/t:p/text()">
                            <xsl:text>[support/p] : </xsl:text>
                            <xsl:apply-templates select="//t:support/t:p" mode="inslib-dimensions"/>
                        </xsl:when>
                        <xsl:otherwise>Unknown</xsl:otherwise>
                    </xsl:choose>
                    <h3>Champ épigraphique : </h3>
                    <p>
                        <xsl:choose>
                            <xsl:when test="//t:layoutDesc/t:layout//text()">
                                <xsl:value-of select="//t:layoutDesc/t:layout"/>
                            </xsl:when>
                            <xsl:otherwise>Unknown.</xsl:otherwise>
                        </xsl:choose>
                    </p>
                    <h3>Lettres : </h3>
                    <ul>
                        <xsl:for-each select="//t:handDesc/t:handNote">
                            <li>
                                <xsl:if test="@corresp">
                                    <xsl:call-template name="iglouvre-handNote-link"/>
                                    <xsl:text> : </xsl:text>
                                </xsl:if>
                                <xsl:apply-templates select="."/>
                            </li>
                        </xsl:for-each>
                    </ul>
                    <!-- 
               <h3>Date : </h3>
               <p>
                  <xsl:choose>
                     <xsl:when test="//t:origin/t:origDate/text()">
                        <xsl:value-of select="//t:origin/t:origDate"/>
                        <xsl:if test="//t:origin/t:origDate[@type='evidence']">
                           <xsl:text>(</xsl:text>
                           <xsl:for-each select="tokenize(//t:origin/t:origDate[@evidence],' ')">
                              <xsl:value-of select="translate(.,'-',' ')"/>
                              <xsl:if test="position()!=last()">
                                 <xsl:text>, </xsl:text>
                              </xsl:if>
                           </xsl:for-each>
                           <xsl:text>)</xsl:text>
                        </xsl:if>
                     </xsl:when>
                     <xsl:otherwise>Unknown.</xsl:otherwise>
                  </xsl:choose>
               </p>
                -->
                    <h3>Lieu de découverte : </h3>
                    <p>
                        <xsl:choose>
                            <xsl:when test="//t:provenance[@type='found'][string(translate(normalize-space(.),' ',''))]">
                                <xsl:apply-templates select="//t:provenance[@type='found']" mode="inslib-placename"/>
                            </xsl:when>
                            <xsl:otherwise>Unknown</xsl:otherwise>
                        </xsl:choose>
                    </p>
                    <h3>Lieu d'origine : </h3>
                    <p>
                        <xsl:choose>
                            <xsl:when test="//t:origin/t:origPlace/text()">
                                <xsl:apply-templates select="//t:origin/t:origPlace" mode="inslib-placename"/>
                            </xsl:when>
                            <xsl:otherwise>Unknown</xsl:otherwise>
                        </xsl:choose>
                    </p>
                    <h3>Lieu de conservation : </h3>
                    <p>
                        <xsl:choose>
                            <xsl:when test="//t:provenance[@type='observed'][string(translate(normalize-space(.),' ',''))]">
                                <xsl:apply-templates select="//t:provenance[@type='observed']" mode="inslib-placename"/>
                                <!-- Named template found below. -->
                                <xsl:call-template name="iglouvre-invno"/>
                            </xsl:when>
                            <xsl:when test="//t:msIdentifier//t:repository[string(translate(normalize-space(.),' ',''))]">
                                <xsl:value-of select="//t:msIdentifier//t:repository[1]"/>
                                <!-- Named template found below. -->
                                <xsl:call-template name="iglouvre-invno"/>
                            </xsl:when>
                            <xsl:otherwise>Unknown</xsl:otherwise>
                        </xsl:choose>
                    </p>
                </div>
                <div id="edition">
                    <h2>Edition :</h2>
                    <!-- Edited text output -->
                    <xsl:variable name="edtxt">
                        <xsl:apply-templates select="//t:div[@type='edition']"/>
                    </xsl:variable>
                    <!-- Moded templates found in htm-tpl-sqbrackets.xsl -->
                    <xsl:apply-templates select="$edtxt" mode="sqbrackets"/>
                </div>
                <div id="apparatus">
                    <!-- Apparatus text output -->
                    <h2>Apparat critique</h2>
                    <xsl:variable name="apptxt">
                        <xsl:apply-templates select="//t:div[@type='apparatus']"/>
                    </xsl:variable>
                    <!-- Moded templates found in htm-tpl-sqbrackets.xsl -->
                    <xsl:apply-templates select="$apptxt" mode="sqbrackets"/>
                </div>
                <div id="translation">
                    <h2>Traduction</h2>
                    <!-- Translation text output -->
                    <xsl:variable name="transtxt">
                        <xsl:apply-templates select="//t:div[@type='translation']//t:p"/>
                    </xsl:variable>
                    <!-- Moded templates found in htm-tpl-sqbrackets.xsl -->
                    <xsl:apply-templates select="$transtxt" mode="sqbrackets"/>
                </div>
                <div id="commentary">
                    <h2>Commentaire </h2>
                    <!-- Commentary text output -->
                    <xsl:variable name="commtxt">
                        <xsl:apply-templates select="//t:div[@type='commentary']//t:p"/>
                    </xsl:variable>
                    <!-- Moded templates found in htm-tpl-sqbrackets.xsl -->
                    <xsl:apply-templates select="$commtxt" mode="sqbrackets"/>
                </div>
                <div id="bibliography">
                    <h2>Bibliographie</h2>
                    <!-- <xsl:apply-templates select="//t:div[@type='bibliography']/t:p/node()"/> -->
                    <xsl:apply-templates select="//t:div[@type='bibliography']"/>
                    <hr/>
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="t:dimensions" mode="inslib-dimensions" priority="1">
        <xsl:if test="text()">
            <xsl:if test="t:width/text()">w: <xsl:value-of select="t:width"/>
                <xsl:if test="t:height/text()">
                    <xsl:text> x </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:if test="t:height/text()">h: <xsl:value-of select="t:height"/>
            </xsl:if>
            <xsl:if test="t:depth/text()"> x d: <xsl:value-of select="t:depth"/>
            </xsl:if>
            <xsl:if test="t:dim[@type='diameter']/text()"> x diam.: <xsl:value-of select="t:dim[@type='diameter']"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:placeName|t:rs" mode="inslib-placename" priority="100">
        <xsl:choose>
            <xsl:when test="contains(@ref,'pleiades.stoa.org') or contains(@ref,'geonames.org')">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="@ref"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="iglouvre-invno">
        <xsl:if test="//t:idno[@type='invNo'][string(translate(normalize-space(.),' ',''))]">
            <xsl:text> (</xsl:text>
            <xsl:for-each select="//t:idno[@type='invNo'][string(translate(normalize-space(.),' ',''))]">
                <xsl:value-of select="."/>
                <xsl:if test="position()!=last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template name="iglouvre-handNote-link">
        <xsl:variable name="n">
            <xsl:value-of select="key('NUMTEXT',@corresp)/@n"/>
        </xsl:variable>
        <xsl:variable name="div-loc">
            <xsl:value-of select="key('DIVLOC',@corresp)/@n"/>
        </xsl:variable>
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="concat('#',$div-loc,'-',$n)"/>
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:value-of select="key('NUMTEXT',@corresp)/t:title"/>
            </xsl:attribute>
            <xsl:value-of select="$n"/>
        </a>
    </xsl:template>


</xsl:stylesheet>
