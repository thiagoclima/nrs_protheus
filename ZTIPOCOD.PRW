#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} zTipoCod
Gatilho para preencher o cÛdigo a partir do tipo de produto
@author Totvs
@since 10.q0.2022
/*/
User Function zTipoCod()
	Local aArea     := GetArea()
	Local cCodigo   := ""
	Local cTipoPrd  := FWFldGet("B1_TIPO")
	Local cSQL      := ''
	Local cTRB      := ''

	cSQL := " SELECT MAX(B1_COD) AS B1_COD  FROM "+RetSQLName('SB1')
	cSQL += " WHERE B1_FILIAL = '" + FWxFilial('SB1') + "' "
	cSQL += " AND B1_TIPO = '" + cTipoPrd + "' "

	cTRB := GetNextAlias()
	cSQL := ChangeQuery( cSQL )

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cTRB,.F.,.T.)

	(cTRB)->( DbGoTop() )
	cCodigo := AllTrim(cTipoPrd)+Padl(AllTrim(Str(Val(Substr((cTRB)->B1_COD,3,7))+1)),7,"0")
	(cTRB)->( dbCloseArea() )

	RestArea(aArea)
Return cCodigo
