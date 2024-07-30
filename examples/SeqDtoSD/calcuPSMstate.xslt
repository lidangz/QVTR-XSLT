<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:my="http:///rcos.iist.unu.edu/2008/lidan"
                xmlns:xmi="http://schema.omg.org/spec/XMI/2.1"
                xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore"
                xmlns:rCOS="http://rcos.iist.unu.edu/rCOS.profile.uml"
                xmlns:uml="http://www.eclipse.org/uml2/3.0.0/UML"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:di="http://www.topcased.org/DI/1.0"
                xmlns:diagrams="http://www.topcased.org/Diagrams/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
   <xsl:include href="my_XMI_Merge.xslt"/>
   <xsl:key name="xmiId" match="*" use="@xmi:id"/>
   <xsl:variable name="xmiKeyVar" select="'xmi:id'"/>
   <xsl:variable name="xmiXMI" select="child::node()"/>
   <xsl:variable name="sourceTypedModels" select="''"/>
   <xsl:param name="stateMachineName" as="xs:string" select="''"/>
   <xsl:param name="workOrderName" as="xs:string" select="''"/>
   <xsl:template match="/">
      <xsl:apply-templates mode="calcuPSMstate" select="."/>
   </xsl:template>
   <xsl:template match="/" mode="calcuPSMstate">
      <xsl:apply-templates mode="RootTrans"/>
   </xsl:template>
   <xsl:template match="subvertex[@xmi:type='uml:Pseudostate' and not(ownedRule[@name='state'])]"
                 mode="VertexToVar">
      <xsl:param name="topreg"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="st" select="current()"/>
      <xsl:variable name="stkd" select="$st/@kind"/>
      <xsl:variable name="stid" select="$st/@xmi:id"/>
      <xsl:variable name="andop" select="' and '"/>
      <xsl:variable name="orop" select="' or '"/>
      <xsl:variable name="lft" select="'('"/>
      <xsl:variable name="rgh" select="')'"/>
      <xsl:variable name="srres" select="my:CalculSourceVert($topreg,$stid)"/>
      <xsl:variable name="stval" select="$srres/@stval"/>
      <xsl:variable name="transval" select="$srres/@transval"/>
      <xsl:variable name="allval"
                    select=" if (exists($transval) and $transval!='') then concat($lft,$stval,$rgh,$andop,$lft,$transval,$rgh) else $stval "/>
      <xsl:if test="$srres/@hasStVars='true' and exists($stkd)">
         <xsl:apply-templates mode="SetStName" select="$st">
            <xsl:with-param name="name" select="$allval"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="$srres/@hasStVars='true' and exists($stkd)">
         <xsl:apply-templates mode="AddConstraint" select="$st">
            <xsl:with-param name="name" select="'state'"/>
            <xsl:with-param name="value" select="$allval"/>
            <xsl:with-param name="basestr" select="'_stvcvtt'"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
   </xsl:template>
   <xsl:template match="subvertex[@xmi:type='uml:State' and region and not(ownedRule[@name='prestate']) and ownedRule[@name='state']]"
                 mode="VertexToVar">
      <xsl:param name="topreg"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="st" select="current()"/>
      <xsl:variable name="stnm" select="$st/@name"/>
      <xsl:variable name="stid" select="$st/@xmi:id"/>
      <xsl:variable name="regs" select="$st/region"/>
      <xsl:variable name="regnm" select="$st/parent::node()/@name"/>
      <xsl:variable name="andop" select="' and '"/>
      <xsl:variable name="orop" select="' or '"/>
      <xsl:variable name="lft" select="'('"/>
      <xsl:variable name="rgh" select="')'"/>
      <xsl:variable name="quot" select="'&#34;'"/>
      <xsl:variable name="eqop" select="'='"/>
      <xsl:variable name="dashop" select="'\\'"/>
      <xsl:variable name="dlft" select="'\('"/>
      <xsl:variable name="drgh" select="'\)'"/>
      <xsl:variable name="srres" select="my:CalculSourceVert($topreg,$stid)"/>
      <xsl:variable name="stval" select="$srres/@stval"/>
      <xsl:variable name="transval" select="$srres/@transval"/>
      <xsl:variable name="allval"
                    select=" if (exists($transval) and $transval!='') then concat($lft,$stval,$rgh,$andop,$lft,$transval,$rgh) else $stval "/>
      <xsl:variable name="rgvars1"
                    select="(for $rg in $regs return concat($rg/@name,$eqop,$quot,'Final',$quot))"/>
      <xsl:variable name="rgvars" select="string-join($rgvars1,$andop)"/>
      <xsl:variable name="ff1" select="concat($orop,$dlft,$rgvars,$drgh)"/>
      <xsl:variable name="ff2" select="replace($allval,$ff1,'')"/>
      <xsl:if test="$srres/@hasStVars='true'">
         <xsl:apply-templates mode="SetStName" select="$st">
            <xsl:with-param name="name" select="$ff2"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="$srres/@hasStVars='true'">
         <xsl:apply-templates mode="AddConstraint" select="$st">
            <xsl:with-param name="name" select="'prestate'"/>
            <xsl:with-param name="value" select="$ff2"/>
            <xsl:with-param name="basestr" select="'_stvcvtt'"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
   </xsl:template>
   <xsl:template match="subvertex[@xmi:type='uml:State' and region[transition]]"
                 mode="MoveTransUp">
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="trans" select="current()/region/transition"/>
      <xsl:variable name="reg" select="current()/parent::node()"/>
      <xsl:variable name="rid" select="$reg/@xmi:id"/>
      <xsl:apply-templates mode="DoMoveTranUp" select="$trans">
         <xsl:with-param name="rid" select="$rid"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="subvertex[ownedRule[@name='state']]" mode="JuncToFinal_bak">
      <xsl:param name="topreg"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="st" select="current()"/>
      <xsl:variable name="stid" select="$st/@xmi:id"/>
      <xsl:variable name="stvar" select="$st/ownedRule[@name='state']"/>
      <xsl:variable name="varid" select="$stvar/@xmi:id"/>
      <xsl:variable name="oldval"
                    select="$stvar/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="regnm" select="$st/parent::node()/@name"/>
      <xsl:variable name="andop" select="' and '"/>
      <xsl:variable name="orop" select="' or '"/>
      <xsl:variable name="lft" select="'('"/>
      <xsl:variable name="rgh" select="')'"/>
      <xsl:variable name="quot" select="'&#34;'"/>
      <xsl:variable name="newstvar"
                    select=" if (contains($regnm,'_StateMachine')) then '_state' else $regnm "/>
      <xsl:variable name="vvv" select="concat($newstvar,'=',$quot,'Final',$quot)"/>
      <xsl:variable name="trres"
                    select=" if (contains($oldval,$vvv)) then null else my:CalculTargetVert($topreg,$stid) "/>
      <xsl:variable name="localst" select=" if (exists($trres)) then $vvv else '' "/>
      <xsl:variable name="stkind" select=" if (exists($st/@kind)) then $st/@kind else '' "/>
      <xsl:if test="$localst!='' and $stkind!='choice'">
         <xsl:apply-templates mode="ReSetConstraint" select="$stvar">
            <xsl:with-param name="value" select="$localst"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
   </xsl:template>
   <xsl:template match="//packagedElement[@xmi:type='uml:Package' and packagedElement[@xmi:type='uml:StateMachine']]"
                 mode="RootTrans">
      <xsl:variable name="prot" select="current()"/>
      <xsl:variable name="sms" select="$prot/packagedElement[@xmi:type='uml:StateMachine']"/>
      <xsl:variable name="sm" select="$sms[@name=$stateMachineName]"/>
      <xsl:variable name="_targetDom_Key" select="''"/>
      <xsl:element name="packagedElement">
         <xsl:attribute name="xmi:type" select="'uml:Package'"/>
         <xsl:element name="packagedElement">
            <xsl:attribute name="xmi:type" select="'uml:StateMachine'"/>
            <xsl:element name="region">
               <xsl:apply-templates mode="SMtoSM" select="$sm">
                  <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
               </xsl:apply-templates>
            </xsl:element>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="packagedElement[@xmi:type='uml:Package' and packagedElement[@xmi:type='uml:StateMachine']]"
                 mode="_func_RootTrans">
      <xsl:variable name="prot" select="current()"/>
      <xsl:variable name="sms" select="$prot/packagedElement[@xmi:type='uml:StateMachine']"/>
      <xsl:variable name="sm" select="$sms[@name=$stateMachineName]"/>
      <xsl:element name="packagedElement">
         <xsl:attribute name="xmi:type" select="'uml:Package'"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="transition[my:xmiXMIrefs(@source)[name()='subvertex'] and my:xmiXMIrefs(@target)[name()='subvertex']]"
                 mode="DoMoveTranUp">
      <xsl:param name="rid"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="tran" select="current()"/>
      <xsl:variable name="tnm" select="$tran/@name"/>
      <xsl:variable name="tid" select="$tran/@xmi:id"/>
      <xsl:variable name="trigg" select="$tran/trigger"/>
      <xsl:variable name="sr" select="my:xmiXMIrefs($tran/@source)[name()='subvertex']"/>
      <xsl:variable name="tr" select="my:xmiXMIrefs($tran/@target)[name()='subvertex']"/>
      <xsl:variable name="reg" select="$tran/parent::node()"/>
      <xsl:element name="transition">
         <xsl:attribute name="xmiDiff" select="'insertTo'"/>
         <xsl:attribute name="targetId" select="$rid"/>
         <xsl:attribute name="name" select="$tnm"/>
         <xsl:attribute name="xmi:id" select="$tid"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($sr/@xmi:id,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($tr/@xmi:id,' ')"/>
         </xsl:element>
         <xsl:copy-of copy-namespaces="no" select="$trigg"/>
      </xsl:element>
      <xsl:element name="transition">
         <xsl:attribute name="xmiDiff" select="'remove'"/>
         <xsl:attribute name="targetId" select="$tid"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="specification[@xmi:type='uml:LiteralString']" mode="ReSetConstraint">
      <xsl:param name="value"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="vid" select="current()/@xmi:id"/>
      <xsl:element name="specification">
         <xsl:attribute name="xmi:type" select="'uml:LiteralString'"/>
         <xsl:attribute name="xmiDiff" select="'resetAtt'"/>
         <xsl:attribute name="targetId" select="$vid"/>
         <xsl:attribute name="resetAttName" select="'value'"/>
         <xsl:attribute name="resetAttValue" select="$value"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="subvertex[@xmi:type='uml:State' and region and not(ownedRule[@name='state'])]"
                 mode="VertexToVar">
      <xsl:param name="topreg"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="st" select="current()"/>
      <xsl:variable name="stnm" select="$st/@name"/>
      <xsl:variable name="stid" select="$st/@xmi:id"/>
      <xsl:variable name="regnm" select="$st/parent::node()/@name"/>
      <xsl:variable name="regs" select="$st/region"/>
      <xsl:variable name="andop" select="' and '"/>
      <xsl:variable name="orop" select="' or '"/>
      <xsl:variable name="lft" select="'('"/>
      <xsl:variable name="rgh" select="')'"/>
      <xsl:variable name="quot" select="'&#34;'"/>
      <xsl:variable name="rgstvars"
                    select="(for $rg in $regs return concat($rg/@name,'=',$quot,'Final',$quot))"/>
      <xsl:variable name="rgstval" select="string-join($rgstvars,$andop)"/>
      <xsl:variable name="vvv" select="concat($lft,$rgstval,$rgh)"/>
      <xsl:variable name="rgstvars2"
                    select="(for $rg in $regs return concat($rg/@name,'=',$quot,'Init',$quot))"/>
      <xsl:variable name="rgstval2" select="string-join($rgstvars2,$andop)"/>
      <xsl:variable name="ttt" select="concat($lft,$rgstval2,$rgh)"/>
      <xsl:apply-templates mode="AddConstraint" select="$st">
         <xsl:with-param name="name" select="'state'"/>
         <xsl:with-param name="value" select="$vvv"/>
         <xsl:with-param name="basestr" select="'_comstvcvt'"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="AddConstraint" select="$st">
         <xsl:with-param name="name" select="'init'"/>
         <xsl:with-param name="value" select="$ttt"/>
         <xsl:with-param name="basestr" select="'_coinimsbvt'"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="region" mode="SMtoSM">
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="reg" select="current()"/>
      <xsl:variable name="sm" select="$reg/parent::node()"/>
      <xsl:variable name="sts" select="my:GetAllVertex($reg)"/>
      <xsl:message terminate="yes">
         <xsl:apply-templates mode="VertexToVar" select="$sts">
            <xsl:with-param name="topreg" select="$reg"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
         <xsl:apply-templates mode="MoveTransUp" select="$reg">
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:message>
   </xsl:template>
   <xsl:template match="*" mode="SetStName">
      <xsl:param name="name"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="uid" select="current()/@xmi:id"/>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:Pseudostate'"/>
         <xsl:attribute name="xmiDiff" select="'resetAtt'"/>
         <xsl:attribute name="targetId" select="$uid"/>
         <xsl:attribute name="resetAttName" select="'name'"/>
         <xsl:attribute name="resetAttValue" select="$name"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="subvertex[@xmi:type='uml:State' and not(ownedRule[@name='state']) and not(region)]"
                 mode="VertexToVar">
      <xsl:param name="topreg"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="st" select="current()"/>
      <xsl:variable name="stnm" select="$st/@name"/>
      <xsl:variable name="stid" select="$st/@xmi:id"/>
      <xsl:variable name="regnm" select="$st/parent::node()/@name"/>
      <xsl:variable name="quot" select="'&#34;'"/>
      <xsl:variable name="stvar"
                    select=" if (contains($regnm,'_StateMachine')) then '_state' else $regnm "/>
      <xsl:variable name="localst" select="concat($stvar,'=',$quot,$stnm,$quot)"/>
      <xsl:apply-templates mode="AddConstraint" select="$st">
         <xsl:with-param name="name" select="'state'"/>
         <xsl:with-param name="value" select="$localst"/>
         <xsl:with-param name="basestr" select="'_stvcvtt'"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="subvertex[ownedRule[@name='state']]" mode="VertexToVar" priority="-10">
      <xsl:param name="topreg"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="st" select="current()"/>
      <xsl:variable name="stid" select="$st/@xmi:id"/>
      <xsl:variable name="regnm" select="$st/parent::node()/@name"/>
      <xsl:variable name="stvar" select="$st/ownedRule[@name='state']"/>
      <xsl:variable name="varid" select="$stvar/@xmi:id"/>
      <xsl:variable name="oldval"
                    select="$stvar/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="andop" select="' and '"/>
      <xsl:variable name="orop" select="' or '"/>
      <xsl:variable name="lft" select="'('"/>
      <xsl:variable name="rgh" select="')'"/>
      <xsl:variable name="quot" select="'&#34;'"/>
      <xsl:variable name="newstvar"
                    select=" if (contains($regnm,'_StateMachine')) then '_state' else $regnm "/>
      <xsl:variable name="vvv" select="concat($newstvar,'=',$quot,'Final',$quot)"/>
      <xsl:variable name="trres"
                    select=" if (contains($oldval,$vvv)) then null else my:CalculTargetVert($topreg,$stid) "/>
      <xsl:variable name="localst" select=" if (exists($trres)) then $vvv else '' "/>
      <xsl:variable name="stkind" select=" if (exists($st/@kind)) then $st/@kind else '' "/>
      <xsl:variable name="composilst" select="my:CalculComTarget($topreg,$st)"/>
      <xsl:if test="$localst!='' and $stkind!='choice'">
         <xsl:apply-templates mode="ReSetConstraint" select="$stvar">
            <xsl:with-param name="value" select="$localst"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="$composilst!='' and $stkind!='choice'">
         <xsl:apply-templates mode="ReSetConstraint" select="$stvar">
            <xsl:with-param name="value" select="$composilst"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
   </xsl:template>
   <xsl:template match="*" mode="AddConstraint">
      <xsl:param name="name"/>
      <xsl:param name="value"/>
      <xsl:param name="basestr"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="uid" select="current()/@xmi:id"/>
      <xsl:variable name="consid" select="my:GetNewId($uid,5,$basestr)"/>
      <xsl:variable name="valueid" select="my:GetNewId($uid,7,$basestr)"/>
      <xsl:element name="ownedRule">
         <xsl:attribute name="xmiDiff" select="'insertTo'"/>
         <xsl:attribute name="targetId" select="$uid"/>
         <xsl:attribute name="name" select="$name"/>
         <xsl:attribute name="xmi:id" select="$consid"/>
         <xsl:element name="specification">
            <xsl:attribute name="xmi:type" select="'uml:LiteralString'"/>
            <xsl:attribute name="value" select="$value"/>
            <xsl:attribute name="xmi:id" select="$valueid"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:function name="my:CalculSourceVert">
      <xsl:param name="reg"/>
      <xsl:param name="stid"/>
      <xsl:variable name="trans" select="$reg//transition"/>
      <xsl:variable name="andop" select="' and '"/>
      <xsl:variable name="orop" select="' or '"/>
      <xsl:variable name="srsts"
                    select="my:xmiXMIrefs($trans[@target=$stid]/@source)[name()='subvertex']"/>
      <xsl:variable name="srtrans" select="$trans[@target=$stid]"/>
      <xsl:variable name="hasStVars"
                    select=" if ((every $vt in $srsts satisfies index-of($vt/ownedRule/@name,'state') &gt; 0)) then 'true' else 'false' "/>
      <xsl:variable name="stonly" select="(for $ss in $srsts return $ss/ownedRule) [@name='state']"/>
      <xsl:variable name="srstsval2" select="(for $vt in $stonly return $vt/specification/@value)"/>
      <xsl:variable name="srstsval" select="distinct-values($srstsval2)"/>
      <xsl:variable name="stval" select="string-join($srstsval,$orop)"/>
      <xsl:variable name="srtrvals"
                    select="(for $vt in $srtrans return $vt/ownedRule/specification/@value)"/>
      <xsl:variable name="transval" select="string-join($srtrvals,$orop)"/>
      <xsl:variable name="result" as="element()*">
         <xsl:choose>
            <xsl:when test="$stval instance of xs:anyAtomicType">
               <xsl:element name="Tuple">
                  <xsl:attribute name="stval" select="$stval"/>
                  <xsl:attribute name="transval" select="$transval"/>
                  <xsl:attribute name="hasStVars" select="$hasStVars"/>
               </xsl:element>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="$stval"/>
               <xsl:sequence select="$transval"/>
               <xsl:sequence select="$hasStVars"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetParentSts">
      <xsl:param name="ele"/>
      <xsl:param name="pregs"/>
      <xsl:variable name="rgs"
                    select=" if (substring-after($ele/@xmi:type,'uml:')='State') then insert-before($pregs, count($pregs)+1, $ele) else $pregs "/>
      <xsl:variable name="pele" select="my:GetParentNode($ele)"/>
      <xsl:variable name="result"
                    select=" if (substring-after($pele/@xmi:type,'uml:')='State' or $pele/name()='region') then my:GetParentSts($pele,$rgs) else $rgs "/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:CalculComTarget">
      <xsl:param name="reg"/>
      <xsl:param name="st"/>
      <xsl:variable name="trans" select="$reg//transition"/>
      <xsl:variable name="andop" select="' and '"/>
      <xsl:variable name="orop" select="' or '"/>
      <xsl:variable name="quot" select="'&#34;'"/>
      <xsl:variable name="eqop" select="'='"/>
      <xsl:variable name="lft" select="'('"/>
      <xsl:variable name="rgh" select="')'"/>
      <xsl:variable name="tvex"
                    select="my:xmiXMIrefs($trans[@source=$st/@xmi:id][@name='' and not(index-of(ownedRule/@name,'pre')  &gt; 0)]/@target)[name()='subvertex'][1]"/>
      <xsl:variable name="oldstvar" select="my:GetConstraint($st,'state')"/>
      <xsl:variable name="tregs" select="$tvex/region"/>
      <xsl:variable name="tregsvar_1"
                    select=" if (exists($tregs)) then (for $rg in $tregs return concat($rg/@name,$eqop,$quot,'Init',$quot)) else '' "/>
      <xsl:variable name="tregsvar"
                    select=" if (exists($tregs)) then string-join($tregsvar_1,$andop) else '' "/>
      <xsl:variable name="iscontain"
                    select=" if (contains($oldstvar,$tregsvar)) then 'true' else 'false' "/>
      <xsl:variable name="result"
                    select=" if (exists($tregs) and $iscontain='false') then concat($lft,$oldstvar,$rgh,$andop,$tregsvar) else '' "/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetOpTrans">
      <xsl:param name="reg"/>
      <xsl:variable name="result" select="$reg//transition[trigger]"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetAllVertex">
      <xsl:param name="reg"/>
      <xsl:variable name="result" select="$reg//subvertex"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:CalculTargetVert">
      <xsl:param name="reg"/>
      <xsl:param name="stid"/>
      <xsl:variable name="trans" select="$reg//transition"/>
      <xsl:variable name="andop" select="' and '"/>
      <xsl:variable name="orop" select="' or '"/>
      <xsl:variable name="quot" select="'&#34;'"/>
      <xsl:variable name="tvex"
                    select="my:xmiXMIrefs($trans[@source=$stid][@name='' and not(index-of(ownedRule/@name,'pre')  &gt; 0)]/@target)[name()='subvertex'][1]"/>
      <xsl:variable name="vexparent" select="my:GetParentNode($tvex)"/>
      <xsl:variable name="stvar"
                    select=" if (contains($vexparent/@name,'_StateMachine')) then '_state' else $vexparent/@name "/>
      <xsl:variable name="localst" select="concat($stvar,'=',$quot,'Final',$quot)"/>
      <xsl:variable name="tstate" select="my:GetConstraint($tvex,'state')"/>
      <xsl:variable name="result"
                    select=" if ($tvex/@name='Final' or contains($tstate,$localst)) then $tvex else $tvex[0] "/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetSourceVert">
      <xsl:param name="reg"/>
      <xsl:param name="stid"/>
      <xsl:variable name="trans" select="$reg//transition"/>
      <xsl:variable name="result"
                    select="my:xmiXMIrefs($trans[@target=$stid]/@source)[name()='subvertex']"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetConstraint">
      <xsl:param name="st"/>
      <xsl:param name="cname"/>
      <xsl:variable name="cnm" select="$st/ownedRule[@name=$cname]/@name"/>
      <xsl:variable name="result"
                    select="$st/ownedRule[@name=$cname]/specification[@xmi:type='uml:LiteralString'][@xmi:type='uml:LiteralString']/@value"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetParentRegs">
      <xsl:param name="ele"/>
      <xsl:param name="pregs"/>
      <xsl:variable name="uid" select="$ele/@xmi:id"/>
      <xsl:variable name="rgs"
                    select=" if ($ele/name()='region') then insert-before($pregs, count($pregs)+1, $ele) else $pregs "/>
      <xsl:variable name="pele" select="my:GetParentNode($ele)"/>
      <xsl:variable name="result"
                    select=" if (substring-after($pele/@xmi:type,'uml:')='State' or $pele/name()='region') then my:GetParentRegs($pele,$rgs) else $rgs "/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetNewId">
      <xsl:param name="in"/>
      <xsl:param name="pos"/>
      <xsl:param name="sufix"/>
      <xsl:variable name="pos1" select="$pos + 1"/>
      <xsl:variable name="p1" select="substring($in,1,$pos)"/>
      <xsl:variable name="p2" select="substring($in,$pos1)"/>
      <xsl:variable name="result" select="concat($p2,$sufix,$p1)"/>
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
      <xsl:sequence select="$xmiXMI//*[@xmi:id=$vvvv/child::node()]"/>
   </xsl:function>
</xsl:stylesheet>