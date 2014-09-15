<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: epidoc-custom-iglouvre.xsl 2090 2014-07-29  emmanuelleMorlock $ -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:t="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="t" version="2.0">
   <!-- templates xsl spécifiques à iglouvre -->
   <!-- comment gérer les personnalisations. exemple t:note apply imports ? ajouter un when au test de base... pb de généricisation : vaut-il mieux changer localement ou faire monter en généricité? -->
   <!-- 
      doc : 
      start-edition.xsl ::
           -   création d'un paramètre 'iglouvre' dans edn-structure
           -   ajout paramètre pour nom de la feuille de style css
           -   lien vers cette feuille de style de surcharge
           -   igl_htm-iglouvre-structure.xsl
           
           app 
            -  apparatus-style:iglouvre
            - titre division : cf. plus bas
            - pour apparat externe : mettre une ancre au niveau de la ligne ? pour naviguer de l'apparat à la ligne ? numéroter toutes les lignes qui ont un apparat ?
            
            
            idées : faire des paramètres pour :
            - les titres de section
            - les abréviations canoniques "vacat, lap.) etc.
            - faire un menu de navigation
            
            TODO
            - découper comme les feuilles de style d'exemple, avec un fichier par template et par module de template nommé qui importe le template officiel correspondant
      
   -->
   <!-- lookup tables -->
   <!--Create a key that indexes the origDate nodes by their @corresp attribute-->
   <xsl:key name="DATETEXT" match="t:origDate" use="@corresp"/>
   <!--Create a key that indexes the handNote nodes by their @corresp attribute-->
   <xsl:key name="HANDTEXT" match="t:handNote" use="@corresp"/>
   <!--Create a key that indexes the msItem nodes by their @corresp attribute-->
   <xsl:key name="TITLETEXT" match="t:msItem" use="concat('#',@xml:id)"/>
   <!--Create a key that indexes the msItem nodes by their @corresp attribute-->
   <xsl:key name="TRANSLATIONTEXT" match="t:div[@type='translation']//t:p" use="@corresp"/>
   <!--Create a key that indexes the glyph nodes by their @xml:id attribute-->
   <xsl:key name="GLYPHINFO" match="t:charDecl/t:glyph" use="concat('#',@xml:id)"/>
   <!--Create a key that indexes the msItem nodes by their @corresp attribute-->
   <xsl:key name="NUMSECTION" match="t:milestone" use="@corresp"/>
   <!--Create a key that indexes the div texpart nodes by their @corresp attribute-->
   <xsl:key name="DIVLOC" match="t:div[@type= 'textpart']"
      use="preceding-sibling::t:milestone/@corresp"/>
   <!-- Create a key for the bibliographic references -->
   <xsl:key name="BIBLIO" match="//t:back/t:div[@subtype='master']//t:biblStruct"
      use="concat('#',@xml:id)"/>
   <!-- Create a key for the choices in text present in apparatus -->
   <xsl:key name="CHOICES" match="t:div[@type= 'edition']//t:choice" use="concat('#',@xml:id)"/>
   <!-- 
   -->
   <!-- from teimilestone.xsl -->
   <!-- 
   -->
   <xsl:template match="t:milestone[@unit='section' or @unit='block']" priority="100">
      <!-- EM: add unit='section' -->
      <!-- adds pipe for block, flanked by spaces if not within word -->
      <xsl:variable name="num">
         <xsl:if test="@n">
            <xsl:value-of select="@n"/>
         </xsl:if>
      </xsl:variable>
      <xsl:variable name="unit">
         <xsl:if test="@unit">
            <xsl:value-of select="@unit"/>
         </xsl:if>
      </xsl:variable>
      <!-- 
      <xsl:variable name="div-type">
         <xsl:for-each select="ancestor::t:div[@type!='edition']">
            <xsl:value-of select="@type"/>
            <xsl:text>-</xsl:text>
         </xsl:for-each>
      </xsl:variable>
       -->
      <xsl:variable name="div-loc">
         <xsl:for-each select="ancestor::t:div[@type= 'textpart']">
            <xsl:value-of select="@n"/>
            <xsl:text>-</xsl:text>
         </xsl:for-each>
      </xsl:variable>
      <xsl:if test="@corresp">
         <!-- get origDate of corresponding text-->
         <xsl:variable name="texte" select="@corresp"/>
         <xsl:variable name="number" select="key('TITLETEXT',@corresp)/@n"/>
         <!-- get handNote of corresponding text  -->
         <a class="tooltip" href="#">
            <span class="milestoneNumber" id="{$div-loc}{$number}">
               <xsl:value-of select="$number"/>
            </span>
            <span class="info">
               <strong>
                  <xsl:value-of select="key('TITLETEXT',@corresp)/t:title"/>
               </strong>
               <!--  
               <p>
                  <xsl:value-of select="key('HANDTEXT',@corresp)"/>
               </p>
               -->
               <p class="translation">
                  <xsl:value-of select="key('TRANSLATIONTEXT',@corresp)"/>
                  <!-- la traduction -->
               </p>
               <p>
                  <xsl:value-of select="key('DATETEXT',@corresp)/t:date[@xml:lang='la']"/>
                  <!-- la date -->
               </p>
               <xsl:variable name="current">
                  <xsl:value-of select="@corresp"/>
               </xsl:variable>
               <xsl:if
                  test="$current is following::t:div[@type='commentary']//t:ref[@target='$current'][1]">
                  <p>
                     <xsl:text>Dans le commentaire :</xsl:text>
                     <ul class="list-inline">
                        <xsl:for-each select="t:div[@type='commentary']//ref[@target='$current']">
                           <li>
                              <xsl:call-template name="makeLinkLink">
                                 <xsl:with-param name="href-link">
                                    <xsl:value-of select="concat('#',@xml:id)"/>
                                 </xsl:with-param>
                                 <xsl:with-param name="text-link">
                                    <xsl:apply-templates select="."/>
                                 </xsl:with-param>
                              </xsl:call-template>
                           </li>
                        </xsl:for-each>
                     </ul>
                     <xsl:text>ya des liens</xsl:text>
                     <xsl:value-of select="$current"/>
                  </p>
               </xsl:if>
               <!-- liens éventuels vers les commentaires -->
            </span>
         </a>
      </xsl:if>
      <xsl:choose>
         <xsl:when
            test="self::t:milestone is ancestor::t:div[1]/t:*[child::t:milestone][1]/t:milestone[1]">
            <!-- 
            <a id="a{$div-loc}{$num}">
               <xsl:comment> debut <xsl:value-of select="$unit"/></xsl:comment>
            </a>  
             -->
            <!-- for the first milestone in a div, create an empty anchor  -->
         </xsl:when>
         <xsl:otherwise>
            <span class="{$unit}">
               <!-- adds a span class for css display -->
               <xsl:if test="not(ancestor::w)">
                  <xsl:text> </xsl:text>
               </xsl:if>
               <xsl:text>|</xsl:text>
               <xsl:if test="not(ancestor::w)">
                  <xsl:text> </xsl:text>
               </xsl:if>
            </span>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- 
   -->
   <!--  
      -->
   <!-- surcharge  teig.xsl -->
   <xsl:template match="t:g" priority="100">
      <xsl:if test="@ref">
         <span class="g">
            <a class="tooltip" href="#">
               <xsl:apply-templates/>
               <span class="info">
                  <xsl:apply-templates select="key('GLYPHINFO',@ref)/t:note"/>
                  <xsl:text> : </xsl:text>
                  <xsl:apply-templates select="key('GLYPHINFO',@ref)/t:mapping"/>
               </span>
            </a>
         </span>
      </xsl:if>
   </xsl:template>
   <!-- 
   -->
   <xsl:template match="t:ref" priority="100">
      <xsl:choose>
         <xsl:when test="self::t:ref[ancestor::t:div[@type='bibliography']]">
            <!-- no display when in div bibliography -->
         </xsl:when>
         <xsl:when test="self::t:ref[starts-with(@target,'http://')]">
            <xsl:choose>
               <xsl:when test="ancestor::t:glyph">
                  <xsl:call-template name="makeLinkText">
                     <xsl:with-param name="href-link">
                        <xsl:value-of select="@target"/>
                     </xsl:with-param>
                     <xsl:with-param name="text-link">
                        <xsl:apply-templates/>
                     </xsl:with-param>
                  </xsl:call-template>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:call-template name="makeLinkLink">
                     <xsl:with-param name="href-link">
                        <xsl:value-of select="@target"/>
                     </xsl:with-param>
                     <xsl:with-param name="text-link">
                        <xsl:apply-templates/>
                     </xsl:with-param>
                     <xsl:with-param name="css-class">
                        <xsl:text>externalLink</xsl:text>
                     </xsl:with-param>
                  </xsl:call-template>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="self::t:ref[contains(@target,'texte')]">
            <!-- if it points to a element defined by a milestone@unit="section" -->
            <!-- may be extended for milestone@unit="block" -->
            <xsl:call-template name="makeLinkLink">
               <xsl:with-param name="href-link">
                  <!-- anchor pattern: a + div[@type='textpart']/@n + milestone[@corresp]/@n -->
                  <xsl:value-of
                     select="concat('#',key('DIVLOC',@target)/@n,'-',key('NUMSECTION',@target)/@n)"
                  />
               </xsl:with-param>
               <xsl:with-param name="text-link">
                  <xsl:apply-templates/>
               </xsl:with-param>
               <xsl:with-param name="css-class">
                  <xsl:text>ref</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="self::t:ref[matches(@cRef,'^[A-Za-z]\-l[0-9]+\-?[0-9]*?')]">
            <!-- examples: 'A-l2' or 'C-l36-37' -->
            <xsl:call-template name="makeLinkLink">
               <xsl:with-param name="href-link">
                  <!-- anchor pattern: a + debut@cRef -->
                  <xsl:analyze-string select="@cRef" regex="\-[0-9]+">
                     <xsl:non-matching-substring>
                        <xsl:value-of select="concat('#a',.)"/>
                     </xsl:non-matching-substring>
                  </xsl:analyze-string>
               </xsl:with-param>
               <xsl:with-param name="text-link">
                  <xsl:apply-templates/>
               </xsl:with-param>
               <xsl:with-param name="css-class">
                  <xsl:text>refLine</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <span class="ref">
               <xsl:apply-templates/>
            </span>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="makeLinkLink">
      <xsl:param name="href-link"/>
      <xsl:param name="text-link"/>
      <xsl:param name="css-class"/>
      <a class="{$css-class}" href="{($href-link)}">
         <xsl:value-of select="$text-link"/>
      </a>
   </xsl:template>
   <xsl:template name="makeLinkText">
      <xsl:param name="href-link"/>
      <xsl:param name="text-link"/>
      <xsl:param name="css-class"/>
      <b>
         <xsl:value-of select="$text-link"/>
      </b>
      <xsl:text> (</xsl:text>
      <xsl:value-of select="$href-link"/>
      <xsl:text>) </xsl:text>
   </xsl:template>
   <!-- surcharge de teinote.xsl -->
   <xsl:template match="t:note" priority="100">
      <xsl:choose>
         <xsl:when test="ancestor::t:p or ancestor::t:l or ancestor::t:ab">
            <i>
               <xsl:apply-imports/>
            </i>
         </xsl:when>
         <!-- ajout em -->
         <xsl:when test="ancestor::t:glyph">
            <span class="note">
               <xsl:apply-templates/>
            </span>
         </xsl:when>
         <!-- fin ajout em -->
         <xsl:otherwise>
            <p class="note">
               <xsl:apply-imports/>
            </p>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- 
   -->
   <xsl:template match="t:listApp" priority="100">
      <xsl:for-each-group select=".//t:app" group-by="substring-before(@loc,'.')">
         <h3>
            <xsl:value-of select="current-grouping-key()"/>
         </h3>
         <dl>
            <xsl:for-each select="current-group()">
               <xsl:variable name="locLabel" select="'Ligne'"/>
               <xsl:variable name="locNum" select="substring-after(@loc,'.')"/>
               <xsl:variable name="locNumFirst">
                  <xsl:analyze-string select="$locNum" regex="^[0-9]+">
                     <xsl:matching-substring>
                        <xsl:value-of select="."/>
                     </xsl:matching-substring>
                  </xsl:analyze-string>
               </xsl:variable>
               <xsl:variable name="ref-to-line">
                  <xsl:choose>
                     <xsl:when test="not(node())">
                        <xsl:value-of select="'no'"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="'yes'"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:variable>
               <xsl:variable name="app-num">
                  <xsl:choose>
                     <xsl:when test="not(node())">
                        <xsl:value-of select="name()"/>
                        <xsl:number level="any" format="01"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="concat(substring-before(@loc,'.'),'-l',$locNumFirst)"
                        />
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:variable>
               <dt>
                  <xsl:choose>
                     <!-- line intervals -->
                     <xsl:when test="contains($locNum,'-')">
                        <xsl:value-of select="concat($locLabel,'s ',$locNum,' : ')"/>
                        <xsl:call-template name="generate-app-link-iglouvre">
                           <xsl:with-param name="location" select="'apparatus'"/>
                           <xsl:with-param name="ref-to-line" select="$ref-to-line"/>
                           <xsl:with-param name="app-num" select="$app-num"/>
                        </xsl:call-template>
                     </xsl:when>
                     <!-- non contiguous lines -->
                     <xsl:when test="contains($locNum,',')">
                        <xsl:value-of
                           select="concat($locLabel,'s ', replace($locNum,',',', '),' : ')"/>
                        <!-- one link for each line -->
                        <xsl:for-each select="tokenize($locNum,',')">
                           <xsl:variable name="lineNumber" select="."/>
                           <xsl:call-template name="generate-app-link-iglouvre">
                              <xsl:with-param name="location" select="'apparatus'"/>
                              <xsl:with-param name="ref-to-line" select="$ref-to-line"/>
                              <xsl:with-param name="app-num" select="$app-num"/>
                           </xsl:call-template>
                        </xsl:for-each>
                     </xsl:when>
                     <!--single line -->
                     <xsl:when test="not(contains($locNum,'-') or contains($locNum,','))">
                        <xsl:value-of select="concat($locLabel,' ',$locNum,' : ')"/>
                        <xsl:call-template name="generate-app-link-iglouvre">
                           <xsl:with-param name="location" select="'apparatus'"/>
                           <xsl:with-param name="ref-to-line" select="$ref-to-line"/>
                           <xsl:with-param name="app-num" select="$app-num"/>
                        </xsl:call-template>
                     </xsl:when>
                     <!--otherwise : no link-->
                     <xsl:otherwise>
                        <xsl:value-of select="concat('l. ',$locNum,' : ')"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </dt>
               <dd>
                  <xsl:apply-templates/>
               </dd>
            </xsl:for-each>
         </dl>
      </xsl:for-each-group>
   </xsl:template>

   <xsl:template match="//t:div[@type='bibliography']//t:p" priority="100">
      <xsl:if test="@n">
         <xsl:choose>
            <xsl:when test="@n='studies'">
               <h3>
                  <xsl:text>Etudes</xsl:text>
               </h3>
            </xsl:when>
            <xsl:when test="@n='editions'">
               <h3>
                  <xsl:text>Editions</xsl:text>
               </h3>
            </xsl:when>
            <xsl:otherwise/>
         </xsl:choose>
         <xsl:element name="p">
            <xsl:attribute name="class">
               <xsl:value-of select="@n"/>
            </xsl:attribute>
         </xsl:element>
      </xsl:if>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="t:div[@subtype='master']" priority="100"/>
   <xsl:template match="t:bibl[ancestor::t:div[@type='bibliography']]" priority="100">
      <!-- the key -->
      <xsl:variable name="key">
         <xsl:sequence select="key('BIBLIO',t:ptr/@target)"/>
      </xsl:variable>
      <!-- parenthesis test if the bibl is inside a clause inside parenthesis, use square braquets aroud dates instead of parenthesis-->
      <xsl:variable name="typoForDateLeft">
         <!-- <xsl:variable name="string" select="ancestor::t:*[1]/text()"/> -->
         <xsl:choose>
            <xsl:when test="@rend='sqbraquets'">
               <xsl:value-of select="' ['"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="' ('"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="typoForDateRight">
         <xsl:choose>
            <xsl:when test="@rend='sqbraquets'">
               <xsl:value-of select="']'"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="')'"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <!--  -->
      <xsl:element name="span">
         <xsl:attribute name="class">
            <xsl:text>bibl</xsl:text>
            <xsl:if test="@type = 'fromStone'">
               <xsl:text> fromStone</xsl:text>
            </xsl:if>
         </xsl:attribute>
         <xsl:choose>
            <xsl:when test="t:ptr">
               <!-- author / ed -->
               <xsl:if test="count(count($key//t:author) + count($key//t:editor) > 1)">
                  <!-- <span class="small-caps"> -->
                  <xsl:choose>
                     <!-- article, chapter or contribution-->
                     <xsl:when test="$key//t:analytic/t:author">
                        <xsl:for-each select="$key//t:analytic/t:author">
                           <xsl:call-template name="makeRefAuthor">
                              <xsl:with-param name="current" select="current()"/>
                           </xsl:call-template>
                        </xsl:for-each>
                     </xsl:when>
                     <!-- monography -->
                     <xsl:when test="$key//t:monogr/t:author">
                        <xsl:for-each select="$key//t:monogr/t:author">
                           <xsl:call-template name="makeRefAuthor">
                              <xsl:with-param name="current" select="current()"/>
                           </xsl:call-template>
                        </xsl:for-each>
                     </xsl:when>
                     <xsl:when test="$key//t:monogr/t:editor">
                        <xsl:for-each select="$key//t:monogr/t:editor">
                           <xsl:call-template name="makeRefAuthor">
                              <xsl:with-param name="current" select="current()"/>
                           </xsl:call-template>
                        </xsl:for-each>
                        <xsl:if test="count($key//t:monogr/t:editor) >= 1">
                           <span class="romain">
                              <xsl:text> (éd.), </xsl:text>
                           </span>
                        </xsl:if>
                     </xsl:when>
                     <xsl:otherwise/>
                  </xsl:choose>
                  <!--  </span>-->
               </xsl:if>
               <!-- title -->
               <xsl:call-template name="makeRefTitle">
                  <xsl:with-param name="key" select="$key"/>
               </xsl:call-template>
               <!-- biblScope -->
               <xsl:if test="$key//t:biblScope">
                  <xsl:call-template name="makeRefBiblScope"/>
                  <xsl:value-of select="$key//t:biblScope"/>
               </xsl:if>
               <!-- date -->
               <xsl:if test="$key//t:imprint/t:date">
                  <xsl:call-template name="makeRefImprint">
                     <xsl:with-param name="key" select="$key"/>
                     <xsl:with-param name="typoForDateLeft" select="$typoForDateLeft"/>
                     <xsl:with-param name="typoForDateRight" select="$typoForDateRight"/>
                  </xsl:call-template>
               </xsl:if>
               <!-- citedRange -->
               <xsl:if test="t:citedRange">
                  <xsl:call-template name="makeCitedRange">
                     <xsl:with-param name="key">
                        <xsl:value-of select="$key"/>
                     </xsl:with-param>
                  </xsl:call-template>
               </xsl:if>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xsl:template name="makeRefBiblScope">
      <xsl:text> </xsl:text>
      <xsl:choose>
         <xsl:when test="@unit='number'">
            <xsl:text>n° </xsl:text>
         </xsl:when>
         <xsl:when test="@unit='part'">
            <!-- todo: verify -->
            <xsl:text/>
         </xsl:when>
         <xsl:otherwise/>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="t:bibl[ancestor::t:div[@type='commentary']]" priority="100">
      <!-- the key -->
      <xsl:variable name="key">
         <xsl:sequence select="key('BIBLIO',t:ptr/@target)"/>
      </xsl:variable>
      <!-- parenthesis for date -->
      <xsl:variable name="typoForDateLeft">
         <!-- depends on @rend value on <gi>bibl</gi>  -->
         <xsl:choose>
            <xsl:when test="@rend='sqbraquets'">
               <xsl:value-of select="' ['"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="' ('"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="typoForDateRight">
         <xsl:choose>
            <xsl:when test="@rend='sqbraquets'">
               <xsl:value-of select="']'"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="')'"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="t:ptr">
            <!-- author -->
            <xsl:choose>
               <!-- if it's an article -->
               <xsl:when test="$key//t:analytic/t:author">
                  <xsl:text>1</xsl:text>
                  <xsl:for-each select="$key//t:analytic/t:author">
                     <xsl:call-template name="makeRefAuthor">
                        <xsl:with-param name="current" select="current()"/>
                     </xsl:call-template>
                  </xsl:for-each>
               </xsl:when>
               <!-- if it's a monography -->
               <xsl:when test="$key//t:monogr/t:author">
                  <xsl:text>2</xsl:text>
                  <xsl:for-each select="$key//t:monogr/t:author">
                     <xsl:call-template name="makeRefAuthor">
                        <xsl:with-param name="current" select="current()"/>
                     </xsl:call-template>
                  </xsl:for-each>
               </xsl:when>
               <xsl:when test="$key//t:monogr/t:editor">
                  <xsl:text>3</xsl:text>
                  <xsl:for-each select="$key//t:monogr/t:editor">
                     <xsl:call-template name="makeRefAuthor">
                        <xsl:with-param name="current" select="current()"/>
                     </xsl:call-template>
                  </xsl:for-each>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>4</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
            <!-- title -->
            <xsl:if test="$key//t:title">
               <xsl:call-template name="makeRefTitle">
                  <xsl:with-param name="key" select="$key"/>
               </xsl:call-template>
            </xsl:if>
            <!-- biblScope -->
            <xsl:if test="$key//t:biblScope">
               <xsl:call-template name="makeRefBiblScope"/>
               <xsl:value-of select="$key//t:biblScope"/>
            </xsl:if>
            <!-- date -->
            <xsl:if test="$key//t:imprint/t:date">
               <xsl:call-template name="makeRefImprint">
                  <xsl:with-param name="key" select="$key"/>
                  <xsl:with-param name="typoForDateLeft" select="$typoForDateLeft"/>
                  <xsl:with-param name="typoForDateRight" select="$typoForDateRight"/>
               </xsl:call-template>
            </xsl:if>
            <!-- citedRange -->
            <xsl:if test="t:citedRange">
               <xsl:call-template name="makeCitedRange">
                  <xsl:with-param name="key">
                     <xsl:value-of select="$key"/>
                  </xsl:with-param>
               </xsl:call-template>
            </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template name="makeRefAuthor">
      <xsl:param name="current"/>
      <xsl:variable name="initial">
         <xsl:value-of select="($current//substring(t:forename,1,1))"/>
      </xsl:variable>
      <span class="author">
         <xsl:value-of select="concat(normalize-space($initial),'. ')"/>
         <xsl:value-of select="$current//t:surname"/>
      </span>
      <xsl:text>, </xsl:text>
   </xsl:template>
   <xsl:template name="makeRefTitle">
      <xsl:param name="key"/>
      <xsl:if test="$key//t:analytic/t:title">
         <xsl:text> « </xsl:text>
         <xsl:value-of select="$key//t:analytic/t:title"/>
         <xsl:text> », </xsl:text>
      </xsl:if>
      <span class="title">
         <xsl:choose>
            <xsl:when test="$key//t:monogr/t:title[@type='short']">
               <xsl:value-of select="$key//t:monogr/t:title[@type='short']"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$key//t:monogr/t:title"/>
            </xsl:otherwise>
         </xsl:choose>
      </span>
   </xsl:template>
   <xsl:template name="makeCitedRange">
      <xsl:param name="key"/>
      <xsl:for-each select="t:citedRange">
         <xsl:choose>
            <xsl:when test="@unit='page'">
               <xsl:text>, p. </xsl:text>
               <xsl:choose>
                  <xsl:when test="@from and @to">
                     <xsl:value-of select="concat(@from,'-',@to)"/>
                  </xsl:when>
                  <xsl:when test="@unit='part' or @unit='number'">
                     <xsl:value-of select="concat(' ',.)"/>
                  </xsl:when>
                  <xsl:otherwise/>
               </xsl:choose>
            </xsl:when>
            <xsl:when test="@unit = 'number'">
               <xsl:value-of select="concat(', n° ',.)"/>
            </xsl:when>
            <xsl:when test="@unit = 'part'">
               <xsl:value-of select="concat(', ',.)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>, </xsl:text>
               <xsl:apply-templates/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="makeRefImprint">
      <xsl:param name="key"/>
      <!-- dépendent du contexte (si à l'intérieur d'autres parenthèses, il faut utiliser des parenthèses carrées) -->
      <xsl:param name="typoForDateLeft"/>
      <xsl:param name="typoForDateRight"/>
      <xsl:choose>
         <xsl:when test="$key//t:imprint/t:date/@when">
            <xsl:value-of select="$typoForDateLeft"/>
            <xsl:value-of select="$key//t:imprint/t:date/@when"/>
            <xsl:value-of select="$typoForDateRight"/>
         </xsl:when>
         <xsl:when test="$key//t:imprint/t:date/@from and $key//t:imprint/t:date/@to">
            <xsl:value-of select="$typoForDateLeft"/>
            <xsl:value-of
               select="concat($key//t:imprint/t:date/@from,'-',$key//t:imprint/t:date/@to)"/>
            <xsl:value-of select="$typoForDateRight"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$typoForDateLeft"/>
            <xsl:value-of select="$key//t:imprint/t:date"/>
            <xsl:value-of select="$typoForDateRight"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="t:persName[not(ancestor::t:div[@type='edition'])]" priority="100">
      <span class="author">
         <xsl:apply-templates/>
      </span>
   </xsl:template>
   <!-- 
   -->
   <!-- em: from teichoice.xsl -->
   <xsl:template match="t:choice" priority="100">
      <xsl:param name="parm-apparatus-style" tunnel="yes" required="no"/>
      <xsl:param name="parm-leiden-style" tunnel="yes" required="no"/>
      <xsl:choose>
         <xsl:when test="child::t:sic and child::t:corr and starts-with($parm-leiden-style, 'edh')">
            <xsl:text>&lt;</xsl:text>
            <xsl:apply-templates select="t:corr"/>
            <xsl:text>=</xsl:text>
            <xsl:value-of select="translate(t:sic, $all-grc, $grc-upper-strip)"/>
            <xsl:text>&gt;</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
      <!-- Found in [htm|txt]-tpl-apparatus -->
      <!-- EM: add param iglouvre and for each -->
      <xsl:variable name="app-from" select="concat('#',@xml:id)"/>
      <xsl:if
         test="($parm-apparatus-style = 'ddbdp' or $parm-apparatus-style = 'iglouvre') and ((child::t:sic and child::t:corr) or (child::t:orig and child::t:reg)) and (following::t:div[@type='apparatus']//t:app[@from = $app-from][1])">
         <!-- on crée un lien pour tous les <app> de l'apparat externe qui citent l'élément courant -->
         <xsl:for-each select="following::t:div[@type='apparatus']//t:app[@from = $app-from]">
            <sup>
               <xsl:call-template name="app-link-iglouvre">
                  <xsl:with-param name="location" select="'text'"/>
                  <xsl:with-param name="ref-to-line" select="'no'"/>
               </xsl:call-template>
            </sup>
         </xsl:for-each>
      </xsl:if>
   </xsl:template>
   <!-- 
   -->
   <xsl:template name="app-link-iglouvre">
      <!-- location defines the direction of linking -->
      <xsl:param name="location"/>
      <xsl:param name="ref-to-line"/>
      <!-- Does not produce links for translations -->
      <xsl:if test="not(ancestor::t:div[@type = 'translation'])">
         <!-- Only produces a link if it is not nested in an element that would be in apparatus -->
         <!-- <xsl:if test="not((local-name() = 'choice' or local-name() = 'subst' or local-name() = 'app')
            and (ancestor::t:choice or ancestor::t:subst or ancestor::t:app))"> -->
         <!-- em: only produces a link if the target exists -->
         <!-- todo -->
         <xsl:variable name="app-num">
            <xsl:value-of select="name()"/>
            <xsl:number level="any" format="01"/>
         </xsl:variable>
         <xsl:call-template name="generate-app-link-iglouvre">
            <xsl:with-param name="location" select="$location"/>
            <xsl:with-param name="app-num" select="$app-num"/>
            <xsl:with-param name="ref-to-line" select="$ref-to-line"/>
         </xsl:call-template>
      </xsl:if>
      <!-- </xsl:if> -->
   </xsl:template>
   <xsl:template name="generate-app-link-iglouvre">
      <xsl:param name="location"/>
      <xsl:param name="ref-to-line"/>
      <xsl:param name="app-num"/>
      <xsl:choose>
         <xsl:when test="$location = 'text'">
            <a>
               <xsl:attribute name="href">
                  <xsl:text>#to-app-</xsl:text>
                  <xsl:value-of select="$app-num"/>
               </xsl:attribute>
               <xsl:attribute name="id">
                  <xsl:text>from-app-</xsl:text>
                  <xsl:value-of select="$app-num"/>
               </xsl:attribute>
               <xsl:text>(*)</xsl:text>
            </a>
         </xsl:when>
         <xsl:when test="$location = 'apparatus' and $ref-to-line ='yes'">
            <a>
               <xsl:attribute name="id">
                  <xsl:text>to-a-</xsl:text>
                  <xsl:value-of select="$app-num"/>
               </xsl:attribute>
               <xsl:attribute name="href">
                  <xsl:text>#a</xsl:text>
                  <xsl:value-of select="$app-num"/>
               </xsl:attribute>
               <xsl:text>^</xsl:text>
            </a>
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:when test="$location = 'apparatus'and $ref-to-line ='no'">
            <a>
               <xsl:attribute name="id">
                  <xsl:text>to-app-</xsl:text>
                  <xsl:value-of select="$app-num"/>
               </xsl:attribute>
               <xsl:attribute name="href">
                  <xsl:text>#from-app-</xsl:text>
                  <xsl:value-of select="$app-num"/>
               </xsl:attribute>
               <xsl:text>^</xsl:text>
            </a>
            <xsl:text> </xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>


</xsl:stylesheet>
