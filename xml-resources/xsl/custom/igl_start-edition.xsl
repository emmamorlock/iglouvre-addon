<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="t" version="2.0">
    <xsl:import href="../epidoc/start-edition.xsl"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Sep 9, 2014</xd:p>
            <xd:p><xd:b>Author:</xd:b> Emmanuelle Morlock</xd:p>
            <xd:p>IGLouvre project's stylesheet: Customization of the Epidoc example stylesheets
                (http://epidoc.sourceforge.net/)</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:output method="xml" encoding="UTF-8"/>

    <xsl:include href="igl_global-varsandparams.xsl"/>
    <xsl:include href="igl_custom.xsl"/>
    <xsl:include href="igl_htm-iglouvre-structure.xsl"/>


    <!-- HTML FILE -->

    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$edn-structure = 'iglouvre'">
                <div>
                    <xsl:call-template name="iglouvre-structure">
                        <xsl:with-param name="parm-apparatus-style" select="$apparatus-style"
                            tunnel="yes"/>
                        <xsl:with-param name="parm-edn-structure" select="$edn-structure"
                            tunnel="yes"/>
                        <xsl:with-param name="parm-edition-type" select="$edition-type" tunnel="yes"/>
                        <xsl:with-param name="parm-hgv-gloss" select="$hgv-gloss" tunnel="yes"/>
                        <xsl:with-param name="parm-leiden-style" select="$leiden-style" tunnel="yes"/>
                        <xsl:with-param name="parm-line-inc" select="$line-inc" tunnel="yes"
                            as="xs:double"/>
                        <xsl:with-param name="parm-verse-lines" select="$verse-lines" tunnel="yes"/>
                        <!-- emorlock -->
                        <xsl:with-param name="parm-css-loc" select="$css-loc" tunnel="yes"/>
                        <!-- end -->
                    </xsl:call-template>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-imports/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
