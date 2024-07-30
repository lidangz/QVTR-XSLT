<?xml version="1.0" encoding="UTF-8"?>
<!--Source model name : C:\sharefile\QVTR_XSLT homepage\QVTR-XSLT_tool\test\TTC-HelloWorld.xml--><xsl:stylesheet xmlns:my="http:///rcos.iist.unu.edu/2008/lidan"
                xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore"
                xmlns:rCOS="http://rcos.iist.unu.edu/rCOS.profile.uml"
                xmlns:uml="http://www.eclipse.org/uml2/3.0.0/UML"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:di="http://www.topcased.org/DI/1.0"
                xmlns:diagrams="http://www.topcased.org/Diagrams/1.0"
                xmlns:graph1="graph1"
                xmlns:xmi="http://www.omg.org/XMI"
                xmlns:graph3="graph3"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
   <xsl:include href="my_XMI_Merge.xslt"/>
   <xsl:key name="xmiId" match="*" use="@xmi:id"/>
   <xsl:variable name="xmiKeyVar" select="'xmi:id'"/>
   <xsl:variable name="xmiXMI" select="child::node()"/>
   <xsl:variable name="sourceTypedModels" select="''"/>
   <xsl:template match="/">
      <xsl:apply-templates mode="TTC_TopologyMigration" select="."/>
   </xsl:template>
   <xsl:template match="/" mode="TTC_TopologyMigration">
      <xsl:variable name="linkEleResult">
         <xsl:apply-templates mode="GraphToGraph"/>
      </xsl:variable>
      <xsl:apply-templates mode="XMI_EleToLinkCopy" select="$linkEleResult/*"/>
   </xsl:template>
   <!--Relation : GraphToGraph--><xsl:template match="//graph1:Graph" mode="GraphToGraph">
      <xsl:variable name="sgp" select="current()"/>
      <xsl:variable name="xid" select="$sgp/@xmi:id"/>
      <xsl:variable name="_targetDom_Key" select="$xid"/>
      <xsl:element name="graph3:Graph">
         <xsl:namespace name="graph3" select="'graph3'"/>
         <xsl:namespace name="xmi" select="'http://www.omg.org/XMI'"/>
         <xsl:attribute name="xmi:id" select="$xid"/>
         <xsl:apply-templates mode="NodeToNode" select="$xmiXMI">
            <xsl:with-param name="_targetDom_Key" select="$xid"/>
         </xsl:apply-templates>
      </xsl:element>
   </xsl:template>
   <xsl:template match="graph1:Graph" mode="_func_GraphToGraph">
      <xsl:variable name="sgp" select="current()"/>
      <xsl:variable name="xid" select="$sgp/@xmi:id"/>
      <xsl:element name="graph3:Graph">
         <xsl:attribute name="xmi:id" select="$xid"/>
      </xsl:element>
   </xsl:template>
   <!--Relation : NodeToNode--><xsl:template match="//nodes[parent::node()]" mode="NodeToNode">
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="nd" select="current()"/>
      <xsl:variable name="nm" select="$nd/@name"/>
      <xsl:variable name="xid" select="$nd/@xmi:id"/>
      <xsl:variable name="sgp" select="$nd/parent::node()"/>
      <xsl:variable name="tnodes" select="my:GetTrgNodes($nd)"/>
      <xsl:variable name="tgp" as="item()*">
         <xsl:apply-templates mode="_func_GraphToGraph" select="$sgp"/>
      </xsl:variable>
      <xsl:if test="$tgp and $tgp/@xmi:id=$_targetDom_Key">
         <xsl:element name="nodes">
            <xsl:attribute name="text" select="$nm"/>
            <xsl:attribute name="xmi:id" select="$xid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'linksTo'"/>
               <xsl:attribute name="value" select="string-join($tnodes/@xmi:id,' ')"/>
            </xsl:element>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <xsl:template match="nodes[parent::node()]" mode="_func_NodeToNode">
      <xsl:variable name="nd" select="current()"/>
      <xsl:variable name="nm" select="$nd/@name"/>
      <xsl:variable name="xid" select="$nd/@xmi:id"/>
      <xsl:variable name="sgp" select="$nd/parent::node()"/>
      <xsl:variable name="tnodes" select="my:GetTrgNodes($nd)"/>
      <xsl:variable name="tgp" as="item()*">
         <xsl:apply-templates mode="_func_GraphToGraph" select="$sgp"/>
      </xsl:variable>
      <xsl:element name="nodes">
         <xsl:attribute name="text" select="$nm"/>
         <xsl:attribute name="xmi:id" select="$xid"/>
      </xsl:element>
   </xsl:template>
   <xsl:function name="my:GetTrgNodes">
      <xsl:param name="sn"/>
      <xsl:variable name="eds" select="$xmiXMI//edges"/>
      <xsl:variable name="result"
                    select="my:xmiXMIrefs($eds[my:xmiXMIrefs(@src)[name()='nodes']/@xmi:id=$sn/@xmi:id]/@trg)[name()='nodes']"/>
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