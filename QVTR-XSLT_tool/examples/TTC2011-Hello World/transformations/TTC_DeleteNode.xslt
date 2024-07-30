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
      <xsl:apply-templates mode="TTC_DeleteNode" select="."/>
   </xsl:template>
   <xsl:template match="/" mode="TTC_DeleteNode">
      <xsl:variable name="diffResult">
         <xsl:apply-templates mode="DelNode"/>
      </xsl:variable>
      <xsl:variable name="diffResult2">
         <xsl:apply-templates mode="XMI_EleToLinkCopy" select="$diffResult/*"/>
      </xsl:variable>
      <xsl:variable name="diffNumber" select="count($diffResult2//*[@xmiDiff])"/>
      <xsl:choose>
         <xsl:when test="$diffNumber &gt; 0">
            <xsl:message select="concat('_XMI_Diff_Result_Num_: ',$diffNumber)"/>
            <xsl:apply-templates mode="XMI_Merge">
               <xsl:with-param name="xmiDiffList" select="$diffResult2//*[@xmiDiff]"/>
            </xsl:apply-templates>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="."/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!--Relation : DelNode--><xsl:template match="//graph1:Graph[nodes[@name='n1']]" mode="DelNode">
      <xsl:variable name="sg" select="current()"/>
      <xsl:variable name="sid" select="$sg/nodes[@name='n1']/@xmi:id"/>
      <xsl:variable name="_targetDom_Key" select="''"/>
      <xsl:element name="graph1:Graph">
         <xsl:namespace name="graph1" select="'graph1'"/>
         <xsl:namespace name="xmi" select="'http://www.omg.org/XMI'"/>
         <xsl:element name="nodes">
            <xsl:attribute name="xmiDiff" select="'remove'"/>
            <xsl:attribute name="targetId" select="$sid"/>
         </xsl:element>
         <xsl:apply-templates mode="DelEdge" select="$sg">
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:element>
   </xsl:template>
   <xsl:template match="graph1:Graph[nodes[@name='n1']]" mode="_func_DelNode">
      <xsl:variable name="sg" select="current()"/>
      <xsl:variable name="sid" select="$sg/nodes[@name='n1']/@xmi:id"/>
      <xsl:element name="graph1:Graph"/>
   </xsl:template>
   <!--Relation : DelEdge--><xsl:template match="edges[my:xmiXMIrefs(@src)[name()='nodes' and @name='n1'  or  my:xmiXMIrefs(current()/@trg)[name()='nodes']/@name ='n1'] and my:xmiXMIrefs(@trg)[name()='nodes']]"
                 mode="DelEdge">
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="sid" select="current()/@xmi:id"/>
      <xsl:variable name="snm"
                    select="my:xmiXMIrefs(current()/@src)[name()='nodes'][@name='n1'  or  my:xmiXMIrefs(current()/@trg)[name()='nodes']/@name ='n1']/@name"/>
      <xsl:variable name="sg" select="current()/parent::node()"/>
      <xsl:variable name="tnm" select="my:xmiXMIrefs(current()/@trg)[name()='nodes']/@name"/>
      <xsl:element name="edges">
         <xsl:attribute name="xmiDiff" select="'remove'"/>
         <xsl:attribute name="targetId" select="$sid"/>
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