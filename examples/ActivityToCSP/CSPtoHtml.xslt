<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:my="http:///rcos.iist.unu.edu/2008/lidan"
                xmlns:xmi="http://schema.omg.org/spec/XMI/2.1"
                xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore"
                xmlns:rCOS="http://rcos.iist.unu.edu/rCOS.profile.uml"
                xmlns:uml="http://www.eclipse.org/uml2/3.0.0/UML"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:di="http://www.topcased.org/DI/1.0"
                xmlns:diagrams="http://www.topcased.org/Diagrams/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
   <xsl:output method="html" encoding="UTF-8" indent="yes"/>
   <xsl:key name="xmiId" match="*" use="@name"/>
   <xsl:variable name="xmiKeyVar" select="'name'"/>
   <xsl:variable name="xmiXMI" select="child::node()"/>
   <xsl:variable name="sourceTypedModels" select="''"/>
   <xsl:template match="/">
      <xsl:apply-templates mode="CSPtoHtml" select="."/>
   </xsl:template>
   <xsl:template match="/" mode="CSPtoHtml">
      <xsl:apply-templates mode="CSPtoHtml"/>
   </xsl:template>
   <xsl:template match="Condition[Process[@type='LEFT'] and Process[@type='RIGHT']]"
                 mode="PEtoTD">
      <xsl:param name="prefix"/>
      <xsl:param name="suffix"/>
      <xsl:message select="concat('PEtoTD(ConditionNextToTD)',' : ',@name,' : ',@name)"/>
      <xsl:variable name="condi" select="current()/@expression"/>
      <xsl:variable name="pa" select="current()/parent::node()"/>
      <xsl:variable name="pnm" select="current()/Process[@type='LEFT']/@name"/>
      <xsl:variable name="pnm2" select="current()/Process[@type='RIGHT']/@name"/>
      <xsl:variable name="txt" select="concat($prefix,$pnm,' &lt;| ',$condi,' |&gt; ',$pnm2,$suffix)"/>
      <xsl:element name="tr">
         <xsl:element name="td">
            <xsl:value-of select="$txt"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="//CspContainer" mode="CSPtoHtml">
      <xsl:message select="concat('CSPtoHtml',' : ',@name,' : ',@name)"/>
      <xsl:variable name="csp" select="current()"/>
      <xsl:element name="html">
         <xsl:element name="head">
            <xsl:element name="title">
               <xsl:value-of select="'Result of Activity to CSP transformation'"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="HtmlBody" select="$csp"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="SKIP" mode="PEtoTD">
      <xsl:param name="prefix"/>
      <xsl:param name="suffix"/>
      <xsl:message select="concat('PEtoTD(SkipToTD)',' : ',@name,' : ',@name)"/>
      <xsl:variable name="pa" select="current()/parent::node()"/>
      <xsl:variable name="txt" select="concat($prefix,' SKIP ')"/>
      <xsl:element name="tr">
         <xsl:element name="td">
            <xsl:value-of select="$txt"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="Process[not(@type='ID')]" mode="PEtoTD">
      <xsl:param name="prefix"/>
      <xsl:param name="suffix"/>
      <xsl:message select="concat('PEtoTD(ProcessToTD)',' : ',@name,' : ',@name)"/>
      <xsl:variable name="pnm" select="current()/@name"/>
      <xsl:variable name="tp" select="current()/@type"/>
      <xsl:variable name="pa" select="current()/parent::node()"/>
      <xsl:variable name="txt" select="concat($prefix,$pnm)"/>
      <xsl:element name="tr">
         <xsl:element name="td">
            <xsl:value-of select="$txt"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="Concurrency[Process[@type='LEFT'] and Concurrency[@type='RIGHT']]"
                 mode="PEtoTD">
      <xsl:param name="prefix"/>
      <xsl:param name="suffix"/>
      <xsl:message select="concat('PEtoTD(ConcurrencyToTD)',' : ',@name,' : ',@name)"/>
      <xsl:variable name="pa" select="current()/parent::node()"/>
      <xsl:variable name="pnm" select="current()/Process[@type='LEFT']/@name"/>
      <xsl:variable name="cnc" select="current()/Concurrency[@type='RIGHT']"/>
      <xsl:variable name="newprefix" select="concat($prefix,$pnm,' || (')"/>
      <xsl:variable name="newsuffix" select="concat(')',$suffix)"/>
      <xsl:apply-templates mode="PEtoTD" select="$cnc">
         <xsl:with-param name="prefix" select="$newprefix"/>
         <xsl:with-param name="suffix" select="$newsuffix"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="CspContainer" mode="HtmlBody">
      <xsl:message select="concat('HtmlBody',' : ',@name,' : ',@name)"/>
      <xsl:variable name="csp" select="current()"/>
      <xsl:element name="body">
         <xsl:element name="table">
            <xsl:apply-templates mode="PAtoTR" select="$csp"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="Concurrency[Process[@type='RIGHT'] and Process[@type='LEFT']]"
                 mode="PEtoTD">
      <xsl:param name="prefix"/>
      <xsl:param name="suffix"/>
      <xsl:message select="concat('PEtoTD(ConcurrencyNextToTD)',' : ',@name,' : ',@name)"/>
      <xsl:variable name="pnm2" select="current()/Process[@type='RIGHT']/@name"/>
      <xsl:variable name="pnm" select="current()/Process[@type='LEFT']/@name"/>
      <xsl:variable name="pa" select="current()/parent::node()"/>
      <xsl:variable name="txt" select="concat($prefix,$pnm,' || ',$pnm2,$suffix)"/>
      <xsl:element name="tr">
         <xsl:element name="td">
            <xsl:value-of select="$txt"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="Prefix[Process and Event]" mode="PEtoTD">
      <xsl:param name="prefix"/>
      <xsl:param name="suffix"/>
      <xsl:message select="concat('PEtoTD(PrefixToTD)',' : ',@name,' : ',@name)"/>
      <xsl:variable name="pnm" select="current()/Process/@name"/>
      <xsl:variable name="evnm" select="current()/Event/@name"/>
      <xsl:variable name="pa" select="current()/parent::node()"/>
      <xsl:variable name="txt" select="concat($prefix,$evnm,' -&gt; ',$pnm)"/>
      <xsl:element name="tr">
         <xsl:element name="td">
            <xsl:value-of select="$txt"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="Prefix[Event and SKIP]" mode="PEtoTD">
      <xsl:param name="prefix"/>
      <xsl:param name="suffix"/>
      <xsl:message select="concat('PEtoTD(PrefixSkipToTD)',' : ',@name,' : ',@name)"/>
      <xsl:variable name="evnm" select="current()/Event/@name"/>
      <xsl:variable name="pa" select="current()/parent::node()"/>
      <xsl:variable name="txt" select="concat($prefix,$evnm,' -&gt; SKIP ')"/>
      <xsl:element name="tr">
         <xsl:element name="td">
            <xsl:value-of select="$txt"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="Condition[Condition[@type='RIGHT'] and Process[@type='LEFT']]"
                 mode="PEtoTD">
      <xsl:param name="prefix"/>
      <xsl:param name="suffix"/>
      <xsl:message select="concat('PEtoTD(ConditionToTD)',' : ',@name,' : ',@name)"/>
      <xsl:variable name="condi" select="current()/@expression"/>
      <xsl:variable name="pa" select="current()/parent::node()"/>
      <xsl:variable name="cd" select="current()/Condition[@type='RIGHT']"/>
      <xsl:variable name="pnm" select="current()/Process[@type='LEFT']/@name"/>
      <xsl:variable name="newprefix" select="concat($prefix,$pnm,' &lt;| ',$condi,' |&gt; (')"/>
      <xsl:variable name="newsuffix" select="concat(')',$suffix)"/>
      <xsl:apply-templates mode="PEtoTD" select="$cd">
         <xsl:with-param name="prefix" select="$newprefix"/>
         <xsl:with-param name="suffix" select="$newsuffix"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="ProcessAssignment[Process[@type='ID']]" mode="PAtoTR">
      <xsl:message select="concat('PAtoTR',' : ',@name,' : ',@name)"/>
      <xsl:variable name="pa" select="current()"/>
      <xsl:variable name="idnm" select="$pa/Process[@type='ID']/@name"/>
      <xsl:variable name="csp" select="$pa/parent::node()"/>
      <xsl:variable name="prefix" select="concat($idnm,' =  ')"/>
      <xsl:variable name="suffix" select="''"/>
      <xsl:apply-templates mode="PEtoTD" select="$pa">
         <xsl:with-param name="prefix" select="$prefix"/>
         <xsl:with-param name="suffix" select="$suffix"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="text()" mode="#all" priority="1"/>
   <xsl:function name="my:xmiXMIrefs">
      <xsl:param name="refer2"/>
      <xsl:variable name="vvvv">
         <xsl:for-each select="$refer2">
            <xsl:variable name="refer" select="."/>
            <xsl:choose>
               <xsl:when test="contains($refer,' ')">
                  <xsl:analyze-string select="$refer" regex="\s+" flags="m">
                     <xsl:non-matching-substring>
                        <val>
                           <xsl:value-of select="."/>
                        </val>
                     </xsl:non-matching-substring>
                  </xsl:analyze-string>
               </xsl:when>
               <xsl:otherwise>
                  <val>
                     <xsl:value-of select="$refer"/>
                  </val>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each>
      </xsl:variable>
      <xsl:sequence select="$xmiXMI//*[@name=$vvvv/child::node()]"/>
   </xsl:function>
</xsl:stylesheet>