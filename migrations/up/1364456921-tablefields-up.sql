ALTER SESSION SET CURRENT_SCHEMA = SYSDBA;
	SET SQLBLANKLINES ON
	SET SQLTERMINATOR ';'
ALTER TABLE SYSDBA.KPSS ADD GOGO CHAR(12 BYTE);
 exec SYSDBA.FB_ADD_FIELD_ST_DESC ('KPSS', 'GOGO', 'CHAR(12 BYTE)', 'WHERE THE COMMENT?');
COMMIT;
