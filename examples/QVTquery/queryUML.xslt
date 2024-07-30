<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:my="http:///rcos.iist.unu.edu/2008/lidan"
                xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore"
                xmlns:rCOS="http://rcos.iist.unu.edu/rCOS.profile.uml"
                xmlns:uml="http://www.omg.org/spec/UML/20110701"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:di="http://www.topcased.org/DI/1.0"
                xmlns:diagrams="http://www.topcased.org/Diagrams/1.0"
                xmlns:xmi="http://www.omg.org/spec/XMI/20110701"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
   <xsl:output method="html" encoding="UTF-8" indent="yes"/>
   <xsl:include href="my_XMI_Merge.xslt"/>
   <xsl:key name="xmiId" match="*" use="@xmi:id"/>
   <xsl:variable name="xmiKeyVar" select="'xmi:id'"/>
   <xsl:variable name="xmiXMI" select="child::node()"/>
   <xsl:variable name="sourceTypedModels" select="''"/>
   <xsl:template match="/">
      <xsl:apply-templates mode="queryUML" select="."/>
   </xsl:template>
   <xsl:template match="/" mode="queryUML">
      <xsl:variable name="linkEleResult">
         <xsl:apply-templates mode="QueryUML"/>
      </xsl:variable>
      <xsl:apply-templates mode="XMI_EleToLinkCopy" select="$linkEleResult/*"/>
   </xsl:template>
   <xsl:template match="//uml:Package[@xmi:type='uml:Package']" mode="QueryUML">
      <xsl:variable name="uml" select="current()"/>

      <xsl:variable name="clsWithAsso" select="my:GetClsWithAssoNum(3)"/>
      <xsl:variable name="clsWithAssoNum" select="count($clsWithAsso)"/>
      <xsl:variable name="clsNum" select="my:CountClass()"/>
      <xsl:variable name="maxdp" select="my:GetMaxDepth()"/>
      <xsl:variable name="_targetDom_Key" select="''"/>
      <xsl:element name="Html">
         <xsl:element name="Head">
            <xsl:element name="title">
               <xsl:value-of select="'Queries on UML superstructure model'"/>
            </xsl:element>
         </xsl:element>
         <xsl:element name="Body">
            <xsl:element name="Table">            
               <xsl:apply-templates mode="Display" select="$uml">
                  <xsl:with-param name="title" select="'Number of classes with 3 assos'"/>
                  <xsl:with-param name="rst" select="$clsWithAssoNum"/>
                  <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
               </xsl:apply-templates>            
               <xsl:apply-templates mode="Display" select="$uml">
                  <xsl:with-param name="title" select="'Number of classes'"/>
                  <xsl:with-param name="rst" select="$clsNum"/>
                  <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
               </xsl:apply-templates>
               <xsl:apply-templates mode="Display" select="$uml">
                  <xsl:with-param name="title" select="'Number of classes with 3 assos'"/>
                  <xsl:with-param name="rst" select="$clsWithAssoNum"/>
                  <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
               </xsl:apply-templates>
               <xsl:apply-templates mode="Display" select="$uml">
                  <xsl:with-param name="title" select="'Max depth'"/>
                  <xsl:with-param name="rst" select="$maxdp"/>
                  <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
               </xsl:apply-templates>
            </xsl:element>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="uml:Package[@xmi:type='uml:Package']" mode="_func_QueryUML">
      <xsl:variable name="uml" select="current()"/>
      <xsl:variable name="clsNum" select="my:CountClass()"/>
      <xsl:variable name="clsWithAsso" select="my:GetClsWithAssoNum(3)"/>
      <xsl:variable name="clsWithAssoNum" select="count($clsWithAsso)"/>
      <xsl:variable name="maxdp" select="my:GetMaxDepth()"/>
      <xsl:element name="Html"/>
   </xsl:template>
   <xsl:template match="*" mode="Display">
      <xsl:param name="title"/>
      <xsl:param name="rst"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:element name="Tr">
         <xsl:element name="td">
            <xsl:value-of select="concat($title,concat(' : ',$rst))"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:function name="my:GetAttributeName">
      <xsl:param name="c"/>
      <xsl:variable name="result"
                    select="$c/ownedAttribute[@xmi:type='uml:Property'][@visibility='public'][@xmi:type='uml:Property' and @visibility='public' and type[@xmi:type='uml:PrimitiveType'] and not(my:xmiXMIrefs(@association)[@xmi:type='uml:Association'])]/@name"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetLinkedClass">
      <xsl:param name="c"/>
      <xsl:variable name="result"
                    select="my:xmiXMIrefs(my:xmiXMIrefs($c/ownedAttribute[@xmi:type='uml:Property']/@association)[@xmi:type='uml:Association']/ownedEnd[@xmi:type='uml:Property']/@type)[@xmi:type='uml:Class'][2]"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetClsWithAssoNum">
      <xsl:param name="assoNum"/>
      <xsl:variable name="cls" select="$xmiXMI//packagedElement[@xmi:type='uml:Class']"/>
      <xsl:variable name="result"
                    select="$cls[count(ownedAttribute[@xmi:type='uml:Property']/@association)=$assoNum]"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:FindName">
      <xsl:param name="p"/>
      <xsl:variable name="result" select="$p//*[matches(@name,'Action*')]"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetClassByName">
      <xsl:param name="name"/>
      <xsl:variable name="result"
                    select="$xmiXMI//packagedElement[@xmi:type='uml:Class'][@name=$name][@xmi:type='uml:Class' and @name=$name]"/>
      <xsl:variable name="cnm" select="$result/@name"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:CountClass">
      <xsl:variable name="cls" select="$xmiXMI//packagedElement[@xmi:type='uml:Class']"/>
      <xsl:variable name="result" select="count($cls)"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetMaxDepth">
      <xsl:variable name="cls" select="$xmiXMI//packagedElement[@xmi:type='uml:Class']"/>
      <xsl:variable name="depths" select="(for $c in $cls return my:CountSuper($c,0))"/>
      <xsl:variable name="result" select="max($depths)"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:CountSuper">
      <xsl:param name="c"/>
      <xsl:param name="num"/>
      <xsl:variable name="sc"
                    select="my:xmiXMIrefs($c/generalization[@xmi:type='uml:Generalization']/@general)[@xmi:type='uml:Class']"/>
      <xsl:variable name="cnum" select="$num + 1"/>
      <xsl:variable name="supers"
                    select=" if (not(exists($sc))) then $cnum else (for $s in $sc return my:CountSuper($s,$cnum)) "/>
      <xsl:variable name="result" select="max($supers)"/>
      <xsl:sequence select="$result"/>
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