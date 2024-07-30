<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:SimpleRDBMS="urn:SimpleRDBMS.ecore" xmlns:SimpleUML="urn:SimpleUML.ecore" xmlns:di="http://www.topcased.org/DI/1.0" xmlns:diagrams="http://www.topcased.org/Diagrams/1.0" xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" xmlns:my="http:///rcos.iist.unu.edu/2008/lidan" xmlns:rCOS="http://rcos.iist.unu.edu/rCOS.profile.uml" xmlns:uml="http://www.eclipse.org/uml2/3.0.0/UML" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:key name="xmiId" match="*" use="@id"/>
	<xsl:variable name="xmiKeyVar" select="'id'"/>
	<xsl:variable name="xmiXMI" select="child::node()"/>
	<xsl:variable name="sourceTypedModels" select="''"/>
	<xsl:template match="/">
		<xsl:apply-templates mode="umlTOrdbms" select="."/>
	</xsl:template>
	<xsl:template match="/" mode="umlTOrdbms">
		<xsl:apply-templates mode="PackageToSchema"/>
	</xsl:template>
	<xsl:template match="ownedElement[@xsi:type='SimpleUML:Class']" mode="AttributeToColumn">
		<xsl:param name="prefix"/>
		<xsl:param name="_targetDom_Key"/>
		<xsl:variable name="c" select="current()"/>
		<xsl:apply-templates mode="PrimitiveAttributeToColumn" select="$c">
			<xsl:with-param name="prefix" select="$prefix"/>
			<xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
		</xsl:apply-templates>
		<xsl:apply-templates mode="ComplexAttributeToColumn" select="$c">
			<xsl:with-param name="prefix" select="$prefix"/>
			<xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
		</xsl:apply-templates>
		<xsl:apply-templates mode="SuperAttributeToColumn" select="$c">
			<xsl:with-param name="prefix" select="$prefix"/>
			<xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="attribute[my:xmiXMIrefs(@type)[@xsi:type='SimpleUML:PrimitiveDataType']]" mode="PrimitiveAttributeToColumn">
		<xsl:param name="prefix"/>
		<xsl:param name="_targetDom_Key"/>
		<xsl:variable name="a" select="current()"/>
		<xsl:variable name="an" select="$a/@name"/>
		<xsl:variable name="p" select="my:xmiXMIrefs($a/@type)[@xsi:type='SimpleUML:PrimitiveDataType']"/>
		<xsl:variable name="pn" select="$p/@name"/>
		<xsl:variable name="c" select="$a/parent::node()"/>
		<xsl:variable name="cln" select=" if ($prefix='') then $an else concat($prefix,'_',$an) "/>
		<xsl:variable name="sqltype" select="my:PrimitiveTypToSqlType($pn)"/>
		<xsl:element name="column">
			<xsl:attribute name="name" select="$cln"/>
			<xsl:attribute name="type" select="$sqltype"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="ownedElement[@xsi:type='SimpleUML:Class' and my:xmiXMIrefs(@general)[@xsi:type='SimpleUML:Class']]" mode="SuperAttributeToColumn">
		<xsl:param name="prefix"/>
		<xsl:param name="_targetDom_Key"/>
		<xsl:variable name="c" select="current()"/>
		<xsl:variable name="sc" select="my:xmiXMIrefs($c/@general)[@xsi:type='SimpleUML:Class']"/>
		<xsl:apply-templates mode="AttributeToColumn" select="$sc">
			<xsl:with-param name="prefix" select="$prefix"/>
			<xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="//ownedElement[@xsi:type='SimpleUML:Class' and @kind='Persistent' and parent::node()]" mode="ClassToTable">
		<xsl:param name="_targetDom_Key"/>
		<xsl:variable name="c" select="current()"/>
		<xsl:variable name="cn" select="$c/@name"/>
		<xsl:variable name="p" select="$c/parent::node()"/>
		<xsl:variable name="prefix" select="$cn"/>
		<xsl:variable name="s" as="item()*">
			<xsl:apply-templates mode="_func_PackageToSchema" select="$p"/>
		</xsl:variable>
		<xsl:if test="$s and $s/@name=$_targetDom_Key">
			<xsl:element name="table">
				<xsl:attribute name="name" select="$cn"/>
				<xsl:element name="column">
					<xsl:attribute name="name" select="concat($cn,'_tid')"/>
					<xsl:attribute name="type" select="'NUMBER'"/>
					<xsl:attribute name="rkey" select="string-join(concat($cn,'_pk'),' ')"/>
				</xsl:element>
				<xsl:element name="rkey">
					<xsl:attribute name="name" select="concat($cn,'_pk')"/>
					<xsl:attribute name="column" select="string-join(concat($cn,'_tid'),' ')"/>
				</xsl:element>
				<xsl:apply-templates mode="AttributeToColumn" select="$c">
					<xsl:with-param name="prefix" select="$prefix"/>
					<xsl:with-param name="_targetDom_Key" select="$cn"/>
				</xsl:apply-templates>
				<xsl:apply-templates mode="AssocToFKey" select="$xmiXMI">
					<xsl:with-param name="_targetDom_Key" select="$cn"/>
				</xsl:apply-templates>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	<xsl:template match="ownedElement[@xsi:type='SimpleUML:Class' and @kind='Persistent' and parent::node()]" mode="_func_ClassToTable">
		<xsl:variable name="c" select="current()"/>
		<xsl:variable name="cn" select="$c/@name"/>
		<xsl:variable name="p" select="$c/parent::node()"/>
		<xsl:variable name="prefix" select="$cn"/>
		<xsl:variable name="s" as="item()*">
			<xsl:apply-templates mode="_func_PackageToSchema" select="$p"/>
		</xsl:variable>
		<xsl:element name="table">
			<xsl:attribute name="name" select="$cn"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="//SimpleUML:Package" mode="PackageToSchema">
		<xsl:param name="_targetDom_Key"/>
		<xsl:variable name="p" select="current()"/>
		<xsl:variable name="pn" select="$p/@name"/>
		<xsl:element name="SimpleRDBMS:Schema">
			<xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
			<xsl:namespace name="SimpleRDBMS" select="'urn:SimpleRDBMS.ecore'"/>
			<xsl:attribute name="name" select="$pn"/>
			<xsl:apply-templates mode="ClassToTable" select="$xmiXMI">
				<xsl:with-param name="_targetDom_Key" select="$pn"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	<xsl:template match="SimpleUML:Package" mode="_func_PackageToSchema">
		<xsl:variable name="p" select="current()"/>
		<xsl:variable name="pn" select="$p/@name"/>
		<xsl:element name="SimpleRDBMS:Schema">
			<xsl:attribute name="name" select="$pn"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="attribute[my:xmiXMIrefs(@type)[@xsi:type='SimpleUML:Class']]" mode="ComplexAttributeToColumn">
		<xsl:param name="prefix"/>
		<xsl:param name="_targetDom_Key"/>
		<xsl:variable name="a" select="current()"/>
		<xsl:variable name="an" select="$a/@name"/>
		<xsl:variable name="c" select="$a/parent::node()"/>
		<xsl:variable name="tc" select="my:xmiXMIrefs($a/@type)[@xsi:type='SimpleUML:Class']"/>
		<xsl:variable name="newprefix" select="concat($prefix,'_',$an)"/>
		<xsl:apply-templates mode="AttributeToColumn" select="$tc">
			<xsl:with-param name="prefix" select="$newprefix"/>
			<xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="//ownedElement[@xsi:type='SimpleUML:Association' and parent::node() and my:xmiXMIrefs(@source)[@xsi:type='SimpleUML:Class' and @kind='Persistent'] and my:xmiXMIrefs(@destination)[@xsi:type='SimpleUML:Class' and @kind='Persistent']]" mode="AssocToFKey">
		<xsl:param name="_targetDom_Key"/>
		<xsl:variable name="a" select="current()"/>
		<xsl:variable name="an" select="$a/@name"/>
		<xsl:variable name="p" select="$a/parent::node()"/>
		<xsl:variable name="sc" select="my:xmiXMIrefs($a/@source)[@xsi:type='SimpleUML:Class'][@kind='Persistent']"/>
		<xsl:variable name="scn" select="$sc/@name"/>
		<xsl:variable name="dc" select="my:xmiXMIrefs($a/@destination)[@xsi:type='SimpleUML:Class'][@kind='Persistent']"/>
		<xsl:variable name="dcn" select="$dc/@name"/>
		<xsl:variable name="fkn" select="concat($scn,'_',$an,'_',$dcn)"/>
		<xsl:variable name="s" as="item()*">
			<xsl:apply-templates mode="_func_PackageToSchema" select="$p"/>
		</xsl:variable>
		<xsl:variable name="srcTbl" as="item()*">
			<xsl:apply-templates mode="_func_ClassToTable" select="$sc"/>
		</xsl:variable>
		<xsl:variable name="destTbl" as="item()*">
			<xsl:apply-templates mode="_func_ClassToTable" select="$dc"/>
		</xsl:variable>
		<xsl:if test="$s and $srcTbl and $destTbl and $srcTbl/@name=$_targetDom_Key">
			<xsl:element name="foreignKey">
				<xsl:attribute name="name" select="$fkn"/>
				<xsl:attribute name="refersTo" select="string-join($destTbl/@name,' ')"/>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	<xsl:template match="ownedElement[@xsi:type='SimpleUML:Association' and parent::node() and my:xmiXMIrefs(@source)[@xsi:type='SimpleUML:Class' and @kind='Persistent'] and my:xmiXMIrefs(@destination)[@xsi:type='SimpleUML:Class' and @kind='Persistent']]" mode="_func_AssocToFKey">
		<xsl:variable name="a" select="current()"/>
		<xsl:variable name="an" select="$a/@name"/>
		<xsl:variable name="p" select="$a/parent::node()"/>
		<xsl:variable name="sc" select="my:xmiXMIrefs($a/@source)[@xsi:type='SimpleUML:Class'][@kind='Persistent']"/>
		<xsl:variable name="scn" select="$sc/@name"/>
		<xsl:variable name="dc" select="my:xmiXMIrefs($a/@destination)[@xsi:type='SimpleUML:Class'][@kind='Persistent']"/>
		<xsl:variable name="dcn" select="$dc/@name"/>
		<xsl:variable name="fkn" select="concat($scn,'_',$an,'_',$dcn)"/>
		<xsl:variable name="s" as="item()*">
			<xsl:apply-templates mode="_func_PackageToSchema" select="$p"/>
		</xsl:variable>
		<xsl:variable name="srcTbl" as="item()*">
			<xsl:apply-templates mode="_func_ClassToTable" select="$sc"/>
		</xsl:variable>
		<xsl:variable name="destTbl" as="item()*">
			<xsl:apply-templates mode="_func_ClassToTable" select="$dc"/>
		</xsl:variable>
		<xsl:element name="foreignKey">
			<xsl:attribute name="name" select="$fkn"/>
			<xsl:attribute name="refersTo" select="string-join($destTbl/@name,' ')"/>
		</xsl:element>
	</xsl:template>
	<xsl:function name="my:PrimitiveTypToSqlType">
		<xsl:param name="pn"/>
		<xsl:variable name="tp1" select=" if ($pn='INTEGER') then 'NUMBER' else '' "/>
		<xsl:variable name="tp2" select=" if ($pn='BOOLEAN') then 'BOOLEAN' else '' "/>
		<xsl:variable name="result" select=" if ($tp1='' and $tp2='') then 'VARCHAR' else concat($tp1,$tp2) "/>
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
		<xsl:sequence select="$xmiXMI//*[@id=$vvvv/child::node()]"/>
	</xsl:function>
</xsl:stylesheet>