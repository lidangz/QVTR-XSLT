<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:di="http://www.topcased.org/DI/1.0" xmlns:diagrams="http://www.topcased.org/Diagrams/1.0" xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" xmlns:my="http:///rcos.iist.unu.edu/2008/lidan" xmlns:rCOS="http://rcos.iist.unu.edu/rCOS.profile.uml" xmlns:uml="http://www.eclipse.org/uml2/3.0.0/UML" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:key name="xmiId" match="*" use="@xmi:id"/>
	<xsl:variable name="xmiXMI" select="child::node()"/>
	<xsl:variable name="sourceTypedModels" select="''"/>
	<xsl:template match="/">
		<xsl:apply-templates mode="ActivityToCSP" select="."/>
	</xsl:template>
	<xsl:template match="/" mode="ActivityToCSP">
		<xsl:apply-templates mode="ActivitityToCSP"/>
	</xsl:template>
	<xsl:template match="node[@xmi:type='uml:ForkNode' and count(my:xmiXMIrefs(current()/@outgoing)[@xmi:type='uml:ControlFlow'])=1 and my:xmiXMIrefs(@incoming)[@xmi:type='uml:ControlFlow'] and my:xmiXMIrefs(@outgoing)[@xmi:type='uml:ControlFlow']]" mode="JoinNode">
		<xsl:param name="ineg"/>
		<xsl:message select="concat('JoinNode',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="fn" select="current()"/>
		<xsl:variable name="ad" select="$fn/parent::node()"/>
		<xsl:variable name="fnm" select="my:xmiXMIrefs($fn/@incoming)[@xmi:type='uml:ControlFlow'][1]/@name"/>
		<xsl:variable name="ept" select="my:xmiXMIrefs($fn/@outgoing)[@xmi:type='uml:ControlFlow'][2]"/>
		<xsl:if test="$ineg=$fnm">
			<xsl:apply-templates mode="JoinNodeGo" select="$fn"/>
		</xsl:if>
		<xsl:if test="$ineg!=$fnm">
			<xsl:apply-templates mode="JoinNodeSKIP" select="$fn"/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="node[@xmi:type='uml:DecisionNode' and count(my:xmiXMIrefs(current()/@outgoing)[@xmi:type='uml:ControlFlow']) &gt; 1 and my:xmiXMIrefs(@outgoing)[@xmi:type='uml:ControlFlow' and guard[@xmi:type='uml:OpaqueExpression']]]" mode="DecisionNode">
		<xsl:message select="concat('DecisionNode',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="dn" select="current()"/>
		<xsl:variable name="ad" select="$dn/parent::node()"/>
		<xsl:variable name="aenm" select="my:xmiXMIrefs($dn/@outgoing)[@xmi:type='uml:ControlFlow'][guard[@xmi:type='uml:OpaqueExpression']/body!='else'][1]/@name"/>
		<xsl:variable name="condi" select="my:xmiXMIrefs($dn/@outgoing)[@xmi:type='uml:ControlFlow'][guard[@xmi:type='uml:OpaqueExpression']/body!='else'][1]/guard[@xmi:type='uml:OpaqueExpression']/body"/>
		<xsl:variable name="pos" select="2"/>
		<xsl:variable name="newae" select="my:xmiXMIrefs($dn/@outgoing)[@xmi:type='uml:ControlFlow'][guard[@xmi:type='uml:OpaqueExpression']/body!='else'][$pos]"/>
		<xsl:element name="Condition">
			<xsl:attribute name="expression" select="$condi"/>
			<xsl:element name="Process">
				<xsl:attribute name="name" select="$aenm"/>
				<xsl:attribute name="type" select="'LEFT'"/>
			</xsl:element>
			<xsl:if test="empty($newae)">
				<xsl:apply-templates mode="DecisionNodeLast" select="$dn"/>
			</xsl:if>
			<xsl:if test="exists($newae)">
				<xsl:apply-templates mode="DecisionNodeNext" select="$dn">
					<xsl:with-param name="pos" select="$pos"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	<xsl:template match="node[@xmi:type='uml:ForkNode' and my:xmiXMIrefs(@outgoing)[@xmi:type='uml:ControlFlow']]" mode="JoinNodeGo">
		<xsl:message select="concat('JoinNodeGo',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="fn" select="current()"/>
		<xsl:variable name="aenm" select="my:xmiXMIrefs($fn/@outgoing)[@xmi:type='uml:ControlFlow']/@name"/>
		<xsl:element name="Prefix">
			<xsl:element name="Event">
				<xsl:attribute name="name" select="'processJoin'"/>
			</xsl:element>
			<xsl:element name="Process">
				<xsl:attribute name="name" select="$aenm"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="//packagedElement[@xmi:type='uml:Activity' and node[@xmi:type='uml:InitialNode' and my:xmiXMIrefs(@outgoing)[@xmi:type='uml:ControlFlow']]]" mode="ActivitityToCSP">
		<xsl:message select="concat('ActivitityToCSP',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="ad" select="current()"/>
		<xsl:variable name="aenm" select="my:xmiXMIrefs($ad/node[@xmi:type='uml:InitialNode']/@outgoing)[@xmi:type='uml:ControlFlow']/@name"/>
		<xsl:element name="CspContainer">
			<xsl:attribute name="initial" select="string-join($aenm,' ')"/>
			<xsl:apply-templates mode="EdgeToPA" select="$ad"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="node[@xmi:type='uml:ActivityFinalNode']" mode="FinalToSKIP">
		<xsl:message select="concat('FinalToSKIP',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="ad" select="current()/parent::node()"/>
		<xsl:element name="SKIP"/>
	</xsl:template>
	<xsl:template match="node[@xmi:type='uml:ForkNode' and my:xmiXMIrefs(@outgoing)[@xmi:type='uml:ControlFlow']]" mode="JoinNodeSKIP">
		<xsl:message select="concat('JoinNodeSKIP',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="fn" select="current()"/>
		<xsl:variable name="aenm" select="my:xmiXMIrefs($fn/@outgoing)[@xmi:type='uml:ControlFlow']/@name"/>
		<xsl:element name="Prefix">
			<xsl:element name="Event">
				<xsl:attribute name="name" select="'processJoin'"/>
			</xsl:element>
			<xsl:element name="SKIP"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="node[@xmi:type='uml:DecisionNode' and my:xmiXMIrefs(@outgoing)[@xmi:type='uml:ControlFlow' and guard[@xmi:type='uml:OpaqueExpression']]]" mode="DecisionNodeNext">
		<xsl:param name="pos"/>
		<xsl:message select="concat('DecisionNodeNext',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="dn" select="current()"/>
		<xsl:variable name="ad" select="$dn/parent::node()"/>
		<xsl:variable name="aenm" select="my:xmiXMIrefs($dn/@outgoing)[@xmi:type='uml:ControlFlow'][guard[@xmi:type='uml:OpaqueExpression']/body!='else'][$pos]/@name"/>
		<xsl:variable name="condi" select="my:xmiXMIrefs($dn/@outgoing)[@xmi:type='uml:ControlFlow'][guard[@xmi:type='uml:OpaqueExpression']/body!='else'][$pos]/guard[@xmi:type='uml:OpaqueExpression']/body"/>
		<xsl:variable name="newpos" select="$pos + 1"/>
		<xsl:variable name="newae" select="my:xmiXMIrefs($dn/@outgoing)[@xmi:type='uml:ControlFlow'][guard[@xmi:type='uml:OpaqueExpression']/body!='else'][$newpos]"/>
		<xsl:element name="Condition">
			<xsl:attribute name="expression" select="$condi"/>
			<xsl:attribute name="type" select="'RIGHT'"/>
			<xsl:element name="Process">
				<xsl:attribute name="name" select="$aenm"/>
				<xsl:attribute name="type" select="'LEFT'"/>
			</xsl:element>
			<xsl:if test="empty($newae)">
				<xsl:apply-templates mode="DecisionNodeLast" select="$dn"/>
			</xsl:if>
			<xsl:if test="exists($newae)">
				<xsl:apply-templates mode="DecisionNodeNext" select="$dn">
					<xsl:with-param name="pos" select="$newpos"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	<xsl:template match="node[@xmi:type='uml:CallBehaviorAction' and my:xmiXMIrefs(@outgoing)[@xmi:type='uml:ControlFlow']]" mode="ActionToPrefix">
		<xsl:message select="concat('ActionToPrefix',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="acnm" select="current()/@name"/>
		<xsl:variable name="ad" select="current()/parent::node()"/>
		<xsl:variable name="aenm" select="my:xmiXMIrefs(current()/@outgoing)[@xmi:type='uml:ControlFlow']/@name"/>
		<xsl:element name="Prefix">
			<xsl:element name="Event">
				<xsl:attribute name="name" select="$acnm"/>
			</xsl:element>
			<xsl:element name="Process">
				<xsl:attribute name="name" select="$aenm"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="node[@xmi:type='uml:DecisionNode' and my:xmiXMIrefs(@outgoing)[@xmi:type='uml:ControlFlow' and guard[@xmi:type='uml:OpaqueExpression']]]" mode="DecisionNodeLast">
		<xsl:message select="concat('DecisionNodeLast',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="dn" select="current()"/>
		<xsl:variable name="ad" select="$dn/parent::node()"/>
		<xsl:variable name="aenm" select="my:xmiXMIrefs($dn/@outgoing)[@xmi:type='uml:ControlFlow'][guard[@xmi:type='uml:OpaqueExpression']/body='else']/@name"/>
		<xsl:element name="Process">
			<xsl:attribute name="name" select="$aenm"/>
			<xsl:attribute name="type" select="'RIGHT'"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="node[@xmi:type='uml:ForkNode' and my:xmiXMIrefs(@outgoing)[@xmi:type='uml:ControlFlow']]" mode="ForkNodeLast">
		<xsl:message select="concat('ForkNodeLast',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="fn" select="current()"/>
		<xsl:variable name="ad" select="$fn/parent::node()"/>
		<xsl:variable name="aenm" select="my:xmiXMIrefs($fn/@outgoing)[@xmi:type='uml:ControlFlow'][last()]/@name"/>
		<xsl:element name="Process">
			<xsl:attribute name="name" select="$aenm"/>
			<xsl:attribute name="type" select="'RIGHT'"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="edge[@xmi:type='uml:ControlFlow' and my:xmiXMIrefs(@target)]" mode="EdgeToPA">
		<xsl:message select="concat('EdgeToPA',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="ae" select="current()"/>
		<xsl:variable name="aenm" select="$ae/@name"/>
		<xsl:variable name="ad" select="$ae/parent::node()"/>
		<xsl:variable name="an" select="my:xmiXMIrefs($ae/@target)"/>
		<xsl:element name="ProcessAssignment">
			<xsl:element name="Process">
				<xsl:attribute name="name" select="$aenm"/>
				<xsl:attribute name="type" select="'ID'"/>
			</xsl:element>
			<xsl:apply-templates mode="ActionToPrefix" select="$an"/>
			<xsl:apply-templates mode="FinalToSKIP" select="$an"/>
			<xsl:apply-templates mode="MergeNode" select="$an"/>
			<xsl:apply-templates mode="DecisionNode" select="$an"/>
			<xsl:apply-templates mode="ForkNode" select="$an"/>
			<xsl:apply-templates mode="JoinNode" select="$an">
				<xsl:with-param name="ineg" select="$aenm"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	<xsl:template match="node[@xmi:type='uml:DecisionNode' and count(my:xmiXMIrefs(current()/@outgoing)[@xmi:type='uml:ControlFlow'])=1 and my:xmiXMIrefs(@outgoing)[@xmi:type='uml:ControlFlow']]" mode="MergeNode">
		<xsl:message select="concat('MergeNode',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="dn" select="current()"/>
		<xsl:variable name="aenm2" select="my:xmiXMIrefs($dn/@outgoing)[@xmi:type='uml:ControlFlow']/@name"/>
		<xsl:variable name="ad" select="$dn/parent::node()"/>
		<xsl:element name="Process">
			<xsl:attribute name="name" select="$aenm2"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="node[@xmi:type='uml:ForkNode' and my:xmiXMIrefs(@outgoing)[@xmi:type='uml:ControlFlow']]" mode="ForkNodeNext">
		<xsl:param name="pos"/>
		<xsl:message select="concat('ForkNodeNext',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="fn" select="current()"/>
		<xsl:variable name="ad" select="$fn/parent::node()"/>
		<xsl:variable name="npos" select="$pos + 1"/>
		<xsl:variable name="nnpos" select="$pos + 2"/>
		<xsl:variable name="aenm" select="my:xmiXMIrefs($fn/@outgoing)[@xmi:type='uml:ControlFlow'][$pos]/@name"/>
		<xsl:variable name="nae" select="my:xmiXMIrefs($fn/@outgoing)[@xmi:type='uml:ControlFlow'][$nnpos]"/>
		<xsl:element name="Concurrency">
			<xsl:attribute name="type" select="'RIGHT'"/>
			<xsl:element name="Process">
				<xsl:attribute name="name" select="$aenm"/>
				<xsl:attribute name="type" select="'LEFT'"/>
			</xsl:element>
			<xsl:if test="empty($nae)">
				<xsl:apply-templates mode="ForkNodeLast" select="$fn"/>
			</xsl:if>
			<xsl:if test="exists($nae)">
				<xsl:apply-templates mode="ForkNodeNext" select="$fn">
					<xsl:with-param name="pos" select="$npos"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	<xsl:template match="node[@xmi:type='uml:ForkNode' and count(my:xmiXMIrefs(current()/@outgoing)[@xmi:type='uml:ControlFlow']) &gt; 1 and my:xmiXMIrefs(@outgoing)[@xmi:type='uml:ControlFlow'][1]]" mode="ForkNode">
		<xsl:message select="concat('ForkNode',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="fn" select="current()"/>
		<xsl:variable name="aenm" select="my:xmiXMIrefs($fn/@outgoing)[@xmi:type='uml:ControlFlow'][1]/@name"/>
		<xsl:variable name="ad" select="$fn/parent::node()"/>
		<xsl:variable name="pos" select="2"/>
		<xsl:variable name="npos" select="$pos + 1"/>
		<xsl:variable name="nae" select="my:xmiXMIrefs($fn/@outgoing)[@xmi:type='uml:ControlFlow'][$npos]"/>
		<xsl:element name="Concurrency">
			<xsl:element name="Process">
				<xsl:attribute name="name" select="$aenm"/>
				<xsl:attribute name="type" select="'LEFT'"/>
			</xsl:element>
			<xsl:if test="empty($nae)">
				<xsl:apply-templates mode="ForkNodeLast" select="$fn"/>
			</xsl:if>
			<xsl:if test="exists($nae)">
				<xsl:apply-templates mode="ForkNodeNext" select="$fn">
					<xsl:with-param name="pos" select="$pos"/>
				</xsl:apply-templates>
			</xsl:if>
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