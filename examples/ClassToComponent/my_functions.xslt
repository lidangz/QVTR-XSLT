<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore" xmlns:my="http:///rcos.iist.unu.edu/2008/lidan" xmlns:rCOS="http://rcos.iist.unu.edu/rCOS.profile.uml" xmlns:uml="http://www.eclipse.org/uml2/3.0.0/UML" xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

	<!-- <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/> -->
	
	
<xsl:function name="my:GetSuperClsIds">
	<xsl:param name="clsId"/>
	
	<xsl:sequence select="$clsId"/>
	
	<xsl:variable name="cls" select="$xmiXMI//key('xmiId',$clsId)"/>
	
	<xsl:for-each select="$cls/generalization">	
		<xsl:sequence select="my:GetSuperClsIds(@general)"/>	
	</xsl:for-each>	
	
</xsl:function>

<xsl:function name="my:GetSubClsIds">
	<xsl:param name="clsId"/>
	
	<xsl:variable name="tttt">
		<xsl:for-each select="$xmiXMI//packagedElement[@xmi:type='uml:Class']/@xmi:id">
			<xsl:call-template name="DoGetSubClass">
					<xsl:with-param name="cId" select="."/>
					<xsl:with-param name="oId" select="$clsId"/>
					<xsl:with-param name="nList" select="''"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:sequence select="distinct-values($tttt/child::node())"/>	
	
</xsl:function>	

<xsl:template name="DoGetSubClass">
	<xsl:param name="cId"/>
	<xsl:param name="oId"/>
	<xsl:param name="nList"/>
	
	<xsl:choose>
		<xsl:when test="$cId=$oId">
			<xsl:for-each select="$nList">
				<xsl:if test=".!=''">
					<xsl:value-of select="."/>
				</xsl:if>	
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="cls" select="$xmiXMI//key('xmiId',$cId)"/>
			<xsl:for-each select="$cls/generalization">	
				<xsl:call-template name="DoGetSubClass">
					<xsl:with-param name="cId" select="@general"/>
					<xsl:with-param name="oId" select="$oId"/>
					<xsl:with-param name="nList" select="insert-before($nList,1,$cId)"/>				
				</xsl:call-template>
			</xsl:for-each>
		</xsl:otherwise> 
	</xsl:choose>
</xsl:template>

<xsl:function name="my:GetSubClsName">
	<xsl:param name="clsName"/>

	<xsl:variable name="clsId" select="$xmiXMI//packagedElement[@xmi:type='uml:Class' and @name=$clsName][1]/@xmi:id"/>
	<xsl:variable name="lclsids" select="my:GetSubClsIds($clsId)"/>
	
	<xsl:variable name="tttt">
		<xsl:for-each select="$lclsids">
			<xsl:variable name="id" select="."/>
				<xsl:value-of select="$xmiXMI//key('xmiId',$id)/@name"/>
		</xsl:for-each>
	</xsl:variable>	
	
	<xsl:value-of select="concat(' ',string-join($tttt/child::node(),' '),' ')"/>		
	
</xsl:function>


<xsl:function name="my:GetSuperClsName">
	<xsl:param name="clsName"/>

	<xsl:variable name="clsId" select="$xmiXMI//packagedElement[@xmi:type='uml:Class' and @name=$clsName][1]/@xmi:id"/>
	<xsl:variable name="lclsids" select="my:GetSuperClsIds($clsId)"/>
	
	<xsl:variable name="tttt">
		<xsl:for-each select="$lclsids">
			<xsl:variable name="id" select="."/>
				<xsl:value-of select="$xmiXMI//key('xmiId',$id)/@name"/>
		</xsl:for-each>
	</xsl:variable>	
	
	<xsl:value-of select="concat(' ',string-join($tttt/child::node(),' '),' ')"/>		
	
</xsl:function>



<xsl:function name="my:GetSubAttName">
	<xsl:param name="clsName"/>

	<xsl:variable name="clsId" select="$xmiXMI//packagedElement[@xmi:type='uml:Class' and @name=$clsName][1]/@xmi:id"/>
	<xsl:variable name="lclsids" select="my:GetSubClsIds($clsId)"/>
	
	<xsl:variable name="tttt">
		<xsl:for-each select="$lclsids">
			<xsl:variable name="id" select="."/>
			<xsl:value-of select="$xmiXMI//key('xmiId',$id)/ownedAttribute/@name"/>
		</xsl:for-each>
	</xsl:variable>	
	
	<xsl:value-of select="concat(' ',string-join($tttt/child::node(),' '),' ')"/>
	
</xsl:function>

<xsl:function name="my:GetSuperAttName">
	<xsl:param name="clsName"/>

	<xsl:variable name="clsId" select="$xmiXMI//packagedElement[@xmi:type='uml:Class' and @name=$clsName][1]/@xmi:id"/>
	<xsl:variable name="lclsids" select="my:GetSuperClsIds($clsId)"/>
	
	<xsl:variable name="tttt">
		<xsl:for-each select="$lclsids">
			<xsl:variable name="id" select="."/>
			<xsl:value-of select="$xmiXMI//key('xmiId',$id)/ownedAttribute/@name"/>
		</xsl:for-each>
	</xsl:variable>	
	
	<xsl:value-of select="concat(' ',string-join($tttt/child::node(),' '),' ')"/>	
	
</xsl:function>
	
<xsl:function name="my:GetInheriClsIds">
	<xsl:param name="clsId"/>
	
	<xsl:sequence select="insert-before(my:GetSuperClsIds($clsId),1,my:GetSubClsIds($clsId))"/>
	
</xsl:function>


<xsl:function name="my:GetAllClsName">
	<xsl:value-of select="$xmiXMI//packagedElement[@xmi:type='uml:Class']/@name"/>
</xsl:function>

<xsl:function name="my:GetInheriClsName">
	<xsl:param name="clsName"/>

	<xsl:variable name="clsId" select="$xmiXMI//packagedElement[@xmi:type='uml:Class' and @name=$clsName][1]/@xmi:id"/>
	<xsl:variable name="ids" select="my:GetInheriClsIds($clsId)"/>
	
	<xsl:variable name="tttt">
		<xsl:for-each select="$ids">
			<xsl:variable name="id" select="."/>
				<xsl:value-of select="$xmiXMI//key('xmiId',$id)/@name"/>
		</xsl:for-each>
	</xsl:variable>	
	
	<xsl:value-of select="concat(' ',string-join($tttt/child::node(),' '),' ')"/>
	
</xsl:function>


<xsl:function name="my:GetAllInheriClsName">
	<xsl:param name="clsName"/>

	<xsl:variable name="clsId" select="$xmiXMI//packagedElement[@xmi:type='uml:Class' and @name=$clsName][1]/@xmi:id"/>
	<xsl:variable name="ids" select="my:GetInheriClsIds($clsId)"/>
	
	<xsl:variable name="tttt">
		<xsl:for-each select="$ids">
			<xsl:variable name="id" select="."/>
				<xsl:value-of select="$xmiXMI//key('xmiId',$id)/@name"/>
		</xsl:for-each>
	</xsl:variable>	
	
	<xsl:sequence select="$tttt/child::node()"/>	
	
</xsl:function>



<xsl:function name="my:GetInheriAttName">
	<xsl:param name="clsName"/>

	<xsl:variable name="clsId" select="$xmiXMI//packagedElement[@xmi:type='uml:Class' and @name=$clsName][1]/@xmi:id"/>
	<xsl:variable name="ids" select="my:GetInheriClsIds($clsId)"/>
	
	<xsl:variable name="tttt">
		<xsl:for-each select="$ids">
			<xsl:variable name="id" select="."/>
			<xsl:value-of select="$xmiXMI//key('xmiId',$id)/ownedAttribute/@name"/>
		</xsl:for-each>
	</xsl:variable>	
	

	
	<xsl:value-of select="concat(' ',string-join($tttt/child::node(),' '),' ')"/>	
	
</xsl:function>	
	

<xsl:function name="my:GetAllInheriAttName">
	<xsl:param name="clsName"/>

	<xsl:variable name="clsId" select="$xmiXMI//packagedElement[@xmi:type='uml:Class' and @name=$clsName][1]/@xmi:id"/>
	<xsl:variable name="ids" select="my:GetInheriClsIds($clsId)"/>
	
	<xsl:variable name="tttt">
		<xsl:for-each select="$ids">
			<xsl:variable name="id" select="."/>
			<xsl:variable name="ans" select="$xmiXMI//key('xmiId',$id)/ownedAttribute/@name"/>
			<xsl:for-each select="$ans">
				<xsl:value-of select="."/>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:variable>	
	
	<xsl:sequence select="distinct-values($tttt/child::node())"/>
	
</xsl:function>	


<xsl:function name="my:GetInheriAttNameExcept">
	<xsl:param name="clsName"/>
	<xsl:param name="ecName"/>

	<xsl:variable name="clsId" select="$xmiXMI//packagedElement[@xmi:type='uml:Class' and @name=$clsName][1]/@xmi:id"/>
	<xsl:variable name="ecId" select="$xmiXMI//packagedElement[@xmi:type='uml:Class' and @name=$ecName][1]/@xmi:id"/>
	
	<xsl:variable name="ids" select="my:GetInheriClsIds($clsId)"/>
	
	<xsl:variable name="pp" select="index-of($ids,$ecId)"/>
		
	<xsl:variable name="newids" select="if ($pp>0) then remove($ids,$pp) else $ids"/>	
	
	
	<xsl:variable name="tttt">
		<xsl:for-each select="$newids">
			<xsl:variable name="id" select="."/>
			<xsl:value-of select="$xmiXMI//key('xmiId',$id)/ownedAttribute/@name"/>
		</xsl:for-each>
	</xsl:variable>	
	
	<xsl:value-of select="concat(' ',string-join($tttt/child::node(),' '),' ')"/>	
	
</xsl:function>	



<xsl:function name="my:Union">
	<xsl:param name="os"/>
	<xsl:param name="ts"/>

	<xsl:variable name="all" select="insert-before($os,1,$ts)"/>
	<xsl:sequence select="distinct-values($all)"/>

</xsl:function>


<xsl:function name="my:Intersection">
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

</xsl:stylesheet>
