<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:SyntaxTree.SyntaxTree_ClassModel="http://rcos.iist.unu.edu/SyntaxTree.uml" xmlns:CSP="http:///CSP.ecore" xmlns:my="http:///rcos.iist.unu.edu/2008/lidan"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" xmlns:uml="http://www.eclipse.org/uml2/3.0.0/UML" xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" xmlns:rCOS="http://rcos.iist.unu.edu/rCOS.profile.uml" xmlns:di="http://www.topcased.org/DI/1.0" xmlns:diagrams="http://www.topcased.org/Diagrams/1.0">


<!-- these two functions should be generated , later,  ld, 2010-12-3 -->
<!--



<xsl:function name="my:GetTypedModel">
	<xsl:param name="modelnm"/>
	<xsl:param name="xmiid"/>
	
	<xsl:variable name="iid" select="if (contains($xmiid,'#')) then substring-after($xmiid,'#') else $xmiid"/>	
	
	<xsl:choose>
		<xsl:when test="$modelnm='digamDIAGRAM'">
			<xsl:sequence select="if (string-length($xmiid)>0) then $digamDIAGRAM//*[@xmi:id=$iid] else $digamDIAGRAM"/>
		</xsl:when>
	</xsl:choose>
	
</xsl:function>

<xsl:function name="my:GetLifelines">
	<xsl:param name="seq"/>
	<xsl:param name="lfnms"/>
	
	
	<xsl:for-each select="$lfnms">
		<xsl:variable name="nm" select="."/>	
		<xsl:sequence select="$seq/lifeline[@name=$nm]"/> 
	</xsl:for-each>
	
	
</xsl:function>


<xsl:function name="my:GetLfMesOcc">
	<xsl:param name="lfs"/>
		
	<xsl:sequence select="my:xmiXMIrefs($lfls/@coveredBy)[@xmi:type='uml:MessageOccurrenceSpecification']"/>
	
</xsl:function>



<xsl:function name="my:CalcuMessages">
	<xsl:param name="type"/>
	<xsl:param name="lf"/>
	<xsl:param name="olfs"/>
	
	<xsl:variable name="alllfs" select="insert-before($lf,1,$olfs)"/>
	
	<xsl:variable name="allmes" select="my:xmiXMIrefs(distinct-values(my:xmiXMIrefs($alllfs/@coveredBy)[@xmi:type='uml:MessageOccurrenceSpecification']/@message))"/>
	
	<xsl:variable name="vvvv">
		<xsl:for-each select="$allmes">
			<xsl:variable name="ms" select="."/>
			<xsl:variable name="sdlfid" select="my:xmiXMIrefs($ms/@sendEvent)/@covered"/>
			<xsl:variable name="reclfid" select="my:xmiXMIrefs($ms/@receiveEvent)/@covered"/>
			
			<xsl:choose>
				<xsl:when test="exists($alllfs[@xmi:id=$sdlfid]) and exists($alllfs[@xmi:id=$reclfid])">
					<xsl:if test="$type='remove'">
						<xsl:sequence select="$ms"/>
					</xsl:if>	
				</xsl:when>
				<xsl:when test="exists($alllfs[@xmi:id=$sdlfid])">
					<xsl:if test="$type='send'">
						<xsl:sequence select="$ms"/>
					</xsl:if>	
				</xsl:when>		
				<xsl:when test="exists($alllfs[@xmi:id=$reclfid])">
					<xsl:if test="$type='receive'">
						<xsl:sequence select="$ms"/>
					</xsl:if>	
				</xsl:when>						
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>	

	<xsl:sequence select="$vvvv/*"/>
	
</xsl:function>



<xsl:function name="my:CalcuRequireOps">
	<xsl:param name="lf"/>
	<xsl:param name="olfs"/>
	
	<xsl:variable name="alllfs" select="insert-before($lf,1,$olfs)"/>
	
	<xsl:variable name="allmes" select="my:xmiXMIrefs(distinct-values(my:xmiXMIrefs($alllfs/@coveredBy)[@xmi:type='uml:MessageOccurrenceSpecification']/@message))"/>
	
	<xsl:variable name="vvvv">
		<xsl:for-each select="$allmes">
			<xsl:variable name="ms" select="."/>
			<xsl:variable name="sdlfid" select="my:xmiXMIrefs($ms/@sendEvent)/@covered"/>
			<xsl:variable name="reclfid" select="my:xmiXMIrefs($ms/@receiveEvent)/@covered"/>
			
			<xsl:if test="not(exists($alllfs[@xmi:id=$sdlfid]) and exists($alllfs[@xmi:id=$reclfid]))">
				<xsl:if test="exists($alllfs[@xmi:id=$sdlfid])">
					<xsl:sequence select="$ms"/>
				</xsl:if>	
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>	
		
	<xsl:variable name="outmes" select="$vvvv/*"/>	
	<xsl:variable name="pops" select="my:xmiXMIrefs(distinct-values(my:xmiXMIrefs(my:xmiXMIrefs($outmes/@receiveEvent)/@event)[@xmi:type='uml:CallEvent']/@operation))"/>	
	<xsl:sequence select="$pops"/>
	
</xsl:function>


<xsl:function name="my:CalcuProvideOps">
	<xsl:param name="lf"/>
	<xsl:param name="olfs"/>
	
	<xsl:variable name="alllfs" select="insert-before($lf,1,$olfs)"/>
	
	<xsl:variable name="allmes" select="my:xmiXMIrefs(distinct-values(my:xmiXMIrefs($alllfs/@coveredBy)[@xmi:type='uml:MessageOccurrenceSpecification']/@message))"/>
	
	<xsl:variable name="vvvv">
		<xsl:for-each select="$allmes">
			<xsl:variable name="ms" select="."/>
			<xsl:variable name="sdlfid" select="my:xmiXMIrefs($ms/@sendEvent)/@covered"/>
			<xsl:variable name="reclfid" select="my:xmiXMIrefs($ms/@receiveEvent)/@covered"/>
			
			<xsl:if test="not(exists($alllfs[@xmi:id=$sdlfid]) and exists($alllfs[@xmi:id=$reclfid]))">
				<xsl:if test="exists($alllfs[@xmi:id=$reclfid])">
					<xsl:sequence select="$ms"/>
				</xsl:if>	
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>	
		
	<xsl:variable name="outmes" select="$vvvv/*"/>	
	<xsl:variable name="pops" select="my:xmiXMIrefs(distinct-values(my:xmiXMIrefs(my:xmiXMIrefs($outmes/@receiveEvent)/@event)[@xmi:type='uml:CallEvent']/@operation))"/>	
	<xsl:sequence select="$pops"/>	
	
</xsl:function>


		<xsl:variable name="lfl" select="current()"/>
		<xsl:variable name="seq" select="$lfl/parent::node()"/>		
		
		<xsl:variable name="olfs" select="my:GetLifelines($seq,$jointLifelinName)"/>	
		
		<xsl:variable name="messs" select="my:CalcuMessages('send',$lfl,$olfs)"/>
			
		<xsl:variable name="tpops" select="my:CalcuProvideOps($lfl,null)"/>
		
		<xsl:variable name="trops" select="my:CalcuRequireOps($lfl,null)"/>


<xsl:function name="my:GetGraphElements">
	<xsl:param name="eleId"/>	
	

	<xsl:variable name="refid" select="concat($sourceTypedModels[1]/@file,'#',$eleId)"/>	
	
	<xsl:sequence select="$digamDIAGRAM//*[semanticModel[@xsi:type='di:EMFSemanticModelBridge']/element[@href=$refid]]"/>

</xsl:function>




<xsl:function name="my:CheckTransValidate">
	<xsl:param name="clsmodel"/>
	<xsl:param name="lfl"/>
	<xsl:param name="olfls"/>
	<xsl:param name="receivems"/>

	<xsl:variable name="lflclsid" select="my:xmiXMIrefs($lfl/@represents)/@type"/>	
	<xsl:variable name="diConnClsids" select="my:GetConnClassIds($clsmodel,$lflclsid)"/>
	
	<xsl:variable name="reclflids" select="distinct-values(my:xmiXMIrefs($receivems/@receiveEvent)/@covered)"/>
	
	<xsl:variable name="vvv">
	
	<xsl:for-each select="$olfls">
		<xsl:variable name="olfl" select="."/>
		<xsl:variable name="oclsid" select="my:xmiXMIrefs($olfl/@represents)/@type"/>
	
		<xsl:choose>
			<xsl:when test="index-of($diConnClsids,$oclsid)>0">
				<diClsid><xsl:value-of select="$oclsid"/></diClsid>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="index-of($reclflids,$olfl/@xmi:id)>0">
						<notallow><xsl:sequence select="$olfl"/></notallow>
					</xsl:when>
					<xsl:otherwise>
						<indilfl><xsl:sequence select="$olfl"/></indilfl>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>

	</xsl:variable>
	
	<xsl:choose>
		<xsl:when test="exists($vvv/notallow)">
			<xsl:sequence select="$vvv/notallow/*"/>
		</xsl:when>
		<xsl:otherwise>
				<xsl:variable name="qqq">
					<xsl:call-template name="DoCheckTransValidate">
						<xsl:with-param name="clsmodel" select="$clsmodel"/>
						<xsl:with-param name="connclsids" select="$vvv/diClsid"/>
						<xsl:with-param name="olfls" select="$vvv/indilfl/*"/>
						<xsl:with-param name="num" select="4"/>
					</xsl:call-template>			
				</xsl:variable>
				<xsl:sequence select="$qqq/child::node()"/>
		</xsl:otherwise>
	</xsl:choose>	
</xsl:function>


<xsl:template name="DoCheckTransValidate">
	<xsl:param name="clsmodel"/>
	<xsl:param name="connclsids"/>
	<xsl:param name="olfls"/>
	<xsl:param name="num"/>
	
	<xsl:choose>
	<xsl:when test="$num = 0 or empty($connclsids) or empty($olfls)">
		 <xsl:sequence select="$olfls"/>
	</xsl:when>
	<xsl:otherwise>
	
	<xsl:variable name="diConnClsids" select="my:GetConnClassIds($clsmodel,$connclsids)"/>
	
	<xsl:variable name="vvv">
	
	<xsl:for-each select="$olfls">
	
		<xsl:variable name="olfl" select="."/>
		<xsl:variable name="oclsid" select="my:xmiXMIrefs($olfl/@represents)/@type"/>	
		
		<xsl:choose>
			<xsl:when test="exists($diConnClsids) and index-of($diConnClsids,$oclsid)>0">
				<diClsid><xsl:value-of select="$oclsid"/></diClsid>
			</xsl:when>
			<xsl:otherwise>
				<indilfl><xsl:sequence select="$olfl"/></indilfl>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>

	</xsl:variable>
	
	<xsl:call-template name="DoCheckTransValidate">
		<xsl:with-param name="clsmodel" select="$clsmodel"/>
		<xsl:with-param name="connclsids" select="$vvv/diClsid"/>
		<xsl:with-param name="olfls" select="$vvv/indilfl/*"/>
		<xsl:with-param name="num" select="$num - 1"/>
	</xsl:call-template>
	
	</xsl:otherwise>
	</xsl:choose>

</xsl:template>


<xsl:function name="my:GetConnClassIds">
	<xsl:param name="clsmodel"/>
	<xsl:param name="lflclsids"/>
	
	<xsl:variable name="vvvv">
		
	<xsl:for-each select="$lflclsids">
	
	<xsl:variable name="lflclsid" select="."/>
	
	<xsl:variable name="allcls" select="my:GetAllSuperClass($lflclsid)"/>
	
	<xsl:for-each select="$allcls">
		<xsl:variable name="clsid" select="./@xmi:id"/>
		
		<xsl:call-template name="DoGetShowValue">
			<xsl:with-param name="ids" select="$clsmodel//*[@xmi:type='uml:Association' and ownedEnd[1]/@type=$clsid and not(ownedEnd[1]/@aggregation) and (not(@navigableOwnedEnd) or @navigableOwnedEnd=ownedEnd[2]/@xmi:id)]/ownedEnd[2]/@type"/>
		</xsl:call-template>

		<xsl:call-template name="DoGetShowValue">
			<xsl:with-param name="ids" select="$clsmodel//*[@xmi:type='uml:Association' and ownedEnd[2]/@type=$clsid and not(ownedEnd[2]/@aggregation) and (not(@navigableOwnedEnd) or @navigableOwnedEnd=ownedEnd[1]/@xmi:id)]/ownedEnd[1]/@type"/>
		</xsl:call-template>
		
	</xsl:for-each>
	
	</xsl:for-each>
	
	</xsl:variable>	
	
	<xsl:sequence select="distinct-values($vvvv/child::node())"/>
	
</xsl:function>

<xsl:template name="DoGetShowValue">
	<xsl:param name="ids"/>
	<xsl:for-each select="$ids">
		<val><xsl:value-of select="."/> </val>
	</xsl:for-each>
</xsl:template>

<xsl:function name="my:GetLifelineMess">
	<xsl:param name="seq"/>
	<xsl:param name="frags"/>
	
	<xsl:variable name="vvvv">
	<xsl:for-each select="$frags">
		<xsl:variable name="eleid" select="."/>
		
		<xsl:variable name="mesid" select="$seq//*[@xmi:id=$eleid and @xmi:type='uml:MessageOccurrenceSpecification']/@message"/>
		
		<xsl:if test="exists($mesid)">
			<xsl:variable name="mes" select="$seq//*[@xmi:id=$mesid]"/>
			<xsl:choose>
				<xsl:when test="$mes/@sendEvent=$eleid">
					<send><val><xsl:value-of select="$mesid"/></val></send>
				</xsl:when>
				<xsl:otherwise>
					<receive><val><xsl:value-of select="$mesid"/></val></receive>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		
		<xsl:if test="starts-with($eleid,'NEW_')">
			<xsl:variable name="nmesid" select="$seq//*[@xmi:id=substring-after($eleid,'NEW_') and @xmi:type='uml:MessageOccurrenceSpecification']/@message"/>
			<xsl:if test="exists($nmesid)">
				<send><val><xsl:value-of select="concat('OLD_',$nmesid)"/></val></send>			
			</xsl:if>
		</xsl:if>		
	
		<xsl:if test="starts-with($eleid,'OLD_')">
			<xsl:variable name="omesid" select="$seq//*[@xmi:id=substring-after($eleid,'OLD_') and @xmi:type='uml:MessageOccurrenceSpecification']/@message"/>
			<xsl:if test="exists($omesid)">
				<receive><val><xsl:value-of select="concat('OLD_',$omesid)"/></val></receive>			
			</xsl:if>
		</xsl:if>	
	
	</xsl:for-each>
	</xsl:variable>

	<xsl:sequence select="$vvvv"/>
	
</xsl:function>

<xsl:function name="my:GetLflGEdgeConntors">
	<xsl:param name="seq"/>
	<xsl:param name="frags"/>
	<xsl:param name="seqdig"/>
	
	<xsl:variable name="lflmes" select="my:GetLifelineMess($seq,$frags)"/>
	
	<xsl:variable name="vvvv">	
	
	<xsl:for-each select="$lflmes/send/*">
		<xsl:variable name="msid" select="."/>
		<xsl:choose>
			<xsl:when test="starts-with($msid,'OLD_')">
				<xsl:variable name="edg" select="$seqdig//contained[@xsi:type='di:GraphEdge' and semanticModel/element[substring-after(@href,'#')=substring-after($msid,'OLD_')]]"/>		
				<val><xsl:value-of select="concat('OLD_',substring-before($edg/@anchor,' '))"/></val>			
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="edg" select="$seqdig//contained[@xsi:type='di:GraphEdge' and semanticModel/element[substring-after(@href,'#')=$msid]]"/>		
				<val><xsl:value-of select="substring-before($edg/@anchor,' ')"/></val>			
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each> 	
	
	<xsl:for-each select="$lflmes/receive/*">
		<xsl:variable name="msid" select="."/>
		<xsl:choose>
			<xsl:when test="starts-with($msid,'OLD_')">
				<xsl:variable name="edg" select="$seqdig//contained[@xsi:type='di:GraphEdge' and semanticModel/element[substring-after(@href,'#')=substring-after($msid,'OLD_')]]"/>		
				<val><xsl:value-of select="concat('OLD_',substring-after($edg/@anchor,' '))"/></val>			
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="edg" select="$seqdig//contained[@xsi:type='di:GraphEdge' and semanticModel/element[substring-after(@href,'#')=$msid]]"/>		
				<val><xsl:value-of select="substring-after($edg/@anchor,' ')"/></val>			
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>	
	
	</xsl:variable>	
	
	<xsl:sequence select="$vvvv/child::node()"/>
	
</xsl:function>

<xsl:function name="my:GetGraphEdgeConntors">
	<xsl:param name="seqdig"/>
	<xsl:param name="receivems"/>
	<xsl:param name="movems"/>
	
	<xsl:variable name="mids" select="$receivems/@xmi:id"/>
	
	<xsl:variable name="edgs" select="$seqdig//contained[@xsi:type='di:GraphEdge' and semanticModel/element[substring-after(@href,'#')=$mids]]"/>
	
	<xsl:variable name="oldmids" select="$movems/@xmi:id"/>
	
	<xsl:variable name="oldedgs" select="$seqdig//contained[@xsi:type='di:GraphEdge' and semanticModel/element[substring-after(@href,'#')=$oldmids]]"/>	
	
	
	<xsl:variable name="vvvv">
		<xsl:for-each select="$edgs">
			<all>
			<val><xsl:value-of select="substring-before(@anchor,' ')"/></val>
			<val><xsl:value-of select="substring-after(@anchor,' ')"/></val>
			</all>
			<left><val><xsl:value-of select="substring-before(@anchor,' ')"/></val></left>
			<right><val><xsl:value-of select="substring-after(@anchor,' ')"/></val></right>
		</xsl:for-each>
		<xsl:for-each select="$oldedgs">
			<all>
			<val><xsl:value-of select="concat('OLD_',substring-before(@anchor,' '))"/></val>
			<val><xsl:value-of select="concat('OLD_',substring-after(@anchor,' '))"/></val>
			</all>
			<left><val><xsl:value-of select="concat('OLD_',substring-before(@anchor,' '))"/></val></left>
			<right><val><xsl:value-of select="concat('OLD_',substring-after(@anchor,' '))"/></val></right>
		</xsl:for-each>		
	</xsl:variable>	
	
	<xsl:sequence select="$vvvv"/>
	
</xsl:function>


<xsl:function name="my:GetMesConntorIds">
	<xsl:param name="seqdig"/>
	<xsl:param name="receivems"/>
	
	<xsl:variable name="mids" select="$receivems/@xmi:id"/>	
	<xsl:variable name="edgs" select="$seqdig//contained[@xsi:type='di:GraphEdge' and semanticModel/element[substring-after(@href,'#')=$mids]]"/>
	
	<xsl:variable name="vvvv">
		<xsl:for-each select="$edgs">
			<val><xsl:value-of select="substring-before(@anchor,' ')"/></val>
			<val><xsl:value-of select="substring-after(@anchor,' ')"/></val>
		</xsl:for-each>
	</xsl:variable>	
	
	<xsl:sequence select="$vvvv/child::node()"/>
	
</xsl:function>



<xsl:function name="my:GetSeqSemanAllIds">
	<xsl:param name="fragids"/>
	<xsl:param name="afragids"/>
	<xsl:param name="receivems"/>
	<xsl:param name="movems"/>
	
	<xsl:variable name="vvvv">
		<xsl:for-each select="$receivems">
			<val><xsl:value-of select="@xmi:id"/></val>
		</xsl:for-each>
		<xsl:for-each select="$movems">
			<val><xsl:value-of select="concat('OLD_',@xmi:id)"/></val>
		</xsl:for-each>		
	</xsl:variable>
	
	<xsl:variable name="vv2" select="insert-before(insert-before($vvvv/child::node(),1,$fragids),1,$afragids)"/>
	
	<xsl:sequence select="distinct-values($vv2)"/>

</xsl:function>



<xsl:function name="my:GetSeqSemanAllIds_old">
	<xsl:param name="actorlfl"/>
	<xsl:param name="lfl"/>
	<xsl:param name="fragids"/>
	<xsl:param name="afragids"/>
	<xsl:param name="receivems"/>
	
	<xsl:variable name="vvvv">
		<val><xsl:value-of select="$actorlfl/@xmi:id"/></val>
		<val><xsl:value-of select="$lfl/@xmi:id"/></val>
		
		<xsl:for-each select="$receivems">
			<val><xsl:value-of select="@xmi:id"/></val>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:variable name="vv2" select="insert-before(insert-before($vvvv/child::node(),1,$fragids),1,$afragids)"/>
	
	<xsl:sequence select="distinct-values($vv2)"/>

</xsl:function>


<xsl:function name="my:GetActorFrag">
	<xsl:param name="fragids"/>
	<xsl:param name="actorlfl"/>

	<xsl:variable name="vvvv">
		<xsl:for-each select="$fragids">
			<xsl:variable name="id" select="."/>
			<xsl:variable name="frag" select="$xmiXMI//key('xmiId',$id)"/>
			<xsl:choose>
				<xsl:when test="$frag[@xmi:type='uml:MessageOccurrenceSpecification']">
					<xsl:variable name="mes" select="$xmiXMI//key('xmiId',$frag/@message)"/>
					<val><xsl:value-of  select="if ($id=$mes/@receiveEvent) then $mes/@sendEvent else $mes/receiveEvent"/></val>				
				</xsl:when>
				<xsl:when test="$frag[@xmi:type='uml:BehaviorExecutionSpecification']">
				</xsl:when>
				<xsl:otherwise>
					<val><xsl:value-of  select="$id"/></val>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<val>
		<xsl:value-of select="$xmiXMI//fragment[@xmi:type='uml:BehaviorExecutionSpecification'][@covered=$actorlfl/@xmi:id]/@xmi:id[1]"/>
		</val>
	</xsl:variable>	
	
	<xsl:sequence select="$vvvv/child::node()"/>

</xsl:function>

<xsl:function name="my:CalcuLifelines">

	<xsl:param name="lf"/>
	<xsl:param name="olfs"/>
	
	<xsl:variable name="alllfs" select="insert-before($lf,1,$olfs)"/>
	
	<xsl:variable name="allmes" select="my:xmiXMIrefs(distinct-values(my:xmiXMIrefs($alllfs/@coveredBy)[@xmi:type='uml:MessageOccurrenceSpecification']/@message))"/>
	
	<xsl:variable name="vvvv">
		<xsl:for-each select="$allmes">
			<xsl:variable name="ms" select="."/>
			<xsl:variable name="sdlfid" select="my:xmiXMIrefs($ms/@sendEvent)/@covered"/>
			<xsl:variable name="reclfid" select="my:xmiXMIrefs($ms/@receiveEvent)/@covered"/>
			
			<xsl:choose>
				<xsl:when test="exists($alllfs[@xmi:id=$sdlfid]) and exists($alllfs[@xmi:id=$reclfid])">

					<removems><xsl:sequence select="$ms"/></removems>
					<removemocc><xsl:sequence select="$xmiXMI//key('xmiId',$ms/@receiveEvent)"/></removemocc>
					<removemocc><xsl:sequence select="$xmiXMI//key('xmiId',$ms/@sendEvent)"/></removemocc>					
	
				</xsl:when>
				
			
				<xsl:when test="exists($olfs[@xmi:id=$sdlfid])">
					<sendms><xsl:sequence select="$ms"/></sendms>
					<sendmocc><xsl:sequence select="$xmiXMI//key('xmiId',$ms/@sendEvent)"/></sendmocc>
				</xsl:when>		
				
				<xsl:when test="exists($olfs[@xmi:id=$reclfid])">
						<receivems><xsl:sequence select="$ms"/></receivems>
						<receivemocc><xsl:sequence select="$xmiXMI//key('xmiId',$ms/@receiveEvent)"/></receivemocc>
				</xsl:when>	

									
			</xsl:choose>
			
			<xsl:if test="not(exists($alllfs[@xmi:id=$sdlfid]) and exists($alllfs[@xmi:id=$reclfid]))">
				<xsl:if test="exists($alllfs[@xmi:id=$reclfid])">
					<proms><xsl:sequence select="$ms"/></proms>
					<dosdlfid><xsl:value-of select="$sdlfid"/></dosdlfid>
				</xsl:if>	
			</xsl:if>	
			
			<xsl:if test="not(exists($alllfs[@xmi:id=$sdlfid]) and exists($alllfs[@xmi:id=$reclfid]))">
				<xsl:if test="exists($alllfs[@xmi:id=$sdlfid])">
					<reqms><xsl:sequence select="$ms"/></reqms>
					<dorecvlfid><xsl:value-of select="$reclfid"/></dorecvlfid>
				</xsl:if>	
			</xsl:if>		
			
			
		</xsl:for-each>
	</xsl:variable>	
	
	<xsl:variable name="dorecvlf" select="my:xmiXMIrefs(distinct-values($vvvv/dorecvlfid))"/>
	
	<xsl:variable name="provvv" select="my:xmiXMIrefs(my:xmiXMIrefs(my:xmiXMIrefs($dorecvlf/@represents)/@type)[@xmi:type='uml:Component']/interfaceRealization/@supplier)"/>	
	
	<xsl:variable name="provideifs">
		<provideifs>
			<xsl:sequence select="$provvv"/>	
		</provideifs>
	</xsl:variable>
	
	<xsl:variable name="provideifids">
		<provideifids>
		<val>
			<xsl:sequence select="string-join($provvv/@xmi:id,' ')"/>
		</val>	
		</provideifids>
	</xsl:variable>	
	
	<xsl:variable name="dosdlf" select="my:xmiXMIrefs(distinct-values($vvvv/dosdlfid))"/>	
	
	<xsl:variable name="reqvv" select="my:xmiXMIrefs(my:xmiXMIrefs(my:xmiXMIrefs($dosdlf/@represents)/@type)[@xmi:type='uml:Component']/packagedElement[@xmi:type='uml:Usage']/@supplier)"/>	

	<xsl:variable name="requireifs">
		<requireifs>
			<xsl:sequence select="my:GetGraphElements($reqvv/@xmi:id)"/>	
		</requireifs>
	</xsl:variable>
	
	<xsl:variable name="requireifids">
		<requireifids>
		<val>
			<xsl:sequence select="string-join($reqvv/@xmi:id,' ')"/>
		</val>	
		</requireifids>
	</xsl:variable>	
	
	<xsl:variable name="sdocc" select="$vvvv/sendmocc/*"/>	
	<xsl:variable name="sendbhav">
		<sendbhav>
			<xsl:sequence select="$xmiXMI//fragment[@xmi:type='uml:BehaviorExecutionSpecification'][@start=$sdocc/@xmi:id or @finish=$sdocc/@xmi:id]"/>
		</sendbhav>
	</xsl:variable>	
	
	<xsl:variable name="rvocc" select="$vvvv/receivemocc/*"/>	
	<xsl:variable name="receivebhav">
		<receivebhav>
			<xsl:sequence select="$xmiXMI//fragment[@xmi:type='uml:BehaviorExecutionSpecification'][@start=$rvocc/@xmi:id or @finish=$rvocc/@xmi:id]"/>
		</receivebhav>
	</xsl:variable>
	
	
	<xsl:variable name="rmocc" select="$vvvv/removemocc/*"/>	
	<xsl:variable name="behavs">
		<xsl:for-each select="$lf/parent::node()/fragment[@xmi:type='uml:BehaviorExecutionSpecification']">
			<xsl:variable name="bhv" select="."/>
			<xsl:choose>
				<xsl:when test="exists($rmocc[@xmi:id=$bhv/@start]) and exists($rmocc[@xmi:id=$bhv/@finish])">
					<removebhav><xsl:sequence select="$bhv"/></removebhav>
				</xsl:when>
				<xsl:when test="exists($rmocc[@xmi:id=$bhv/@start])">
					<chstartbhav><xsl:sequence select="$bhv"/></chstartbhav>
				</xsl:when>	
				<xsl:when test="exists($rmocc[@xmi:id=$bhv/@finish])">
					<chfinishbhav><xsl:sequence select="$bhv"/></chfinishbhav>
				</xsl:when>							
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>

	
	<xsl:variable name="proms" select="$vvvv/proms/*"/>
	<xsl:variable name="pops">
		<pops>	
			<xsl:sequence select="my:xmiXMIrefs(distinct-values(my:xmiXMIrefs(my:xmiXMIrefs($proms/@receiveEvent)/@event)[@xmi:type='uml:CallEvent']/@operation))"/>
		</pops>
	</xsl:variable>		
	
	<xsl:variable name="reqms" select="$vvvv/reqms/*"/>
	<xsl:variable name="rops">
		<rops>	
			<xsl:sequence select="my:xmiXMIrefs(distinct-values(my:xmiXMIrefs(my:xmiXMIrefs($reqms/@receiveEvent)/@event)[@xmi:type='uml:CallEvent']/@operation))"/>
		</rops>
	</xsl:variable>	
	
	
	<xsl:variable name="oooo">
	
		<xsl:sequence select="$provideifids"/>
	
		<xsl:sequence select="$provideifs"/>	
	
	
		<xsl:sequence select="$requireifids"/>
	
		<xsl:sequence select="$requireifs"/>
			
		<xsl:sequence select="$receivebhav"/>
	
		<xsl:sequence select="$sendbhav"/>
	
		<xsl:sequence select="$behavs/removebhav"/>
		
		<xsl:sequence select="$behavs/chstartbhav"/>
		
		<xsl:sequence select="$behavs/chfinishbhav"/>
	
		<xsl:sequence select="$vvvv/removemocc"/>
	
		<xsl:sequence select="$vvvv/removems"/>
		
		<xsl:sequence select="$vvvv/sendms"/>
		
		<xsl:sequence select="$vvvv/receivems"/>
		
		<xsl:sequence select="$vvvv/sendmocc"/>
		
		<xsl:sequence select="$vvvv/receivemocc"/>		
		
		<xsl:sequence select="$pops"/>
		
		<xsl:sequence select="$rops"/>	
		
		<xsl:sequence  select="$vvvv/proms"/>	
		
		<xsl:sequence  select="$vvvv/reqms"/>
		
	</xsl:variable>
	
	<xsl:sequence select="$oooo"/>	
	
</xsl:function>


<xsl:function name="my:GetLifelineCoveredBy">
	<xsl:param name="lfl"/>
	<xsl:param name="delOcc"/>
	<xsl:param name="delBeha"/>
	<xsl:param name="addOcc"/>
	<xsl:param name="addBeha"/>	
	<xsl:param name="pos"/>
	
	<xsl:variable name="vvv">
		<xsl:analyze-string select="$lfl/@coveredBy" regex="\s+" flags="m">
			<xsl:non-matching-substring>
				<xsl:variable name="cele" select="."/>	
				
				<xsl:if test="not(exists($delOcc[@xmi:id=$cele]) or exists($delBeha[@xmi:id=$cele]))">
					<val><xsl:value-of select="$cele"/></val>
				</xsl:if>
		   </xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:variable>
	
	<xsl:variable name="vvv0">
		<xsl:for-each select="$addBeha">
			<val><xsl:value-of select="./@xmi:id"/></val>
		</xsl:for-each>
		<xsl:for-each select="$addOcc">
			<val><xsl:value-of select="./@xmi:id"/></val>
		</xsl:for-each>
	</xsl:variable>	
	
	<xsl:variable name="vv" select="if (exists($vvv0/child::node())) then insert-before($vvv/child::node(),count($vvv/child::node()),$vvv0/child::node()) else $vvv/child::node()"/>
	
	<xsl:sequence select="$vv"/>
	
</xsl:function>

<xsl:function name="my:GetNewCoveredBy">
	<xsl:param name="lfl"/>
	<xsl:param name="delOcc"/>
	<xsl:param name="delBeha"/>
	<xsl:param name="addOcc"/>
	<xsl:param name="addBeha"/>	
	<xsl:param name="pos"/>
	
	<xsl:variable name="vvv">
		<xsl:analyze-string select="$lfl/@coveredBy" regex="\s+" flags="m">
			<xsl:non-matching-substring>
				<xsl:variable name="cele" select="."/>	
				
				<xsl:if test="not(exists($delOcc[@xmi:id=$cele]) or exists($delBeha[@xmi:id=$cele]))">
					<val><xsl:value-of select="$cele"/></val>
				</xsl:if>
		   </xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:variable>
	
	<xsl:variable name="vvv0">
		<xsl:for-each select="$addBeha">
			<val><xsl:value-of select="concat('NEW_',./@xmi:id)"/></val>
		</xsl:for-each>
		<xsl:for-each select="$addOcc">
			<val><xsl:value-of select="concat('NEW_',./@xmi:id)"/></val>
		</xsl:for-each>
	</xsl:variable>	
	
	<xsl:variable name="vv" select="if (exists($vvv0/child::node())) then insert-before($vvv/child::node(),count($vvv/child::node()),$vvv0/child::node()) else $vvv/child::node()"/>
	
	<xsl:sequence select="$vv"/>
	
</xsl:function>


<xsl:function name="my:GetNewCombineCoveredBy">
	<xsl:param name="clflids"/>
	<xsl:param name="basestr"/>	
	<xsl:param name="lflid"/>
	<xsl:param name="alflid"/>
	<xsl:param name="olfls"/>

	<xsl:variable name="cvlfs" select="my:GetStringAsList($clflids)"/>
	
	<xsl:variable name="vvvv">	
	<xsl:for-each select="$cvlfs">
		<xsl:variable name="lid" select="."/>
		<xsl:variable name="nlid" select="my:GetNewId($lid,7,$basestr)"/>
		<xsl:choose>
			<xsl:when test="$olfls[@xmi:id=$lid]">
				<val><xsl:value-of select="$nlid"/></val>	
			</xsl:when>
			<xsl:when test="$lflid=$nlid">
				<val><xsl:value-of select="concat($lflid,' ',$alflid)"/></val>	
			</xsl:when>			
		</xsl:choose>
	</xsl:for-each>
	</xsl:variable>
	
	<xsl:value-of select="string-join($vvvv/child::node(),' ')"/>
	
</xsl:function>


<xsl:function name="my:GetAllFrags">
	<xsl:param name="lfl"/>
	<xsl:param name="olfls"/>
	<xsl:param name="receivemocc"/>
	<xsl:param name="receivebhav"/>	
	<xsl:param name="sendmocc"/>
	
	<xsl:variable name="vvvvlfl">
	
		<xsl:element name="{$lfl/@name}">
		<xsl:variable name="lflc" select="my:GetStringAsList($lfl/@coveredBy)"/>
		<xsl:for-each select="$lflc">
			<xsl:variable name="cele" select="."/>				
			<xsl:if test="not(exists($sendmocc[@xmi:id=$cele]))">
				<val><xsl:value-of select="$cele"/></val>
			</xsl:if>		
		</xsl:for-each>
	
		<xsl:for-each select="$receivebhav">
			<val><xsl:value-of select="./@xmi:id"/></val>
		</xsl:for-each>
		
		<xsl:for-each select="$receivemocc">
			<val><xsl:value-of select="concat('NEW_',./@xmi:id)"/></val>
			<val><xsl:value-of select="./@xmi:id"/></val>
		</xsl:for-each>	
		</xsl:element>
		
		<xsl:for-each select="$olfls">
			<xsl:element name="{./@name}">
				<xsl:variable name="lflc" select="my:GetStringAsList(./@coveredBy)"/>
				
				<xsl:for-each select="$lflc">
					<xsl:variable name="cele" select="."/>				
					<xsl:if test="not(exists($sendmocc[@xmi:id=$cele]))">
						<xsl:choose>
							<xsl:when test="exists($receivebhav[@xmi:id=$cele])">
								<val><xsl:value-of select="concat('OLD_',$cele)"/></val>
							</xsl:when>
							<xsl:when test="exists($receivemocc[@xmi:id=$cele])">
								<val><xsl:value-of select="concat('OLD_',$cele)"/></val>
							</xsl:when>
							<xsl:otherwise>
								<val><xsl:value-of select="$cele"/></val>
							</xsl:otherwise>							
						</xsl:choose>
					</xsl:if>		
				</xsl:for-each>	
			</xsl:element>
		</xsl:for-each>
	
	</xsl:variable> 		
	
	<xsl:sequence select="$vvvvlfl"/>	
	
</xsl:function>	


<xsl:function name="my:GetObjLifelines">
	<xsl:param name="seq"/>
	<xsl:param name="lfnms"/>
	
	<xsl:for-each select="$lfnms">
		<xsl:variable name="nm" select="."/>	
		<xsl:sequence select="$seq/lifeline[@name=$nm][my:xmiXMIrefs(my:xmiXMIrefs(@represents)/@type)/@xmi:type='uml:Class']"/> 
	</xsl:for-each>

</xsl:function>	


<xsl:function name="my:GetSeqEvent">
		<xsl:param name="popids"/>
		<xsl:message select="concat('GetSeqEvent',' : ',' : ')"/>
		<xsl:variable name="return" select="$xmiXMI//*/packagedElement[@xmi:type='uml:CallEvent'][@operation=$popids]"/>
		<xsl:sequence select="$return"/>
</xsl:function>


-->

<xsl:function name="my:ShowMessage">
	<xsl:param name="str"/>
	<xsl:param name="names"/>
	
	<xsl:message select="concat($str,' : ',string-join($names,' , '))"/>
	
	<xsl:sequence select="''"/>
	
</xsl:function>	

<xsl:function name="my:GetChildNodes">
	<xsl:param name="node"/>
	<xsl:sequence select="$node/child::node()"/>
</xsl:function>	

<xsl:function name="my:GetAllChildWithName">
	<xsl:param name="node"/>
	<xsl:param name="nm"/>
	<xsl:sequence select="$node//*[name()=$nm]"/>
</xsl:function>


<xsl:function name="my:GetNewIdGroup">
	<xsl:param name="in"/>	
	<xsl:param name="pos"/>
	<xsl:param name="sufix"/>
	
	<xsl:variable name="ingrp" select="if (exists($in/@xmi:id)) then $in/@xmi:id else if (count($in)>1) then $in else if (contains($in,' ')) then my:GetStringAsList($in) else $in"/>
	
	<xsl:variable name="vvvv">
	
	<xsl:for-each select="$ingrp">		   
		<xsl:variable name="p1" select="substring(.,1,$pos)"/>
		<xsl:variable name="p2" select="substring(.,$pos+1)"/>		   
		<val>
			<xsl:value-of select="concat($p2,$sufix,$p1)"/>	
		</val>		
	</xsl:for-each>	
	</xsl:variable>
	
	<xsl:sequence select="$vvvv/child::node()"/>

</xsl:function>

<xsl:function name="my:GetNewIdGroup2">
	<xsl:param name="in"/>	
	<xsl:param name="pos"/>
	<xsl:param name="sufix"/>
	<xsl:param name="addstr"/>
	
	<xsl:variable name="ingrp" select="if (exists($in/@xmi:id)) then $in/@xmi:id else if (count($in)>1) then $in else if (contains($in,' ')) then my:GetStringAsList($in) else $in"/>
	
	<xsl:variable name="vvvv">
	
	<xsl:for-each select="$ingrp">		
		<xsl:variable name="ss" select="concat($addstr,.)"/>   
		<xsl:variable name="p1" select="substring($ss,1,$pos)"/>
		<xsl:variable name="p2" select="substring($ss,$pos+1)"/>		   
		<val>
			<xsl:value-of select="concat($p2,$sufix,$p1)"/>	
		</val>		
	</xsl:for-each>	
	</xsl:variable>
	
	<xsl:sequence select="$vvvv/child::node()"/>

</xsl:function>


<xsl:function name="my:GetObjFromIds">
		<xsl:param name="in"/>
		
		<xsl:variable name="ingrp" select="if (count($in)>1) then $in else if (contains($in,' ')) then my:GetStringAsList($in) else $in"/>	
		
		<xsl:sequence select="$xmiXMI//*[@xmi:id=$ingrp]"/>
		
</xsl:function>

<xsl:function name="my:StringJoin">
	<xsl:param name="col"/>
	<xsl:param name="sp"/>

	<xsl:sequence select="string-join($col,$sp)"/>

</xsl:function>

<xsl:function name="my:GetSubPart">
	<xsl:param name="col"/>
	<xsl:param name="sname"/>
	<xsl:param name="pos"/>

	<xsl:sequence select="$col/*[name()=$sname]/*"/>

</xsl:function>

<!-- 
<xsl:function name="my:GetGraphElements">
	<xsl:param name="eleIds"/>	
	
	<xsl:variable name="ids" select="if (exists($eleIds/@xmi:id)) then $eleIds/@xmi:id else $eleIds"/>	
	
	<xsl:variable name="vvvv">
	<xsl:for-each select="$ids">
	
		<xsl:variable name="tid" select="."/>
		
		<xsl:variable name="refid" select="concat($sourceTypedModels[1]/@file,'#',$tid)"/>	
	
		<xsl:sequence select="$digamDIAGRAM//*[semanticModel[@xsi:type='di:EMFSemanticModelBridge']/element[@href=$refid]]"/>

	</xsl:for-each>
	</xsl:variable>
	
	<xsl:sequence select="$vvvv/*"/>
		
</xsl:function>	


<xsl:function name="my:GetModelDiagrams">
	<xsl:param name="modelId"/>
	
	<xsl:variable name="refid" select="concat($sourceTypedModels[1]/@file,'#',$modelId)"/>	
	
	<xsl:sequence select="$digamDIAGRAM//subdiagrams[model[@href=$refid]]"/>	
	

</xsl:function>	


-->


<xsl:function name="my:GetAllSuperAtt">
	<xsl:param name="clsId"/>
	
	<xsl:variable name="clss" select="my:GetAllSuperClass($clsId)"/>	
	<xsl:sequence select="$clss/ownedAttribute"/>
</xsl:function>

<xsl:function name="my:GetAllSubAtt">
	<xsl:param name="clsId"/>	
	<xsl:variable name="clss" select="my:GetAllSubClass($clsId)"/>	
	<xsl:sequence select="$clss/ownedAttribute"/>
</xsl:function>



<xsl:function name="my:GetAllInheritAtt">
	<xsl:param name="clsId"/>	
	
	<xsl:variable name="clss" select="my:GetAllInheritClass($clsId)"/>	
	<xsl:sequence select="$clss/ownedAttribute"/>	

</xsl:function>

<xsl:function name="my:GetAllInheritAttExcept">
	<xsl:param name="clsId"/>	
	<xsl:param name="exId"/>
	
	<xsl:variable name="clss" select="my:GetAllInheritExcept($clsId,$exId)"/>	
	<xsl:sequence select="$clss/ownedAttribute"/>
		
</xsl:function>

<xsl:function name="my:GetAllSuperClass">
	<xsl:param name="clsId"/>	
	
	<xsl:variable name="cls" select="key('xmiId',$clsId,$xmiXMI)"/>
	
	<xsl:sequence select="$cls"/>
	<!--
	<xsl:element name="value">
		<xsl:sequence select="$clsId"/>
	</xsl:element>
	-->
		
	<xsl:for-each select="$cls/generalization">	
		<xsl:sequence select="my:GetAllSuperClass(@general)"/>	
	</xsl:for-each>	
	
</xsl:function>

<xsl:function name="my:GetAllSubClass">
	<xsl:param name="clsId"/>
	
	<xsl:variable name="tttt">
		<xsl:for-each select="$xmiXMI//packagedElement[@xmi:type='uml:Class']/@xmi:id">
			<xsl:variable name="vv">
				<xsl:call-template name="DoGetAllSubClass">
					<xsl:with-param name="cId" select="."/>
					<xsl:with-param name="oId" select="$clsId"/>
					<xsl:with-param name="nList" select="''"/>
				</xsl:call-template>
			</xsl:variable>

			<xsl:if test="exists($vv/child::node())">
				<xsl:sequence select="$vv/child::node()"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
		
	<xsl:sequence select="$xmiXMI//packagedElement[@xmi:id=distinct-values($tttt/child::node())]"/>	
	
</xsl:function>	

<xsl:function name="my:GetAllInheritClass">
	<xsl:param name="clsId"/>	
	<xsl:sequence select="insert-before(my:GetAllSuperClass($clsId),1,my:GetAllSubClass($clsId))"/>	
</xsl:function>

<xsl:function name="my:GetAllInheritExcept">
	<xsl:param name="clsId"/>	
	<xsl:param name="exId"/>
	
	<xsl:variable name="allcls" select="insert-before(my:GetAllSuperClass($clsId),1,my:GetAllSubClass($clsId))"/>	
	
	<xsl:sequence select="$allcls[@xmi:id!=$exId]"/>	
	
</xsl:function>

<xsl:function name="my:DoUnion">
	<xsl:param name="os"/>
	<xsl:param name="ts"/>

	<xsl:variable name="all" select="insert-before($os,1,$ts)"/>
	<xsl:sequence select="distinct-values($all)"/>

</xsl:function>


<xsl:function name="my:DoIntersection">
	<xsl:param name="os"/>
	<xsl:param name="ts"/>

	<xsl:for-each select="$os">
		<xsl:variable name="oo" select="."/>
		<xsl:for-each select="$ts">
			<xsl:if test="deep-equal(.,$oo)">
				<xsl:sequence select="$oo"/>
			</xsl:if>		
		</xsl:for-each>
	</xsl:for-each>

</xsl:function>


<xsl:template name="DoGetAllSubClass">
	<xsl:param name="cId"/>
	<xsl:param name="oId"/>
	<xsl:param name="nList"/>
	
	<xsl:choose>
		<xsl:when test="$cId=$oId">
			<xsl:for-each select="$nList">
				<xsl:if test=".!=''">
					<xsl:element name="value">
						<xsl:value-of select="."/>
					</xsl:element>					
				</xsl:if>			
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="cls" select="key('xmiId',$cId,$xmiXMI)"/>
			<xsl:for-each select="$cls/generalization">	
				<xsl:call-template name="DoGetAllSubClass">
					<xsl:with-param name="cId" select="@general"/>
					<xsl:with-param name="oId" select="$oId"/>
					<xsl:with-param name="nList" select="insert-before($nList,1,$cId)"/>				
				</xsl:call-template>
			</xsl:for-each>
		</xsl:otherwise> 
	</xsl:choose>
</xsl:template>

<xsl:template mode="XMI_EleToLinkCopy" match="*">
		  <xsl:copy copy-namespaces="yes">
			<xsl:copy-of select="@*"/>  
			<xsl:apply-templates mode="DOEleToLinkCopy"/>
		  </xsl:copy>
</xsl:template>	

<xsl:template match="*" mode="DOEleToLinkCopy">
		<xsl:copy>
			<xsl:copy-of select="@*"/> 
			 <xsl:for-each-group select="child::node()[name()='_link_AS_element']" group-by="@name">
				<xsl:variable name="tvalue" select="string-join(current-group()/@value,' ')"/>
				<xsl:attribute name="{current-grouping-key()}" select="$tvalue"/>	
			</xsl:for-each-group>	
			
			<xsl:copy-of select="text()"/> 	
				
			<xsl:apply-templates select="child::node()[name()!='_link_AS_element']" mode="DOEleToLinkCopy"/>
		</xsl:copy>
	  <!--	
	  <xsl:element name="{name()}">
		  <xsl:for-each select="@*">
		  <xsl:if test="not(name()='xmiDiff' or name()='targetId')">
			  <xsl:copy-of select="."/>
		  </xsl:if>
	  </xsl:for-each>
      <xsl:apply-templates select="child::node()" mode="shellCopyNoXmlDiff"/> 
	  </xsl:element>	
      -->
      
</xsl:template>


<xsl:template match="text()" mode="DOEleToLinkCopy">
	<xsl:copy/> 
</xsl:template>
	
	
<xsl:template mode="XMI_Merge" match="/xmi:XMI | /diagrams:Diagrams ">
		  <xsl:param name="xmiDiffList"/>
		  
		  <xsl:copy copy-namespaces="yes">
			<xsl:copy-of select="@*"/>  
			<xsl:apply-templates mode="DOxmiDiffModel">
				<xsl:with-param name="xmiDiffList" select="$xmiDiffList"/>	
			</xsl:apply-templates> 		  
		  </xsl:copy>
</xsl:template>	
	

<xsl:template match="*" mode="DOxmiDiffModel">
	<xsl:param name="xmiDiffList"/>
		
	  <xsl:variable name="xmiid" select="@xmi:id"/>	
	  
	  <xsl:variable name="myList" select="$xmiDiffList[@targetId=$xmiid]"/>
	  
	  <xsl:choose>
		
			<xsl:when test="empty($myList)">	
				 <xsl:element name="{name()}">
					<xsl:copy-of select="@*"/>  
					
					<xsl:copy-of select="text()"/> 
					
				<xsl:apply-templates mode="DOxmiDiffModel">
					<xsl:with-param name="xmiDiffList" select="$xmiDiffList"/>	
				</xsl:apply-templates> 					
					
				 </xsl:element>
			</xsl:when>
			
			<xsl:otherwise>
			
				<xsl:variable name="rlist" select="$myList[@xmiDiff='replace']"/>
				<xsl:variable name="alist" select="$myList[@xmiDiff='insertNext']"/>
				<xsl:variable name="ilist" select="$myList[@xmiDiff='insertTo']"/>
				<xsl:variable name="dlist" select="$myList[@xmiDiff='remove']"/>
				<xsl:variable name="blist" select="$myList[@xmiDiff='insertBefore']"/>
				<xsl:variable name="renamelist" select="$myList[@xmiDiff='resetAtt']"/>
				
				<xsl:for-each select="$blist">
					<!--<xsl:copy-of select="."/>-->
					<xsl:apply-templates select="." mode="shellCopyOuter"/>	
				</xsl:for-each>	
								
				<xsl:if test="empty($dlist)">
				
				<xsl:variable name="curpre">
				  <xsl:choose>
					<xsl:when test="empty($rlist)">
						<xsl:copy-of select="."/>	
					</xsl:when>
					<xsl:otherwise>
						<!--<xsl:copy-of select="$rlist[1]"/>-->
						<xsl:apply-templates select="$rlist[1]" mode="shellCopyOuter"/>						
					</xsl:otherwise>					
				   </xsl:choose>
				</xsl:variable>	
				
				<!-- replace one with one -->				
				<xsl:variable name="cur" select="$curpre/*"/>
				
				<xsl:element name="{$cur/name()}">
				
					  <xsl:choose>
							<xsl:when test="not(empty($renamelist))">							
								<xsl:for-each select="$cur/@*">									
									<xsl:if test="not(index-of($renamelist/@resetAttName,name())>0)">
										<xsl:copy-of select="."/>									
									</xsl:if>
								</xsl:for-each>
								
								<xsl:for-each select="$renamelist">
									<xsl:if test="exists(@resetAttValue)">
											<xsl:attribute name="{@resetAttName}" select="@resetAttValue"/>
									</xsl:if>
								</xsl:for-each>
																
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="$cur/@*"/> 
							</xsl:otherwise>
					   </xsl:choose> 
					  
					  <xsl:copy-of select="$cur/text()"/>
					  
					  <xsl:for-each select="$ilist">
							<!--<xsl:copy-of select="."/>-->
							<xsl:apply-templates select="." mode="shellCopyOuter"/>		
					  </xsl:for-each>
					  
					  <xsl:apply-templates select="$cur/*" mode="DOxmiDiffModel">
							<xsl:with-param name="xmiDiffList" select="$xmiDiffList"/>	
					  </xsl:apply-templates> 					  
				</xsl:element>
				
				</xsl:if>	
										
				<xsl:for-each select="$alist">
					<!--<xsl:copy-of select="."/>-->
					<xsl:apply-templates select="." mode="shellCopyOuter"/>
				</xsl:for-each>	
											
	  	   </xsl:otherwise>
	  	   
	  </xsl:choose>	   
		
</xsl:template>


<xsl:template match="text()" mode="DOxmiDiffModel">
	<xsl:copy/> 
</xsl:template>

<xsl:template match="*" mode="shellCopyOuter">	
  <xsl:element name="{name()}">
	  <xsl:for-each select="@*">
		  <xsl:if test="not(name()='xmiDiff' or name()='targetId')">
			  <xsl:copy-of select="."/>
		  </xsl:if>
	  </xsl:for-each>
	  <xsl:copy-of select="text()"/> 
      <xsl:apply-templates select="child::node()" mode="shellCopyNoXmlDiff"/> 
   </xsl:element>	   
</xsl:template>

<xsl:template match="text()" mode="shellCopyOuter">
	<xsl:copy/> 
</xsl:template>

<xsl:template match="*" mode="shellCopyNoXmlDiff">
		<xsl:if test="not(exists(@xmiDiff))">
			<xsl:copy copy-namespaces="no">
				<xsl:copy-of select="@*"/>  
				<xsl:copy-of select="text()"/> 
				<xsl:apply-templates select="child::node()" mode="shellCopyNoXmlDiff"/>
		    </xsl:copy>	
		</xsl:if>
</xsl:template>

<xsl:template match="text()" mode="shellCopyNoXmlDiff">
	<xsl:copy/> 
</xsl:template>

<xsl:template name="copyAttsNoXmiDiff">	
	  	
	  <xsl:for-each select="@*">
		  <xsl:if test="not(name()='xmiDiff' or name()='targetId')">
			  <xsl:copy-of select="."/>
		  </xsl:if>
	  </xsl:for-each>
</xsl:template>

<xsl:function name="my:GetStringAsList">
	<xsl:param name="exp"/>
		
	<xsl:variable name="vvv">
		<xsl:analyze-string select="$exp" regex=";|,|\s+" flags="m">
			<xsl:non-matching-substring>
				<val><xsl:value-of select="my:strAllTrim(.)"/></val>
		   </xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:variable>
		
	<xsl:sequence select="$vvv/child::node()"/>
		
</xsl:function>	


<xsl:function name="my:strAllTrim">
	<xsl:param name="str2"/>	
	
	<xsl:variable name="str" select="string-join($str2,'')"/>

	<xsl:choose>
		<xsl:when test="$str='' or empty($str)">
			<xsl:value-of select="''"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:analyze-string select="$str" regex="(\s*)((\S(\S|\s)*\S)|(\S))" flags="s">
				<xsl:matching-substring>
					<xsl:value-of select="regex-group(2)"/>
				</xsl:matching-substring>
			</xsl:analyze-string>	
		</xsl:otherwise>
	</xsl:choose>	
	
</xsl:function>


<xsl:function name="my:GetPosX" as="xs:integer">
	<xsl:param name="exp"/>
	<xsl:value-of select="if (exists(my:GetStringAsList($exp)[1])) then my:GetStringAsList($exp)[1] else 0"/>	
</xsl:function>

<xsl:function name="my:GetPosY" as="xs:integer">
	<xsl:param name="exp"/>
	<xsl:value-of select="if (exists(my:GetStringAsList($exp)[2])) then my:GetStringAsList($exp)[2] else 0"/>	
</xsl:function>



<xsl:function name="my:GetNewPosXY">
	<xsl:param name="pos"/>
	<xsl:param name="x" as="xs:integer"/>
	<xsl:param name="y" as="xs:integer"/>
	
	<!--
	<xsl:variable name="oldx" select="my:GetPosX($pos)"/>
	<xsl:variable name="oldy" select="my:GetPosY($pos)"/>
	
	<xsl:variable name="newx" select="$oldx + $x"/>
	
	<xsl:variable name="newy" select="$oldy + $y"/>

	<xsl:message select="concat('NewPos',' : ',concat($newx,',', $newy))"/>
	
	<xsl:value-of select="concat($newx,',', $newy)"/>
	-->
	
	<xsl:value-of select="concat(my:GetPosX($pos)+$x,',', my:GetPosY($pos)+$y)"/>
		
</xsl:function>



<xsl:function name="my:xmiXMIrefs3">
	<xsl:param name="refer2"/>
	
	<xsl:variable name="vvvv">
		<xsl:for-each select="$refer2">
			<xsl:variable name="refer" select="."/>
			<xsl:choose>
				<xsl:when test="contains($refer,' ')">
					<xsl:analyze-string select="$refer" regex="\s+" flags="m">
						<xsl:non-matching-substring>
							<val><xsl:value-of select="."/></val>
					    </xsl:non-matching-substring>
					</xsl:analyze-string>				
				</xsl:when>
				<xsl:otherwise>
					<val><xsl:value-of select="$refer"/></val>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:sequence select="$xmiXMI//*[@xmi:id=$vvvv/child::node()]"/>
	
</xsl:function>

	
</xsl:stylesheet>


