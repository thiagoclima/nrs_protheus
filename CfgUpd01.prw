#Include "totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CFGUPD01  ³Autor  ³Henio Brasil        ³ Data ³ 07/02/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Programa de Manutencao de Casas Decimais do Dicionario de   º±±
±±º          ³Dados.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºModelo    ³Muriel Cosmeticos                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºVr. 1.01  ³1. A partir de 3 tabelas TXT contendo tabelas, campos       º±±
±±º          ³2.                                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDireitos  ³PPTi Consulting Services                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function CFGUPD01()

	Local i
	Local cEmp
	Local cFil
	Local cCampos	:= ""
	Local lMsgShow1	:= .F.
	Local cRootPath	:= GetSrvProfString("RootPath", "")
	Local cTexto 	:= 	"Este programa atualiza o dicionário de dados do Protheus "+;
						"quanto aos seus campos numéricos. É necessário acesso exclusivo ao sistema "+;
						"e a existência de 3 arquivos (tabelas.txt, valor.txt e quantidade.txt) numa "+;
						"pasta C:\Temp\ na estação executora dessa rotina."+Chr(10)+;
						"Confirma a execução?"
	Private aStru	:={}
	Private aTables	:={}
	Private aValor	:={}
	Private aQuant	:={}

	If !MsgYesNo(cTexto)
		Return
	Endif

	If !File("C:\Temp\Tabelas.txt")
		MsgStop("Não foi possivel encontrar as tabelas modelo para executar a manutenção!")
		Return
	Endif

	If !File("C:\Temp\ValorUnit.txt")
		MsgStop("Não foi possivel encontrar as tabelas modelo para executar a manutenção!")
		Return
	Endif

	If !File("C:\Temp\Quantidade.txt")
		MsgStop("Não foi possivel encontrar as tabelas modelo para executar a manutenção!")
		Return
	Endif

	// Base com menos campos
	Processa({|| aTables:= UpdLoadArray("C:\Temp\Tabelas.txt")}		,"Lendo tabelas")
	Processa({|| aValor	:= UpdLoadArray("C:\Temp\ValorUnit.txt")}	,"Campos de Valores")
	Processa({|| aQuant	:= UpdLoadArray("C:\Temp\Quantidade.txt")}	,"Campos de Quantidade")
	/*
	Processa({|| aTables:= UpdLoadArray(cRootPath+"\Estrutura\Tabelas.txt")}		,"Lendo tabelas")
	Processa({|| aValor	:= UpdLoadArray(cRootPath+"\Estrutura\ValorUnit.txt")}	,"Campos de Valores")
	Processa({|| aQuant	:= UpdLoadArray(cRootPath+"\Estrutura\Quantidade.txt")}	,"Campos de Quantidade")	*/


	// Seleciona a Empresa/Filial
	UpdChoiceEmp(@cEmp,@cFil)
	If !MsgYesNo("Confirma atualização da empresa "+cEmp+"/"+cFil+"?")
		Return
	Endif

	// Roda o processo de Atualizacao
	Processa({|| RpcSetEnv(cEmp,cFil)},"Aguarde! Abrindo Empresa.")
	If Len(aValor)>0.and.Len(aQuant)>0
		UpdMadeEst(@aStru,aValor[1],aQuant[1])
		If Len(aStru)==0
			MsgStop("O vetor <aStru> esta em branco.")
			Return
		Endif
	Else
		MsgStop("Não foi gerado lista de campos para alterar.  Verifique se os arquivos existem.")
		Return
	Endif
	If(lMsgShow1, MsgStop("Passou bem pela funcao UPDMADEEST... com tamanho do aStru: "+Str(Len(aStru),5) ), .T.)

	DbSelectArea('SX3')
	SX3->(DbSetOrder(2))
	For i:=1 to Len(aValor)
		SX3->(DbSeek(Padr(aValor[i],10)))
		If SX3->(Found())
			RecLock("SX3",.f.)
			SX3->X3_TAMANHO:=aStru[1,1]
			SX3->X3_DECIMAL:=aStru[1,2]
			SX3->X3_PICTURE:=aStru[1,3]
			SX3->(MsUnlock())
		Else
			cCampos+="Campo não encontrado - "+aValor[i]+CRLF
		Endif
	Next
	For i:=1 to Len(aQuant)
		SX3->(DbSeek(Padr(aQuant[i],10)))
		If SX3->(Found())
			RecLock("SX3",.f.)
			SX3->X3_TAMANHO:=aStru[2,1]
			SX3->X3_DECIMAL:=aStru[2,2]
			SX3->X3_PICTURE:=aStru[2,3]
			SX3->(MsUnlock())
			//Conout("Campo "+aValor[i])
		Else
			cCampos+="Campo não encontrado - "+aQuant[i]+CRLF
		Endif
	Next

	Processa({|| UpdAlterTab(aTables)},"Alterando Estruturas")

	MsgAlert("CfgUpd01 - Processo Concluido... "+CRLF+cCampos)
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UpdAlterTab ³Autor  ³Henio Brasil       ³ Data ³ 07/02/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDireitos  ³PPTi Consulting Services                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
// Static Function Me03ReadXls(aParam)
Static Function UpdAlterTab(aTables)

	Local i
	ProcRegua(Len(aTables))
	For i:=1 to Len(aTables)
		X31UPDTABLE(aTables[i])
		IncProc(aTables[i])
	Next
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UpdLoadArray³Autor  ³Henio Brasil       ³ Data ³ 07/02/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDireitos  ³PPTi Consulting Services                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function UpdLoadArray(cArq)

	Local aArray	:= {}
	Local cTexto	:= ''
	Local cTexto1	:= ''

	FT_FUSE(cArq)
	ProcRegua(FT_FLASTREC())
	While !FT_FEOF()
		cTexto1	:= FT_FREADLN()
		cTexto2	:= AllTrim(Left(cTexto,At(" ",cTexto)))
		IncProc()
		aAdd(aArray,cTexto1)
		FT_FSKIP()
	End
	FT_FUSE()

Return aArray

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UpdChoiceEmp³Autor  ³Henio Brasil       ³ Data ³ 07/02/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDireitos  ³PPTi Consulting Services                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function UpdChoiceEmp(cEmp,cFil)

	Local oDlg
	Local aEmpFil	:= {}
	Local aEmp		:= {}
	Local aFil		:= {}
	Local aNome		:= {}
	Local nList		:= 1
	/*
	DbUseArea(.T.,"DBFCDX","/SYSTEM/SIGAMAT.EMP","ZZZ",.f.,.f.)
	dbUseArea(.T., , "SIGAMAT.EMP", "SM0", lShared, .F.)
	DbUseArea(.T.,,"/SYSTEM/SIGAMAT.EMP","EMP",.T.,.F.)
	DbSetIndex("/SYSTEM/SIGAMAT.IND")
	*/
	//_nRcSM0 := SM0->(Recno())
	DbSelectArea('SM0')
	While SM0->(!Eof())
		aAdd(aEmpFil,SM0->M0_CODIGO+"-"+SM0->M0_CODFIL+":"+SM0->M0_NOME+"/"+SM0->M0_FILIAL)
		AADD(aEmp,SM0->M0_CODIGO)
		AADD(aFil,SM0->M0_CODFIL)
		SM0->(DbSkip())
	End
	SM0->(DbGoTop())
	//SM0->(DbGoTo(_nRcSM0))

	Define MsDialog oDlg fROM 0,0 to 200,400 Title "Escolha uma Empresa/Filial" Pixel
	@ 05,05 ListBox nList Items aEmpFil Of oDlg Pixel Size 190,50
	Define Sbutton from 70,150 Type 1 Enable of oDlg Pixel Action oDlg:End()
	Activate MsDialog oDlg Centered
	//ZZZ->(DbCloseArea())
	cEmp:=aEmp[nList]
	cFil:=aFil[nList]
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UpdMadeEst  ³Autor  ³Henio Brasil       ³ Data ³ 07/02/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDireitos  ³PPTi Consulting Services                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function UpdMadeEst(aStru,cValor,cQtd)

	Local nTam1		:= TamSx3(cValor)[1]
	Local nTam2		:= TamSx3(cQtd)[1]
	Local nDec1		:= TamSx3(cValor)[2]
	Local nDec2 	:= TamSx3(cQtd)[2]
	Local cPict1	:= X3Picture(cValor)
	Local cPict2	:= X3Picture(cQtd)
	Local lMsgShow2	:= .F.
	Local oDlg

	If Empty(cValor)
		MsgStop("Não temos estrutura definida no momento!","Manutenção Decimais")
		Return
	Endif

	Define MsDialog oDlg Title "Campos Numéricos" From 0,0 to 360,600 Pixel

	@ 05,05 Say "Valores:" of oDlg Pixel
	@ 15,05 Say "Tamanho:" of oDlg Pixel
	@ 14,30 MsGet nTam1 of oDlg Pixel Picture "99" Valid nTam1>0.and.nTam1<=18
	@ 30,05 Say "Decimal:" of oDlg Pixel
	@ 29,30 MsGet nDec1 of oDlg Pixel Picture "99" Valid nDec1<=(nTam1-2)
	@ 45,05 Say "Mascara:" of oDlg Pixel
	@ 44,30 MsGet cPict1 of oDlg Pixel Size 100,10

	@ 75,05 Say "Quantidades:" of oDlg Pixel
	@ 90,05 Say "Tamanho:" of oDlg Pixel
	@ 89,30 MsGet nTam2 of oDlg Pixel Picture "99" Valid nTam2>0.and.nTam2<=18
	@ 105,05 Say "Decimal:" of oDlg Pixel
	@ 104,30 MsGet nDec2 of oDlg Pixel Picture "99" Valid nDec2<=(nTam2-2)
	@ 120,05 Say "Mascara:" of oDlg Pixel Size 100,10
	@ 119,30 MsGet cPict2 of oDlg Pixel

	Define sButton From 140,170 Type 1 Enable of oDlg Pixel Action oDlg:End()
	Activate MsDialog oDlg Centered

	Aadd(aStru,{nTam1,nDec1,cPict1})
	Aadd(aStru,{nTam2,nDec2,cPict2})
	If(lMsgShow2, MsgAlert("tamanho vetor < aStru > : "+Str(Len(aStru))), .T. )
Return