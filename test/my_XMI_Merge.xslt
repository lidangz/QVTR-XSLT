<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:SyntaxTree.SyntaxTree_ClassModel="http://rcos.iist.unu.edu/SyntaxTree.uml" xmlns:CSP="http:///CSP.ecore" xmlns:my="http:///rcos.iist.unu.edu/2008/lidan"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" xmlns:uml="http://www.eclipse.org/uml2/3.0.0/UML" xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" xmlns:rCOS="http://rcos.iist.unu.edu/rCOS.profile.uml" xmlns:di="http://www.topcased.org/DI/1.0" xmlns:diagrams="http://www.topcased.org/Diagrams/1.0">


<xsl:template match="*" mode="DisplayMessage">
      <xsl:param name="mess"/>
      
      <xsl:message select="$mess"/>
      
</xsl:template>

<xsl:function name="my:ShowMessage">
	<xsl:param name="str"/>
	<xsl:param name="names"/>
	
	<xsl:message select="concat($str,' : ',string-join($names,' , '))"/>
	
	<xsl:sequence select="''"/>
	
</xsl:function>	


<xsl:function name="my:MakeMessageStr">
  <xsl:param name="items"/> 
  <xsl:param name="separ"/>
  
  <xsl:choose>
		<xsl:when test="$items instance of xs:anyAtomicType">
			<xsl:value-of select="xs:string($items)"/>
		</xsl:when>
		<xsl:when test="$items[1]/@*[name()=$xmiKeyVar]">
			<xsl:value-of select="string-join($items/@*[name()=$xmiKeyVar],$separ)"/>
		</xsl:when>		
		<xsl:otherwise>
			<xsl:value-of select="string-join($items,$separ)"/>
		</xsl:otherwise>
	</xsl:choose> 
</xsl:function>


<xsl:function name="my:GetChildNodes">
	<xsl:param name="node"/>
	<xsl:sequence select="$node/child::node()"/>
</xsl:function>	

<xsl:function name="my:GetParentNode">
	<xsl:param name="node"/>
	<xsl:sequence select="$node/parent::node()"/>
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


<xsl:function name="my:GetSortedBy" as="item()*">
   <xsl:param name="seq" as="item()*"/>	
   <xsl:param name="svar" as="xs:string"/>
   
	  <xsl:choose>
				<xsl:when test="$svar=''">
				  <xsl:for-each select="$seq">
					<xsl:sort select="."/> 
					<xsl:sequence select="."/>
				  </xsl:for-each>	
				</xsl:when>
				<xsl:otherwise>
				  <xsl:for-each select="$seq">
					<xsl:sort select="@*[name()=$svar]"/> 
					<xsl:sequence select="."/>
				  </xsl:for-each>				
				</xsl:otherwise>
	  </xsl:choose> 

</xsl:function>

<xsl:function name="my:SortedByNumber" as="item()*">
   <xsl:param name="seq" as="item()*"/>	
   <xsl:param name="svar" as="xs:string"/>
   
	  <xsl:choose>
				<xsl:when test="$svar=''">
				  <xsl:for-each select="$seq">
					<xsl:sort select="."/> 
					<xsl:sequence select="."/>
				  </xsl:for-each>	
				</xsl:when>
				<xsl:otherwise>
				  <xsl:for-each select="$seq">
					<xsl:sort select="@*[name()=$svar]" data-type="number"/> 
					<xsl:sequence select="."/>
				  </xsl:for-each>				
				</xsl:otherwise>
	  </xsl:choose> 

</xsl:function>


<xsl:function name="my:DoDistinct" as="item()*">
  <xsl:param name="nodes" as="item()*"/> 
  
  <xsl:choose>
		<xsl:when test="$nodes[1] instance of xs:anyAtomicType">
			<xsl:sequence select="distinct-values($nodes)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="keyvalues" select="distinct-values($nodes/@*[name()=$xmiKeyVar])"/> 
			<xsl:sequence select="for $kk in $keyvalues return $nodes[@*[name()=$xmiKeyVar]=$kk][1]"/>		
		</xsl:otherwise>
	</xsl:choose> 
</xsl:function>

<!--	
 
  <xsl:sequence select=" 
    for $seq in (1 to count($nodes))
    return $nodes[$seq][not(functx:is-node-in-sequence(
                                .,$nodes[position() &lt; $seq]))]
 "/>
   
</xsl:function>


<xsl:function name="functx:is-node-in-sequence" as="xs:boolean" 
              xmlns:functx="http://www.functx.com" >
  <xsl:param name="node" as="node()?"/> 
  <xsl:param name="seq" as="node()*"/> 
 
  <xsl:sequence select=" 
   some $nodeInSeq in $seq satisfies $nodeInSeq is $node
 "/>
   
</xsl:function>

-->

<xsl:function name="my:DoMinus" as="item()*">
  <xsl:param name="nodes1" as="item()*"/> 
  <xsl:param name="nodes2" as="item()*"/>   
  
  <xsl:sequence select="$nodes1[not(@*[name()=$xmiKeyVar]=$nodes2/@*[name()=$xmiKeyVar])]"/>
  
</xsl:function>


<xsl:function name="my:DoValueExcept">
  <xsl:param name="arg1" as="xs:anyAtomicType*"/> 
  <xsl:param name="arg2" as="xs:anyAtomicType*"/> 
 
  <xsl:sequence select="distinct-values($arg1[not(.=$arg2)])"/>

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
				<!-- <xsl:attribute name="{current-grouping-key()}" select="$tvalue"/>	-->
				
				<xsl:if test="not($tvalue='')">
					<xsl:attribute name="{current-grouping-key()}" select="$tvalue"/>
				</xsl:if>
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
	
	
<!-- <xsl:template mode="XMI_Merge" match="/xmi:XMI | /diagrams:Diagrams ">  -->

<xsl:template mode="XMI_Merge" match="*">
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
		
	  <!-- <xsl:variable name="xmiid" select="@xmi:id"/>  -->
	  
	  <!-- <xsl:message select="concat('DiffName',' : ',@name)"/>  -->
	  	
	  <!-- <xsl:variable name="xmiid" select="if (exists(@xmi:id)) then @xmi:id else @name"/>  -->
	  
	  <xsl:variable name="xmiid" select="@*[name()=$xmiKeyVar]"/> 
	  
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
		<xsl:analyze-string select="if (exists($exp)) then $exp else ''" regex=";|,|\s+" flags="m">
			<xsl:non-matching-substring>
				<val><xsl:value-of select="my:strAllTrim(.)"/></val>
		   </xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:variable>
		
	<xsl:sequence select="$vvv/child::node()"/>
		
</xsl:function>	

<xsl:function name="my:IsStringInList">
	<xsl:param name="str"/>
	<xsl:param name="lst"/>
	
	<xsl:variable name="strlst" select="my:GetStringAsList($str)"/>
	
	<xsl:variable name="vvv">
	<xsl:for-each select="$strlst">			
		  <xsl:if test=".=$lst">
			  <xsl:sequence select="."/>
		  </xsl:if>
	</xsl:for-each>	
	</xsl:variable>
	
	<xsl:sequence select="if (exists($vvv/child::node())) then true() else false()"/>
		
</xsl:function>

<xsl:function name="my:strAllTrim" as="xs:string">
  <xsl:param name="arg"/> 
  
  <xsl:variable name="str" select="string-join($arg,'')"/>
  
  <xsl:sequence select="replace(replace($str,'\s+$',''),'^\s+','')"/>
  
</xsl:function>


<xsl:function name="my:strAllTrim-old">
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


<xsl:function name="my:GetNodeAbsPos">
	<xsl:param name="gnode"/>
	<xsl:param name="opos"/>
	
	<xsl:variable name="ox" select="if ($opos='') then 0 else my:GetPosX($opos)"/>
	<xsl:variable name="oy" select="if ($opos='') then 0 else my:GetPosY($opos)"/>	
		
	<xsl:variable name="cpos" select="if ($gnode/@position) then  my:GetNewPosXY($gnode/@position,$ox,$oy) else concat($ox,',',$oy)"/>
	
    <xsl:choose>
		<xsl:when test="$gnode/parent::node()/@xsi:type='di:GraphNode'">
			<xsl:value-of select="my:GetNodeAbsPos($gnode/parent::node(),$cpos)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$cpos"/>
		</xsl:otherwise>
	</xsl:choose>	

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


