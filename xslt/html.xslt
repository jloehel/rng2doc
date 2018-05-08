<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" doctype-system="about:legacy-compat" encoding="utf-8" indent="yes" />
  <xsl:include href="svg.xslt"/>

  <xsl:template match="/">
    <xsl:apply-templates select="documentation"/>
  </xsl:template>

  <xsl:key name="first_letters" match="element" use="substring(@name, 1, 1)"/>
  <xsl:template match="documentation">
    <html lang="en">
      <xsl:call-template name="head"/>
      <body>
        <xsl:call-template name="nav"/>
        <div class="container">
          <div id="index">
            <h1>Elemente</h1>
            <xsl:for-each select="element[count(. | key('first_letters', substring(@name, 1, 1))[1]) = 1]">
                <xsl:sort select="@name" />
                <xsl:variable name="counter_hack" select="position() - 1"/>                
                <xsl:variable name="first_letter" select="substring(@name, 1, 1)" />
                <xsl:if test="$counter_hack mod 3 = 0">
                  <xsl:text disable-output-escaping="yes"><![CDATA[<div class="row index">]]></xsl:text>
                </xsl:if>
                <div class="col-sm-4 index">
                  <ul id="{$first_letter}" class="list-group">
                    <li class="list-group-item active"><xsl:value-of select="$first_letter"/></li>
                    <xsl:apply-templates select="key('first_letters', substring(@name, 1, 1))" mode="index">
                      <xsl:sort select="@name" />
                    </xsl:apply-templates>
                  </ul>
                </div>
                <xsl:if test="$counter_hack mod 3 = 2">
                  <xsl:text disable-output-escaping="yes"><![CDATA[</div>]]></xsl:text>
                </xsl:if>
            </xsl:for-each>
          </div>
          <div class="card-columns">
            <xsl:apply-templates select="element" mode="visualize"/>
          </div>
        </div>
        <xsl:call-template name="footer"/>
        <xsl:call-template name="scripts"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="element" mode="index">
    <li class="list-group-item"><a href="#element{@id}"><code><xsl:value-of select="@name"/></code></a></li>
  </xsl:template>  

  <xsl:template match="element" mode="visualize">
    <xsl:variable name="id" select="@id"/> 
    <div class="card" id="element{$id}" name="element{$id}">
      <div class="card-header">
        Element
      </div>
      <div class="card-body">
        <h5 class="card-title"><xsl:value-of select="@name"/></h5>
        <h6 class="card-subtitle mb-2 text-muted">
          Namensraum:<xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
          <xsl:choose>
            <xsl:when test="boolean(namespace/text())">
              <xsl:value-of select="namespace"/>
            </xsl:when>
            <xsl:otherwise>
              -
            </xsl:otherwise>
          </xsl:choose>
        </h6>
        <p class="card-text"><xsl:value-of select="description"/></p>
        <div class="svg">
          <xsl:call-template name="transform_element_to_svg">
            <xsl:with-param name="element" select="."/>
          </xsl:call-template>
        </div>
        <ul class="list-group list-group-flush">
          <li class="list-group-item">
            <span class="lead">Vaterelemente:</span>
            <xsl:variable name="parents" select="//element/child[@id = $id]/parent::element"/>
            <xsl:choose>
              <xsl:when test="$parents">  
                <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
                <xsl:apply-templates select="$parents" mode="parent"/>
              </xsl:when>
              <xsl:otherwise>
                -
              </xsl:otherwise>
            </xsl:choose>
          </li>
        </ul>
        <ul class="list-group list-group-flush">
          <li class="list-group-item">
            <span class="lead">Kindelemente:</span>
              <xsl:choose>
                <xsl:when test="child">
                  <xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
                  <xsl:apply-templates select="child"/>
                </xsl:when>
                <xsl:otherwise>
                  -
                </xsl:otherwise>
              </xsl:choose>
          </li>
        </ul>
        <br/>
        <h5 class="card-title">Attribute</h5>
        <hr/>
        <div class="card-columns">
          <xsl:choose>
            <xsl:when test="attribute">
              <xsl:apply-templates select="attribute"/>
            </xsl:when>
            <xsl:otherwise>
              <p>Dieses Element hat keine Attribute</p>
            </xsl:otherwise>
          </xsl:choose>
        </div>
      </div>
    </div>
    <div class="toTop"><a href="#index"> [ top ] </a></div>
  </xsl:template>

  <xsl:template match="element" mode="parent">
    <a href ="#element{@id}"><xsl:value-of select="@name"/></a>
    <xsl:if test="position() != last()">
         <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="child">
    <xsl:variable name="id" select="@id"/> 
    <a href="#element{@id}"><xsl:value-of select="//element[@id = $id]/@name"/></a>
    <xsl:if test="position() != last()">
         <xsl:text>, </xsl:text>
    </xsl:if> 
  </xsl:template>

  <xsl:template match="attribute">
    <div class="card">
      <div class="card-body">
        <h6 class="card-title"><xsl:value-of select="name"/><span class="badge badge-secondary"><xsl:value-of select="use"/></span></h6>
        <h6 class="card-subtitle mb-2 text-muted">
          Namensraum:<xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text>
          <xsl:choose>
            <xsl:when test="boolean(namespace/text())">
              <xsl:value-of select="namespace"/>
            </xsl:when>
            <xsl:otherwise>
              -
            </xsl:otherwise>
          </xsl:choose>
        </h6>
        <hr/>
        <p class="card-text"><xsl:value-of select="description"/></p>
        <table class="table table-bordered">
          <tbody>
            <tr class="d-flex">
              <th scope="row" class="col-sm-2">Datentyp</th>
              <xsl:choose>
                <xsl:when test="type/@name">
                  <td class="col-sm-10"><xsl:value-of select="type/@name"/></td>
                </xsl:when>
                <xsl:otherwise>
                  <td class="col-sm-10">-</td>
                </xsl:otherwise>
              </xsl:choose>
            </tr>
            <tr class="d-flex">
              <th scope="row" class="col-sm-2">Parameter</th>
              <xsl:choose>
                <xsl:when test="type/param/@name">
                  <td class="col-sm-10"><xsl:value-of select="type/param/@name"/>: <xsl:value-of select="type/param/text()"/></td>
                </xsl:when>
                <xsl:otherwise>
                  <td class="col-sm-10">-</td>
                </xsl:otherwise>
              </xsl:choose>
            </tr>
          </tbody>
        </table> 
      </div>
    </div>
  </xsl:template>

  <xsl:template name="head">
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
      <meta name="description" content=""/>
      <meta name="viewport" content="width=device-width, initial-scale=1"/>
      <xsl:call-template name="style"/>
      <title>RELAX-NG Schema documentation</title>
    </head>
  </xsl:template>

  <xsl:template name="nav">
    <nav class="navbar navbar-expand-md navbar-light bg-light" role="navigation">
      <div class="navbar-header">
        <a class="navbar-brand" href="#">RELAX-NG Schema Dokumentation</a>
      </div>
    </nav>
  </xsl:template>

  <xsl:template name="footer">
    <footer class="footer">
      <div class="text-center" lang="en">
        Created with <i class="fa fa-heart secondary-colour"><xsl:text disable-output-escaping="yes"><![CDATA[&nbsp;]]></xsl:text></i> by jloehel for the SUSE documentation team
      </div>
    </footer>
  </xsl:template>

  <xsl:template name="scripts">
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js" integrity="sha384-smHYKdLADwkXOn1EmN1qk/HfnUcbVRZyYmZ4qpPea6sjB/pTJ0euyQp0Mk8ck+5T" crossorigin="anonymous"></script>
  </xsl:template>

  <xsl:template name="style">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/css/bootstrap.min.css" integrity="sha384-WskhaSGFgHYWDcbwN70/dfYBj47jz9qbsMId/iRN3ewGhXQFZCSftd1LZCfmhktB" crossorigin="anonymous"/>
    <link href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" crossorigin="anonymous"/>
    <style>
      .footer {
        height: 60px;
        line-height: 60px;
        width: 100%;
        background-color: #f5f5f5;
      }

      .navbar {
          margin-bottom: 20px;
      }

      .svg {
          margin-top: 10px;
          margin-bottom: 10px;
      }
      
      #index {
        margin-bottom: 40px;
      }

      .borderless {
          border: 0;
      }

      .toTop {
        margin-bottom: 30px;
        margin-top: 10px;
      }

      .index {
        margin-bottom: 10px;
      }

      .badge {
        margin-left: 3px;
      }


      @media (min-width: 576px) {
          .card-columns {
              column-count: 1;
          }
      }

      @media (min-width: 768px) {
          .card-columns {
              column-count: 1;
          }
      }

      @media (min-width: 992px) {
          .card-columns {
              column-count: 1;
          }
      }

      @media (min-width: 1200px) {
          .card-columns {
              column-count: 1;
          }
      }
    </style>
  </xsl:template>

</xsl:stylesheet>
