<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:di="http://www.topcased.org/DI/1.0" xmlns:diagrams="http://www.topcased.org/Diagrams/1.0" xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" xmlns:my="http:///rcos.iist.unu.edu/2008/lidan" xmlns:rCOS="http://rcos.iist.unu.edu/rCOS.profile.uml" xmlns:uml="http://www.eclipse.org/uml2/3.0.0/UML" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:key name="xmiId" match="*" use="@name"/>
	<xsl:variable name="xmiXMI" select="child::node()"/>
	<xsl:variable name="sourceTypedModels" select="''"/>
	<xsl:template match="/">
		<xsl:apply-templates mode="rdbmsToSQL" select="."/>
	</xsl:template>
	<xsl:template match="/" mode="rdbmsToSQL">
		<xsl:apply-templates mode="SchemaToHtml"/>
	</xsl:template>
	<xsl:template match="Table" mode="ForeignKey">
		<xsl:message select="concat('ForeignKey',' : ',@name,' : ',@name)"/>
		<xsl:variable name="tab" select="current()"/>
		<xsl:variable name="sch" select="$tab/parent::node()"/>
		<xsl:variable name="snm" select="$sch/@name"/>
		<xsl:apply-templates mode="ForeignToTr" select="$tab">
			<xsl:with-param name="snm" select="$snm"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="Column" mode="ColumnToTr">
		<xsl:message select="concat('ColumnToTr',' : ',@name,' : ',@name)"/>
		<xsl:variable name="cnm" select="current()/@name"/>
		<xsl:variable name="ty" select="current()/@type"/>
		<xsl:variable name="ky" select="my:xmiXMIrefs(current()/@key)"/>
		<xsl:variable name="tab" select="current()/parent::node()"/>
		<xsl:variable name="iskey" select=" if (not(exists($ky))) then '' else ' not null ' "/>
		<xsl:variable name="txt" select=" if ($ty='varchar') then concat($cnm,' ',$ty,'(60)',$iskey,',') else concat($cnm,' ',$ty,$iskey,',') "/>
		<xsl:element name="tr">
			<xsl:element name="td">
				<xsl:value-of select="$txt"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="Key" mode="KeyToTr">
		<xsl:message select="concat('KeyToTr',' : ',@name,' : ',@name)"/>
		<xsl:variable name="knm" select="current()/@name"/>
		<xsl:variable name="cnm" select="my:xmiXMIrefs(current()/@column)/@name"/>
		<xsl:variable name="tab" select="current()/parent::node()"/>
		<xsl:variable name="txt" select="concat('CONSTRAINT ',$knm,' PRIMARY  KEY  ( ',$cnm, ' ))；')"/>
		<xsl:element name="tr">
			<xsl:element name="td">
				<xsl:value-of select="$txt"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="Schema" mode="HtmlBody">
		<xsl:message select="concat('HtmlBody',' : ',@name,' : ',@name)"/>
		<xsl:variable name="sch" select="current()"/>
		<xsl:variable name="snm" select="$sch/@name"/>
		<xsl:variable name="txt" select="concat('CREATE SCHEMA ',$snm,'；')"/>
		<xsl:element name="body">
			<xsl:element name="table">
				<xsl:element name="tr">
					<xsl:element name="td">
						<xsl:value-of select="$txt"/>
					</xsl:element>
				</xsl:element>
				<xsl:apply-templates mode="TableToTr" select="$sch"/>
				<xsl:apply-templates mode="ForeignKey" select="$sch"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="Table" mode="TableToTr">
		<xsl:message select="concat('TableToTr',' : ',@name,' : ',@name)"/>
		<xsl:variable name="tab" select="current()"/>
		<xsl:variable name="tnm" select="$tab/@name"/>
		<xsl:variable name="sch" select="$tab/parent::node()"/>
		<xsl:variable name="snm" select="$sch/@name"/>
		<xsl:variable name="txt" select="concat('CREATE  TABLE ',$snm,'.',$tnm,' ( ')"/>
		<xsl:element name="tr">
			<xsl:element name="td">
				<xsl:value-of select="$txt"/>
			</xsl:element>
		</xsl:element>
		<xsl:apply-templates mode="ColumnToTr" select="$tab"/>
		<xsl:apply-templates mode="KeyToTr" select="$tab"/>
	</xsl:template>
	<xsl:template match="//Schema" mode="SchemaToHtml">
		<xsl:message select="concat('SchemaToHtml',' : ',@name,' : ',@name)"/>
		<xsl:variable name="sch" select="current()"/>
		<xsl:element name="html">
			<xsl:element name="head">
				<xsl:element name="title">
					<xsl:value-of select="'SQL generated from RDBMS model'"/>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates mode="HtmlBody" select="$sch"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="ForeignKey" mode="ForeignToTr">
		<xsl:param name="snm"/>
		<xsl:message select="concat('ForeignToTr',' : ',@name,' : ',@name)"/>
		<xsl:variable name="fnm" select="current()/@name"/>
		<xsl:variable name="tab" select="current()/parent::node()"/>
		<xsl:variable name="tnm" select="$tab/@name"/>
		<xsl:variable name="cnm" select="my:xmiXMIrefs(current()/@column)/@name"/>
		<xsl:variable name="ktnm" select="my:xmiXMIrefs(current()/@refersTo)/parent::node()/@name"/>
		<xsl:variable name="txt1" select="concat('ALTER TABLE ',$snm,'.',$tnm,' ADD  CONSTRAINT ',$fnm)"/>
		<xsl:variable name="txt" select="concat($txt1,' FOREIGN  KEY ( ',$cnm,') REFERENCES ',$snm,'.',$ktnm,'；')"/>
		<xsl:element name="tr">
			<xsl:element name="td">
				<xsl:value-of select="$txt"/>
			</xsl:element>
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
		<xsl:sequence select="$xmiXMI//*[@name=$vvvv/child::node()]"/>
	</xsl:function>
</xsl:stylesheet>