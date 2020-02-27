<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xs xd t" version="2.0">

    <!-- ******************************************************************************
        Takes an inscription marked up in Epidoc (US Ep version, Winter 2011) and
        transforms it to HTML for display. This is based on the US Ep proofreading
        XSL and on the original USEp display XSL.
        **Change Log
        2011-11-8 EM Begun
        2011-11-29 EM adding edition handling
        2014-09-25 EM many changes including:
        2015-9-15 SJD and EM rewrote image display to accomodate graphics from external webpages
        2015-09-29 SJD Added variables, added concat to remove excess commas
        2015-09-30 EM testing the acquisition field with no variable
        2015-10-06 SJD Added string-length tests to remove commas
        2015-10-13 SJD added variables and tests for Layout, Writing, Condition
        2015-10-20 SJD fixing display xsl for writing, layout, condition; fixed path errors in dateOfProvenance and acquisitionDate variables
        2015-10-21 SJD small fixes to display (removed all stray commas)
        2015-10-21 SJD fixed display of transcribed texts with multiple divs
        2015-11-02 SJD made small change to columns display
        2015-11-17 SJD made expansions to columns and line display (added tests for wider ranger of situations)
        2015-11-18 SJD added captions to image display
        2015-11-19 SJD Fixed column displays, removed stray periods from title heading; small tweaks to fix caption display
        2015-11-24 SJD Added support for lg in displaying transcription
        2015-12-02 SJD Added variable for material
        2016-01-19 SJD Small tweak to column display
        2016-01-21 SJD Fixed typo in provenance, added display of descriptions for provenance/acquisition
        2016-03-02 SJD Made fixes to allow multiple provenance elements to display correctly
        2016-11-10 EM change to display XML button to view source
        2017-06-29 SJD separated Date of Origin and Place of Origin into two distinct categories
        2017-07-14 SJD tweaked spacing of external links in bibl; renamed Date of Origin to Date
        2018-08-08 SJD fixes issues with provenance to display according to desired categories; added table display for authorship
        2019-11-14 SJD fixed main issue with authorship display, pushed alpha version to site
        2020-01-30 SJD reordered major metadata categories, display orders of transcription per JB's design requests; commented out editor display privileging authorial creation
        ******************************************************************************   -->

    <xsl:output indent="yes" encoding="UTF-8" method="xml"/>
    <xsl:variable name="imageDir" select="'../../../../usep_images'"/>

    <xsl:include href="epidoc-xsl-p5/start-edition.xsl"/>

    <!-- Output is not complete HTML file, because in our case, most of the page, header and so on are handled by django.
        This script takes care of anything beneath the title of the inscription (handled by django) down to the bibliographic
        citations and the images. -->

    <xsl:template match="/">
        <xsl:result-document href="#container">
            <div>

                <!-- This outputs the full text description at the top of the page, after checking that there are descriptions to output. -->
                <div class="titleBlurb">
                    <xsl:if test="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:physDesc/*">
                        <h3>Summary</h3>
                        <p><xsl:value-of
                                select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:msContents/t:msItem/t:p"/>.<br/>
                            <xsl:if
                                test="string(normalize-space(/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:physDesc/t:objectDesc/t:supportDesc/t:support/t:p))">
                                <xsl:value-of
                                    select="concat(/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:physDesc/t:objectDesc/t:supportDesc/t:support/t:p, '.')"
                                />
                            </xsl:if>
                        </p>
                    </xsl:if>
                </div>



                <!-- enclosing div so that metadata and images can be side by side -->
                <div class="topDivs">
                  <!-- This outputs the text using Epidoc stylesheets, checks to see if there is a transcription. -->
                  <xsl:if
                      test="/t:TEI/t:text/t:body/t:div[@type = 'edition']/t:ab/t:lb or /t:TEI/t:text/t:body/t:div[@type = 'edition']/t:lg or /t:TEI/t:text/t:body/t:div[@type = 'edition']/t:div[@type = 'textpart']">
                      <div class="transcription">
                        <h3>Transcription</h3>
                      <style id="transcription_style">
                          .linenumber{
                              display:block;
                              float:left;
                              margin-left:-2em;
                          }</style>
                      <xsl:call-template name="default-body-structure">
                          <xsl:with-param name="parm-leiden-style" tunnel="yes"
                              >panciera</xsl:with-param>
                          <xsl:with-param name="parm-line-inc" tunnel="yes" as="xs:double"
                              >5</xsl:with-param>
                          <xsl:with-param name="parm-bib" tunnel="yes">none</xsl:with-param>
                      </xsl:call-template>
                      </div>
                  </xsl:if>
                    <!-- This outputs the inscription metadata, after checking that there is some. -->
                    <xsl:if test="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:physDesc/*">
                        <div class="metadata">
                            <h3>Attributes</h3>
                            <!-- variables -->
                            <xsl:variable name="placeOfOrigin"
                                select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:origin/t:placeName"/>
                            <xsl:variable name="dateOfOrigin">
                                <xsl:sequence
                                    select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:origin/t:date"
                                />
                            </xsl:variable>
                            <xsl:variable name="placeOfOrigin"
                                select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:origin/t:placeName"/>
                            <xsl:variable name="placeOfProvenance">
                                <xsl:sequence
                                    select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:provenance/t:p"
                                />
                            </xsl:variable>
                           <!-- <xsl:variable name="dateOfProvenance"
                                select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:provenance/t:date"/> -->
                            <xsl:variable name="acquisitionDesc">
                                <xsl:sequence
                                    select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:acquisition/t:p"
                                />
                            </xsl:variable>
                            <xsl:variable name="acquisitionDate"
                                select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:acquisition/t:date"/>
                            <xsl:variable name="condition"
                                select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:physDesc/t:objectDesc/t:supportDesc/t:condition"/>
                            <xsl:variable name="layout"
                                select="t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:physDesc/t:objectDesc/t:layoutDesc/t:layout"/>
                            <xsl:variable name="writing"
                                select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:physDesc/t:handDesc/t:handNote"/>
                            <xsl:variable name="material"
                                select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:physDesc/t:objectDesc/t:supportDesc/@ana"/>

                            <!-- end variables -->

                            <table>
                                <tr>
                                    <td class="label">Inscription Type</td>
                                    <td class="value">
                                        <xsl:value-of
                                            select="id(substring-after(/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:msContents/t:msItem/@class, '#'))/t:catDesc"
                                        />
                                    </td>
                                </tr>
                                <tr>
                                    <td class="label">Object Type</td>
                                    <td class="value">
                                        <xsl:value-of
                                            select="id(substring-after(/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:physDesc/t:objectDesc/@ana, '#'))/t:catDesc"
                                        />
                                    </td>
                                </tr>
                                <tr>
                                    <td class="label">Material</td>
                                    <td class="value">
                                        <xsl:for-each select="$material">
                                            <xsl:value-of
                                                select="id(substring-after($material, '#'))/t:catDesc"/>
                                            <xsl:if test="position() != last()">
                                                <xsl:text>, </xsl:text>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </td>
                                </tr>
                                <!-- check for existence of controlled and full text values here. -->
                                <tr>
                                    <td class="label">Writing</td>
                                    <td class="value">
                                        <xsl:choose>
                                            <xsl:when
                                                test="string-length($writing/@ana) != 0 and normalize-space($writing)">
                                                <xsl:value-of
                                                  select="concat(id(substring-after($writing/@ana, '#'))/t:catDesc, ', ', $writing)"
                                                />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of
                                                  select="id(substring-after($writing/@ana, '#'))/t:catDesc"
                                                />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="label">Layout</td>
                                    <td class="value">
                                        <xsl:choose>
                                            <xsl:when
                                                test="string-length($layout/@columns) != 0 and string-length($layout/@writtenLines) != 0 and $layout/@columns > '1'">
                                                <xsl:value-of
                                                  select="concat($layout/@columns, ' columns, ', $layout/@writtenLines, ' lines')"
                                                />
                                            </xsl:when>
                                            <xsl:when
                                                test="string-length($layout/@columns) != 0 and string-length($layout/@writtenLines) != 0 and $layout/@columns = '1' and $layout/@writtenLines = '1'">
                                                <xsl:value-of
                                                  select="concat($layout/@columns, ' column, ', $layout/@writtenLines, ' line')"
                                                />
                                            </xsl:when>
                                            <xsl:when
                                                test="string-length($layout/@columns) != 0 and string-length($layout/@writtenLines) != 0 and $layout/@columns > '1' and $layout/@writtenLines = '1'">
                                                <xsl:value-of
                                                  select="concat($layout/@columns, ' columns, ', $layout/@writtenLines, ' line')"
                                                />
                                            </xsl:when>
                                            <xsl:when
                                                test="string-length($layout/@columns) != 0 and string-length($layout/@writtenLines) != 0 and $layout/@columns = '1' and $layout/@writtenLines > '1'">
                                                <xsl:value-of
                                                  select="concat($layout/@columns, ' column, ', $layout/@writtenLines, ' lines')"
                                                />
                                            </xsl:when>
                                            <xsl:when
                                                test="$layout/@columns = '0' and string-length($layout/@writtenLines) != 0 and $layout/@writtenLines = '1'">
                                                <xsl:value-of
                                                  select="concat($layout/@writtenLines, ' line')"/>
                                            </xsl:when>
                                            <xsl:when
                                                test="$layout/@columns = '0' and string-length($layout/@writtenLines) != 0 and $layout/@writtenLines != '1'">
                                                <xsl:value-of
                                                  select="concat($layout/@writtenLines, ' lines')"/>
                                            </xsl:when>
                                        </xsl:choose>

                                    </td>
                                </tr>

                                <tr>
                                    <td class="label">Decoration</td>
                                    <td class="value">
                                        <xsl:value-of
                                            select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:physDesc/t:decoDesc/t:decoNote/@ana"/>
                                        <xsl:value-of
                                            select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:physDesc/t:decoDesc/t:decoNote"
                                        />
                                    </td>
                                </tr>
                                <tr>
                                    <td class="label">Condition</td>
                                    <td class="value">
                                        <xsl:choose>
                                            <xsl:when
                                                test="normalize-space($condition/t:p) and string-length($condition/@ana) != 0">
                                                <xsl:value-of
                                                  select="concat(id(substring-after($condition/@ana, '#'))/t:catDesc, ', ', $condition/t:p)"
                                                />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of
                                                  select="id(substring-after($condition/@ana, '#'))/t:catDesc"
                                                />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="label">Place of Origin</td>
                                    <td class="value">
                                        <xsl:value-of select="$placeOfOrigin"/>
                                    </td>
                                </tr>

                                <xsl:for-each select="//t:provenance">
                                    <tr>
                                        <td class="label">Subsequent Location</td>
                                        <td class="value">
                                            <xsl:choose>
                                                <xsl:when
                                                  test="string-length(child::t:p) != 0">
                                                  <xsl:value-of
                                                  select="(child::t:p)"/>
                                                </xsl:when>
                                            </xsl:choose>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                                <tr>
                                    <td class="label">Acquired</td>
                                    <td class="value">
                                        <xsl:choose>
                                            <xsl:when test="string-length($acquisitionDesc) != 0">
                                                <xsl:value-of
                                                  select="concat($acquisitionDate, ', ', $acquisitionDesc)"
                                                />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$acquisitionDate"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="label">Date</td>
                                    <td class="value">
                                        <xsl:value-of select="$dateOfOrigin"/>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </xsl:if>

                    <!-- Output the images (hope to format these at upper  right perhaps?), again, first checking to see if there are any. -->
                    <xsl:result-document href="#images">
                        <xsl:for-each select="/t:TEI/t:facsimile/t:surface">

                            <xsl:for-each select="t:graphic">
                                <xsl:choose>
                                    <xsl:when test="starts-with(@url, 'http')">
                                        <a class="highslide" href="{@url}"
                                            onclick="return hs.expand(this)">
                                            <img src="{@url}" alt="" width="200"/>
                                        </a>
                                        <xsl:value-of select="preceding-sibling::t:desc"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a class="highslide" href="{concat($imageDir, '/',@url)}"
                                            onclick="return hs.expand(this)">
                                            <img src="{concat($imageDir, '/',@url)}" alt=""
                                                width="200"/>
                                        </a>
                                        <xsl:value-of select="preceding-sibling::t:desc"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:result-document>
                </div>


                <!-- This outputs the bibliography. No need to check, there is always bibliography. -->
                <div class="bibl">
                    <h3>Bibliography</h3>
                    <xsl:call-template name="bibl"/>

                    <!-- this should be enclosed in a bibl and put into the bibliography script,
                            it should also check that link is descendant of div type=bib -->

                </div>

                <xsl:choose>
                    <xsl:when
                        test="/t:TEI/t:text/t:body/t:div[@type = 'edition']/t:ab/t:lb or /t:TEI/t:text/t:body/t:div[@type = 'edition']/t:lg or /t:TEI/t:text/t:body/t:div[@type = 'edition']/t:div[@type = 'textpart']">
                        <!-- transcribed folder -->
                        <pc class="XMLsource">
                            <a href="{concat('https://github.com/Brown-University-Library/usep-data/blob/master/xml_inscriptions/transcribed/',/t:TEI/t:teiHeader/t:fileDesc/t:publicationStmt/t:idno/@xml:id,'.xml')}">
                                <img style="height:50px;" src="{concat($imageDir, '/xmlIcon.png')}"/>
                            </a>
                        </pc>
                    </xsl:when>
                    <xsl:when
                        test="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:msContents/t:msItem[@class]">
                        <!-- bib only folder -->
                        <p class="XMLsource">
                            <a
                                href="{concat('https://github.com/Brown-University-Library/usep-data/blob/master/xml_inscriptions/metadata_only/',/t:TEI/t:teiHeader/t:fileDesc/t:publicationStmt/t:idno/@xml:id,'.xml')}">
                                <img style="height:50px;" src="{concat($imageDir, '/xmlIcon.png')}"/>
                            </a>
                        </p>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- only option left is metadata only -->
                        <p class="XMLsource">
                            <a
                                href="{concat('https://github.com/Brown-University-Library/usep-data/blob/master/xml_inscriptions/bib_only/',/t:TEI/t:teiHeader/t:fileDesc/t:publicationStmt/t:idno/@xml:id,'.xml')}">
                                <img style="height:50px;" src="{concat($imageDir, '/xmlIcon.png')}"/>
                            </a>
                        </p>
                    </xsl:otherwise>
                </xsl:choose>




            </div>
            <!-- ****** Author/Editor Information ****** -->


                <div class="author">
                    <table>
                      <xsl:for-each select="//t:change">
                        <tr>
                        <xsl:choose>
                            <xsl:when test="position()=1">
                                <td type="label">Author: </td>
                                <td type="value"><xsl:value-of select="concat(@who, ' on: ', @when)"/></td>
                            </xsl:when>
                            <!--><xsl:otherwise>
                                <td type="label">Edited by: </td>
                                <td type="value">
                                    <xsl:value-of select="concat(@who, ' on: ', @when)"/>
                                </td>
                            </xsl:otherwise><-->
                        </xsl:choose>
                        </tr>
                    </xsl:for-each>

                    </table>
                </div>
        </xsl:result-document>
    </xsl:template>



    <!-- ****************** This outputs the bibliography ******************** -->

    <xsl:template name="bibl">

        <xsl:for-each select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:listBibl/t:bibl">
            <xsl:variable name="myID" select="substring-after(t:ptr/@target, '#')"/>
            <p>
                <!-- Note: I'm not handling cases where articles are directly in the monograph. Only where they
                    are in a volume. We don't have any, so let's do it later.
                -->
                <!-- Output the author, if there is one. Right now, assumption is that there is an
                    potentially an author on the bibl if it's an article, or on the outermost bibl if
                    it's a corpus or monograph. Assume that there is always a <persName type="sort"> and use that.
                -->

                <xsl:if test="id($myID)/t:author/t:persName[@type = 'sort']">
                    <xsl:value-of
                        select="concat(id($myID)/t:author/t:persName[@type = 'sort'], ', ')"/>
                </xsl:if>

                <!-- output title or abbreviation. if it's a monograph, output the title. If  corpus or a journal
                    output the abbreviation if there is one. I am not outputting titles for volumes or articles, as
                    we don't have any. If it's an abbreviation, link it back to the bibliography. This was changed. Code
                    left in.
                -->

                <xsl:choose>
                    <xsl:when
                        test="id($myID)/ancestor-or-self::t:bibl[@type = 'm' or @type = 'u']/t:title">
                        <i>
                            <xsl:value-of
                                select="id($myID)/ancestor-or-self::t:bibl[@type = 'm' or @type = 'u']/t:title"
                            />
                        </i>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when
                                test="id($myID)/ancestor-or-self::t:bibl[@type = 'c' or @type = 'j']/t:abbr">
                                <!-- I  have commented out the code that made an abbreviation into a link to the actual bibliographic entry -->
                                <!-- <a href="../refList.html#{//bibl[@id=$myID]/ancestor-or-self::bibl[@type='c' or @type='j']/@id}"> -->
                                <i>
                                    <xsl:value-of
                                        select="id($myID)/ancestor-or-self::t:bibl[@type = 'c' or @type = 'j']/t:abbr[@type = 'primary']"
                                    />
                                </i>
                                <!-- </a> -->
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="id($myID)/ancestor-or-self::t:bibl[@type = 'c' or @type = 'j']/t:title"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>

                <!-- output the volume, if there is one. with a space before it. -->

                <xsl:if test="id($myID)/ancestor-or-self::t:bibl[@type = 'v']">
                    <xsl:value-of
                        select="concat(' ', id($myID)/ancestor-or-self::t:bibl[@type = 'v']/t:biblScope)"
                    />
                </xsl:if>

                <!-- output the year, if there is one. with a space before it and inside parentheses. -->

                <xsl:choose>
                    <xsl:when test="id($myID)/t:date">
                        <xsl:value-of select="concat(' (', id($myID)/t:date, ')')"/>
                    </xsl:when>
                    <xsl:when
                        test="id($myID)/ancestor-or-self::t:bibl[@type = 'v' or type = 'm']/t:date">
                        <xsl:value-of
                            select="concat(' (', id($myID)/ancestor-or-self::t:bibl[@type = 'v' or type = 'm']/t:date, ')')"
                        />
                    </xsl:when>
                </xsl:choose>

                <!-- everything has a reference except for unpub. but put a space before it. -->

                <xsl:if test="t:biblScope">
                    <xsl:value-of select="concat(': ', t:biblScope)"/>
                </xsl:if>

                <!--  This puts the author at the end of a citation in quotes. seems odd, can't tell what or why.
                <xsl:if test="id($myID)/t:author">
                    <xsl:value-of select="concat(' [', id($myID)/t:author, ']')"/>
                </xsl:if> -->

                <!-- This prints the jstor link   -->
                <xsl:if test="id($myID)/t:ref[@type = 'jstor']">
                    <br/>
                    <a href="{id($myID)/t:ref/@target}" class="biblink">
                        <xsl:value-of
                            select="concat(id($myID)/t:ref[@type = 'jstor'], '(external link; access to JSTOR required)')"
                        />
                    </a>
                </xsl:if>

                <xsl:if test="t:ref">
                    <a href="{t:ref/@target}">
                        <xsl:value-of select="concat(t:ref, ' (external link)')"/>
                    </a>
                </xsl:if>

            </p>
        </xsl:for-each>
    </xsl:template>


</xsl:stylesheet>
