INICIAL
RAMA1



*********************************************************************************************************************
* Trigger de indicadores CORTASSA
* Si falla el INSERT que actualiza RWS_LOGS se almacena el mismo en una tabla DBI con la
* misma estructura que RWS_LOGS y con la siguiente nomenclatura de nombre "rws_logs_usr_" + ALLTRIM(m.Noma) + ".dbi"
*********************************************************************************************************************
LPARAMETERS tcTabla, tcTrigger, tcEmpresa, tlAsincro, tuClave
*********************************************************************************************************************
* tcTabla   : Tabla que va a enviar información a la web
* tcTrigger : Tipo de trigger( I,U ó D)
* tcEmpresa : Empresa desde donde se envía la información
* tlAsincro	: Envío asincrónico de datos
* tuClave	: Clave a buscar en caso de delete asincrónicos
*********************************************************************************************************************

IF .NOT. (TYPE("m.EsSincroni") = "L" .AND. m.EsSincroni) .AND. .NOT. (TYPE("m.glEsPreseaOffline") = "L" .AND. m.glEsPreseaOffline) .AND.;
   .NOT. (TYPE("m.glEsPreseaTicket") = "L" .AND. m.glEsPreseaTicket) .AND. .NOT. (TYPE("m.glEsOtroEjecutable") = "L" .AND. m.glEsOtroEjecutable);
   .AND. (TYPE("nMenu1")="N" .AND. m.nMenu1 <> 2476 .AND. m.nMenu1 <> 139 .AND. m.nMenu1 <> 1161)

	LOCAL lnAreaAnterior, lcCadenaInsert, lcPkey, lcURL, lcVarRWS

	m.lcCadenaInsert 	= ""
	m.lnAreaAnterior 	= SELECT(0)
	plErrorConexion  	= .F.
	plErrorPath      	= .F. 
	m.plAsincronico    	= .F.
	m.tcTabla 			= ALLTRIM(m.tcTabla)

	IF UPPER(ALLTRIM(PROGRAM(1))) <> "SINCRONI" .AND. (VARTYPE(m.gcRWSVar_SINBUS) <> "L" .OR. .NOT. m.gcRWSVar_SINBUS)

		SET DATE TO JAPAN

		TRY 
		
		IF m.nMenu1 = 0 .OR. VARTYPE(m.gcRWSVar_BUSACTIVO) <> "L" .OR. .NOT. m.gcRWSVar_BUSACTIVO
			=rws_set1()
		ENDIF 
		
		* Sincronizador apagado manualmente
		= rws_verificar_conexion()
		
		IF .NOT. plErrorPath .AND. VARTYPE(noma) = "C" .AND. .NOT. EMPTY(m.Noma)
			* Verifico el tema del AUTOMATA para hacer asincrónicas las tablas
			IF TXNLEVEL() > 0 .OR. m.Noma = "AUTOMATA" .OR. (VARTYPE(m.aAutoma) = "L" .AND. m.aAutoma)
				m.plAsincronico = .NOT. tlAsincro
			ENDIF 

			DO CASE 
				CASE UPPER(m.tcTabla) == "STOCK_DE" .AND. JUSTSTEM(DBF()) = "STOCK_DE" .AND. DEPOSITO=100
					m.lcPkey = STR(EMPRESA,5)+STR(CODIGO,15)+STR(DEPOSITO,12)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("STOCK_DE")
							m.lcURL = m.gcRWSVar_URLU + "stock_de0"
						
						CASE m.tcTrigger = "I"
							m.lcCadenaInsert = traer_cadena_insert("STOCK_DE")
							m.lcURL = m.gcRWSVar_URLI + "stock_de0"
						
						OTHERWISE   
							m.lcCadenaInsert = "empresa=|" + ALLTRIM(STR(empresa, 5)) + "&|codigo=|" + ALLTRIM(STR(codigo,15)) + "&|deposito=|" + ALLTRIM(STR(deposito, 12))
							m.lcURL = m.gcRWSVar_URLD + "stock_de0"
							m.tlAsincro = .T.
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_STOCK_DE

					* Envío asincronico por errores de reintento
					m.plAsincronico = .NOT. tlAsincro

				CASE UPPER(m.tcTabla) == "DEPOSITO" .AND. JUSTSTEM(DBF()) = "DEPOSITO"
					m.lcPkey = STR(codigo, 12)		
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("DEPOSITO")
							m.lcURL = m.gcRWSVar_URLU + "deposito0"
						
						CASE m.tcTrigger = "I"
							m.lcCadenaInsert = traer_cadena_insert("DEPOSITO")
							m.lcURL = m.gcRWSVar_URLI + "deposito0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(codigo, 12))
							else	
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(m.tuClave, 12))
								m.lcPkey = STR(m.tuClave,12)
							endif
							m.lcURL = m.gcRWSVar_URLD + "deposito0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_DEPOSITO

				CASE UPPER(m.tcTabla) == "RELACION" .AND. JUSTSTEM(DBF()) = "RELACION"
					m.lcPkey = STR(id_rws, 12)		
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("RELACION")
							m.lcURL = m.gcRWSVar_URLU + "relacion0"
						
						CASE m.tcTrigger = "I"
							m.lcCadenaInsert = traer_cadena_insert("RELACION")
							m.lcURL = m.gcRWSVar_URLI + "relacion0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "id_rws=|" + ALLTRIM(STR(id_rws, 12))
							else	
								m.lcCadenaInsert = "id_rws=|" + ALLTRIM(STR(m.tuClave, 12))
								m.lcPkey = STR(m.tuClave,12)
							endif
							m.lcURL = m.gcRWSVar_URLD + "relacion0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_RELACION

				CASE UPPER(m.tcTabla) == "GUIATRAN" .AND. JUSTSTEM(DBF()) = "GUIATRAN"
					m.lcPkey = STR(remito, 12)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("GUIATRAN")
							m.lcURL = m.gcRWSVar_URLU + "guiatran0"
						
						CASE m.tcTrigger = "I"
							m.lcCadenaInsert = traer_cadena_insert("GUIATRAN")
							m.lcURL = m.gcRWSVar_URLI + "guiatran0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "remito=|" + ALLTRIM(STR(remito, 12))
							else	
								m.lcCadenaInsert = "remito=|" + ALLTRIM(STR(m.tuClave, 12))
								m.lcPkey = STR(m.tuClave,12)
							endif
							m.lcURL = m.gcRWSVar_URLD + "guiatran0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_GUIATRAN

				CASE UPPER(m.tcTabla) == "DESEOSSC" .AND. JUSTSTEM(DBF()) = "DESEOSSC"
					m.lcPkey = STR(id_rws, 12)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("DESEOSSC")
							m.lcURL = m.gcRWSVar_URLU + "deseossc0"
						
						CASE m.tcTrigger = "I"
							m.lcCadenaInsert = traer_cadena_insert("DESEOSSC")
							m.lcURL = m.gcRWSVar_URLI + "deseossc0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "id_rws=|" + ALLTRIM(STR(id_rws, 12))
							else	
								m.lcCadenaInsert = "id_rws=|" + ALLTRIM(STR(m.tuClave, 12))
								m.lcPkey = STR(m.tuClave,12)
							endif
							m.lcURL = m.gcRWSVar_URLD + "deseossc0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_DESEOSSC

				CASE UPPER(m.tcTabla) == "DTOPROD" .AND. JUSTSTEM(DBF()) = "DTOPROD"
					m.lcPkey = STR(id_rws, 12)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("DTOPROD")
							m.lcURL = m.gcRWSVar_URLU + "dtoprod0"
						
						CASE m.tcTrigger = "I"
							m.lcCadenaInsert = traer_cadena_insert("DTOPROD")
							m.lcURL = m.gcRWSVar_URLI + "dtoprod0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "id_rws=|" + ALLTRIM(STR(id_rws, 12))
							else	
								m.lcCadenaInsert = "id_rws=|" + ALLTRIM(STR(m.tuClave, 12))
								m.lcPkey = STR(m.tuClave,12)
							endif
							m.lcURL = m.gcRWSVar_URLD + "dtoprod0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_DTOPROD
							
					* Envío asincronico por errores de reintento
					m.plAsincronico = .NOT. tlAsincro

				CASE UPPER(m.tcTabla) == "PROVEEDO" .AND. JUSTSTEM(DBF()) = "PROVEEDO"
					m.lcPkey = STR(codigo, 6)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("PROVEEDO")
							m.lcURL = m.gcRWSVar_URLU + "proveedo0"
						
						CASE m.tcTrigger = "I"
							m.lcCadenaInsert = traer_cadena_insert("PROVEEDO")
							m.lcURL = m.gcRWSVar_URLI + "proveedo0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(codigo, 6))
							else	
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(m.tuClave, 6))
								m.lcPkey = STR(m.tuClave, 6)
							endif
							m.lcURL = m.gcRWSVar_URLD + "proveedo0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_PROVEEDO
			
				CASE UPPER(m.tcTabla) == "CODBARRA" .AND. JUSTSTEM(DBF()) = "CODBARRA"
					m.lcPkey = STR(coddun14, 14)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("CODBARRA")
							m.lcURL = m.gcRWSVar_URLU + "codbarra0"
						
						CASE m.tcTrigger = "I"
							m.lcCadenaInsert = traer_cadena_insert("CODBARRA")
							m.lcURL = m.gcRWSVar_URLI + "codbarra0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "coddun14=|" + ALLTRIM(STR(coddun14, 14))
							else	
								m.lcCadenaInsert = "coddun14=|" + ALLTRIM(STR(m.tuClave, 14))
								m.lcPkey = STR(m.tuClave,14)
							endif
							m.lcURL = m.gcRWSVar_URLD + "codbarra0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_CODBARRA

				CASE UPPER(m.tcTabla) == "DOMICILI" .AND. JUSTSTEM(DBF()) = "DOMICILI"
					m.lcPkey = codigo
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("DOMICILI")
							m.lcURL = m.gcRWSVar_URLU + "domicili0"
						
						CASE m.tcTrigger = "I"
							m.lcCadenaInsert = traer_cadena_insert("DOMICILI")
							m.lcURL = m.gcRWSVar_URLI + "domicili0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(codigo)
							else	
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(m.tuClave)
								m.lcPkey = STR(m.tuClave,14)
							endif
							m.lcURL = m.gcRWSVar_URLD + "domicili0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_DOMICILI
			
				CASE UPPER(m.tcTabla) == "RUBRO_CL" .AND. JUSTSTEM(DBF()) = "RUBRO_CL"
					m.lcPkey = STR(codigo, 6)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("RUBRO_CL")
							m.lcURL = m.gcRWSVar_URLU + "rubro_cl0"
						
						CASE m.tcTrigger = "I"
							m.lcCadenaInsert = traer_cadena_insert("RUBRO_CL")
							m.lcURL = m.gcRWSVar_URLI + "rubro_cl0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(codigo, 6))
							else	
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(m.tuClave, 6))
								m.lcPkey = STR(m.tuClave, 6)
							endif
							m.lcURL = m.gcRWSVar_URLD + "rubro_cl0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_RUBRO_CL
				
				CASE UPPER(m.tcTabla) == "REFER_CL" .AND. JUSTSTEM(DBF()) = "REFER_CL"
					m.lcPkey = STR(codigo, 6)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("REFER_CL")
							m.lcURL = m.gcRWSVar_URLU + "refer_cl0"
						
						CASE m.tcTrigger = "I"
							m.lcCadenaInsert = traer_cadena_insert("REFER_CL")
							m.lcURL = m.gcRWSVar_URLI + "refer_cl0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(codigo, 6))
							else	
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(m.tuClave, 6))
								m.lcPkey = STR(m.tuClave, 6)
							endif
							m.lcURL = m.gcRWSVar_URLD + "refer_cl0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_REFER_CL
			
				CASE UPPER(m.tcTabla) == "MED_COB" .AND. JUSTSTEM(DBF()) = "MED_COB"
					m.lcPkey = STR(cod_med, 3)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("MED_COB")
							m.lcURL = m.gcRWSVar_URLU + "med_cob0"
						
						CASE m.tcTrigger = "I"
							m.lcCadenaInsert = traer_cadena_insert("MED_COB")
							m.lcURL = m.gcRWSVar_URLI + "med_cob0"
						
						OTHERWISE   
							m.lcCadenaInsert = "cod_med=|" + ALLTRIM(STR(cod_med, 3))
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "cod_med=|" + ALLTRIM(STR(cod_med, 3))
							else	
								m.lcCadenaInsert = "cod_med=|" + ALLTRIM(STR(m.tuClave, 3))
								m.lcPkey = STR(m.tuClave, 3)
							endif
							m.lcURL = m.gcRWSVar_URLD + "med_cob0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_MED_COB

				CASE UPPER(m.tcTabla) == "MOVIMIEN" .AND. JUSTSTEM(DBF()) = "MOVIMIEN" .AND. CODIGOCOMP=38
					m.lcPkey = STR(EMPRESA,5)+STR(CODIGOCOMP,3)+STR(OPERACION,12)+STR(ITEM,8)+STR(ID,6)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("MOVIMIEN")
							m.lcURL = m.gcRWSVar_URLU + "movimien0"
						
						CASE m.tcTrigger = "I"
							m.lcCadenaInsert = traer_cadena_insert("MOVIMIEN")
							m.lcURL = m.gcRWSVar_URLI + "movimien0"
						
						OTHERWISE   
							m.lcCadenaInsert = "empresa=|" + ALLTRIM(STR(empresa, 5)) + "&|codigocomp=|" + ALLTRIM(STR(codigocomp,3)) + "&|operacion=|" + ALLTRIM(STR(operacion, 12)) + "&|item=|" + ALLTRIM(STR(item,8))+ "&|id=|" + ALLTRIM(STR(id,6))
							m.lcURL = m.gcRWSVar_URLD + "movimien0"
							m.tlAsincro = .T.
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_MOVIMIEN

					* Envío asincronico por errores de reintento
					m.plAsincronico = .NOT. tlAsincro

				CASE UPPER(m.tcTabla) == "DEUDORES" .AND. JUSTSTEM(DBF()) = "DEUDORES" .AND. ID_RWS <> 0
					m.lcPkey = STR(ID_RWS,12)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("DEUDORES")
							m.lcURL = m.gcRWSVar_URLU + "deudores0"
						
						CASE m.tcTrigger = "I"
							m.lcCadenaInsert = traer_cadena_insert("DEUDORES")
							m.lcURL = m.gcRWSVar_URLI + "deudores0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "id_rws=|" + ALLTRIM(STR(id_rws, 12))
							else	
								m.lcCadenaInsert = "id_rws=|" + ALLTRIM(STR(m.tuClave, 12))
								m.lcPkey = STR(m.tuClave,12)
							endif
							m.lcURL = m.gcRWSVar_URLD + "deudores0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_DEUDORES

					* Envío asincronico por errores de reintento
					m.plAsincronico = .NOT. tlAsincro

				CASE UPPER(m.tcTabla) == "CONDICIO" .AND. JUSTSTEM(DBF()) = "CONDICIO"
					m.lcPkey = STR(ID_RWS,12)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("CONDICIO")
							m.lcURL = m.gcRWSVar_URLU + "condicio0"
						
						CASE m.tcTrigger = "I"
							m.glAuditarTablas = .T.
							m.lcCadenaInsert = traer_cadena_insert("CONDICIO")
							m.lcURL = m.gcRWSVar_URLI + "condicio0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "id_rws=|" + ALLTRIM(STR(id_rws, 12))
							else	
								m.lcCadenaInsert = "id_rws=|" + ALLTRIM(STR(m.tuClave, 12))
								m.lcPkey = STR(m.tuClave,12)
							endif
							m.lcURL = m.gcRWSVar_URLD + "condicio0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_CONDICIO

				CASE UPPER(m.tcTabla) == "TRANSPOR" .AND. JUSTSTEM(DBF()) = "TRANSPOR"
					m.lcPkey = STR(CODIGO,6)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("TRANSPOR")
							m.lcURL = m.gcRWSVar_URLU + "transpor0"
						
						CASE m.tcTrigger = "I"
							m.glAuditarTablas = .T.
							m.lcCadenaInsert = traer_cadena_insert("TRANSPOR")
							m.lcURL = m.gcRWSVar_URLI + "transpor0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(codigo, 6))
							else	
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(m.tuClave, 6))
								m.lcPkey = STR(m.tuClave, 6)
							endif
							m.lcURL = m.gcRWSVar_URLD + "transpor0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_TRANSPOR
					
				CASE UPPER(m.tcTabla) == "DLISTAPR" .AND. JUSTSTEM(DBF()) = "DLISTAPR" .AND. INLIST(LISTAPRE, "LBS1", "FRESISTENC", "MAYORISTA")
					m.lcPkey = listapre+STR(version,4)+STR(codigo,15)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("DLISTAPR")
							m.lcURL = m.gcRWSVar_URLU + "dlistapr0"
						
						CASE m.tcTrigger = "I"
							m.glAuditarTablas = .T.
							m.lcCadenaInsert = traer_cadena_insert("DLISTAPR")
							m.lcURL = m.gcRWSVar_URLI + "dlistapr0"
						
						OTHERWISE   
							m.lcCadenaInsert = "listapre=|" + ALLTRIM(listapre) + "&|version=|" + ALLTRIM(STR(version,4)) + "&|codigo=|" + ALLTRIM(STR(codigo, 15))
							m.lcURL = m.gcRWSVar_URLD + "dlistapr0"
							m.tlAsincro = .T.
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_DLISTAPR

					* Envío asincronico por errores de reintento
					m.plAsincronico = .NOT. tlAsincro

				CASE UPPER(m.tcTabla) == "VENDEDOR" .AND. JUSTSTEM(DBF()) = "VENDEDOR"
					m.lcPkey = STR(CODIGO,6)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("VENDEDOR")
							m.lcURL = m.gcRWSVar_URLU + "vendedor0"
						
						CASE m.tcTrigger = "I"
							m.glAuditarTablas = .T.
							m.lcCadenaInsert = traer_cadena_insert("VENDEDOR")
							m.lcURL = m.gcRWSVar_URLI + "vendedor0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(codigo, 6))
							else	
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(m.tuClave, 6))
								m.lcPkey = STR(m.tuClave, 6)
							endif
							m.lcURL = m.gcRWSVar_URLD + "vendedor0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_VENDEDOR

				CASE UPPER(m.tcTabla) == "STOCK" .AND. JUSTSTEM(DBF()) = "STOCK"
					m.lcPkey = STR(CODIGO,15)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("STOCK")
							m.lcURL = m.gcRWSVar_URLU + "stock0"
						
						CASE m.tcTrigger = "I"
							m.glAuditarTablas = .T.
							m.lcCadenaInsert = traer_cadena_insert("STOCK")
							m.lcURL = m.gcRWSVar_URLI + "stock0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(codigo, 15))
							else	
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(m.tuClave, 15))
								m.lcPkey = STR(m.tuClave, 15)
							endif
							m.lcURL = m.gcRWSVar_URLD + "stock0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_STOCK

					* Envío asincronico por errores de reintento
					m.plAsincronico = .NOT. tlAsincro
					
				CASE UPPER(m.tcTabla) == "DTOAUTO" .AND. JUSTSTEM(DBF()) = "DTOAUTO"
					m.lcPkey = STR(ID_RWS,12)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("DTOAUTO")
							m.lcURL = m.gcRWSVar_URLU + "dtoauto0"
						
						CASE m.tcTrigger = "I"
							m.glAuditarTablas = .T.
							m.lcCadenaInsert = traer_cadena_insert("DTOAUTO")
							m.lcURL = m.gcRWSVar_URLI + "dtoauto0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "id_rws=|" + ALLTRIM(STR(id_rws, 12))
							else	
								m.lcCadenaInsert = "id_rws=|" + ALLTRIM(STR(m.tuClave, 12))
								m.lcPkey = STR(m.tuClave,12)
							endif
							m.lcURL = m.gcRWSVar_URLD + "dtoauto0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_DTOAUTO
					
				CASE UPPER(m.tcTabla) == "CLIENTES" .AND. JUSTSTEM(DBF()) = "CLIENTES"
					m.lcPkey = STR(CODIGO,6)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("CLIENTES")
							m.lcURL = m.gcRWSVar_URLU + "clientes0"
						
						CASE m.tcTrigger = "I"
							m.glAuditarTablas = .T.
							m.lcCadenaInsert = traer_cadena_insert("CLIENTES")
							m.lcURL = m.gcRWSVar_URLI + "clientes0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(codigo, 6))
							else	
								m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(m.tuClave, 6))
								m.lcPkey = STR(m.tuClave, 6)
							endif
							m.lcURL = m.gcRWSVar_URLD + "clientes0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_CLIENTES
					
	*!*				CASE UPPER(m.tcTabla) == "NOTAS" .AND. JUSTSTEM(DBF()) = "NOTAS"
	*!*					m.lcPkey = STR(EMPRESA,5)+FORMULARIO+STR(NUMERO,12)
	*!*					DO CASE 
	*!*						CASE m.tcTrigger = "U"
	*!*							m.lcCadenaInsert = traer_cadena_insert("NOTAS")
	*!*							m.lcURL = m.gcRWSVar_URLU + "notas0"
	*!*						
	*!*						CASE m.tcTrigger = "I"
	*!*							m.lcCadenaInsert = traer_cadena_insert("NOTAS")
	*!*							m.lcURL = m.gcRWSVar_URLI + "notas0"
	*!*						
	*!*						OTHERWISE   
	*!*							m.lcCadenaInsert = "empresa=|" + ALLTRIM(STR(empresa, 5)) + "&|formulario=|" + ALLTRIM(formulario) + "&|numero=|" + ALLTRIM(STR(numero, 12))
	*!*							m.lcURL = m.gcRWSVar_URLD + "notas0"
	*!*							m.tlAsincro = .T.
	*!*					ENDCASE  
	*!*					m.lcVarRWS = m.gcRWSVar_NOTAS
	*!*					
	*!*					* Envío asincronico por errores de reintento
	*!*					m.plAsincronico = .NOT. tlAsincro

				CASE UPPER(m.tcTabla) == "MNOTAS" .AND. JUSTSTEM(DBF()) = "MNOTAS"
					m.lcPkey = STR(EMPRESA,5)+FORMULARIO+STR(NNUMERO,12)+STR(ID,6)
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("MNOTAS")
							m.lcURL = m.gcRWSVar_URLU + "mnotas0"
						
						CASE m.tcTrigger = "I"
							m.lcCadenaInsert = traer_cadena_insert("MNOTAS")
							m.lcURL = m.gcRWSVar_URLI + "mnotas0"
						
						OTHERWISE   
						
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "empresa=|" + ALLTRIM(STR(empresa, 5)) + "&|formulario=|" + ALLTRIM(formulario) + "&|nnumero=|" + ALLTRIM(STR(nnumero, 12)) + "&|id=|" + ALLTRIM(STR(id,6))
								m.lcPkey = m.lcCadenaInsert
							else	
								m.lcCadenaInsert = m.tuClave
								m.lcPkey = m.tuClave
							endif
							
							m.lcURL = m.gcRWSVar_URLD + "mnotas0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_MNOTAS				

					* Envío asincronico por errores de reintento
					m.plAsincronico = .NOT. tlAsincro

				CASE UPPER(m.tcTabla) == "MORDENVT" .AND. JUSTSTEM(DBF()) = "MORDENVT"

					m.lcPkey = STR(EMPRESA,5)+FORMULARIO+STR(NNUMERO,12)+STR(CODIGO,15)+STR(ID,6)+DTOC(FECH_AUTOR,1)	&&+HORA_AUTOR
					DO CASE 
						CASE m.tcTrigger = "U"
							m.lcCadenaInsert = traer_cadena_insert("MORDENVT")
							m.lcURL = m.gcRWSVar_URLU + "mordenvt0"
						
						CASE m.tcTrigger = "I"
							m.lcCadenaInsert = traer_cadena_insert("MORDENVT")
							m.lcURL = m.gcRWSVar_URLI + "mordenvt0"
						
						OTHERWISE   
							if VARTYPE(m.tuClave) = "L"
								m.lcCadenaInsert = "empresa=|" + ALLTRIM(STR(empresa, 5)) + "&|formulario=|" + ALLTRIM(formulario) + "&|nnumero=|" + ALLTRIM(STR(nnumero, 12))
								m.lcCadenaInsert = m.lcCadenaInsert + "&|codigo=|" + ALLTRIM(STR(codigo,15))+ "&|id=|" + ALLTRIM(STR(id,6))+ "&|fech_autor=|" + IIF(EMPTY(fech_autor) , "0000-00-00", STRTRAN(dtoc(fech_autor), "/", "-"))
								m.lcPkey = m.lcCadenaInsert
							else	
								m.lcCadenaInsert = m.tuClave
								m.lcPkey = m.tuClave
							endif
							m.lcURL = m.gcRWSVar_URLD + "mordenvt0"
					ENDCASE  
					m.lcVarRWS = m.gcRWSVar_MORDENVT				

					* Envío asincronico por errores de reintento
					m.plAsincronico = .NOT. tlAsincro

			ENDCASE	

			IF .not. EMPTY(m.lcCadenaInsert)
				
				* Encripto la cadena, la paso a UNICODE, luego a UTF8 y finalmente a Base64
				m.lcCadenaInsert = m.lcVarRWS + "&dato=|" + STRCONV(STRCONV(strconv(m.lcCadenaInsert, 5), 10), 13)
*!*					IF UPPER(m.tcTabla) == "MORDENVT"
*!*						STRTOFILE(m.lcCadenaInsert, "F:\Clientes\Cortassa\RWS\cadenainsert64b.txt")
*!*					ENDIF	

				*************************************************************
				* Envio de Peteción de Insert al Web Service de RWS  	    *	
				*************************************************************	
				DO CASE 
					CASE m.plErrorConexion
						m.lnStatus = 555
					
					CASE m.plAsincronico
						m.lnStatus = 888	
					
					OTHERWISE 
						m.goRWSVar_XMLHttp.Open("POST", m.lcURL, .F.)
						m.goRWSVar_XMLHttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')			
						m.goRWSVar_XMLHttp.Send(m.lcCadenaInsert)
						m.lnStatus = m.goRWSVar_XMLHttp.STATUS	
				ENDCASE  

				* Inserto en el log
				IF .NOT. USED("RWSLI")
					SELECT1()
					USE RWS_LOGS AGAIN ALIAS RWSLI
				ENDIF 

				IF m.lnStatus = 200 .AND. "fail" $ m.goRWSVar_XMLHttp.responseText
					m.lnStatus = 444
				ENDIF 

				SELECT RWSLI
				TRY
					INSERT INTO (ALIAS()) (OPERADOR, FECHA_HORA, STATUSCODE, TABLA, TRIGGER, EXP_INSERT);
					VALUES(m.Noma, DATETIME1(), m.lnStatus, UPPER(m.tcTabla), m.tcTrigger, m.lcPkey)
				CATCH TO m.loException 	
					IF( m.loException.ErrorNo = 108 .OR. m.loException.ErrorNo = 109) && "108: Otra persona esta utilizando en archivo, 109: Otra persona esta utilizando el registro" 
						LOCAL lcFile
						
						m.lcFile = m.gcPathPresea + "rws_logs_usr_" + ALLTRIM(m.Noma) + ".dbi"
						IF .NOT.( FILE(lcFile) )
							SELECT RWSLI
							COPY STRUCTURE TO ( m.lcFile )
							USE ( m.lcFile ) ALIAS _DBI
						ELSE
							SELECT1() 
							USE ( m.lcFile ) ALIAS _DBI
						ENDIF	
						SELECT _DBI				
						INSERT INTO (ALIAS()) (OPERADOR, FECHA_HORA, STATUSCODE, TABLA, TRIGGER, EXP_INSERT);
						VALUES(m.Noma, DATETIME1(), m.lnStatus , UPPER(m.tcTabla), m.tcTrigger, m.lcPkey)
						USE
					ELSE
						*enviarmail("hernan@rosariows.com", .f., "Error de rwsi1b", "TABLA: " + UPPER(m.tcTabla) + CHR(13) + " - " + m.loException.message + CHR(13))
						TRY 
							STRTOFILE("Error de rwsi1b" + CHR(13) + "TABLA: " + UPPER(m.tcTabla) + CHR(13) + m.loException.message + CHR(13) + " - Lugar: " + STR(m.nMenu1,5), ADDBS(m.gcPathPresea) + "rwsbackup\rwsi1blogerror" + DTOS(DATE()) + ".txt")
						CATCH
						ENDTRY 	
					ENDIF
				ENDTRY 
			ENDIF 	
		ENDIF 

		CATCH TO m.loException
			*enviarmail("hernan@rosariows.com", .f., "Error de rwsi1b", "TABLA: " + UPPER(m.tcTabla) + CHR(13) + " - " + m.loException.message + CHR(13) + " - Lugar: " + STR(m.nMenu1,5) )
			TRY 
				STRTOFILE("Error de rwsi1b" + CHR(13) + "TABLA: " + UPPER(m.tcTabla) + CHR(13) + m.loException.message + CHR(13) + " - Lugar: " + STR(m.nMenu1,5), ADDBS(m.gcPathPresea) + "rwsbackup\rwsi1blogerror" + DTOS(DATE()) + ".txt")
			CATCH
			ENDTRY 	
		ENDTRY 

		SET DATE TO FRENCH
	ENDIF 

	SELECT(m.lnAreaAnterior)
ENDIF 

******************************************************************************************************************************************************************
*
******************************************************************************************************************************************************************
PROCEDURE traer_cadena_insert

LPARAMETERS tcTabla

LOCAL lcCadenaInsert

m.lcCadenaInsert = ""

DO CASE 
	CASE m.tcTabla == "NOTAS"
		m.lcCadenaInsert = "numero=|" + ALLTRIM(STR(numero, 12))&& + "&"+ALLTRIM(LOWER(m.tcCampo)) +"="+ rws_retc(tcCampo, tnDecimales)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|condicion=|" + ALLTRIM(STR(condicion, 5))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|formulario=|" + ALLTRIM(formulario)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|empresa=|" + ALLTRIM(STR(empresa, 5))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|fecha=|" + STRTRAN(dtoc(fecha), "/", "-")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cliente=|" + ALLTRIM(STR(cliente, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|despachado=|" + ALLTRIM(despachado)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|moneda=|" + ALLTRIM(STR(moneda, 2))										
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cotizacion=|" + ALLTRIM(STR(cotizacion, 14, 8))							
		m.lcCadenaInsert = m.lcCadenaInsert + "&|vendedor=|" + ALLTRIM(STR(vendedor, 6))																							
		m.lcCadenaInsert = m.lcCadenaInsert + "&|transporte=|" + ALLTRIM(STR(transporte, 5))															
		m.lcCadenaInsert = m.lcCadenaInsert + "&|importe=|" + ALLTRIM(STR(importe, 12, 2))					
		m.lcCadenaInsert = m.lcCadenaInsert + "&|iva=|" + ALLTRIM(STR(iva, 12, 2))										
		m.lcCadenaInsert = m.lcCadenaInsert + "&|total_item=|" + ALLTRIM(STR(total_item, 12))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|total_item=|" + ALLTRIM(STR(total_cant, 12))																									
		m.lcCadenaInsert = m.lcCadenaInsert + "&|domi_entre=|" + ALLTRIM(domi_entre)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|operacion=|" + ALLTRIM(STR(operacion, 12))																														
		m.lcCadenaInsert = m.lcCadenaInsert + "&|listapre=|" + ALLTRIM(listapre)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|ver_lista=|" + ALLTRIM(STR(ver_lista, 4))	

	CASE m.tcTabla == "MNOTAS"
		m.lcCadenaInsert = "nnumero=|" + ALLTRIM(STR(nnumero, 12))&& + "&"+ALLTRIM(LOWER(m.tcCampo)) +"="+ rws_retc(tcCampo, tnDecimales)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|formulario=|" + ALLTRIM(formulario)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|empresa=|" + ALLTRIM(STR(empresa, 5))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|id=|" + ALLTRIM(STR(id, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|codigo=|" + ALLTRIM(STR(codigo, 15))							
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cantidad=|" + ALLTRIM(STR(cantidad, 14, 7))					
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cant_desp=|" + ALLTRIM(STR(cant_desp, 14, 7))					
		m.lcCadenaInsert = m.lcCadenaInsert + "&|deposito=|" + ALLTRIM(STR(deposito, 12))		
					
	CASE m.tcTabla == "MORDENVT"
		m.lcCadenaInsert = "nnumero=|" + ALLTRIM(STR(nnumero, 12))&& + "&"+ALLTRIM(LOWER(m.tcCampo)) +"="+ rws_retc(tcCampo, tnDecimales)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|formulario=|" + ALLTRIM(formulario)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|empresa=|" + ALLTRIM(STR(empresa, 5))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|id=|" + ALLTRIM(STR(id, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|codigo=|" + ALLTRIM(STR(codigo, 15))							
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cantidad=|" + ALLTRIM(STR(cantidad, 14, 7))					
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cant_desp=|" + ALLTRIM(STR(cant_desp, 14, 7))	
		m.lcCadenaInsert = m.lcCadenaInsert + "&|fech_autor=|" + STRTRAN(dtoc(fech_autor), "/", "-")				
		m.lcCadenaInsert = m.lcCadenaInsert + "&|deposito=|" + ALLTRIM(STR(deposito, 12))		

	CASE m.tcTabla == "CLIENTES"
		m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(CODIGO, 6))&& + "&"+ALLTRIM(LOWER(m.tcCampo)) +"="+ rws_retc(tcCampo, tnDecimales)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|condicion=|" + ALLTRIM(STR(condicion, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|credito=|" + ALLTRIM(STR(credito, 12, 2))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cuit=|" + ALLTRIM(STR(cuit, 12))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|c_postal=|" + ALLTRIM(c_postal)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|domicilio=|" + ALLTRIM(domicilio)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|e_mail=|" + ALLTRIM(e_mail)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|e_mail2=|" + ALLTRIM(e_mail2)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|f_inicio=|" + STRTRAN(dtoc(f_inicio), "/", "-")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|u_factura=|" + STRTRAN(dtoc(u_factura), "/", "-")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|listapre=|" + ALLTRIM(listapre)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|localidad=|" + ALLTRIM(localidad)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|nombre=|" + ALLTRIM(nombre)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|n_fantasia=|" + ALLTRIM(n_fantasia)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|provincia=|" + ALLTRIM(provincia)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|telefono=|" + ALLTRIM(telefono)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|tipo_resp=|" + ALLTRIM(STR(tipo_resp, 3, 1))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|zona=|" + ALLTRIM(STR(zona, 3))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|rwsmayoris=|" + IIF(rwsmayoris, "1", "0")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|vendedor=|" + ALLTRIM(STR(vendedor, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cod_med=|" + ALLTRIM(STR(cod_med, 3))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|transporte=|" + ALLTRIM(STR(transporte, 5))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|referencia=|" + ALLTRIM(referencia)		
		m.lcCadenaInsert = m.lcCadenaInsert + "&|categoria=|" + ALLTRIM(categoria)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|categor=|" + ALLTRIM(categor)		
		m.lcCadenaInsert = m.lcCadenaInsert + "&|rubro=|" + ALLTRIM(rubro)		
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cobrador=|" + ALLTRIM(STR(cobrador, 6))		

	CASE m.tcTabla == "DTOAUTO"
		m.lcCadenaInsert = "grupo=|" + ALLTRIM(grupo)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|categoria=|" + ALLTRIM(categoria)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cantidad=|" + ALLTRIM(STR(cantidad, 14, 7))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|dto=|" + ALLTRIM(STR(dto, 7, 3))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|dto1=|" + ALLTRIM(STR(dto1, 7, 3))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|dto2=|" + ALLTRIM(STR(dto2, 7, 3))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|desde=|" + STRTRAN(dtoc(desde), "/", "-")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|hasta=|" + STRTRAN(dtoc(hasta), "/", "-")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|id_rws=|" + ALLTRIM(STR(id_rws, 12))

	CASE m.tcTabla == "STOCK"
		m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(CODIGO, 15))&& + "&"+ALLTRIM(LOWER(m.tcCampo)) +"="+ rws_retc(tcCampo, tnDecimales)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|detalle=|" + ALLTRIM(detalle)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|tipo=|" + ALLTRIM(tipo)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|discontinu=|" + IIF(EMPTY(discontinu), "0", "1")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|sin_stock=|" + IIF(EMPTY(sin_stock), "0", "1")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|rubro=|" + ALLTRIM(rubro)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|especif=|" + ALLTRIM(especif)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|especif1=|" + ALLTRIM(especif1)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|especif2=|" + ALLTRIM(especif2)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|especif3=|" + ALLTRIM(especif3)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|marca_cor=|" + ALLTRIM(marca_cor)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|nombre_cor=|" + ALLTRIM(nombre_cor)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|agrupa=|" + ALLTRIM(STR(agrupa, 15))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|tamano=|" + ALLTRIM(tamano)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|extracto=|" + ALLTRIM(extracto)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|iva=|" + ALLTRIM(STR(iva,5,2))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|deta_lista=|" + ALLTRIM(deta_lista)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|genero=|" + ALLTRIM(genero)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|division=|" + ALLTRIM(division)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|marca=|" + ALLTRIM(STR(marca,6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|sub_marca=|" + ALLTRIM(sub_marca)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|familia=|" + ALLTRIM(familia)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|info=|" + ALLTRIM(info)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|notas=|" + ALLTRIM(notas)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|desdepromo=|" + STRTRAN(dtoc(desdepromo), "/", "-")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|hastapromo=|" + STRTRAN(dtoc(hastapromo), "/", "-")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|especifweb=|" + ALLTRIM(especifweb)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|verwebmay=|" + ALLTRIM(STR(IIF(verwebmay, 1, 0), 3))		
		m.lcCadenaInsert = m.lcCadenaInsert + "&|tapa_may=|" + ALLTRIM(tapa_may)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|proveedor=|" + ALLTRIM(STR(proveedor, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|grupo_des=|" + ALLTRIM(grupo_des)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|relacion1=|" + ALLTRIM(relacion1)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|relacion2=|" + ALLTRIM(relacion2)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|relacion3=|" + ALLTRIM(relacion3)				
		m.lcCadenaInsert = m.lcCadenaInsert + "&|nivel=|" + ALLTRIM(STR(nivel,3))
		
	CASE m.tcTabla == "VENDEDOR"
		m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(CODIGO, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|nombre=|" + ALLTRIM(nombre)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|telefono=|" + ALLTRIM(telefono)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|celular=|" + ALLTRIM(celular)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|e_mail=|" + ALLTRIM(e_mail)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|interno=|" + ALLTRIM(interno)

	CASE m.tcTabla == "DLISTAPR"
		m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(CODIGO, 15))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|listapre=|" + ALLTRIM(listapre)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|version=|" + ALLTRIM(STR(version, 4))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|precio=|" + ALLTRIM(STR(precio, 12, 4))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|ult_modif=|" + STRTRAN(dtoc(ult_modif), "/", "-")

	CASE m.tcTabla == "TRANSPOR"
		m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(CODIGO, 6))&& + "&"+ALLTRIM(LOWER(m.tcCampo)) +"="+ rws_retc(tcCampo, tnDecimales)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cuit=|" + ALLTRIM(STR(cuit, 12, 2))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|tipo_resp=|" + ALLTRIM(STR(tipo_resp, 3))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|c_postal=|" + ALLTRIM(c_postal)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|domicilio=|" + ALLTRIM(domicilio)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|localidad=|" + ALLTRIM(localidad)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|nombre=|" + ALLTRIM(nombre)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|provincia=|" + ALLTRIM(provincia)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|telefonos=|" + ALLTRIM(telefonos)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|destino=|" + ALLTRIM(destino)

	CASE m.tcTabla == "CONDICIO"
		m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(CODIGO, 5))&& + "&"+ALLTRIM(LOWER(m.tcCampo)) +"="+ rws_retc(tcCampo, tnDecimales)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|nombre=|" + ALLTRIM(nombre)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|dias=|" + ALLTRIM(STR(dias, 3))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|particip=|" + ALLTRIM(STR(particip, 8, 4))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|moneda=|" + ALLTRIM(STR(moneda, 2))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cuotas=|" + ALLTRIM(STR(cuotas, 3))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|id_rws=|" + ALLTRIM(STR(id_rws, 12))

	CASE m.tcTabla == "DEUDORES"
		m.lcCadenaInsert = "numero=|" + ALLTRIM(STR(numero, 12))&& + "&"+ALLTRIM(LOWER(m.tcCampo)) +"="+ rws_retc(tcCampo, tnDecimales)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|formulario=|" + ALLTRIM(formulario)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|empresa=|" + ALLTRIM(STR(empresa, 5))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|id_rws=|" + ALLTRIM(STR(id_rws, 12))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|condicion=|" + ALLTRIM(STR(condicion, 5))							
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cuota=|" + ALLTRIM(cuota)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|importe=|" + ALLTRIM(STR(importe, 12, 2))					
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cotizacion=|" + ALLTRIM(STR(cotizacion, 14, 8))					
		m.lcCadenaInsert = m.lcCadenaInsert + "&|iva=|" + ALLTRIM(STR(iva, 12, 2))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|moneda=|" + ALLTRIM(STR(moneda, 2))					
		m.lcCadenaInsert = m.lcCadenaInsert + "&|tipo=|" + ALLTRIM(STR(tipo, 1))					
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cliente=|" + ALLTRIM(STR(cliente, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|fecha=|" + STRTRAN(dtoc(fecha), "/", "-")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|vto=|" + STRTRAN(dtoc(vto), "/", "-")

	CASE m.tcTabla == "MOVIMIEN"
		m.lcCadenaInsert = "nnumero=|" + ALLTRIM(STR(nnumero, 12))&& + "&"+ALLTRIM(LOWER(m.tcCampo)) +"="+ rws_retc(tcCampo, tnDecimales)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|formulario=|" + ALLTRIM(formulario)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|empresa=|" + ALLTRIM(STR(empresa, 5))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|operacion=|" + ALLTRIM(STR(operacion, 12))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|condicion=|" + ALLTRIM(STR(condicion, 5))							
		m.lcCadenaInsert = m.lcCadenaInsert + "&|detalle=|" + ALLTRIM(detalle)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|precio=|" + ALLTRIM(STR(precio, 12, 4))					
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cotizacion=|" + ALLTRIM(STR(cotizacion, 14, 8))					
		m.lcCadenaInsert = m.lcCadenaInsert + "&|iva=|" + ALLTRIM(STR(iva, 14, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|moneda=|" + ALLTRIM(STR(moneda, 2))					
		m.lcCadenaInsert = m.lcCadenaInsert + "&|item=|" + ALLTRIM(STR(item, 8))					
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cliente=|" + ALLTRIM(STR(cliente, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|fecha=|" + STRTRAN(dtoc(fecha), "/", "-")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|codigo=|" + ALLTRIM(STR(codigo, 15))					
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cantidad=|" + ALLTRIM(STR(cantidad, 14, 7))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|dto=|" + ALLTRIM(STR(dto, 7, 3))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|dto1=|" + ALLTRIM(STR(dto1, 7, 3))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|dto2=|" + ALLTRIM(STR(dto2, 7, 3))									
		m.lcCadenaInsert = m.lcCadenaInsert + "&|id=|" + ALLTRIM(STR(id, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|codigocomp=|" + ALLTRIM(STR(codigocomp, 3))										
		m.lcCadenaInsert = m.lcCadenaInsert + "&|porce_iva=|" + ALLTRIM(STR(porce_iva, 6, 2))					
		m.lcCadenaInsert = m.lcCadenaInsert + "&|anulada=|" + ALLTRIM(STR(IIF(anulada, 1, 0), 3))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|letra_r=|" + ALLTRIM(letra_r)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|letra=|" + ALLTRIM(letra)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|tipo=|" + ALLTRIM(STR(tipo, 1))					
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cant_remi=|" + ALLTRIM(STR(cant_remi, 14, 7))					
		m.lcCadenaInsert = m.lcCadenaInsert + "&|remito=|" + ALLTRIM(STR(remito, 12))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|nota_venta=|" + ALLTRIM(STR(nota_venta, 12))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|fecha_remi=|" + STRTRAN(dtoc(fecha_remi), "/", "-")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cant_desp=|" + ALLTRIM(STR(cant_desp, 14, 7))					

	CASE m.tcTabla == "MED_COB"
		m.lcCadenaInsert = "cod_med=|" + ALLTRIM(STR(cod_med, 3))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|det_med=|" + ALLTRIM(det_med)

	CASE m.tcTabla == "REFER_CL"
		m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(codigo, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|descripcio=|" + ALLTRIM(descripcio)

	CASE m.tcTabla == "RUBRO_CL"
		m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(codigo, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|rubro=|" + ALLTRIM(rubro)

	CASE m.tcTabla == "DOMICILI"
		m.lcCadenaInsert = "codigo=|" + ALLTRIM(codigo)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cliente=|" + ALLTRIM(STR(cliente, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|domicilio=|" + ALLTRIM(domicilio)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|c_postal=|" + ALLTRIM(c_postal)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|localidad=|" + ALLTRIM(localidad)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|provincia=|" + ALLTRIM(provincia)

	CASE m.tcTabla == "CODBARRA"
		m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(codigo, 15))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|coddun14=|" + ALLTRIM(STR(coddun14, 14))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|unidades=|" + ALLTRIM(STR(unidades, 8))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|canautprep=|" + IIF(canautprep, "1", "0")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|formato=|" + ALLTRIM(formato)

	CASE m.tcTabla == "PROVEEDO"
		m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(codigo, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|nombre=|" + ALLTRIM(nombre)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|domicilio=|" + ALLTRIM(domicilio)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|c_postal=|" + ALLTRIM(c_postal)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|localidad=|" + ALLTRIM(localidad)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|provincia=|" + ALLTRIM(provincia)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|telefono=|" + ALLTRIM(telefono)						
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cuit=|" + ALLTRIM(STR(cuit, 12))		

	CASE m.tcTabla == "DTOPROD"
		m.lcCadenaInsert = "id=|" + ALLTRIM(STR(id, 8))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|id_rws=|" + ALLTRIM(STR(id_rws, 12))		
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cant_desde=|" + ALLTRIM(STR(cant_desde, 14, 7))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cant_hasta=|" + ALLTRIM(STR(cant_hasta, 14, 7))		
		m.lcCadenaInsert = m.lcCadenaInsert + "&|codpromo=|" + ALLTRIM(codpromo)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|dto=|" + ALLTRIM(STR(dto, 7, 3))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|expresion=|" + ALLTRIM(expresion)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|exp_precio=|" + ALLTRIM(exp_precio)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|filtro=|" + ALLTRIM(filtro)		
		m.lcCadenaInsert = m.lcCadenaInsert + "&|novalidar=|" + IIF(novalidar, "1", "0")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|orden=|" + ALLTRIM(STR(orden, 5))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|precio_f=|" + ALLTRIM(STR(precio_f, 12, 4))
		*m.lcCadenaInsert = m.lcCadenaInsert + "&|texto=|" + ALLTRIM(texto)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|todos=|" + ALLTRIM(todos)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|version=|" + ALLTRIM(STR(version, 5))
	
	CASE m.tcTabla == "DESEOSSC"
		m.lcCadenaInsert = "cod_cli=|" + ALLTRIM(STR(cod_cli, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|id_rws=|" + ALLTRIM(STR(id_rws, 12))		
		m.lcCadenaInsert = m.lcCadenaInsert + "&|nom_cli=|" + ALLTRIM(nom_cli)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|baja=|" + IIF(baja, "1", "0")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|fecha=|" + STRTRAN(dtoc(fecha), "/", "-")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|operador=|" + ALLTRIM(operador)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cod_prod=|" + ALLTRIM(STR(cod_prod, 15))		
		m.lcCadenaInsert = m.lcCadenaInsert + "&|nom_prod=|" + ALLTRIM(nom_prod)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cantidad=|" + ALLTRIM(STR(cantidad, 14, 4))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|observacio=|" + ALLTRIM(observacio)

	CASE m.tcTabla == "GUIATRAN"
		m.lcCadenaInsert = "codcliente=|" + ALLTRIM(STR(codcliente, 6))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|nomcliente=|" + ALLTRIM(nomcliente)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|codtransp=|" + ALLTRIM(STR(codtransp, 5))		
		m.lcCadenaInsert = m.lcCadenaInsert + "&|nomtransp=|" + ALLTRIM(nomtransp)		
		m.lcCadenaInsert = m.lcCadenaInsert + "&|bultos=|" + ALLTRIM(STR(bultos, 9))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|num_guia=|" + ALLTRIM(num_guia)		
		m.lcCadenaInsert = m.lcCadenaInsert + "&|entrega=|" + STRTRAN(dtoc(entrega), "/", "-")
		m.lcCadenaInsert = m.lcCadenaInsert + "&|turno=|" + ALLTRIM(turno)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|remito=|" + ALLTRIM(STR(remito, 12))		
		m.lcCadenaInsert = m.lcCadenaInsert + "&|observacio=|" + ALLTRIM(observacio)

	CASE m.tcTabla == "RELACION"
		m.lcCadenaInsert = "id_rws=|" + ALLTRIM(STR(id_rws, 12))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|articulo=|" + ALLTRIM(STR(articulo, 15))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|insumo=|" + ALLTRIM(STR(insumo, 15))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|cantidad=|" + ALLTRIM(STR(cantidad, 14, 7))

	CASE m.tcTabla == "DEPOSITO"
		m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(codigo, 12))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|grupo=|" + ALLTRIM(grupo)
		m.lcCadenaInsert = m.lcCadenaInsert + "&|disponible=|" + ALLTRIM(disponible)

	CASE m.tcTabla == "STOCK_DE"
		m.lcCadenaInsert = "codigo=|" + ALLTRIM(STR(codigo, 12))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|empresa=|" + ALLTRIM(STR(empresa,5))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|deposito=|" + ALLTRIM(STR(deposito,12))
		m.lcCadenaInsert = m.lcCadenaInsert + "&|stock=|" + ALLTRIM(STR(stock,14,7))

ENDCASE 

RETURN m.lcCadenaInsert

*******************************************************************************************************************************************************************
* Verifica si no está cerrada la configuracion
*******************************************************************************************************************************************************************
PROCEDURE rws_verificar_conexion

LOCAL lnAreaAnt, llRet

m.lnAreaAnt = SELECT(0)

IF .NOT. USED("RWSCF")
	SELECT1()
	USE RWS_CONF AGAIN ALIAS RWSCF
ENDIF 

SELECT("RWSCF")
GO TOP 
m.llRet = APAGADO .OR. UPPER(ADDBS(m.gcPathPresea)) <> UPPER(ADDBS(PATH))

IF( APAGADO ) .OR. (VARTYPE(m.gcRWSVar_SIN_CONEXION) = "L" .AND. m.gcRWSVar_SIN_CONEXION)
	m.plErrorConexion = APAGADO
ENDIF

IF( UPPER(ADDBS(m.gcPathPresea)) <> UPPER(ADDBS(PATH)) )
	m.plErrorPath = .T.
ENDIF

SELECT(m.lnAreaAnt)

RETURN m.llRet


********************************************************************************************************************************************************************************************************************
* Busca áreas libres
********************************************************************************************************************************************************************************************************************
PROCEDURE SELECT1

IF VARTYPE(gnAreaLibre) <> "N"
	PUBLIC gnAreaLibre
	m.gnAreaLibre = 20000
ENDIF 

* Si me paso de 30000 arranco nuevamente en 20000
IF m.gnAreaLibre => 30000
	m.gnAreaLibre = 20000
ENDIF 

DO WHILE m.gnAreaLibre < 30000 .and. USED(m.gnAreaLibre)
	m.gnAreaLibre = m.gnAreaLibre + 1
ENDDO 

SELECT(m.gnAreaLibre)
m.gnAreaLibre = m.gnAreaLibre + 1