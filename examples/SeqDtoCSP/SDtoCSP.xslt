<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:di="http://www.topcased.org/DI/1.0" xmlns:diagrams="http://www.topcased.org/Diagrams/1.0" xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" xmlns:my="http:///rcos.iist.unu.edu/2008/lidan" xmlns:rCOS="http://rcos.iist.unu.edu/rCOS.profile.uml" xmlns:uml="http://www.eclipse.org/uml2/3.0.0/UML" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:include href="my_functions.xslt"/>
	<xsl:key name="xmiId" match="*" use="@xmi:id"/>
	<xsl:variable name="xmiXMI" select="child::node()"/>
	<xsl:variable name="sourceTypedModels" select="''"/>
	<xsl:template match="/">
		<xsl:apply-templates mode="SDtoCSP" select="."/>
	</xsl:template>
	<xsl:template match="/" mode="SDtoCSP">
		<xsl:apply-templates mode="InteractionToCSP"/>
	</xsl:template>
	<xsl:template match="operand" mode="OperandToSub">
		<xsl:param name="pn"/>
		<xsl:param name="lfid"/>
		<xsl:param name="nextP"/>
		<xsl:message select="concat('OperandToSub',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="iop" select="current()"/>
		<xsl:variable name="fr" select="$iop/fragment"/>
		<xsl:variable name="lf" select="my:xmiXMIrefs($fr/@covered)"/>
		<xsl:variable name="msg" select="'MessageOccurrenceSpecification'"/>
		<xsl:variable name="cmb" select="'CombinedFragment'"/>
		<xsl:variable name="frs" select="$iop/fragment[my:xmiXMIrefs(@covered)/@xmi:id=$lfid][substring-after(@xmi:type,'uml:')=$msg or substring-after(@xmi:type,'uml:')=$cmb]"/>
		<xsl:variable name="frids" select="$frs/@xmi:id"/>
		<xsl:apply-templates mode="FragmentToSub" select="$frs">
			<xsl:with-param name="pn" select="$pn"/>
			<xsl:with-param name="lfid" select="$lfid"/>
			<xsl:with-param name="nextP" select="$nextP"/>
			<xsl:with-param name="frids" select="$frids"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="fragment[@xmi:type='uml:MessageOccurrenceSpecification' and not(@xmi:id=my:xmiXMIrefs(my:xmiXMIrefs(current()/@message)/@sendEvent)[@xmi:type='uml:MessageOccurrenceSpecification']/@xmi:id) and my:xmiXMIrefs(@message)[my:xmiXMIrefs(@sendEvent)[@xmi:type='uml:MessageOccurrenceSpecification']]]" mode="FragmentToSub">
		<xsl:param name="pn"/>
		<xsl:param name="lfid"/>
		<xsl:param name="nextP"/>
		<xsl:param name="frids"/>
		<xsl:message select="concat('FragmentToSub(ReceiveEventToPrefix)',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="fr" select="current()"/>
		<xsl:variable name="mid" select="$fr/@xmi:id"/>
		<xsl:variable name="ms" select="my:xmiXMIrefs($fr/@message)"/>
		<xsl:variable name="fn" select="$ms/@name"/>
		<xsl:variable name="fr2" select="my:xmiXMIrefs($ms/@sendEvent)[@xmi:type='uml:MessageOccurrenceSpecification']"/>
		<xsl:variable name="mid2" select="$fr2/@xmi:id"/>
		<xsl:variable name="ptn" select="my:xmiXMIrefs(my:xmiXMIrefs($fr2/@covered)/@represents)/@name"/>
		<xsl:variable name="iop" select="$fr/parent::node()"/>
		<xsl:variable name="pos" select="position() + 1"/>
		<xsl:variable name="nid" select="$frids[$pos]"/>
		<xsl:variable name="newNextP" select=" if (exists($nid)) then my:NewPName($pn,$nid) else $nextP "/>
		<xsl:variable name="pfnm" select="my:NewPName($pn,$mid)"/>
		<xsl:variable name="cn" select="concat(lower-case($ptn),'_',lower-case($pn),'_',$fn)"/>
		<xsl:element name="Prefix">
			<xsl:attribute name="name" select="$pfnm"/>
			<xsl:attribute name="target" select="string-join($newNextP,' ')"/>
			<xsl:element name="Event">
				<xsl:attribute name="name" select="$fn"/>
				<xsl:attribute name="direction" select="'?'"/>
				<xsl:attribute name="passBy" select="string-join($cn,' ')"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="lifeline[my:xmiXMIrefs(@represents)]" mode="LifelineToProcess">
		<xsl:message select="concat('LifelineToProcess',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="lf" select="current()"/>
		<xsl:variable name="lfid" select="$lf/@xmi:id"/>
		<xsl:variable name="seq" select="$lf/parent::node()"/>
		<xsl:variable name="pt" select="my:xmiXMIrefs($lf/@represents)"/>
		<xsl:variable name="rn" select="$pt/@name"/>
		<xsl:variable name="cn" select="my:xmiXMIrefs($pt/@type)/@name"/>
		<xsl:variable name="pn" select=" if (empty(my:xmiXMIrefs($pt/@type))) then $rn else $cn "/>
		<xsl:variable name="msg" select="'MessageOccurrenceSpecification'"/>
		<xsl:variable name="cmb" select="'CombinedFragment'"/>
		<xsl:variable name="fstid" select="$seq/fragment[my:xmiXMIrefs(@covered)/@xmi:id=$lfid][substring-after(@xmi:type,'uml:')=$msg or substring-after(@xmi:type,'uml:')=$cmb][1]/@xmi:id"/>
		<xsl:variable name="fstnm" select="my:NewPName($pn,$fstid)"/>
		<xsl:element name="Process">
			<xsl:attribute name="name" select="$pn"/>
			<xsl:element name="SubProcess">
				<xsl:attribute name="target" select="string-join($fstnm,' ')"/>
			</xsl:element>
			<xsl:apply-templates mode="OperandToSub" select="$seq">
				<xsl:with-param name="pn" select="$pn"/>
				<xsl:with-param name="lfid" select="$lfid"/>
				<xsl:with-param name="nextP" select="'SKIP'"/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	<xsl:template match="//packagedElement[@xmi:type='uml:Collaboration' and ownedBehavior[@xmi:type='uml:Interaction' and lifeline]]" mode="InteractionToCSP">
		<xsl:message select="concat('InteractionToCSP',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="co" select="current()"/>
		<xsl:variable name="seq" select="$co/ownedBehavior[@xmi:type='uml:Interaction']"/>
		<xsl:variable name="sn" select="$seq/@name"/>
		<xsl:variable name="lfs" select="$seq/lifeline"/>
		<xsl:variable name="lfids" select="$lfs/@xmi:id"/>
		<xsl:element name="CSP">
			<xsl:attribute name="name" select="$sn"/>
			<xsl:apply-templates mode="MessageToChannel" select="$seq"/>
			<xsl:apply-templates mode="LifelineToProcess" select="$seq"/>
			<xsl:apply-templates mode="LifelineToPara" select="$seq"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="message[my:xmiXMIrefs(@receiveEvent)[@xmi:type='uml:MessageOccurrenceSpecification' and my:xmiXMIrefs(@covered)[my:xmiXMIrefs(@represents)]]]" mode="MessageToChannel">
		<xsl:message select="concat('MessageToChannel',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="ms" select="current()"/>
		<xsl:variable name="fn" select="$ms/@name"/>
		<xsl:variable name="lf2id" select="my:xmiXMIrefs($ms/@receiveEvent)[@xmi:type='uml:MessageOccurrenceSpecification']/@covered"/>
		<xsl:variable name="p2n" select="my:xmiXMIrefs(my:xmiXMIrefs(my:xmiXMIrefs($ms/@receiveEvent)[@xmi:type='uml:MessageOccurrenceSpecification']/@covered)/@represents)/@name"/>
		<xsl:variable name="seq" select="$ms/parent::node()"/>
		<xsl:variable name="lfid" select="my:xmiXMIrefs($ms/@sendEvent)[@xmi:type='uml:MessageOccurrenceSpecification']/@covered"/>
		<xsl:variable name="pn" select="my:xmiXMIrefs(my:xmiXMIrefs(my:xmiXMIrefs($ms/@sendEvent)[@xmi:type='uml:MessageOccurrenceSpecification']/@covered)/@represents)/@name"/>
		<xsl:variable name="cn" select="concat(lower-case($pn),'_',lower-case($p2n),'_',$fn)"/>
		<xsl:element name="Channel">
			<xsl:attribute name="name" select="$cn"/>
			<xsl:attribute name="from" select="string-join($pn,' ')"/>
			<xsl:attribute name="to" select="string-join($p2n,' ')"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="ownedBehavior[@xmi:type='uml:Interaction']" mode="LifelineToPara">
		<xsl:param name="lfids"/>
		<xsl:message select="concat('LifelineToPara',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="seq" select="current()"/>
		<xsl:variable name="lft" select="$seq/lifeline[2]"/>
		<xsl:variable name="pnt" select="my:xmiXMIrefs($lft/@represents)/@name"/>
		<xsl:variable name="mot" select="my:xmiXMIrefs($lft/@coveredBy )[@xmi:type='uml:MessageOccurrenceSpecification']"/>
		<xsl:variable name="mest" select="my:xmiXMIrefs($mot/@message)"/>
		<xsl:variable name="lf" select="$seq/lifeline[1]"/>
		<xsl:variable name="lfid" select="$lf/@xmi:id"/>
		<xsl:variable name="pn" select="my:xmiXMIrefs($lf/@represents)/@name"/>
		<xsl:variable name="mo" select="my:xmiXMIrefs($lf/@coveredBy )[@xmi:type='uml:MessageOccurrenceSpecification']"/>
		<xsl:variable name="mes" select="my:xmiXMIrefs($mo/@message)"/>
		<xsl:variable name="cmes" select="my:Intersection($mes,$mest)"/>
		<xsl:variable name="pos" select="position()"/>
		<xsl:element name="CSP">
			<xsl:element name="Process">
				<xsl:attribute name="name" select="concat($pn,concat('_',$pnt))"/>
				<xsl:element name="Parallel ">
					<xsl:element name="SubProcess">
						<xsl:attribute name="type" select="'left'"/>
						<xsl:attribute name="target" select="string-join($pn,' ')"/>
					</xsl:element>
					<xsl:element name="SubProcess">
						<xsl:attribute name="type" select="'right'"/>
						<xsl:attribute name="target" select="string-join($pnt,' ')"/>
					</xsl:element>
					<xsl:apply-templates mode="MessageToChannel" select="$cmes"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="fragment[@xmi:type='uml:MessageOccurrenceSpecification' and not(@xmi:id=my:xmiXMIrefs(my:xmiXMIrefs(current()/@message)/@receiveEvent)[@xmi:type='uml:MessageOccurrenceSpecification']/@xmi:id) and my:xmiXMIrefs(@message)[my:xmiXMIrefs(@receiveEvent)[@xmi:type='uml:MessageOccurrenceSpecification']]]" mode="FragmentToSub">
		<xsl:param name="pn"/>
		<xsl:param name="lfid"/>
		<xsl:param name="nextP"/>
		<xsl:param name="frids"/>
		<xsl:message select="concat('FragmentToSub(SendEventToPrefix)',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="fr" select="current()"/>
		<xsl:variable name="mid" select="$fr/@xmi:id"/>
		<xsl:variable name="iop" select="$fr/parent::node()"/>
		<xsl:variable name="ms" select="my:xmiXMIrefs($fr/@message)"/>
		<xsl:variable name="fn" select="$ms/@name"/>
		<xsl:variable name="fr2" select="my:xmiXMIrefs($ms/@receiveEvent)[@xmi:type='uml:MessageOccurrenceSpecification']"/>
		<xsl:variable name="mid2" select="$fr2/@xmi:id"/>
		<xsl:variable name="ptn" select="my:xmiXMIrefs(my:xmiXMIrefs($fr2/@covered)/@represents)/@name"/>
		<xsl:variable name="pos" select="position() + 1"/>
		<xsl:variable name="nid" select="$frids[$pos]"/>
		<xsl:variable name="newNextP" select=" if (exists($nid)) then my:NewPName($pn,$nid) else $nextP "/>
		<xsl:variable name="pfnm" select="my:NewPName($pn,$mid)"/>
		<xsl:variable name="cn" select="concat(lower-case($pn),'_',lower-case($ptn),'_',$fn)"/>
		<xsl:element name="Prefix">
			<xsl:attribute name="name" select="$pfnm"/>
			<xsl:attribute name="target" select="string-join($newNextP,' ')"/>
			<xsl:element name="Event">
				<xsl:attribute name="name" select="$fn"/>
				<xsl:attribute name="direction" select="'!'"/>
				<xsl:attribute name="passBy" select="string-join($cn,' ')"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='loop']" mode="FragmentToSub">
		<xsl:param name="pn"/>
		<xsl:param name="lfid"/>
		<xsl:param name="nextP"/>
		<xsl:param name="frids"/>
		<xsl:message select="concat('FragmentToSub(LoopToIf)',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="fr" select="current()"/>
		<xsl:variable name="frid" select="$fr/@xmi:id"/>
		<xsl:variable name="op1" select="$fr/operand"/>
		<xsl:variable name="exp" select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
		<xsl:variable name="iop" select="$fr/parent::node()"/>
		<xsl:variable name="pos" select="position() + 1"/>
		<xsl:variable name="nid" select="$frids[$pos]"/>
		<xsl:variable name="newNextP" select=" if (exists($nid)) then my:NewPName($pn,$nid) else $nextP "/>
		<xsl:variable name="snm" select="my:NewPName($pn,$frid)"/>
		<xsl:element name="IfThenElse">
			<xsl:attribute name="name" select="$snm"/>
			<xsl:element name="bExp">
				<xsl:value-of select="$exp"/>
			</xsl:element>
			<xsl:element name="SubProcess">
				<xsl:attribute name="type" select="'then'"/>
				<xsl:apply-templates mode="OperandToSub" select="$op1">
					<xsl:with-param name="pn" select="$pn"/>
					<xsl:with-param name="lfid" select="$lfid"/>
					<xsl:with-param name="nextP" select="$snm"/>
				</xsl:apply-templates>
			</xsl:element>
			<xsl:element name="SubProcess">
				<xsl:attribute name="type" select="'else'"/>
				<xsl:attribute name="target" select="string-join($newNextP,' ')"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='alt' and operand[2] and operand[not(guard)][1]]" mode="FragmentToSub">
		<xsl:param name="pn"/>
		<xsl:param name="lfid"/>
		<xsl:param name="nextP"/>
		<xsl:param name="frids"/>
		<xsl:message select="concat('FragmentToSub(AltToExt)',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="fr" select="current()"/>
		<xsl:variable name="frid" select="$fr/@xmi:id"/>
		<xsl:variable name="iop" select="$fr/parent::node()"/>
		<xsl:variable name="op2" select="$fr/operand[2]"/>
		<xsl:variable name="op1" select="$fr/operand[1]"/>
		<xsl:variable name="pos" select="position() + 1"/>
		<xsl:variable name="nid" select="$frids[$pos]"/>
		<xsl:variable name="newNextP" select=" if (exists($nid)) then my:NewPName($pn,$nid) else $nextP "/>
		<xsl:variable name="snm" select="my:NewPName($pn,$frid)"/>
		<xsl:element name="ExternalChoice">
			<xsl:attribute name="name" select="$snm"/>
			<xsl:element name="SubProcess">
				<xsl:attribute name="type" select="'left'"/>
				<xsl:apply-templates mode="OperandToSub" select="$op1">
					<xsl:with-param name="pn" select="$pn"/>
					<xsl:with-param name="lfid" select="$lfid"/>
					<xsl:with-param name="nextP" select="$newNextP"/>
				</xsl:apply-templates>
			</xsl:element>
			<xsl:element name="SubProcess">
				<xsl:attribute name="type" select="'right'"/>
				<xsl:apply-templates mode="OperandToSub" select="$op2">
					<xsl:with-param name="pn" select="$pn"/>
					<xsl:with-param name="lfid" select="$lfid"/>
					<xsl:with-param name="nextP" select="$newNextP"/>
				</xsl:apply-templates>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="ownedBehavior[@xmi:type='uml:Interaction']" mode="OperandToSub">
		<xsl:param name="pn"/>
		<xsl:param name="lfid"/>
		<xsl:param name="nextP"/>
		<xsl:message select="concat('OperandToSub(InteractionToSub)',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="iop" select="current()"/>
		<xsl:variable name="fr" select="$iop/fragment"/>
		<xsl:variable name="lf" select="my:xmiXMIrefs($fr/@covered)"/>
		<xsl:variable name="msg" select="'MessageOccurrenceSpecification'"/>
		<xsl:variable name="cmb" select="'CombinedFragment'"/>
		<xsl:variable name="frs" select="$iop/fragment[my:xmiXMIrefs(@covered)/@xmi:id=$lfid][substring-after(@xmi:type,'uml:')=$msg or substring-after(@xmi:type,'uml:')=$cmb]"/>
		<xsl:variable name="frids" select="$frs/@xmi:id"/>
		<xsl:apply-templates mode="FragmentToSub" select="$frs">
			<xsl:with-param name="pn" select="$pn"/>
			<xsl:with-param name="lfid" select="$lfid"/>
			<xsl:with-param name="nextP" select="$nextP"/>
			<xsl:with-param name="frids" select="$frids"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='break']" mode="FragmentToSub">
		<xsl:param name="pn"/>
		<xsl:param name="lfid"/>
		<xsl:param name="nextP"/>
		<xsl:param name="frids"/>
		<xsl:message select="concat('FragmentToSub(BreaktToIf)',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="fr" select="current()"/>
		<xsl:variable name="frid" select="$fr/@xmi:id"/>
		<xsl:variable name="iop" select="$fr/parent::node()"/>
		<xsl:variable name="op1" select="$fr/operand"/>
		<xsl:variable name="exp" select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
		<xsl:variable name="pos" select="position() + 1"/>
		<xsl:variable name="nid" select="$frids[$pos]"/>
		<xsl:variable name="newNextP" select=" if (exists($nid)) then my:NewPName($pn,$nid) else $nextP "/>
		<xsl:variable name="snm" select="my:NewPName($pn,$frid)"/>
		<xsl:element name="IfThenElse">
			<xsl:attribute name="name" select="$snm"/>
			<xsl:element name="bExp">
				<xsl:value-of select="$exp"/>
			</xsl:element>
			<xsl:element name="SubProcess">
				<xsl:attribute name="type" select="'then'"/>
				<xsl:apply-templates mode="OperandToSub" select="$op1">
					<xsl:with-param name="pn" select="$pn"/>
					<xsl:with-param name="lfid" select="$lfid"/>
					<xsl:with-param name="nextP" select="'SKIP'"/>
				</xsl:apply-templates>
			</xsl:element>
			<xsl:element name="SubProcess">
				<xsl:attribute name="type" select="'else'"/>
				<xsl:attribute name="target" select="string-join($newNextP,' ')"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='opt']" mode="FragmentToSub">
		<xsl:param name="pn"/>
		<xsl:param name="lfid"/>
		<xsl:param name="nextP"/>
		<xsl:param name="frids"/>
		<xsl:message select="concat('FragmentToSub(OptToIf)',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="fr" select="current()"/>
		<xsl:variable name="frid" select="$fr/@xmi:id"/>
		<xsl:variable name="iop" select="$fr/parent::node()"/>
		<xsl:variable name="op1" select="$fr/operand"/>
		<xsl:variable name="exp" select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
		<xsl:variable name="pos" select="position() + 1"/>
		<xsl:variable name="nid" select="$frids[$pos]"/>
		<xsl:variable name="newNextP" select=" if (exists($nid)) then my:NewPName($pn,$nid) else $nextP "/>
		<xsl:variable name="snm" select="my:NewPName($pn,$frid)"/>
		<xsl:element name="IfThenElse">
			<xsl:attribute name="name" select="$snm"/>
			<xsl:element name="bExp">
				<xsl:value-of select="$exp"/>
			</xsl:element>
			<xsl:element name="SubProcess">
				<xsl:attribute name="type" select="'then'"/>
				<xsl:apply-templates mode="OperandToSub" select="$op1">
					<xsl:with-param name="pn" select="$pn"/>
					<xsl:with-param name="lfid" select="$lfid"/>
					<xsl:with-param name="nextP" select="$newNextP"/>
				</xsl:apply-templates>
			</xsl:element>
			<xsl:element name="SubProcess">
				<xsl:attribute name="type" select="'else'"/>
				<xsl:attribute name="target" select="string-join($newNextP,' ')"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='alt' and operand[guard[specification[@xmi:type='uml:LiteralString']]][1] and operand[2]]" mode="FragmentToSub">
		<xsl:param name="pn"/>
		<xsl:param name="lfid"/>
		<xsl:param name="nextP"/>
		<xsl:param name="frids"/>
		<xsl:message select="concat('FragmentToSub(AltToIf)',' : ',@xmi:id,' : ',@name)"/>
		<xsl:variable name="fr" select="current()"/>
		<xsl:variable name="frid" select="$fr/@xmi:id"/>
		<xsl:variable name="iop" select="$fr/parent::node()"/>
		<xsl:variable name="op1" select="$fr/operand[1]"/>
		<xsl:variable name="exp" select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
		<xsl:variable name="op2" select="$fr/operand[2]"/>
		<xsl:variable name="pos" select="position() + 1"/>
		<xsl:variable name="nid" select="$frids[$pos]"/>
		<xsl:variable name="newNextP" select=" if (exists($nid)) then my:NewPName($pn,$nid) else $nextP "/>
		<xsl:variable name="snm" select="my:NewPName($pn,$frid)"/>
		<xsl:element name="IfThenElse">
			<xsl:attribute name="name" select="$snm"/>
			<xsl:element name="bExp">
				<xsl:value-of select="$exp"/>
			</xsl:element>
			<xsl:element name="SubProcess">
				<xsl:attribute name="type" select="'else'"/>
				<xsl:apply-templates mode="OperandToSub" select="$op2">
					<xsl:with-param name="pn" select="$pn"/>
					<xsl:with-param name="lfid" select="$lfid"/>
					<xsl:with-param name="nextP" select="$newNextP"/>
				</xsl:apply-templates>
			</xsl:element>
			<xsl:element name="SubProcess">
				<xsl:attribute name="type" select="'then'"/>
				<xsl:apply-templates mode="OperandToSub" select="$op1">
					<xsl:with-param name="pn" select="$pn"/>
					<xsl:with-param name="lfid" select="$lfid"/>
					<xsl:with-param name="nextP" select="$newNextP"/>
				</xsl:apply-templates>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:function name="my:GetNewId">
<xsl:param name="in"/>	
<xsl:param name="pos"/>
		   
<xsl:variable name="p1" select="substring($in,1,$pos)"/>

<xsl:variable name="p2" select="substring($in,$pos+1)"/>
		   
<xsl:value-of select="concat($p2,$p1)"/><xsl:message select="concat('GetNewId',' : ',' : ')"/></xsl:function>
	<xsl:function name="my:NewPName">
<xsl:param name="pn"/>	
<xsl:param name="id"/>		   
	   
<xsl:value-of select="concat($pn,'_',substring($id,37))"/>
<xsl:message select="concat('NewPName',' : ',' : ')"/></xsl:function>
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