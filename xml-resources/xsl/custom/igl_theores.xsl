<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xsl tei html">
    <xsl:key name="BLOCS" match="//tei:sourceDoc//tei:surface" use="concat('#',@xml:id)"/>
    <xsl:key name="BLOC-ZONE" match="//tei:sourceDoc//tei:surface" use="tei:zone/@xml:id"/>
    <xsl:key name="ZONE" match="//tei:sourceDoc//tei:zone" use="concat('#',@xml:id)"/>
    <xsl:key name="LINE" match="//tei:sourceDoc//tei:line" use="@n"/>
    <!--Create a key that indexes the handNote nodes by their @corresp attribute-->
    <xsl:key name="HANDS" match="//tei:msDesc//tei:physDesc//tei:handNote" use="concat('#',@xml:id)"/>
    <xsl:key name="OBJECTS" match="//tei:msPart" use="concat('#',@xml:id)"/>

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>


    <xsl:template match="tei:*">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:attribute name="{local-name()}">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="@*" mode="sourceDoc2text">
        <xsl:attribute name="{local-name()}">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="tei:TEI">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title>
                    <xsl:value-of select="//tei:titleStmt/tei:title"/>
                </title>
                <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
                <link rel="stylesheet" type="text/css" media="screen, projection" href="igl_theores.css"
                />
            </head>
            <xsl:apply-templates/>
        </html>
    </xsl:template>

    <xsl:template
        match="//tei:teiHeader|tei:facsimile|tei:sourceDoc|tei:div[not(@type='edition'or @type='textpart')]|tei:back"/>


    <xsl:template match="tei:text">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:div[@type='edition']|tei:div[@type='textpart']">
        <div>
            <xsl:attribute name="class">
                <xsl:text>clearfix </xsl:text>
                <xsl:apply-templates select="@type"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- <xsl:template match="tei:ab">
        <div class="{local-name()}">
            <xsl:apply-templates/>
        </div>
    </xsl:template> -->

    <xsl:template match="tei:list//tei:head">
        <!-- do not display head inside list -->
    </xsl:template>

    <xsl:template match="tei:list">
        <xsl:if test="tei:head">
            <h2>
                <xsl:value-of select="."/>
            </h2>
        </xsl:if>
        <ul>
            <!-- <xsl:apply-templates select="*[not(local-name()='head')]"/> -->
            <xsl:call-template name="makeCbs">
                <xsl:with-param name="content">
                    <xsl:sequence select="."/>
                </xsl:with-param>
            </xsl:call-template>
        </ul>
        <hr/>
    </xsl:template>
    
    <xsl:template match="tei:list[@type='prosopography']">
        <xsl:if test="tei:head">
            <h2>
                <xsl:value-of select="."/>
            </h2>
        </xsl:if>
        <ul>
            <xsl:apply-templates mode="prosopography"></xsl:apply-templates>
        </ul>
        
    </xsl:template>
    
    <xsl:template name="makeCbs">
        <xsl:param name="content"/>
        <xsl:choose>
            <xsl:when test="tei:cb">
                <xsl:for-each-group select="node()" group-starting-with="tei:cb">
                    <!-- Copies the only lb in the group first (N.B the first group does not contain lb) -->
                    <xsl:apply-templates select="current-group()/self::tei:cb"/>
                    <span class="cb">
                        <!-- <xsl:apply-templates select="current()/ancestor::tei:*[1]/@*"/> -->
                        <!-- Copies the elements in the group except lb -->
                        <xsl:apply-templates select="current-group()[not(self::tei:cb)]"/>
                    </span>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <span class="unecolonne">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:item">
        <xsl:choose>
            <xsl:when test="tei:ptr">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="tei:join">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <li>
                    <xsl:apply-templates/>
                </li>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="tei:ab">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:ptr">
        <xsl:variable name="key" select="key('ZONE',@target)"/>
        <xsl:variable name="key2" select="key('BLOC-ZONE',substring-after(@target,'#'))"/>
        <xsl:variable name="objectID" select="$key2//@corresp"/>
        <xsl:variable name="color" select="key('OBJECTS',$objectID)//tei:support/tei:p/@rend"/>
        <xsl:for-each select="$key//tei:line">
            <li class="{$color}">
                <xsl:apply-templates/>
            </li>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="tei:seg">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="tei:line">
        <xsl:value-of select="."/>
    </xsl:template>



    <!-- cf. syd bauman *
        https://listserv.brown.edu/archives/cgi-bin/wa?A2=ind1305&L=TEI-L&D=0&1=TEI-L&9=A&I=-3&J=on&d=No+Match%3BMatch%3BMatches&z=4&P=28725
    -->

    <xsl:variable name="inputTree" select="//tei:sourceDoc"/>
    <xsl:variable name="inputTree2" select="//tei:sourceDesc"/>

    <xsl:template name="findElementByTarget">
        <xsl:param name="thisTarget"/>
        <xsl:sequence select="$inputTree//*[@xml:id eq $thisTarget]"/>
    </xsl:template>

    <xsl:template name="makeLi">
        <xsl:param name="color"/>
        <xsl:element name="li">
            <xsl:attribute name="class" select="$color"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:join" mode="test">
        <xsl:variable name="target">
            <xsl:for-each select="tokenize(@target,' ')">
                <xsl:variable name="thisTarget" select="substring(.,2)"/>
                <xsl:call-template name="findElementByTarget">
                    <xsl:with-param name="thisTarget" select="$thisTarget"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>
        
        <!-- à généraliser (li) avec par ex. choose sur le type d'élément parent line -> li ou autre -->
        <!-- cf. http://www.oxygenxml.com/archives/xsl-list/201101/msg00074.html -->
        
        <xsl:for-each select="tokenize(@target,' ')">            
            <xsl:variable name="thisTarget2" select="substring(.,2)"/>
            <xsl:variable name="surface">
            <xsl:value-of select="key('BLOC-ZONE',$inputTree//*[@xml:id eq $thisTarget2], $inputTree)"/> 
            </xsl:variable>      
             <xsl:variable name="objectID" select="$surface//@corresp"/>
            <xsl:variable name="color" select="key('OBJECTS',$objectID, $inputTree)//tei:support/tei:p/@rend"/>           
            <xsl:variable name="key2">
                 <xsl:sequence select="key('BLOC-ZONE',$thisTarget2,$inputTree)"/> 
            </xsl:variable>       
            <xsl:for-each-group select="$target//tei:line" group-by="@n">
                <li>
                    <xsl:for-each select="current-group()">
                        <xsl:value-of select="."/>
                    </xsl:for-each>
                </li>
            </xsl:for-each-group>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="tei:join">
        <xsl:variable name="target">
            <xsl:for-each select="tokenize(@target,' ')">
                <xsl:variable name="thisTarget" select="substring(.,2)"/>
                    <xsl:call-template name="findElementByTarget">
                        <xsl:with-param name="thisTarget" select="$thisTarget"/>
                    </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>
        <!-- à généraliser (li) -->
        <xsl:for-each-group select="$target//tei:line" group-by="@n">
            <li>
                <xsl:for-each select="current-group()">
                    <xsl:variable name="zone" select="current()/ancestor-or-self::*/@xml:id"/>                       
                    <seg>
                        <xsl:attribute name="class">
                            <xsl:call-template name="getObjectColor">
                                <xsl:with-param name="zone" select="$zone"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                    </seg>
                </xsl:for-each>
            </li>
        </xsl:for-each-group>
    </xsl:template>
    
    
    <xsl:template name="getObjectColor">
        <xsl:param name="zone"/>
        <xsl:variable name="surface" select="$inputTree//*[@xml:id eq $zone]/ancestor::tei:surface/@xml:id"/>
        <xsl:variable name="object" select="$inputTree//*[@xml:id eq $surface]/@corresp"/>
        <xsl:variable name="objectID" select="substring-after($object,'#')"/>
        <xsl:variable name="color" select="$inputTree2//*[@xml:id eq $objectID]//tei:support/tei:p/@rend"/>
        <xsl:value-of select="$color"/>
               
    </xsl:template>

    <xsl:template match="tei:join[@type='sourceDoc2text']">
        <xsl:for-each select="tokenize(@target,' ')">
            <xsl:variable name="thisTarget" select="substring(.,2)"/>
            <xsl:apply-templates select="$inputTree//*[@xml:id eq $thisTarget]"
                mode="sourceDoc2text"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="tei:sourceDoc/tei:surface" mode="sourceDoc2text">
        <xsl:variable name="color">
            <xsl:text> </xsl:text>
            <xsl:value-of select="key('OBJECTS',@corresp)//tei:support/tei:p/@rend"/>
        </xsl:variable>
        <div>
            <xsl:attribute name="class">
                <xsl:value-of select="concat('clearfix ',local-name(),$color)"/>
            </xsl:attribute>
            <xsl:apply-templates select="*|@*|text()" mode="sourceDoc2text"/>
        </div>
    </xsl:template>

    <xsl:template match="tei:sourceDoc//tei:zone" mode="sourceDoc2text">
        <ul>
            <xsl:attribute name="class">
                <xsl:value-of select="local-name()"/>
            </xsl:attribute>
            <xsl:apply-templates select="*|@*|text()" mode="sourceDoc2text"/>
        </ul>
    </xsl:template>



    <xsl:template match="tei:sourceDoc//tei:line" mode="sourceDoc2text">
        <li>
            <xsl:attribute name="class">
                <xsl:value-of select="local-name()"/>
            </xsl:attribute>
            <xsl:apply-templates select="*|@*|text()" mode="sourceDoc2text"/>
        </li>
    </xsl:template>

    <xsl:template match="tei:cb">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- dates dans le sourceDoc -->

    <xsl:template match="tei:*[starts-with(@ana,'#date-')]">
        <a class="tooltip" href="#">
            <xsl:apply-templates/>
            <span class="info">
                <xsl:value-of select="substring-after(@ana,'#date-')"/>
            </span>
        </a>
    </xsl:template>

</xsl:stylesheet>
