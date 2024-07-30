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
      <xsl:apply-templates mode="TCC_InsertTransitiveEdges" select="."/>
   </xsl:template>
   <xsl:template match="/" mode="TCC_InsertTransitiveEdges">
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
         <xsl:apply-templates mode="LookTransitive" select="$sgp">
            <xsl:with-param name="pnds" select="null"/>
            <xsl:with-param name="counter" select="0"/>
            <xsl:with-param name="_targetDom_Key" select="$xid"/>
         </xsl:apply-templates>
         <xsl:apply-templates mode="NodeToNode" select="$xmiXMI">
            <xsl:with-param name="_targetDom_Key" select="$xid"/>
         </xsl:apply-templates>
         <xsl:apply-templates mode="EdgeToEdge" select="$xmiXMI">
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
   <!--Relation : LookTransitive--><xsl:template match="nodes" mode="LookTransitive">
      <xsl:param name="pnds"/>
      <xsl:param name="counter"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="nd" select="current()"/>
      <xsl:variable name="nid" select="$nd/@xmi:id"/>
      <xsl:variable name="sgp" select="$nd/parent::node()"/>
      <xsl:variable name="lknodes"
                    select=" if ($counter &gt; 1) then null else my:GetLinkedNodes($nd) "/>
      <xsl:variable name="newpnds" select="insert-before($pnds, count($pnds)+1, $nd)"/>
      <xsl:variable name="newcounter" select="$counter + 1"/>
      <xsl:variable name="firstnd" select="$pnds[1]"/>
      <xsl:variable name="dlinks"
                    select=" if ($counter &gt; 1) then my:GetLinks($firstnd,$nd) else null "/>
      <xsl:if test="$counter &gt; 1 and empty($dlinks) and $nid!=$firstnd/@xmi:id">
         <xsl:apply-templates mode="InsertEdge" select="$nd">
            <xsl:with-param name="fnd" select="$firstnd"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="$counter&lt;=1">
         <xsl:apply-templates mode="LookTransitive" select="$lknodes">
            <xsl:with-param name="pnds" select="$newpnds"/>
            <xsl:with-param name="counter" select="$newcounter"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
   </xsl:template>
   <!--Relation : NodeToNode--><xsl:template match="//nodes[parent::node()]" mode="NodeToNode">
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="snd" select="current()"/>
      <xsl:variable name="nm" select="$snd/@name"/>
      <xsl:variable name="sid" select="$snd/@xmi:id"/>
      <xsl:variable name="sgp" select="$snd/parent::node()"/>
      <xsl:variable name="tgp" as="item()*">
         <xsl:apply-templates mode="_func_GraphToGraph" select="$sgp"/>
      </xsl:variable>
      <xsl:if test="$tgp and $tgp/@xmi:id=$_targetDom_Key">
         <xsl:element name="nodes">
            <xsl:attribute name="name" select="$nm"/>
            <xsl:attribute name="xmi:id" select="$sid"/>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <xsl:template match="nodes[parent::node()]" mode="_func_NodeToNode">
      <xsl:variable name="snd" select="current()"/>
      <xsl:variable name="nm" select="$snd/@name"/>
      <xsl:variable name="sid" select="$snd/@xmi:id"/>
      <xsl:variable name="sgp" select="$snd/parent::node()"/>
      <xsl:variable name="tgp" as="item()*">
         <xsl:apply-templates mode="_func_GraphToGraph" select="$sgp"/>
      </xsl:variable>
      <xsl:element name="nodes">
         <xsl:attribute name="name" select="$nm"/>
         <xsl:attribute name="xmi:id" select="$sid"/>
      </xsl:element>
   </xsl:template>
   <!--Relation : EdgeToEdge--><xsl:template match="//edges[parent::node()]" mode="EdgeToEdge">
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="sed" select="current()"/>
      <xsl:variable name="eid" select="$sed/@xmi:id"/>
      <xsl:variable name="sgp" select="$sed/parent::node()"/>
      <xsl:variable name="tn" select="my:xmiXMIrefs($sed/@trg)[name()='nodes']"/>
      <xsl:variable name="sn" select="my:xmiXMIrefs($sed/@src)[name()='nodes']"/>
      <xsl:variable name="tgp" as="item()*">
         <xsl:apply-templates mode="_func_GraphToGraph" select="$sgp"/>
      </xsl:variable>
      <xsl:if test="$tgp and $tgp/@xmi:id=$_targetDom_Key">
         <xsl:element name="edges">
            <xsl:attribute name="xmi:id" select="$eid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'src'"/>
               <xsl:attribute name="value" select="string-join($sn/@xmi:id,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'trg'"/>
               <xsl:attribute name="value" select="string-join($tn/@xmi:id,' ')"/>
            </xsl:element>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <xsl:template match="edges[parent::node()]" mode="_func_EdgeToEdge">
      <xsl:variable name="sed" select="current()"/>
      <xsl:variable name="eid" select="$sed/@xmi:id"/>
      <xsl:variable name="sgp" select="$sed/parent::node()"/>
      <xsl:variable name="tn" select="my:xmiXMIrefs($sed/@trg)[name()='nodes']"/>
      <xsl:variable name="sn" select="my:xmiXMIrefs($sed/@src)[name()='nodes']"/>
      <xsl:variable name="tgp" as="item()*">
         <xsl:apply-templates mode="_func_GraphToGraph" select="$sgp"/>
      </xsl:variable>
      <xsl:element name="edges">
         <xsl:attribute name="xmi:id" select="$eid"/>
      </xsl:element>
   </xsl:template>
   <!--Relation : InsertEdge--><xsl:template match="nodes" mode="InsertEdge">
      <xsl:param name="fnd"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="nd" select="current()"/>
      <xsl:variable name="sgp" select="$nd/parent::node()"/>
      <xsl:variable name="eid" select="concat('_0.@edges.',$fnd/@name,'.',$nd/@name)"/>
      <xsl:element name="edges">
         <xsl:attribute name="xmi:id" select="$eid"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'trg'"/>
            <xsl:attribute name="value" select="string-join($nd/@xmi:id,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'src'"/>
            <xsl:attribute name="value" select="string-join($fnd/@xmi:id,' ')"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:function name="my:GetLinks">
      <xsl:param name="snd"/>
      <xsl:param name="tnd"/>
      <xsl:variable name="eds" select="$snd/parent::node()/edges"/>
      <xsl:variable name="result"
                    select="$eds[my:xmiXMIrefs(@src)[name()='nodes']/@xmi:id=$snd/@xmi:id&#xA;and my:xmiXMIrefs(@trg)[name()='nodes']/@xmi:id=$tnd/@xmi:id]"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetLinkedNodes">
      <xsl:param name="nd"/>
      <xsl:variable name="nid" select="$nd/@xmi:id"/>
      <xsl:variable name="eds" select="$nd/parent::node()/edges"/>
      <xsl:variable name="result"
                    select="my:xmiXMIrefs($eds[my:xmiXMIrefs(@src)[name()='nodes']/@xmi:id=$nid][ not(my:xmiXMIrefs(@trg)[name()='nodes']/@xmi:id=$nid)]/@trg)[name()='nodes']"/>
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