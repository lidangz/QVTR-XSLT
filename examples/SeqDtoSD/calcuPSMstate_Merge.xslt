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
   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
   <xsl:include href="my_XMI_Merge.xslt"/>
   <xsl:key name="xmiId" match="*" use="@xmi:id"/>
   <xsl:variable name="xmiKeyVar" select="'xmi:id'"/>
   <xsl:param name="diffResult" as="item()*" required="yes"/>
   <xsl:variable name="xmiXMI" select="child::node()"/>
   <xsl:variable name="sourceTypedModels" select="''"/>
   <xsl:template match="/">
      <xsl:apply-templates mode="calcuPSMstate" select="."/>
   </xsl:template>
   <xsl:template match="/" mode="calcuPSMstate">
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