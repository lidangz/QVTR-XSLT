<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:di="http://www.topcased.org/DI/1.0" xmlns:diagrams="http://www.topcased.org/Diagrams/1.0" xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" xmlns:my="http:///rcos.iist.unu.edu/2008/lidan" xmlns:rCOS="http://rcos.iist.unu.edu/rCOS.profile.uml" xmlns:uml="http://www.eclipse.org/uml2/3.0.0/UML" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:include href="my_XMI_Merge.xslt"/>
	<xsl:key name="xmiId" match="*" use="@xmi:id"/>
	<xsl:variable name="xmiXMI" select="child::node()"/>
	<xsl:variable name="sourceTypedModels" select="''"/>
	<xsl:template match="/">
		<xsl:apply-templates mode="ClassToComponent" select="."/>
	</xsl:template>
	<xsl:template match="/" mode="ClassToComponent">
		<xsl:variable name="diffResult">
			<xsl:apply-templates mode="RootTrans"/>
		</xsl:variable>
		<xsl:variable name="diffResult2">
			<xsl:apply-templates mode="XMI_EleToLinkCopy" select="$diffResult/*"/>
		</xsl:variable>
		<xsl:apply-templates mode="XMI_Merge">
			<xsl:with-param name="xmiDiffList" select="$diffResult2//*[@xmiDiff]"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="ownedParameter[my:xmiXMIrefs(@type)[@xmi:type='uml:Class'] and not(type[@xmi:type='uml:PrimitiveType'])]" mode="ParaToPara">
		<xsl:message select="concat('ParaToPara(ParaToPara1)',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="di" select="current()/@direction"/>
		<xsl:variable name="pnm" select="current()/@name"/>
		<xsl:variable name="pid" select="current()/@xmi:id"/>
		<xsl:variable name="cop" select="current()/parent::node()"/>
		<xsl:variable name="cid" select="current()/@type"/>
		<xsl:variable name="npid" select="my:GetNewId($pid,3)"/>
		<xsl:element name="ownedParameter">
			<xsl:attribute name="name" select="$pnm"/>
			<xsl:attribute name="direction" select="$di"/>
			<xsl:attribute name="xmi:id" select="$npid"/>
			<xsl:element name="_link_AS_element">
				<xsl:attribute name="name" select="'type'"/>
				<xsl:attribute name="value" select="string-join($cid,' ')"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="ownedParameter[type[@xmi:type='uml:PrimitiveType'] and not(my:xmiXMIrefs(@type)[@xmi:type='uml:Class'])]" mode="ParaToPara">
		<xsl:message select="concat('ParaToPara',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="di" select="current()/@direction"/>
		<xsl:variable name="pnm" select="current()/@name"/>
		<xsl:variable name="pid" select="current()/@xmi:id"/>
		<xsl:variable name="hf" select="current()/type[@xmi:type='uml:PrimitiveType']/@href"/>
		<xsl:variable name="cop" select="current()/parent::node()"/>
		<xsl:variable name="npid" select="my:GetNewId($pid,3)"/>
		<xsl:element name="ownedParameter">
			<xsl:attribute name="name" select="$pnm"/>
			<xsl:attribute name="direction" select="$di"/>
			<xsl:attribute name="xmi:id" select="$npid"/>
			<xsl:element name="type">
				<xsl:attribute name="xmi:type" select="'uml:PrimitiveType'"/>
				<xsl:attribute name="href" select="$hf"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="rCOS:ClassModel[my:xmiXMIrefs(@base_Package)[@xmi:type='uml:Package']]" mode="ClassMToComM">
		<xsl:param name="commid"/>
		<xsl:message select="concat('ClassMToComM',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="sr" select="current()/parent::node()"/>
		<xsl:variable name="clsm" select="my:xmiXMIrefs(current()/@base_Package)[@xmi:type='uml:Package']"/>
		<xsl:variable name="umm" select="$clsm/parent::node()"/>
		<xsl:variable name="umn" select="$umm/@name"/>
		<xsl:variable name="umid" select="$umm/@xmi:id"/>
		<xsl:element name="uml:Model">
			<xsl:attribute name="name" select="$umn"/>
			<xsl:attribute name="xmi:id" select="$umid"/>
			<xsl:element name="packagedElement">
				<xsl:attribute name="xmi:type" select="'uml:Package'"/>
				<xsl:attribute name="xmi:id" select="$commid"/>
				<xsl:apply-templates mode="ClassToCom" select="$clsm">
					<xsl:with-param name="commid" select="$commid"/>
				</xsl:apply-templates>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="packagedElement[@xmi:type='uml:Class' and @name=my:GetToComClass()]" mode="ClassToCom">
		<xsl:param name="commid"/>
		<xsl:message select="concat('ClassToCom',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="cls" select="current()"/>
		<xsl:variable name="clsn" select="$cls/@name"/>
		<xsl:variable name="clsid" select="$cls/@xmi:id"/>
		<xsl:variable name="clsm" select="$cls/parent::node()"/>
		<xsl:variable name="comn" select="concat('Com_from_',$clsn)"/>
		<xsl:variable name="ifn" select="concat('Inter_from_',$clsn)"/>
		<xsl:variable name="comid" select="my:GetNewId($clsid,3)"/>
		<xsl:variable name="ifid" select="my:GetNewId($clsid,5)"/>
		<xsl:variable name="ifrid" select="my:GetNewId($clsid,7)"/>
		<xsl:element name="packagedElement">
			<xsl:attribute name="xmi:type" select="'uml:Interface'"/>
			<xsl:attribute name="name" select="$ifn"/>
			<xsl:attribute name="xmi:id" select="$ifid"/>
			<xsl:attribute name="xmiDiff" select="'insertTo'"/>
			<xsl:attribute name="targetId" select="$commid"/>
			<xsl:apply-templates mode="OperToOper" select="$cls"/>
		</xsl:element>
		<xsl:element name="packagedElement">
			<xsl:attribute name="xmi:type" select="'uml:Component'"/>
			<xsl:attribute name="name" select="$comn"/>
			<xsl:attribute name="xmi:id" select="$comid"/>
			<xsl:attribute name="xmiDiff" select="'insertTo'"/>
			<xsl:attribute name="targetId" select="$commid"/>
			<xsl:element name="interfaceRealization">
				<xsl:attribute name="name" select="'InterfaceRealization'"/>
				<xsl:attribute name="xmi:id" select="$ifrid"/>
				<xsl:element name="_link_AS_element">
					<xsl:attribute name="name" select="'implementingClassifier'"/>
					<xsl:attribute name="value" select="string-join($clsid,' ')"/>
				</xsl:element>
				<xsl:element name="_link_AS_element">
					<xsl:attribute name="name" select="'contract'"/>
					<xsl:attribute name="value" select="string-join($ifid,' ')"/>
				</xsl:element>
				<xsl:element name="_link_AS_element">
					<xsl:attribute name="name" select="'supplier'"/>
					<xsl:attribute name="value" select="string-join($ifid,' ')"/>
				</xsl:element>
				<xsl:element name="_link_AS_element">
					<xsl:attribute name="name" select="'client'"/>
					<xsl:attribute name="value" select="string-join($comid,' ')"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="//xmi:XMI[rCOS:ComponentModel[my:xmiXMIrefs(@base_Package)[@xmi:type='uml:Package']]]" mode="RootTrans">
		<xsl:message select="concat('RootTrans',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="sr" select="current()"/>
		<xsl:variable name="commid" select="$sr/rCOS:ComponentModel/@base_Package"/>
		<xsl:element name="xmi:XMI">
			<xsl:apply-templates mode="ClassMToComM" select="$sr">
				<xsl:with-param name="commid" select="$commid"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	<xsl:template match="ownedOperation" mode="OperToOper">
		<xsl:message select="concat('OperToOper',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="cop" select="current()"/>
		<xsl:variable name="onm" select="$cop/@name"/>
		<xsl:variable name="oid" select="$cop/@xmi:id"/>
		<xsl:variable name="cls" select="$cop/parent::node()"/>
		<xsl:variable name="noid" select="my:GetNewId($oid,3)"/>
		<xsl:element name="ownedOperation">
			<xsl:attribute name="name" select="$onm"/>
			<xsl:attribute name="xmi:id" select="$noid"/>
			<xsl:apply-templates mode="ParaToPara" select="$cop"/>
		</xsl:element>
	</xsl:template>
	<xsl:function name="my:GetToComClass">
		<xsl:variable name="return" select="'CashPayment'"/>
		<xsl:sequence select="$return"/>
		<xsl:message select="concat('GetToComClass',' : ',' : ')"/>
	</xsl:function>
	<xsl:function name="my:GetNewId">
		<xsl:param name="in"/>
		<xsl:param name="pos"/>
		<xsl:variable name="p1" select="substring($in,1,$pos)"/>
		<xsl:variable name="pos1" select="$pos + 1"/>
		<xsl:variable name="p2" select="substring($in,$pos1)"/>
		<xsl:variable name="return" select="concat($p2,$p1)"/>
		<xsl:sequence select="$return"/>
		<xsl:message select="concat('GetNewId',' : ',' : ')"/>
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