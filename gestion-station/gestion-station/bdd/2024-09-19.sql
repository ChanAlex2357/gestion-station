

INSERT INTO MENUDYNAMIQUE
(ID, LIBELLE, ICONE, HREF, RANG, NIVEAU, ID_PERE)
VALUES('MNDSN287', 'ECRITURE', 'fa-pencil', '#', 1, 2, 'MNDN274');

INSERT INTO MENUDYNAMIQUE
(ID, LIBELLE, ICONE, HREF, RANG, NIVEAU, ID_PERE)
VALUES('MNDSN285', 'LIste', 'fa fa-list', 'module.jsp?but=compta/ecriture/sousecriture-liste.jsp', 2, 3, 'MNDSN287');

INSERT INTO MENUDYNAMIQUE
(ID, LIBELLE, ICONE, HREF, RANG, NIVEAU, ID_PERE)
VALUES('MNDSN286', 'Saisie', 'fa fa-plus', 'module.jsp?but=compta/ecriture/saisie-ecriture-multiple.jsp', 1, 3, 'MNDSN287');

-- PHARMACIE_GALLOIS.REPORTCAISSELIB source


INSERT INTO TAUXDECHANGE
(ID, IDDEVISE, TAUX, DATY)
VALUES('TX000031', 'AR', 1, TIMESTAMP '2024-07-30 00:00:00.000000');


CREATE OR REPLACE  VIEW REPORTCAISSE_devise (ID, IDCAISSE, IDCAISSELIB, MONTANT, MONTANTTHEORIQUE, DATY, ETAT,iddevise, ETATLIB) AS 
  SELECT 
r.ID ,
r.IDCAISSE ,
c.VAL AS IDCAISSELIB,
r.MONTANT ,
r.MONTANTTHEORIQUE ,
r.DATY ,
r.ETAT ,
c.iddevise,
CASE 
	WHEN r.ETAT = 0 
	THEN 'ANNULEE'
	WHEN r.ETAT = 1 
	THEN 'CREE'
	WHEN r.ETAT = 11 
	THEN 'VALIDEE'
END AS ETATLIB 
FROM REPORTCAISSE r 
LEFT JOIN CAISSE c ON c.ID  = r.IDCAISSE ;



CREATE MATERIALIZED VIEW V_ETATCAISSE_devise_AR 
build IMMEDIATE
 refresh complete
 START WITH sysdate
 NEXT sysdate + INTERVAL '120' MINUTE AS 
SELECT 
	r.ID,
	r.IDCAISSE ,
	c.val AS idcaisseLib,
	c.idtypecaisse,
	tc.desce AS idtypecaisselib,
	c.idpoint,
	p.desce AS idpointlib,
	r.DATY dateDernierReport,
	CAST(NVL(r.MONTANT*taux.taux,0) AS number(30,2)) montantDernierReport,
	CAST(NVL(mvt.debit,0) AS number(30,2)) debit, 
	CAST(NVL(mvt.credit,0) AS number(30,2)) credit, 
	CAST((NVL(mvt.credit,0)+NVL(r.MONTANT*taux.taux,0)-NVL(mvt.debit,0))  AS number(30,2)) reste,
	'AR' AS devise
FROM 
	REPORTCAISSE_devise r,
	(
		SELECT 
			r.IDCAISSE ,
			MAX(r.DATY) maxDateReport
		FROM 
			REPORTCAISSE_devise r 
		WHERE 
			r.ETAT = 11 
			AND r.DATY < sysdate
		GROUP BY r.IDCAISSE
	) rm,
	(
		SELECT 
			m.IDCAISSE ,
			SUM(nvl((m.DEBIT*t.taux),0)) DEBIT , 
			SUM(nvl((m.CREDIT*t.taux) ,0)) CREDIT 
		FROM 
			MOUVEMENTCAISSE m ,
			(
				SELECT 
					r.IDCAISSE ,
					MAX(r.DATY) maxDateReport
				FROM 
					REPORTCAISSE r 
				WHERE 
					r.ETAT = 11 
					AND r.DATY < sysdate
				GROUP BY r.IDCAISSE
			) rm,
			--ajout jointure table tauxdechange
			( SELECT
						ta.*
					FROM
						TAUXDECHANGE ta,
						(
						SELECT 
										max(daty) AS daty,
										iddevise
						FROM 
										TAUXDECHANGE t
							------mipetraka eto ilay date en params		
						WHERE
							daty <= sysdate
						GROUP BY iddevise) tmax
					WHERE
						ta.daty = tmax.daty 
						AND ta.iddevise = tmax.iddevise
			) t
		WHERE 
			m.iddevise= t.iddevise(+)
			AND m.IDCAISSE = rm.idcaisse(+)
			AND m.DATY > rm.maxDateReport
			AND m.DATY <=  sysdate
		GROUP BY m.IDCAISSE
	) mvt,
	--ajout jointure table tauxdechange
	( SELECT
						ta.*
					FROM
						TAUXDECHANGE ta,
						(
						SELECT 
										max(daty) AS daty,
										iddevise
						FROM 
										TAUXDECHANGE t
							------mipetraka eto ilay date en params		
						WHERE
							daty <= sysdate
						GROUP BY iddevise) tmax
					WHERE
						ta.daty = tmax.daty 
						AND ta.iddevise = tmax.iddevise
			) taux,
	caisse c,
	typecaisse tc,
	point p
WHERE 
	r.DATY = rm.maxDateReport
	AND r.IDDEVISE =taux.iddevise (+)
	AND r.ETAT = 11
	AND r.IDCAISSE = rm.IDCAISSE
	AND r.IDCAISSE = c.ID(+)
	AND r.IDCAISSE = mvt.idcaisse(+)
	AND c.IDTYPECAISSE = tc.ID (+)
	AND c.IDPOINT = p.ID ;














