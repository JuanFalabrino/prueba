SELECT DISTINCT

CONCAT(sehope.OpMonoRamCod,"_",sehope.OpMonoRamPolNum) AS Rama_Poliza
,sehope.ArtCod AS Producto
,sehope.SpolNum AS Operacion
,gntdaf.DafPfApel  AS apellido
,gntdaf.DafpfNomb AS Nombre
,sehope.OpCabDatIns AS Fecha_insert
,sehsup.OpDetFecEmi AS Fecha_Emis
,sehope.OpFecIniVig
,sehope.OpFecFinVig
,REPLACE(gntdaf.DafPfFecNac,'-','') AS fechanac
,gntdaftdo.TdoCod AS Tipo_Doc
 ,gntdaftdo.DafTdoNum AS Num_Doc
 ,gntdafmail.MailDirec AS mail
,sehope.OpeIntTip
,sehope.OpeInt1Cod
,Int1Des AS Nombre_Intermediario
,REPLACE(sehope.OpFecIniVig,'-','') AS fecha_Ini_Vig
,REPLACE(sehope.OpFecfinVig,'-','') AS fecha_Fin_Vig
 ,sehsupram.OpDetRPrima_Actuarial  AS Prima_Pura
,sehsupram.OpDetRPrima_Actuarial + sehsupram.OpDetRAjuste_Comercial AS Prima_Comercial_emitida
,(sehsupram.OpDetRPrima_Actuarial + sehsupram.OpDetRAjuste_Tecnico + sehsupram.OpDetRGExpl_GAdqui + sehsupram.OpDetRAjuste_Comercial + sehsupram.OpDetRRecargos + sehsupram.OpDetRImpuestos_Tasas) AS premio
,sehsuprambas.SupBasSumAseg AS Suma_Asegurada

,IF(SEHOPE.OpCabEcon='0',"Activa","Anulada")  AS Estado_poliza
,OpCabEnProc AS Endoso_en_Proceso
,sehope.OpCabinBoxSrvId AS Cod_Solicitud
,  CASE
WHEN sehope.OpCabinBoxSrvId=1 THEN 'PENDIENTE ASEGURADO'
WHEN sehope.OpCabinBoxSrvId=15 THEN 'PENDIENTE OPERACIONES'
WHEN sehope.OpCabinBoxSrvId=91 THEN 'RECHAZADA'
WHEN sehope.OpCabinBoxSrvId=2 AND sehope.opmonorampolnum=0 THEN 'Vuelve a proceso de emisión (Rechazo)'
WHEN sehope.OpCabinBoxSrvId=0 AND sehope.opmonorampolnum=0 THEN 'Vuelve a proceso de emisión (Rechazo)'
WHEN sehope.OpCabinBoxSrvId=55 THEN 'COTIZADA'

ELSE 'POLIZA EMITIDA'

END AS Estado_Solicitud
,sehope.OpFlagRefac

FROM sehope

INNER JOIN gntdaf
ON sehope.OpeDafCod=gntdaf.DafCod
 INNER JOIN gntdaftdo
 ON sehope.OpeDafCod=gntdaftdo.DafCod AND gntdaftdo.TdoCod=  (SELECT MIN(gntdaftdo.TdoCod) FROM  gntdaftdo WHERE sehope.OpeDafCod=gntdaftdo.DafCod GROUP BY gntdaftdo.DafCod) -- AND gntdaftdo.DafTdoPrf=1

LEFT JOIN setint1
ON sehope.OpeIntTip=setint1.IntTip AND sehope.OpeInt1Cod=setint1.Int1Cod

LEFT JOIN sehsuprambas
        ON (sehope.EmpCod = sehsuprambas.EmpCod)  AND (sehope.ArtCod = sehsuprambas.ArtCod) AND (sehope.SpolNum = sehsuprambas.SpolNum) AND (sehope.SucCod = sehsuprambas.SucCod)  AND sehsuprambas.SpolSspoNum=0

LEFT JOIN sehsup
        ON (sehope.EmpCod = sehsup.EmpCod)  AND (sehope.ArtCod = sehsup.ArtCod) AND (sehope.SpolNum = sehsup.SpolNum) AND (sehope.SucCod = sehsup.SucCod) AND sehsup.SpolSspoNum=0
LEFT JOIN sehsupram
        ON (sehope.EmpCod = sehsupram.EmpCod)  AND (sehope.ArtCod = sehsupram.ArtCod) AND (sehope.SpolNum = sehsupram.SpolNum) AND (sehope.SucCod = sehsupram.SucCod) AND sehsupram.SpolSspoNum=0

LEFT JOIN gntdafmail
ON sehope.OpeDafCod=gntdafmail.DafCod   AND dafmailsec=  (SELECT MAX(dafmailsec) FROM  gntdafmail WHERE sehope.OpeDafCod=gntdafmail.DafCod GROUP BY gntdafmail.DafCod)

WHERE sehope.artcod=303
AND sehope.EmpCod='S' AND sehope.SucCod='CC'
AND gntdaf.DafPfApel <> 'WEBER'
