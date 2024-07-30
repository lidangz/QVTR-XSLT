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
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
   <xsl:include href="my_XMI_Merge.xslt"/>
   <xsl:key name="xmiId" match="*" use="@xmi:id"/>
   <xsl:variable name="xmiKeyVar" select="'xmi:id'"/>
   <xsl:variable name="xmiXMI" select="child::node()"/>
   <xsl:variable name="sourceTypedModels" select="''"/>
   <xsl:template match="/">
      <xsl:apply-templates mode="TTC_ReverseEdges" select="."/>
   </xsl:template>
   <xsl:template match="/" mode="TTC_ReverseEdges">
      <xsl:variable name="linkEleResult">
         <xsl:apply-templates mode="GraphToGraph"/>
      </xsl:variable>
      <xsl:apply-templates mode="XMI_EleToLinkCopy" select="$linkEleResult/*"/>
   </xsl:template>
   <!--Relation : GraphToGraph--><xsl:template match="//graph1:Graph" mode="GraphToGraph">
      <xsl:variable name="sgp" select="current()"/>
      <xsl:variable name="xid" select="$sgp/@xmi:id"/>
      <xsl:variable name="_targetDom_Key" select="$xid"/>
      <xsl:element name="graph1:Graph">
         <xsl:namespace name="graph1" select="'graph1'"/>
         <xsl:namespace name="xmi" select="'http://www.omg.org/XMI'"/>
         <xsl:attribute name="xmi:id" select="$xid"/>
         <xsl:apply-templates mode="EdgeToEdge" select="$xmiXMI">
            <xsl:with-param name="_targetDom_Key" select="$xid"/>
         </xsl:apply-templates>
         <xsl:apply-templates mode="NodeToNode" select="$xmiXMI">
            <xsl:with-param name="_targetDom_Key" select="$xid"/>
         </xsl:apply-templates>
      </xsl:element>
   </xsl:template>
   <xsl:template match="graph1:Graph" mode="_func_GraphToGraph">
      <xsl:variable name="sgp" select="current()"/>
      <xsl:variable name="xid" select="$sgp/@xmi:id"/>
      <xsl:element name="graph1:Graph">
         <xsl:attribute name="xmi:id" select="$xid"/>
      </xsl:element>
   </xsl:template>
   <!--Relation : EdgeToEdge--><xsl:template match="//edges[parent::node()]" mode="EdgeToEdge">
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="sed" select="current()"/>
      <xsl:variable name="eid" select="$sed/@xmi:id"/>
      <xsl:variable name="tn" select="my:xmiXMIrefs($sed/@trg)[name()='nodes']"/>
      <xsl:variable name="sn" select="my:xmiXMIrefs($sed/@src)[name()='nodes']"/>
      <xsl:variable name="sgp" select="$sed/parent::node()"/>
      <xsl:variable name="tgp" as="item()*">
         <xsl:apply-templates mode="_func_GraphToGraph" select="$sgp"/>
      </xsl:variable>
      <xsl:variable name="sn2" as="item()*">
         <xsl:apply-templates mode="_func_NodeToNode" select="$sn"/>
      </xsl:variable>
      <xsl:variable name="tn2" as="item()*">
         <xsl:apply-templates mode="_func_NodeToNode" select="$tn"/>
      </xsl:variable>
      <xsl:if test="$tgp and $sn2 and $tn2 and $tgp/@xmi:id=$_targetDom_Key">
         <xsl:element name="edges">
            <xsl:attribute name="xmi:id" select="$eid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'trg'"/>
               <xsl:attribute name="value" select="string-join($sn2/@xmi:id,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'src'"/>
               <xsl:attribute name="value" select="string-join($tn2/@xmi:id,' ')"/>
            </xsl:element>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <xsl:template match="edges[parent::node()]" mode="_func_EdgeToEdge">
      <xsl:variable name="sed" select="current()"/>
      <xsl:variable name="eid" select="$sed/@xmi:id"/>
      <xsl:variable name="tn" select="my:xmiXMIrefs($sed/@trg)[name()='nodes']"/>
      <xsl:variable name="sn" select="my:xmiXMIrefs($sed/@src)[name()='nodes']"/>
      <xsl:variable name="sgp" select="$sed/parent::node()"/>
      <xsl:variable name="tgp" as="item()*">
         <xsl:apply-templates mode="_func_GraphToGraph" select="$sgp"/>
      </xsl:variable>
      <xsl:variable name="sn2" as="item()*">
         <xsl:apply-templates mode="_func_NodeToNode" select="$sn"/>
      </xsl:variable>
      <xsl:variable name="tn2" as="item()*">
         <xsl:apply-templates mode="_func_NodeToNode" select="$tn"/>
      </xsl:variable>
      <xsl:element name="edges">
         <xsl:attribute name="xmi:id" select="$eid"/>
      </xsl:element>
   </xsl:template>
   <!--Relation : NodeToNode--><xsl:template match="//nodes[parent::node()]" mode="NodeToNode">
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="snd" select="current()"/>
      <xsl:variable name="nm" select="$snd/@name"/>
      <xsl:variable name="xid" select="$snd/@xmi:id"/>
      <xsl:variable name="sgp" select="$snd/parent::node()"/>
      <xsl:variable name="tgp" as="item()*">
         <xsl:apply-templates mode="_func_GraphToGraph" select="$sgp"/>
      </xsl:variable>
      <xsl:if test="$tgp and $tgp/@xmi:id=$_targetDom_Key">
         <xsl:element name="nodes">
            <xsl:attribute name="name" select="$nm"/>
            <xsl:attribute name="xmi:id" select="$xid"/>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <xsl:template match="nodes[parent::node()]" mode="_func_NodeToNode">
      <xsl:variable name="snd" select="current()"/>
      <xsl:variable name="nm" select="$snd/@name"/>
      <xsl:variable name="xid" select="$snd/@xmi:id"/>
      <xsl:variable name="sgp" select="$snd/parent::node()"/>
      <xsl:variable name="tgp" as="item()*">
         <xsl:apply-templates mode="_func_GraphToGraph" select="$sgp"/>
      </xsl:variable>
      <xsl:element name="nodes">
         <xsl:attribute name="name" select="$nm"/>
         <xsl:attribute name="xmi:id" select="$xid"/>
      </xsl:element>
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
      <xsl:sequence select="$xmiXMI//*[@xmi:id=$vvvv/child::node()]"/>
   </xsl:function>
</xsl:stylesheet>