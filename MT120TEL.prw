//Bibliotecas
#Include "Protheus.ch"
  
 /*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  MT120TEL                                                                                              |
 | Desc:  Ponto de Entrada para adicionar campos no cabeçalho do pedido de compra                               |
 | Link:  http://tdn.totvs.com/display/public/mp/MT120TEL                                                       |
 *--------------------------------------------------------------------------------------------------------------*/
 
User Function MT120TEL()
    Local aArea     := GetArea()
    Local oDlg      := PARAMIXB[1] 
    Local aPosGet   := PARAMIXB[2]
    Local nOpcx     := PARAMIXB[4]
    Local lEdit     := IIF(nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  9, .F., .F.)
    Local oXObsAux
    Public cXObsAux := POSICIONE("SY1",3,XFILIAL("SY1")+SC7->C7_USER,"Y1_NOME")

 
    //Criando na janela o campo OBS
    @ 062, aPosGet[1,08] - 012 SAY Alltrim(RetTitle("C7_XNOMECM")) OF oDlg PIXEL SIZE 050,006
    @ 061, aPosGet[1,09] - 006 MSGET oXObsAux VAR cXObsAux SIZE 100, 006 OF oDlg COLORS 0, 16777215  PIXEL
    oXObsAux:bHelp := {|| ShowHelpCpo( "C7_XNOMECM", {GetHlpSoluc("C7_XNOMECM")[1]}, 5  )}

    //Se não houver edição, desabilita os gets
    If !lEdit
        oXObsAux:lActive := .F.
    EndIf
 
    RestArea(aArea)
Return
