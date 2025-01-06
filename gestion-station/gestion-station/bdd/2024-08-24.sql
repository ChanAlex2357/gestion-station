-- GALLOIS.FACTUREFOURNISSEURCPL source

CREATE OR REPLACE FORCE VIEW "FACTUREFOURNISSEURCPL" 
("ID", "IDFOURNISSEUR", "IDFOURNISSEURLIB", "IDMODEPAIEMENT", "IDMODEPAIEMENTLIB", "DATY", "DESIGNATION", "DATEECHEANCEPAIEMENT", 
"ETAT", "ETATLIB", "REFERENCE", "IDBC", "IDMAGASIN", "DEVISE", "TAUX", "IDMAGASINLIB", "IDDEVISE", "MONTANTTVA", "MONTANTHT", 
"MONTANTTTC", "MONTANTTTCAR", "MONTANTPAYE", "MONTANTRESTE", "TAUXDECHANGE","idPrevision") AS 
  SELECT f.ID,
       f.IDFOURNISSEUR,
       f2.NOM  AS IDFOURNISSEURLIB,
       f.IDMODEPAIEMENT,
       m.VAL   AS IDMODEPAIEMENTLIB,
       f.DATY,
       f.DESIGNATION,
       f.DATEECHEANCEPAIEMENT,
       f.ETAT,
       CASE
           WHEN f.ETAT = 1
               THEN 'CREE'
           WHEN f.ETAT = 0
               THEN 'ANNULEE'
           WHEN f.ETAT = 11
               THEN 'VISEE'
           END AS ETATLIB,
       f.REFERENCE,
       f.IDBC,
       f.IDMAGASIN,
       f.DEVISE,
       f.TAUX,
       p.VAL   AS idMagasinLib,
       f3.IDDEVISE,
       cast(f3.MONTANTTVA as number(30,2)) as MONTANTTVA,
       	CAST(f3.MONTANTTTC-f3.MONTANTTVA as number(30,2)) AS MONTANTHT,
          cast(f3.MONTANTTTC as number(30,2)) as montantttc,
          cast(f3.MONTANTTTC*f3.tauxdechange as number(30,2)) as MONTANTTTCAR,
          cast(nvl(mv.debit,0) AS NUMBER(30,2)) AS montantpaye,
          cast(f3.MONTANTTTC-nvl(mv.debit,0) AS NUMBER(30,2)) AS montantreste,
           cast(nvl(f3.tauxdechange,0) AS  NUMBER(30,2)) AS tauxdechange,
           '' as idPrevision
FROM FACTUREFOURNISSEUR f
         LEFT JOIN FOURNISSEUR f2 ON f2.ID = f.IDFOURNISSEUR
         LEFT JOIN MODEPAIEMENT m ON m.ID = f.IDMODEPAIEMENT
         LEFT JOIN MAGASIN p ON p.ID = f.IDMAGASIN
         JOIN FACTUREFOURNISSEURMONTANT f3 ON f.ID = f3.id 
         LEFT JOIN mouvementcaisseGroupeFacture mv ON f.id=mv.IDORIGINE 
         --LEFT JOIN prevision prev ON prev.idfacture=f.id
        ;
        
        CREATE OR REPLACE FORCE VIEW "RESULTATPREVEFFECTIFTOUS"  AS 
  SELECT 
t.daty,
nvl(r.debit,0) AS debit,
nvl(r.credit,0) AS credit,
(CAST (to_char( t.daty, 'IW') AS INTEGER)) AS semaine,
extract(YEAR FROM t.daty) AS annee,
EXTRACT (MONTH FROM t.daty) AS mois
FROM tousLesDate t 
left join resultatPrevisionnelEffectif r ON t.daty=r.daty ;

CREATE OR REPLACE FORCE VIEW "RESULTATPREVISIONNELEFFECTIF" ("DATY", "DEBIT", "CREDIT") AS 
  SELECT daty,
sum(debit) AS debit, 
sum(credit) AS credit
FROM MOUVEMENTCAISSE m  group by daty;

CREATE OR REPLACE FORCE VIEW RESULTATPREVISIONNELTOUS AS 
  SELECT 
t.daty,
nvl(r.debit,0) AS debit,
nvl(r.credit,0) AS credit,
(CAST (to_char( t.daty, 'IW') AS INTEGER)) AS semaine,
extract(YEAR FROM t.daty) AS annee,
EXTRACT (MONTH FROM t.daty) AS mois
FROM tousLesDate t  left join resultatPrevisionnel r ON t.daty=r.daty   ;

