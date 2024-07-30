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
                xmlns:result="result"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
   <xsl:include href="my_XMI_Merge.xslt"/>
   <xsl:key name="xmiId" match="*" use="@xmi:id"/>
   <xsl:variable name="xmiKeyVar" select="'xmi:id'"/>
   <xsl:variable name="xmiXMI" select="child::node()"/>
   <xsl:variable name="sourceTypedModels" select="''"/>
   <xsl:template match="/">
      <xsl:apply-templates mode="TTC_CountElements" select="."/>
   </xsl:template>
   <xsl:template match="/" mode="TTC_CountElements">
      <xsl:variable name="linkEleResult">
         <xsl:apply-templates mode="GraphToResult"/>
      </xsl:variable>
      <xsl:apply-templates mode="XMI_EleToLinkCopy" select="$linkEleResult/*"/>
   </xsl:template>
   <!--Relation : ShowIntResult--><xsl:template match="graph1:Graph" mode="ShowIntResult">
      <xsl:param name="title"/>
      <xsl:param name="res"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:element name="ints">
         <xsl:attribute name="result" select="$res"/>
         <xsl:attribute name="text" select="$title"/>
      </xsl:element>
   </xsl:template>
   <!--Relation : ShowBoolResult--><xsl:template match="graph1:Graph" mode="ShowBoolResult">
      <xsl:param name="title"/>
      <xsl:param name="res"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:element name="BoolResult">
         <xsl:attribute name="result" select="$res"/>
         <xsl:attribute name="text" select="$title"/>
      </xsl:element>
   </xsl:template>
   <!--Relation : GraphToResult--><xsl:template match="//graph1:Graph" mode="GraphToResult">
      <xsl:variable name="gp" select="current()"/>
      <xsl:variable name="nodesNumber" select="my:GetNodesNumber($gp)"/>
      <xsl:variable name="loopingEdges" select="my:GetLoopingEdges($gp)"/>
      <xsl:variable name="isolatedNodes" select="my:GetIsolatedNodes($gp)"/>
      <xsl:variable name="circleNumber" select="my:GetAllCircleNodes($gp)"/>
      <xsl:variable name="danglingEdges" select="my:GetDanglingEdges($gp)"/>
      <xsl:variable name="_targetDom_Key" select="''"/>
      <xsl:element name="result:Result">
         <xsl:namespace name="result" select="'result'"/>
         <xsl:namespace name="xmi" select="'http://www.omg.org/XMI'"/>
         <xsl:apply-templates mode="ShowIntResult" select="$gp">
            <xsl:with-param name="title" select="'The number of nodes'"/>
            <xsl:with-param name="res" select="$nodesNumber"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
         <xsl:apply-templates mode="ShowIntResult" select="$gp">
            <xsl:with-param name="title" select="'The number of looping edges'"/>
            <xsl:with-param name="res" select="$loopingEdges"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
         <xsl:apply-templates mode="ShowIntResult" select="$gp">
            <xsl:with-param name="title" select="'The number of isolated nodes'"/>
            <xsl:with-param name="res" select="$isolatedNodes"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
         <xsl:apply-templates mode="ShowIntResult" select="$gp">
            <xsl:with-param name="title" select="'The number of circles of three nodes'"/>
            <xsl:with-param name="res" select="$circleNumber"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
         <xsl:apply-templates mode="ShowIntResult" select="$gp">
            <xsl:with-param name="title" select="'The number of dangling edges'"/>
            <xsl:with-param name="res" select="$danglingEdges"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:element>
   </xsl:template>
   <xsl:template match="graph1:Graph" mode="_func_GraphToResult">
      <xsl:variable name="gp" select="current()"/>
      <xsl:variable name="nodesNumber" select="my:GetNodesNumber($gp)"/>
      <xsl:variable name="loopingEdges" select="my:GetLoopingEdges($gp)"/>
      <xsl:variable name="isolatedNodes" select="my:GetIsolatedNodes($gp)"/>
      <xsl:variable name="circleNumber" select="my:GetAllCircleNodes($gp)"/>
      <xsl:variable name="danglingEdges" select="my:GetDanglingEdges($gp)"/>
      <xsl:element name="result:Result"/>
   </xsl:template>
   <!--Relation : ShowStrResult--><xsl:template match="graph1:Graph" mode="ShowStrResult">
      <xsl:param name="title"/>
      <xsl:param name="res"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:element name="strs">
         <xsl:attribute name="result" select="$res"/>
         <xsl:attribute name="text" select="$title"/>
      </xsl:element>
   </xsl:template>
   <xsl:function name="my:GetLoopingEdges">
      <xsl:param name="gp"/>
      <xsl:variable name="eds" select="$gp/edges"/>
      <xsl:variable name="result"
                    select="count($eds[my:xmiXMIrefs(@src)[name()='nodes']/@xmi:id=my:xmiXMIrefs(@trg)[name()='nodes']/@xmi:id])"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetIsolatedNodes">
      <xsl:param name="gp"/>
      <xsl:variable name="nds" select="$gp/nodes"/>
      <xsl:variable name="snd" select="my:xmiXMIrefs($gp/edges/@src)[name()='nodes']"/>
      <xsl:variable name="tnd" select="my:xmiXMIrefs($gp/edges/@trg)[name()='nodes']"/>
      <xsl:variable name="linkednds"
                    select="my:DoDistinct(insert-before($snd, count($snd)+1, $tnd))"/>
      <xsl:variable name="result" select="count($nds[ not(@xmi:id=$linkednds/@xmi:id)])"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetLinkedNodes">
      <xsl:param name="nd"/>
      <xsl:variable name="nnm" select="$nd/@xmi:id"/>
      <xsl:variable name="eds" select="$nd/parent::node()/edges"/>
      <xsl:variable name="result"
                    select="my:xmiXMIrefs($eds[my:xmiXMIrefs(@src)[name()='nodes']/@xmi:id=$nnm][ not(my:xmiXMIrefs(@trg)[name()='nodes']/@xmi:id=$nnm)]/@trg)[name()='nodes']"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetDanglingEdges">
      <xsl:param name="gp"/>
      <xsl:variable name="eds" select="$gp/edges"/>
      <xsl:variable name="result"
                    select="count($eds[not(exists(my:xmiXMIrefs(@src)[name()='nodes']))&#xA;or not(exists(my:xmiXMIrefs(@trg)[name()='nodes']))])"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetNodesNumber">
      <xsl:param name="gp"/>
      <xsl:variable name="nds" select="$gp/nodes"/>
      <xsl:variable name="result" select="count($nds)"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetCircleNodes">
      <xsl:param name="nd"/>
      <xsl:param name="list"/>
      <xsl:param name="counter"/>      <xsl:variable name="lnds" select="my:GetLinkedNodes($nd)"/>
      
      <xsl:for-each select="$lnds">
        <xsl:variable name="cnd" select="."/>
        
        <xsl:choose>
			<xsl:when test="$counter=0 and $list[1][@xmi:id=$cnd/@xmi:id]">
				<xsl:variable name="rrr" as="item()*">
					<xsl:for-each select="$list">
						<xsl:sort select="@xmi:id" data-type="text" order="ascending"/>
						<val><xsl:value-of select="./@xmi:id"/></val>
					</xsl:for-each>
				</xsl:variable>
				<val><xsl:value-of select="string-join($rrr,'')"/></val>
			</xsl:when>
			<xsl:when test="$counter>0 and not($list[@xmi:id=$cnd/@xmi:id])">
				<xsl:variable name="newlist" select="insert-before($list,count($list)+1,$cnd)"/>
				<xsl:sequence select="my:GetCircleNodes($cnd,$newlist,$counter - 1)"/>
			</xsl:when>
		</xsl:choose>
      
      </xsl:for-each></xsl:function>
   <xsl:function name="my:GetAllCircleNodes">
      <xsl:param name="gp"/>      <xsl:variable name="nds" select="$gp/nodes"/>            
	  <xsl:variable name="allcnodes" as="item()*">
		<xsl:for-each select="$nds">
			<xsl:sequence select="my:GetCircleNodes(.,.,2)"/>
		</xsl:for-each>  
	  </xsl:variable>      
      <xsl:sequence select="count(distinct-values($allcnodes))"/></xsl:function>
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