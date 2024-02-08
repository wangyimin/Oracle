SELECT * FROM DUAL 
MODEL 
  DIMENSION BY(0 n) MEASURES('A' c) RULES(c [1] = 'C')
-----
N    C
0    A
1    C


SELECT * FROM DUAL
MODEL DIMENSION BY (0 n) MEASURES ('A' c)
      RULES (UPDATE c[1]='C',  
                    c[2]='X')
-----
N    C
0    A
2    X



SELECT * FROM DUAL
MODEL DIMENSION BY (0 n) MEASURES ('A' c)
      RULES UPDATE (c[1]='C',
                    c[2]='X')
-----
N    C
0    A


SELECT * FROM DUAL
MODEL DIMENSION BY (0 n) MEASURES ('A' c)
      RULES (c[n BETWEEN 0 and 1]='C')
-----
N    C
0    C


c[ n = 1 ] =          n��1�̎��̂�
c[ n in (0, 1) ] =    n��0�܂���1�̎��̂�
c[ ANY ] =            ���݂��邷�ׂẴZ���B n IS ANY�̏ȗ��`
c[ n ] =              n = n�̏ȗ��`�BANY�Ɠ���
c[ n + 1 ] =          n = n + 1�̏ȗ��`�B�Ȃɂ��K�����Ȃ�
c[ n IS ANY ] =       ���݂��邷�ׂẴZ���B ANY�Ɠ���


SELECT * FROM DUAL
MODEL DIMENSION BY (0 n) MEASURES ('A' c)
      RULES (c[FOR n IN (0, 1, 2)]='C')
-----
N    C
0    C
1    C
2    C


FOR n IN (1, 2, 3)                  IN���X�g
FOR n FROM 1 TO 3 INCREMENT 1       �J��Ԃ�
FOR n IN (SELECT col FROM table)    �T�u�N�G��


SELECT * FROM DUAL 
MODEL DIMENSION BY (0 n) MEASURES ('A' c)
      RULES (c[DECODE(c[0], 'A' ,1, 2)]='C')
-----
N    C
0    A
1    C


select column_value from table(sys.odcinumberlist(1,2,3,4,5))


WITH t as (
  SELECT 100 as LN, 'Apple' as ITEM, 20 as QTY FROM dual
  UNION ALL
  SELECT 200 as LN, 'Apple' as ITEM, 20 as QTY FROM dual
  UNION ALL
  SELECT 100 as LN, 'Orange' as ITEM, 20 as QTY FROM dual
)
SELECT * FROM t
MODEL DIMENSION BY (ln, item) MEASURES (10 qty)
      RULES (UPSERT qty[ln in (100, 200, 300), 'Orange'] = 100)
-------------------
LN    ITEM     QTY
100   Apple    10
200   Apple    10
100   Orange   100


WITH t as (
  SELECT 100 as LN, 'Apple' as ITEM, 20 as QTY FROM dual
  UNION ALL
  SELECT 200 as LN, 'Apple' as ITEM, 20 as QTY FROM dual
  UNION ALL
  SELECT 100 as LN, 'Orange' as ITEM, 20 as QTY FROM dual
)
SELECT * FROM t
MODEL DIMENSION BY (ln, item) MEASURES (10 qty)
      RULES (UPSERT ALL qty[ln in (100, 200, 300), 'Orange'] = 100)
-------------------
LN    ITEM     QTY
100   Apple    10
200   Apple    10
100   Orange   100
200   Orange   100


UPDATE              �K������s���X�V����B�ǉ��͂��Ȃ��B
UPSERT (default)    �K������s���X�V����B�Y������Ӓl�̂Ƃ����݂��Ȃ��s��ǉ�����B
UPSERT ALL          �K������s���X�V����B�Y������Ӓl�ƕ]���l�����݂��Ă��鎞�A�]�����̒l���w�肳�ꂽ��Ӓl�ɂȂ��Ƃ����s�ɂ���Βǉ�����B


SELECT * FROM DUAL
MODEL DIMENSION BY (0 n) MEASURES ('A' c)
      RULES (c[FOR n IN (0, 1, 5)] = CV(n))
-----
N    C
0    0
1    1
5    5


SELECT * FROM DUAL
MODEL DIMENSION BY (0 id) MEASURES (0 value, 0 doubled) 
      RULES (value[0] = 100,
             value[1] = 500,
             value[2] = 300,
             value[3] = 600,
             doubled[ANY] = value[CV()] * 2)
ORDER BY ID
----------------------
ID    VALUE    DOUBLED
0     100      200
1     500      1000
2     300      600
3     600      1200


SELECT * FROM DUAL
MODEL DIMENSION BY (0 id) MEASURES (0 value, 0 prev)
      RULES (value[0] = 100,
             value[1] = 500,
             value[2] = 300,
             value[3] = 600,
             prev[ANY] = value[CV() - 1])
ORDER BY ID
----------------------
ID    VALUE    PREV
0     100      NULL
1     500      100
2     300      500
3     600      300


WITH t AS (
  SELECT 1 as ID, 100 as VALUE FROM DUAL UNION ALL SELECT  6, 500 FROM DUAL 
  UNION ALL
  SELECT 10 as ID, 300 as VALUE FROM DUAL UNION ALL SELECT 20, 600 FROM DUAL
)
SELECT * FROM t
MODEL DIMENSION BY (ROW_NUMBER() OVER(ORDER BY id) rn)
      MEASURES (id, value, 0 prev)
      RULES (prev[ANY] = value[CV() - 1])
--------------------------
RN    ID    VALUE    PREV
1     1     100      NULL
2     6     500      100
3     10    300      500
4     20    600      300


SELECT * FROM DUAL
MODEL DIMENSION BY (0 id) MEASURES (0 value, 0 run_sum1, 0 run_sum2)
      RULES (value[0] = 100,
             value[1] = 500,
             value[2] = 300,
             value[3] = 600,
             run_sum1[ANY] = SUM(value)[id <= CV()],
             run_sum2[ANY] = SUM(value) OVER (ORDER BY id))
ORDER BY id
----------------------------------
ID    VALUE    RUN_SUM1    RUN_SUM2
0     100      100         100
1     500      600         600
2     300      900         900
3     600      1500        1500


SELECT * FROM DUAL 
MODEL DIMENSION BY (0 id) MEASURES (0 value, 0 max1, 0 max2)
      RULES (value[0] = 100, value[1] = 500, value[2] = 300, value[3] = 600,
             max1[id IN (0, 1)] = MAX(value)[ANY], 
             max2[id IN (0, 1)] = MAX(value) OVER ())
ORDER BY id
----------------------------------
ID    VALUE    MAX1    MAX2
0     100      600     500
1     500      600     500
2     300      NULL    NULL
3     600      NULL    NULL


RETURN ALL ROWS       DEFAULT    ���ׂĂ̍s��Ԃ��܂��B
RETURN UPDATED ROWS              MODEL��RULES��ő���X�V���ꂽ�s�݂̂�Ԃ��܂��B


KEEP NAV              DEFAULT    ���݂��Ȃ����l�Z���̒l��NULL�Ƃ��ď�������
IGNORE NAV                       ���݂��Ȃ����l�Z���̒l0�Ƃ��ď�������


UNIQUE DIMENSION      DEFAULT    �Y���̓��j�[�N�łȂ���΂Ȃ�Ȃ��B
UNIQUE SINGLE REFERENCE          �Y���̏d���������邪�A�d���Z���ɉE�ӂŃA�N�Z�X����ꍇ�͕����Z����Ԃ��Ȃ��悤�C�����Ȃ���΂Ȃ�Ȃ��B


