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
   <xsl:key name="xmiId" match="*" use="@xmi:id"/>
   <xsl:variable name="xmiKeyVar" select="'xmi:id'"/>
   <xsl:variable name="xmiXMI" select="child::node()"/>
   <xsl:variable name="sourceTypedModels" select="''"/>
   <xsl:template match="/">
      <xsl:apply-templates mode="multiToOCLHtml" select="."/>
   </xsl:template>
   <xsl:template match="/" mode="multiToOCLHtml">
      <xsl:apply-templates mode="RootToRoot"/>
   </xsl:template>
   <xsl:template match="ownedAttribute[upperValue[@xmi:type='uml:LiteralUnlimitedNatural' and @value='1'] and my:xmiXMIrefs(@type)[@xmi:type='uml:Class'] and lowerValue[@xmi:type='uml:LiteralInteger' and @value='1'] and my:xmiXMIrefs(@association)[@xmi:type='uml:Association']]"
                 mode="AssoEndToOCL"
                 priority="10">
      <xsl:message select="concat('AssoEndToOCL(AssoEndToOCL_1)',' : ',@xmi:id,' : ',@name)"/>
      <xsl:variable name="asn" select="current()"/>
      <xsl:variable name="asnnm" select="$asn/@name"/>
      <xsl:variable name="sc" select="$asn/parent::node()"/>
      <xsl:variable name="scnm" select="$sc/@name"/>
      <xsl:variable name="asnm"
                    select="my:xmiXMIrefs($asn/@association)[@xmi:type='uml:Association']/@name"/>
      <xsl:variable name="assoNm" select=" if ($asnnm!='') then $asnnm else $asnm "/>
      <xsl:variable name="csnm" select="concat('I_',$scnm,'_',$assoNm,'_size')"/>
      <xsl:variable name="ocl" select="concat('self.',$assoNm,'-&gt;size()= 1')"/>
      <xsl:variable name="txt" select="concat('  inv ',$csnm,': ',$ocl)"/>
      <xsl:element name="tr">
         <xsl:element name="td">
            <xsl:value-of select="$txt"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="packagedElement[@xmi:type='uml:Class']" mode="ClassToClass">
      <xsl:message select="concat('ClassToClass',' : ',@xmi:id,' : ',@name)"/>
      <xsl:variable name="sc" select="current()"/>
      <xsl:variable name="scn" select="$sc/@name"/>
      <xsl:variable name="sm" select="$sc/parent::node()"/>
      <xsl:variable name="txt" select="concat('context ',$scn)"/>
      <xsl:element name="tr">
         <xsl:element name="td">
            <xsl:value-of select="$txt"/>
         </xsl:element>
      </xsl:element>
      <xsl:apply-templates mode="AssoEndToOCL" select="$sc"/>
   </xsl:template>
   <xsl:template match="ownedAttribute[empty(current()/lowerValue[@xmi:type='uml:LiteralInteger']/@value) and upperValue[@xmi:type='uml:LiteralUnlimitedNatural' and @value='*'] and lowerValue[@xmi:type='uml:LiteralInteger'] and my:xmiXMIrefs(@association)[@xmi:type='uml:Association'] and my:xmiXMIrefs(@type)[@xmi:type='uml:Class']]"
                 mode="AssoEndToOCL"
                 priority="100">
      <xsl:message select="concat('AssoEndToOCL(AssoEndToOCL_No)',' : ',@xmi:id,' : ',@name)"/>
      <xsl:variable name="asn" select="current()"/>
      <xsl:variable name="sc" select="$asn/parent::node()"/>
   </xsl:template>
   <xsl:template match="//xmi:XMI[uml:Model]" mode="RootToRoot">
      <xsl:message select="concat('RootToRoot',' : ',@xmi:id,' : ',@name)"/>
      <xsl:variable name="sm" select="current()/uml:Model"/>
      <xsl:variable name="smnm" select="$sm/@name"/>
      <xsl:variable name="txt"
                    select="concat('Generate OCL constrains from association multiplicity :',$smnm)"/>
      <xsl:element name="html">
         <xsl:element name="body">
            <xsl:element name="table">
               <xsl:apply-templates mode="ClassToClass" select="$sm"/>
            </xsl:element>
         </xsl:element>
         <xsl:element name="head">
            <xsl:element name="title">
               <xsl:value-of select="$txt"/>
            </xsl:element>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="ownedAttribute[upperValue[@xmi:type='uml:LiteralUnlimitedNatural'] and my:xmiXMIrefs(@type)[@xmi:type='uml:Class'] and lowerValue[@xmi:type='uml:LiteralInteger'] and my:xmiXMIrefs(@association)[@xmi:type='uml:Association']]"
                 mode="AssoEndToOCL">
      <xsl:message select="concat('AssoEndToOCL',' : ',@xmi:id,' : ',@name)"/>
      <xsl:variable name="asn" select="current()"/>
      <xsl:variable name="asnnm" select="$asn/@name"/>
      <xsl:variable name="uv"
                    select="$asn/upperValue[@xmi:type='uml:LiteralUnlimitedNatural']/@value"/>
      <xsl:variable name="sc" select="$asn/parent::node()"/>
      <xsl:variable name="scnm" select="$sc/@name"/>
      <xsl:variable name="lv" select="$asn/lowerValue[@xmi:type='uml:LiteralInteger']/@value"/>
      <xsl:variable name="asnm"
                    select="my:xmiXMIrefs($asn/@association)[@xmi:type='uml:Association']/@name"/>
      <xsl:variable name="assoNm" select=" if ($asnnm!='') then $asnnm else $asnm "/>
      <xsl:variable name="csnm" select="concat('I_',$scnm,'_',$assoNm,'_size')"/>
      <xsl:variable name="oclhigh"
                    select=" if ($uv!='*') then concat('self.',$assoNm,'-&gt;size()&lt;=',$uv) else '' "/>
      <xsl:variable name="ocllow"
                    select=" if (exists($lv)) then concat('self.',$assoNm,'-&gt;size()&gt;=',$lv) else '' "/>
      <xsl:variable name="txt"
                    select="concat('  inv ',$csnm,': ', if ($oclhigh!='' and $ocllow!='') then concat($ocllow,' and ',$oclhigh) else concat($ocllow,$oclhigh) )"/>
      <xsl:element name="tr">
         <xsl:element name="td">
            <xsl:value-of select="$txt"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:function name="my:GetNewId"><xsl:param name="in"/>	
<xsl:param name="pos"/>
		   
<xsl:variable name="p1" select="substring($in,1,$pos)"/>

<xsl:variable name="p2" select="substring($in,$pos+1)"/>
		   
<xsl:value-of select="concat($p2,$p1)"/>
</xsl:function>
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
      <xsl:sequence select="$xmiXMI//*[@xmi:id=$vvvv/child::node()]"/>
   </xsl:function>
</xsl:stylesheet>