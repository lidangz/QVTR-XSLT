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
   <xsl:variable name="transParameter_file" select="doc('seqDtransSD-para.xml')/*"/>
   <xsl:variable name="transSeqDName" select="$transParameter_file/transSeqDName"/>
   <xsl:variable name="cmbUsedAsRef" select="$transParameter_file/cmbUsedAsRef"/>
   <xsl:variable name="transLifelinName" select="$transParameter_file/transLifelinName"/>
   <xsl:variable name="sourceTypedModels" select="$transParameter_file/sourceTypedModel"/>
   <xsl:variable name="digamDIAGRAM"
                 select="document(concat('bak-',$sourceTypedModels[@name='digamDIAGRAM']/@file),.)"/>
   <xsl:template match="/">
      <xsl:apply-templates mode="seqDtransSD" select="."/>
   </xsl:template>
   <xsl:template match="/" mode="seqDtransSD">
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
            <xsl:result-document href="{$sourceTypedModels[@name='digamDIAGRAM']/@file}">
               <xsl:apply-templates mode="XMI_Merge" select="$digamDIAGRAM">
                  <xsl:with-param name="xmiDiffList" select="$diffResult2//*[@xmiDiff]"/>
               </xsl:apply-templates>
            </xsl:result-document>
            <xsl:apply-templates mode="XMI_Merge">
               <xsl:with-param name="xmiDiffList" select="$diffResult2//*[@xmiDiff]"/>
            </xsl:apply-templates>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="."/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="subdiagrams" mode="SDDiagram">
      <xsl:param name="seq"/>
      <xsl:param name="lfl"/>
      <xsl:param name="tids"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="sdgid" select="current()/@xmi:id"/>
      <xsl:variable name="dig" select="current()/diagrams"/>
      <xsl:variable name="dgpos" select="$dig/@position"/>
      <xsl:variable name="dgsize" select="$dig/@size"/>
      <xsl:variable name="dgid" select="$dig/@xmi:id"/>
      <xsl:variable name="dgvi" select="$dig/@viewport"/>
      <xsl:variable name="xid" select="substring-after(current()/model/@href,'#')"/>
      <xsl:variable name="diagramWidth" select="1680"/>
      <xsl:variable name="diagramHeight" select="2376"/>
      <xsl:variable name="pageFormatName" select="'A2'"/>
      <xsl:variable name="midx" select="$diagramWidth  div  2 + 0"/>
      <xsl:variable name="diagramMiddle" select="xs:integer($midx)"/>
      <xsl:variable name="basestr" select="'_SDG_'"/>
      <xsl:variable name="statenm" select="concat($lfl/@name,'_StateMachine')"/>
      <xsl:variable name="tsdgid" select="my:GetNewId($sdgid,7,$basestr)"/>
      <xsl:variable name="comma" select="','"/>
      <xsl:variable name="stdgids" select="my:GetDgIds($tids/@stateid)"/>
      <xsl:element name="subdiagrams">
         <xsl:attribute name="xmiDiff" select="'insertNext'"/>
         <xsl:attribute name="targetId" select="$sdgid"/>
         <xsl:attribute name="xmi:id" select="$tsdgid"/>
         <xsl:element name="model">
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'href'"/>
               <xsl:attribute name="value"
                              select="string-join(concat($sourceTypedModels[@name='xmiXMI']/@file,'#',$tids/@stateid),' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:element name="diagrams">
            <xsl:if test="exists($dgsize)">
               <xsl:attribute name="size" select="$dgsize"/>
            </xsl:if>
            <xsl:if test="exists($dgpos)">
               <xsl:attribute name="position" select="$dgpos"/>
            </xsl:if>
            <xsl:attribute name="viewport" select="$dgvi"/>
            <xsl:attribute name="name" select="$statenm"/>
            <xsl:attribute name="xmi:id" select="$stdgids/@dgid"/>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'pageFormatName'"/>
               <xsl:with-param name="kvalue" select="$pageFormatName"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'diagramWidth'"/>
               <xsl:with-param name="kvalue" select="$diagramWidth"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'diagramHeight'"/>
               <xsl:with-param name="kvalue" select="$diagramHeight"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'pageMarginName'"/>
               <xsl:with-param name="kvalue" select="'Small Margin'"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'diagramTopMargin'"/>
               <xsl:with-param name="kvalue" select="'20'"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'diagramBottomMargin'"/>
               <xsl:with-param name="kvalue" select="'20'"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'diagramLeftMargin'"/>
               <xsl:with-param name="kvalue" select="'20'"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'diagramRightMargin'"/>
               <xsl:with-param name="kvalue" select="'20'"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'orientation'"/>
               <xsl:with-param name="kvalue" select="'landscape'"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="CopyGSemantic" select="$dig">
               <xsl:with-param name="dgids" select="$stdgids"/>
               <xsl:with-param name="pres" select="'edu.unu.iist.rcos.modeler.statemachinediagram'"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="InteractionToDig" select="$seq">
               <xsl:with-param name="lflid" select="$lfl/@xmi:id"/>
               <xsl:with-param name="preP" select="$tids/@firstSid"/>
               <xsl:with-param name="nextP" select="$tids/@lastSid"/>
               <xsl:with-param name="tids" select="$tids"/>
               <xsl:with-param name="diagramMiddle" select="$diagramMiddle"/>
               <xsl:with-param name="upperS" select="''"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*" mode="DelElement">
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="uid" select="current()/@xmi:id"/>
      <xsl:element name="packagedElement">
         <xsl:attribute name="xmi:type" select="'uml:Package'"/>
         <xsl:attribute name="xmiDiff" select="'remove'"/>
         <xsl:attribute name="targetId" select="$uid"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:MessageOccurrenceSpecification' and my:xmiXMIrefs(@message)[name()='message']]"
                 mode="FragmentToState">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="condi"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="ev" select="my:xmiXMIrefs($fr/@event)[@xmi:type='uml:CallEvent']"/>
      <xsl:variable name="evid" select="$ev/@xmi:id"/>
      <xsl:variable name="opid" select="$ev/@operation"/>
      <xsl:variable name="opnm"
                    select="my:xmiXMIrefs($ev/@operation)[name()='ownedOperation']/@name"/>
      <xsl:variable name="ms" select="my:xmiXMIrefs($fr/@message)[name()='message']"/>
      <xsl:variable name="msnm" select="$ms/@name"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes" select="my:CalcuPos($preP,$nextP,$frids,$upperS,$cpos)"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="pos" select="$cpos + 1"/>
      <xsl:variable name="stnm" select="concat('S',$upperS,'_',$cpos)"/>
      <xsl:variable name="allcondi" select="my:GetTranCondi($frids,$cpos,$condi)"/>
      <xsl:variable name="transnm"
                    select=" if ($allcondi!='') then concat('[',$allcondi,']',$opnm) else $opnm "/>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:State'"/>
         <xsl:attribute name="name" select="$stnm"/>
         <xsl:attribute name="xmi:id" select="$stids/@stid"/>
      </xsl:element>
      <xsl:element name="transition">
         <xsl:attribute name="name" select="$transnm"/>
         <xsl:attribute name="xmi:id" select="$stids/@transid"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@stid,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($posRes/@newPreP,' ')"/>
         </xsl:element>
         <xsl:element name="trigger">
            <xsl:attribute name="xmi:id" select="$stids/@triid"/>
            <xsl:attribute name="name" select="concat($opnm,'_trigger')"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'event'"/>
               <xsl:attribute name="value" select="string-join($ev/@xmi:id,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:if test="$allcondi!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$allcondi"/>
               <xsl:with-param name="basestr" select="'_transpre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@transid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='break']"
                 mode="FragmentToState">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="condi"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="op1" select="$fr/operand"/>
      <xsl:variable name="exp"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes" select="my:CalcuPos($preP,$nextP,$frids,$upperS,$cpos)"/>
      <xsl:variable name="stnm" select="''"/>
      <xsl:variable name="prestnm" select="''"/>
      <xsl:variable name="prestnm" select="'NOChoice'"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="finalstids" select="my:GetIdsFromSt($tids/@lastSid)"/>
      <xsl:variable name="op1frag" select="my:CalcuFrag($lflid,$op1)"/>
      <xsl:variable name="inLastStIds" select="my:GetStIds($op1frag/@inLastItemId)"/>
      <xsl:variable name="allcondi" select="my:GetTranCondi($frids,$cpos,$condi)"/>
      <xsl:variable name="prnTrannm"
                    select=" if ($allcondi!='') then concat('[',$allcondi,']') else '' "/>
      <xsl:variable name="inlastcondi" select="my:GetPreFragCondi($op1frag/@inLastItemId)"/>
      <xsl:variable name="inLastTrannm"
                    select=" if ($inlastcondi!='') then concat('[',$inlastcondi,']') else '' "/>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$finalstids/@ltransid"/>
         <xsl:attribute name="name" select="$inLastTrannm"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($inLastStIds/@stid,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($finalstids/@stid,' ')"/>
         </xsl:element>
         <xsl:if test="$inlastcondi!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$inlastcondi"/>
               <xsl:with-param name="basestr" select="'_inlastpre'"/>
               <xsl:with-param name="_targetDom_Key" select="$finalstids/@ltransid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@transid"/>
         <xsl:attribute name="name" select="$prnTrannm"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@stid,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($posRes/@newPreP,' ')"/>
         </xsl:element>
         <xsl:if test="$allcondi!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$allcondi"/>
               <xsl:with-param name="basestr" select="'_transpre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@transid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:Pseudostate'"/>
         <xsl:attribute name="xmi:id" select="$stids/@stid"/>
         <xsl:if test="exists('choice')">
            <xsl:attribute name="kind" select="'choice'"/>
         </xsl:if>
         <xsl:attribute name="name" select="$stnm"/>
      </xsl:element>
      <xsl:apply-templates mode="OperandToVertex" select="$op1">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$stids/@stid"/>
         <xsl:with-param name="nextP" select="$finalstids/@stid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS"/>
         <xsl:with-param name="condi" select="$exp"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="property[not(@key='eStructuralFeatureID')]" mode="CopyGProperty">
      <xsl:param name="basestr"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="pid" select="current()/@xmi:id"/>
      <xsl:variable name="pkey" select="current()/@key"/>
      <xsl:variable name="kvalue" select="current()/@value"/>
      <xsl:variable name="tpid" select="my:GetNewId($pid,7,$basestr)"/>
      <xsl:element name="property">
         <xsl:attribute name="xmi:id" select="$tpid"/>
         <xsl:attribute name="key" select="$pkey"/>
         <xsl:attribute name="value" select="$kvalue"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="ownedBehavior[@xmi:type='uml:Interaction']"
                 mode="InteractionToVertex_bak">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="tids"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="iop" select="current()"/>
      <xsl:variable name="cmb" select="'CombinedFragment'"/>
      <xsl:variable name="frs" select="my:GetRecFrag($iop,$lflid)"/>
      <xsl:variable name="frids" select="$frs/@xmi:id"/>
      <xsl:apply-templates mode="FragmentToState" select="$frs">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$preP"/>
         <xsl:with-param name="nextP" select="$nextP"/>
         <xsl:with-param name="frids" select="$frids"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="''"/>
         <xsl:with-param name="condi" select="''"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='par']"
                 mode="FragmentToDig">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="preNum"/>
      <xsl:param name="posX"/>
      <xsl:param name="baseY"/>
      <xsl:param name="nexttranP"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="op1" select="$fr/operand[1]"/>
      <xsl:variable name="op1id" select="$op1/@xmi:id"/>
      <xsl:variable name="exp"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="op2" select="$fr/operand[2]"/>
      <xsl:variable name="op2id" select="$op2/@xmi:id"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes"
                    select="my:CalcuPosDig($preP,$nextP,$frids,$upperS,$cpos,$nexttranP)"/>
      <xsl:variable name="comma" select="','"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="laststids" select="my:GetIdsFromSt($posRes/@newNextP)"/>
      <xsl:variable name="reg1nm" select="concat($posRes/@newUpperS,'_1')"/>
      <xsl:variable name="reg2nm" select="concat($posRes/@newUpperS,'_2')"/>
      <xsl:variable name="op1frag" select="my:CalcuFrag($lflid,$op1)"/>
      <xsl:variable name="op2frag" select="my:CalcuFrag($lflid,$op2)"/>
      <xsl:variable name="op12all" select="my:CalcuTotalFrag($op1frag,$op2frag)"/>
      <xsl:variable name="xyRes" select="my:CalcuXY($op12all,$cpos,$preNum,$posX,$baseY,$mid)"/>
      <xsl:variable name="xyRes2" select="my:CalcuXY($op12all,$cpos,$preNum,$posX,$baseY,$mid)"/>
      <xsl:variable name="tstids" select="my:GetDgIds($stids/@stid)"/>
      <xsl:variable name="transids" select="my:GetDgIds($stids/@transid)"/>
      <xsl:variable name="sstids" select="my:GetDgIds($posRes/@newPreP)"/>
      <xsl:variable name="nstids" select="my:GetDgIds($posRes/@newNextP)"/>
      <xsl:variable name="nexttranids" select="my:GetDgIds($posRes/@nexttid)"/>
      <xsl:variable name="basestr1" select="'_SD_p1_'"/>
      <xsl:variable name="basestr2" select="'_SD_p2_'"/>
      <xsl:variable name="tids1" select="my:GetTids($op1id,$lflid,$basestr1)"/>
      <xsl:variable name="tids2" select="my:GetTids($op2id,$lflid,$basestr2)"/>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$transids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$transids"/>
            <xsl:with-param name="fromids" select="$sstids"/>
            <xsl:with-param name="toids" select="$tstids"/>
            <xsl:with-param name="_targetDom_Key" select="$transids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:if test="exists($xyRes/@comstsize)">
            <xsl:attribute name="size" select="$xyRes/@comstsize"/>
         </xsl:if>
         <xsl:attribute name="xmi:id" select="$tstids/@dgid"/>
         <xsl:if test="exists($xyRes/@comstpos)">
            <xsl:attribute name="position" select="$xyRes/@comstpos"/>
         </xsl:if>
         <xsl:element name="anchorage">
            <xsl:attribute name="xmi:id" select="$tstids/@anchid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($transids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($nexttranids/@dgid,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$fr">
            <xsl:with-param name="dgids" select="$tstids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$tstids/@dgid"/>
         </xsl:apply-templates>
         <xsl:apply-templates mode="SetGProperty" select="$fr">
            <xsl:with-param name="pkey" select="'RegionLayoutOrientation'"/>
            <xsl:with-param name="kvalue" select="'false'"/>
            <xsl:with-param name="_targetDom_Key" select="$tstids/@dgid"/>
         </xsl:apply-templates>
         <xsl:apply-templates mode="InteractionToDig" select="$op1">
            <xsl:with-param name="lflid" select="$lflid"/>
            <xsl:with-param name="preP" select="$tids1/@firstSid"/>
            <xsl:with-param name="nextP" select="$tids1/@lastSid"/>
            <xsl:with-param name="tids" select="$tids1"/>
            <xsl:with-param name="diagramMiddle" select="150"/>
            <xsl:with-param name="upperS" select="$reg1nm"/>
            <xsl:with-param name="_targetDom_Key" select="$tstids/@dgid"/>
         </xsl:apply-templates>
         <xsl:apply-templates mode="InteractionToDig" select="$op2">
            <xsl:with-param name="lflid" select="$lflid"/>
            <xsl:with-param name="preP" select="$tids2/@firstSid"/>
            <xsl:with-param name="nextP" select="$tids2/@lastSid"/>
            <xsl:with-param name="tids" select="$tids2"/>
            <xsl:with-param name="diagramMiddle" select="150"/>
            <xsl:with-param name="upperS" select="$reg2nm"/>
            <xsl:with-param name="_targetDom_Key" select="$tstids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
   </xsl:template>
   <xsl:template match="ownedBehavior[@xmi:type='uml:Interaction']" mode="InteractionToDig_bak">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="tids"/>
      <xsl:param name="diagramMiddle"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="iop" select="current()"/>
      <xsl:variable name="cmb" select="'CombinedFragment'"/>
      <xsl:variable name="allfrs1" select="my:GetAllRecFrag($iop,$lflid)"/>
      <xsl:variable name="allfrs"
                    select="(for $fr in $allfrs1 return my:DoFileterFrag($fr,$lflid))"/>
      <xsl:variable name="frs" select="my:GetRecFrag($iop,$lflid)"/>
      <xsl:variable name="frids" select="$frs/@xmi:id"/>
      <xsl:variable name="lastid" select="$frids[last()]"/>
      <xsl:variable name="count" select="count($allfrs) + 2"/>
      <xsl:variable name="preNum" select="$allfrs/@xmi:id"/>
      <xsl:variable name="finalstids" select="my:GetIdsFromSt($nextP)"/>
      <xsl:apply-templates mode="FragmentToDig" select="$frs">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$preP"/>
         <xsl:with-param name="nextP" select="$nextP"/>
         <xsl:with-param name="frids" select="$frids"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="''"/>
         <xsl:with-param name="preNum" select="$preNum"/>
         <xsl:with-param name="posX" select="$diagramMiddle"/>
         <xsl:with-param name="baseY" select="20"/>
         <xsl:with-param name="nexttranP" select="$finalstids/@transid"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="CreateFinalTransDig" select="$iop">
         <xsl:with-param name="finalstid" select="$nextP "/>
         <xsl:with-param name="preid" select="$lastid"/>
         <xsl:with-param name="preNum" select="$count"/>
         <xsl:with-param name="posX" select="$diagramMiddle"/>
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='alt']"
                 mode="FragmentToState">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="condi"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="op1" select="$fr/operand[1]"/>
      <xsl:variable name="exp"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="op2" select="$fr/operand[2]"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes" select="my:CalcuPos($preP,$nextP,$frids,$upperS,$cpos)"/>
      <xsl:variable name="prestnm" select="'Choice'"/>
      <xsl:variable name="stnm" select="''"/>
      <xsl:variable name="prestnm" select="''"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="op1frag" select="my:CalcuFrag($lflid,$op1)"/>
      <xsl:variable name="inLastStIds" select="my:GetStIds($op1frag/@inLastItemId)"/>
      <xsl:variable name="op2frag" select="my:CalcuFrag($lflid,$op2)"/>
      <xsl:variable name="inLastStIds2" select="my:GetStIds($op2frag/@inLastItemId)"/>
      <xsl:variable name="allcondi" select="my:GetTranCondi($frids,$cpos,$condi)"/>
      <xsl:variable name="prnTrannm"
                    select=" if ($allcondi!='') then concat('[',$allcondi,']') else '' "/>
      <xsl:variable name="inlastcondi" select="my:GetPreFragCondi($op1frag/@inLastItemId)"/>
      <xsl:variable name="inLastTrannm"
                    select=" if ($inlastcondi!='') then concat('[',$inlastcondi,']') else '' "/>
      <xsl:variable name="inlastcondi2" select="my:GetPreFragCondi($op2frag/@inLastItemId)"/>
      <xsl:variable name="inLastTrannm2"
                    select=" if ($inlastcondi2!='') then concat('[',$inlastcondi2,']') else '' "/>
      <xsl:variable name="notexp"
                    select=" if (exists($exp) and $exp!='') then concat('not(',$exp,')') else '' "/>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@ltransid"/>
         <xsl:attribute name="name" select="$inLastTrannm2"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($inLastStIds2/@stid,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@stid,' ')"/>
         </xsl:element>
         <xsl:if test="$inlastcondi2!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$inlastcondi2"/>
               <xsl:with-param name="basestr" select="'_inlast2pre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@ltransid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@lpretransid"/>
         <xsl:attribute name="name" select="$prnTrannm"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($posRes/@newPreP,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@prestid,' ')"/>
         </xsl:element>
         <xsl:if test="$allcondi!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$allcondi"/>
               <xsl:with-param name="basestr" select="'_transpre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@lpretransid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:Pseudostate'"/>
         <xsl:attribute name="xmi:id" select="$stids/@prestid"/>
         <xsl:if test="exists('choice')">
            <xsl:attribute name="kind" select="'choice'"/>
         </xsl:if>
         <xsl:attribute name="name" select="$prestnm"/>
      </xsl:element>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@transid"/>
         <xsl:attribute name="name" select="$inLastTrannm"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($inLastStIds/@stid,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@stid,' ')"/>
         </xsl:element>
         <xsl:if test="$inlastcondi!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$inlastcondi"/>
               <xsl:with-param name="basestr" select="'_inlastpre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@transid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:Pseudostate'"/>
         <xsl:attribute name="xmi:id" select="$stids/@stid"/>
         <xsl:if test="exists('junction')">
            <xsl:attribute name="kind" select="'junction'"/>
         </xsl:if>
         <xsl:attribute name="name" select="$stnm"/>
      </xsl:element>
      <xsl:apply-templates mode="OperandToVertex" select="$op1">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$stids/@prestid"/>
         <xsl:with-param name="nextP" select="$stids/@stid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS"/>
         <xsl:with-param name="condi" select="$exp"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="OperandToVertex" select="$op2">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$stids/@prestid"/>
         <xsl:with-param name="nextP" select="$stids/@stid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS2"/>
         <xsl:with-param name="condi" select="$notexp"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="*" mode="CreateTransition">
      <xsl:param name="tranid"/>
      <xsl:param name="sstid"/>
      <xsl:param name="tstid"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$tranid"/>
         <xsl:attribute name="name" select="''"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($tstid,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($sstid,' ')"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*" mode="SetGProperty">
      <xsl:param name="pkey"/>
      <xsl:param name="kvalue"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="pid" select="current()/@xmi:id"/>
      <xsl:variable name="tpid" select="my:GetNewId($pid,9,$pkey)"/>
      <xsl:element name="property">
         <xsl:attribute name="xmi:id" select="$tpid"/>
         <xsl:attribute name="key" select="$pkey"/>
         <xsl:attribute name="value" select="$kvalue"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="subdiagrams" mode="SDDiagram_bak">
      <xsl:param name="seq"/>
      <xsl:param name="lfl"/>
      <xsl:param name="tids"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="sdgid" select="current()/@xmi:id"/>
      <xsl:variable name="xid" select="substring-after(current()/model/@href,'#')"/>
      <xsl:variable name="dig" select="current()/diagrams"/>
      <xsl:variable name="dgpos" select="$dig/@position"/>
      <xsl:variable name="dgsize" select="$dig/@size"/>
      <xsl:variable name="dgid" select="$dig/@xmi:id"/>
      <xsl:variable name="dgvi" select="$dig/@viewport"/>
      <xsl:variable name="diagramWidth" select="1680"/>
      <xsl:variable name="diagramHeight" select="2376"/>
      <xsl:variable name="pageFormatName" select="'A2'"/>
      <xsl:variable name="midx" select="$diagramWidth  div  2 + 0"/>
      <xsl:variable name="diagramMiddle" select="xs:integer($midx)"/>
      <xsl:variable name="basestr" select="'_SDG_'"/>
      <xsl:variable name="statenm" select="concat($lfl/@name,'_StateMachine')"/>
      <xsl:variable name="tsdgid" select="my:GetNewId($sdgid,7,$basestr)"/>
      <xsl:variable name="comma" select="','"/>
      <xsl:variable name="xstep" select="$diagramMiddle + 10"/>
      <xsl:variable name="initSPos" select="concat($xstep,$comma,'20')"/>
      <xsl:variable name="firstSPos" select="concat($diagramMiddle,$comma,'90')"/>
      <xsl:variable name="stdgids" select="my:GetDgIds($tids/@stateid)"/>
      <xsl:variable name="regids" select="my:GetDgIds($tids/@regionid)"/>
      <xsl:variable name="firstSids" select="my:GetDgIds($tids/@firstSid)"/>
      <xsl:variable name="lastSids" select="my:GetDgIds($tids/@lastSid)"/>
      <xsl:variable name="initSids" select="my:GetDgIds($tids/@initSid)"/>
      <xsl:variable name="firstTrids" select="my:GetDgIds($tids/@firstTrid)"/>
      <xsl:variable name="infras" select="my:CalcuFrag($lfl/@xmi:id,$seq)"/>
      <xsl:variable name="infirstids" select="my:GetStIds($infras/@inFirstItemId)"/>
      <xsl:variable name="inFirstItemType" select="$infras/@inFirstItemType"/>
      <xsl:variable name="infirsttranid"
                    select=" if ($inFirstItemType='occ') then $infirstids/@transid else $infirstids/@lpretransid "/>
      <xsl:variable name="infirsttransdgids" select="my:GetDgIds($infirsttranid)"/>
      <xsl:element name="subdiagrams">
         <xsl:attribute name="xmiDiff" select="'insertNext'"/>
         <xsl:attribute name="targetId" select="$sdgid"/>
         <xsl:attribute name="xmi:id" select="$tsdgid"/>
         <xsl:element name="model">
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'href'"/>
               <xsl:attribute name="value"
                              select="string-join(concat($sourceTypedModels[@name='xmiXMI']/@file,'#',$tids/@stateid),' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:element name="diagrams">
            <xsl:if test="exists($dgsize)">
               <xsl:attribute name="size" select="$dgsize"/>
            </xsl:if>
            <xsl:if test="exists($dgpos)">
               <xsl:attribute name="position" select="$dgpos"/>
            </xsl:if>
            <xsl:attribute name="viewport" select="$dgvi"/>
            <xsl:attribute name="name" select="$statenm"/>
            <xsl:attribute name="xmi:id" select="$stdgids/@dgid"/>
            <xsl:element name="contained">
               <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
               <xsl:attribute name="xmi:id" select="$regids/@dgid"/>
               <xsl:if test="exists('-1,-1')">
                  <xsl:attribute name="size" select="'-1,-1'"/>
               </xsl:if>
               <xsl:element name="contained">
                  <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
                  <xsl:attribute name="xmi:id" select="$firstTrids/@dgid"/>
                  <xsl:apply-templates mode="CopyEdgeProper" select="$dig">
                     <xsl:with-param name="dgids" select="$firstTrids"/>
                     <xsl:with-param name="fromids" select="$initSids"/>
                     <xsl:with-param name="toids" select="$firstSids"/>
                     <xsl:with-param name="_targetDom_Key" select="$firstTrids/@dgid"/>
                  </xsl:apply-templates>
               </xsl:element>
               <xsl:element name="contained">
                  <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
                  <xsl:attribute name="xmi:id" select="$firstSids/@dgid"/>
                  <xsl:if test="exists('50,25')">
                     <xsl:attribute name="size" select="'50,25'"/>
                  </xsl:if>
                  <xsl:if test="exists($firstSPos)">
                     <xsl:attribute name="position" select="$firstSPos"/>
                  </xsl:if>
                  <xsl:element name="anchorage">
                     <xsl:attribute name="xmi:id" select="$firstSids/@anchid"/>
                     <xsl:element name="_link_AS_element">
                        <xsl:attribute name="name" select="'graphEdge'"/>
                        <xsl:attribute name="value" select="string-join($firstTrids/@dgid,' ')"/>
                     </xsl:element>
                     <xsl:element name="_link_AS_element">
                        <xsl:attribute name="name" select="'graphEdge'"/>
                        <xsl:attribute name="value" select="string-join($infirsttransdgids/@dgid,' ')"/>
                     </xsl:element>
                  </xsl:element>
                  <xsl:apply-templates mode="CopyGSemantic" select="$dig">
                     <xsl:with-param name="dgids" select="$firstSids"/>
                     <xsl:with-param name="pres" select="'default'"/>
                     <xsl:with-param name="_targetDom_Key" select="$firstSids/@dgid"/>
                  </xsl:apply-templates>
               </xsl:element>
               <xsl:element name="contained">
                  <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
                  <xsl:attribute name="xmi:id" select="$initSids/@dgid"/>
                  <xsl:if test="exists('30,30')">
                     <xsl:attribute name="size" select="'30,30'"/>
                  </xsl:if>
                  <xsl:if test="exists($initSPos)">
                     <xsl:attribute name="position" select="$initSPos"/>
                  </xsl:if>
                  <xsl:element name="anchorage">
                     <xsl:attribute name="xmi:id" select="$initSids/@anchid"/>
                     <xsl:element name="_link_AS_element">
                        <xsl:attribute name="name" select="'graphEdge'"/>
                        <xsl:attribute name="value" select="string-join($firstTrids/@dgid,' ')"/>
                     </xsl:element>
                  </xsl:element>
                  <xsl:apply-templates mode="CopyGSemantic" select="$dig">
                     <xsl:with-param name="dgids" select="$initSids"/>
                     <xsl:with-param name="pres" select="'default'"/>
                     <xsl:with-param name="_targetDom_Key" select="$initSids/@dgid"/>
                  </xsl:apply-templates>
               </xsl:element>
               <xsl:apply-templates mode="CopyGSemantic" select="$dig">
                  <xsl:with-param name="dgids" select="$regids"/>
                  <xsl:with-param name="pres" select="'default'"/>
                  <xsl:with-param name="_targetDom_Key" select="$regids/@dgid"/>
               </xsl:apply-templates>
               <xsl:apply-templates mode="InteractionToDig" select="$seq">
                  <xsl:with-param name="lflid" select="$lfl/@xmi:id"/>
                  <xsl:with-param name="preP" select="$tids/@firstSid"/>
                  <xsl:with-param name="nextP" select="$tids/@lastSid"/>
                  <xsl:with-param name="tids" select="$tids"/>
                  <xsl:with-param name="diagramMiddle" select="$diagramMiddle"/>
                  <xsl:with-param name="_targetDom_Key" select="$regids/@dgid"/>
               </xsl:apply-templates>
            </xsl:element>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'pageFormatName'"/>
               <xsl:with-param name="kvalue" select="$pageFormatName"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'diagramWidth'"/>
               <xsl:with-param name="kvalue" select="$diagramWidth"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'diagramHeight'"/>
               <xsl:with-param name="kvalue" select="$diagramHeight"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'pageMarginName'"/>
               <xsl:with-param name="kvalue" select="'Small Margin'"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'diagramTopMargin'"/>
               <xsl:with-param name="kvalue" select="'20'"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'diagramBottomMargin'"/>
               <xsl:with-param name="kvalue" select="'20'"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'diagramLeftMargin'"/>
               <xsl:with-param name="kvalue" select="'20'"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'diagramRightMargin'"/>
               <xsl:with-param name="kvalue" select="'20'"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="SetGProperty" select="$dig">
               <xsl:with-param name="pkey" select="'orientation'"/>
               <xsl:with-param name="kvalue" select="'landscape'"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
            <xsl:apply-templates mode="CopyGSemantic" select="$dig">
               <xsl:with-param name="dgids" select="$stdgids"/>
               <xsl:with-param name="pres" select="'edu.unu.iist.rcos.modeler.statemachinediagram'"/>
               <xsl:with-param name="_targetDom_Key" select="$stdgids/@dgid"/>
            </xsl:apply-templates>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:CombinedFragment']" mode="FragmentToDig"
                 priority="-10">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="preNum"/>
      <xsl:param name="posX"/>
      <xsl:param name="baseY"/>
      <xsl:param name="nexttranP"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="op1" select="$fr/operand"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes"
                    select="my:CalcuPosDig($preP,$nextP,$frids,$upperS,$cpos,$nexttranP)"/>
      <xsl:variable name="comma" select="','"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="laststids" select="my:GetIdsFromSt($posRes/@newNextP)"/>
      <xsl:variable name="op1frag" select="my:CalcuFrag($lflid,$op1)"/>
      <xsl:variable name="infirstids" select="my:GetStIds($op1frag/@inFirstItemId)"/>
      <xsl:variable name="inlastitem2" select="my:GetStIds($op1frag/@inLastItemId)"/>
      <xsl:variable name="inlaststdgids" select="my:GetDgIds($inlastitem2/@stid)"/>
      <xsl:variable name="xyRes" select="my:CalcuXY($op1frag,$cpos,$preNum,$posX,$baseY,$mid)"/>
      <xsl:variable name="nexttrandgids" select="my:GetDgIds($posRes/@nexttid)"/>
      <xsl:variable name="preprestdgids" select="my:GetDgIds($posRes/@newPreP)"/>
      <xsl:variable name="prestdgids" select="my:GetDgIds($stids/@prestid)"/>
      <xsl:variable name="pretransdgids" select="my:GetDgIds($stids/@lpretransid)"/>
      <xsl:variable name="gstids" select="my:GetDgIds($stids/@stid)"/>
      <xsl:variable name="transdgids" select="my:GetDgIds($stids/@ltransid)"/>
      <xsl:variable name="inLastItemType" select="$op1frag/@inLastItemType"/>
      <xsl:variable name="inFirstItemType" select="$op1frag/@inFirstItemType"/>
      <xsl:variable name="nowinfirsttranid"
                    select=" if ($inFirstItemType='occ') then $infirstids/@transid else $infirstids/@lpretransid "/>
      <xsl:variable name="infirstrantdgids" select="my:GetDgIds($nowinfirsttranid)"/>
      <xsl:variable name="inlastdgids" select="my:GetDgIds($stids/@transid)"/>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:attribute name="xmi:id" select="$prestdgids/@dgid"/>
         <xsl:if test="exists('40,30')">
            <xsl:attribute name="size" select="'40,30'"/>
         </xsl:if>
         <xsl:if test="exists($xyRes/@newpos)">
            <xsl:attribute name="position" select="$xyRes/@newpos"/>
         </xsl:if>
         <xsl:element name="anchorage">
            <xsl:attribute name="xmi:id" select="$prestdgids/@anchid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($infirstrantdgids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($pretransdgids/@dgid,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$fr">
            <xsl:with-param name="dgids" select="$prestdgids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$prestdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$inlastdgids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$inlastdgids"/>
            <xsl:with-param name="fromids" select="$inlaststdgids"/>
            <xsl:with-param name="toids" select="$gstids"/>
            <xsl:with-param name="_targetDom_Key" select="$inlastdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:attribute name="xmi:id" select="$gstids/@dgid"/>
         <xsl:if test="exists('30,30')">
            <xsl:attribute name="size" select="'30,30'"/>
         </xsl:if>
         <xsl:if test="exists($xyRes/@newpos3)">
            <xsl:attribute name="position" select="$xyRes/@newpos3"/>
         </xsl:if>
         <xsl:element name="anchorage">
            <xsl:attribute name="xmi:id" select="$gstids/@anchid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($inlastdgids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($nexttrandgids/@dgid,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$fr">
            <xsl:with-param name="dgids" select="$gstids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$gstids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$pretransdgids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$pretransdgids"/>
            <xsl:with-param name="fromids" select="$preprestdgids"/>
            <xsl:with-param name="toids" select="$prestdgids"/>
            <xsl:with-param name="_targetDom_Key" select="$pretransdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:apply-templates mode="OperandToDig" select="$op1">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$stids/@prestid"/>
         <xsl:with-param name="nextP" select="$stids/@stid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS"/>
         <xsl:with-param name="preNum" select="$preNum"/>
         <xsl:with-param name="posX" select="$xyRes/@newPosX"/>
         <xsl:with-param name="nexttranP" select="$stids/@transid"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='par']"
                 mode="ParToState_bak">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="condi"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="op1" select="$fr/operand[1]"/>
      <xsl:variable name="exp"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="op2" select="$fr/operand[2]"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes" select="my:CalcuPos($preP,$nextP,$frids,$upperS,$cpos)"/>
      <xsl:variable name="prestnm" select="'Choice'"/>
      <xsl:variable name="stnm" select="''"/>
      <xsl:variable name="prestnm" select="''"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="op1frag" select="my:CalcuFrag($lflid,$op1)"/>
      <xsl:variable name="inLastStIds" select="my:GetStIds($op1frag/@inLastItemId)"/>
      <xsl:variable name="op2frag" select="my:CalcuFrag($lflid,$op2)"/>
      <xsl:variable name="inLastStIds2" select="my:GetStIds($op2frag/@inLastItemId)"/>
      <xsl:variable name="reg1nm" select="concat($upperS,'_reg1')"/>
      <xsl:variable name="reg2nm" select="concat($upperS,'_reg2')"/>
      <xsl:variable name="allcondi" select="my:GetTranCondi($frids,$cpos,$condi)"/>
      <xsl:variable name="prnTrannm"
                    select=" if ($allcondi!='') then concat('[',$allcondi,']') else '' "/>
      <xsl:variable name="inlastcondi" select="my:GetPreFragCondi($op1frag/@inLastItemId)"/>
      <xsl:variable name="inLastTrannm"
                    select=" if ($inlastcondi!='') then concat('[',$inlastcondi,']') else '' "/>
      <xsl:variable name="inlastcondi2" select="my:GetPreFragCondi($op2frag/@inLastItemId)"/>
      <xsl:variable name="inLastTrannm2"
                    select=" if ($inlastcondi2!='') then concat('[',$inlastcondi2,']') else '' "/>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@transid"/>
         <xsl:attribute name="name" select="$inLastTrannm"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($inLastStIds/@stid,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@stid,' ')"/>
         </xsl:element>
         <xsl:if test="$inlastcondi!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$inlastcondi"/>
               <xsl:with-param name="basestr" select="'_inlastpre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@transid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:Pseudostate'"/>
         <xsl:attribute name="xmi:id" select="$stids/@stid"/>
         <xsl:if test="exists('join')">
            <xsl:attribute name="kind" select="'join'"/>
         </xsl:if>
         <xsl:attribute name="name" select="$stnm"/>
      </xsl:element>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@ltransid"/>
         <xsl:attribute name="name" select="$inLastTrannm2"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@stid,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($inLastStIds2/@stid,' ')"/>
         </xsl:element>
         <xsl:if test="$inlastcondi2!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$inlastcondi2"/>
               <xsl:with-param name="basestr" select="'_inlast2pre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@ltransid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:Pseudostate'"/>
         <xsl:attribute name="xmi:id" select="$stids/@prestid"/>
         <xsl:if test="exists('fork')">
            <xsl:attribute name="kind" select="'fork'"/>
         </xsl:if>
         <xsl:attribute name="name" select="$prestnm"/>
      </xsl:element>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@lpretransid"/>
         <xsl:attribute name="name" select="$prnTrannm"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($posRes/@newPreP,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@prestid,' ')"/>
         </xsl:element>
         <xsl:if test="$allcondi!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$allcondi"/>
               <xsl:with-param name="basestr" select="'_transpre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@lpretransid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:apply-templates mode="OperandToVertex" select="$op1">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$stids/@prestid"/>
         <xsl:with-param name="nextP" select="$stids/@stid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS"/>
         <xsl:with-param name="condi" select="''"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="OperandToVertex" select="$op2">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$stids/@prestid"/>
         <xsl:with-param name="nextP" select="$stids/@stid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS2"/>
         <xsl:with-param name="condi" select="''"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="*" mode="CopyEdgeProper">
      <xsl:param name="dgids"/>
      <xsl:param name="fromids"/>
      <xsl:param name="toids"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="sd" select="current()"/>
      <xsl:variable name="conn" select="concat($fromids/@anchid,' ',$toids/@anchid)"/>
      <xsl:element name="property">
         <xsl:attribute name="xmi:id" select="$dgids/@propid"/>
         <xsl:attribute name="key" select="'router'"/>
         <xsl:attribute name="value" select="'Rectilinear'"/>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:EdgeObjectOffset'"/>
         <xsl:attribute name="xmi:id" select="$dgids/@offsetid"/>
         <xsl:attribute name="id" select="'nameEdgeObject'"/>
      </xsl:element>
      <xsl:element name="_link_AS_element">
         <xsl:attribute name="name" select="'anchor'"/>
         <xsl:attribute name="value" select="string-join($conn,' ')"/>
      </xsl:element>
      <xsl:apply-templates mode="CopyGSemantic" select="$sd">
         <xsl:with-param name="dgids" select="$dgids"/>
         <xsl:with-param name="pres" select="'default'"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="*" mode="InteractionToDig">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="tids"/>
      <xsl:param name="diagramMiddle"/>
      <xsl:param name="upperS"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="seq" select="current()"/>
      <xsl:variable name="seqid" select="$seq/@xmi:id"/>
      <xsl:variable name="cmb" select="'CombinedFragment'"/>
      <xsl:variable name="allfrs1" select="my:GetAllRecFrag($seq,$lflid)"/>
      <xsl:variable name="allfrs"
                    select="(for $fr in $allfrs1 return my:DoFileterFrag($fr,$lflid))"/>
      <xsl:variable name="frs" select="my:GetRecFrag($seq,$lflid)"/>
      <xsl:variable name="frids" select="$frs/@xmi:id"/>
      <xsl:variable name="lastid" select="$frids[last()]"/>
      <xsl:variable name="count" select="count($allfrs) + 2"/>
      <xsl:variable name="preNum" select="$allfrs/@xmi:id"/>
      <xsl:variable name="comma" select="','"/>
      <xsl:variable name="xstep" select="$diagramMiddle + 10"/>
      <xsl:variable name="initSPos" select="concat($xstep,$comma,'20')"/>
      <xsl:variable name="firstSPos" select="concat($diagramMiddle,$comma,'90')"/>
      <xsl:variable name="regids" select="my:GetDgIds($tids/@regionid)"/>
      <xsl:variable name="firstSids" select="my:GetDgIds($tids/@firstSid)"/>
      <xsl:variable name="lastSids" select="my:GetDgIds($tids/@lastSid)"/>
      <xsl:variable name="initSids" select="my:GetDgIds($tids/@initSid)"/>
      <xsl:variable name="firstTrids" select="my:GetDgIds($tids/@firstTrid)"/>
      <xsl:variable name="infras" select="my:CalcuFrag($lflid,$seq)"/>
      <xsl:variable name="infirstids" select="my:GetStIds($infras/@inFirstItemId)"/>
      <xsl:variable name="inFirstItemType" select="$infras/@inFirstItemType"/>
      <xsl:variable name="infirsttranid"
                    select=" if ($inFirstItemType='occ') then $infirstids/@transid else $infirstids/@lpretransid "/>
      <xsl:variable name="infirsttransdgids" select="my:GetDgIds($infirsttranid)"/>
      <xsl:variable name="finalstids" select="my:GetIdsFromSt($nextP)"/>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:attribute name="xmi:id" select="$regids/@dgid"/>
         <xsl:if test="exists('-1,-1')">
            <xsl:attribute name="size" select="'-1,-1'"/>
         </xsl:if>
         <xsl:element name="contained">
            <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
            <xsl:attribute name="xmi:id" select="$firstTrids/@dgid"/>
            <xsl:apply-templates mode="CopyEdgeProper" select="$seq">
               <xsl:with-param name="dgids" select="$firstTrids"/>
               <xsl:with-param name="fromids" select="$initSids"/>
               <xsl:with-param name="toids" select="$firstSids"/>
               <xsl:with-param name="_targetDom_Key" select="$firstTrids/@dgid"/>
            </xsl:apply-templates>
         </xsl:element>
         <xsl:element name="contained">
            <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
            <xsl:attribute name="xmi:id" select="$initSids/@dgid"/>
            <xsl:if test="exists($initSPos)">
               <xsl:attribute name="position" select="$initSPos"/>
            </xsl:if>
            <xsl:if test="exists('30,30')">
               <xsl:attribute name="size" select="'30,30'"/>
            </xsl:if>
            <xsl:element name="anchorage">
               <xsl:attribute name="xmi:id" select="$initSids/@anchid"/>
               <xsl:element name="_link_AS_element">
                  <xsl:attribute name="name" select="'graphEdge'"/>
                  <xsl:attribute name="value" select="string-join($firstTrids/@dgid,' ')"/>
               </xsl:element>
            </xsl:element>
            <xsl:apply-templates mode="CopyGSemantic" select="$seq">
               <xsl:with-param name="dgids" select="$initSids"/>
               <xsl:with-param name="pres" select="'default'"/>
               <xsl:with-param name="_targetDom_Key" select="$initSids/@dgid"/>
            </xsl:apply-templates>
         </xsl:element>
         <xsl:element name="contained">
            <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
            <xsl:attribute name="xmi:id" select="$firstSids/@dgid"/>
            <xsl:if test="exists('50,25')">
               <xsl:attribute name="size" select="'50,25'"/>
            </xsl:if>
            <xsl:if test="exists($firstSPos)">
               <xsl:attribute name="position" select="$firstSPos"/>
            </xsl:if>
            <xsl:element name="anchorage">
               <xsl:attribute name="xmi:id" select="$firstSids/@anchid"/>
               <xsl:element name="_link_AS_element">
                  <xsl:attribute name="name" select="'graphEdge'"/>
                  <xsl:attribute name="value" select="string-join($infirsttransdgids/@dgid,' ')"/>
               </xsl:element>
               <xsl:element name="_link_AS_element">
                  <xsl:attribute name="name" select="'graphEdge'"/>
                  <xsl:attribute name="value" select="string-join($firstTrids/@dgid,' ')"/>
               </xsl:element>
            </xsl:element>
            <xsl:apply-templates mode="CopyGSemantic" select="$seq">
               <xsl:with-param name="dgids" select="$firstSids"/>
               <xsl:with-param name="pres" select="'default'"/>
               <xsl:with-param name="_targetDom_Key" select="$firstSids/@dgid"/>
            </xsl:apply-templates>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$seq">
            <xsl:with-param name="dgids" select="$regids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$regids/@dgid"/>
         </xsl:apply-templates>
         <xsl:apply-templates mode="FragmentToDig" select="$frs">
            <xsl:with-param name="lflid" select="$lflid"/>
            <xsl:with-param name="preP" select="$preP"/>
            <xsl:with-param name="nextP" select="$nextP"/>
            <xsl:with-param name="frids" select="$frids"/>
            <xsl:with-param name="tids" select="$tids"/>
            <xsl:with-param name="upperS" select="$upperS"/>
            <xsl:with-param name="preNum" select="$preNum"/>
            <xsl:with-param name="posX" select="$diagramMiddle"/>
            <xsl:with-param name="baseY" select="20"/>
            <xsl:with-param name="nexttranP" select="$finalstids/@transid"/>
            <xsl:with-param name="_targetDom_Key" select="$regids/@dgid"/>
         </xsl:apply-templates>
         <xsl:apply-templates mode="CreateFinalTransDig" select="$seq">
            <xsl:with-param name="finalstid" select="$nextP "/>
            <xsl:with-param name="preid" select="$lastid"/>
            <xsl:with-param name="preNum" select="$count"/>
            <xsl:with-param name="posX" select="$diagramMiddle"/>
            <xsl:with-param name="lflid" select="$lflid"/>
            <xsl:with-param name="_targetDom_Key" select="$regids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='opt']"
                 mode="FragmentToDig">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="preNum"/>
      <xsl:param name="posX"/>
      <xsl:param name="baseY"/>
      <xsl:param name="nexttranP"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="op1" select="$fr/operand"/>
      <xsl:variable name="exp"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes"
                    select="my:CalcuPosDig($preP,$nextP,$frids,$upperS,$cpos,$nexttranP)"/>
      <xsl:variable name="comma" select="','"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="laststids" select="my:GetIdsFromSt($posRes/@newNextP)"/>
      <xsl:variable name="op1frag" select="my:CalcuFrag($lflid,$op1)"/>
      <xsl:variable name="infirstids" select="my:GetStIds($op1frag/@inFirstItemId)"/>
      <xsl:variable name="inlastitem2" select="my:GetStIds($op1frag/@inLastItemId)"/>
      <xsl:variable name="inlaststdgids" select="my:GetDgIds($inlastitem2/@stid)"/>
      <xsl:variable name="xyRes" select="my:CalcuXY($op1frag,$cpos,$preNum,$posX,$baseY,$mid)"/>
      <xsl:variable name="nexttrandgids" select="my:GetDgIds($posRes/@nexttid)"/>
      <xsl:variable name="preprestdgids" select="my:GetDgIds($posRes/@newPreP)"/>
      <xsl:variable name="prestdgids" select="my:GetDgIds($stids/@prestid)"/>
      <xsl:variable name="pretransdgids" select="my:GetDgIds($stids/@lpretransid)"/>
      <xsl:variable name="gstids" select="my:GetDgIds($stids/@stid)"/>
      <xsl:variable name="transdgids" select="my:GetDgIds($stids/@ltransid)"/>
      <xsl:variable name="inLastItemType" select="$op1frag/@inLastItemType"/>
      <xsl:variable name="inFirstItemType" select="$op1frag/@inFirstItemType"/>
      <xsl:variable name="nowinfirsttranid"
                    select=" if ($inFirstItemType='occ') then $infirstids/@transid else $infirstids/@lpretransid "/>
      <xsl:variable name="infirstrantdgids" select="my:GetDgIds($nowinfirsttranid)"/>
      <xsl:variable name="inlastdgids" select="my:GetDgIds($stids/@transid)"/>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:attribute name="xmi:id" select="$gstids/@dgid"/>
         <xsl:if test="exists('30,30')">
            <xsl:attribute name="size" select="'30,30'"/>
         </xsl:if>
         <xsl:if test="exists($xyRes/@newpos3)">
            <xsl:attribute name="position" select="$xyRes/@newpos3"/>
         </xsl:if>
         <xsl:element name="anchorage">
            <xsl:attribute name="xmi:id" select="$gstids/@anchid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($nexttrandgids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($inlastdgids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($transdgids/@dgid,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$fr">
            <xsl:with-param name="dgids" select="$gstids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$gstids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$inlastdgids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$inlastdgids"/>
            <xsl:with-param name="fromids" select="$inlaststdgids"/>
            <xsl:with-param name="toids" select="$gstids"/>
            <xsl:with-param name="_targetDom_Key" select="$inlastdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$transdgids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$transdgids"/>
            <xsl:with-param name="fromids" select="$prestdgids"/>
            <xsl:with-param name="toids" select="$gstids"/>
            <xsl:with-param name="_targetDom_Key" select="$transdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$pretransdgids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$pretransdgids"/>
            <xsl:with-param name="fromids" select="$preprestdgids"/>
            <xsl:with-param name="toids" select="$prestdgids"/>
            <xsl:with-param name="_targetDom_Key" select="$pretransdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:attribute name="xmi:id" select="$prestdgids/@dgid"/>
         <xsl:if test="exists('40,30')">
            <xsl:attribute name="size" select="'40,30'"/>
         </xsl:if>
         <xsl:if test="exists($xyRes/@newpos)">
            <xsl:attribute name="position" select="$xyRes/@newpos"/>
         </xsl:if>
         <xsl:element name="anchorage">
            <xsl:attribute name="xmi:id" select="$prestdgids/@anchid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($transdgids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($pretransdgids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($infirstrantdgids/@dgid,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$fr">
            <xsl:with-param name="dgids" select="$prestdgids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$prestdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:apply-templates mode="OperandToDig" select="$op1">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$stids/@prestid"/>
         <xsl:with-param name="nextP" select="$stids/@stid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS"/>
         <xsl:with-param name="preNum" select="$preNum"/>
         <xsl:with-param name="posX" select="$xyRes/@newPosX"/>
         <xsl:with-param name="nexttranP" select="$stids/@transid"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="*" mode="CopyGuard">
      <xsl:param name="guard"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:element name="ownedRule">
         <xsl:element name="specification">
            <xsl:attribute name="xmi:type" select="'uml:LiteralString'"/>
            <xsl:attribute name="value" select="$guard"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="subdiagrams[diagrams[@name=$transSeqDName]]" mode="DiagNameToSeq">
      <xsl:param name="commid"/>
      <xsl:param name="umid"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="subdgm" select="current()"/>
      <xsl:variable name="dgm" select="$subdgm/diagrams[@name=$transSeqDName]"/>
      <xsl:variable name="dgmnm" select="$dgm/@name"/>
      <xsl:variable name="seq"
                    select="my:GetTypedModel('xmiXMI',$dgm/semanticModel[@xsi:type='di:EMFSemanticModelBridge']/element/@href)"/>
      <xsl:apply-templates mode="LifelineToSD" select="$seq">
         <xsl:with-param name="subdgm" select="$subdgm"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='par']"
                 mode="FragmentToState">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="condi"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="op2" select="$fr/operand[2]"/>
      <xsl:variable name="op2id" select="$op2/@xmi:id"/>
      <xsl:variable name="op1" select="$fr/operand[1]"/>
      <xsl:variable name="op1id" select="$op1/@xmi:id"/>
      <xsl:variable name="exp"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes" select="my:CalcuPos($preP,$nextP,$frids,$upperS,$cpos)"/>
      <xsl:variable name="prestnm" select="'Choice'"/>
      <xsl:variable name="stnm" select="''"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="reg1nm" select="concat($posRes/@newUpperS,'_1')"/>
      <xsl:variable name="reg2nm" select="concat($posRes/@newUpperS,'_2')"/>
      <xsl:variable name="allcondi" select="my:GetTranCondi($frids,$cpos,$condi)"/>
      <xsl:variable name="transnm"
                    select=" if ($allcondi!='') then concat('[',$allcondi,']') else '' "/>
      <xsl:variable name="allfrag" select="my:GetAllRecFrag($fr,$lflid)"/>
      <xsl:variable name="boool" select="exists($allfrag[@interactionOperator='critical'])"/>
      <xsl:variable name="strict1"
                    select=" if ($boool) then concat('_critical',$reg2nm,'=OFF') else '' "/>
      <xsl:variable name="strict2"
                    select=" if ($boool) then concat('_critical',$reg1nm,'=OFF') else '' "/>
      <xsl:variable name="basestr1" select="'_SD_p1_'"/>
      <xsl:variable name="basestr2" select="'_SD_p2_'"/>
      <xsl:variable name="tids1" select="my:GetTids($op1id,$lflid,$basestr1)"/>
      <xsl:variable name="tids2" select="my:GetTids($op2id,$lflid,$basestr2)"/>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:State'"/>
         <xsl:attribute name="name" select="$stnm"/>
         <xsl:attribute name="xmi:id" select="$stids/@stid"/>
         <xsl:apply-templates mode="InteractionToVertex" select="$op1">
            <xsl:with-param name="lflid" select="$lflid"/>
            <xsl:with-param name="preP" select="$tids1/@firstSid"/>
            <xsl:with-param name="nextP" select="$tids1/@lastSid"/>
            <xsl:with-param name="tids" select="$tids1"/>
            <xsl:with-param name="parentStnm" select="$reg1nm"/>
            <xsl:with-param name="strictVar" select="$strict1"/>
            <xsl:with-param name="_targetDom_Key" select="$stids/@stid"/>
         </xsl:apply-templates>
         <xsl:apply-templates mode="InteractionToVertex" select="$op2">
            <xsl:with-param name="lflid" select="$lflid"/>
            <xsl:with-param name="preP" select="$tids2/@firstSid"/>
            <xsl:with-param name="nextP" select="$tids2/@lastSid"/>
            <xsl:with-param name="tids" select="$tids2"/>
            <xsl:with-param name="parentStnm" select="$reg2nm"/>
            <xsl:with-param name="strictVar" select="$strict2"/>
            <xsl:with-param name="_targetDom_Key" select="$stids/@stid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="transition">
         <xsl:attribute name="name" select="$transnm"/>
         <xsl:attribute name="xmi:id" select="$stids/@transid"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($posRes/@newPreP,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@stid,' ')"/>
         </xsl:element>
         <xsl:if test="$allcondi!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$allcondi"/>
               <xsl:with-param name="basestr" select="'_transpre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@transid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='break']"
                 mode="FragmentToDig">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="preNum"/>
      <xsl:param name="posX"/>
      <xsl:param name="baseY"/>
      <xsl:param name="nexttranP"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="op1" select="$fr/operand"/>
      <xsl:variable name="exp"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes"
                    select="my:CalcuPosDig($preP,$nextP,$frids,$upperS,$cpos,$nexttranP)"/>
      <xsl:variable name="comma" select="','"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="finalstids" select="my:GetIdsFromSt($tids/@lastSid)"/>
      <xsl:variable name="op1frag" select="my:CalcuFrag($lflid,$op1)"/>
      <xsl:variable name="infirstids" select="my:GetStIds($op1frag/@inFirstItemId)"/>
      <xsl:variable name="inlastitem2" select="my:GetStIds($op1frag/@inLastItemId)"/>
      <xsl:variable name="inlaststdgids" select="my:GetDgIds($inlastitem2/@stid)"/>
      <xsl:variable name="xyRes" select="my:CalcuXY($op1frag,$cpos,$preNum,$posX,$baseY,$mid)"/>
      <xsl:variable name="nexttrandgids" select="my:GetDgIds($posRes/@nexttid)"/>
      <xsl:variable name="preprestdgids" select="my:GetDgIds($posRes/@newPreP)"/>
      <xsl:variable name="prestdgids" select="my:GetDgIds($stids/@prestid)"/>
      <xsl:variable name="pretransdgids" select="my:GetDgIds($stids/@transid)"/>
      <xsl:variable name="gstids" select="my:GetDgIds($stids/@stid)"/>
      <xsl:variable name="inLastItemType" select="$op1frag/@inLastItemType"/>
      <xsl:variable name="inFirstItemType" select="$op1frag/@inFirstItemType"/>
      <xsl:variable name="nowinfirsttranid"
                    select=" if ($inFirstItemType='occ') then $infirstids/@transid else $infirstids/@lpretransid "/>
      <xsl:variable name="infirstrantdgids" select="my:GetDgIds($nowinfirsttranid)"/>
      <xsl:variable name="inlastdgids" select="my:GetDgIds($finalstids/@ltransid)"/>
      <xsl:variable name="finaldgids" select="my:GetDgIds($finalstids/@stid)"/>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$pretransdgids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$pretransdgids"/>
            <xsl:with-param name="fromids" select="$preprestdgids"/>
            <xsl:with-param name="toids" select="$gstids"/>
            <xsl:with-param name="_targetDom_Key" select="$pretransdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$inlastdgids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$inlastdgids"/>
            <xsl:with-param name="fromids" select="$inlaststdgids"/>
            <xsl:with-param name="toids" select="$finaldgids"/>
            <xsl:with-param name="_targetDom_Key" select="$inlastdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:attribute name="xmi:id" select="$gstids/@dgid"/>
         <xsl:if test="exists('40,30')">
            <xsl:attribute name="size" select="'40,30'"/>
         </xsl:if>
         <xsl:if test="exists($xyRes/@newpos)">
            <xsl:attribute name="position" select="$xyRes/@newpos"/>
         </xsl:if>
         <xsl:element name="anchorage">
            <xsl:attribute name="xmi:id" select="$gstids/@anchid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($nexttrandgids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($infirstrantdgids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($pretransdgids/@dgid,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$fr">
            <xsl:with-param name="dgids" select="$gstids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$gstids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:apply-templates mode="OperandToDig" select="$op1">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$stids/@stid"/>
         <xsl:with-param name="nextP" select="$finalstids/@stid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS"/>
         <xsl:with-param name="preNum" select="$preNum"/>
         <xsl:with-param name="posX" select="$xyRes/@newPosX"/>
         <xsl:with-param name="nexttranP" select="$finalstids/@ltransid"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='par']"
                 mode="ParToDig_bak">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="preNum"/>
      <xsl:param name="posX"/>
      <xsl:param name="baseY"/>
      <xsl:param name="nexttranP"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="op1" select="$fr/operand[1]"/>
      <xsl:variable name="exp"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="op2" select="$fr/operand[2]"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes"
                    select="my:CalcuPosDig($preP,$nextP,$frids,$upperS,$cpos,$nexttranP)"/>
      <xsl:variable name="comma" select="','"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="laststids" select="my:GetIdsFromSt($posRes/@newNextP)"/>
      <xsl:variable name="op1frag" select="my:CalcuFrag($lflid,$op1)"/>
      <xsl:variable name="infirstids" select="my:GetStIds($op1frag/@inFirstItemId)"/>
      <xsl:variable name="inlastitem2" select="my:GetStIds($op1frag/@inLastItemId)"/>
      <xsl:variable name="inlaststdgids" select="my:GetDgIds($inlastitem2/@stid)"/>
      <xsl:variable name="op2frag" select="my:CalcuFrag($lflid,$op2)"/>
      <xsl:variable name="infirstids2" select="my:GetStIds($op2frag/@inFirstItemId)"/>
      <xsl:variable name="inlastitem22" select="my:GetStIds($op2frag/@inLastItemId)"/>
      <xsl:variable name="inlaststdgids2" select="my:GetDgIds($inlastitem22/@stid)"/>
      <xsl:variable name="op12all" select="my:CalcuTotalFrag($op1frag,$op2frag)"/>
      <xsl:variable name="xyRes" select="my:CalcuXY($op12all,$cpos,$preNum,$posX,$baseY,$mid)"/>
      <xsl:variable name="xyRes2" select="my:CalcuXY($op12all,$cpos,$preNum,$posX,$baseY,$mid)"/>
      <xsl:variable name="nexttrandgids" select="my:GetDgIds($posRes/@nexttid)"/>
      <xsl:variable name="preprestdgids" select="my:GetDgIds($posRes/@newPreP)"/>
      <xsl:variable name="prestdgids" select="my:GetDgIds($stids/@prestid)"/>
      <xsl:variable name="pretransdgids" select="my:GetDgIds($stids/@lpretransid)"/>
      <xsl:variable name="gstids" select="my:GetDgIds($stids/@stid)"/>
      <xsl:variable name="inLastItemType" select="$op1frag/@inLastItemType"/>
      <xsl:variable name="inFirstItemType" select="$op1frag/@inFirstItemType"/>
      <xsl:variable name="nowinfirsttranid"
                    select=" if ($inFirstItemType='occ') then $infirstids/@transid else $infirstids/@lpretransid "/>
      <xsl:variable name="infirstrantdgids" select="my:GetDgIds($nowinfirsttranid)"/>
      <xsl:variable name="inlastdgids" select="my:GetDgIds($stids/@transid)"/>
      <xsl:variable name="inLastItemType2" select="$op2frag/@inLastItemType"/>
      <xsl:variable name="inFirstItemType2" select="$op2frag/@inFirstItemType"/>
      <xsl:variable name="nowinfirsttranid2"
                    select=" if ($inFirstItemType2='occ') then $infirstids2/@transid else $infirstids2/@lpretransid "/>
      <xsl:variable name="infirstrantdgids2" select="my:GetDgIds($nowinfirsttranid2)"/>
      <xsl:variable name="inlastdgids2" select="my:GetDgIds($stids/@ltransid)"/>
      <xsl:variable name="comstdgids" select="my:GetDgIds($stids/@regstid)"/>
      <xsl:variable name="reg1dgids" select="my:GetDgIds($stids/@reg1id)"/>
      <xsl:variable name="reg2dgids" select="my:GetDgIds($stids/@reg2id)"/>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$inlastdgids2/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$inlastdgids2"/>
            <xsl:with-param name="fromids" select="$inlaststdgids2"/>
            <xsl:with-param name="toids" select="$gstids"/>
            <xsl:with-param name="_targetDom_Key" select="$inlastdgids2/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$pretransdgids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$pretransdgids"/>
            <xsl:with-param name="fromids" select="$preprestdgids"/>
            <xsl:with-param name="toids" select="$prestdgids"/>
            <xsl:with-param name="_targetDom_Key" select="$pretransdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:attribute name="xmi:id" select="$gstids/@dgid"/>
         <xsl:if test="exists('50,15')">
            <xsl:attribute name="size" select="'50,15'"/>
         </xsl:if>
         <xsl:if test="exists($xyRes/@newpos3)">
            <xsl:attribute name="position" select="$xyRes/@newpos3"/>
         </xsl:if>
         <xsl:element name="anchorage">
            <xsl:attribute name="xmi:id" select="$gstids/@anchid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($nexttrandgids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($inlastdgids2/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($inlastdgids/@dgid,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$fr">
            <xsl:with-param name="dgids" select="$gstids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$gstids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$inlastdgids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$inlastdgids"/>
            <xsl:with-param name="fromids" select="$inlaststdgids"/>
            <xsl:with-param name="toids" select="$gstids"/>
            <xsl:with-param name="_targetDom_Key" select="$inlastdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:attribute name="xmi:id" select="$prestdgids/@dgid"/>
         <xsl:if test="exists('50,15')">
            <xsl:attribute name="size" select="'50,15'"/>
         </xsl:if>
         <xsl:if test="exists($xyRes/@newpos)">
            <xsl:attribute name="position" select="$xyRes/@newpos"/>
         </xsl:if>
         <xsl:element name="anchorage">
            <xsl:attribute name="xmi:id" select="$prestdgids/@anchid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($infirstrantdgids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($pretransdgids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($infirstrantdgids2/@dgid,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$fr">
            <xsl:with-param name="dgids" select="$prestdgids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$prestdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:apply-templates mode="OperandToDig" select="$op1">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$stids/@prestid"/>
         <xsl:with-param name="nextP" select="$stids/@stid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS"/>
         <xsl:with-param name="preNum" select="$preNum"/>
         <xsl:with-param name="posX" select="$xyRes/@newPosX"/>
         <xsl:with-param name="nexttranP" select="$stids/@transid"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="OperandToDig" select="$op2">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$stids/@prestid"/>
         <xsl:with-param name="nextP" select="$stids/@stid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS"/>
         <xsl:with-param name="preNum" select="$preNum"/>
         <xsl:with-param name="posX" select="$xyRes2/@newPosX2"/>
         <xsl:with-param name="nexttranP" select="$stids/@ltransid"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:MessageOccurrenceSpecification' and my:xmiXMIrefs(@message)[name()='message']]"
                 mode="FragmentToDig">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="preNum"/>
      <xsl:param name="posX"/>
      <xsl:param name="baseY"/>
      <xsl:param name="nexttranP"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="ev" select="my:xmiXMIrefs($fr/@event)[@xmi:type='uml:CallEvent']"/>
      <xsl:variable name="evid" select="$ev/@xmi:id"/>
      <xsl:variable name="opid" select="$ev/@operation"/>
      <xsl:variable name="opnm"
                    select="my:xmiXMIrefs($ev/@operation)[name()='ownedOperation']/@name"/>
      <xsl:variable name="ms" select="my:xmiXMIrefs($fr/@message)[name()='message']"/>
      <xsl:variable name="msnm" select="$ms/@name"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="comma" select="','"/>
      <xsl:variable name="posRes"
                    select="my:CalcuPosDig($preP,$nextP,$frids,$upperS,$cpos,$nexttranP)"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="laststids" select="my:GetIdsFromSt($posRes/@newNextP)"/>
      <xsl:variable name="stnm" select="concat('S',$upperS,'_',$cpos)"/>
      <xsl:variable name="stnmlen" select="string-length($stnm)"/>
      <xsl:variable name="morelen"
                    select=" if ($stnmlen &gt; 5) then ( $stnmlen  -  5 ) * 7 + 50 else 50 "/>
      <xsl:variable name="stsize" select="concat($morelen,$comma,'28')"/>
      <xsl:variable name="abspos" select="index-of($preNum,$mid)"/>
      <xsl:variable name="count" select="$abspos + 1"/>
      <xsl:variable name="newposy" select="$count * 70 + $baseY"/>
      <xsl:variable name="newpos" select="concat($posX,$comma,$newposy)"/>
      <xsl:variable name="tstids" select="my:GetDgIds($stids/@stid)"/>
      <xsl:variable name="transids" select="my:GetDgIds($stids/@transid)"/>
      <xsl:variable name="sstids" select="my:GetDgIds($posRes/@newPreP)"/>
      <xsl:variable name="nstids" select="my:GetDgIds($posRes/@newNextP)"/>
      <xsl:variable name="nexttranids" select="my:GetDgIds($posRes/@nexttid)"/>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$transids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$transids"/>
            <xsl:with-param name="fromids" select="$sstids"/>
            <xsl:with-param name="toids" select="$tstids"/>
            <xsl:with-param name="_targetDom_Key" select="$transids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:attribute name="xmi:id" select="$tstids/@dgid"/>
         <xsl:if test="exists($stsize)">
            <xsl:attribute name="size" select="$stsize"/>
         </xsl:if>
         <xsl:if test="exists($newpos)">
            <xsl:attribute name="position" select="$newpos"/>
         </xsl:if>
         <xsl:element name="anchorage">
            <xsl:attribute name="xmi:id" select="$tstids/@anchid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($transids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($nexttranids/@dgid,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$fr">
            <xsl:with-param name="dgids" select="$tstids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$tstids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='alt']"
                 mode="FragmentToDig">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="preNum"/>
      <xsl:param name="posX"/>
      <xsl:param name="baseY"/>
      <xsl:param name="nexttranP"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="op1" select="$fr/operand[1]"/>
      <xsl:variable name="exp"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="op2" select="$fr/operand[2]"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes"
                    select="my:CalcuPosDig($preP,$nextP,$frids,$upperS,$cpos,$nexttranP)"/>
      <xsl:variable name="comma" select="','"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="laststids" select="my:GetIdsFromSt($posRes/@newNextP)"/>
      <xsl:variable name="op1frag" select="my:CalcuFrag($lflid,$op1)"/>
      <xsl:variable name="infirstids" select="my:GetStIds($op1frag/@inFirstItemId)"/>
      <xsl:variable name="inlastitem2" select="my:GetStIds($op1frag/@inLastItemId)"/>
      <xsl:variable name="inlaststdgids" select="my:GetDgIds($inlastitem2/@stid)"/>
      <xsl:variable name="op2frag" select="my:CalcuFrag($lflid,$op2)"/>
      <xsl:variable name="infirstids2" select="my:GetStIds($op2frag/@inFirstItemId)"/>
      <xsl:variable name="inlastitem22" select="my:GetStIds($op2frag/@inLastItemId)"/>
      <xsl:variable name="inlaststdgids2" select="my:GetDgIds($inlastitem22/@stid)"/>
      <xsl:variable name="op12all" select="my:CalcuTotalFrag($op1frag,$op2frag)"/>
      <xsl:variable name="xyRes" select="my:CalcuXY($op12all,$cpos,$preNum,$posX,$baseY,$mid)"/>
      <xsl:variable name="xyRes2" select="my:CalcuXY($op12all,$cpos,$preNum,$posX,$baseY,$mid)"/>
      <xsl:variable name="nexttrandgids" select="my:GetDgIds($posRes/@nexttid)"/>
      <xsl:variable name="preprestdgids" select="my:GetDgIds($posRes/@newPreP)"/>
      <xsl:variable name="prestdgids" select="my:GetDgIds($stids/@prestid)"/>
      <xsl:variable name="pretransdgids" select="my:GetDgIds($stids/@lpretransid)"/>
      <xsl:variable name="gstids" select="my:GetDgIds($stids/@stid)"/>
      <xsl:variable name="inLastItemType" select="$op1frag/@inLastItemType"/>
      <xsl:variable name="inFirstItemType" select="$op1frag/@inFirstItemType"/>
      <xsl:variable name="nowinfirsttranid"
                    select=" if ($inFirstItemType='occ') then $infirstids/@transid else $infirstids/@lpretransid "/>
      <xsl:variable name="infirstrantdgids" select="my:GetDgIds($nowinfirsttranid)"/>
      <xsl:variable name="inlastdgids" select="my:GetDgIds($stids/@transid)"/>
      <xsl:variable name="inLastItemType2" select="$op2frag/@inLastItemType"/>
      <xsl:variable name="inFirstItemType2" select="$op2frag/@inFirstItemType"/>
      <xsl:variable name="nowinfirsttranid2"
                    select=" if ($inFirstItemType2='occ') then $infirstids2/@transid else $infirstids2/@lpretransid "/>
      <xsl:variable name="infirstrantdgids2" select="my:GetDgIds($nowinfirsttranid2)"/>
      <xsl:variable name="inlastdgids2" select="my:GetDgIds($stids/@ltransid)"/>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$inlastdgids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$inlastdgids"/>
            <xsl:with-param name="fromids" select="$inlaststdgids"/>
            <xsl:with-param name="toids" select="$gstids"/>
            <xsl:with-param name="_targetDom_Key" select="$inlastdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$pretransdgids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$pretransdgids"/>
            <xsl:with-param name="fromids" select="$preprestdgids"/>
            <xsl:with-param name="toids" select="$prestdgids"/>
            <xsl:with-param name="_targetDom_Key" select="$pretransdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$inlastdgids2/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$inlastdgids2"/>
            <xsl:with-param name="fromids" select="$inlaststdgids2"/>
            <xsl:with-param name="toids" select="$gstids"/>
            <xsl:with-param name="_targetDom_Key" select="$inlastdgids2/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:attribute name="xmi:id" select="$gstids/@dgid"/>
         <xsl:if test="exists('30,30')">
            <xsl:attribute name="size" select="'30,30'"/>
         </xsl:if>
         <xsl:if test="exists($xyRes/@newpos3)">
            <xsl:attribute name="position" select="$xyRes/@newpos3"/>
         </xsl:if>
         <xsl:element name="anchorage">
            <xsl:attribute name="xmi:id" select="$gstids/@anchid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($nexttrandgids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($inlastdgids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($inlastdgids2/@dgid,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$fr">
            <xsl:with-param name="dgids" select="$gstids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$gstids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:attribute name="xmi:id" select="$prestdgids/@dgid"/>
         <xsl:if test="exists('40,30')">
            <xsl:attribute name="size" select="'40,30'"/>
         </xsl:if>
         <xsl:if test="exists($xyRes/@newpos)">
            <xsl:attribute name="position" select="$xyRes/@newpos"/>
         </xsl:if>
         <xsl:element name="anchorage">
            <xsl:attribute name="xmi:id" select="$prestdgids/@anchid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($infirstrantdgids2/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($pretransdgids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($infirstrantdgids/@dgid,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$fr">
            <xsl:with-param name="dgids" select="$prestdgids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$prestdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:apply-templates mode="OperandToDig" select="$op1">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$stids/@prestid"/>
         <xsl:with-param name="nextP" select="$stids/@stid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS"/>
         <xsl:with-param name="preNum" select="$preNum"/>
         <xsl:with-param name="posX" select="$xyRes/@newPosX"/>
         <xsl:with-param name="nexttranP" select="$stids/@transid"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
      <xsl:apply-templates mode="OperandToDig" select="$op2">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$stids/@prestid"/>
         <xsl:with-param name="nextP" select="$stids/@stid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS"/>
         <xsl:with-param name="preNum" select="$preNum"/>
         <xsl:with-param name="posX" select="$xyRes2/@newPosX2"/>
         <xsl:with-param name="nexttranP" select="$stids/@ltransid"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="*" mode="OperandToVertex">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="condi"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="iop" select="current()"/>
      <xsl:variable name="cmb" select="'CombinedFragment'"/>
      <xsl:variable name="frs" select="my:GetRecFrag($iop,$lflid)"/>
      <xsl:variable name="frids" select="$frs/@xmi:id"/>
      <xsl:apply-templates mode="FragmentToState" select="$frs">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$preP"/>
         <xsl:with-param name="nextP" select="$nextP"/>
         <xsl:with-param name="frids" select="$frids"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$upperS"/>
         <xsl:with-param name="condi" select="$condi"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="*" mode="InteractionToVertex">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="tids"/>
      <xsl:param name="parentStnm"/>
      <xsl:param name="strictVar"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="seq" select="current()"/>
      <xsl:variable name="seqid" select="$seq/@xmi:id"/>
      <xsl:variable name="cmb" select="'CombinedFragment'"/>
      <xsl:variable name="regionnm"
                    select=" if (contains($parentStnm,'_StateMachine')) then concat($parentStnm,'_Region') else concat('_state',$parentStnm) "/>
      <xsl:variable name="laststids" select="my:GetIdsFromSt($tids/@lastSid)"/>
      <xsl:variable name="infrag" select="my:CalcuFrag($lflid,$seq)"/>
      <xsl:variable name="inLastStIds" select="my:GetStIds($infrag/@inLastItemId)"/>
      <xsl:variable name="uppers"
                    select=" if (contains($parentStnm,'_StateMachine')) then '' else $parentStnm "/>
      <xsl:variable name="inlastcondi" select="my:GetPreFragCondi($infrag/@inLastItemId)"/>
      <xsl:variable name="lastTrannm"
                    select=" if ($inlastcondi!='') then concat('[',$inlastcondi,']') else '' "/>
      <xsl:variable name="frs" select="my:GetRecFrag($seq,$lflid)"/>
      <xsl:variable name="frids" select="$frs/@xmi:id"/>
      <xsl:element name="region">
         <xsl:attribute name="name" select="$regionnm"/>
         <xsl:attribute name="xmi:id" select="$tids/@regionid"/>
         <xsl:element name="transition">
            <xsl:attribute name="xmi:id" select="$laststids/@transid"/>
            <xsl:attribute name="name" select="$lastTrannm"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'source'"/>
               <xsl:attribute name="value" select="string-join($inLastStIds/@stid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'target'"/>
               <xsl:attribute name="value" select="string-join($tids/@lastSid,' ')"/>
            </xsl:element>
            <xsl:if test="$inlastcondi!=''">
               <xsl:apply-templates mode="SetConstrain" select="$seq">
                  <xsl:with-param name="name" select="'pre'"/>
                  <xsl:with-param name="value" select="$inlastcondi"/>
                  <xsl:with-param name="basestr" select="'_inlastpre'"/>
                  <xsl:with-param name="_targetDom_Key" select="$laststids/@transid"/>
               </xsl:apply-templates>
            </xsl:if>
         </xsl:element>
         <xsl:element name="subvertex">
            <xsl:attribute name="xmi:type" select="'uml:Pseudostate'"/>
            <xsl:attribute name="xmi:id" select="$tids/@initSid"/>
         </xsl:element>
         <xsl:element name="subvertex">
            <xsl:attribute name="xmi:type" select="'uml:State'"/>
            <xsl:attribute name="name" select="'Init'"/>
            <xsl:attribute name="xmi:id" select="$tids/@firstSid"/>
         </xsl:element>
         <xsl:element name="subvertex">
            <xsl:attribute name="xmi:type" select="'uml:FinalState'"/>
            <xsl:attribute name="xmi:id" select="$tids/@lastSid"/>
            <xsl:attribute name="name" select="'Final'"/>
         </xsl:element>
         <xsl:element name="transition">
            <xsl:attribute name="name" select="''"/>
            <xsl:attribute name="xmi:id" select="$tids/@firstTrid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'source'"/>
               <xsl:attribute name="value" select="string-join($tids/@initSid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'target'"/>
               <xsl:attribute name="value" select="string-join($tids/@firstSid,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:if test="$strictVar!=''">
            <xsl:apply-templates mode="SetConstrain" select="$seq">
               <xsl:with-param name="name" select="'critical'"/>
               <xsl:with-param name="value" select="$strictVar"/>
               <xsl:with-param name="basestr" select="'_strctvv'"/>
               <xsl:with-param name="_targetDom_Key" select="$tids/@regionid"/>
            </xsl:apply-templates>
         </xsl:if>
         <xsl:apply-templates mode="FragmentToState" select="$frs">
            <xsl:with-param name="lflid" select="$lflid"/>
            <xsl:with-param name="preP" select="$preP"/>
            <xsl:with-param name="nextP" select="$nextP"/>
            <xsl:with-param name="frids" select="$frids"/>
            <xsl:with-param name="tids" select="$tids"/>
            <xsl:with-param name="upperS" select="$uppers"/>
            <xsl:with-param name="condi" select="''"/>
            <xsl:with-param name="_targetDom_Key" select="$tids/@regionid"/>
         </xsl:apply-templates>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*" mode="OperandToDig">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="preNum"/>
      <xsl:param name="posX"/>
      <xsl:param name="nexttranP"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="iop" select="current()"/>
      <xsl:variable name="cmb" select="'CombinedFragment'"/>
      <xsl:variable name="frs" select="my:GetRecFrag($iop,$lflid)"/>
      <xsl:variable name="frids" select="$frs/@xmi:id"/>
      <xsl:apply-templates mode="FragmentToDig" select="$frs">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$preP"/>
         <xsl:with-param name="nextP" select="$nextP"/>
         <xsl:with-param name="frids" select="$frids"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$upperS"/>
         <xsl:with-param name="preNum" select="$preNum"/>
         <xsl:with-param name="posX" select="$posX"/>
         <xsl:with-param name="baseY" select="20"/>
         <xsl:with-param name="nexttranP" select="$nexttranP"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="ownedBehavior[@xmi:type='uml:Interaction' and lifeline[@name=$transLifelinName]]"
                 mode="LifelineToSD_bak">
      <xsl:param name="subdgm"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="seq" select="current()"/>
      <xsl:variable name="seqnm" select="$seq/@name"/>
      <xsl:variable name="seqid" select="$seq/@xmi:id"/>
      <xsl:variable name="proid" select="$seq/parent::node()/parent::node()/@xmi:id"/>
      <xsl:variable name="lfl" select="$seq/lifeline[@name=$transLifelinName]"/>
      <xsl:variable name="lflid" select="$lfl/@xmi:id"/>
      <xsl:variable name="lflnm" select="$lfl/@name"/>
      <xsl:variable name="basestr" select="'_SD_'"/>
      <xsl:variable name="statenm" select="concat($lflnm,'_StateMachine')"/>
      <xsl:variable name="regionnm" select="concat($statenm,'_Region')"/>
      <xsl:variable name="rprot" select="my:GetRCOSProtocol($proid)"/>
      <xsl:variable name="oldst"
                    select=" if (exists($rprot/@statemachine)) then my:GetObjFromIds($rprot/@statemachine) else null "/>
      <xsl:variable name="oldstdg"
                    select=" if (exists($rprot/@statemachine)) then my:GetModelDiagrams($rprot/@statemachine) else null "/>
      <xsl:variable name="tids" select="my:GetTids($lflid,$seqid,$basestr)"/>
      <xsl:variable name="laststids" select="my:GetIdsFromSt($tids/@lastSid)"/>
      <xsl:variable name="infrag" select="my:CalcuFrag($lflid,$seq)"/>
      <xsl:variable name="inLastStIds" select="my:GetStIds($infrag/@inLastItemId)"/>
      <xsl:variable name="inlastcondi" select="my:GetPreFragCondi($infrag/@inLastItemId)"/>
      <xsl:variable name="lastTrannm"
                    select=" if ($inlastcondi!='') then concat('[',$inlastcondi,']') else '' "/>
      <xsl:variable name="errmess" select="my:CheckSeq($seq,$lflid)"/>
      <xsl:element name="rCOS:Protocol">
         <xsl:attribute name="xmiDiff" select="'resetAtt'"/>
         <xsl:attribute name="targetId" select="$rprot/@xmi:id"/>
         <xsl:attribute name="resetAttName" select="'statemachine'"/>
         <xsl:attribute name="resetAttValue" select="$tids/@stateid"/>
      </xsl:element>
      <xsl:element name="packagedElement">
         <xsl:attribute name="xmi:type" select="'uml:Package'"/>
         <xsl:element name="packagedElement">
            <xsl:attribute name="xmi:type" select="'uml:StateMachine'"/>
            <xsl:attribute name="xmiDiff" select="'insertTo'"/>
            <xsl:attribute name="targetId" select="$proid"/>
            <xsl:attribute name="name" select="$statenm"/>
            <xsl:attribute name="xmi:id" select="$tids/@stateid"/>
            <xsl:element name="region">
               <xsl:attribute name="name" select="$regionnm"/>
               <xsl:attribute name="xmi:id" select="$tids/@regionid"/>
               <xsl:element name="transition">
                  <xsl:attribute name="xmi:id" select="$tids/@firstTrid"/>
                  <xsl:attribute name="name" select="''"/>
                  <xsl:element name="_link_AS_element">
                     <xsl:attribute name="name" select="'source'"/>
                     <xsl:attribute name="value" select="string-join($tids/@initSid,' ')"/>
                  </xsl:element>
                  <xsl:element name="_link_AS_element">
                     <xsl:attribute name="name" select="'target'"/>
                     <xsl:attribute name="value" select="string-join($tids/@firstSid,' ')"/>
                  </xsl:element>
               </xsl:element>
               <xsl:element name="transition">
                  <xsl:attribute name="xmi:id" select="$laststids/@transid"/>
                  <xsl:attribute name="name" select="$lastTrannm"/>
                  <xsl:element name="_link_AS_element">
                     <xsl:attribute name="name" select="'source'"/>
                     <xsl:attribute name="value" select="string-join($inLastStIds/@stid,' ')"/>
                  </xsl:element>
                  <xsl:element name="_link_AS_element">
                     <xsl:attribute name="name" select="'target'"/>
                     <xsl:attribute name="value" select="string-join($tids/@lastSid,' ')"/>
                  </xsl:element>
                  <xsl:if test="$inlastcondi!=''">
                     <xsl:apply-templates mode="SetConstrain" select="$seq">
                        <xsl:with-param name="name" select="'pre'"/>
                        <xsl:with-param name="value" select="$inlastcondi"/>
                        <xsl:with-param name="basestr" select="'_inlastpre'"/>
                        <xsl:with-param name="_targetDom_Key" select="$laststids/@transid"/>
                     </xsl:apply-templates>
                  </xsl:if>
               </xsl:element>
               <xsl:element name="subvertex">
                  <xsl:attribute name="xmi:type" select="'uml:Pseudostate'"/>
                  <xsl:attribute name="xmi:id" select="$tids/@initSid"/>
               </xsl:element>
               <xsl:element name="subvertex">
                  <xsl:attribute name="xmi:type" select="'uml:FinalState'"/>
                  <xsl:attribute name="name" select="'Final'"/>
                  <xsl:attribute name="xmi:id" select="$tids/@lastSid"/>
               </xsl:element>
               <xsl:element name="subvertex">
                  <xsl:attribute name="xmi:type" select="'uml:State'"/>
                  <xsl:attribute name="name" select="'Init'"/>
                  <xsl:attribute name="xmi:id" select="$tids/@firstSid"/>
               </xsl:element>
               <xsl:if test="$errmess=''">
                  <xsl:apply-templates mode="InteractionToVertex" select="$seq">
                     <xsl:with-param name="lflid" select="$lflid"/>
                     <xsl:with-param name="preP" select="$tids/@firstSid"/>
                     <xsl:with-param name="nextP" select="$tids/@lastSid"/>
                     <xsl:with-param name="tids" select="$tids"/>
                     <xsl:with-param name="_targetDom_Key" select="$tids/@regionid"/>
                  </xsl:apply-templates>
               </xsl:if>
            </xsl:element>
         </xsl:element>
      </xsl:element>
      <xsl:if test="exists($rprot/@statemachine)">
         <xsl:apply-templates mode="DelElement" select="$oldst">
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="exists($rprot/@statemachine)">
         <xsl:apply-templates mode="DelElement" select="$oldstdg">
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test=" not($errmess='')">
         <xsl:apply-templates mode="DisplayMessage" select="$lfl">
            <xsl:with-param name="mess" select="$errmess"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="$errmess=''">
         <xsl:apply-templates mode="SDDiagram" select="$subdgm">
            <xsl:with-param name="seq" select="$seq"/>
            <xsl:with-param name="lfl" select="$lfl"/>
            <xsl:with-param name="tids" select="$tids"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='loop']"
                 mode="FragmentToDig">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="preNum"/>
      <xsl:param name="posX"/>
      <xsl:param name="baseY"/>
      <xsl:param name="nexttranP"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="op1" select="$fr/operand"/>
      <xsl:variable name="exp"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes"
                    select="my:CalcuPosDig($preP,$nextP,$frids,$upperS,$cpos,$nexttranP)"/>
      <xsl:variable name="comma" select="','"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="laststids" select="my:GetIdsFromSt($posRes/@newNextP)"/>
      <xsl:variable name="op1frag" select="my:CalcuFrag($lflid,$op1)"/>
      <xsl:variable name="infirstids" select="my:GetStIds($op1frag/@inFirstItemId)"/>
      <xsl:variable name="inlastitem2" select="my:GetStIds($op1frag/@inLastItemId)"/>
      <xsl:variable name="inlaststdgids" select="my:GetDgIds($inlastitem2/@stid)"/>
      <xsl:variable name="xyRes" select="my:CalcuXY($op1frag,$cpos,$preNum,$posX,$baseY,$mid)"/>
      <xsl:variable name="nexttranids" select="my:GetDgIds($posRes/@nexttid)"/>
      <xsl:variable name="preprestids" select="my:GetDgIds($posRes/@newPreP)"/>
      <xsl:variable name="prestids" select="my:GetDgIds($stids/@prestid)"/>
      <xsl:variable name="pretransids" select="my:GetDgIds($stids/@lpretransid)"/>
      <xsl:variable name="gstids" select="my:GetDgIds($stids/@stid)"/>
      <xsl:variable name="transids" select="my:GetDgIds($stids/@transid)"/>
      <xsl:variable name="inLastItemType" select="$op1frag/@inLastItemType"/>
      <xsl:variable name="inFirstItemType" select="$op1frag/@inFirstItemType"/>
      <xsl:variable name="nowinfirsttranid"
                    select=" if ($inFirstItemType='occ') then $infirstids/@transid else $infirstids/@lpretransid "/>
      <xsl:variable name="infirstrantids" select="my:GetDgIds($nowinfirsttranid)"/>
      <xsl:variable name="inlastids" select="my:GetDgIds($stids/@pretransid)"/>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$pretransids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$pretransids"/>
            <xsl:with-param name="fromids" select="$preprestids"/>
            <xsl:with-param name="toids" select="$prestids"/>
            <xsl:with-param name="_targetDom_Key" select="$pretransids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:attribute name="xmi:id" select="$gstids/@dgid"/>
         <xsl:if test="exists('40,30')">
            <xsl:attribute name="size" select="'40,30'"/>
         </xsl:if>
         <xsl:if test="exists($xyRes/@newpos3)">
            <xsl:attribute name="position" select="$xyRes/@newpos3"/>
         </xsl:if>
         <xsl:element name="anchorage">
            <xsl:attribute name="xmi:id" select="$gstids/@anchid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($nexttranids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($infirstrantids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($transids/@dgid,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$fr">
            <xsl:with-param name="dgids" select="$gstids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$gstids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$inlastids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$inlastids"/>
            <xsl:with-param name="fromids" select="$inlaststdgids"/>
            <xsl:with-param name="toids" select="$prestids"/>
            <xsl:with-param name="_targetDom_Key" select="$inlastids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:attribute name="xmi:id" select="$prestids/@dgid"/>
         <xsl:if test="exists('30,30')">
            <xsl:attribute name="size" select="'30,30'"/>
         </xsl:if>
         <xsl:if test="exists($xyRes/@newpos)">
            <xsl:attribute name="position" select="$xyRes/@newpos"/>
         </xsl:if>
         <xsl:element name="anchorage">
            <xsl:attribute name="xmi:id" select="$prestids/@anchid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($pretransids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($inlastids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($transids/@dgid,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$fr">
            <xsl:with-param name="dgids" select="$prestids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$prestids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$transids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$transids"/>
            <xsl:with-param name="fromids" select="$prestids"/>
            <xsl:with-param name="toids" select="$gstids"/>
            <xsl:with-param name="_targetDom_Key" select="$transids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:apply-templates mode="OperandToDig" select="$op1">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$stids/@stid"/>
         <xsl:with-param name="nextP" select="$stids/@prestid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS"/>
         <xsl:with-param name="preNum" select="$preNum"/>
         <xsl:with-param name="posX" select="$xyRes/@newPosX"/>
         <xsl:with-param name="nexttranP" select="$stids/@pretransid"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='opt']"
                 mode="FragmentToState">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="condi"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="op1" select="$fr/operand"/>
      <xsl:variable name="exp"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes" select="my:CalcuPos($preP,$nextP,$frids,$upperS,$cpos)"/>
      <xsl:variable name="prestnm" select="'Choice'"/>
      <xsl:variable name="stnm" select="''"/>
      <xsl:variable name="prestnm" select="''"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="op1frag" select="my:CalcuFrag($lflid,$op1)"/>
      <xsl:variable name="inLastStIds" select="my:GetStIds($op1frag/@inLastItemId)"/>
      <xsl:variable name="allcondi" select="my:GetTranCondi($frids,$cpos,$condi)"/>
      <xsl:variable name="prnTrannm"
                    select=" if ($allcondi!='') then concat('[',$allcondi,']') else '' "/>
      <xsl:variable name="inlastcondi" select="my:GetPreFragCondi($op1frag/@inLastItemId)"/>
      <xsl:variable name="inLastTrannm"
                    select=" if ($inlastcondi!='') then concat('[',$inlastcondi,']') else '' "/>
      <xsl:variable name="notexp" select=" if (exists($exp)) then concat('not(',$exp,')') else '' "/>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@transid"/>
         <xsl:attribute name="name" select="$inLastTrannm"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($inLastStIds/@stid,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@stid,' ')"/>
         </xsl:element>
         <xsl:if test="$inlastcondi!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$inlastcondi"/>
               <xsl:with-param name="basestr" select="'_inlastpre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@transid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:Pseudostate'"/>
         <xsl:attribute name="xmi:id" select="$stids/@prestid"/>
         <xsl:if test="exists('choice')">
            <xsl:attribute name="kind" select="'choice'"/>
         </xsl:if>
         <xsl:attribute name="name" select="''"/>
      </xsl:element>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@ltransid"/>
         <xsl:attribute name="name" select="''"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($stids/@prestid,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@stid,' ')"/>
         </xsl:element>
         <xsl:if test="exists($exp)">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$notexp"/>
               <xsl:with-param name="basestr" select="'_trans2pre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@ltransid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:Pseudostate'"/>
         <xsl:attribute name="xmi:id" select="$stids/@stid"/>
         <xsl:if test="exists('junction')">
            <xsl:attribute name="kind" select="'junction'"/>
         </xsl:if>
         <xsl:attribute name="name" select="''"/>
      </xsl:element>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@lpretransid"/>
         <xsl:attribute name="name" select="$prnTrannm"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@prestid,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($posRes/@newPreP,' ')"/>
         </xsl:element>
         <xsl:if test="$allcondi!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$allcondi"/>
               <xsl:with-param name="basestr" select="'_transpre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@lpretransid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:apply-templates mode="OperandToVertex" select="$op1">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$stids/@prestid"/>
         <xsl:with-param name="nextP" select="$stids/@stid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS"/>
         <xsl:with-param name="condi" select="$exp"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="*" mode="CopyGSemantic">
      <xsl:param name="dgids"/>
      <xsl:param name="pres"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:element name="semanticModel">
         <xsl:attribute name="xsi:type" select="'di:EMFSemanticModelBridge'"/>
         <xsl:attribute name="xmi:id" select="$dgids/@semid"/>
         <xsl:attribute name="presentation" select="$pres"/>
         <xsl:element name="element">
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'href'"/>
               <xsl:attribute name="value"
                              select="string-join(concat($sourceTypedModels[@name='xmiXMI']/@file,'#',$dgids/@id),' ')"/>
            </xsl:element>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*" mode="CreateFinalTransDig">
      <xsl:param name="finalstid"/>
      <xsl:param name="preid"/>
      <xsl:param name="preNum"/>
      <xsl:param name="posX"/>
      <xsl:param name="lflid"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="iop" select="current()"/>
      <xsl:variable name="fstids" select="my:GetIdsFromSt($finalstid)"/>
      <xsl:variable name="prestids" select="my:GetStIds($preid)"/>
      <xsl:variable name="tstids" select="my:GetDgIds($fstids/@stid)"/>
      <xsl:variable name="transids" select="my:GetDgIds($fstids/@transid)"/>
      <xsl:variable name="ltransids" select="my:GetDgIds($fstids/@ltransid)"/>
      <xsl:variable name="sstids" select="my:GetDgIds($prestids/@stid)"/>
      <xsl:variable name="breakid" select="my:GetBreakId($iop,$lflid)"/>
      <xsl:variable name="egids"
                    select=" if ($breakid='') then $transids/@dgid else concat($ltransids/@dgid,' ',$transids/@dgid) "/>
      <xsl:variable name="count" select="$preNum"/>
      <xsl:variable name="newposy" select="$count * 70 + 20"/>
      <xsl:variable name="comma" select="','"/>
      <xsl:variable name="newpos" select="concat($posX,$comma,$newposy)"/>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$transids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$iop">
            <xsl:with-param name="dgids" select="$transids"/>
            <xsl:with-param name="fromids" select="$sstids"/>
            <xsl:with-param name="toids" select="$tstids"/>
            <xsl:with-param name="_targetDom_Key" select="$transids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:attribute name="xmi:id" select="$tstids/@dgid"/>
         <xsl:if test="exists('30,30')">
            <xsl:attribute name="size" select="'30,30'"/>
         </xsl:if>
         <xsl:if test="exists($newpos)">
            <xsl:attribute name="position" select="$newpos"/>
         </xsl:if>
         <xsl:element name="anchorage">
            <xsl:attribute name="xmi:id" select="$tstids/@anchid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($egids,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$iop">
            <xsl:with-param name="dgids" select="$tstids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$tstids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='loop']"
                 mode="FragmentToState">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="condi"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="op1" select="$fr/operand"/>
      <xsl:variable name="exp"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes" select="my:CalcuPos($preP,$nextP,$frids,$upperS,$cpos)"/>
      <xsl:variable name="stnm" select="''"/>
      <xsl:variable name="prestnm" select="''"/>
      <xsl:variable name="prestnm" select="'Junction'"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="op1frag" select="my:CalcuFrag($lflid,$op1)"/>
      <xsl:variable name="inLastStIds" select="my:GetStIds($op1frag/@inLastItemId)"/>
      <xsl:variable name="allcondi" select="my:GetTranCondi($frids,$cpos,$condi)"/>
      <xsl:variable name="prnTrannm"
                    select=" if ($allcondi!='') then concat('[',$allcondi,']') else '' "/>
      <xsl:variable name="inlastcondi" select="my:GetPreFragCondi($op1frag/@inLastItemId)"/>
      <xsl:variable name="inLastTrannm"
                    select=" if ($inlastcondi!='') then concat('[',$inlastcondi,']') else '' "/>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@transid"/>
         <xsl:attribute name="name" select="''"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@stid,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($stids/@prestid,' ')"/>
         </xsl:element>
      </xsl:element>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:Pseudostate'"/>
         <xsl:attribute name="xmi:id" select="$stids/@stid"/>
         <xsl:if test="exists('choice')">
            <xsl:attribute name="kind" select="'choice'"/>
         </xsl:if>
         <xsl:attribute name="name" select="''"/>
      </xsl:element>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@lpretransid"/>
         <xsl:attribute name="name" select="$prnTrannm"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@prestid,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($posRes/@newPreP,' ')"/>
         </xsl:element>
         <xsl:if test="$allcondi!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$allcondi"/>
               <xsl:with-param name="basestr" select="'_transpre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@lpretransid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@pretransid"/>
         <xsl:attribute name="name" select="$inLastTrannm"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($inLastStIds/@stid,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@prestid,' ')"/>
         </xsl:element>
         <xsl:if test="$inlastcondi!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$inlastcondi"/>
               <xsl:with-param name="basestr" select="'_inlastpre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@pretransid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:Pseudostate'"/>
         <xsl:attribute name="xmi:id" select="$stids/@prestid"/>
         <xsl:if test="exists('junction')">
            <xsl:attribute name="kind" select="'junction'"/>
         </xsl:if>
         <xsl:attribute name="name" select="''"/>
      </xsl:element>
      <xsl:apply-templates mode="OperandToVertex" select="$op1">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$stids/@stid"/>
         <xsl:with-param name="nextP" select="$stids/@prestid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS"/>
         <xsl:with-param name="condi" select="$exp"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='assert']"
                 mode="FragmentToState">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="condi"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="op1" select="$fr/operand"/>
      <xsl:variable name="exp"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes" select="my:CalcuPos($preP,$nextP,$frids,$upperS,$cpos)"/>
      <xsl:variable name="prestnm" select="'Choice'"/>
      <xsl:variable name="stnm" select="''"/>
      <xsl:variable name="prestnm" select="''"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="lfl" select="my:GetObjFromIds($lflid)"/>
      <xsl:variable name="lflcls" select="my:GetLifelineType($lfl)"/>
      <xsl:variable name="newseq" select="my:GetEleByDigNm($exp)"/>
      <xsl:variable name="newlfl" select="my:GetLflByType($newseq,$lflcls/@xmi:id)"/>
      <xsl:variable name="newlflid" select="$newlfl/@xmi:id"/>
      <xsl:variable name="op1frag" select="my:CalcuFrag($newlflid,$newseq)"/>
      <xsl:variable name="inLastStIds" select="my:GetStIds($op1frag/@inLastItemId)"/>
      <xsl:variable name="prnTrannm"
                    select=" if ($cpos=1 and $condi!='') then concat('[',$condi,']') else '' "/>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@lpretransid"/>
         <xsl:attribute name="name" select="$prnTrannm"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($posRes/@newPreP,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@prestid,' ')"/>
         </xsl:element>
         <xsl:if test="$cpos=1 and $condi!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$condi"/>
               <xsl:with-param name="basestr" select="'_transpre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@lpretransid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:Pseudostate'"/>
         <xsl:attribute name="xmi:id" select="$stids/@stid"/>
         <xsl:if test="exists('junction')">
            <xsl:attribute name="kind" select="'junction'"/>
         </xsl:if>
         <xsl:attribute name="name" select="''"/>
      </xsl:element>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@transid"/>
         <xsl:attribute name="name" select="''"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@stid,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($inLastStIds/@stid,' ')"/>
         </xsl:element>
      </xsl:element>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:Pseudostate'"/>
         <xsl:attribute name="xmi:id" select="$stids/@prestid"/>
         <xsl:if test="exists('junction')">
            <xsl:attribute name="kind" select="'junction'"/>
         </xsl:if>
         <xsl:attribute name="name" select="''"/>
      </xsl:element>
      <xsl:apply-templates mode="OperandToVertex" select="$newseq">
         <xsl:with-param name="lflid" select="$newlflid"/>
         <xsl:with-param name="preP" select="$stids/@prestid"/>
         <xsl:with-param name="nextP" select="$stids/@stid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS"/>
         <xsl:with-param name="condi" select="''"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:CombinedFragment' and @interactionOperator='assert']"
                 mode="FragmentToDig">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="preNum"/>
      <xsl:param name="posX"/>
      <xsl:param name="baseY"/>
      <xsl:param name="nexttranP"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="op1" select="$fr/operand"/>
      <xsl:variable name="exp"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes"
                    select="my:CalcuPosDig($preP,$nextP,$frids,$upperS,$cpos,$nexttranP)"/>
      <xsl:variable name="comma" select="','"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="laststids" select="my:GetIdsFromSt($posRes/@newNextP)"/>
      <xsl:variable name="lfl" select="my:GetObjFromIds($lflid)"/>
      <xsl:variable name="lflcls" select="my:GetLifelineType($lfl)"/>
      <xsl:variable name="newseq" select="my:GetEleByDigNm($exp)"/>
      <xsl:variable name="newlfl" select="my:GetLflByType($newseq,$lflcls/@xmi:id)"/>
      <xsl:variable name="newlflid" select="$newlfl/@xmi:id"/>
      <xsl:variable name="op1frag" select="my:CalcuFrag($newlflid,$newseq)"/>
      <xsl:variable name="infirstids" select="my:GetStIds($op1frag/@inFirstItemId)"/>
      <xsl:variable name="inlastitem2" select="my:GetStIds($op1frag/@inLastItemId)"/>
      <xsl:variable name="inlaststdgids" select="my:GetDgIds($inlastitem2/@stid)"/>
      <xsl:variable name="xyRes" select="my:CalcuXY($op1frag,$cpos,$preNum,$posX,$baseY,$mid)"/>
      <xsl:variable name="nexttrandgids" select="my:GetDgIds($posRes/@nexttid)"/>
      <xsl:variable name="preprestdgids" select="my:GetDgIds($posRes/@newPreP)"/>
      <xsl:variable name="prestdgids" select="my:GetDgIds($stids/@prestid)"/>
      <xsl:variable name="pretransdgids" select="my:GetDgIds($stids/@lpretransid)"/>
      <xsl:variable name="gstids" select="my:GetDgIds($stids/@stid)"/>
      <xsl:variable name="transdgids" select="my:GetDgIds($stids/@ltransid)"/>
      <xsl:variable name="inLastItemType" select="$op1frag/@inLastItemType"/>
      <xsl:variable name="inFirstItemType" select="$op1frag/@inFirstItemType"/>
      <xsl:variable name="nowinfirsttranid"
                    select=" if ($inFirstItemType='occ') then $infirstids/@transid else $infirstids/@lpretransid "/>
      <xsl:variable name="infirstrantdgids" select="my:GetDgIds($nowinfirsttranid)"/>
      <xsl:variable name="inlastdgids" select="my:GetDgIds($stids/@transid)"/>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$inlastdgids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$inlastdgids"/>
            <xsl:with-param name="fromids" select="$inlaststdgids"/>
            <xsl:with-param name="toids" select="$gstids"/>
            <xsl:with-param name="_targetDom_Key" select="$inlastdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphEdge'"/>
         <xsl:attribute name="xmi:id" select="$pretransdgids/@dgid"/>
         <xsl:apply-templates mode="CopyEdgeProper" select="$fr">
            <xsl:with-param name="dgids" select="$pretransdgids"/>
            <xsl:with-param name="fromids" select="$preprestdgids"/>
            <xsl:with-param name="toids" select="$prestdgids"/>
            <xsl:with-param name="_targetDom_Key" select="$pretransdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:attribute name="xmi:id" select="$gstids/@dgid"/>
         <xsl:if test="exists('30,30')">
            <xsl:attribute name="size" select="'30,30'"/>
         </xsl:if>
         <xsl:if test="exists($xyRes/@newpos3)">
            <xsl:attribute name="position" select="$xyRes/@newpos3"/>
         </xsl:if>
         <xsl:element name="anchorage">
            <xsl:attribute name="xmi:id" select="$gstids/@anchid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($inlastdgids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($nexttrandgids/@dgid,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$fr">
            <xsl:with-param name="dgids" select="$gstids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$gstids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:element name="contained">
         <xsl:attribute name="xsi:type" select="'di:GraphNode'"/>
         <xsl:attribute name="xmi:id" select="$prestdgids/@dgid"/>
         <xsl:if test="exists('40,30')">
            <xsl:attribute name="size" select="'40,30'"/>
         </xsl:if>
         <xsl:if test="exists($xyRes/@newpos)">
            <xsl:attribute name="position" select="$xyRes/@newpos"/>
         </xsl:if>
         <xsl:element name="anchorage">
            <xsl:attribute name="xmi:id" select="$prestdgids/@anchid"/>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($infirstrantdgids/@dgid,' ')"/>
            </xsl:element>
            <xsl:element name="_link_AS_element">
               <xsl:attribute name="name" select="'graphEdge'"/>
               <xsl:attribute name="value" select="string-join($pretransdgids/@dgid,' ')"/>
            </xsl:element>
         </xsl:element>
         <xsl:apply-templates mode="CopyGSemantic" select="$fr">
            <xsl:with-param name="dgids" select="$prestdgids"/>
            <xsl:with-param name="pres" select="'default'"/>
            <xsl:with-param name="_targetDom_Key" select="$prestdgids/@dgid"/>
         </xsl:apply-templates>
      </xsl:element>
      <xsl:apply-templates mode="OperandToDig" select="$newseq">
         <xsl:with-param name="lflid" select="$newlflid"/>
         <xsl:with-param name="preP" select="$stids/@prestid"/>
         <xsl:with-param name="nextP" select="$stids/@stid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS"/>
         <xsl:with-param name="preNum" select="$preNum"/>
         <xsl:with-param name="posX" select="$xyRes/@newPosX"/>
         <xsl:with-param name="nexttranP" select="$stids/@transid"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="ownedBehavior[@xmi:type='uml:Interaction' and lifeline[@name=$transLifelinName]]"
                 mode="LifelineToSD">
      <xsl:param name="subdgm"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="seq" select="current()"/>
      <xsl:variable name="seqnm" select="$seq/@name"/>
      <xsl:variable name="seqid" select="$seq/@xmi:id"/>
      <xsl:variable name="lfl" select="$seq/lifeline[@name=$transLifelinName]"/>
      <xsl:variable name="lflid" select="$lfl/@xmi:id"/>
      <xsl:variable name="lflnm" select="$lfl/@name"/>
      <xsl:variable name="proid" select="$seq/parent::node()/parent::node()/@xmi:id"/>
      <xsl:variable name="basestr" select="'_SD_'"/>
      <xsl:variable name="statenm" select="concat($lflnm,'_StateMachine')"/>
      <xsl:variable name="rprot" select="my:GetRCOSProtocol($proid)"/>
      <xsl:variable name="oldst"
                    select=" if (exists($rprot/@statemachine)) then my:GetObjFromIds($rprot/@statemachine) else null "/>
      <xsl:variable name="oldstdg"
                    select=" if (exists($rprot/@statemachine)) then my:GetModelDiagrams($rprot/@statemachine) else null "/>
      <xsl:variable name="tids" select="my:GetTids($lflid,$seqid,$basestr)"/>
      <xsl:variable name="errmess" select="my:CheckSeq($seq,$lflid)"/>
      <xsl:element name="packagedElement">
         <xsl:attribute name="xmi:type" select="'uml:Package'"/>
         <xsl:element name="packagedElement">
            <xsl:attribute name="xmi:type" select="'uml:StateMachine'"/>
            <xsl:attribute name="xmiDiff" select="'insertTo'"/>
            <xsl:attribute name="targetId" select="$proid"/>
            <xsl:attribute name="name" select="$statenm"/>
            <xsl:attribute name="xmi:id" select="$tids/@stateid"/>
            <xsl:if test="$errmess=''">
               <xsl:apply-templates mode="InteractionToVertex" select="$seq">
                  <xsl:with-param name="lflid" select="$lflid"/>
                  <xsl:with-param name="preP" select="$tids/@firstSid"/>
                  <xsl:with-param name="nextP" select="$tids/@lastSid"/>
                  <xsl:with-param name="tids" select="$tids"/>
                  <xsl:with-param name="parentStnm" select="$statenm"/>
                  <xsl:with-param name="strictVar" select="''"/>
                  <xsl:with-param name="_targetDom_Key" select="$tids/@stateid"/>
               </xsl:apply-templates>
            </xsl:if>
         </xsl:element>
      </xsl:element>
      <xsl:element name="rCOS:Protocol">
         <xsl:attribute name="xmiDiff" select="'resetAtt'"/>
         <xsl:attribute name="targetId" select="$rprot/@xmi:id"/>
         <xsl:attribute name="resetAttName" select="'statemachine'"/>
         <xsl:attribute name="resetAttValue" select="$tids/@stateid"/>
      </xsl:element>
      <xsl:if test="exists($rprot/@statemachine)">
         <xsl:apply-templates mode="DelElement" select="$oldst">
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="exists($rprot/@statemachine)">
         <xsl:apply-templates mode="DelElement" select="$oldstdg">
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test=" not($errmess='')">
         <xsl:apply-templates mode="DisplayMessage" select="$lfl">
            <xsl:with-param name="mess" select="$errmess"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="$errmess=''">
         <xsl:apply-templates mode="SDDiagram" select="$subdgm">
            <xsl:with-param name="seq" select="$seq"/>
            <xsl:with-param name="lfl" select="$lfl"/>
            <xsl:with-param name="tids" select="$tids"/>
            <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
         </xsl:apply-templates>
      </xsl:if>
   </xsl:template>
   <xsl:template match="*" mode="SetConstrain">
      <xsl:param name="name"/>
      <xsl:param name="value"/>
      <xsl:param name="basestr"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="uid" select="current()/@xmi:id"/>
      <xsl:variable name="consid" select="my:GetNewId($uid,5,$basestr)"/>
      <xsl:variable name="valueid" select="my:GetNewId($uid,7,$basestr)"/>
      <xsl:element name="ownedRule">
         <xsl:attribute name="name" select="$name"/>
         <xsl:attribute name="xmi:id" select="$consid"/>
         <xsl:element name="specification">
            <xsl:attribute name="xmi:type" select="'uml:LiteralString'"/>
            <xsl:attribute name="value" select="$value"/>
            <xsl:attribute name="xmi:id" select="$valueid"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="fragment[@xmi:type='uml:CombinedFragment']" mode="FragmentToState"
                 priority="-10">
      <xsl:param name="lflid"/>
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="tids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="condi"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:variable name="fr" select="current()"/>
      <xsl:variable name="mid" select="$fr/@xmi:id"/>
      <xsl:variable name="frop" select="$fr/@interactionOperator"/>
      <xsl:variable name="op1" select="$fr/operand"/>
      <xsl:variable name="iop" select="$fr/parent::node()"/>
      <xsl:variable name="cpos" select="position()"/>
      <xsl:variable name="posRes" select="my:CalcuPos($preP,$nextP,$frids,$upperS,$cpos)"/>
      <xsl:variable name="prestnm" select="'Choice'"/>
      <xsl:variable name="stnm" select="''"/>
      <xsl:variable name="prestnm" select="''"/>
      <xsl:variable name="stids" select="my:GetStIds($mid)"/>
      <xsl:variable name="op1frag" select="my:CalcuFrag($lflid,$op1)"/>
      <xsl:variable name="inLastStIds" select="my:GetStIds($op1frag/@inLastItemId)"/>
      <xsl:variable name="allcondi" select="my:GetTranCondi($frids,$cpos,$condi)"/>
      <xsl:variable name="prnTrannm"
                    select=" if ($allcondi!='') then concat('[',$allcondi,']') else '' "/>
      <xsl:variable name="inlastcondi" select="my:GetPreFragCondi($op1frag/@inLastItemId)"/>
      <xsl:variable name="inLastTrannm"
                    select=" if ($inlastcondi!='') then concat('[',$inlastcondi,']') else '' "/>
      <xsl:variable name="strictvar1" select="concat('_critical',$upperS,'=ON')"/>
      <xsl:variable name="strictvar2" select="concat('_critical',$upperS,'=OFF')"/>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:Pseudostate'"/>
         <xsl:attribute name="xmi:id" select="$stids/@stid"/>
         <xsl:if test="exists('junction')">
            <xsl:attribute name="kind" select="'junction'"/>
         </xsl:if>
         <xsl:attribute name="name" select="''"/>
         <xsl:if test="$frop='critical'">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'critical'"/>
               <xsl:with-param name="value" select="$strictvar2"/>
               <xsl:with-param name="basestr" select="'_strct2btvv'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@stid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@transid"/>
         <xsl:attribute name="name" select="$inLastTrannm"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($inLastStIds/@stid,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@stid,' ')"/>
         </xsl:element>
         <xsl:if test="$inlastcondi!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$inlastcondi"/>
               <xsl:with-param name="basestr" select="'_inlastpre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@transid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:Pseudostate'"/>
         <xsl:attribute name="xmi:id" select="$stids/@prestid"/>
         <xsl:if test="exists('junction')">
            <xsl:attribute name="kind" select="'junction'"/>
         </xsl:if>
         <xsl:attribute name="name" select="''"/>
         <xsl:if test="$frop='critical'">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'critical'"/>
               <xsl:with-param name="value" select="$strictvar1"/>
               <xsl:with-param name="basestr" select="'_strct1btvv'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@prestid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:element name="transition">
         <xsl:attribute name="xmi:id" select="$stids/@lpretransid"/>
         <xsl:attribute name="name" select="$prnTrannm"/>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'source'"/>
            <xsl:attribute name="value" select="string-join($posRes/@newPreP,' ')"/>
         </xsl:element>
         <xsl:element name="_link_AS_element">
            <xsl:attribute name="name" select="'target'"/>
            <xsl:attribute name="value" select="string-join($stids/@prestid,' ')"/>
         </xsl:element>
         <xsl:if test="$allcondi!=''">
            <xsl:apply-templates mode="SetConstrain" select="$fr">
               <xsl:with-param name="name" select="'pre'"/>
               <xsl:with-param name="value" select="$allcondi"/>
               <xsl:with-param name="basestr" select="'_transpre'"/>
               <xsl:with-param name="_targetDom_Key" select="$stids/@lpretransid"/>
            </xsl:apply-templates>
         </xsl:if>
      </xsl:element>
      <xsl:apply-templates mode="OperandToVertex" select="$op1">
         <xsl:with-param name="lflid" select="$lflid"/>
         <xsl:with-param name="preP" select="$stids/@prestid"/>
         <xsl:with-param name="nextP" select="$stids/@stid"/>
         <xsl:with-param name="tids" select="$tids"/>
         <xsl:with-param name="upperS" select="$posRes/@newUpperS"/>
         <xsl:with-param name="condi" select="''"/>
         <xsl:with-param name="_targetDom_Key" select="$_targetDom_Key"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="//xmi:XMI[rCOS:ComponentModel[my:xmiXMIrefs(@base_Package)[@xmi:type='uml:Package']]]"
                 mode="RootTrans">
      <xsl:variable name="sr" select="current()"/>
      <xsl:variable name="comm"
                    select="my:xmiXMIrefs($sr/rCOS:ComponentModel/@base_Package)[@xmi:type='uml:Package']"/>
      <xsl:variable name="commid" select="$comm/@xmi:id"/>
      <xsl:variable name="umm" select="$comm/parent::node()"/>
      <xsl:variable name="umn" select="$umm/@name"/>
      <xsl:variable name="umid" select="$umm/@xmi:id"/>
      <xsl:variable name="diagmodel" select="my:GetTypedModel('digamDIAGRAM','')"/>
      <xsl:variable name="_targetDom_Key" select="''"/>
      <xsl:element name="xmi:XMI">
         <xsl:element name="uml:Model">
            <xsl:attribute name="name" select="$umn"/>
            <xsl:attribute name="xmi:id" select="$umid"/>
            <xsl:element name="packagedElement">
               <xsl:attribute name="xmi:type" select="'uml:Package'"/>
               <xsl:attribute name="xmi:id" select="$commid"/>
               <xsl:apply-templates mode="DiagNameToSeq" select="$diagmodel">
                  <xsl:with-param name="commid" select="$commid"/>
                  <xsl:with-param name="umid" select="$umid"/>
                  <xsl:with-param name="_targetDom_Key" select="$commid"/>
               </xsl:apply-templates>
            </xsl:element>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <xsl:template match="xmi:XMI[rCOS:ComponentModel[my:xmiXMIrefs(@base_Package)[@xmi:type='uml:Package']]]"
                 mode="_func_RootTrans">
      <xsl:variable name="sr" select="current()"/>
      <xsl:variable name="comm"
                    select="my:xmiXMIrefs($sr/rCOS:ComponentModel/@base_Package)[@xmi:type='uml:Package']"/>
      <xsl:variable name="commid" select="$comm/@xmi:id"/>
      <xsl:variable name="umm" select="$comm/parent::node()"/>
      <xsl:variable name="umn" select="$umm/@name"/>
      <xsl:variable name="umid" select="$umm/@xmi:id"/>
      <xsl:variable name="diagmodel" select="my:GetTypedModel('digamDIAGRAM','')"/>
      <xsl:element name="xmi:XMI"/>
   </xsl:template>
   <xsl:template match="*" mode="CreateState">
      <xsl:param name="stid"/>
      <xsl:param name="stnm"/>
      <xsl:param name="_targetDom_Key"/>
      <xsl:element name="subvertex">
         <xsl:attribute name="xmi:type" select="'uml:State'"/>
         <xsl:attribute name="name" select="$stnm"/>
         <xsl:attribute name="xmi:id" select="$stid"/>
      </xsl:element>
   </xsl:template>
   <xsl:function name="my:GetLifelineType">
      <xsl:param name="lfl"/>
      <xsl:variable name="result"
                    select="my:xmiXMIrefs(my:xmiXMIrefs($lfl/@represents)[name()='ownedAttribute']/@type)"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:CalcuLfTrace">
      <xsl:param name="iop"/>
      <xsl:param name="lflid"/>
      <xsl:param name="trace"/>
      <xsl:variable name="msg" select="'MessageOccurrenceSpecification'"/>
      <xsl:variable name="cmb" select="'CombinedFragment'"/>
      <xsl:variable name="frs" select="my:GetRecFrag($iop,$lflid)"/>
      <xsl:variable name="fr" select="$frs[1]"/>
      <xsl:variable name="leftfrs" select="$frs[ not(@xmi:id=$fr/@xmi:id)]"/>
      <xsl:variable name="result" select="my:GetTrace($fr,$lflid,$leftfrs,$trace)"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetRecMessOcc">
      <xsl:param name="iop"/>
      <xsl:param name="lflid"/>
      <xsl:variable name="result"
                    select="my:xmiXMIrefs(my:xmiXMIrefs($iop/fragment[@xmi:type='uml:MessageOccurrenceSpecification']/@message)[name()='message']/@receiveEvent)[@xmi:type='uml:MessageOccurrenceSpecification'][@xmi:type='uml:MessageOccurrenceSpecification' and my:xmiXMIrefs(@covered)[name()='lifeline' and @xmi:id=$lflid]]"/>
      <xsl:variable name="lfid" select="$result/@covered"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetOccTrace">
      <xsl:param name="fr"/>
      <xsl:param name="lflid"/>
      <xsl:param name="leftfrs"/>
      <xsl:param name="trace"/>
      <xsl:variable name="op"
                    select="my:xmiXMIrefs(my:xmiXMIrefs($fr/@event)[@xmi:type='uml:CallEvent']/@operation)[name()='ownedOperation']"/>
      <xsl:variable name="opid" select="$op/@xmi:id"/>
      <xsl:variable name="opnm" select="$op/@name"/>
      <xsl:variable name="cma" select=" if ($trace[1]='') then '' else  ',' "/>
      <xsl:variable name="newtrace" select="(for $tr in $trace return concat($tr,$cma,$opnm))"/>
      <xsl:variable name="newfr" select="$leftfrs[1]"/>
      <xsl:variable name="newleftfrs" select="$leftfrs[ not(@xmi:id=$newfr/@xmi:id)]"/>
      <xsl:variable name="result"
                    select=" if (exists($newfr)) then my:GetTrace($newfr,$lflid,$newleftfrs,$newtrace) else $newtrace "/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetRecFrag">
      <xsl:param name="iop"/>
      <xsl:param name="lflid"/>
      <xsl:variable name="frs" select="$iop/fragment"/>
      <xsl:variable name="msg" select="'MessageOccurrenceSpecification'"/>
      <xsl:variable name="cmb" select="'CombinedFragment'"/>
      <xsl:variable name="sdfrs" select="my:GetSendMessOcc($iop,$lflid)"/>
      <xsl:variable name="queryfrs" select="my:GetQueryMessOcc($iop,$lflid)"/>
      <xsl:variable name="sdqfrs" select="insert-before($sdfrs, count($sdfrs)+1, $queryfrs)"/>
      <xsl:variable name="result"
                    select="$frs[my:xmiXMIrefs(@covered)[name()='lifeline']/@xmi:id=$lflid][substring-after(@xmi:type,'uml:')=$msg or substring-after(@xmi:type,'uml:')=$cmb][ not(@xmi:id=$sdqfrs/@xmi:id)]"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetLifelineByNm">
      <xsl:param name="seq"/>
      <xsl:param name="lfnm"/>
      <xsl:variable name="result" select="$seq/lifeline[@name=$lfnm]"/>
      <xsl:variable name="nm" select="$result/@name"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetBreakId">
      <xsl:param name="iop"/>
      <xsl:param name="lflid"/>
      <xsl:variable name="brks"
                    select="$iop//fragment[@xmi:type='uml:CombinedFragment'][@interactionOperator='break']"/>
      <xsl:variable name="brk"
                    select="$brks[my:xmiXMIrefs(@covered)[name()='lifeline']/@xmi:id=$lflid]"/>
      <xsl:variable name="result" select=" if (exists($brk)) then $brk/@xmi:id[1] else '' "/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetRCOSProtocol">
      <xsl:param name="proid"/>
      <xsl:variable name="result"
                    select="$xmiXMI//rCOS:Protocol[my:xmiXMIrefs(@base_Package)[@xmi:type='uml:Package' and @xmi:id=$proid]]"/>
      <xsl:variable name="pid" select="$result/@base_Package"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetTrace">
      <xsl:param name="fr"/>
      <xsl:param name="lflid"/>
      <xsl:param name="leftfrs"/>
      <xsl:param name="trace"/>
      <xsl:variable name="msg" select="'MessageOccurrenceSpecification'"/>
      <xsl:variable name="cmb" select="'CombinedFragment'"/>
      <xsl:variable name="result"
                    select=" if (substring-after($fr/@xmi:type,'uml:')=$cmb) then my:GetCmbTrace($fr,$lflid,$leftfrs,$trace) else my:GetOccTrace($fr,$lflid,$leftfrs,$trace) "/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetQueryMessOcc">
      <xsl:param name="iop"/>
      <xsl:param name="lflid"/>
      <xsl:variable name="result"
                    select="$iop//fragment[@xmi:type='uml:MessageOccurrenceSpecification'][@xmi:type='uml:MessageOccurrenceSpecification' and my:xmiXMIrefs(@event)[@xmi:type='uml:CallEvent' and my:xmiXMIrefs(@operation)[name()='ownedOperation' and @isQuery='true']] and my:xmiXMIrefs(@covered)[name()='lifeline' and @xmi:id=$lflid]]"/>
      <xsl:variable name="lfid" select="$result/@covered"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetLflByType">
      <xsl:param name="seq"/>
      <xsl:param name="typeid"/>
      <xsl:variable name="result"
                    select="$seq/lifeline[my:xmiXMIrefs(@represents)[name()='ownedAttribute' and my:xmiXMIrefs(@type)[@xmi:id=$typeid]]]"/>
      <xsl:variable name="clsid"
                    select="my:xmiXMIrefs($result/@represents)[name()='ownedAttribute']/@type"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetSendMessOcc">
      <xsl:param name="iop"/>
      <xsl:param name="lflid"/>
      <xsl:variable name="result"
                    select="my:xmiXMIrefs(my:xmiXMIrefs($iop/fragment[@xmi:type='uml:MessageOccurrenceSpecification']/@message)[name()='message']/@sendEvent)[@xmi:type='uml:MessageOccurrenceSpecification'][@xmi:type='uml:MessageOccurrenceSpecification' and my:xmiXMIrefs(@covered)[name()='lifeline' and @xmi:id=$lflid]]"/>
      <xsl:variable name="lfid" select="$result/@covered"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetAllRecFrag">
      <xsl:param name="iop"/>
      <xsl:param name="lflid"/>
      <xsl:variable name="frs" select="$iop//fragment"/>
      <xsl:variable name="msg" select="'MessageOccurrenceSpecification'"/>
      <xsl:variable name="cmb" select="'CombinedFragment'"/>
      <xsl:variable name="sdfrs" select="my:GetAllSendMessOcc($iop,$lflid)"/>
      <xsl:variable name="queryfrs" select="my:GetQueryMessOcc($iop,$lflid)"/>
      <xsl:variable name="sdqfrs" select="insert-before($sdfrs, count($sdfrs)+1, $queryfrs)"/>
      <xsl:variable name="result"
                    select="$frs[my:xmiXMIrefs(@covered)[name()='lifeline']/@xmi:id=$lflid][substring-after(@xmi:type,'uml:')=$msg or substring-after(@xmi:type,'uml:')=$cmb][ not(@xmi:id=$sdqfrs/@xmi:id)]"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetAllSendMessOcc">
      <xsl:param name="iop"/>
      <xsl:param name="lflid"/>
      <xsl:variable name="result"
                    select="my:xmiXMIrefs(my:xmiXMIrefs($iop//fragment[@xmi:type='uml:MessageOccurrenceSpecification']/@message)[name()='message']/@sendEvent)[@xmi:type='uml:MessageOccurrenceSpecification'][@xmi:type='uml:MessageOccurrenceSpecification' and my:xmiXMIrefs(@covered)[name()='lifeline' and @xmi:id=$lflid]]"/>
      <xsl:variable name="lfid" select="$result/@covered"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetRefedAllFrag">
      <xsl:param name="fr"/>
      <xsl:param name="lflid"/>
      <xsl:variable name="op1" select="$fr/operand"/>
      <xsl:variable name="exp"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="lfl" select="my:GetObjFromIds($lflid)"/>
      <xsl:variable name="lflcls" select="my:GetLifelineType($lfl)"/>
      <xsl:variable name="newseq" select="my:GetEleByDigNm($exp)"/>
      <xsl:variable name="newlfl" select="my:GetLflByType($newseq,$lflcls/@xmi:id)"/>
      <xsl:variable name="newlflid" select="$newlfl/@xmi:id"/>
      <xsl:variable name="frs" select="my:GetAllRecFrag($newseq,$newlflid)"/>
      <xsl:variable name="ffrs" select="(for $fr in $frs return my:DoFileterFrag($fr,$newlflid))"/>
      <xsl:variable name="result" select="insert-before($fr, count($fr)+1, $ffrs)"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetCmbGuard">
      <xsl:param name="fr"/>
      <xsl:variable name="op1" select="$fr/operand[1]"/>
      <xsl:variable name="result"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString'][@xmi:type='uml:LiteralString']/@value"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetEleByDigNm">
      <xsl:param name="dignm"/>
      <xsl:variable name="subdgm" select="$digamDIAGRAM//subdiagrams"/>
      <xsl:variable name="dgm" select="$subdgm/diagrams[@name=$dignm]"/>
      <xsl:variable name="dgmnm" select="$dgm/@name"/>
      <xsl:variable name="result"
                    select="my:GetTypedModel('xmiXMI',$dgm/semanticModel[@xsi:type='di:EMFSemanticModelBridge']/element/@href)[1][1]"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetCmbTrace">
      <xsl:param name="fr"/>
      <xsl:param name="lflid"/>
      <xsl:param name="leftfrs"/>
      <xsl:param name="trace"/>
      <xsl:variable name="optor" select="$fr/@interactionOperator"/>
      <xsl:variable name="op1" select="$fr/operand[1]"/>
      <xsl:variable name="exp"
                    select="$op1/guard/specification[@xmi:type='uml:LiteralString']/@value"/>
      <xsl:variable name="op2" select="$fr/operand[2]"/>
      <xsl:variable name="intrace" select="my:CalcuLfTrace($op1,$lflid,$trace)"/>
      <xsl:variable name="intrace2"
                    select=" if (exists($op2)) then my:CalcuLfTrace($op2,$lflid,$trace) else $trace "/>
      <xsl:variable name="newtrace"
                    select=" if ($optor='seq') then $intrace else insert-before($intrace, count($intrace)+1, $intrace2) "/>
      <xsl:variable name="newfr" select="$leftfrs[1]"/>
      <xsl:variable name="newleftfrs" select="$leftfrs[ not(@xmi:id=$newfr/@xmi:id)]"/>
      <xsl:variable name="result"
                    select=" if (exists($newfr)) then my:GetTrace($newfr,$lflid,$newleftfrs,$newtrace) else $newtrace "/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetFragIds">
      <xsl:param name="iop"/>
      <xsl:param name="lflid"/>
      <xsl:variable name="msg" select="'MessageOccurrenceSpecification'"/>
      <xsl:variable name="cmb" select="'CombinedFragment'"/>
      <xsl:variable name="sdfrs" select="my:GetSendMessOcc($iop,$lflid)"/>
      <xsl:variable name="frs"
                    select="$iop/fragment[my:xmiXMIrefs(@covered)[name()='lifeline']/@xmi:id=$lflid][substring-after(@xmi:type,'uml:')=$msg or substring-after(@xmi:type,'uml:')=$cmb][ not(@xmi:id=$sdfrs/@xmi:id)]"/>
      <xsl:variable name="result" select="$frs/@xmi:id"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:CalcuNextTranId">
      <xsl:param name="nid"/>
      <xsl:variable name="fr" select="my:GetObjFromIds($nid)"/>
      <xsl:variable name="ids" select="my:GetStIds($nid)"/>
      <xsl:variable name="cmb" select="'CombinedFragment'"/>
      <xsl:variable name="frType"
                    select=" if (substring-after($fr/@xmi:type,'uml:')=$cmb) then $fr/@interactionOperator else 'occ' "/>
      <xsl:variable name="result"
                    select=" if ($frType='break' or $frType='par' or $frType='occ') then $ids/@transid else $ids/@lpretransid "/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:CalcuNextId">
      <xsl:param name="nid"/>
      <xsl:variable name="fr" select="my:GetObjFromIds($nid)"/>
      <xsl:variable name="ids" select="my:GetStIds($nid)"/>
      <xsl:variable name="msg" select="'MessageOccurrenceSpecification'"/>
      <xsl:variable name="result"
                    select=" if (substring-after($fr/@xmi:type,'uml:')=$msg or $fr/@interactionOperator='break' or $fr/@interactionOperator='par') then $ids/@stid else $ids/@prestid "/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:CheckSeq">
      <xsl:param name="seq"/>
      <xsl:param name="lflid"/>
      <xsl:variable name="msg" select="'MessageOccurrenceSpecification'"/>
      <xsl:variable name="cmb" select="'CombinedFragment'"/>
      <xsl:variable name="allfrs1" select="my:GetAllRecFrag($seq,$lflid)"/>
      <xsl:variable name="allfrs"
                    select="(for $fr in $allfrs1 return my:DoFileterFrag($fr,$lflid))"/>
      <xsl:variable name="opers"
                    select="(for $fr in $allfrs[substring-after(@xmi:type,'uml:')=$cmb and @interactionOperator!='assert'] return $fr/operand)"/>
      <xsl:variable name="empopers" select="$opers[empty(fragment)]"/>
      <xsl:variable name="empcmberror"
                    select=" if (exists($empopers)) then 'There are empty combine fragments. ' else '' "/>
      <xsl:variable name="result" select="$empcmberror"/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:CalcuPosDig">
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="cpos"/>
      <xsl:param name="nexttranP"/>
      <xsl:variable name="pos" select="$cpos + 1"/>
      <xsl:variable name="nid" select="$frids[$pos]"/>
      <xsl:variable name="prepos" select="$cpos  -  1"/>
      <xsl:variable name="preid" select="$frids[$prepos]"/>
      <xsl:variable name="newPreP"
                    select=" if (exists($preid)) then my:GetNewId($preid,2,'SD') else $preP "/>
      <xsl:variable name="newNextP"
                    select=" if (exists($nid)) then my:CalcuNextId($nid) else $nextP "/>
      <xsl:variable name="newUpperS" select="concat($upperS,'_',$cpos)"/>
      <xsl:variable name="laststids" select="my:GetIdsFromSt($newNextP)"/>
      <xsl:variable name="nexttid"
                    select=" if (exists($nid)) then my:CalcuNextTranId($nid) else $nexttranP "/>
      <xsl:variable name="hasNid" select=" if (exists($nid)) then 'true' else 'false' "/>
      <xsl:variable name="result" as="element()*">
         <xsl:element name="Tuple">
            <xsl:attribute name="newPreP" select="$newPreP"/>
            <xsl:attribute name="newNextP" select="$newNextP"/>
            <xsl:attribute name="newUpperS" select="$newUpperS"/>
            <xsl:attribute name="nexttid" select="$nexttid"/>
            <xsl:attribute name="nid" select="$nid"/>
            <xsl:attribute name="preid" select="$preid"/>
            <xsl:attribute name="hasNid" select="$hasNid"/>
         </xsl:element>
      </xsl:variable>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetDgIds">
      <xsl:param name="id1"/>
      <xsl:variable name="sufix" select="'_SDG_'"/>
      <xsl:variable name="id" select="$id1"/>
      <xsl:variable name="dgid" select="my:GetNewId($id1,7,$sufix)"/>
      <xsl:variable name="semid" select="my:GetNewId($id1,8,$sufix)"/>
      <xsl:variable name="anch1id" select="my:GetNewId($id1,9,$sufix)"/>
      <xsl:variable name="anch2id" select="my:GetNewId($id1,10,$sufix)"/>
      <xsl:variable name="anchid" select="my:GetNewId($id1,11,$sufix)"/>
      <xsl:variable name="propid" select="my:GetNewId($id1,5,$sufix)"/>
      <xsl:variable name="offsetid" select="my:GetNewId($id1,6,$sufix)"/>
      <xsl:variable name="result" as="element()*">
         <xsl:element name="Tuple">
            <xsl:attribute name="id" select="$id"/>
            <xsl:attribute name="dgid" select="$dgid"/>
            <xsl:attribute name="semid" select="$semid"/>
            <xsl:attribute name="anch1id" select="$anch1id"/>
            <xsl:attribute name="anch2id" select="$anch2id"/>
            <xsl:attribute name="propid" select="$propid"/>
            <xsl:attribute name="offsetid" select="$offsetid"/>
            <xsl:attribute name="anchid" select="$anchid"/>
         </xsl:element>
      </xsl:variable>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:CalcuXY">
      <xsl:param name="opfrag"/>
      <xsl:param name="cpos"/>
      <xsl:param name="preNum"/>
      <xsl:param name="posX"/>
      <xsl:param name="baseY"/>
      <xsl:param name="frid"/>
      <xsl:variable name="comma" select="','"/>
      <xsl:variable name="abspos" select="index-of($preNum,$frid)"/>
      <xsl:variable name="count" select="$abspos + 1"/>
      <xsl:variable name="newposy" select="$count * 70 + $baseY"/>
      <xsl:variable name="newpos" select="concat($posX,$comma,$newposy)"/>
      <xsl:variable name="newPosX" select="$posX  -  200"/>
      <xsl:variable name="ccount" select="$opfrag/@countAll"/>
      <xsl:variable name="newPosY2" select="$ccount * 70 + $newposy"/>
      <xsl:variable name="newpos2" select="concat($newPosX,$comma,$newPosY2)"/>
      <xsl:variable name="newPosX2" select="$posX + 200"/>
      <xsl:variable name="ccount2" select="$opfrag/@countAll"/>
      <xsl:variable name="newPosY22" select="$ccount2 * 70 + $newposy"/>
      <xsl:variable name="newpos3" select="concat($posX,$comma,$newPosY22)"/>
      <xsl:variable name="comPosX" select="$posX  -  300"/>
      <xsl:variable name="composY" select="$newposy  -  30"/>
      <xsl:variable name="comstpos" select="concat($comPosX,$comma,$composY)"/>
      <xsl:variable name="comPosY22" select="$newPosY22  -  50"/>
      <xsl:variable name="count3" select=" if ($ccount2&lt;4) then $ccount2 + 2 else $ccount2 "/>
      <xsl:variable name="comsizeyy" select="$count3 * 70 + 50"/>
      <xsl:variable name="comstsize" select="concat('600',$comma,$comsizeyy)"/>
      <xsl:variable name="result" as="element()*">
         <xsl:element name="Tuple">
            <xsl:attribute name="newposy" select="$newposy"/>
            <xsl:attribute name="newpos" select="$newpos"/>
            <xsl:attribute name="newPosX" select="$newPosX"/>
            <xsl:attribute name="newpos2" select="$newpos2"/>
            <xsl:attribute name="newPosX2" select="$newPosX2"/>
            <xsl:attribute name="newpos3" select="$newpos3"/>
            <xsl:attribute name="comstpos" select="$comstpos"/>
            <xsl:attribute name="comstsize" select="$comstsize"/>
         </xsl:element>
      </xsl:variable>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:DoFileterFrag">
      <xsl:param name="fr"/>
      <xsl:param name="lflid"/>
      <xsl:variable name="result"
                    select=" if ($fr/@interactionOperator='assert') then my:GetRefedAllFrag($fr,$lflid) else $fr "/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetPreFragCondi">
      <xsl:param name="preid"/>
      <xsl:variable name="msg" select="'MessageOccurrenceSpecification'"/>
      <xsl:variable name="cmb" select="'CombinedFragment'"/>
      <xsl:variable name="prefrag" select="my:GetObjFromIds($preid)"/>
      <xsl:variable name="exp"
                    select=" if (substring-after($prefrag/@xmi:type,'uml:')=$cmb and ( $prefrag/@interactionOperator='loop' or $prefrag/@interactionOperator='break' )) then my:GetCmbGuard($prefrag) else '' "/>
      <xsl:variable name="result"
                    select=" if (exists($exp) and $exp!='') then concat('not(',$exp,')') else '' "/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetIdsFromSt">
      <xsl:param name="stid"/>
      <xsl:variable name="transid" select="my:GetNewId($stid,3,'SD')"/>
      <xsl:variable name="ltransid" select="my:GetNewId($stid,3,'SD_l')"/>
      <xsl:variable name="triid" select="my:GetNewId($stid,4,'SD')"/>
      <xsl:variable name="result" as="element()*">
         <xsl:element name="Tuple">
            <xsl:attribute name="stid" select="$stid"/>
            <xsl:attribute name="transid" select="$transid"/>
            <xsl:attribute name="ltransid" select="$ltransid"/>
            <xsl:attribute name="triid" select="$triid"/>
         </xsl:element>
      </xsl:variable>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetModelDiagrams">
      <xsl:param name="modelId"/>	<xsl:variable name="refid" select="concat($sourceTypedModels[1]/@file,'#',$modelId)"/>	
	
	<xsl:sequence select="$digamDIAGRAM//subdiagrams[model[@href=$refid]]"/></xsl:function>
   <xsl:function name="my:GetStIds">
      <xsl:param name="mid"/>
      <xsl:variable name="stid" select="my:GetNewId($mid,2,'SD')"/>
      <xsl:variable name="prestid" select="my:GetNewId($mid,2,'SD_p')"/>
      <xsl:variable name="transid" select="my:GetNewId($stid,3,'SD')"/>
      <xsl:variable name="pretransid" select="my:GetNewId($prestid,3,'SD')"/>
      <xsl:variable name="ltransid" select="my:GetNewId($stid,3,'SD_l')"/>
      <xsl:variable name="lpretransid" select="my:GetNewId($prestid,3,'SD_l')"/>
      <xsl:variable name="triid" select="my:GetNewId($stid,4,'SD')"/>
      <xsl:variable name="regstid" select="my:GetNewId($stid,5,'SD')"/>
      <xsl:variable name="reg1id" select="my:GetNewId($stid,6,'SD_r1')"/>
      <xsl:variable name="reg2id" select="my:GetNewId($stid,6,'SD_r2')"/>
      <xsl:variable name="result" as="element()*">
         <xsl:element name="Tuple">
            <xsl:attribute name="stid" select="$stid"/>
            <xsl:attribute name="prestid" select="$prestid"/>
            <xsl:attribute name="transid" select="$transid"/>
            <xsl:attribute name="pretransid" select="$pretransid"/>
            <xsl:attribute name="ltransid" select="$ltransid"/>
            <xsl:attribute name="lpretransid" select="$lpretransid"/>
            <xsl:attribute name="triid" select="$triid"/>
            <xsl:attribute name="regstid" select="$regstid"/>
            <xsl:attribute name="reg1id" select="$reg1id"/>
            <xsl:attribute name="reg2id" select="$reg2id"/>
         </xsl:element>
      </xsl:variable>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:CalcuTotalFrag">
      <xsl:param name="op1"/>
      <xsl:param name="op2"/>
      <xsl:variable name="count1" select="$op1/@countAll"/>
      <xsl:variable name="count2" select="$op2/@countAll"/>
      <xsl:variable name="countAll" select="$count1 + $count2 + 0"/>
      <xsl:variable name="result" as="element()*">
         <xsl:element name="Tuple">
            <xsl:attribute name="count1" select="$count1"/>
            <xsl:attribute name="count2" select="$count2"/>
            <xsl:attribute name="countAll" select="$countAll"/>
         </xsl:element>
      </xsl:variable>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:CalcuFrag">
      <xsl:param name="lflid"/>
      <xsl:param name="op"/>
      <xsl:variable name="msg" select="'MessageOccurrenceSpecification'"/>
      <xsl:variable name="cmb" select="'CombinedFragment'"/>
      <xsl:variable name="op1allfrag" select="my:GetAllRecFrag($op,$lflid)"/>
      <xsl:variable name="op1frag" select="my:GetRecFrag($op,$lflid)"/>
      <xsl:variable name="inLastItem" select="$op1frag[last()]"/>
      <xsl:variable name="inFirstItem" select="$op1frag[1]"/>
      <xsl:variable name="inLastItemId" select="$inLastItem/@xmi:id"/>
      <xsl:variable name="inFirstItemId" select="$inFirstItem/@xmi:id"/>
      <xsl:variable name="inLastItemType1"
                    select=" if (substring-after($inLastItem/@xmi:type,'uml:')=$cmb) then $inLastItem/@interactionOperator else 'occ' "/>
      <xsl:variable name="inFirstItemType1"
                    select=" if (substring-after($inFirstItem/@xmi:type,'uml:')=$cmb) then $inFirstItem/@interactionOperator else 'occ' "/>
      <xsl:variable name="inLastItemType"
                    select=" if ($inLastItemType1='break' or $inLastItemType1='par') then 'occ' else $inLastItemType1 "/>
      <xsl:variable name="inFirstItemType"
                    select=" if ($inFirstItemType1='break' or $inFirstItemType1='par') then 'occ' else $inFirstItemType1 "/>
      <xsl:variable name="count" select="count($op1frag)"/>
      <xsl:variable name="countAll" select="count($op1allfrag)"/>
      <xsl:variable name="result" as="element()*">
         <xsl:element name="Tuple">
            <xsl:attribute name="inFirstItemId" select="$inFirstItemId"/>
            <xsl:attribute name="inLastItemId" select="$inLastItemId"/>
            <xsl:attribute name="count" select="$count"/>
            <xsl:attribute name="countAll" select="$countAll"/>
            <xsl:attribute name="inLastItemType" select="$inLastItemType"/>
            <xsl:attribute name="inFirstItemType" select="$inFirstItemType"/>
         </xsl:element>
      </xsl:variable>
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
   <xsl:function name="my:GetTids">
      <xsl:param name="id1"/>
      <xsl:param name="id2"/>
      <xsl:param name="sufix"/>
      <xsl:variable name="stateid" select="my:GetNewId($id1,2,$sufix)"/>
      <xsl:variable name="regionid" select="my:GetNewId($id1,3,$sufix)"/>
      <xsl:variable name="firstSid" select="my:GetNewId($id1,4,$sufix)"/>
      <xsl:variable name="lastSid" select="my:GetNewId($id1,5,$sufix)"/>
      <xsl:variable name="initSid" select="my:GetNewId($id1,6,$sufix)"/>
      <xsl:variable name="firstTrid" select="my:GetNewId($id1,7,$sufix)"/>
      <xsl:variable name="rifdgid" select="my:GetNewId($id2,3,$sufix)"/>
      <xsl:variable name="iniconsid" select="my:GetNewId($id2,4,$sufix)"/>
      <xsl:variable name="iniconvalid" select="my:GetNewId($id2,5,$sufix)"/>
      <xsl:variable name="result" as="element()*">
         <xsl:element name="Tuple">
            <xsl:attribute name="stateid" select="$stateid"/>
            <xsl:attribute name="regionid" select="$regionid"/>
            <xsl:attribute name="firstSid" select="$firstSid"/>
            <xsl:attribute name="lastSid" select="$lastSid"/>
            <xsl:attribute name="initSid" select="$initSid"/>
            <xsl:attribute name="firstTrid" select="$firstTrid"/>
            <xsl:attribute name="iniconsid" select="$iniconsid"/>
            <xsl:attribute name="iniconvalid" select="$iniconvalid"/>
         </xsl:element>
      </xsl:variable>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:GetTranCondi">
      <xsl:param name="frids"/>
      <xsl:param name="cpos"/>
      <xsl:param name="condi"/>
      <xsl:variable name="prepos" select="$cpos  -  1"/>
      <xsl:variable name="preid" select="$frids[$prepos]"/>
      <xsl:variable name="preCondi"
                    select=" if (exists($preid)) then my:GetPreFragCondi($preid) else '' "/>
      <xsl:variable name="result" select=" if ($cpos=1 and $condi!='') then $condi else $preCondi "/>
      <xsl:sequence select="$result"/>
   </xsl:function>
   <xsl:function name="my:CalcuPos">
      <xsl:param name="preP"/>
      <xsl:param name="nextP"/>
      <xsl:param name="frids"/>
      <xsl:param name="upperS"/>
      <xsl:param name="cpos"/>
      <xsl:variable name="pos" select="$cpos + 1"/>
      <xsl:variable name="nid" select="$frids[$pos]"/>
      <xsl:variable name="prepos" select="$cpos  -  1"/>
      <xsl:variable name="preid" select="$frids[$prepos]"/>
      <xsl:variable name="newPreP"
                    select=" if (exists($preid)) then my:GetNewId($preid,2,'SD') else $preP "/>
      <xsl:variable name="newNextP"
                    select=" if (exists($nid)) then my:CalcuNextId($nid) else $nextP "/>
      <xsl:variable name="newUpperS" select="concat($upperS,'_',$cpos)"/>
      <xsl:variable name="newUpperS2" select="concat($upperS,'-',$cpos)"/>
      <xsl:variable name="laststids" select="my:GetIdsFromSt($newNextP)"/>
      <xsl:variable name="nexttid"
                    select=" if (exists($nid)) then my:CalcuNextTranId($nid) else $laststids/@transid "/>
      <xsl:variable name="hasNid" select=" if (exists($nid)) then 'true' else 'false' "/>
      <xsl:variable name="result" as="element()*">
         <xsl:element name="Tuple">
            <xsl:attribute name="newPreP" select="$newPreP"/>
            <xsl:attribute name="newNextP" select="$newNextP"/>
            <xsl:attribute name="newUpperS" select="$newUpperS"/>
            <xsl:attribute name="newUpperS2" select="$newUpperS2"/>
            <xsl:attribute name="nexttid" select="$nexttid"/>
            <xsl:attribute name="nid" select="$nid"/>
            <xsl:attribute name="preid" select="$preid"/>
            <xsl:attribute name="hasNid" select="$hasNid"/>
         </xsl:element>
      </xsl:variable>
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
   <xsl:function name="my:digamDIAGRAMrefs">
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
      <xsl:sequence select="$digamDIAGRAM//*[@xmi:id=$vvvv/child::node()]"/>
   </xsl:function>
   <xsl:function name="my:GetTypedModel">
      <xsl:param name="modelnm"/>
      <xsl:param name="xmiid"/>
      <xsl:variable name="iid"
                    select="if (contains($xmiid,'#')) then substring-after($xmiid,'#') else $xmiid"/>
      <xsl:choose>
         <xsl:when test="$modelnm='xmiXMI'">
            <xsl:sequence select="if (string-length($xmiid)&gt;0) then $xmiXMI//*[@xmi:id=$iid] else $xmiXMI/*"/>
         </xsl:when>
         <xsl:when test="$modelnm='digamDIAGRAM'">
            <xsl:sequence select="if (string-length($xmiid)&gt;0) then $digamDIAGRAM//*[@xmi:id=$iid] else $digamDIAGRAM/*"/>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
</xsl:stylesheet>