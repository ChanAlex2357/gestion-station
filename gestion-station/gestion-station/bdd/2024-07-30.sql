alter table TYPEGAINPERTE add estdoubleecriture number(1);

alter table pertegainimprevue add tva number(4,2);

CREATE or replace VIEW pertegainimprevuelib
AS
SELECT
pgi.*,
tgp.val AS TYPE,
tgp.desce AS compte,
case when perte > 0 then perte + perte * tva/100 else gain + gain * tva/100 end as montantttc,
case when perte > 0 then perte else gain end as montantht,
case when perte > 0 then perte * tva/100 else gain * tva/100 end as montanttva
FROM pertegainimprevue pgi
LEFT JOIN typegainperte tgp on pgi.idtypegainperte = tgp.id;
