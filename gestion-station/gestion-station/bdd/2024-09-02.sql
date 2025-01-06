CREATE OR REPLACE VIEW "PREVISIONAVECMVTCAISSE" AS 
  SELECT p."ID",p."DESIGNATION",p."IDCAISSE",p."IDVENTEDETAIL",p."IDVIREMENT",p."DEBIT",p."CREDIT",p."DATY",p."ETAT",p."IDOP",p."IDORIGINE",p."IDDEVISE",
  p."TAUX",p."IDTIERS",p."COMPTE",p."IDFACTURE",nvl(m.montantMere*nvl(m.taux,1),0) AS effectifdeb,nvl(m.montantCredit*nvl(m.taux,1),0) AS effectifCred 
FROM PREVISIONVALIDE p LEFT JOIN MvtCaisseSomPrevisionGroup m ON p.id=m.id2;

CREATE OR REPLACE VIEW PREVISION_COMPLET_CPLPositif as
   SELECT * from PREVISION_COMPLET_CPL pr WHERE pr.DEPENSEECART >0 OR RECETTEECART >0;


CREATE OR REPLACE  VIEW "VENTEMONTANT" AS 
  SELECT v.ID,
            cast(SUM ((1-nvl(vd.remise/100,0))*(NVL (vd.QTE, 0) * NVL (vd.PU, 0))) as number(30,2)) AS montanttotal,
            cast(SUM ( (NVL (vd.QTE, 0) * NVL (vd.PuAchat, 0))) as number(30,2)) AS montanttotalachat,
            cast(SUM ((1-nvl(vd.remise/100,0))* (NVL (vd.QTE, 0) * NVL (vd.PU, 0))* (NVL (VD.TVA , 0))/100) as number(30,2)) AS montantTva,
            cast(SUM ((1-nvl(vd.remise/100,0))* (NVL (vd.QTE, 0) * NVL (vd.PU, 0))* (NVL (VD.TVA , 0))/100)+SUM ((1-nvl(vd.remise/100,0))* (NVL (vd.QTE, 0) * NVL (vd.PU, 0)))as number(30,2))  as montantTTC,
            NVL (vd.IDDEVISE,'AR') AS IDDEVISE,
            NVL(avg(vd.tauxDeChange),1 ) AS tauxDeChange,
            cast(SUM ( (1-nvl(vd.remise/100,0))*(NVL (vd.QTE, 0) * NVL (vd.PU, 0)*NVL(VD.TAUXDECHANGE,1) )* (NVL (VD.TVA , 0))/100)+SUM ((1-nvl(vd.remise/100,0))* (NVL (vd.QTE, 0) * NVL (vd.PU, 0)*NVL(VD.TAUXDECHANGE,1)))as number(30,2)) as montantTTCAR
       FROM VENTE_DETAILS vd LEFT JOIN VENTE v ON v.ID = vd.IDVENTE
   GROUP BY v.ID, vd.IDDEVISE;
  
  CREATE OR REPLACE  VIEW "VENTE_CPL"  AS 
  SELECT v.ID,
          v.DESIGNATION,
          v.IDMAGASIN,
          m.VAL AS IDMAGASINLIB,
          v.DATY,
          v.REMARQUE,
          v.ETAT,
          CASE
             WHEN v.ETAT = 1 THEN 'CREE'
             WHEN v.ETAT = 11 THEN 'VISEE'
             WHEN v.ETAT = 0 THEN 'ANNULEE'
          END
             AS ETATLIB,
          v2.MONTANTTOTAL,
          v2.IDDEVISE,
          v.IDCLIENT,
          c.NOM AS IDCLIENTLIB,
          cast(V2.MONTANTTVA as number(30,2)) as MONTANTTVA,
          cast(V2.MONTANTTTC as number(30,2)) as montantttc,
          cast(V2.MONTANTTTCAR as number(30,2)) as MONTANTTTCAR,
          cast(nvl(mv.credit,0)-nvl(ACG.MONTANTPAYE, 0) AS NUMBER(30,2)) AS montantpaye,
          cast(V2.MONTANTTTC-nvl(mv.credit,0)-nvl(ACG.resteapayer_avr, 0) AS NUMBER(30,2)) AS montantreste,
          nvl(ACG.MONTANTTTC_avr, 0)  as avoir,
          v2.tauxDeChange AS tauxDeChange
     FROM VENTE v
          LEFT JOIN CLIENT c ON c.ID = v.IDCLIENT
          LEFT JOIN MAGASIN m ON m.ID = v.IDMAGASIN
          JOIN VENTEMONTANT v2 ON v2.ID = v.ID
          LEFT JOIN mouvementcaisseGroupeFacture mv ON v.id=mv.IDORIGINE
      LEFT JOIN AVOIRFCLIB_CPL_GRP ACG on ACG.IDVENTE = v.ID;