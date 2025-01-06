CREATE OR REPLACE VIEW "AVOIRFCFILLE_GRP" as 
SELECT
a.idavoirfc ,
CAST(nvl(sum(a.QTE * a.PU),0) AS NUMBER(30,2)) AS montantht,
CAST(nvl(sum( a.QTE * a.PU*a.TVA/100 ),0) AS NUMBER(30,2)) AS montanttva,
CAST(nvl(sum( (a.QTE * a.PU) + (a.QTE * a.PU*a.TVA/100) ),0) AS NUMBER(30,2)) AS montantttc,
CAST(nvl(sum(a.QTE * a.PU * nvl(a.TAUXDECHANGE,1)),0) AS NUMBER(30,2)) AS montanthtAR,
CAST(nvl(sum( (a.QTE * a.PU*a.TVA/100 ) * nvl(a.TAUXDECHANGE,1) ),0) AS NUMBER(30,2)) AS montanttvaAR,
CAST(nvl(sum( (a.QTE * a.PU) + (a.QTE * a.PU*a.TVA/100) * nvl(a.TAUXDECHANGE,1) ),0) AS NUMBER(30,2)) AS montantttcar,
MAX(TAUXDECHANGE) as tauxdechange,
a.IDDEVISE
FROM AVOIRFCFILLE a
GROUP BY a.idavoirfc, a.IDDEVISE;

CREATE OR REPLACE VIEW "AVOIRFCFILLE_GRP" as 
SELECT
a.idavoirfc ,
CAST(nvl(sum(a.QTE * a.PU),0) AS NUMBER(30,2)) AS montantht,
CAST(nvl(sum( a.QTE * a.PU*a.TVA/100 ),0) AS NUMBER(30,2)) AS montanttva,
CAST(nvl(sum( (a.QTE * a.PU) + (a.QTE * a.PU*a.TVA/100) ),0) AS NUMBER(30,2)) AS montantttc,
CAST(nvl(sum(a.QTE * a.PU * nvl(a.TAUXDECHANGE,1)),0) AS NUMBER(30,2)) AS montanthtAR,
CAST(nvl(sum( (a.QTE * a.PU*a.TVA/100 ) * nvl(a.TAUXDECHANGE,1) ),0) AS NUMBER(30,2)) AS montanttvaAR,
CAST(nvl(sum( (a.QTE * a.PU* nvl(a.TAUXDECHANGE,1)) + (a.QTE * a.PU*a.TVA/100) * nvl(a.TAUXDECHANGE,1) ),0) AS NUMBER(30,2)) AS montantttcar,
MAX(TAUXDECHANGE) as tauxdechange,
a.IDDEVISE
FROM AVOIRFCFILLE a
GROUP BY a.idavoirfc, a.IDDEVISE;