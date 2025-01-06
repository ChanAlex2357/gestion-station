CREATE OR REPLACE  VIEW "FACTUREFOURNISSEURFILLECPL" AS 
  SELECT 
f.ID ,
f.IDFACTUREFOURNISSEUR ,
f.IDPRODUIT ,
p.VAL AS IDPRODUITLIB,
f.QTE ,
f.PU ,
f.REMISES ,
f.IDBCDETAIL ,
f.TVA ,
f.IDDEVISE,
CAST(f.QTE * f.PU AS NUMBER(30,2)) AS montantht,
CAST(f.QTE * f.PU + (f.QTE * f.PU * f.TVA/100) AS NUMBER(30,2)) AS montantttc,
CAST(f.QTE * f.PU * f.TVA/100 AS NUMBER(30,2)) AS montanttva,
CAST((nvl(f.remises/100,0))*(f.QTE * f.PU) AS NUMBER(30,2)) AS montantRemise,
CAST((1-nvl(f.remises/100,0))*(f.QTE * f.PU) AS NUMBER(30,2)) AS montant
FROM FACTUREFOURNISSEURFILLE f 
LEFT JOIN FACTUREFOURNISSEUR f2 ON f2.ID = f.IDFACTUREFOURNISSEUR 
LEFT JOIN PRODUIT p ON p.ID = f.IDPRODUIT ;


CREATE OR REPLACE VIEW "VENTE_DETAILS_CPL"  AS 
  SELECT vd.ID,
          vd.IDVENTE,
          v.DESIGNATION AS IDVENTELIB,
          vd.IDPRODUIT,
          p.VAL AS IDPRODUITLIB,
          vd.IDORIGINE,
          vd.QTE,
          VD.pu
             AS PU,
         	CAST((nvl(vd.remise/100,0))*(vd.QTE * vd.PU) AS NUMBER(30,2)) AS montantRemise,
            CAST((1-nvl(vd.remise/100,0))*(vd.QTE * vd.PU) AS NUMBER(30,2)) AS montant,
          vd.iddevise AS iddevise,
          vd.tauxDeChange AS tauxDeChange,
          vd.tva AS tva,
          v.idclient,
          v.idclientlib,
          vd.designation
     FROM VENTE_DETAILS vd
          LEFT JOIN VENTE_LIB v ON v.ID = vd.IDVENTE
          LEFT JOIN PRODUIT p ON p.ID = vd.IDPRODUIT;


CREATE OR REPLACE FORCE VIEW "VENTEMONTANT" AS 
  SELECT v.ID,
            cast(SUM ((1-nvl(vd.remise/100,0))*(NVL (vd.QTE, 0) * NVL (vd.PU, 0))) as number(30,2)) AS montanttotal,
            cast(SUM ( (NVL (vd.QTE, 0) * NVL (vd.PuAchat, 0))) as number(30,2)) AS montanttotalachat,
            cast(SUM ((1-nvl(vd.remise/100,0))* (NVL (vd.QTE, 0) * NVL (vd.PU, 0))* (NVL (VD.TVA , 0))/100) as number(30,2)) AS montantTva,
            cast(SUM ((1-nvl(vd.remise/100,0))* (NVL (vd.QTE, 0) * NVL (vd.PU, 0))* (NVL (VD.TVA , 0))/100)+SUM ((1-nvl(vd.remise/100,0))* (NVL (vd.QTE, 0) * NVL (vd.PU, 0)))as number(30,2))  as montantTTC,
            NVL (vd.IDDEVISE,'AR') AS IDDEVISE,
            cast(SUM ( (1-nvl(vd.remise/100,0))*(NVL (vd.QTE, 0) * NVL (vd.PU, 0)*NVL(VD.TAUXDECHANGE,1) )* (NVL (VD.TVA , 0))/100)+SUM ((1-nvl(vd.remise/100,0))* (NVL (vd.QTE, 0) * NVL (vd.PU, 0)*NVL(VD.TAUXDECHANGE,1)))as number(30,2)) as montantTTCAR
       FROM VENTE_DETAILS vd LEFT JOIN VENTE v ON v.ID = vd.IDVENTE
   GROUP BY v.ID, vd.IDDEVISE;

CREATE OR REPLACE VIEW "FACTUREFOURNISSEURMONTANT"  AS 
  SELECT v.ID,
            cast(SUM ((1-nvl(vd.remises/100,0))* (NVL (vd.QTE, 0) * NVL (vd.PU, 0))) as number(30,2)) AS montanttotal, 
            cast(SUM ((1-nvl(vd.REMISES /100,0))* (NVL (vd.QTE, 0) * NVL (vd.PU, 0))* (NVL (VD.TVA , 0))/100) as number(30,2)) AS montantTva,
            cast(SUM ((1-nvl(vd.remises/100,0))* (NVL (vd.QTE, 0) * NVL (vd.PU, 0))* (NVL (VD.TVA , 0))/100)+SUM ((1-nvl(vd.remises/100,0))* (NVL (vd.QTE, 0) * NVL (vd.PU, 0)))as number(30,2))  as montantTTC,
            NVL (vd.IDDEVISE,'AR') AS IDDEVISE,
            nvl (vd.tauxdechange,0) AS tauxdechange
            FROM FactureFournisseurFille vd LEFT JOIN facturefournisseur v ON v.ID = vd.idfacturefournisseur
   GROUP BY v.ID, vd.IDDEVISE,vd.tauxdechange;