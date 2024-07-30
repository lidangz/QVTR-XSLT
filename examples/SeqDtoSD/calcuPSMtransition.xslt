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
      <xsl:apply-templates mode="calcuPSMtransition" select="."/>
   </xsl:template>
   <xsl:template match="/" mode="calcuPSMtransition">
      <xsl:variable name="diffResult">
         <xsl:apply-templates mode="RootTrans"/>
      </xsl:variable>
      <xsl:variable name="diffResult2">
         <xsl:apply-templates mode="XMI_EleToLinkCopy" select="$diffResult/*"/>
      </xsl:variable>
      <xsl:variable name="diffNumber" select="count($diffResult2//*[@xmiDiff])"/>
      <xsl:choose>
         <xsl:when test="$diffNumber &gt; 0">
            <xsl:message select="concat('_XMI_Diff_Result_Num_: ',$diffNumber)"/>
            <xsl:apply-templates mode="XMI_Merge">
               <xsl:with-param name="xmiDiffList" select="$diffResult2//*[@xmiDiff]"/>
            </xsl:apply-templates>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="."/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="*" mode="AddRule">
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
            <xsl:attribute name="xmi:type" select="'uml:OpaqueExpression'"/>
            <xsl:attribute name="xmi:id" select="$valueid"/>
            <xsl:element name="body">
               <xsl:value-of select="$value"/>
            </xsl:element>
         </xsl:element>
      </xsl:element>
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
               <xsl:apply-templates mode="SMtoPrePost" select="$sm">
                  <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
               </xsl:apply-templates>
               <xsl:apply-templates mode="SMtoInterface" select="$sm">
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
   <xsl:template match="transition[my:xmiXMIrefs(@source)[name()='subvertex' and ownedRule[@name='state' and specification[@xmi:type='uml:LiteralString']]]]"
                 mode="TransToPrePost_bak">
      <xsl:param name="topreg"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="tran" select="current()"/>
      <xsl:variable name="srst" select="my:xmiXMIrefs($tran/@source)[name()='subvertex']"/>
      <xsl:variable name="prestate"
                    select="$srst/ownedRule[@name='state']/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="tgst" select="my:xmiXMIrefs($tran/@target)[name()='subvertex']"/>
      <xsl:variable name="poststate"
                    select="$tgst/ownedRule[@name='state']/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="postprestate"
                    select="$tgst/ownedRule[@name='prestate']/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="pre" select="$tran/ownedRule[@name='pre']"/>
      <xsl:variable name="precondi" select="$pre/specification[@xmi:type='uml:LiteralString']"/>
      <xsl:variable name="sid" select="$precondi/@xmi:id"/>
      <xsl:variable name="prevalue" select="$precondi/@value"/>
      <xsl:variable name="sreg" select="$tran/parent::node()"/>
      <xsl:variable name="andop" select="' and '"/>
      <xsl:variable name="orop" select="' or '"/>
      <xsl:variable name="lft" select="'('"/>
      <xsl:variable name="rgh" select="')'"/>
      <xsl:variable name="quot" select="'&#34;'"/>
      <xsl:variable name="prestval"
                    select=" if (exists($prevalue)) then concat($lft,$prevalue,$rgh,$andop,$lft,$prestate,$rgh) else $prestate "/>
      <xsl:variable name="poststval"
                    select=" if (exists($postprestate)) then $postprestate else $poststate "/>
      <xsl:variable name="allregs" select="my:GetParentRegs($sreg,null)"/>
      <xsl:variable name="stricts"
                    select="(for $rr in $allregs return my:GetConstraint($rr,'strict'))"/>
      <xsl:variable name="strictval" select="string-join($stricts,$andop)"/>
      <xsl:variable name="allsts" select="my:GetParentSts($sreg,null)"/>
      <xsl:variable name="prestates"
                    select="(for $rr in $allsts return my:GetConstraint($rr,'prestate'))"/>
      <xsl:variable name="prestateval" select="string-join($prestates,$andop)"/>
      <xsl:variable name="preval_1"
                    select=" if ($strictval!='') then concat($lft,$prestval,$rgh,$andop,$strictval) else $prestval "/>
      <xsl:variable name="preval_2"
                    select=" if ($prestateval!='') then concat($lft,$preval_1,$rgh,$andop,$prestateval) else $preval_1 "/>
      <xsl:variable name="preval" select="$preval_2"/>
      <xsl:variable name="postval" select="$poststval"/>
      <xsl:if test="not(exists($prevalue)) and $preval!=''">
         <xsl:apply-templates mode="AddConstraint" select="$tran">
            <xsl:with-param name="name" select="'pre'"/>
            <xsl:with-param name="value" select="$preval"/>
            <xsl:with-param name="basestr" select="'_sprcdt'"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="exists($prevalue) and $preval!=''">
         <xsl:apply-templates mode="ReSetConstraint" select="$precondi">
            <xsl:with-param name="value" select="$preval"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="$postval!=''">
         <xsl:apply-templates mode="AddConstraint" select="$tran">
            <xsl:with-param name="name" select="'post'"/>
            <xsl:with-param name="value" select="$postval"/>
            <xsl:with-param name="basestr" select="'_spostrcdt'"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
   </xsl:template>
   <xsl:template match="region" mode="SMtoPrePost">
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="reg" select="current()"/>
      <xsl:variable name="sm" select="$reg/parent::node()"/>
      <xsl:variable name="optrans" select="my:GetOpTrans($reg)"/>
      <xsl:apply-templates mode="TransToPrePost" select="$optrans">
         <xsl:with-param name="topreg" select="$reg"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
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
   <xsl:template match="specification[@xmi:type='uml:LiteralString']" mode="ReSetRule">
      <xsl:param name="value"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="vid" select="current()/@xmi:id"/>
      <xsl:element name="specification">
         <xsl:attribute name="xmi:type" select="'uml:OpaqueExpression'"/>
         <xsl:attribute name="xmiDiff" select="'resetAtt'"/>
         <xsl:attribute name="targetId" select="$vid"/>
         <xsl:attribute name="resetAttName" select="'#body'"/>
         <xsl:attribute name="resetAttValue" select="$value"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="ownedOperation" mode="OpToPrePost">
      <xsl:param name="topreg"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="op" select="current()"/>
      <xsl:variable name="opid" select="$op/@xmi:id"/>
      <xsl:variable name="post" select="$op/ownedRule[@name='post']"/>
      <xsl:variable name="postcondi" select="$post/specification[@xmi:type='uml:LiteralString']"/>
      <xsl:variable name="pre" select="$op/ownedRule[@name='pre']"/>
      <xsl:variable name="precondi" select="$pre/specification[@xmi:type='uml:LiteralString']"/>
      <xsl:variable name="andop" select="' and '"/>
      <xsl:variable name="orop" select="' or '"/>
      <xsl:variable name="lft" select="'('"/>
      <xsl:variable name="rgh" select="')'"/>
      <xsl:variable name="quot" select="'&#34;'"/>
      <xsl:variable name="dash" select="'/'"/>
      <xsl:variable name="ifop" select="' if '"/>
      <xsl:variable name="thenop" select="' then '"/>
      <xsl:variable name="elseop" select="' else '"/>
      <xsl:variable name="trans" select="my:GetTransOfOp($topreg,$op/@xmi:id)"/>
      <xsl:variable name="allpreposts"
                    select="(for $tr in $trans return my:CalculTranPrePost($tr,$topreg))"/>
      <xsl:variable name="allpres_1"
                    select="(for $vv in $allpreposts return concat($lft,$vv/@preval,$rgh))"/>
      <xsl:variable name="allpres" select="string-join($allpres_1,$orop)"/>
      <xsl:variable name="allposts_1"
                    select="(for $vv in $allpreposts return concat($ifop,$vv/@preval,$thenop,$vv/@postval))"/>
      <xsl:variable name="allposts_2" select="string-join($allposts_1,$elseop)"/>
      <xsl:variable name="allposts" select="concat($allposts_2,$elseop,'skip')"/>
      <xsl:if test="not(exists($precondi))">
         <xsl:apply-templates mode="AddRule" select="$op">
            <xsl:with-param name="name" select="'pre'"/>
            <xsl:with-param name="value" select="$allpres"/>
            <xsl:with-param name="basestr" select="'_vfgsp_r'"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="exists($precondi)">
         <xsl:apply-templates mode="ReSetRule" select="$precondi">
            <xsl:with-param name="value" select="$allpres"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="not(exists($postcondi))">
         <xsl:apply-templates mode="AddRule" select="$op">
            <xsl:with-param name="name" select="'post'"/>
            <xsl:with-param name="value" select="$allposts"/>
            <xsl:with-param name="basestr" select="'_vptfg_p'"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="exists($postcondi)">
         <xsl:apply-templates mode="ReSetRule" select="$postcondi">
            <xsl:with-param name="value" select="$allposts"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
   </xsl:template>
   <xsl:template match="transition" mode="TransToPrePost">
      <xsl:param name="topreg"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="tran" select="current()"/>
      <xsl:variable name="pre" select="$tran/ownedRule[@name='pre']"/>
      <xsl:variable name="precondi" select="$pre/specification[@xmi:type='uml:LiteralString']"/>
      <xsl:variable name="sreg" select="$tran/parent::node()"/>
      <xsl:variable name="post" select="$tran/ownedRule[@name='post']"/>
      <xsl:variable name="postcondi" select="$post/specification[@xmi:type='uml:LiteralString']"/>
      <xsl:variable name="trggier" select="$tran/trigger"/>
      <xsl:variable name="ev" select="my:xmiXMIrefs($trggier/@event)[@xmi:type='uml:CallEvent']"/>
      <xsl:variable name="opnm"
                    select="my:xmiXMIrefs($ev/@operation)[name()='ownedOperation']/@name"/>
      <xsl:variable name="andop" select="' and '"/>
      <xsl:variable name="orop" select="' or '"/>
      <xsl:variable name="lft" select="'('"/>
      <xsl:variable name="rgh" select="')'"/>
      <xsl:variable name="quot" select="'&#34;'"/>
      <xsl:variable name="dash" select="'/'"/>
      <xsl:variable name="condi" select="my:CalculTranPrePost($tran,$topreg)"/>
      <xsl:variable name="trannm"
                    select="concat('[',$condi/@preval,']',$opnm,$dash,'[',$condi/@postval,']')"/>
      <xsl:if test="not(exists($precondi))">
         <xsl:apply-templates mode="AddConstraint" select="$tran">
            <xsl:with-param name="name" select="'pre'"/>
            <xsl:with-param name="value" select="$condi/@preval"/>
            <xsl:with-param name="basestr" select="'_sprcdt'"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="exists($precondi)">
         <xsl:apply-templates mode="ReSetConstraint" select="$precondi">
            <xsl:with-param name="value" select="$condi/@preval"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="not(exists($postcondi))">
         <xsl:apply-templates mode="AddConstraint" select="$tran">
            <xsl:with-param name="name" select="'pre'"/>
            <xsl:with-param name="value" select="$condi/@postval"/>
            <xsl:with-param name="basestr" select="'_spostrcdt'"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="exists($postcondi)">
         <xsl:apply-templates mode="ReSetConstraint" select="$postcondi">
            <xsl:with-param name="value" select="$condi/@postval"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:apply-templates mode="SetStName" select="$tran">
         <xsl:with-param name="name" select="$trannm"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
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
   <xsl:template match="*" mode="AddAttribute">
      <xsl:param name="uid"/>
      <xsl:param name="type"/>
      <xsl:param name="vals"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="eid" select="current()/@xmi:id"/>
      <xsl:variable name="pos" select="position()"/>
      <xsl:variable name="name" select="$vals[$pos]"/>
      <xsl:variable name="aid" select="my:GetNewId($eid,3,$name)"/>
      <xsl:variable name="typecomm"
                    select="'pathmap://RCOS_LIBRARIES/RCOSPrimitiveTypes.library.uml#'"/>
      <xsl:variable name="atype" select="concat($typecomm,$type)"/>
      <xsl:element name="ownedAttribute">
         <xsl:attribute name="xmiDiff" select="'insertTo'"/>
         <xsl:attribute name="targetId" select="$uid"/>
         <xsl:attribute name="name" select="$name"/>
         <xsl:attribute name="xmi:id" select="$aid"/>
         <xsl:element name="type">
            <xsl:attribute name="xmi:type" select="'uml:PrimitiveType'"/>
            <xsl:attribute name="href" select="$atype"/>
         </xsl:element>
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
   <xsl:template match="region" mode="SMtoInterface">
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="reg" select="current()"/>
      <xsl:variable name="sm" select="$reg/parent::node()"/>
      <xsl:variable name="eqop" select="'='"/>
      <xsl:variable name="seqop" select="' , '"/>
      <xsl:variable name="quot" select="'&#34;'"/>
      <xsl:variable name="andop" select="' and '"/>
      <xsl:variable name="orop" select="' or '"/>
      <xsl:variable name="tranops" select="my:GetTranOps($reg)"/>
      <xsl:variable name="op1" select="$tranops[1]"/>
      <xsl:variable name="inter" select="my:GetParentNode($op1)"/>
      <xsl:variable name="allregs" select="my:GetAllRegions($sm)"/>
      <xsl:variable name="allstatevar" select="(for $rg in $allregs return my:GetStateVar($rg))"/>
      <xsl:variable name="allstricts"
                    select="(for $rg in $allregs return my:GetConstraint($rg,'critical'))"/>
      <xsl:variable name="allstrictvar"
                    select="(for $rg in $allstricts return substring-before($rg,$eqop))"/>
      <xsl:variable name="strictregs" select="$allregs[ownedRule/@name='critical']"/>
      <xsl:variable name="inivar_1"
                    select="(for $rg in $allstatevar return concat($rg,$eqop,$quot,'Init',$quot))"/>
      <xsl:variable name="inivar_2"
                    select="insert-before($inivar_1, count($inivar_1)+1, $allstricts)"/>
      <xsl:variable name="inivar" select="string-join($inivar_2,$seqop)"/>
      <xsl:variable name="alltrans" select="my:GetAllTrans($reg)"/>
      <xsl:variable name="emptrans"
                    select="$alltrans[not(exists(trigger)) and index-of(ownedRule/@name,'pre') &gt; 0]"/>
      <xsl:variable name="invari_1"
                    select="(for $tr in $emptrans return my:CalculChoiceToFinal($tr,$reg))"/>
      <xsl:variable name="invari" select="string-join($invari_1,$seqop)"/>
      <xsl:apply-templates mode="AddRule" select="$inter">
         <xsl:with-param name="name" select="'Init'"/>
         <xsl:with-param name="value" select="$inivar"/>
         <xsl:with-param name="basestr" select="'_dc4rgt'"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="AddAttribute" select="$allregs">
         <xsl:with-param name="uid" select="$inter/@xmi:id"/>
         <xsl:with-param name="type" select="'String'"/>
         <xsl:with-param name="vals" select="$allstatevar"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="AddAttribute" select="$strictregs">
         <xsl:with-param name="uid" select="$inter/@xmi:id"/>
         <xsl:with-param name="type" select="'Boolean'"/>
         <xsl:with-param name="vals" select="$allstrictvar"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
      <xsl:if test="exists($invari) and $invari!=''">
         <xsl:apply-templates mode="AddRule" select="$inter">
            <xsl:with-param name="name" select="'Invariants'"/>
            <xsl:with-param name="value" select="$invari"/>
            <xsl:with-param name="basestr" select="'_dc9invirnmt'"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:apply-templates mode="OpToPrePost" select="$tranops">
         <xsl:with-param name="topreg" select="$reg"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:function name="my:CalculTargetVert">
      <xsl:param name="reg"/>
      <xsl:param name="stid"/>
      <xsl:variable name="trans" select="$reg//transition"/>
      <xsl:variable name="andop" select="' and '"/>
      <xsl:variable name="orop" select="' or '"/>
      <xsl:variable name="tvex"
                    select="my:xmiXMIrefs($trans[@source=$stid][not(exists(@name)) and not(index-of(ownedRule/@name,'pre')  &gt; 0)]/@target)[name()='subvertex']"/>
      <xsl:variable name="result"
                    select="$tvex[@name='Final' or index-of(ownedRule/specification/@value,'Final') &gt; 0]"/>
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
   <xsl:function name="my:GetConstraint">
      <xsl:param name="st"/>
      <xsl:param name="cname"/>
      <xsl:variable name="cnm" select="$st/ownedRule[@name=$cname]/@name"/>
      <xsl:variable name="result"
                    select="$st/ownedRule[@name=$cname]/specification[@xmi:type='uml:LiteralString'][@xmi:type='uml:LiteralString']/@value"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetTranOps">
      <xsl:param name="reg"/>
      <xsl:variable name="ops"
                    select="my:xmiXMIrefs(my:xmiXMIrefs($reg//transition/trigger/@event)[@xmi:type='uml:CallEvent']/@operation)[name()='ownedOperation']"/>
      <xsl:variable name="result" select="my:DoDistinct($ops)"/>
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
   <xsl:function name="my:GetTransOfOp">
      <xsl:param name="reg"/>
      <xsl:param name="opid"/>
      <xsl:variable name="result"
                    select="$reg//transition[trigger[my:xmiXMIrefs(@event)[@xmi:type='uml:CallEvent' and my:xmiXMIrefs(@operation)[name()='ownedOperation' and @xmi:id=$opid]]]]"/>
      <xsl:variable name="oid"
                    select="my:xmiXMIrefs($result/trigger/@event)[@xmi:type='uml:CallEvent']/@operation"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetAllRegions">
      <xsl:param name="sm"/>
      <xsl:variable name="result" select="$sm//region"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:CalculTranPrePost">
      <xsl:param name="tran"/>
      <xsl:param name="topreg"/>
      <xsl:variable name="tgst" select="my:xmiXMIrefs($tran/@target)[name()='subvertex']"/>
      <xsl:variable name="postprestate"
                    select="$tgst/ownedRule[@name='prestate']/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="poststate"
                    select="$tgst/ownedRule[@name='state']/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="srst" select="my:xmiXMIrefs($tran/@source)[name()='subvertex']"/>
      <xsl:variable name="sreg" select="$srst/parent::node()"/>
      <xsl:variable name="prestate"
                    select="$srst/ownedRule[@name='state']/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="pre" select="$tran/ownedRule[@name='pre']"/>
      <xsl:variable name="precondi" select="$pre/specification[@xmi:type='uml:LiteralString']"/>
      <xsl:variable name="sid" select="$precondi/@xmi:id"/>
      <xsl:variable name="prevalue" select="$precondi/@value"/>
      <xsl:variable name="andop" select="' and '"/>
      <xsl:variable name="orop" select="' or '"/>
      <xsl:variable name="lft" select="'('"/>
      <xsl:variable name="rgh" select="')'"/>
      <xsl:variable name="quot" select="'&#34;'"/>
      <xsl:variable name="prestval"
                    select=" if (exists($prevalue)) then concat($lft,$prevalue,$rgh,$andop,$lft,$prestate,$rgh) else $prestate "/>
      <xsl:variable name="poststval"
                    select=" if (exists($postprestate)) then $postprestate else $poststate "/>
      <xsl:variable name="emptySet" select="$tran[0]"/>
      <xsl:variable name="allregs" select="my:GetParentRegs($sreg,$emptySet)"/>
      <xsl:variable name="stricts"
                    select="(for $rr in $allregs return my:GetConstraint($rr,'critical'))"/>
      <xsl:variable name="strictval" select="string-join($stricts,$andop)"/>
      <xsl:variable name="allsts" select="my:GetParentSts($sreg,$emptySet)"/>
      <xsl:variable name="prestates"
                    select="(for $rr in $allsts return my:GetConstraint($rr,'prestate'))"/>
      <xsl:variable name="prestateval" select="string-join($prestates,$andop)"/>
      <xsl:variable name="prestrict" select="my:GetConstraint($srst,'critical')"/>
      <xsl:variable name="tgtgst" select="my:GetTargetVert($topreg,$tgst/@xmi:id)"/>
      <xsl:variable name="poststrict" select="my:GetConstraint($tgtgst,'critical')"/>
      <xsl:variable name="strictop"
                    select=" if (exists($prestrict) or $poststrict) then concat($prestrict,$poststrict) else '' "/>
      <xsl:variable name="preval_1"
                    select=" if ($strictval!='') then concat($lft,$prestval,$rgh,$andop,$strictval) else $prestval "/>
      <xsl:variable name="preval_2"
                    select=" if ($prestateval!='') then concat($lft,$preval_1,$rgh,$andop,$prestateval) else $preval_1 "/>
      <xsl:variable name="preval" select="xs:string($preval_2)"/>
      <xsl:variable name="postval_1"
                    select=" if ($strictop!='') then concat($poststval,$andop,$strictop) else $poststval "/>
      <xsl:variable name="postval" select="xs:string($postval_1)"/>
      <xsl:variable name="result" as="element()*">
         <xsl:choose>
            <xsl:when test="$preval instance of xs:anyAtomicType">
               <xsl:element name="Tuple">
                  <xsl:attribute name="preval" select="$preval"/>
                  <xsl:attribute name="postval" select="$postval"/>
               </xsl:element>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="$preval"/>
               <xsl:sequence select="$postval"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:CalculChoiceToFinal">
      <xsl:param name="tran"/>
      <xsl:param name="topreg"/>
      <xsl:variable name="tgst" select="my:xmiXMIrefs($tran/@target)[name()='subvertex']"/>
      <xsl:variable name="tgstnm" select="$tgst/@name"/>
      <xsl:variable name="poststate"
                    select="$tgst/ownedRule[@name='state']/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="srst" select="my:xmiXMIrefs($tran/@source)[name()='subvertex']"/>
      <xsl:variable name="sreg" select="$srst/parent::node()"/>
      <xsl:variable name="prestate"
                    select="$srst/ownedRule[@name='state']/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="pre" select="$tran/ownedRule[@name='pre']"/>
      <xsl:variable name="precondi" select="$pre/specification[@xmi:type='uml:LiteralString']"/>
      <xsl:variable name="sid" select="$precondi/@xmi:id"/>
      <xsl:variable name="prevalue" select="$precondi/@value"/>
      <xsl:variable name="andop" select="' and '"/>
      <xsl:variable name="orop" select="' or '"/>
      <xsl:variable name="impliop" select="' implies '"/>
      <xsl:variable name="seqop" select="','"/>
      <xsl:variable name="lft" select="'('"/>
      <xsl:variable name="rgh" select="')'"/>
      <xsl:variable name="quot" select="'&#34;'"/>
      <xsl:variable name="eqop" select="'='"/>
      <xsl:variable name="stvar" select="my:GetStateVar($sreg)"/>
      <xsl:variable name="stinitvar" select="concat($stvar,$eqop,$quot,'Final',$quot)"/>
      <xsl:variable name="istgstFinal"
                    select=" if ($tgstnm='Final' or contains($poststate,$stinitvar)) then 'true' else 'false' "/>
      <xsl:variable name="tregs" select="(for $rg in $tgst return $rg/region)"/>
      <xsl:variable name="isOK"
                    select=" if (exists($prevalue) and exists($prestate) and ( exists($tregs) or $istgstFinal='true' )) then 'true' else 'false' "/>
      <xsl:variable name="tregsvar_1"
                    select=" if (exists($tregs)) then (for $rg in $tregs return concat($rg/@name,$eqop,$quot,'Init',$quot)) else '' "/>
      <xsl:variable name="tregsvar"
                    select=" if (exists($tregs)) then string-join($tregsvar_1,$andop) else '' "/>
      <xsl:variable name="prepart" select="concat($lft,$prevalue,$rgh,$andop,$lft,$prestate,$rgh)"/>
      <xsl:variable name="postpart"
                    select=" if ($istgstFinal='true') then $stinitvar else $tregsvar "/>
      <xsl:variable name="result"
                    select=" if ($isOK='true') then concat($prepart,$impliop,$postpart) else $tran[0] "/>
      <xsl:sequence select="$result"/>
   </xsl:function>
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
   <xsl:function name="my:GetRule">
      <xsl:param name="st"/>
      <xsl:param name="cname"/>
      <xsl:variable name="cnm" select="$st/ownedRule[@name=$cname]/@name"/>
      <xsl:variable name="result"
                    select="$st/ownedRule[@name=$cname]/specification[@xmi:type='uml:OpaqueExpression'][@xmi:type='uml:OpaqueExpression']/body"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetTargetVert">
      <xsl:param name="reg"/>
      <xsl:param name="stid"/>
      <xsl:variable name="trans" select="$reg//transition"/>
      <xsl:variable name="result"
                    select="my:xmiXMIrefs($trans[@source=$stid]/@target)[name()='subvertex']"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetAllVertex">
      <xsl:param name="reg"/>
      <xsl:variable name="result" select="$reg//subvertex"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetOpTrans">
      <xsl:param name="reg"/>
      <xsl:variable name="result" select="$reg//transition[trigger]"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetAllTrans">
      <xsl:param name="reg"/>
      <xsl:variable name="result" select="$reg//transition"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetStateVar">
      <xsl:param name="reg"/>
      <xsl:variable name="regnm" select="$reg/@name"/>
      <xsl:variable name="result"
                    select=" if (contains($regnm,'_StateMachine')) then '_state' else $regnm "/>
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