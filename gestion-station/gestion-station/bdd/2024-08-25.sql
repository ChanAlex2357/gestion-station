CREATE or REPLACE VIEW previsionValide AS SELECT * FROM prevision WHERE etat>=1;

CREATE OR REPLACE FORCE VIEW "RESULTATPREVISIONNELEFFECTIF" AS 
  SELECT daty,
sum(debit) AS debit, 
sum(credit) AS credit
FROM MOUVEMENTCAISSE_VISE  group by daty;

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

CREATE OR REPLACE FORCE VIEW "RESULTATPREVISIONNEL" AS 
  SELECT 
daty,
sum(debit) AS debit, 
sum(credit) AS credit 
FROM PREVISIONvalide p  group by daty;

CREATE OR REPLACE FORCE VIEW RESULTATPREVISIONNELTOUS AS 
  SELECT 
t.daty,
nvl(r.debit,0) AS debit,
nvl(r.credit,0) AS credit,
(CAST (to_char( t.daty, 'IW') AS INTEGER)) AS semaine,
extract(YEAR FROM t.daty) AS annee,
EXTRACT (MONTH FROM t.daty) AS mois
FROM tousLesDate t  left join resultatPrevisionnel r ON t.daty=r.daty   ;

CREATE TABLE MVTCAISSEPREVISION (
	ID VARCHAR2(100) NOT NULL PRIMARY KEY,
	ID1 VARCHAR2(100),
	ID2 VARCHAR2(100),
	MONTANTMERE NUMBER(30,2),
	ETAT INTEGER,
	REMARQUE VARCHAR2(200),
	MONTANTCREDIT NUMBER(30,2),
	devise varchar2(50),
	taux INTEGER
);
ALTER TABLE MVTCAISSEPREVISION ADD CONSTRAINT MVT_PREVISION_FK FOREIGN KEY (ID2) REFERENCES PREVISION(ID);
ALTER TABLE MVTCAISSEPREVISION ADD CONSTRAINT MVT_MVTCAISSE_FK FOREIGN KEY (ID1) REFERENCES MOUVEMENTCAISSE(ID);

create or replace view MvtCaissePrevisionVise as select * from MVTCAISSEPREVISION where etat>=1;

CREATE OR REPLACE VIEW mvtCaisseSomPrevisionGroup AS 
SELECT '-' AS id, '' AS id1,id2,etat,'-' AS remarque,sum(montantMere) AS montantMere,sum(montantCredit) AS montantCredit,nvl(max(taux),1) AS taux,devise  
FROM MVTCAISSEPREVISIONVise GROUP BY id2,etat,devise;

CREATE OR REPLACE VIEW mvtCaisseGroupPrevisionSom AS 
SELECT '-' AS id, id1,'' AS id2,etat,'-' AS remarque,sum(montantMere) AS montantMere,sum(montantCredit) AS montantCredit,nvl(max(taux),1) AS taux,devise 
FROM MVTCAISSEPREVISIONVise GROUP BY id1,etat,devise;

CREATE OR REPLACE VIEW PrevisionAvecMvtCaisse AS 
SELECT p.*,nvl(m.montantMere*m.taux,0) AS effectifdeb,nvl(m.montantCredit*m.taux,0) AS effectifCred 
FROM PREVISIONVALIDE p LEFT JOIN MvtCaisseSomPrevisionGroup m ON p.id=m.id2;

CREATE OR REPLACE FORCE VIEW RESULTATPREVISIONNELMVT AS 
  SELECT 
daty,
greatest(sum(debit-effectifdeb),0) AS debit, 
greatest(sum(credit-effectifCred),0) AS credit 
FROM PrevisionAvecMvtCaisse p  group by daty;

CREATE OR REPLACE FORCE VIEW RESULTATPREVISIONNELTOUSMVT AS 
  SELECT 
t.daty,
nvl(r.debit,0) AS debit,
nvl(r.credit,0) AS credit,
(CAST (to_char( t.daty, 'IW') AS INTEGER)) AS semaine,
extract(YEAR FROM t.daty) AS annee,
EXTRACT (MONTH FROM t.daty) AS mois
FROM tousLesDate t  left join resultatPrevisionnelMvt r ON t.daty=r.daty   ;
