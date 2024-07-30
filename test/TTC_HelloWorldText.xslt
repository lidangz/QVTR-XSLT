<?xml version="1.0" encoding="UTF-8"?>
<!--Source model name : C:\sharefile\QVTR_XSLT homepage\QVTR-XSLT_tool\test\TTC-HelloWorld.xml--><xsl:stylesheet xmlns:my="http:///rcos.iist.unu.edu/2008/lidan"
                xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore"
                xmlns:rCOS="http://rcos.iist.unu.edu/rCOS.profile.uml"
                xmlns:uml="http://www.eclipse.org/uml2/3.0.0/UML"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:di="http://www.topcased.org/DI/1.0"
                xmlns:diagrams="http://www.topcased.org/Diagrams/1.0"
                xmlns:helloworldext="helloworldext"
                xmlns:xmi="http://www.omg.org/XMI"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
   <xsl:output method="html" encoding="UTF-8" indent="yes"/>
   <xsl:key name="xmiId" match="*" use="@text"/>
   <xsl:variable name="xmiKeyVar" select="'text'"/>
   <xsl:variable name="xmiXMI" select="child::node()"/>
   <xsl:variable name="sourceTypedModels" select="''"/>
   <xsl:template match="/">
      <xsl:apply-templates mode="TTC_HelloWorldText" select="."/>
   </xsl:template>
   <xsl:template match="/" mode="TTC_HelloWorldText">
      <xsl:apply-templates mode="HelloWorldText"/>
   </xsl:template>
   <!--Relation : HelloWorldText--><xsl:template match="//helloworldext:Greeting[greetingMessage and person]"
                 mode="HelloWorldText">
      <xsl:variable name="greet" select="current()/greetingMessage/@text"/>
      <xsl:variable name="nm" select="current()/person/@name"/>
      <xsl:variable name="_targetDom_Key" select="''"/>
      <xsl:element name="html">
         <xsl:element name="body">
            <xsl:element name="table">
               <xsl:element name="tr">
                  <xsl:element name="td">
                     <xsl:value-of select="concat($greet,concat(' ',concat($nm,' !')))"/>
                  </xsl:element>
               </xsl:element>
            </xsl:element>
         </xsl:element>
         <xsl:element name="head">
            <xsl:element name="title">
               <xsl:value-of select="'Hello World model-to-text transformation'"/>
            </xsl:element>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="helloworldext:Greeting[greetingMessage and person]"
                 mode="_func_HelloWorldText">
      <xsl:variable name="greet" select="current()/greetingMessage/@text"/>
      <xsl:variable name="nm" select="current()/person/@name"/>
      <xsl:element name="html"/>
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
      <xsl:sequence select="$xmiXMI//*[@text=$vvvv/child::node()]"/>
   </xsl:function>
</xsl:stylesheet>