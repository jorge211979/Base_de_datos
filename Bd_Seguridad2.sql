------JORGE ALBERTO LÓPEZ BARBOZA-----

use seguridad2
--systemmtric key--
create table encriptacionsimetrica(
nombres varchar(100),
docnum varbinary(128)
)

--creación de una base de datos maestra--
create master key encryption by password = 'miclavesegura'

---Ceación de Certificado---
create certificate Miprimercertificado with subject = 'Memoria de Certificado',
expiry_date = '05-13-2020'

---Crear Nuestra llave Simetrica---
create symmetric key millavesimetrica
with
key_source = 'miclavefuente',
identity_value = 'miidentificacion',
algorithm = AES_256
encryption by certificate Miprimercertificado

select name, algorithm_desc
from sys.symmetric_keys

----insertar valores----
open symmetric key millavesimetrica
decryption by certificate Miprimercertificado

insert into encriptacionsimetrica(nombres,docnum)
values ('Jorge', ENCRYPTBYKEY(KEY_GUID('millavesimetrica'),'123'))

----Practica 9-----
close symmetric key millavesimetrica

open symmetric key millavesimetrica
decryption by certificate Miprimercertificado

select nombres, convert(varchar(8),
DECRYPTBYKEY (docnum)) as docnum
from encriptacionsimetrica

CREATE LOGIN Usuario2 WITH PASSWORD = N'123'
CREATE USER Usuario2 FOR LOGIN Usuario2
GRANT SELECT ON encriptacionsimetrica TO Usuario2

EXECUTE AS USER = 'Usuario2'
OPEN SYMMETRIC KEY millavesimetrica DECRYPTION BY CERTIFICATE Miprimercertificado;
SELECT nombres, CONVERT(varchar(8),DECRYPTBYKEY(docnum)) as docnum
FROM encriptacionsimetrica
REVERT

GRANT CONTROL ON CERTIFICATE :: Miprimercertificado TO Usuario2

GRANT CONTROL ON SYMMETRIC KEY :: millavesimetrica TO Usuario2

EXECUTE AS USER = 'Usuario2'
OPEN SYMMETRIC KEY millavesimetrica DECRYPTION BY CERTIFICATE Miprimercertificado;
SELECT nombres, CONVERT(varchar(8),DECRYPTBYKEY(docnum)) AS docnum
FROM encriptacionsimetrica
REVERT