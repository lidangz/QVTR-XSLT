<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:di="http://www.topcased.org/DI/1.0" xmlns:diagrams="http://www.topcased.org/Diagrams/1.0" xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" xmlns:my="http:///rcos.iist.unu.edu/2008/lidan" xmlns:rCOS="http://rcos.iist.unu.edu/rCOS.profile.uml" xmlns:uml="http://www.eclipse.org/uml2/3.0.0/UML" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:key name="xmiId" match="*" use="@xmi:id"/>
	<xsl:variable name="xmiXMI" select="child::node()"/>
	<xsl:variable name="sourceTypedModels" select="''"/>
	<xsl:template match="/">
		<xsl:apply-templates mode="umlTOrdbms" select="."/>
	</xsl:template>
	<xsl:template match="/" mode="umlTOrdbms">
		<xsl:apply-templates mode="PackageToSchema"/>
	</xsl:template>
	<xsl:template match="ownedAttribute[my:xmiXMIrefs(@type)[@xmi:type='uml:Class'] and not(my:xmiXMIrefs(@association)[@xmi:type='uml:Association'])]" mode="ComplexAttributeToColumn">
		<xsl:param name="prefix"/>
		<xsl:message select="concat('ComplexAttributeToColumn',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="ctt" select="current()"/>
		<xsl:variable name="an" select="$ctt/@name"/>
		<xsl:variable name="tc" select="my:xmiXMIrefs($ctt/@type)[@xmi:type='uml:Class']"/>
		<xsl:variable name="c" select="$ctt/parent::node()"/>
		<xsl:variable name="newprefix" select=" if ($prefix='') then $an else concat($prefix,'_',$an) "/>
		<xsl:apply-templates mode="AttributeToColumn" select="$tc">
			<xsl:with-param name="prefix" select="$newprefix"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="ownedAttribute[type[@xmi:type='uml:PrimitiveType']]" mode="PrimitiveAttributeToColumn">
		<xsl:param name="prefix"/>
		<xsl:message select="concat('PrimitiveAttributeToColumn',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="att" select="current()"/>
		<xsl:variable name="an" select="$att/@name"/>
		<xsl:variable name="tp" select="$att/type[@xmi:type='uml:PrimitiveType']"/>
		<xsl:variable name="pn" select="$tp/@href"/>
		<xsl:variable name="c" select="$att/parent::node()"/>
		<xsl:variable name="cln" select=" if ($prefix='') then $an else concat($prefix,'_',$an) "/>
		<xsl:variable name="sqltype" select="my:PrimitiveTypToSqlType($pn)"/>
		<xsl:element name="Column">
			<xsl:attribute name="name" select="$cln"/>
			<xsl:attribute name="type" select="$sqltype"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="packagedElement[@xmi:type='uml:Class']" mode="AttributeToColumn">
		<xsl:param name="prefix"/>
		<xsl:message select="concat('AttributeToColumn',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="c" select="current()"/>
		<xsl:apply-templates mode="PrimitiveAttributeToColumn" select="$c">
			<xsl:with-param name="prefix" select="$prefix"/>
		</xsl:apply-templates>
		<xsl:apply-templates mode="ComplexAttributeToColumn" select="$c">
			<xsl:with-param name="prefix" select="$prefix"/>
		</xsl:apply-templates>
		<xsl:apply-templates mode="SuperAttributeToColumn" select="$c">
			<xsl:with-param name="prefix" select="$prefix"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="//packagedElement[@xmi:type='uml:Package' and not(@name='UML Standard Profile')]" mode="PackageToSchema">
		<xsl:message select="concat('PackageToSchema',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="p" select="current()"/>
		<xsl:variable name="pn" select="$p/@name"/>
		<xsl:element name="Schema">
			<xsl:attribute name="name" select="$pn"/>
			<xsl:apply-templates mode="ClassToTable" select="$p"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="ownedAttribute[upperValue[@xmi:type='uml:LiteralUnlimitedNatural' and @value='1'] and my:xmiXMIrefs(@type)[@xmi:type='uml:Class' and not(@isAbstract='true')] and my:xmiXMIrefs(@association)[@xmi:type='uml:Association']]" mode="AssocEndToFKey">
		<xsl:message select="concat('AssocEndToFKey',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="asso" select="current()"/>
		<xsl:variable name="an" select="$asso/@name"/>
		<xsl:variable name="c" select="$asso/parent::node()"/>
		<xsl:variable name="cn" select="$c/@name"/>
		<xsl:variable name="dc" select="my:xmiXMIrefs($asso/@type)[@xmi:type='uml:Class'][not(@isAbstract='true')]"/>
		<xsl:variable name="dcn" select="$dc/@name"/>
		<xsl:variable name="asn" select="my:xmiXMIrefs($asso/@association)[@xmi:type='uml:Association']/@name"/>
		<xsl:variable name="ran" select=" if ($an='') then $asn else $an "/>
		<xsl:variable name="fkn" select="concat($cn,'_',$ran,'_',$dcn)"/>
		<xsl:variable name="fcn" select="concat($fkn,'_tid')"/>
		<xsl:element name="ForeignKey">
			<xsl:attribute name="name" select="$fkn"/>
			<xsl:attribute name="refersTo" select="string-join(concat($dcn,'_pk'),' ')"/>
			<xsl:attribute name="column" select="string-join($fcn,' ')"/>
		</xsl:element>
		<xsl:element name="Column">
			<xsl:attribute name="name" select="$fcn"/>
			<xsl:attribute name="type" select="'integer'"/>
			<xsl:attribute name="foreignkey" select="string-join($fkn,' ')"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="packagedElement[@xmi:type='uml:Class' and not(@isAbstract='true') and parent::node()[@xmi:type='uml:Package']]" mode="ClassToTable">
		<xsl:message select="concat('ClassToTable',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="c" select="current()"/>
		<xsl:variable name="abs" select="$c/@isAbstract"/>
		<xsl:variable name="cn" select="$c/@name"/>
		<xsl:variable name="p" select="$c/parent::node()"/>
		<xsl:element name="Table">
			<xsl:attribute name="name" select="$cn"/>
			<xsl:element name="Column">
				<xsl:attribute name="name" select="concat($cn,'_tid')"/>
				<xsl:attribute name="type" select="'integer'"/>
				<xsl:attribute name="key" select="string-join(concat($cn,'_pk'),' ')"/>
			</xsl:element>
			<xsl:element name="Key">
				<xsl:attribute name="name" select="concat($cn,'_pk')"/>
				<xsl:attribute name="column" select="string-join(concat($cn,'_tid'),' ')"/>
			</xsl:element>
			<xsl:apply-templates mode="AttributeToColumn" select="$c">
				<xsl:with-param name="prefix" select="''"/>
			</xsl:apply-templates>
			<xsl:apply-templates mode="AssocEndToFKey" select="$c"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="generalization[my:xmiXMIrefs(@general)[@xmi:type='uml:Class']]" mode="SuperAttributeToColumn">
		<xsl:param name="prefix"/>
		<xsl:message select="concat('SuperAttributeToColumn',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="g" select="current()"/>
		<xsl:variable name="sc" select="my:xmiXMIrefs($g/@general)[@xmi:type='uml:Class']"/>
		<xsl:variable name="c" select="$g/parent::node()"/>
		<xsl:apply-templates mode="AttributeToColumn" select="$sc">
			<xsl:with-param name="prefix" select="$prefix"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:function name="my:PrimitiveTypToSqlType">
		<xsl:param name="pn"/>
		<xsl:variable name="tp1" select="substring-after($pn,'#')"/>
		<xsl:variable name="tp" select="lower-case($tp1)"/>
		<xsl:variable name="rt" select=" if ($tp='integer' or $tp='boolean') then $tp else 'varchar' "/>
		<xsl:variable name="return" select=" if ($rt='boolean') then 'tinyint' else $rt "/>
		<xsl:sequence select="$return"/>
		<xsl:message select="concat('PrimitiveTypToSqlType',' : ',' : ')"/>
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