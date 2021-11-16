--
-- PostgreSQL database dump
--

-- Dumped from database version 13.4
-- Dumped by pg_dump version 13.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: get_adr(jsonb); Type: FUNCTION; Schema: public; Owner: alexey
--

CREATE FUNCTION public.get_adr(u_id jsonb) RETURNS character varying
    LANGUAGE sql
    AS $$
    SELECT CASE
               WHEN count.cnt > 0
                   THEN 'true'
               ELSE 'false'
               END AS comment
    FROM (
             SELECT COUNT(doc -> 'id') cnt
             FROM adress_plus
             WHERE doc -> 'id' @> u_id
         ) AS count;
$$;


ALTER FUNCTION public.get_adr(u_id jsonb) OWNER TO alexey;

--
-- Name: increment(integer); Type: FUNCTION; Schema: public; Owner: alexey
--

CREATE FUNCTION public.increment(i integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
                RETURN i + 1;
        END;
$$;


ALTER FUNCTION public.increment(i integer) OWNER TO alexey;

--
-- Name: increment(character varying); Type: FUNCTION; Schema: public; Owner: alexey
--

CREATE FUNCTION public.increment(i character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
                RETURN (select min(price) from products where category like i);
                --RETURN i + 1;
        END;
$$;


ALTER FUNCTION public.increment(i character varying) OWNER TO alexey;

--
-- Name: work1(character varying); Type: FUNCTION; Schema: public; Owner: alexey
--

CREATE FUNCTION public.work1(i character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
        BEGIN
                RETURN (select min(price) from products where category like i);
                --RETURN i + 1;
        END;
$$;


ALTER FUNCTION public.work1(i character varying) OWNER TO alexey;

--
-- Name: work10(); Type: FUNCTION; Schema: public; Owner: alexey
--

CREATE FUNCTION public.work10() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        DELETE FROM orders WHERE prod_prod_id = OLD.product_id;
        DELETE FROM products WHERE product_id = OLD.product_id;
        RETURN NULL;
    END IF;
END;
$$;


ALTER FUNCTION public.work10() OWNER TO alexey;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.customers (
    userr_id integer NOT NULL,
    fio character varying(134) NOT NULL,
    birthday date NOT NULL,
    email character varying(134) NOT NULL,
    passw character varying(45) NOT NULL,
    dateofregistration date NOT NULL,
    contact_phone character varying(11) NOT NULL,
    discount character varying(45) NOT NULL
);


ALTER TABLE public.customers OWNER TO alexey;

--
-- Name: work2_getus(integer); Type: FUNCTION; Schema: public; Owner: alexey
--

CREATE FUNCTION public.work2_getus(u_id integer DEFAULT 0) RETURNS public.customers
    LANGUAGE sql
    AS $$
    SELECT *
    FROM customers
    WHERE userr_id = u_id;
$$;


ALTER FUNCTION public.work2_getus(u_id integer) OWNER TO alexey;

--
-- Name: work3(); Type: FUNCTION; Schema: public; Owner: alexey
--

CREATE FUNCTION public.work3() RETURNS TABLE(price1 integer, kolvo integer)
    LANGUAGE plpgsql
    AS $$
    BEGIN
    return QUERY ( SELECT price, qua from orders inner join products p on p.product_id = orders.prod_prod_id);
    END;
$$;


ALTER FUNCTION public.work3() OWNER TO alexey;

--
-- Name: work4(); Type: FUNCTION; Schema: public; Owner: alexey
--

CREATE FUNCTION public.work4() RETURNS TABLE(ommmm integer, shippingnn date, statunns integer)
    LANGUAGE plpgsql
    AS $$
begin
return QUERY (WITH RECURSIVE r(ord_id, shipping, st) AS (
   SELECT order_id, date_of_shipping, order_status
   FROM orders
   WHERE order_status = 1

   UNION all
   select *
      from
         (
         SELECT order_id,  date_of_shipping, order_status
         FROM orders
         WHERE order_status <= 5
         ) as a
)
select * from r);
end;
$$;


ALTER FUNCTION public.work4() OWNER TO alexey;

--
-- Name: work5(integer, integer); Type: PROCEDURE; Schema: public; Owner: alexey
--

CREATE PROCEDURE public.work5(a integer, b integer)
    LANGUAGE sql
    AS $$
INSERT INTO temp VALUES (a);
INSERT INTO temp VALUES (b);
$$;


ALTER PROCEDURE public.work5(a integer, b integer) OWNER TO alexey;

--
-- Name: work6(); Type: PROCEDURE; Schema: public; Owner: alexey
--

CREATE PROCEDURE public.work6()
    LANGUAGE plpgsql
    AS $$
begin
WITH RECURSIVE r(ord_id, shipping, st) AS (
   SELECT order_id, date_of_shipping, order_status
   FROM orders
   WHERE order_status = 1

   UNION all
   select *
      from
         (
         SELECT order_id,  date_of_shipping, order_status
         FROM orders
         WHERE order_status <= 5
         ) as a
)
--select * from r;
insert into temp1(tmp1, tmp2, tmp3)  SELECT  ord_id, shipping, st FROM r;
    --select avg(price) into mmm from products
end;
$$;


ALTER PROCEDURE public.work6() OWNER TO alexey;

--
-- Name: work7(numeric); Type: PROCEDURE; Schema: public; Owner: alexey
--

CREATE PROCEDURE public.work7(numeric)
    LANGUAGE plpgsql
    AS $_$
   DECLARE
        _id_order ALIAS FOR $1;
        crs_my CURSOR FOR select order_id, date_of_shipping, order_status from orders where
                                                      order_id = _id_order order by order_id;
        _order_id numeric;
        _date_of_shipping date;
        _order_status numeric;
   BEGIN
    OPEN crs_my;--открываем курсор
    LOOP --начинаем цикл по курсору
    FETCH crs_my INTO _order_id, _date_of_shipping, _order_status;
    IF NOT FOUND THEN EXIT;END IF;
    insert into temp1(tmp1, tmp2, tmp3)  values (_order_id, _date_of_shipping, _order_status);
    END LOOP;
    CLOSE crs_my; --закрываем курсор
   END;
   $_$;


ALTER PROCEDURE public.work7(numeric) OWNER TO alexey;

--
-- Name: work8_metadata(character varying); Type: PROCEDURE; Schema: public; Owner: alexey
--

CREATE PROCEDURE public.work8_metadata(name character varying)
    LANGUAGE plpgsql
    AS $$
    -- Инфа про метаданные:
    -- https://postgrespro.ru/docs/postgresql/9.6/infoschema-columns
    DECLARE
        myCursor CURSOR FOR
            SELECT column_name,
                   data_type
           -- INFORMATION_SCHEMA обеспечивает доступ к метаданным о базе данных.
           -- columns - данные о столбацых.
            FROM information_schema.columns
            WHERE table_name = name;
        -- RECORD - переменная, которая подстравивается под любой тип.
        tmp RECORD;
BEGIN
        OPEN myCursor;
        LOOP
            FETCH myCursor
            INTO tmp;
            EXIT WHEN NOT FOUND;
            RAISE NOTICE 'column name = %; data type = %', tmp.column_name, tmp.data_type;
        END LOOP;
        CLOSE myCursor;
END;
$$;


ALTER PROCEDURE public.work8_metadata(name character varying) OWNER TO alexey;

--
-- Name: work9(); Type: FUNCTION; Schema: public; Owner: alexey
--

CREATE FUNCTION public.work9() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    mstr varchar(30);
    astr varchar(100);
    retstr varchar(254);
BEGIN
    IF    TG_OP = 'INSERT' THEN
        astr = NEW.order_id;
        mstr := 'Add new order ';
        retstr := mstr || astr;
        INSERT INTO logs(text,added) values (retstr,NOW());
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        astr = NEW.order_id;
        mstr := 'Update order ';
        retstr := mstr || astr;
        INSERT INTO logs(text,added) values (retstr,NOW());
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        astr = OLD.order_id;
        mstr := 'Remove order ';
        retstr := mstr || astr;
        INSERT INTO logs(text,added) values (retstr,NOW());
        RETURN OLD;
    END IF;
END;
$$;


ALTER FUNCTION public.work9() OWNER TO alexey;

--
-- Name: a; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.a (
    id smallint,
    name_a character varying(10) NOT NULL
);


ALTER TABLE public.a OWNER TO alexey;

--
-- Name: adress_plus; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.adress_plus (
    doc jsonb
);


ALTER TABLE public.adress_plus OWNER TO alexey;

--
-- Name: b; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.b (
    id smallint,
    name_a character varying(10) NOT NULL
);


ALTER TABLE public.b OWNER TO alexey;

--
-- Name: base; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.base (
    id integer NOT NULL,
    title character varying(40),
    test integer
);


ALTER TABLE public.base OWNER TO alexey;

--
-- Name: bestselling; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.bestselling (
    prod_prod_id integer,
    sq bigint,
    sr money
);


ALTER TABLE public.bestselling OWNER TO alexey;

--
-- Name: copy_orders; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.copy_orders (
    order_id integer NOT NULL,
    date_of_shipping date NOT NULL,
    addres character varying(45) NOT NULL,
    order_status integer NOT NULL,
    creation_time timestamp without time zone NOT NULL,
    source character varying(45),
    prod_prod_id integer,
    cust_cust_id integer,
    man_man_id integer
);


ALTER TABLE public.copy_orders OWNER TO alexey;

--
-- Name: couriers; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.couriers (
    courier_id integer,
    car_type integer,
    login character varying,
    password character varying,
    salary integer
);


ALTER TABLE public.couriers OWNER TO alexey;

--
-- Name: logs; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.logs (
    text text,
    added timestamp without time zone
);


ALTER TABLE public.logs OWNER TO alexey;

--
-- Name: managers; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.managers (
    manager_id integer NOT NULL,
    fio character varying(134) NOT NULL,
    email character varying(134) NOT NULL,
    passw character varying(45) NOT NULL,
    acces_card integer NOT NULL,
    contact_phone character varying(11) NOT NULL
);


ALTER TABLE public.managers OWNER TO alexey;

--
-- Name: myemployees; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.myemployees (
    employeeid smallint NOT NULL,
    firstname character varying(30) NOT NULL,
    lastname character varying(40) NOT NULL,
    title character varying(50) NOT NULL,
    deptid smallint NOT NULL,
    managerid integer
);


ALTER TABLE public.myemployees OWNER TO alexey;

--
-- Name: ord_status; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.ord_status (
    data json
);


ALTER TABLE public.ord_status OWNER TO alexey;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    date_of_shipping date NOT NULL,
    addres character varying(45) NOT NULL,
    order_status integer NOT NULL,
    creation_time timestamp without time zone NOT NULL,
    source character varying(45),
    prod_prod_id integer,
    cust_cust_id integer,
    man_man_id integer,
    qua integer
);


ALTER TABLE public.orders OWNER TO alexey;

--
-- Name: orders_id_date; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.orders_id_date (
    orders_id integer,
    date_of_shipping date
);


ALTER TABLE public.orders_id_date OWNER TO alexey;

--
-- Name: orders_import; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.orders_import (
    doc json
);


ALTER TABLE public.orders_import OWNER TO alexey;

--
-- Name: products; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.products (
    product_id integer NOT NULL,
    articul integer NOT NULL,
    nme character varying(33) NOT NULL,
    category character varying(66) NOT NULL,
    weigth smallint NOT NULL,
    dateofrelease date NOT NULL,
    price integer NOT NULL
);


ALTER TABLE public.products OWNER TO alexey;

--
-- Name: sub; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.sub (
    id integer NOT NULL,
    count integer
);


ALTER TABLE public.sub OWNER TO alexey;

--
-- Name: table1; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.table1 (
    id smallint NOT NULL,
    var1 character varying(10) NOT NULL,
    valid_from_dttm date NOT NULL,
    valid_to_dttm date NOT NULL
);


ALTER TABLE public.table1 OWNER TO alexey;

--
-- Name: table2; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.table2 (
    id smallint NOT NULL,
    var2 character varying(10) NOT NULL,
    valid_from_dttm date NOT NULL,
    valid_to_dttm date NOT NULL
);


ALTER TABLE public.table2 OWNER TO alexey;

--
-- Name: temp; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.temp (
    tmp integer
);


ALTER TABLE public.temp OWNER TO alexey;

--
-- Name: temp1; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.temp1 (
    tmp1 integer,
    tmp2 date,
    tmp3 integer
);


ALTER TABLE public.temp1 OWNER TO alexey;

--
-- Name: tr; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.tr (
    nam character varying,
    kol integer
);


ALTER TABLE public.tr OWNER TO alexey;

--
-- Name: users; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.users (
    name text
);


ALTER TABLE public.users OWNER TO alexey;

--
-- Name: users_info_plus; Type: TABLE; Schema: public; Owner: alexey
--

CREATE TABLE public.users_info_plus (
    doc json
);


ALTER TABLE public.users_info_plus OWNER TO alexey;

--
-- Name: wr10; Type: VIEW; Schema: public; Owner: alexey
--

CREATE VIEW public.wr10 AS
 SELECT p.product_id
   FROM (public.orders o
     JOIN public.products p ON ((p.product_id = o.prod_prod_id)));


ALTER TABLE public.wr10 OWNER TO alexey;

--
-- Data for Name: a; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.a (id, name_a) FROM stdin;
2	b
2	c
3	d
\N	e
4	f
\N	g
\.


--
-- Data for Name: adress_plus; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.adress_plus (doc) FROM stdin;
{"id": 1, "house": {"floor": 1, "comment": "no ring", "apartam_num": 1}}
{"id": 2, "house": {"floor": 3, "comment": "lift repair", "apartam_num": 11}}
{"id": 0, "house": {"floor": 3, "comment": null, "apartam_num": 12}}
{"id": 44, "house": {"floor": 11, "comment": "two doors, flat number", "apartam_num": 70}}
\.


--
-- Data for Name: b; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.b (id, name_a) FROM stdin;
2	a
3	b
3	c
\N	d
4	e
5	f
6	g
\.


--
-- Data for Name: base; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.base (id, title, test) FROM stdin;
1	base_1	10
2	base_2	11
3	base_3	12
\.


--
-- Data for Name: bestselling; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.bestselling (prod_prod_id, sq, sr) FROM stdin;
938	1	$1,859,980.20
753	1	$1,211,747.04
652	2	$5,200,210.40
273	1	$39,447.54
550	1	$250,988.10
394	2	$4,467,928.78
51	1	$7,822.50
272	2	$640,426.62
781	1	$2,144,797.20
70	1	$464,335.20
839	2	$5,473,841.10
350	3	$1,298,620.68
874	1	$4,646,730.00
278	1	$933,958.70
406	1	$922,738.80
946	2	$1,386,762.24
176	1	$222,985.10
309	1	$14,861.20
292	1	$1,613,875.20
509	1	$769,410.00
663	2	$5,065,533.00
271	1	$2,157,317.76
417	1	$2,749,631.52
556	2	$834,843.97
764	3	$1,917,588.24
475	1	$2,085,333.90
641	1	$276,746.40
529	3	$1,082,250.26
638	1	$744,145.20
961	2	$2,621,131.84
888	1	$34,109.46
791	1	$872,607.12
775	2	$70,729.52
282	1	$264,250.80
940	1	$4,938,420.00
390	1	$666,755.60
173	1	$381,642.24
733	1	$521,760.96
269	1	$1,522,295.28
502	1	$3,759,079.50
189	1	$585,398.40
113	2	$452,747.40
257	2	$601,666.56
632	2	$702,767.88
658	1	$162,964.20
120	1	$511,440.16
578	1	$358,080.32
815	1	$324,493.40
349	1	$767,649.96
19	3	$2,886,085.12
160	1	$369,099.99
644	1	$175,831.21
824	1	$1,236,852.00
357	3	$3,732,224.36
913	2	$1,974,450.26
599	3	$315,086.16
677	1	$2,173,947.28
266	1	$22,014.32
315	1	$249,204.60
307	1	$1,933,538.04
366	2	$1,726,520.00
803	2	$236,378.85
305	1	$224,565.75
698	1	$1,548,834.30
181	4	$1,331,267.95
96	1	$147,177.87
466	2	$438,079.60
201	4	$3,801,385.11
844	4	$6,457,142.19
10	2	$3,917,200.88
35	2	$44,943.64
980	2	$705,362.02
6	1	$38,159.45
446	2	$5,103,071.76
749	3	$5,573,139.70
220	1	$2,114,080.50
86	3	$5,880,306.46
822	2	$1,458,701.44
400	2	$4,279,753.80
920	1	$3,033,607.50
175	1	$1,688,379.00
363	1	$54,584.64
596	2	$535,228.56
285	1	$1,128,407.72
66	3	$2,905,825.70
231	1	$2,063,866.20
340	1	$11,624.64
512	2	$2,517,988.60
873	1	$235,828.80
356	1	$948,037.26
523	1	$1,354,122.00
391	1	$16,096.56
414	1	$9,490.20
487	2	$1,053,225.16
2	1	$23,934.48
640	1	$6,010,767.00
699	1	$93,230.72
368	2	$2,095,840.74
128	1	$93,161.64
735	1	$1,218,381.84
166	1	$0.00
906	1	$2,533,757.80
595	4	$412,556.32
745	1	$88,486.80
142	1	$2,000,430.12
924	1	$268,677.12
152	1	$1,750,145.28
872	1	$1,764,882.00
428	2	$1,601,616.80
637	2	$2,637,755.12
355	2	$1,699,666.20
792	1	$299,326.08
651	3	$8,732,217.73
381	1	$1,339,246.08
359	1	$6,278,964.24
164	1	$822,686.12
548	1	$30,875.88
730	1	$77,220.00
217	1	$568,190.70
453	1	$2,111,300.10
787	3	$695,461.32
186	3	$8,411,407.44
47	2	$569,429.86
501	2	$2,637,783.50
545	3	$951,341.76
727	2	$184,875.68
985	1	$129,543.52
810	1	$163,421.28
779	1	$449,867.52
18	1	$200,193.12
528	1	$232,202.88
110	2	$66,368.82
145	3	$2,157,872.64
563	3	$11,221,456.05
143	1	$735,686.73
811	1	$35,227.92
496	1	$806,803.20
58	1	$493,885.60
228	1	$7,903.35
485	2	$791,288.97
668	1	$1,157,861.25
294	2	$44,981.44
229	2	$4,994,192.28
559	2	$5,659,819.80
788	2	$2,760,687.84
926	1	$399,470.61
645	2	$3,179,011.74
438	1	$1,514,656.00
382	1	$195,592.00
633	2	$8,459,585.16
258	1	$9,973.95
853	1	$4,766,978.50
378	1	$1,268,405.92
341	2	$378,990.10
450	1	$435,993.60
900	1	$0.00
84	2	$2,204,891.70
170	2	$3,699,062.64
799	3	$3,729,379.80
192	3	$5,930,924.40
513	1	$16,235.76
101	2	$3,614,978.15
69	1	$396,076.56
646	1	$632,073.96
878	2	$1,624,805.10
379	2	$2,607,513.26
320	2	$2,370,610.00
115	1	$2,070,391.96
375	2	$138,463.92
983	2	$82,832.08
415	1	$353,526.12
97	1	$68,539.60
729	1	$52,284.96
680	2	$1,227,885.75
408	2	$110,698.56
59	1	$1,146,602.13
127	1	$703,296.00
555	3	$2,606,458.66
522	1	$110,632.08
567	2	$980,221.90
329	2	$2,820,198.30
630	1	$4,004,699.93
821	1	$747,717.00
659	1	$2,501,174.55
676	3	$1,567,165.60
778	1	$46,863.94
279	1	$1,412,790.40
507	1	$448,125.92
944	1	$1,160,292.18
214	2	$57,463.20
847	1	$1,875,941.76
9	2	$219,186.00
741	1	$442,324.80
897	1	$1,045,265.90
565	2	$1,491,620.13
736	1	$2,354,886.00
551	3	$2,475,182.15
532	1	$2,010,174.48
85	2	$100,466.26
457	2	$1,231,373.77
592	1	$8,119.20
687	2	$2,312,267.04
553	1	$1,354,246.47
259	1	$377,445.60
519	1	$100,929.52
172	1	$626,167.26
302	1	$5,386,601.22
965	1	$5,353,024.60
409	1	$90,128.22
840	2	$3,828,923.00
288	1	$121,174.56
21	1	$125,187.50
3	2	$2,942,802.00
927	4	$1,509,638.04
324	2	$269,099.66
936	2	$1,424,988.60
921	1	$514,323.00
398	3	$4,780,347.12
635	2	$55,701.75
255	2	$851,113.44
388	1	$2,332,848.00
165	2	$1,152,276.30
820	2	$6,477,794.00
209	3	$591,769.25
984	1	$1,441,249.92
74	1	$1,153,962.72
992	1	$5,146,977.12
620	1	$62,729.64
937	2	$499,801.46
894	1	$565,881.88
868	2	$5,755,919.40
34	2	$3,477,993.00
418	1	$187,695.52
205	1	$842,624.64
761	1	$117,457.56
978	5	$17,935,898.74
895	1	$908,493.60
673	3	$7,470,666.36
904	1	$541,271.34
443	1	$96,537.60
387	2	$2,765,627.84
783	3	$179,154.80
334	3	$899,974.80
144	1	$1,302,718.56
540	1	$346,675.14
168	3	$3,551,992.84
690	1	$2,148,040.44
471	1	$945,188.44
526	1	$376,037.20
524	1	$247,738.98
464	1	$595,055.93
312	1	$1,095,745.28
167	2	$3,962,591.73
498	3	$272,000.58
862	1	$458,830.68
277	2	$767,307.52
469	3	$4,269,883.20
494	2	$122,414.00
300	1	$65,761.92
118	1	$121,176.00
683	1	$1,769,053.44
317	1	$732,984.00
284	1	$416,305.96
342	1	$399,494.36
702	3	$277,353.92
488	1	$73,859.73
360	1	$340,515.78
463	1	$107,273.60
99	2	$1,574,415.04
726	2	$5,797,096.32
588	1	$1,614,551.40
206	3	$517,694.64
46	2	$747,575.28
439	3	$6,810,103.12
224	2	$4,319,618.64
586	1	$3,770,175.00
572	1	$3,614,478.00
32	2	$4,633,284.49
756	1	$376,305.68
318	2	$575,998.50
336	1	$276,536.96
275	1	$1,232,731.71
260	2	$7,812,993.96
933	1	$161,560.80
423	1	$5,574,600.44
136	3	$1,675,538.00
139	1	$42,625.24
647	1	$73,718.80
442	1	$152,308.44
593	1	$635,589.25
479	1	$28,857.36
411	1	$953,686.71
869	2	$1,853,280.65
864	2	$4,344,121.98
495	1	$1,317,534.00
672	1	$309,855.96
154	1	$2,756,669.85
825	2	$2,411,303.43
657	1	$839,277.36
234	1	$2,902,579.68
316	3	$521,271.63
731	2	$633,371.00
899	2	$4,510,444.96
332	1	$14,603.75
675	1	$1,580,148.00
748	1	$128,520.00
33	2	$1,750,147.36
422	2	$1,624,171.22
185	1	$63,690.24
264	2	$396,115.52
130	4	$1,321,751.96
270	3	$2,468,123.46
612	2	$3,166,103.80
898	3	$10,992,188.83
486	1	$2,155,511.84
384	1	$878,452.80
617	2	$1,106,308.51
351	1	$1,684,314.00
765	1	$65,289.60
552	1	$166,843.95
732	1	$257,967.36
887	2	$3,929,559.30
837	2	$837,525.48
959	2	$4,933,519.39
314	1	$161,667.48
817	1	$1,124,463.00
826	1	$3,264,732.00
431	1	$137,148.27
433	2	$11,001,860.76
911	1	$424,216.50
491	2	$1,885,717.44
462	1	$155,152.10
299	2	$2,267,588.40
169	3	$2,262,503.00
855	1	$39,294.74
345	1	$233,601.75
92	2	$3,963,573.81
605	2	$116,487.96
541	1	$17,154.72
180	2	$6,367,242.00
870	1	$1,077,891.47
967	1	$634,758.60
236	2	$1,959,187.10
941	1	$85,698.36
957	2	$2,473,517.41
949	1	$1,472,275.60
197	1	$265,816.08
135	1	$2,623,963.41
784	1	$2,242,334.64
999	2	$1,341,742.80
493	1	$24,500.19
707	1	$36,324.48
665	2	$564,184.90
470	2	$2,995,306.14
768	1	$414,780.45
879	1	$69,084.00
838	1	$132,134.40
500	1	$1,698,988.20
311	2	$6,105,797.88
103	1	$19,276.11
505	2	$3,084,297.60
875	3	$4,673,870.40
121	3	$5,959,400.00
239	1	$529,294.08
88	2	$2,078,623.69
420	1	$373,079.25
188	1	$1,472,494.92
461	2	$1,312,113.60
240	1	$190,944.00
328	4	$5,050,056.24
525	1	$2,970,552.75
717	1	$871,628.76
634	1	$403,757.64
845	1	$38,601.36
755	1	$1,142,835.75
196	1	$504,384.00
291	3	$2,709,507.70
15	3	$896,427.80
226	1	$1,005,239.04
210	1	$166,691.85
48	1	$1,252,134.00
447	1	$1,503,706.05
298	1	$553,783.23
61	1	$2,318,757.84
244	2	$2,585,680.81
602	2	$2,747,303.12
691	1	$622,110.90
954	2	$3,230,799.00
468	1	$1,108,152.00
721	2	$18,522.00
800	1	$630,813.04
251	2	$582,101.36
204	2	$2,248,864.80
171	1	$1,278,346.68
960	1	$2,081,760.65
397	2	$424,856.02
531	1	$785,036.46
604	1	$46,058.40
427	1	$1,143,720.96
786	2	$2,816,463.94
347	1	$1,486,594.20
283	3	$4,435,220.72
807	2	$2,279,048.85
179	2	$5,531,922.36
624	1	$3,600,088.80
562	1	$5,529,646.85
636	3	$1,743,120.24
686	1	$3,776,030.22
297	1	$106,395.78
361	1	$971,881.56
681	3	$4,972,096.24
321	2	$437,775.80
303	2	$34,146.42
402	1	$1,054,861.50
472	1	$2,642,187.60
804	3	$1,535,091.76
537	1	$108,780.36
233	4	$2,376,292.80
866	1	$3,081,882.24
889	1	$482,003.64
991	4	$13,282,969.88
93	2	$8,550,413.52
31	1	$2,251,504.48
467	1	$218,342.40
776	3	$4,457,532.96
723	1	$219,600.00
253	3	$7,775,168.83
497	1	$1,574,378.06
109	2	$4,141,530.14
884	1	$2,450,398.86
722	2	$75,802.15
416	2	$743,222.52
724	1	$3,968,004.96
199	2	$582,508.08
372	1	$2,971,394.64
369	1	$20,222.40
441	2	$1,663,556.40
243	1	$1,052,761.92
902	3	$1,509,063.78
772	2	$764,958.60
335	1	$925,790.25
591	2	$239,449.84
603	3	$2,035,048.32
808	1	$85,201.28
892	1	$1,119,249.92
856	1	$2,004,841.86
230	1	$372.32
301	1	$111,782.40
7	4	$2,216,325.16
771	1	$133,887.30
827	2	$3,202,034.55
503	1	$60,234.24
254	1	$37,475.28
377	2	$281,293.50
952	4	$1,463,354.64
78	1	$2,410,459.56
573	3	$111,704.60
250	2	$29,581.14
857	1	$93,991.80
986	1	$578,209.50
619	2	$2,408,659.02
20	1	$728,228.16
621	2	$1,055,988.30
319	1	$1,647,397.08
1	1	$1,354,276.80
76	1	$211,175.10
962	1	$50,731.56
106	3	$4,089,349.26
178	1	$2,062,152.40
129	1	$140,441.28
795	1	$125,890.74
203	1	$4,361,349.96
585	2	$1,052,574.25
8	1	$520,044.62
934	3	$5,050,856.25
789	4	$6,758,817.04
455	2	$5,673,096.48
346	1	$2,237,138.40
370	2	$1,410,775.68
71	3	$2,326,265.60
684	1	$609,960.00
267	1	$13,478.96
713	1	$2,596,158.88
773	1	$241,227.45
448	2	$468,224.16
80	1	$56,425.82
146	1	$14,966.64
701	2	$3,844,503.35
511	2	$5,679,905.32
162	3	$3,103,396.17
132	1	$63,040.20
738	1	$366,419.70
582	2	$873,469.02
330	2	$3,742,132.14
237	1	$696,063.72
751	1	$226,178.70
262	2	$5,653,669.78
451	2	$508,812.96
323	1	$412,600.20
348	2	$1,191,825.96
337	1	$1,827,406.50
60	1	$1,587,845.70
238	2	$542,087.78
399	1	$128,153.07
112	2	$1,024,906.72
560	1	$550,077.84
547	2	$926,979.00
818	1	$1,986,679.36
518	1	$404,110.08
754	1	$156.75
268	1	$547,840.86
289	1	$3,067,616.16
613	2	$741,105.12
65	1	$2,894,063.28
124	1	$1,329,170.00
693	1	$138,842.88
830	2	$1,248,256.00
98	2	$2,040,712.80
527	1	$1,140,831.75
964	1	$252,699.20
235	3	$2,746,584.60
601	1	$715,659.84
590	1	$378,945.28
627	3	$1,008,421.12
763	3	$3,455,501.76
286	1	$292,798.44
480	2	$21,476.83
685	3	$8,198,805.60
358	1	$2,094,342.88
412	3	$5,095,020.84
973	1	$3,747,087.36
610	1	$1,114,126.56
79	2	$2,201,332.56
989	3	$6,173,613.04
950	2	$1,721,349.00
678	3	$1,177,619.58
579	1	$79,132.68
642	1	$741,734.40
77	1	$2,579,436.75
725	2	$359,912.82
310	1	$0.00
28	3	$1,017,438.48
212	2	$2,953,045.20
832	1	$339,963.20
907	3	$1,829,135.50
584	2	$4,417,006.79
720	3	$5,123,216.00
746	1	$430,320.60
806	2	$505,979.88
917	1	$1,590,048.46
997	1	$86,345.28
489	1	$11,395.92
834	2	$1,421,752.50
515	2	$4,648,042.08
813	1	$867,993.84
574	1	$327,820.15
225	1	$526,188.48
706	1	$264,891.90
63	1	$93,804.48
571	2	$5,476,038.39
516	1	$2,051,043.20
666	1	$50,387.61
216	1	$23,173.20
956	1	$347,088.24
542	1	$4,184,440.48
174	2	$4,057,126.12
958	1	$2,483,421.60
694	1	$466,051.00
213	1	$124,021.80
955	1	$710,352.00
274	1	$1,074,191.04
918	1	$155,998.29
669	3	$6,201,990.99
223	1	$227,341.85
36	1	$3,391,782.55
975	3	$6,776,709.12
362	2	$1,515,161.55
430	1	$3,477,472.53
102	3	$2,469,204.36
688	1	$0.00
158	1	$1,202,950.35
594	1	$1,367,063.68
499	2	$1,390,293.30
265	1	$2,927.46
111	2	$6,754,513.06
851	1	$100,279.08
459	1	$31,413.60
16	2	$524,285.28
968	1	$1,106,218.00
62	2	$714,264.80
979	1	$10,928.34
123	1	$385,411.07
993	2	$703,675.80
326	2	$204,014.70
568	1	$1,639,188.48
371	3	$895,844.81
805	2	$5,152,397.04
544	1	$2,398,053.28
365	1	$2,065,524.48
704	2	$8,604,179.84
157	1	$729,365.00
606	1	$507,450.84
308	1	$232,135.20
618	2	$1,449,296.65
880	1	$1,891,350.72
183	2	$694,910.10
100	1	$487,953.44
313	1	$270,332.25
150	1	$35,446.70
140	2	$4,131,668.22
248	1	$5,210,949.12
137	1	$96,573.40
24	1	$3,725,467.20
191	1	$2,945,491.92
966	1	$57,345.04
760	1	$237,439.68
25	4	$1,223,192.11
141	1	$403,230.00
122	2	$231,617.32
218	2	$4,998,359.94
648	1	$1,703,904.95
923	1	$796,254.80
995	2	$824,743.50
49	1	$540,448.20
211	3	$2,479,534.74
901	1	$544,543.02
580	1	$0.00
928	1	$104,694.48
536	2	$899,125.86
520	1	$1,410,845.04
64	3	$2,791,558.26
742	2	$1,981,441.44
912	2	$2,234,723.40
55	4	$3,748,316.80
846	1	$587,583.92
790	1	$220,210.20
\.


--
-- Data for Name: copy_orders; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.copy_orders (order_id, date_of_shipping, addres, order_status, creation_time, source, prod_prod_id, cust_cust_id, man_man_id) FROM stdin;
62	2018-07-23	moscow, ulica 62	4	2017-07-25 00:00:00	source62	110	414	198
49	2017-04-27	moscow, ulica 49	5	2018-12-21 00:00:00	source49	428	288	165
53	2018-03-25	moscow, ulica 53	1	2018-03-14 00:00:00	source53	468	438	12
421	2018-11-27	moscow, ulica 421	1	2017-03-25 00:00:00	source421	579	353	48
444	2018-11-21	moscow, ulica 444	2	2018-07-09 00:00:00	source444	673	824	630
388	2017-03-25	moscow, ulica 388	1	2018-02-02 00:00:00	source388	9	561	750
618	2017-07-14	moscow, ulica 618	2	2017-12-18 00:00:00	source618	980	914	92
855	2018-04-15	moscow, ulica 855	3	2018-05-28 00:00:00	source855	788	819	87
170	2017-11-04	moscow, ulica 170	1	2018-10-20 00:00:00	source170	983	184	645
156	2017-10-25	moscow, ulica 156	4	2017-08-31 00:00:00	source156	100	212	475
767	2018-01-25	moscow, ulica 767	3	2017-04-06 00:00:00	source767	773	545	285
704	2018-04-25	moscow, ulica 704	4	2018-12-01 00:00:00	source704	6	256	431
171	2018-03-27	moscow, ulica 171	5	2018-06-05 00:00:00	source171	541	462	191
166	2018-09-17	moscow, ulica 166	2	2017-08-07 00:00:00	source166	699	343	880
348	2017-03-18	moscow, ulica 348	1	2018-06-16 00:00:00	source348	815	994	338
995	2018-07-31	moscow, ulica 995	4	2018-02-15 00:00:00	source995	328	86	194
402	2017-09-17	moscow, ulica 402	3	2018-01-30 00:00:00	source402	685	881	480
498	2017-07-27	moscow, ulica 498	4	2017-05-05 00:00:00	source498	904	488	405
520	2018-08-20	moscow, ulica 520	3	2017-01-12 00:00:00	source520	746	620	484
320	2018-01-09	moscow, ulica 320	3	2018-09-17 00:00:00	source320	186	420	788
677	2018-11-19	moscow, ulica 677	1	2017-06-28 00:00:00	source677	136	572	948
620	2018-06-24	moscow, ulica 620	3	2017-03-25 00:00:00	source620	197	257	164
679	2017-12-19	moscow, ulica 679	2	2017-10-27 00:00:00	source679	388	824	386
423	2018-02-09	moscow, ulica 423	1	2017-10-06 00:00:00	source423	887	488	890
728	2017-02-19	moscow, ulica 728	4	2018-04-06 00:00:00	source728	997	996	648
131	2017-02-01	moscow, ulica 131	2	2018-02-19 00:00:00	source131	702	378	616
973	2017-03-19	moscow, ulica 973	5	2018-03-12 00:00:00	source973	283	698	63
544	2018-09-29	moscow, ulica 544	1	2017-01-14 00:00:00	source544	102	417	323
286	2018-01-30	moscow, ulica 286	1	2017-11-12 00:00:00	source286	573	615	316
848	2017-10-26	moscow, ulica 848	5	2018-12-12 00:00:00	source848	371	530	664
470	2018-01-16	moscow, ulica 470	5	2018-03-26 00:00:00	source470	71	443	93
204	2018-01-03	moscow, ulica 204	1	2018-10-22 00:00:00	source204	127	989	726
487	2017-10-05	moscow, ulica 487	1	2018-06-13 00:00:00	source487	869	722	782
98	2018-12-21	moscow, ulica 98	2	2017-02-25 00:00:00	source98	507	337	654
625	2017-10-01	moscow, ulica 625	2	2017-03-27 00:00:00	source625	826	438	205
766	2017-07-16	moscow, ulica 766	1	2017-11-23 00:00:00	source766	326	105	81
776	2018-07-25	moscow, ulica 776	4	2018-02-18 00:00:00	source776	917	608	153
849	2018-05-10	moscow, ulica 849	2	2017-09-30 00:00:00	source849	25	923	930
108	2018-06-02	moscow, ulica 108	2	2017-04-27 00:00:00	source108	196	525	829
540	2018-01-21	moscow, ulica 540	3	2018-04-22 00:00:00	source540	170	916	834
506	2018-10-29	moscow, ulica 506	4	2018-08-02 00:00:00	source506	732	52	521
187	2018-06-14	moscow, ulica 187	2	2017-10-22 00:00:00	source187	603	366	541
893	2018-11-04	moscow, ulica 893	5	2018-03-03 00:00:00	source893	559	232	713
670	2018-11-07	moscow, ulica 670	4	2018-11-08 00:00:00	source670	173	1	816
196	2017-06-03	moscow, ulica 196	5	2017-09-27 00:00:00	source196	578	252	333
589	2017-06-23	moscow, ulica 589	4	2018-12-08 00:00:00	source589	529	263	614
397	2017-02-19	moscow, ulica 397	3	2018-10-01 00:00:00	source397	618	566	827
450	2018-10-08	moscow, ulica 450	2	2017-07-09 00:00:00	source450	787	547	778
61	2017-06-15	moscow, ulica 61	2	2017-01-20 00:00:00	source61	751	78	952
992	2017-02-22	moscow, ulica 992	4	2018-11-10 00:00:00	source992	102	139	743
993	2018-05-24	moscow, ulica 993	3	2017-01-19 00:00:00	source993	603	625	794
994	2018-11-27	moscow, ulica 994	4	2018-12-27 00:00:00	source994	427	484	559
510	2018-10-13	moscow, ulica 510	2	2018-10-06 00:00:00	source510	595	851	610
784	2017-04-21	moscow, ulica 784	4	2017-03-03 00:00:00	source784	284	611	59
580	2017-06-24	moscow, ulica 580	3	2017-05-19 00:00:00	source580	493	530	905
917	2017-11-14	moscow, ulica 917	4	2018-03-06 00:00:00	source917	387	460	119
114	2018-03-22	moscow, ulica 114	3	2017-07-27 00:00:00	source114	244	889	439
868	2018-10-12	moscow, ulica 868	1	2018-06-22 00:00:00	source868	47	5	614
663	2018-04-22	moscow, ulica 663	1	2018-04-25 00:00:00	source663	488	16	65
806	2018-01-02	moscow, ulica 806	3	2017-12-17 00:00:00	source806	725	843	241
350	2017-11-14	moscow, ulica 350	3	2017-09-12 00:00:00	source350	316	947	19
882	2018-09-18	moscow, ulica 882	2	2018-12-18 00:00:00	source882	673	185	815
819	2018-07-13	moscow, ulica 819	5	2018-10-01 00:00:00	source819	239	445	816
7	2018-04-08	moscow, ulica 7	5	2018-08-25 00:00:00	source7	486	924	110
691	2017-02-18	moscow, ulica 691	2	2017-01-21 00:00:00	source691	824	376	64
455	2018-03-30	moscow, ulica 455	1	2017-10-18 00:00:00	source455	357	952	279
89	2017-11-30	moscow, ulica 89	5	2018-03-07 00:00:00	source89	613	341	128
167	2018-04-03	moscow, ulica 167	5	2017-11-02 00:00:00	source167	233	665	623
581	2018-02-09	moscow, ulica 581	2	2018-11-09 00:00:00	source581	787	133	236
722	2018-01-31	moscow, ulica 722	4	2017-01-01 00:00:00	source722	494	112	708
111	2017-12-15	moscow, ulica 111	5	2017-07-07 00:00:00	source111	853	973	879
452	2017-08-19	moscow, ulica 452	1	2017-08-20 00:00:00	source452	721	597	386
889	2017-12-26	moscow, ulica 889	5	2017-03-15 00:00:00	source889	64	885	668
469	2018-11-20	moscow, ulica 469	2	2017-03-28 00:00:00	source469	950	962	889
522	2017-08-28	moscow, ulica 522	5	2017-06-04 00:00:00	source522	960	129	18
454	2017-07-11	moscow, ulica 454	1	2017-11-21 00:00:00	source454	61	275	804
899	2017-09-07	moscow, ulica 899	2	2018-04-28 00:00:00	source899	93	98	306
690	2018-09-24	moscow, ulica 690	5	2017-09-14 00:00:00	source690	668	250	457
765	2018-09-16	moscow, ulica 765	1	2017-01-28 00:00:00	source765	601	992	632
768	2018-06-04	moscow, ulica 768	3	2018-02-21 00:00:00	source768	496	602	126
80	2018-11-13	moscow, ulica 80	1	2017-09-19 00:00:00	source80	192	155	687
896	2017-01-04	moscow, ulica 896	4	2018-12-17 00:00:00	source896	10	737	725
547	2018-11-08	moscow, ulica 547	5	2017-04-14 00:00:00	source547	98	995	35
303	2017-09-12	moscow, ulica 303	4	2017-01-05 00:00:00	source303	772	689	269
178	2017-11-07	moscow, ulica 178	1	2018-04-10 00:00:00	source178	62	858	574
52	2017-10-14	moscow, ulica 52	5	2018-08-10 00:00:00	source52	772	939	802
944	2018-12-19	moscow, ulica 944	5	2018-06-08 00:00:00	source944	783	476	912
39	2017-03-19	moscow, ulica 39	3	2018-03-28 00:00:00	source39	79	888	211
217	2018-02-21	moscow, ulica 217	5	2017-08-24 00:00:00	source217	866	660	612
657	2017-04-10	moscow, ulica 657	2	2017-10-04 00:00:00	source657	442	953	475
504	2018-05-20	moscow, ulica 504	4	2018-04-09 00:00:00	source504	978	738	337
489	2018-05-13	moscow, ulica 489	4	2017-04-08 00:00:00	source489	501	564	848
814	2018-06-18	moscow, ulica 814	2	2018-12-03 00:00:00	source814	154	47	74
519	2018-12-06	moscow, ulica 519	2	2017-10-23 00:00:00	source519	145	576	95
383	2018-09-12	moscow, ulica 383	1	2018-01-17 00:00:00	source383	346	784	807
976	2017-06-04	moscow, ulica 976	5	2017-12-24 00:00:00	source976	936	823	867
839	2017-02-06	moscow, ulica 839	2	2018-07-18 00:00:00	source839	927	777	931
224	2018-10-08	moscow, ulica 224	5	2017-02-25 00:00:00	source224	292	664	855
351	2018-03-27	moscow, ulica 351	5	2018-03-03 00:00:00	source351	264	92	311
51	2017-10-07	moscow, ulica 51	4	2018-08-19 00:00:00	source51	55	811	430
586	2018-11-29	moscow, ulica 586	1	2017-03-15 00:00:00	source586	459	425	909
188	2017-11-28	moscow, ulica 188	2	2017-07-15 00:00:00	source188	792	39	535
263	2018-06-28	moscow, ulica 263	2	2018-01-30 00:00:00	source263	529	191	421
186	2018-10-07	moscow, ulica 186	4	2017-09-15 00:00:00	source186	106	819	78
675	2018-01-09	moscow, ulica 675	5	2017-06-02 00:00:00	source675	106	633	912
989	2018-08-24	moscow, ulica 989	5	2018-02-02 00:00:00	source989	727	492	695
530	2018-10-15	moscow, ulica 530	1	2017-01-09 00:00:00	source530	372	363	729
1	2018-10-02	moscow, ulica 1	5	2017-02-22 00:00:00	source1	898	290	851
932	2017-11-18	moscow, ulica 932	2	2018-07-21 00:00:00	source932	101	608	444
590	2017-02-05	moscow, ulica 590	2	2018-05-20 00:00:00	source590	235	818	791
753	2017-09-04	moscow, ulica 753	1	2017-06-10 00:00:00	source753	174	622	866
6	2018-07-27	moscow, ulica 6	5	2017-06-15 00:00:00	source6	189	363	445
714	2017-06-23	moscow, ulica 714	5	2018-02-19 00:00:00	source714	487	873	705
928	2017-04-21	moscow, ulica 928	2	2018-02-24 00:00:00	source928	443	80	716
262	2018-11-12	moscow, ulica 262	5	2018-03-01 00:00:00	source262	470	346	183
279	2017-08-30	moscow, ulica 279	4	2017-07-27 00:00:00	source279	321	835	502
208	2018-02-07	moscow, ulica 208	2	2018-06-02 00:00:00	source208	279	682	231
933	2018-08-01	moscow, ulica 933	2	2017-06-28 00:00:00	source933	844	619	652
648	2017-02-19	moscow, ulica 648	4	2018-10-18 00:00:00	source648	681	725	213
150	2018-11-01	moscow, ulica 150	5	2017-05-05 00:00:00	source150	724	924	505
509	2017-11-08	moscow, ulica 509	5	2017-11-08 00:00:00	source509	160	424	234
394	2018-06-28	moscow, ulica 394	1	2018-10-17 00:00:00	source394	764	479	356
955	2017-03-09	moscow, ulica 955	5	2017-09-16 00:00:00	source955	316	756	306
486	2018-03-16	moscow, ulica 486	1	2017-01-05 00:00:00	source486	975	104	160
553	2018-02-15	moscow, ulica 553	2	2017-12-18 00:00:00	source553	96	394	69
250	2018-10-01	moscow, ulica 250	5	2017-05-10 00:00:00	source250	526	648	356
90	2018-08-25	moscow, ulica 90	1	2017-08-02 00:00:00	source90	368	508	919
25	2018-10-21	moscow, ulica 25	2	2018-08-11 00:00:00	source25	183	156	925
921	2017-06-30	moscow, ulica 921	5	2018-05-31 00:00:00	source921	789	326	766
533	2017-02-05	moscow, ulica 533	5	2017-07-13 00:00:00	source533	329	610	147
328	2018-07-13	moscow, ulica 328	5	2017-09-02 00:00:00	source328	618	34	24
720	2017-05-05	moscow, ulica 720	3	2017-08-30 00:00:00	source720	34	943	568
830	2018-03-31	moscow, ulica 830	3	2017-05-03 00:00:00	source830	702	786	677
829	2018-01-02	moscow, ulica 829	4	2018-06-14 00:00:00	source829	646	126	930
734	2018-04-01	moscow, ulica 734	4	2018-03-18 00:00:00	source734	512	905	870
43	2017-11-05	moscow, ulica 43	2	2017-02-20 00:00:00	source43	630	307	614
627	2018-06-02	moscow, ulica 627	2	2018-04-08 00:00:00	source627	878	544	758
305	2018-08-24	moscow, ulica 305	3	2018-07-17 00:00:00	source305	320	257	928
378	2018-03-07	moscow, ulica 378	2	2017-11-10 00:00:00	source378	702	129	363
183	2017-09-06	moscow, ulica 183	5	2018-02-27 00:00:00	source183	991	147	653
745	2018-08-26	moscow, ulica 745	3	2017-08-18 00:00:00	source745	537	965	397
934	2017-05-31	moscow, ulica 934	2	2017-12-01 00:00:00	source934	283	671	539
611	2018-03-17	moscow, ulica 611	4	2017-12-25 00:00:00	source611	71	897	874
915	2017-10-05	moscow, ulica 915	4	2017-06-17 00:00:00	source915	450	148	380
287	2018-08-11	moscow, ulica 287	1	2018-09-20 00:00:00	source287	965	642	569
744	2017-12-23	moscow, ulica 744	1	2018-01-10 00:00:00	source744	844	513	451
87	2017-09-03	moscow, ulica 87	1	2017-09-08 00:00:00	source87	940	20	172
638	2018-10-02	moscow, ulica 638	4	2017-11-17 00:00:00	source638	19	58	746
91	2018-01-26	moscow, ulica 91	5	2018-09-14 00:00:00	source91	602	658	221
571	2018-03-08	moscow, ulica 571	3	2017-02-26 00:00:00	source571	698	808	190
930	2017-03-14	moscow, ulica 930	1	2018-09-19 00:00:00	source930	412	911	845
324	2018-07-01	moscow, ulica 324	2	2017-08-23 00:00:00	source324	763	658	273
688	2017-09-21	moscow, ulica 688	4	2018-10-12 00:00:00	source688	989	764	962
671	2018-12-25	moscow, ulica 671	2	2017-12-21 00:00:00	source671	336	388	478
386	2017-12-14	moscow, ulica 386	1	2018-03-17 00:00:00	source386	122	916	960
548	2018-06-25	moscow, ulica 548	3	2017-07-23 00:00:00	source548	946	633	460
803	2017-07-14	moscow, ulica 803	3	2017-12-18 00:00:00	source803	644	575	123
826	2017-04-01	moscow, ulica 826	5	2018-08-13 00:00:00	source826	723	551	923
248	2017-11-08	moscow, ulica 248	3	2017-07-22 00:00:00	source248	86	538	749
812	2017-05-24	moscow, ulica 812	3	2018-12-08 00:00:00	source812	937	289	880
884	2017-09-08	moscow, ulica 884	2	2017-07-04 00:00:00	source884	647	386	715
600	2017-06-07	moscow, ulica 600	5	2018-03-21 00:00:00	source600	93	343	468
542	2018-08-24	moscow, ulica 542	2	2017-12-14 00:00:00	source542	901	519	872
83	2017-06-01	moscow, ulica 83	1	2018-09-02 00:00:00	source83	379	207	623
137	2017-06-19	moscow, ulica 137	2	2018-06-04 00:00:00	source137	485	782	596
570	2017-11-28	moscow, ulica 570	2	2017-08-09 00:00:00	source570	111	343	997
562	2017-10-13	moscow, ulica 562	2	2017-08-23 00:00:00	source562	813	702	708
448	2017-02-23	moscow, ulica 448	5	2017-02-16 00:00:00	source448	902	388	362
50	2017-07-03	moscow, ulica 50	2	2018-07-07 00:00:00	source50	86	710	923
610	2018-05-12	moscow, ulica 610	5	2017-04-22 00:00:00	source610	555	425	811
961	2017-09-28	moscow, ulica 961	3	2017-07-10 00:00:00	source961	725	358	891
308	2017-01-14	moscow, ulica 308	4	2017-09-09 00:00:00	source308	150	60	513
642	2017-08-17	moscow, ulica 642	3	2017-12-17 00:00:00	source642	106	263	91
511	2017-02-20	moscow, ulica 511	3	2017-05-18 00:00:00	source511	181	318	255
924	2018-05-03	moscow, ulica 924	3	2017-11-06 00:00:00	source924	199	331	932
919	2018-05-02	moscow, ulica 919	5	2018-12-21 00:00:00	source919	920	738	359
524	2018-12-17	moscow, ulica 524	2	2018-07-18 00:00:00	source524	605	856	633
92	2018-04-17	moscow, ulica 92	1	2017-04-10 00:00:00	source92	471	269	991
69	2018-12-22	moscow, ulica 69	5	2017-05-06 00:00:00	source69	283	224	73
472	2018-08-18	moscow, ulica 472	2	2017-08-20 00:00:00	source472	258	689	433
330	2017-11-03	moscow, ulica 330	5	2018-04-18 00:00:00	source330	297	796	490
878	2017-08-08	moscow, ulica 878	1	2017-04-03 00:00:00	source878	540	220	365
908	2017-12-30	moscow, ulica 908	5	2017-07-14 00:00:00	source908	305	400	610
640	2018-11-29	moscow, ulica 640	3	2018-06-09 00:00:00	source640	433	833	588
144	2017-03-18	moscow, ulica 144	3	2017-10-02 00:00:00	source144	204	248	421
787	2017-09-27	moscow, ulica 787	4	2017-12-01 00:00:00	source787	834	881	411
777	2018-03-15	moscow, ulica 777	2	2018-12-16 00:00:00	source777	722	843	423
877	2018-01-24	moscow, ulica 877	5	2018-02-23 00:00:00	source877	763	897	821
977	2017-11-13	moscow, ulica 977	3	2018-05-12 00:00:00	source977	303	103	914
912	2018-12-19	moscow, ulica 912	2	2018-09-16 00:00:00	source912	706	189	628
478	2017-03-11	moscow, ulica 478	5	2018-03-26 00:00:00	source478	355	11	697
603	2017-06-16	moscow, ulica 603	2	2018-12-28 00:00:00	source603	417	575	769
543	2017-04-20	moscow, ulica 543	3	2017-07-23 00:00:00	source543	178	245	860
175	2017-02-09	moscow, ulica 175	1	2018-03-30 00:00:00	source175	645	659	245
583	2017-01-07	moscow, ulica 583	3	2018-02-25 00:00:00	source583	251	773	28
516	2017-07-12	moscow, ulica 516	2	2017-07-06 00:00:00	source516	738	6	703
200	2018-04-22	moscow, ulica 200	3	2017-03-26 00:00:00	source200	599	489	408
986	2017-06-09	moscow, ulica 986	4	2018-03-22 00:00:00	source986	162	571	311
21	2017-06-17	moscow, ulica 21	1	2017-07-05 00:00:00	source21	786	426	401
459	2018-07-16	moscow, ulica 459	4	2018-04-16 00:00:00	source459	545	641	621
123	2018-05-21	moscow, ulica 123	4	2017-11-22 00:00:00	source123	397	998	896
567	2017-11-14	moscow, ulica 567	1	2017-03-09 00:00:00	source567	260	738	780
142	2018-10-04	moscow, ulica 142	5	2018-02-01 00:00:00	source142	619	667	614
725	2017-12-23	moscow, ulica 725	3	2018-11-28 00:00:00	source725	681	302	317
311	2017-04-03	moscow, ulica 311	1	2017-08-04 00:00:00	source311	678	29	841
431	2018-05-24	moscow, ulica 431	5	2018-05-24 00:00:00	source431	122	754	593
231	2018-05-25	moscow, ulica 231	5	2018-08-01 00:00:00	source231	595	76	546
428	2017-02-01	moscow, ulica 428	5	2018-02-09 00:00:00	source428	731	819	368
749	2018-11-25	moscow, ulica 749	1	2018-10-01 00:00:00	source749	633	996	230
18	2018-02-04	moscow, ulica 18	1	2018-04-12 00:00:00	source18	128	991	940
941	2018-06-01	moscow, ulica 941	5	2018-08-25 00:00:00	source941	223	485	536
479	2018-09-29	moscow, ulica 479	3	2018-05-25 00:00:00	source479	97	313	184
773	2018-03-01	moscow, ulica 773	2	2018-12-26 00:00:00	source773	254	875	796
783	2018-12-24	moscow, ulica 783	3	2018-02-25 00:00:00	source783	139	109	795
10	2018-05-08	moscow, ulica 10	3	2018-12-27 00:00:00	source10	818	408	956
304	2018-08-28	moscow, ulica 304	1	2018-03-20 00:00:00	source304	760	295	683
47	2017-01-01	moscow, ulica 47	3	2017-10-25 00:00:00	source47	683	652	295
813	2017-02-19	moscow, ulica 813	5	2018-04-13 00:00:00	source813	74	431	942
254	2018-10-04	moscow, ulica 254	5	2018-03-13 00:00:00	source254	789	387	294
837	2017-08-30	moscow, ulica 837	2	2018-10-11 00:00:00	source837	275	274	847
118	2017-08-04	moscow, ulica 118	3	2017-04-03 00:00:00	source118	453	478	529
152	2018-03-28	moscow, ulica 152	4	2017-03-11 00:00:00	source152	717	697	502
942	2018-03-21	moscow, ulica 942	5	2018-01-29 00:00:00	source942	201	17	558
202	2018-11-29	moscow, ulica 202	1	2018-05-09 00:00:00	source202	811	422	337
433	2018-05-13	moscow, ulica 433	2	2017-06-14 00:00:00	source433	897	101	187
552	2017-05-08	moscow, ulica 552	1	2017-05-02 00:00:00	source552	845	352	69
484	2018-04-25	moscow, ulica 484	3	2017-03-16 00:00:00	source484	799	255	877
750	2017-09-03	moscow, ulica 750	1	2017-12-19 00:00:00	source750	328	186	572
191	2018-10-10	moscow, ulica 191	4	2017-11-09 00:00:00	source191	556	390	524
93	2017-12-03	moscow, ulica 93	5	2017-12-02 00:00:00	source93	632	674	346
241	2017-10-19	moscow, ulica 241	1	2017-05-24 00:00:00	source241	879	338	442
740	2017-06-11	moscow, ulica 740	4	2017-12-29 00:00:00	source740	810	358	930
132	2017-03-29	moscow, ulica 132	4	2017-08-27 00:00:00	source132	341	411	91
982	2017-09-05	moscow, ulica 982	1	2018-07-26 00:00:00	source982	984	935	210
401	2017-02-17	moscow, ulica 401	1	2018-01-07 00:00:00	source401	349	431	515
974	2018-06-04	moscow, ulica 974	5	2017-10-19 00:00:00	source974	934	447	459
212	2018-08-15	moscow, ulica 212	1	2017-06-11 00:00:00	source212	370	271	216
40	2018-06-21	moscow, ulica 40	5	2018-08-05 00:00:00	source40	59	612	781
103	2018-04-08	moscow, ulica 103	5	2017-01-12 00:00:00	source103	634	906	229
370	2018-01-05	moscow, ulica 370	3	2018-08-03 00:00:00	source370	878	554	962
551	2018-07-05	moscow, ulica 551	2	2018-09-09 00:00:00	source551	334	455	757
275	2018-06-27	moscow, ulica 275	3	2018-06-30 00:00:00	source275	47	344	138
105	2017-04-12	moscow, ulica 105	4	2017-04-30 00:00:00	source105	776	506	790
274	2018-01-16	moscow, ulica 274	4	2018-09-22 00:00:00	source274	545	935	207
1000	2018-01-29	moscow, ulica 1000	2	2018-08-16 00:00:00	source1000	317	292	843
791	2017-07-11	moscow, ulica 791	4	2017-06-19 00:00:00	source791	586	567	424
238	2017-05-22	moscow, ulica 238	5	2017-03-14 00:00:00	source238	786	900	771
36	2017-06-15	moscow, ulica 36	5	2018-07-30 00:00:00	source36	399	789	42
629	2017-02-07	moscow, ulica 629	4	2018-01-19 00:00:00	source629	255	948	781
531	2017-07-08	moscow, ulica 531	3	2018-08-18 00:00:00	source531	658	900	313
972	2017-08-12	moscow, ulica 972	3	2018-03-09 00:00:00	source972	516	757	958
500	2018-01-09	moscow, ulica 500	4	2017-05-09 00:00:00	source500	130	368	540
864	2017-02-15	moscow, ulica 864	4	2017-04-20 00:00:00	source864	130	47	197
79	2017-03-27	moscow, ulica 79	5	2017-05-04 00:00:00	source79	544	406	530
597	2018-12-11	moscow, ulica 597	4	2018-12-22 00:00:00	source597	986	77	383
746	2018-10-05	moscow, ulica 746	4	2018-04-02 00:00:00	source746	397	306	36
845	2018-05-03	moscow, ulica 845	5	2017-10-19 00:00:00	source845	318	387	722
945	2018-08-28	moscow, ulica 945	4	2017-03-26 00:00:00	source945	439	449	35
106	2017-04-07	moscow, ulica 106	1	2018-09-09 00:00:00	source106	49	930	80
376	2017-02-06	moscow, ulica 376	3	2018-02-09 00:00:00	source376	551	975	491
476	2018-05-16	moscow, ulica 476	3	2018-10-12 00:00:00	source476	573	486	343
537	2018-04-06	moscow, ulica 537	5	2017-05-18 00:00:00	source537	218	644	685
979	2018-04-16	moscow, ulica 979	5	2017-09-21 00:00:00	source979	212	786	792
650	2017-12-29	moscow, ulica 650	5	2017-06-14 00:00:00	source650	599	2	887
194	2017-09-14	moscow, ulica 194	5	2017-12-29 00:00:00	source194	959	473	724
265	2018-09-25	moscow, ulica 265	4	2017-04-24 00:00:00	source265	233	977	316
74	2018-09-20	moscow, ulica 74	5	2017-12-15 00:00:00	source74	779	752	25
892	2017-11-04	moscow, ulica 892	1	2018-09-08 00:00:00	source892	384	80	767
233	2018-08-19	moscow, ulica 233	5	2017-11-26 00:00:00	source233	912	365	133
635	2017-01-25	moscow, ulica 635	4	2017-09-06 00:00:00	source635	985	938	526
535	2017-12-15	moscow, ulica 535	3	2018-04-07 00:00:00	source535	25	827	462
639	2018-09-30	moscow, ulica 639	2	2018-02-18 00:00:00	source639	289	736	890
804	2018-07-13	moscow, ulica 804	3	2018-10-21 00:00:00	source804	817	791	915
474	2017-10-20	moscow, ulica 474	4	2017-01-23 00:00:00	source474	230	655	583
429	2017-01-14	moscow, ulica 429	1	2018-02-14 00:00:00	source429	946	449	200
299	2018-12-18	moscow, ulica 299	1	2018-07-28 00:00:00	source299	168	218	721
863	2017-04-08	moscow, ulica 863	3	2017-05-08 00:00:00	source863	520	81	594
335	2017-10-06	moscow, ulica 335	3	2018-02-01 00:00:00	source335	783	1000	685
205	2018-03-28	moscow, ulica 205	1	2017-03-07 00:00:00	source205	420	300	278
821	2017-03-14	moscow, ulica 821	4	2017-10-30 00:00:00	source821	864	823	415
366	2017-11-24	moscow, ulica 366	3	2018-03-31 00:00:00	source366	337	968	757
641	2018-02-13	moscow, ulica 641	1	2017-11-22 00:00:00	source641	505	772	899
340	2017-12-24	moscow, ulica 340	4	2017-07-14 00:00:00	source340	612	459	942
343	2017-07-04	moscow, ulica 343	5	2018-12-12 00:00:00	source343	259	815	570
702	2017-03-25	moscow, ulica 702	3	2017-03-28 00:00:00	source702	146	47	740
312	2017-06-06	moscow, ulica 312	3	2018-01-25 00:00:00	source312	313	396	734
182	2017-02-17	moscow, ulica 182	1	2018-11-21 00:00:00	source182	524	881	422
257	2017-04-10	moscow, ulica 257	4	2018-07-14 00:00:00	source257	217	714	175
413	2017-02-21	moscow, ulica 413	1	2018-05-17 00:00:00	source413	366	504	510
148	2017-01-26	moscow, ulica 148	3	2018-11-12 00:00:00	source148	498	499	332
318	2018-01-05	moscow, ulica 318	3	2018-12-19 00:00:00	source318	553	703	166
971	2018-11-03	moscow, ulica 971	2	2017-01-27 00:00:00	source971	183	459	452
158	2018-04-27	moscow, ulica 158	1	2018-07-27 00:00:00	source158	588	587	310
869	2017-07-25	moscow, ulica 869	4	2018-11-27 00:00:00	source869	580	190	717
843	2018-09-28	moscow, ulica 843	1	2017-09-22 00:00:00	source843	15	3	656
462	2018-09-17	moscow, ulica 462	4	2018-04-05 00:00:00	source462	763	609	483
197	2017-01-13	moscow, ulica 197	3	2018-06-23 00:00:00	source197	375	882	605
913	2018-04-02	moscow, ulica 913	1	2018-12-12 00:00:00	source913	803	794	2
965	2017-03-10	moscow, ulica 965	1	2017-06-24 00:00:00	source965	844	299	141
872	2018-06-24	moscow, ulica 872	5	2018-02-24 00:00:00	source872	363	856	435
764	2017-06-05	moscow, ulica 764	3	2017-08-20 00:00:00	source764	366	904	232
833	2017-10-06	moscow, ulica 833	4	2017-03-30 00:00:00	source833	291	842	908
471	2018-08-26	moscow, ulica 471	4	2018-02-11 00:00:00	source471	391	72	14
404	2017-10-11	moscow, ulica 404	2	2018-11-12 00:00:00	source404	807	952	623
174	2018-04-13	moscow, ulica 174	1	2018-02-08 00:00:00	source174	568	254	646
95	2017-08-15	moscow, ulica 95	2	2017-07-10 00:00:00	source95	302	206	168
141	2018-05-16	moscow, ulica 141	3	2018-03-06 00:00:00	source141	837	874	726
276	2017-07-12	moscow, ulica 276	1	2017-11-11 00:00:00	source276	76	773	756
477	2017-09-05	moscow, ulica 477	1	2018-10-29 00:00:00	source477	952	857	721
809	2018-06-28	moscow, ulica 809	5	2018-06-28 00:00:00	source809	621	234	847
20	2018-10-29	moscow, ulica 20	2	2018-03-08 00:00:00	source20	637	135	936
112	2018-02-12	moscow, ulica 112	3	2018-07-28 00:00:00	source112	519	863	550
879	2018-05-19	moscow, ulica 879	3	2017-10-01 00:00:00	source879	789	458	812
149	2018-11-10	moscow, ulica 149	2	2017-03-31 00:00:00	source149	637	331	355
121	2017-12-11	moscow, ulica 121	1	2017-11-20 00:00:00	source121	574	596	732
347	2017-03-01	moscow, ulica 347	1	2017-03-23 00:00:00	source347	980	180	134
55	2018-03-19	moscow, ulica 55	3	2017-07-10 00:00:00	source55	804	350	583
832	2017-07-06	moscow, ulica 832	5	2017-01-22 00:00:00	source832	805	135	665
473	2017-11-27	moscow, ulica 473	5	2017-10-27 00:00:00	source473	77	760	329
332	2018-06-10	moscow, ulica 332	1	2017-12-21 00:00:00	source332	676	172	673
160	2017-04-18	moscow, ulica 160	5	2018-11-06 00:00:00	source160	768	266	20
22	2017-12-12	moscow, ulica 22	5	2018-01-04 00:00:00	source22	271	447	677
859	2018-09-17	moscow, ulica 859	4	2017-04-14 00:00:00	source859	603	379	731
396	2017-09-25	moscow, ulica 396	5	2017-06-06 00:00:00	source396	231	766	581
558	2017-04-26	moscow, ulica 558	5	2017-04-28 00:00:00	source558	913	543	155
866	2017-07-15	moscow, ulica 866	5	2017-06-06 00:00:00	source866	469	144	73
712	2018-12-27	moscow, ulica 712	5	2017-08-03 00:00:00	source712	324	136	441
359	2018-10-13	moscow, ulica 359	5	2018-12-26 00:00:00	source359	170	726	668
333	2017-07-08	moscow, ulica 333	5	2018-06-16 00:00:00	source333	253	928	366
781	2018-04-01	moscow, ulica 781	4	2018-07-16 00:00:00	source781	229	432	877
29	2017-11-16	moscow, ulica 29	5	2017-07-09 00:00:00	source29	571	957	797
285	2017-02-04	moscow, ulica 285	1	2018-12-17 00:00:00	source285	862	312	520
739	2017-09-29	moscow, ulica 739	4	2017-06-25 00:00:00	source739	141	567	933
439	2018-01-12	moscow, ulica 439	1	2017-02-18 00:00:00	source439	864	167	133
236	2017-07-27	moscow, ulica 236	1	2018-05-26 00:00:00	source236	873	773	618
215	2017-07-03	moscow, ulica 215	5	2017-07-27 00:00:00	source215	92	889	897
505	2018-04-25	moscow, ulica 505	2	2017-04-25 00:00:00	source505	933	230	868
11	2017-02-10	moscow, ulica 11	3	2017-10-02 00:00:00	source11	451	294	875
794	2017-11-30	moscow, ulica 794	5	2018-03-03 00:00:00	source794	168	230	780
614	2018-05-05	moscow, ulica 614	5	2018-02-25 00:00:00	source614	973	696	913
3	2017-01-12	moscow, ulica 3	5	2017-06-01 00:00:00	source3	822	935	153
445	2018-12-08	moscow, ulica 445	3	2017-03-21 00:00:00	source445	335	93	952
801	2017-02-04	moscow, ulica 801	4	2018-09-26 00:00:00	source801	906	688	635
888	2018-10-02	moscow, ulica 888	1	2018-04-16 00:00:00	source888	414	389	387
779	2017-10-08	moscow, ulica 779	4	2018-06-20 00:00:00	source779	78	865	29
419	2017-11-05	moscow, ulica 419	2	2017-12-21 00:00:00	source419	907	188	690
407	2017-10-20	moscow, ulica 407	3	2018-10-10 00:00:00	source407	784	474	336
94	2017-07-02	moscow, ulica 94	3	2018-10-03 00:00:00	source94	209	146	897
412	2017-10-29	moscow, ulica 412	4	2017-08-18 00:00:00	source412	422	361	48
133	2017-11-09	moscow, ulica 133	5	2018-01-12 00:00:00	source133	621	202	483
82	2018-06-22	moscow, ulica 82	5	2018-09-11 00:00:00	source82	253	992	722
117	2017-09-09	moscow, ulica 117	3	2017-07-21 00:00:00	source117	899	704	629
538	2017-09-11	moscow, ulica 538	4	2018-08-13 00:00:00	source538	137	714	732
406	2018-02-07	moscow, ulica 406	2	2017-03-06 00:00:00	source406	993	164	312
587	2017-05-20	moscow, ulica 587	3	2017-10-08 00:00:00	source587	913	469	709
268	2017-12-31	moscow, ulica 268	3	2018-01-03 00:00:00	source268	967	407	581
946	2017-04-11	moscow, ulica 946	4	2018-02-08 00:00:00	source946	686	1000	567
724	2017-08-22	moscow, ulica 724	3	2017-02-20 00:00:00	source724	303	161	860
556	2017-07-06	moscow, ulica 556	5	2018-09-08 00:00:00	source556	323	26	81
243	2017-02-02	moscow, ulica 243	4	2018-11-22 00:00:00	source243	464	289	816
307	2017-11-02	moscow, ulica 307	3	2018-09-20 00:00:00	source307	378	612	116
630	2017-11-02	moscow, ulica 630	1	2017-01-10 00:00:00	source630	268	378	894
628	2018-06-26	moscow, ulica 628	4	2018-11-02 00:00:00	source628	869	957	612
539	2017-07-05	moscow, ulica 539	5	2017-12-24 00:00:00	source539	25	354	25
258	2017-08-23	moscow, ulica 258	5	2017-08-30 00:00:00	source258	590	677	979
409	2018-01-07	moscow, ulica 409	3	2018-04-16 00:00:00	source409	169	863	580
852	2017-11-01	moscow, ulica 852	1	2017-09-23 00:00:00	source852	834	467	972
19	2017-11-07	moscow, ulica 19	3	2018-09-15 00:00:00	source19	832	843	513
797	2018-02-15	moscow, ulica 797	2	2018-05-09 00:00:00	source797	472	356	245
27	2018-04-25	moscow, ulica 27	1	2017-01-16 00:00:00	source27	342	138	176
988	2017-09-17	moscow, ulica 988	5	2017-05-01 00:00:00	source988	636	589	28
871	2017-12-21	moscow, ulica 871	3	2017-01-07 00:00:00	source871	755	3	760
808	2018-06-02	moscow, ulica 808	5	2017-10-21 00:00:00	source808	9	906	856
834	2018-04-16	moscow, ulica 834	4	2018-04-12 00:00:00	source834	888	603	148
651	2017-11-13	moscow, ulica 651	1	2018-02-25 00:00:00	source651	291	948	808
438	2017-05-06	moscow, ulica 438	3	2018-07-23 00:00:00	source438	340	41	145
660	2017-08-08	moscow, ulica 660	1	2018-11-16 00:00:00	source660	28	231	181
115	2018-01-26	moscow, ulica 115	4	2017-03-29 00:00:00	source115	408	324	637
762	2018-02-23	moscow, ulica 762	3	2018-11-07 00:00:00	source762	368	10	853
501	2017-09-25	moscow, ulica 501	2	2017-05-25 00:00:00	source501	255	699	8
669	2017-04-13	moscow, ulica 669	1	2018-07-18 00:00:00	source669	800	904	939
341	2017-04-04	moscow, ulica 341	5	2017-06-13 00:00:00	source341	781	346	531
405	2017-11-19	moscow, ulica 405	5	2017-06-28 00:00:00	source405	381	331	114
694	2018-08-23	moscow, ulica 694	3	2017-06-03 00:00:00	source694	228	186	513
873	2018-05-01	moscow, ulica 873	4	2017-10-24 00:00:00	source873	874	717	961
198	2017-11-25	moscow, ulica 198	1	2017-08-12 00:00:00	source198	314	832	116
329	2017-04-07	moscow, ulica 329	4	2018-01-29 00:00:00	source329	64	351	879
84	2018-05-05	moscow, ulica 84	3	2017-12-21 00:00:00	source84	462	231	149
354	2017-02-01	moscow, ulica 354	2	2018-10-30 00:00:00	source354	480	468	67
252	2017-06-22	moscow, ulica 252	5	2018-08-03 00:00:00	source252	975	765	448
453	2017-10-24	moscow, ulica 453	2	2018-08-06 00:00:00	source453	594	258	876
616	2017-05-22	moscow, ulica 616	4	2018-05-11 00:00:00	source616	7	424	135
488	2018-01-15	moscow, ulica 488	3	2017-09-19 00:00:00	source488	927	878	357
122	2018-05-10	moscow, ulica 122	5	2018-09-15 00:00:00	source122	411	185	192
327	2018-11-09	moscow, ulica 327	1	2018-09-28 00:00:00	source327	892	208	418
528	2018-09-09	moscow, ulica 528	2	2017-11-27 00:00:00	source528	398	386	554
717	2017-04-27	moscow, ulica 717	2	2017-02-09 00:00:00	source717	264	79	904
856	2017-05-12	moscow, ulica 856	4	2018-02-13 00:00:00	source856	912	125	637
416	2017-05-17	moscow, ulica 416	5	2017-08-14 00:00:00	source416	270	131	997
68	2018-08-24	moscow, ulica 68	1	2017-10-04 00:00:00	source68	641	367	165
929	2018-01-16	moscow, ulica 929	2	2017-10-24 00:00:00	source929	961	311	945
840	2018-11-13	moscow, ulica 840	5	2018-07-23 00:00:00	source840	491	368	763
85	2018-05-07	moscow, ulica 85	3	2017-02-10 00:00:00	source85	181	936	130
759	2017-12-06	moscow, ulica 759	1	2018-10-23 00:00:00	source759	978	11	686
155	2017-04-14	moscow, ulica 155	2	2018-12-05 00:00:00	source155	209	49	319
824	2018-07-17	moscow, ulica 824	2	2018-09-01 00:00:00	source824	185	501	453
909	2017-09-17	moscow, ulica 909	4	2018-10-09 00:00:00	source909	511	905	226
736	2017-09-08	moscow, ulica 736	3	2018-06-20 00:00:00	source736	748	178	656
754	2017-10-27	moscow, ulica 754	2	2017-08-04 00:00:00	source754	512	63	41
608	2018-02-05	moscow, ulica 608	2	2018-03-30 00:00:00	source608	536	357	775
786	2017-12-25	moscow, ulica 786	3	2017-10-17 00:00:00	source786	99	277	786
451	2017-06-26	moscow, ulica 451	5	2017-06-12 00:00:00	source451	551	561	962
644	2018-11-12	moscow, ulica 644	4	2017-06-07 00:00:00	source644	687	489	621
136	2018-09-29	moscow, ulica 136	1	2017-06-03 00:00:00	source136	422	164	147
119	2017-02-03	moscow, ulica 119	1	2018-09-02 00:00:00	source119	927	85	103
582	2018-03-13	moscow, ulica 582	3	2017-06-19 00:00:00	source582	32	706	992
619	2018-07-03	moscow, ulica 619	3	2017-07-28 00:00:00	source619	311	371	806
719	2017-03-11	moscow, ulica 719	4	2018-04-03 00:00:00	source719	213	996	451
937	2017-04-28	moscow, ulica 937	4	2018-04-04 00:00:00	source937	203	587	650
911	2017-02-01	moscow, ulica 911	3	2017-10-04 00:00:00	source911	681	772	202
850	2017-05-29	moscow, ulica 850	2	2017-05-15 00:00:00	source850	941	550	675
818	2018-02-22	moscow, ulica 818	5	2018-01-28 00:00:00	source818	596	41	842
788	2018-06-09	moscow, ulica 788	3	2018-01-23 00:00:00	source788	820	969	26
81	2017-12-24	moscow, ulica 81	2	2017-05-21 00:00:00	source81	360	82	155
529	2017-07-09	moscow, ulica 529	3	2018-11-01 00:00:00	source529	899	331	867
219	2018-03-06	moscow, ulica 219	2	2018-01-09 00:00:00	source219	375	866	195
774	2017-10-17	moscow, ulica 774	2	2018-07-10 00:00:00	source774	309	805	317
227	2017-11-30	moscow, ulica 227	1	2017-08-06 00:00:00	source227	181	80	215
943	2018-01-22	moscow, ulica 943	5	2017-01-10 00:00:00	source943	595	769	126
805	2018-11-27	moscow, ulica 805	1	2018-02-14 00:00:00	source805	820	558	675
954	2017-09-28	moscow, ulica 954	4	2018-04-28 00:00:00	source954	556	767	406
502	2018-05-02	moscow, ulica 502	1	2018-05-27 00:00:00	source502	192	164	467
226	2017-06-14	moscow, ulica 226	4	2018-10-05 00:00:00	source226	875	309	952
906	2018-04-26	moscow, ulica 906	5	2018-09-18 00:00:00	source906	685	534	59
13	2017-06-01	moscow, ulica 13	2	2017-08-30 00:00:00	source13	257	562	469
147	2018-10-09	moscow, ulica 147	2	2017-09-23 00:00:00	source147	562	955	919
707	2017-12-06	moscow, ulica 707	5	2017-10-06 00:00:00	source707	416	830	645
615	2017-06-26	moscow, ulica 615	3	2017-02-28 00:00:00	source615	775	481	416
294	2017-06-17	moscow, ulica 294	1	2018-07-15 00:00:00	source294	868	383	525
710	2018-03-15	moscow, ulica 710	4	2018-01-01 00:00:00	source710	761	561	65
189	2017-03-10	moscow, ulica 189	2	2017-06-12 00:00:00	source189	790	687	677
513	2018-07-17	moscow, ulica 513	2	2018-12-20 00:00:00	source513	457	958	357
983	2018-11-15	moscow, ulica 983	3	2018-09-29 00:00:00	source983	277	229	912
352	2018-09-24	moscow, ulica 352	5	2017-12-19 00:00:00	source352	48	450	977
870	2018-06-19	moscow, ulica 870	3	2018-02-01 00:00:00	source870	952	85	185
457	2017-06-14	moscow, ulica 457	4	2017-03-02 00:00:00	source457	298	811	993
555	2018-07-16	moscow, ulica 555	5	2017-08-06 00:00:00	source555	889	981	487
554	2018-09-21	moscow, ulica 554	2	2017-08-27 00:00:00	source554	595	556	171
67	2017-12-24	moscow, ulica 67	5	2018-09-02 00:00:00	source67	448	452	183
527	2017-02-21	moscow, ulica 527	5	2017-06-11 00:00:00	source527	632	269	609
895	2018-02-03	moscow, ulica 895	5	2018-06-27 00:00:00	source895	898	758	577
940	2017-07-22	moscow, ulica 940	2	2018-11-28 00:00:00	source940	547	712	509
656	2017-10-08	moscow, ulica 656	2	2018-05-13 00:00:00	source656	937	144	511
584	2018-11-21	moscow, ulica 584	4	2017-07-14 00:00:00	source584	430	285	979
708	2018-04-15	moscow, ulica 708	1	2018-02-02 00:00:00	source708	382	954	494
154	2018-11-21	moscow, ulica 154	2	2017-01-03 00:00:00	source154	498	202	251
799	2018-09-09	moscow, ulica 799	2	2018-09-26 00:00:00	source799	209	215	7
673	2017-12-06	moscow, ulica 673	3	2018-08-19 00:00:00	source673	730	75	158
637	2017-01-08	moscow, ulica 637	5	2018-12-04 00:00:00	source637	32	104	374
161	2018-02-04	moscow, ulica 161	3	2018-02-24 00:00:00	source161	957	257	202
159	2018-06-19	moscow, ulica 159	3	2017-04-20 00:00:00	source159	993	728	564
211	2018-12-02	moscow, ulica 211	2	2018-04-13 00:00:00	source211	362	781	772
220	2018-06-04	moscow, ulica 220	1	2017-02-14 00:00:00	source220	968	21	666
761	2017-04-10	moscow, ulica 761	4	2018-11-25 00:00:00	source761	489	140	794
696	2018-11-13	moscow, ulica 696	2	2018-06-12 00:00:00	source696	328	207	854
685	2017-06-20	moscow, ulica 685	3	2018-11-13 00:00:00	source685	46	689	492
292	2017-03-07	moscow, ulica 292	4	2017-06-17 00:00:00	source292	171	744	308
128	2017-06-02	moscow, ulica 128	5	2018-11-12 00:00:00	source128	438	150	363
842	2018-05-08	moscow, ulica 842	5	2017-03-21 00:00:00	source842	201	455	124
790	2017-04-04	moscow, ulica 790	4	2017-08-15 00:00:00	source790	830	666	621
732	2018-11-26	moscow, ulica 732	4	2018-01-17 00:00:00	source732	884	465	352
532	2017-03-02	moscow, ulica 532	5	2017-02-10 00:00:00	source532	143	493	617
601	2017-07-28	moscow, ulica 601	4	2018-03-20 00:00:00	source601	243	585	377
169	2018-01-30	moscow, ulica 169	2	2018-02-05 00:00:00	source169	234	65	542
591	2018-02-06	moscow, ulica 591	5	2017-04-30 00:00:00	source591	326	64	928
206	2018-02-24	moscow, ulica 206	1	2017-06-24 00:00:00	source206	244	807	554
569	2017-10-31	moscow, ulica 569	2	2017-01-17 00:00:00	source569	599	652	532
177	2017-03-04	moscow, ulica 177	4	2018-11-22 00:00:00	source177	592	90	581
278	2018-11-09	moscow, ulica 278	2	2017-12-13 00:00:00	source278	351	952	849
143	2017-01-02	moscow, ulica 143	5	2017-05-29 00:00:00	source143	10	115	803
817	2018-03-20	moscow, ulica 817	3	2017-06-13 00:00:00	source817	15	52	859
417	2018-03-08	moscow, ulica 417	1	2017-03-20 00:00:00	source417	181	170	549
242	2017-01-24	moscow, ulica 242	3	2017-08-10 00:00:00	source242	237	428	616
88	2018-07-08	moscow, ulica 88	3	2017-06-30 00:00:00	source88	954	727	247
559	2018-07-09	moscow, ulica 559	2	2017-12-03 00:00:00	source559	348	983	907
393	2018-04-17	moscow, ulica 393	2	2018-05-07 00:00:00	source393	851	773	331
362	2017-03-05	moscow, ulica 362	3	2018-06-20 00:00:00	source362	361	987	974
422	2018-07-16	moscow, ulica 422	3	2017-04-01 00:00:00	source422	299	852	512
260	2017-04-29	moscow, ulica 260	3	2017-09-16 00:00:00	source260	282	790	619
468	2017-02-14	moscow, ulica 468	5	2018-05-06 00:00:00	source468	927	47	306
789	2017-01-23	moscow, ulica 789	1	2017-08-21 00:00:00	source789	204	755	84
785	2018-09-25	moscow, ulica 785	5	2017-10-24 00:00:00	source785	267	232	669
435	2018-01-15	moscow, ulica 435	1	2018-10-31 00:00:00	source435	20	98	635
33	2017-08-01	moscow, ulica 33	5	2017-01-08 00:00:00	source33	250	628	711
578	2017-01-27	moscow, ulica 578	3	2017-12-09 00:00:00	source578	359	810	464
338	2018-01-07	moscow, ulica 338	5	2017-01-14 00:00:00	source338	991	7	355
936	2018-10-30	moscow, ulica 936	5	2018-09-02 00:00:00	source936	211	608	595
466	2017-01-27	moscow, ulica 466	5	2017-11-14 00:00:00	source466	85	116	548
234	2018-10-03	moscow, ulica 234	1	2017-08-22 00:00:00	source234	88	851	306
14	2017-06-18	moscow, ulica 14	2	2018-08-03 00:00:00	source14	669	505	390
15	2018-07-01	moscow, ulica 15	3	2018-09-19 00:00:00	source15	387	765	634
701	2017-12-12	moscow, ulica 701	5	2018-11-23 00:00:00	source701	201	221	68
568	2017-08-10	moscow, ulica 568	3	2017-03-16 00:00:00	source568	212	159	288
918	2018-12-22	moscow, ulica 918	1	2017-03-12 00:00:00	source918	71	553	972
541	2018-11-04	moscow, ulica 541	5	2017-01-05 00:00:00	source541	923	813	309
253	2017-09-30	moscow, ulica 253	5	2017-10-17 00:00:00	source253	838	854	537
424	2018-12-01	moscow, ulica 424	1	2018-11-05 00:00:00	source424	19	67	101
361	2018-06-08	moscow, ulica 361	2	2018-01-07 00:00:00	source361	447	98	855
358	2017-04-29	moscow, ulica 358	1	2018-03-11 00:00:00	source358	563	495	878
721	2018-01-30	moscow, ulica 721	1	2017-03-17 00:00:00	source721	726	622	808
266	2018-09-20	moscow, ulica 266	2	2017-11-19 00:00:00	source266	808	915	431
858	2017-01-31	moscow, ulica 858	3	2017-03-23 00:00:00	source858	485	584	637
634	2017-09-11	moscow, ulica 634	4	2018-01-21 00:00:00	source634	567	394	690
390	2018-07-28	moscow, ulica 390	4	2017-04-21 00:00:00	source390	807	202	307
741	2018-05-05	moscow, ulica 741	5	2017-10-28 00:00:00	source741	330	562	740
606	2017-10-24	moscow, ulica 606	2	2018-07-23 00:00:00	source606	192	273	223
297	2018-04-05	moscow, ulica 297	1	2018-07-22 00:00:00	source297	978	258	340
820	2018-06-30	moscow, ulica 820	4	2017-09-23 00:00:00	source820	907	315	532
865	2017-06-23	moscow, ulica 865	3	2018-11-15 00:00:00	source865	934	393	123
499	2018-02-05	moscow, ulica 499	3	2018-01-28 00:00:00	source499	898	824	534
302	2017-02-25	moscow, ulica 302	5	2018-09-11 00:00:00	source302	291	688	223
990	2018-01-09	moscow, ulica 990	4	2018-02-08 00:00:00	source990	887	238	227
731	2017-04-26	moscow, ulica 731	3	2017-02-01 00:00:00	source731	778	829	199
970	2018-12-04	moscow, ulica 970	4	2018-12-07 00:00:00	source970	560	959	751
693	2018-02-24	moscow, ulica 693	3	2019-01-01 00:00:00	source693	722	722	429
907	2017-09-01	moscow, ulica 907	1	2017-10-16 00:00:00	source907	624	241	287
901	2018-11-13	moscow, ulica 901	1	2018-12-14 00:00:00	source901	830	713	587
716	2018-06-18	moscow, ulica 716	4	2018-06-23 00:00:00	source716	633	924	797
577	2017-11-21	moscow, ulica 577	4	2017-10-06 00:00:00	source577	678	695	523
321	2018-04-15	moscow, ulica 321	4	2018-02-11 00:00:00	source321	680	360	291
26	2018-03-31	moscow, ulica 26	2	2017-08-18 00:00:00	source26	162	445	7
282	2017-11-10	moscow, ulica 282	1	2018-07-03 00:00:00	source282	365	99	769
256	2017-03-19	moscow, ulica 256	4	2017-07-28 00:00:00	source256	233	786	737
490	2017-10-06	moscow, ulica 490	3	2017-02-03 00:00:00	source490	610	21	472
60	2018-06-09	moscow, ulica 60	5	2018-08-28 00:00:00	source60	415	992	755
692	2018-01-27	moscow, ulica 692	5	2018-05-24 00:00:00	source692	795	168	512
31	2018-02-22	moscow, ulica 31	1	2017-11-30 00:00:00	source31	51	885	218
566	2018-06-27	moscow, ulica 566	2	2017-07-06 00:00:00	source566	669	333	61
165	2018-05-28	moscow, ulica 165	5	2018-01-24 00:00:00	source165	400	838	956
493	2017-06-28	moscow, ulica 493	3	2017-01-20 00:00:00	source493	269	937	467
138	2018-04-11	moscow, ulica 138	2	2017-05-29 00:00:00	source138	619	690	45
432	2018-09-24	moscow, ulica 432	4	2018-10-05 00:00:00	source432	8	159	818
465	2017-01-03	moscow, ulica 465	4	2018-03-10 00:00:00	source465	179	723	956
436	2017-03-05	moscow, ulica 436	5	2018-01-06 00:00:00	source436	665	42	776
655	2017-11-04	moscow, ulica 655	2	2018-01-12 00:00:00	source655	791	18	601
34	2017-12-26	moscow, ulica 34	2	2017-04-23 00:00:00	source34	463	246	116
134	2017-12-19	moscow, ulica 134	3	2018-07-18 00:00:00	source134	593	265	774
890	2018-03-05	moscow, ulica 890	2	2017-11-07 00:00:00	source890	479	990	744
176	2017-05-25	moscow, ulica 176	4	2018-10-07 00:00:00	source176	179	788	401
78	2017-10-04	moscow, ulica 78	4	2017-02-22 00:00:00	source78	673	353	957
534	2017-11-20	moscow, ulica 534	3	2017-07-01 00:00:00	source534	690	931	140
960	2018-08-01	moscow, ulica 960	4	2017-11-21 00:00:00	source960	875	96	47
210	2017-09-18	moscow, ulica 210	4	2017-05-17 00:00:00	source210	918	145	432
443	2018-01-11	moscow, ulica 443	5	2017-01-01 00:00:00	source443	164	627	682
349	2018-08-02	moscow, ulica 349	2	2017-10-17 00:00:00	source349	582	922	956
617	2017-05-30	moscow, ulica 617	2	2018-03-09 00:00:00	source617	627	699	848
682	2017-12-01	moscow, ulica 682	4	2018-02-14 00:00:00	source682	121	244	793
442	2017-01-13	moscow, ulica 442	1	2017-02-27 00:00:00	source442	685	575	603
375	2018-04-08	moscow, ulica 375	5	2018-11-04 00:00:00	source375	2	353	777
44	2017-06-17	moscow, ulica 44	4	2017-04-16 00:00:00	source44	174	611	409
399	2018-03-13	moscow, ulica 399	4	2018-12-27 00:00:00	source399	627	563	498
48	2018-05-03	moscow, ulica 48	5	2018-09-28 00:00:00	source48	911	213	595
130	2017-02-09	moscow, ulica 130	1	2017-10-09 00:00:00	source130	398	658	301
28	2017-03-06	moscow, ulica 28	2	2017-10-25 00:00:00	source28	329	17	641
827	2018-07-04	moscow, ulica 827	3	2017-10-04 00:00:00	source827	894	763	280
698	2017-01-20	moscow, ulica 698	5	2018-03-01 00:00:00	source698	416	621	650
336	2018-04-14	moscow, ulica 336	2	2017-08-05 00:00:00	source336	729	141	255
157	2018-12-07	moscow, ulica 157	2	2017-09-24 00:00:00	source157	545	457	46
368	2018-09-27	moscow, ulica 368	2	2017-07-01 00:00:00	source368	400	441	289
229	2017-09-30	moscow, ulica 229	3	2018-11-11 00:00:00	source229	502	842	354
300	2017-11-09	moscow, ulica 300	3	2017-09-14 00:00:00	source300	825	387	574
9	2017-02-19	moscow, ulica 9	3	2017-02-11 00:00:00	source9	573	703	217
997	2017-08-19	moscow, ulica 997	5	2018-06-17 00:00:00	source997	118	197	627
497	2018-09-24	moscow, ulica 497	4	2018-08-22 00:00:00	source497	612	369	736
775	2018-04-13	moscow, ulica 775	3	2018-07-20 00:00:00	source775	266	458	186
75	2018-06-30	moscow, ulica 75	5	2017-01-01 00:00:00	source75	964	442	860
935	2018-08-27	moscow, ulica 935	3	2017-09-19 00:00:00	source935	494	116	45
515	2018-08-06	moscow, ulica 515	5	2017-08-31 00:00:00	source515	140	645	13
514	2017-10-25	moscow, ulica 514	5	2017-09-26 00:00:00	source514	975	976	451
482	2017-03-29	moscow, ulica 482	4	2018-06-10 00:00:00	source482	857	611	464
291	2018-01-21	moscow, ulica 291	2	2018-06-04 00:00:00	source291	551	874	738
564	2017-01-11	moscow, ulica 564	4	2017-07-03 00:00:00	source564	206	259	626
214	2018-10-31	moscow, ulica 214	1	2018-08-07 00:00:00	source214	439	630	351
410	2018-02-15	moscow, ulica 410	4	2018-04-08 00:00:00	source410	500	699	857
392	2018-06-16	moscow, ulica 392	3	2017-01-12 00:00:00	source392	319	646	566
379	2018-10-29	moscow, ulica 379	5	2017-09-16 00:00:00	source379	218	251	245
975	2018-05-14	moscow, ulica 975	5	2018-11-21 00:00:00	source975	294	197	672
748	2018-04-13	moscow, ulica 748	3	2017-07-22 00:00:00	source748	63	275	822
203	2018-05-09	moscow, ulica 203	4	2017-02-25 00:00:00	source203	620	529	451
35	2017-02-23	moscow, ulica 35	2	2018-03-26 00:00:00	source35	214	33	867
104	2017-01-12	moscow, ulica 104	4	2017-10-09 00:00:00	source104	62	641	569
949	2017-07-08	moscow, ulica 949	5	2017-01-22 00:00:00	source949	499	498	695
894	2018-02-11	moscow, ulica 894	3	2018-09-07 00:00:00	source894	736	196	987
113	2018-08-26	moscow, ulica 113	2	2017-01-11 00:00:00	source113	251	447	820
999	2017-09-01	moscow, ulica 999	2	2017-07-08 00:00:00	source999	299	81	436
857	2017-08-28	moscow, ulica 857	2	2017-12-16 00:00:00	source857	509	930	665
364	2018-03-22	moscow, ulica 364	2	2018-05-08 00:00:00	source364	46	295	368
769	2018-06-23	moscow, ulica 769	2	2018-10-13 00:00:00	source769	765	118	246
485	2017-05-27	moscow, ulica 485	1	2018-01-04 00:00:00	source485	944	881	239
968	2017-06-01	moscow, ulica 968	1	2018-04-27 00:00:00	source968	250	141	318
602	2018-03-11	moscow, ulica 602	5	2018-09-23 00:00:00	source602	868	21	759
665	2017-01-28	moscow, ulica 665	5	2017-02-05 00:00:00	source665	741	930	256
16	2017-06-10	moscow, ulica 16	2	2018-01-19 00:00:00	source16	957	429	307
411	2017-10-24	moscow, ulica 411	3	2018-09-13 00:00:00	source411	112	393	490
430	2017-12-25	moscow, ulica 430	4	2017-07-08 00:00:00	source430	684	437	815
467	2018-12-02	moscow, ulica 467	3	2018-08-13 00:00:00	source467	764	253	308
689	2018-07-18	moscow, ulica 689	1	2018-06-07 00:00:00	source689	924	181	894
97	2017-07-11	moscow, ulica 97	2	2017-09-14 00:00:00	source97	950	532	431
387	2018-05-12	moscow, ulica 387	1	2018-12-13 00:00:00	source387	418	452	716
678	2017-09-17	moscow, ulica 678	4	2017-05-17 00:00:00	source678	274	692	940
356	2017-04-29	moscow, ulica 356	2	2017-06-14 00:00:00	source356	34	101	346
815	2018-02-01	moscow, ulica 815	4	2017-09-25 00:00:00	source815	983	501	878
963	2018-11-13	moscow, ulica 963	5	2018-07-28 00:00:00	source963	144	327	221
525	2017-08-21	moscow, ulica 525	2	2018-08-14 00:00:00	source525	236	850	949
458	2018-04-22	moscow, ulica 458	5	2017-11-05 00:00:00	source458	262	21	798
213	2017-07-10	moscow, ulica 213	4	2017-02-08 00:00:00	source213	109	944	710
838	2018-01-28	moscow, ulica 838	1	2018-12-27 00:00:00	source838	80	798	917
384	2017-01-22	moscow, ulica 384	2	2018-03-21 00:00:00	source384	7	458	459
146	2017-12-13	moscow, ulica 146	1	2017-08-07 00:00:00	source146	145	635	720
565	2017-06-15	moscow, ulica 565	5	2018-05-07 00:00:00	source565	402	589	865
508	2018-05-26	moscow, ulica 508	5	2018-12-01 00:00:00	source508	307	203	963
573	2017-12-08	moscow, ulica 573	2	2017-09-18 00:00:00	source573	567	948	648
585	2018-03-20	moscow, ulica 585	5	2018-05-11 00:00:00	source585	112	859	252
847	2018-12-15	moscow, ulica 847	4	2017-12-30 00:00:00	source847	446	737	681
546	2018-04-02	moscow, ulica 546	3	2017-06-21 00:00:00	source546	928	504	266
816	2018-12-14	moscow, ulica 816	5	2017-07-07 00:00:00	source816	130	71	224
346	2017-01-04	moscow, ulica 346	2	2018-04-01 00:00:00	source346	238	850	421
572	2018-10-30	moscow, ulica 572	5	2018-03-13 00:00:00	source572	240	520	876
667	2018-12-12	moscow, ulica 667	4	2017-09-06 00:00:00	source667	846	855	438
984	2018-02-10	moscow, ulica 984	5	2017-05-15 00:00:00	source984	966	586	263
980	2018-01-11	moscow, ulica 980	5	2017-07-02 00:00:00	source980	584	33	891
293	2017-06-08	moscow, ulica 293	4	2018-07-11 00:00:00	source293	839	437	480
854	2017-07-09	moscow, ulica 854	5	2018-04-24 00:00:00	source854	731	847	608
958	2018-04-04	moscow, ulica 958	3	2018-02-13 00:00:00	source958	123	866	352
626	2017-02-24	moscow, ulica 626	1	2018-03-30 00:00:00	source626	315	632	338
605	2017-04-19	moscow, ulica 605	3	2017-04-05 00:00:00	source605	687	814	538
209	2018-07-20	moscow, ulica 209	2	2017-05-07 00:00:00	source209	720	216	790
851	2018-01-23	moscow, ulica 851	3	2017-02-21 00:00:00	source851	787	232	408
12	2018-10-12	moscow, ulica 12	2	2018-09-22 00:00:00	source12	28	550	970
757	2018-09-13	moscow, ulica 757	5	2018-03-04 00:00:00	source757	989	772	38
172	2017-05-10	moscow, ulica 172	2	2017-04-07 00:00:00	source172	707	965	730
792	2018-07-19	moscow, ulica 792	1	2017-10-23 00:00:00	source792	678	576	624
686	2017-03-02	moscow, ulica 686	3	2017-03-10 00:00:00	source686	257	170	174
425	2018-12-29	moscow, ulica 425	4	2018-05-12 00:00:00	source425	536	682	619
795	2017-05-29	moscow, ulica 795	4	2017-11-02 00:00:00	source795	33	325	973
168	2018-02-07	moscow, ulica 168	5	2018-12-18 00:00:00	source168	135	632	264
947	2017-07-25	moscow, ulica 947	3	2017-07-17 00:00:00	source947	377	718	104
102	2018-02-13	moscow, ulica 102	2	2017-02-26 00:00:00	source102	214	190	824
914	2018-11-08	moscow, ulica 914	3	2018-04-10 00:00:00	source914	635	683	855
846	2018-01-31	moscow, ulica 846	3	2018-08-18 00:00:00	source846	28	416	246
237	2017-07-06	moscow, ulica 237	3	2018-02-19 00:00:00	source237	7	532	58
190	2017-06-27	moscow, ulica 190	2	2017-06-21 00:00:00	source190	121	896	680
195	2018-12-13	moscow, ulica 195	1	2017-10-01 00:00:00	source195	776	457	423
521	2018-06-30	moscow, ulica 521	2	2019-01-01 00:00:00	source521	822	525	916
58	2017-08-27	moscow, ulica 58	5	2017-12-12 00:00:00	source58	408	868	352
162	2018-12-10	moscow, ulica 162	1	2018-04-21 00:00:00	source162	642	336	560
593	2017-07-22	moscow, ulica 593	4	2017-04-13 00:00:00	source593	324	172	519
400	2018-10-26	moscow, ulica 400	1	2017-09-03 00:00:00	source400	439	937	37
223	2017-05-28	moscow, ulica 223	3	2017-01-03 00:00:00	source223	565	50	227
441	2018-02-11	moscow, ulica 441	5	2017-01-02 00:00:00	source441	412	18	95
622	2018-02-18	moscow, ulica 622	3	2018-03-18 00:00:00	source622	69	392	487
771	2018-03-03	moscow, ulica 771	1	2018-09-06 00:00:00	source771	3	708	665
37	2017-03-31	moscow, ulica 37	2	2017-11-23 00:00:00	source37	776	454	446
464	2018-10-26	moscow, ulica 464	5	2017-02-22 00:00:00	source464	286	966	951
317	2018-07-31	moscow, ulica 317	4	2018-06-01 00:00:00	source317	341	675	704
180	2018-01-05	moscow, ulica 180	2	2017-04-30 00:00:00	source180	157	103	428
632	2017-10-12	moscow, ulica 632	3	2017-06-25 00:00:00	source632	142	373	24
310	2018-04-25	moscow, ulica 310	2	2017-12-12 00:00:00	source310	109	161	223
45	2017-03-13	moscow, ulica 45	3	2017-07-10 00:00:00	source45	451	607	434
382	2017-10-15	moscow, ulica 382	2	2017-06-25 00:00:00	source382	65	285	126
517	2017-03-17	moscow, ulica 517	3	2017-06-12 00:00:00	source517	720	281	552
811	2017-06-13	moscow, ulica 811	2	2018-05-12 00:00:00	source811	21	265	704
991	2017-02-19	moscow, ulica 991	5	2018-11-14 00:00:00	source991	837	31	338
323	2018-04-04	moscow, ulica 323	1	2017-03-16 00:00:00	source323	652	464	100
891	2017-01-17	moscow, ulica 891	5	2017-10-17 00:00:00	source891	7	541	867
446	2018-01-09	moscow, ulica 446	1	2018-06-22 00:00:00	source446	441	555	369
760	2018-01-07	moscow, ulica 760	3	2017-12-25 00:00:00	source760	783	186	93
862	2018-01-05	moscow, ulica 862	1	2018-03-24 00:00:00	source862	584	851	20
998	2017-04-11	moscow, ulica 998	3	2017-10-01 00:00:00	source998	501	724	570
985	2018-09-07	moscow, ulica 985	2	2017-06-29 00:00:00	source985	168	650	680
621	2017-06-17	moscow, ulica 621	4	2018-01-12 00:00:00	source621	211	400	253
588	2017-01-30	moscow, ulica 588	5	2018-05-30 00:00:00	source588	394	143	226
715	2018-05-24	moscow, ulica 715	4	2017-02-15 00:00:00	source715	827	846	868
920	2017-11-11	moscow, ulica 920	3	2017-05-02 00:00:00	source920	272	900	1
623	2017-06-15	moscow, ulica 623	5	2018-09-21 00:00:00	source623	742	981	635
987	2017-04-12	moscow, ulica 987	3	2018-02-02 00:00:00	source987	701	505	987
738	2017-06-22	moscow, ulica 738	4	2017-02-15 00:00:00	source738	542	199	509
398	2017-10-08	moscow, ulica 398	1	2017-12-24 00:00:00	source398	934	508	445
703	2017-09-12	moscow, ulica 703	2	2018-07-24 00:00:00	source703	555	549	654
676	2017-07-26	moscow, ulica 676	4	2018-01-23 00:00:00	source676	253	493	177
647	2018-11-07	moscow, ulica 647	5	2018-12-08 00:00:00	source647	582	861	243
646	2017-07-30	moscow, ulica 646	2	2018-04-15 00:00:00	source646	350	19	672
179	2018-11-16	moscow, ulica 179	2	2017-12-12 00:00:00	source179	676	248	104
277	2017-09-24	moscow, ulica 277	2	2018-06-20 00:00:00	source277	726	464	36
264	2017-05-19	moscow, ulica 264	5	2017-08-05 00:00:00	source264	236	151	451
381	2018-09-19	moscow, ulica 381	2	2018-11-05 00:00:00	source381	130	600	70
116	2018-10-22	moscow, ulica 116	2	2017-10-21 00:00:00	source116	955	526	866
76	2017-09-08	moscow, ulica 76	4	2018-06-09 00:00:00	source76	513	200	667
24	2017-12-09	moscow, ulica 24	1	2018-07-12 00:00:00	source24	334	954	556
365	2017-05-20	moscow, ulica 365	3	2018-12-09 00:00:00	source365	961	176	742
185	2017-12-30	moscow, ulica 185	3	2017-02-06 00:00:00	source185	220	581	708
64	2018-10-19	moscow, ulica 64	1	2018-07-04 00:00:00	source64	101	683	674
886	2018-07-03	moscow, ulica 886	1	2018-12-11 00:00:00	source886	120	175	310
860	2017-01-04	moscow, ulica 860	2	2017-06-25 00:00:00	source860	140	633	380
652	2018-03-11	moscow, ulica 652	2	2018-12-18 00:00:00	source652	547	725	243
96	2018-03-29	moscow, ulica 96	1	2017-11-29 00:00:00	source96	355	258	254
853	2017-03-13	moscow, ulica 853	2	2018-02-04 00:00:00	source853	523	418	110
796	2017-07-29	moscow, ulica 796	2	2017-05-02 00:00:00	source796	469	311	511
953	2017-03-02	moscow, ulica 953	4	2017-12-26 00:00:00	source953	321	924	600
867	2018-01-23	moscow, ulica 867	1	2017-07-02 00:00:00	source867	952	424	366
221	2018-06-10	moscow, ulica 221	5	2017-10-19 00:00:00	source221	872	158	157
822	2017-10-07	moscow, ulica 822	2	2018-03-02 00:00:00	source822	657	338	564
355	2017-12-02	moscow, ulica 355	5	2018-06-15 00:00:00	source355	756	233	263
645	2017-12-21	moscow, ulica 645	5	2017-10-16 00:00:00	source645	638	866	83
232	2018-07-30	moscow, ulica 232	3	2017-09-07 00:00:00	source232	585	382	474
883	2018-09-01	moscow, ulica 883	5	2018-06-13 00:00:00	source883	348	50	206
306	2017-02-08	moscow, ulica 306	5	2017-09-10 00:00:00	source306	550	24	307
967	2017-09-22	moscow, ulica 967	1	2018-07-07 00:00:00	source967	596	677	375
951	2017-09-18	moscow, ulica 951	2	2017-05-02 00:00:00	source951	652	306	534
273	2018-07-23	moscow, ulica 273	2	2017-08-03 00:00:00	source273	233	2	131
887	2017-10-11	moscow, ulica 887	3	2018-10-05 00:00:00	source887	431	647	542
110	2018-05-24	moscow, ulica 110	2	2018-10-07 00:00:00	source110	357	503	685
523	2018-11-14	moscow, ulica 523	4	2018-09-02 00:00:00	source523	428	408	385
925	2017-07-31	moscow, ulica 925	3	2018-06-03 00:00:00	source925	956	728	765
377	2017-03-15	moscow, ulica 377	2	2018-10-31 00:00:00	source377	469	489	660
981	2018-11-29	moscow, ulica 981	3	2017-05-12 00:00:00	source981	511	827	44
549	2018-10-15	moscow, ulica 549	5	2018-08-09 00:00:00	source549	475	237	461
325	2018-06-02	moscow, ulica 325	1	2017-07-17 00:00:00	source325	529	669	514
810	2018-01-26	moscow, ulica 810	1	2018-04-01 00:00:00	source810	224	426	368
151	2017-07-01	moscow, ulica 151	3	2018-06-19 00:00:00	source151	165	689	712
563	2017-08-04	moscow, ulica 563	1	2018-08-24 00:00:00	source563	839	575	601
876	2018-10-14	moscow, ulica 876	5	2018-10-07 00:00:00	source876	753	106	905
280	2017-07-04	moscow, ulica 280	2	2018-01-26 00:00:00	source280	503	813	566
752	2017-08-23	moscow, ulica 752	1	2018-12-24 00:00:00	source752	605	69	132
272	2017-04-08	moscow, ulica 272	4	2017-06-28 00:00:00	source272	870	66	402
607	2017-11-07	moscow, ulica 607	3	2017-09-23 00:00:00	source607	334	68	386
372	2017-05-30	moscow, ulica 372	4	2018-01-02 00:00:00	source372	216	774	104
244	2018-01-25	moscow, ulica 244	2	2017-02-24 00:00:00	source244	201	737	775
267	2017-04-22	moscow, ulica 267	5	2017-04-03 00:00:00	source267	180	802	621
575	2018-06-27	moscow, ulica 575	2	2018-09-22 00:00:00	source575	358	993	627
550	2017-05-14	moscow, ulica 550	3	2017-11-17 00:00:00	source550	248	254	864
643	2018-08-15	moscow, ulica 643	5	2018-06-30 00:00:00	source643	532	88	922
705	2017-10-27	moscow, ulica 705	1	2017-01-25 00:00:00	source705	900	961	419
193	2017-11-17	moscow, ulica 193	4	2018-07-23 00:00:00	source193	636	80	531
956	2017-06-09	moscow, ulica 956	2	2018-07-10 00:00:00	source956	229	538	687
959	2017-03-03	moscow, ulica 959	3	2018-06-05 00:00:00	source959	206	699	379
54	2018-05-15	moscow, ulica 54	2	2018-04-10 00:00:00	source54	92	233	989
756	2017-03-23	moscow, ulica 756	5	2018-06-23 00:00:00	source756	136	285	544
962	2018-01-14	moscow, ulica 962	5	2017-07-27 00:00:00	source962	606	189	55
594	2018-08-15	moscow, ulica 594	3	2018-09-05 00:00:00	source594	754	583	467
780	2018-09-15	moscow, ulica 780	4	2017-11-07 00:00:00	source780	16	672	292
415	2018-10-21	moscow, ulica 415	4	2017-02-06 00:00:00	source415	749	905	968
447	2018-09-20	moscow, ulica 447	3	2017-01-13 00:00:00	source447	390	38	128
875	2018-06-25	moscow, ulica 875	3	2018-07-13 00:00:00	source875	680	192	474
723	2018-02-27	moscow, ulica 723	3	2018-04-02 00:00:00	source723	613	267	220
526	2017-09-02	moscow, ulica 526	5	2017-07-22 00:00:00	source526	205	297	368
371	2018-02-27	moscow, ulica 371	1	2018-05-04 00:00:00	source371	165	101	299
598	2017-06-15	moscow, ulica 598	3	2017-08-25 00:00:00	source598	999	10	83
503	2017-11-06	moscow, ulica 503	4	2018-02-05 00:00:00	source503	371	77	228
668	2017-01-05	moscow, ulica 668	3	2017-08-20 00:00:00	source668	701	802	148
978	2017-05-24	moscow, ulica 978	2	2017-10-21 00:00:00	source978	433	147	42
109	2017-02-27	moscow, ulica 109	5	2017-02-22 00:00:00	source109	691	956	738
758	2017-08-07	moscow, ulica 758	3	2017-01-12 00:00:00	source758	672	763	721
624	2018-12-07	moscow, ulica 624	1	2018-10-21 00:00:00	source624	651	559	666
687	2017-11-23	moscow, ulica 687	5	2017-08-25 00:00:00	source687	350	290	728
507	2017-09-22	moscow, ulica 507	3	2018-07-01 00:00:00	source507	175	642	525
283	2017-05-09	moscow, ulica 283	4	2017-09-08 00:00:00	source283	55	862	995
836	2018-09-30	moscow, ulica 836	5	2017-05-18 00:00:00	source836	978	794	18
711	2017-04-23	moscow, ulica 711	4	2017-11-24 00:00:00	source711	548	307	278
426	2018-01-28	moscow, ulica 426	1	2017-11-28 00:00:00	source426	169	847	500
440	2018-03-31	moscow, ulica 440	4	2018-10-03 00:00:00	source440	423	251	105
681	2017-11-07	moscow, ulica 681	2	2017-07-06 00:00:00	source681	480	735	348
706	2017-11-02	moscow, ulica 706	2	2017-11-15 00:00:00	source706	102	749	291
778	2018-07-31	moscow, ulica 778	2	2017-08-05 00:00:00	source778	565	205	601
331	2018-04-03	moscow, ulica 331	1	2018-12-27 00:00:00	source331	713	267	528
181	2017-02-11	moscow, ulica 181	2	2017-01-17 00:00:00	source181	79	234	233
230	2018-07-09	moscow, ulica 230	4	2018-09-29 00:00:00	source230	294	89	507
284	2017-07-22	moscow, ulica 284	3	2018-07-11 00:00:00	source284	669	607	659
228	2018-03-03	moscow, ulica 228	2	2018-01-21 00:00:00	source228	675	506	428
957	2018-10-17	moscow, ulica 957	5	2017-06-29 00:00:00	source957	103	133	39
770	2017-03-03	moscow, ulica 770	2	2018-11-13 00:00:00	source770	505	807	575
353	2018-05-08	moscow, ulica 353	5	2018-08-23 00:00:00	source353	563	161	751
437	2018-12-16	moscow, ulica 437	5	2018-05-22 00:00:00	source437	499	64	136
654	2018-09-17	moscow, ulica 654	5	2017-03-16 00:00:00	source654	979	519	693
140	2017-12-24	moscow, ulica 140	1	2017-04-28 00:00:00	source140	412	960	62
316	2018-02-09	moscow, ulica 316	4	2017-08-06 00:00:00	source316	470	64	134
290	2018-07-25	moscow, ulica 290	5	2018-06-04 00:00:00	source290	804	660	484
201	2018-03-16	moscow, ulica 201	4	2017-10-09 00:00:00	source201	311	233	718
666	2018-05-03	moscow, ulica 666	5	2018-12-14 00:00:00	source666	926	514	432
841	2018-01-22	moscow, ulica 841	3	2017-04-10 00:00:00	source841	938	237	39
235	2018-11-12	moscow, ulica 235	1	2017-06-10 00:00:00	source235	663	732	284
966	2018-12-07	moscow, ulica 966	2	2017-03-11 00:00:00	source966	721	662	709
483	2017-02-11	moscow, ulica 483	5	2017-03-06 00:00:00	source483	235	931	686
927	2017-08-20	moscow, ulica 927	4	2018-01-05 00:00:00	source927	806	536	764
41	2017-08-02	moscow, ulica 41	3	2018-06-27 00:00:00	source41	455	943	740
369	2017-06-24	moscow, ulica 369	2	2018-03-22 00:00:00	source369	99	316	743
153	2018-11-15	moscow, ulica 153	4	2018-11-09 00:00:00	source153	991	821	604
938	2018-03-04	moscow, ulica 938	4	2017-01-01 00:00:00	source938	515	360	457
727	2018-01-22	moscow, ulica 727	4	2018-11-04 00:00:00	source727	15	240	928
414	2018-05-16	moscow, ulica 414	1	2017-06-18 00:00:00	source414	840	433	379
561	2017-04-17	moscow, ulica 561	1	2018-11-09 00:00:00	source561	902	1	603
807	2018-01-22	moscow, ulica 807	3	2017-04-25 00:00:00	source807	735	55	343
828	2018-11-09	moscow, ulica 828	1	2018-09-15 00:00:00	source828	825	918	891
334	2018-06-24	moscow, ulica 334	5	2017-10-23 00:00:00	source334	166	112	385
255	2017-02-18	moscow, ulica 255	4	2017-10-17 00:00:00	source255	804	827	878
360	2018-09-12	moscow, ulica 360	3	2018-04-10 00:00:00	source360	33	585	182
595	2018-10-02	moscow, ulica 595	4	2017-07-17 00:00:00	source595	446	873	230
344	2017-10-22	moscow, ulica 344	3	2017-10-17 00:00:00	source344	167	802	514
145	2017-12-15	moscow, ulica 145	2	2017-12-24 00:00:00	source145	362	282	395
496	2018-04-25	moscow, ulica 496	5	2018-02-11 00:00:00	source496	952	174	844
42	2017-02-11	moscow, ulica 42	4	2018-11-10 00:00:00	source42	225	338	996
612	2017-10-11	moscow, ulica 612	3	2018-08-06 00:00:00	source612	111	890	699
743	2018-07-01	moscow, ulica 743	3	2018-06-27 00:00:00	source743	954	898	275
631	2018-01-30	moscow, ulica 631	3	2018-10-26 00:00:00	source631	84	147	717
737	2017-06-10	moscow, ulica 737	3	2017-09-22 00:00:00	source737	491	430	725
246	2017-12-10	moscow, ulica 246	2	2018-09-26 00:00:00	source246	840	993	674
636	2018-02-16	moscow, ulica 636	1	2017-12-13 00:00:00	source636	627	53	269
613	2018-02-06	moscow, ulica 613	3	2018-12-31 00:00:00	source613	677	839	361
844	2018-08-07	moscow, ulica 844	5	2018-09-29 00:00:00	source844	124	666	960
288	2018-03-08	moscow, ulica 288	5	2017-11-27 00:00:00	source288	559	999	270
697	2017-03-15	moscow, ulica 697	3	2018-02-28 00:00:00	source697	55	351	465
380	2018-09-24	moscow, ulica 380	1	2018-04-29 00:00:00	source380	288	279	7
881	2018-01-21	moscow, ulica 881	1	2017-04-04 00:00:00	source881	210	934	543
281	2018-06-28	moscow, ulica 281	5	2018-07-01 00:00:00	source281	186	582	420
874	2017-03-18	moscow, ulica 874	2	2017-08-09 00:00:00	source874	497	486	31
373	2018-07-04	moscow, ulica 373	4	2018-05-08 00:00:00	source373	347	550	522
923	2018-02-26	moscow, ulica 923	2	2018-03-15 00:00:00	source923	651	667	859
747	2018-07-13	moscow, ulica 747	1	2017-06-09 00:00:00	source747	727	718	259
800	2018-05-11	moscow, ulica 800	2	2017-03-07 00:00:00	source800	318	947	805
733	2017-04-21	moscow, ulica 733	1	2017-09-17 00:00:00	source733	113	450	482
367	2018-05-16	moscow, ulica 367	3	2017-08-12 00:00:00	source367	555	211	634
948	2017-03-31	moscow, ulica 948	4	2017-06-13 00:00:00	source948	98	349	190
772	2017-10-22	moscow, ulica 772	3	2017-10-23 00:00:00	source772	855	354	637
342	2018-02-28	moscow, ulica 342	3	2017-08-16 00:00:00	source342	522	239	297
4	2018-07-22	moscow, ulica 4	1	2017-09-14 00:00:00	source4	136	789	269
240	2017-12-18	moscow, ulica 240	4	2018-06-30 00:00:00	source240	58	25	795
950	2018-11-05	moscow, ulica 950	3	2018-02-03 00:00:00	source950	803	682	362
475	2018-06-22	moscow, ulica 475	1	2017-10-19 00:00:00	source475	84	345	184
135	2018-10-30	moscow, ulica 135	3	2018-03-23 00:00:00	source135	328	892	807
926	2018-06-21	moscow, ulica 926	2	2017-10-24 00:00:00	source926	591	437	875
216	2018-02-13	moscow, ulica 216	2	2018-03-20 00:00:00	source216	238	772	298
699	2017-01-26	moscow, ulica 699	3	2018-05-06 00:00:00	source699	188	258	546
782	2018-06-27	moscow, ulica 782	4	2018-08-27 00:00:00	source782	571	886	969
23	2017-08-28	moscow, ulica 23	5	2018-10-06 00:00:00	source23	515	691	172
57	2017-03-26	moscow, ulica 57	5	2018-12-27 00:00:00	source57	260	967	244
222	2017-03-19	moscow, ulica 222	3	2017-05-01 00:00:00	source222	921	857	518
674	2017-01-09	moscow, ulica 674	4	2018-01-05 00:00:00	source674	409	556	510
249	2018-02-27	moscow, ulica 249	2	2018-02-20 00:00:00	source249	821	819	285
659	2017-06-19	moscow, ulica 659	3	2018-01-31 00:00:00	source659	602	571	975
460	2017-10-08	moscow, ulica 460	3	2017-09-04 00:00:00	source460	369	813	506
269	2017-11-30	moscow, ulica 269	3	2018-12-27 00:00:00	source269	572	340	878
574	2018-05-05	moscow, ulica 574	2	2017-01-11 00:00:00	source574	186	696	254
129	2017-06-21	moscow, ulica 129	2	2018-07-30 00:00:00	source129	704	678	775
2	2018-01-31	moscow, ulica 2	5	2017-06-21 00:00:00	source2	806	958	62
449	2017-06-21	moscow, ulica 449	1	2017-08-05 00:00:00	source449	640	506	856
763	2018-11-27	moscow, ulica 763	4	2017-10-07 00:00:00	source763	455	13	983
207	2017-10-09	moscow, ulica 207	1	2017-12-06 00:00:00	source207	676	921	655
755	2018-10-31	moscow, ulica 755	2	2017-11-18 00:00:00	source755	659	833	29
916	2017-01-07	moscow, ulica 916	4	2017-05-23 00:00:00	source916	799	209	252
70	2018-11-06	moscow, ulica 70	4	2018-01-26 00:00:00	source70	85	403	961
315	2017-12-02	moscow, ulica 315	3	2018-10-14 00:00:00	source315	775	803	863
46	2017-11-10	moscow, ulica 46	4	2018-01-01 00:00:00	source46	991	994	141
729	2017-12-19	moscow, ulica 729	4	2017-10-20 00:00:00	source729	24	438	152
17	2018-02-05	moscow, ulica 17	3	2017-12-18 00:00:00	source17	158	855	145
900	2018-08-04	moscow, ulica 900	5	2017-12-31 00:00:00	source900	121	762	12
592	2018-11-04	moscow, ulica 592	3	2017-04-11 00:00:00	source592	645	391	57
247	2018-05-29	moscow, ulica 247	3	2018-07-02 00:00:00	source247	636	142	834
861	2017-02-02	moscow, ulica 861	5	2018-05-29 00:00:00	source861	959	379	480
99	2018-06-04	moscow, ulica 99	3	2017-08-21 00:00:00	source99	875	804	716
952	2018-02-26	moscow, ulica 952	2	2018-11-28 00:00:00	source952	989	738	904
922	2017-05-27	moscow, ulica 922	4	2017-08-28 00:00:00	source922	270	850	648
199	2018-07-22	moscow, ulica 199	4	2017-09-06 00:00:00	source199	300	870	981
163	2018-11-29	moscow, ulica 163	5	2017-06-12 00:00:00	source163	356	508	690
964	2018-08-18	moscow, ulica 964	4	2017-08-06 00:00:00	source964	235	502	639
910	2017-05-19	moscow, ulica 910	4	2017-10-07 00:00:00	source910	461	861	26
100	2017-09-19	moscow, ulica 100	1	2018-10-17 00:00:00	source100	949	155	324
239	2018-02-16	moscow, ulica 239	2	2018-07-02 00:00:00	source239	152	80	591
59	2017-09-26	moscow, ulica 59	2	2018-01-30 00:00:00	source59	285	66	307
596	2018-10-28	moscow, ulica 596	2	2018-05-22 00:00:00	source596	999	190	701
793	2017-02-19	moscow, ulica 793	4	2017-08-15 00:00:00	source793	525	7	431
898	2018-12-08	moscow, ulica 898	5	2018-02-21 00:00:00	source898	651	771	854
301	2017-06-23	moscow, ulica 301	2	2018-03-25 00:00:00	source301	745	871	841
403	2018-04-23	moscow, ulica 403	1	2017-04-02 00:00:00	source403	995	786	664
835	2017-05-06	moscow, ulica 835	4	2018-08-18 00:00:00	source835	211	702	22
385	2018-08-25	moscow, ulica 385	5	2018-02-04 00:00:00	source385	518	915	354
124	2017-02-17	moscow, ulica 124	2	2018-02-21 00:00:00	source124	66	848	898
86	2018-03-10	moscow, ulica 86	4	2017-03-25 00:00:00	source86	273	248	726
658	2017-09-29	moscow, ulica 658	2	2017-04-30 00:00:00	source658	1	820	21
557	2018-05-11	moscow, ulica 557	3	2017-10-31 00:00:00	source557	64	884	830
296	2017-07-18	moscow, ulica 296	5	2017-07-07 00:00:00	source296	162	939	869
579	2018-11-08	moscow, ulica 579	1	2018-05-28 00:00:00	source579	585	740	377
713	2017-04-17	moscow, ulica 713	1	2018-02-10 00:00:00	source713	113	959	322
649	2017-09-19	moscow, ulica 649	1	2018-11-06 00:00:00	source649	958	657	586
322	2017-08-31	moscow, ulica 322	4	2018-04-21 00:00:00	source322	527	943	913
418	2017-04-04	moscow, ulica 418	5	2018-02-01 00:00:00	source418	693	218	677
456	2017-08-04	moscow, ulica 456	2	2018-09-10 00:00:00	source456	789	501	771
389	2017-11-10	moscow, ulica 389	4	2018-04-07 00:00:00	source389	199	190	361
903	2018-11-09	moscow, ulica 903	2	2017-06-20 00:00:00	source903	666	424	811
261	2017-08-03	moscow, ulica 261	3	2018-08-24 00:00:00	source261	880	331	791
751	2018-10-17	moscow, ulica 751	4	2018-05-15 00:00:00	source751	226	224	540
127	2017-01-17	moscow, ulica 127	1	2018-05-20 00:00:00	source127	461	171	527
662	2017-10-08	moscow, ulica 662	5	2017-08-07 00:00:00	source662	467	597	392
661	2018-03-15	moscow, ulica 661	5	2018-10-21 00:00:00	source661	310	764	758
295	2017-04-03	moscow, ulica 295	2	2018-09-19 00:00:00	source295	35	473	92
56	2018-09-14	moscow, ulica 56	4	2017-10-26 00:00:00	source56	167	803	938
72	2018-10-23	moscow, ulica 72	3	2017-03-01 00:00:00	source72	36	387	56
461	2017-03-03	moscow, ulica 461	2	2017-02-21 00:00:00	source461	88	489	832
969	2018-12-05	moscow, ulica 969	4	2018-08-15 00:00:00	source969	66	869	855
480	2017-01-17	moscow, ulica 480	4	2017-06-21 00:00:00	source480	308	460	388
996	2018-11-12	moscow, ulica 996	4	2017-09-11 00:00:00	source996	129	903	488
259	2017-04-20	moscow, ulica 259	1	2018-03-10 00:00:00	source259	936	268	976
536	2018-12-09	moscow, ulica 536	2	2018-12-18 00:00:00	source536	617	811	156
576	2017-10-27	moscow, ulica 576	1	2017-04-27 00:00:00	source576	145	503	788
463	2017-09-25	moscow, ulica 463	3	2017-01-04 00:00:00	source463	191	22	457
313	2017-08-03	moscow, ulica 313	2	2018-03-13 00:00:00	source313	962	262	656
218	2018-10-05	moscow, ulica 218	3	2018-12-18 00:00:00	source218	498	406	774
718	2017-09-08	moscow, ulica 718	4	2018-03-30 00:00:00	source718	844	900	502
184	2018-05-06	moscow, ulica 184	1	2017-11-27 00:00:00	source184	206	38	709
653	2018-06-18	moscow, ulica 653	5	2018-08-30 00:00:00	source653	172	161	967
225	2018-10-24	moscow, ulica 225	4	2018-06-06 00:00:00	source225	799	258	676
251	2017-06-26	moscow, ulica 251	3	2017-06-15 00:00:00	source251	272	631	132
319	2017-03-06	moscow, ulica 319	2	2017-05-16 00:00:00	source319	180	331	535
66	2017-07-03	moscow, ulica 66	1	2018-03-26 00:00:00	source66	31	269	83
173	2017-10-25	moscow, ulica 173	2	2018-09-30 00:00:00	source173	907	395	698
289	2018-03-23	moscow, ulica 289	3	2018-03-25 00:00:00	source289	749	514	296
518	2018-01-05	moscow, ulica 518	5	2018-05-16 00:00:00	source518	665	145	111
8	2018-10-12	moscow, ulica 8	5	2017-08-30 00:00:00	source8	563	619	217
495	2018-07-17	moscow, ulica 495	3	2018-06-09 00:00:00	source495	330	368	897
339	2018-07-09	moscow, ulica 339	2	2017-02-20 00:00:00	source339	110	841	364
700	2017-04-05	moscow, ulica 700	1	2017-04-29 00:00:00	source700	55	560	471
107	2018-01-21	moscow, ulica 107	5	2018-11-24 00:00:00	source107	742	909	158
164	2018-04-28	moscow, ulica 164	1	2017-11-17 00:00:00	source164	466	913	477
798	2017-07-02	moscow, ulica 798	3	2018-08-27 00:00:00	source798	270	357	233
374	2018-08-25	moscow, ulica 374	3	2018-01-15 00:00:00	source374	115	446	359
77	2018-07-22	moscow, ulica 77	4	2018-08-28 00:00:00	source77	441	548	765
599	2018-09-05	moscow, ulica 599	4	2017-10-31 00:00:00	source599	66	761	680
512	2018-10-03	moscow, ulica 512	3	2018-07-05 00:00:00	source512	771	24	519
434	2017-03-24	moscow, ulica 434	2	2018-07-10 00:00:00	source434	805	999	243
735	2018-03-12	moscow, ulica 735	1	2018-10-17 00:00:00	source735	19	616	777
270	2017-12-01	moscow, ulica 270	2	2018-09-12 00:00:00	source270	35	963	138
345	2018-01-20	moscow, ulica 345	2	2018-10-26 00:00:00	source345	552	759	528
314	2017-08-24	moscow, ulica 314	1	2018-06-12 00:00:00	source314	992	877	922
65	2018-05-23	moscow, ulica 65	5	2017-03-24 00:00:00	source65	357	680	785
38	2018-03-23	moscow, ulica 38	3	2018-06-06 00:00:00	source38	487	156	449
120	2018-08-02	moscow, ulica 120	4	2017-01-16 00:00:00	source120	749	19	850
695	2018-05-17	moscow, ulica 695	5	2017-06-22 00:00:00	source695	856	132	790
32	2017-11-18	moscow, ulica 32	2	2018-01-23 00:00:00	source32	16	699	509
684	2017-06-20	moscow, ulica 684	3	2017-08-18 00:00:00	source684	379	218	13
63	2018-12-14	moscow, ulica 63	4	2018-11-30 00:00:00	source63	617	726	500
357	2018-05-18	moscow, ulica 357	3	2017-05-19 00:00:00	source357	406	5	853
337	2018-09-03	moscow, ulica 337	3	2018-09-05 00:00:00	source337	277	420	848
904	2018-11-22	moscow, ulica 904	4	2017-01-14 00:00:00	source904	648	575	885
326	2017-03-20	moscow, ulica 326	1	2017-04-11 00:00:00	source326	531	395	894
494	2017-08-18	moscow, ulica 494	2	2017-08-22 00:00:00	source494	528	397	940
492	2017-11-12	moscow, ulica 492	5	2018-03-11 00:00:00	source492	995	831	464
825	2018-02-08	moscow, ulica 825	1	2018-08-15 00:00:00	source825	978	347	252
664	2018-10-20	moscow, ulica 664	1	2017-05-03 00:00:00	source664	18	836	500
633	2017-08-25	moscow, ulica 633	1	2018-11-12 00:00:00	source633	265	561	184
363	2017-11-22	moscow, ulica 363	1	2017-11-23 00:00:00	source363	132	375	745
823	2018-12-02	moscow, ulica 823	1	2018-04-13 00:00:00	source823	320	117	345
931	2018-12-16	moscow, ulica 931	5	2018-08-18 00:00:00	source931	176	377	193
709	2018-07-23	moscow, ulica 709	5	2018-11-22 00:00:00	source709	788	768	486
609	2017-02-06	moscow, ulica 609	4	2018-07-14 00:00:00	source609	332	342	864
126	2017-07-30	moscow, ulica 126	2	2018-06-18 00:00:00	source126	466	801	809
125	2018-12-31	moscow, ulica 125	1	2018-05-04 00:00:00	source125	370	120	817
245	2018-03-30	moscow, ulica 245	4	2017-11-27 00:00:00	source245	169	736	240
71	2017-01-20	moscow, ulica 71	5	2017-08-21 00:00:00	source71	663	710	935
902	2018-10-08	moscow, ulica 902	2	2018-10-08 00:00:00	source902	827	969	63
680	2017-04-13	moscow, ulica 680	3	2017-01-17 00:00:00	source680	457	956	218
481	2017-09-30	moscow, ulica 481	2	2018-01-27 00:00:00	source481	70	769	391
604	2018-10-10	moscow, ulica 604	1	2018-05-04 00:00:00	source604	224	970	508
192	2018-09-29	moscow, ulica 192	4	2017-09-21 00:00:00	source192	591	410	452
683	2018-09-20	moscow, ulica 683	4	2018-12-06 00:00:00	source683	635	367	573
395	2018-09-11	moscow, ulica 395	4	2018-02-07 00:00:00	source395	720	821	672
73	2017-07-28	moscow, ulica 73	1	2017-11-29 00:00:00	source73	733	513	433
672	2017-07-18	moscow, ulica 672	4	2018-01-21 00:00:00	source672	604	92	675
885	2017-10-13	moscow, ulica 885	1	2017-08-29 00:00:00	source885	312	281	583
391	2018-07-11	moscow, ulica 391	1	2018-11-05 00:00:00	source391	902	223	63
726	2018-05-07	moscow, ulica 726	5	2017-08-17 00:00:00	source726	262	847	660
560	2017-02-01	moscow, ulica 560	1	2018-01-03 00:00:00	source560	704	438	876
897	2018-07-03	moscow, ulica 897	1	2018-06-28 00:00:00	source897	301	794	858
420	2017-10-23	moscow, ulica 420	5	2018-08-01 00:00:00	source420	60	896	405
491	2018-11-29	moscow, ulica 491	1	2017-11-24 00:00:00	source491	495	450	2
271	2017-06-13	moscow, ulica 271	1	2018-07-30 00:00:00	source271	394	500	384
309	2018-08-04	moscow, ulica 309	1	2017-03-12 00:00:00	source309	316	996	45
298	2017-06-20	moscow, ulica 298	1	2017-07-25 00:00:00	source298	764	321	408
408	2017-08-22	moscow, ulica 408	3	2017-01-14 00:00:00	source408	448	444	172
939	2017-09-02	moscow, ulica 939	1	2018-01-17 00:00:00	source939	895	108	7
831	2017-11-16	moscow, ulica 831	4	2018-02-17 00:00:00	source831	345	758	705
139	2018-04-21	moscow, ulica 139	2	2017-06-26 00:00:00	source139	694	230	566
742	2018-06-21	moscow, ulica 742	1	2017-04-15 00:00:00	source742	371	236	282
5	2017-01-17	moscow, ulica 5	3	2018-04-19 00:00:00	source5	398	394	671
880	2017-02-13	moscow, ulica 880	2	2018-10-09 00:00:00	source880	278	50	141
30	2017-08-02	moscow, ulica 30	2	2017-11-10 00:00:00	source30	86	75	282
905	2017-09-15	moscow, ulica 905	3	2018-06-24 00:00:00	source905	377	224	745
101	2017-05-12	moscow, ulica 101	5	2018-08-14 00:00:00	source101	688	764	692
730	2018-06-23	moscow, ulica 730	1	2018-05-14 00:00:00	source730	847	349	568
545	2017-01-22	moscow, ulica 545	5	2017-05-14 00:00:00	source545	25	871	616
802	2018-01-15	moscow, ulica 802	2	2018-12-08 00:00:00	source802	3	192	346
427	2017-12-09	moscow, ulica 427	3	2017-05-30 00:00:00	source427	350	625	545
\.


--
-- Data for Name: couriers; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.couriers (courier_id, car_type, login, password, salary) FROM stdin;
1	3	asddads	qwerty	50000
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.customers (userr_id, fio, birthday, email, passw, dateofregistration, contact_phone, discount) FROM stdin;
1	Ivan1	1974-05-29	nas@tam.net1	gg1	2020-06-02	74953222233	7
2	Ivan2	1977-03-15	nas@tam.net2	gg2	2020-05-13	74953222234	70
3	Ivan3	1968-09-16	nas@tam.net3	gg3	2020-08-26	74953222235	67
4	Ivan4	1982-08-01	nas@tam.net4	gg4	2020-04-21	74953222236	18
5	Ivan5	1975-04-06	nas@tam.net5	gg5	2020-12-12	74953222237	76
6	Ivan6	1967-10-05	nas@tam.net6	gg6	2020-02-17	74953222238	15
7	Ivan7	1974-12-08	nas@tam.net7	gg7	2020-04-17	74953222239	75
8	Ivan8	1960-11-04	nas@tam.net8	gg8	2020-04-07	74953222240	95
9	Ivan9	1973-08-31	nas@tam.net9	gg9	2020-09-07	74953222241	54
10	Ivan10	1954-04-02	nas@tam.net10	gg10	2020-09-29	74953222242	97
11	Ivan11	1992-07-23	nas@tam.net11	gg11	2020-08-31	74953222243	99
12	Ivan12	1955-08-28	nas@tam.net12	gg12	2020-11-30	74953222244	13
13	Ivan13	1998-07-24	nas@tam.net13	gg13	2020-10-18	74953222245	21
14	Ivan14	1982-07-17	nas@tam.net14	gg14	2020-01-05	74953222246	44
15	Ivan15	1962-03-03	nas@tam.net15	gg15	2020-03-29	74953222247	49
16	Ivan16	1960-04-25	nas@tam.net16	gg16	2020-10-11	74953222248	17
17	Ivan17	1966-08-06	nas@tam.net17	gg17	2020-03-31	74953222249	35
18	Ivan18	1960-04-21	nas@tam.net18	gg18	2020-08-26	74953222250	56
19	Ivan19	1979-11-26	nas@tam.net19	gg19	2020-10-07	74953222251	76
20	Ivan20	1950-02-01	nas@tam.net20	gg20	2020-01-10	74953222252	80
21	Ivan21	1969-06-18	nas@tam.net21	gg21	2020-10-19	74953222253	86
22	Ivan22	1957-07-18	nas@tam.net22	gg22	2020-03-22	74953222254	42
23	Ivan23	1980-06-19	nas@tam.net23	gg23	2020-10-03	74953222255	59
24	Ivan24	1993-07-25	nas@tam.net24	gg24	2020-10-26	74953222256	57
25	Ivan25	1958-10-24	nas@tam.net25	gg25	2020-05-01	74953222257	26
26	Ivan26	1972-12-02	nas@tam.net26	gg26	2020-12-03	74953222258	19
27	Ivan27	1984-02-04	nas@tam.net27	gg27	2020-12-09	74953222259	14
28	Ivan28	1950-04-29	nas@tam.net28	gg28	2020-06-30	74953222260	70
29	Ivan29	1960-02-07	nas@tam.net29	gg29	2020-04-23	74953222261	19
30	Ivan30	1979-07-31	nas@tam.net30	gg30	2020-12-21	74953222262	12
31	Ivan31	1961-11-27	nas@tam.net31	gg31	2020-05-18	74953222263	66
32	Ivan32	1960-06-13	nas@tam.net32	gg32	2020-08-13	74953222264	30
33	Ivan33	1961-12-24	nas@tam.net33	gg33	2020-04-03	74953222265	2
34	Ivan34	1999-09-01	nas@tam.net34	gg34	2020-08-16	74953222266	1
35	Ivan35	1997-09-16	nas@tam.net35	gg35	2020-01-31	74953222267	4
36	Ivan36	1981-07-03	nas@tam.net36	gg36	2020-12-15	74953222268	85
37	Ivan37	1966-09-18	nas@tam.net37	gg37	2020-12-08	74953222269	36
38	Ivan38	1950-08-03	nas@tam.net38	gg38	2020-03-26	74953222270	40
39	Ivan39	1979-11-10	nas@tam.net39	gg39	2020-05-09	74953222271	6
40	Ivan40	1965-06-07	nas@tam.net40	gg40	2020-12-18	74953222272	44
41	Ivan41	1977-02-12	nas@tam.net41	gg41	2020-09-09	74953222273	4
42	Ivan42	1998-11-28	nas@tam.net42	gg42	2020-04-24	74953222274	59
43	Ivan43	1987-04-03	nas@tam.net43	gg43	2020-05-06	74953222275	90
44	Ivan44	1979-10-28	nas@tam.net44	gg44	2020-04-12	74953222276	31
45	Ivan45	1970-01-30	nas@tam.net45	gg45	2020-08-17	74953222277	51
46	Ivan46	1977-08-02	nas@tam.net46	gg46	2020-06-19	74953222278	34
47	Ivan47	1964-01-09	nas@tam.net47	gg47	2020-09-06	74953222279	41
48	Ivan48	1951-04-13	nas@tam.net48	gg48	2020-07-21	74953222280	32
49	Ivan49	1967-04-30	nas@tam.net49	gg49	2020-05-07	74953222281	97
50	Ivan50	1963-09-14	nas@tam.net50	gg50	2020-08-21	74953222282	46
51	Ivan51	1964-04-26	nas@tam.net51	gg51	2020-11-16	74953222283	48
52	Ivan52	1950-08-08	nas@tam.net52	gg52	2020-04-28	74953222284	24
53	Ivan53	1956-03-02	nas@tam.net53	gg53	2020-04-09	74953222285	80
54	Ivan54	1978-10-02	nas@tam.net54	gg54	2020-01-26	74953222286	7
55	Ivan55	1986-11-03	nas@tam.net55	gg55	2020-08-03	74953222287	39
56	Ivan56	1995-01-11	nas@tam.net56	gg56	2020-09-04	74953222288	72
57	Ivan57	1995-12-28	nas@tam.net57	gg57	2020-06-13	74953222289	6
58	Ivan58	1999-02-14	nas@tam.net58	gg58	2020-07-08	74953222290	95
59	Ivan59	1973-08-11	nas@tam.net59	gg59	2020-12-11	74953222291	25
60	Ivan60	1962-01-27	nas@tam.net60	gg60	2020-03-17	74953222292	29
61	Ivan61	1963-09-20	nas@tam.net61	gg61	2020-07-01	74953222293	89
62	Ivan62	1987-01-26	nas@tam.net62	gg62	2020-04-18	74953222294	24
63	Ivan63	1967-10-19	nas@tam.net63	gg63	2020-04-03	74953222295	18
64	Ivan64	1950-03-22	nas@tam.net64	gg64	2020-06-26	74953222296	15
65	Ivan65	1986-04-18	nas@tam.net65	gg65	2020-11-30	74953222297	66
66	Ivan66	1965-12-14	nas@tam.net66	gg66	2020-11-02	74953222298	19
67	Ivan67	1964-03-29	nas@tam.net67	gg67	2020-06-21	74953222299	65
68	Ivan68	1978-06-19	nas@tam.net68	gg68	2020-07-22	74953222300	5
69	Ivan69	1992-02-08	nas@tam.net69	gg69	2020-03-28	74953222301	22
70	Ivan70	1988-07-07	nas@tam.net70	gg70	2020-08-02	74953222302	7
71	Ivan71	1951-07-21	nas@tam.net71	gg71	2020-07-29	74953222303	1
72	Ivan72	1966-10-22	nas@tam.net72	gg72	2020-01-16	74953222304	1
73	Ivan73	1951-01-07	nas@tam.net73	gg73	2020-03-04	74953222305	81
74	Ivan74	1990-05-28	nas@tam.net74	gg74	2020-08-12	74953222306	84
75	Ivan75	1962-01-12	nas@tam.net75	gg75	2020-05-31	74953222307	27
76	Ivan76	1998-05-19	nas@tam.net76	gg76	2020-03-29	74953222308	39
77	Ivan77	1956-09-28	nas@tam.net77	gg77	2020-06-25	74953222309	99
78	Ivan78	1983-02-25	nas@tam.net78	gg78	2020-02-23	74953222310	66
79	Ivan79	1968-01-24	nas@tam.net79	gg79	2020-12-09	74953222311	80
80	Ivan80	1967-06-15	nas@tam.net80	gg80	2020-02-29	74953222312	48
81	Ivan81	1950-08-06	nas@tam.net81	gg81	2020-07-10	74953222313	72
82	Ivan82	1995-02-28	nas@tam.net82	gg82	2020-07-29	74953222314	89
83	Ivan83	1995-03-31	nas@tam.net83	gg83	2020-10-21	74953222315	39
84	Ivan84	1976-06-04	nas@tam.net84	gg84	2020-01-10	74953222316	6
85	Ivan85	1974-03-01	nas@tam.net85	gg85	2020-02-17	74953222317	83
86	Ivan86	1988-06-12	nas@tam.net86	gg86	2020-12-18	74953222318	4
87	Ivan87	1957-10-19	nas@tam.net87	gg87	2020-08-10	74953222319	48
88	Ivan88	1983-02-25	nas@tam.net88	gg88	2020-09-15	74953222320	74
89	Ivan89	1960-07-07	nas@tam.net89	gg89	2020-12-28	74953222321	31
90	Ivan90	1991-03-28	nas@tam.net90	gg90	2020-09-22	74953222322	60
91	Ivan91	1975-07-21	nas@tam.net91	gg91	2020-03-03	74953222323	95
92	Ivan92	1990-04-06	nas@tam.net92	gg92	2020-08-30	74953222324	36
93	Ivan93	1958-07-05	nas@tam.net93	gg93	2020-06-03	74953222325	33
94	Ivan94	1956-10-21	nas@tam.net94	gg94	2020-11-22	74953222326	49
95	Ivan95	1951-05-23	nas@tam.net95	gg95	2020-09-24	74953222327	74
96	Ivan96	1968-05-18	nas@tam.net96	gg96	2020-04-28	74953222328	100
97	Ivan97	1967-10-09	nas@tam.net97	gg97	2020-10-16	74953222329	70
98	Ivan98	1985-02-11	nas@tam.net98	gg98	2020-03-25	74953222330	99
99	Ivan99	1973-06-18	nas@tam.net99	gg99	2020-06-24	74953222331	64
100	Ivan100	1982-02-06	nas@tam.net100	gg100	2020-04-18	74953222332	76
101	Ivan101	1988-01-27	nas@tam.net101	gg101	2020-03-20	74953222333	47
102	Ivan102	1976-12-25	nas@tam.net102	gg102	2020-06-03	74953222334	77
103	Ivan103	1976-07-17	nas@tam.net103	gg103	2020-12-03	74953222335	52
104	Ivan104	1984-05-11	nas@tam.net104	gg104	2020-04-10	74953222336	96
105	Ivan105	1979-04-22	nas@tam.net105	gg105	2020-06-10	74953222337	90
106	Ivan106	1961-05-29	nas@tam.net106	gg106	2020-09-26	74953222338	74
107	Ivan107	1978-05-26	nas@tam.net107	gg107	2020-09-08	74953222339	17
108	Ivan108	1993-02-21	nas@tam.net108	gg108	2020-09-18	74953222340	42
109	Ivan109	1982-03-05	nas@tam.net109	gg109	2020-09-30	74953222341	79
110	Ivan110	1957-10-05	nas@tam.net110	gg110	2020-08-04	74953222342	32
111	Ivan111	1957-10-17	nas@tam.net111	gg111	2020-05-08	74953222343	69
112	Ivan112	1998-03-26	nas@tam.net112	gg112	2020-05-28	74953222344	0
113	Ivan113	1995-08-25	nas@tam.net113	gg113	2020-08-08	74953222345	99
114	Ivan114	1975-12-30	nas@tam.net114	gg114	2020-05-27	74953222346	62
115	Ivan115	1988-05-16	nas@tam.net115	gg115	2020-03-23	74953222347	62
116	Ivan116	1958-11-12	nas@tam.net116	gg116	2020-01-15	74953222348	2
117	Ivan117	1957-03-24	nas@tam.net117	gg117	2020-09-20	74953222349	28
118	Ivan118	1950-02-08	nas@tam.net118	gg118	2020-03-25	74953222350	60
119	Ivan119	1960-01-18	nas@tam.net119	gg119	2020-04-14	74953222351	54
120	Ivan120	1981-04-24	nas@tam.net120	gg120	2020-01-07	74953222352	80
121	Ivan121	1990-10-25	nas@tam.net121	gg121	2020-05-07	74953222353	26
122	Ivan122	1992-09-29	nas@tam.net122	gg122	2020-09-04	74953222354	57
123	Ivan123	1982-08-29	nas@tam.net123	gg123	2020-02-04	74953222355	38
124	Ivan124	1986-12-16	nas@tam.net124	gg124	2020-01-14	74953222356	18
125	Ivan125	1995-12-27	nas@tam.net125	gg125	2020-01-07	74953222357	66
126	Ivan126	1990-06-23	nas@tam.net126	gg126	2020-10-22	74953222358	28
127	Ivan127	1995-02-07	nas@tam.net127	gg127	2020-07-28	74953222359	74
128	Ivan128	1983-02-28	nas@tam.net128	gg128	2020-11-04	74953222360	28
129	Ivan129	1957-07-01	nas@tam.net129	gg129	2020-11-23	74953222361	29
130	Ivan130	1963-05-12	nas@tam.net130	gg130	2020-09-12	74953222362	52
131	Ivan131	1971-01-30	nas@tam.net131	gg131	2020-11-11	74953222363	64
132	Ivan132	1963-10-31	nas@tam.net132	gg132	2020-12-17	74953222364	61
133	Ivan133	1989-03-10	nas@tam.net133	gg133	2020-01-26	74953222365	47
134	Ivan134	1993-10-08	nas@tam.net134	gg134	2020-06-26	74953222366	31
135	Ivan135	1954-01-19	nas@tam.net135	gg135	2020-08-04	74953222367	44
136	Ivan136	1998-08-29	nas@tam.net136	gg136	2020-07-05	74953222368	86
137	Ivan137	1998-12-15	nas@tam.net137	gg137	2020-07-22	74953222369	15
138	Ivan138	1950-06-14	nas@tam.net138	gg138	2020-08-10	74953222370	94
139	Ivan139	1952-08-24	nas@tam.net139	gg139	2020-02-10	74953222371	54
140	Ivan140	1984-04-14	nas@tam.net140	gg140	2020-11-27	74953222372	3
141	Ivan141	1958-10-24	nas@tam.net141	gg141	2020-02-22	74953222373	12
142	Ivan142	1951-06-21	nas@tam.net142	gg142	2020-01-16	74953222374	35
143	Ivan143	1954-08-22	nas@tam.net143	gg143	2020-04-01	74953222375	83
144	Ivan144	1965-08-26	nas@tam.net144	gg144	2020-01-26	74953222376	41
145	Ivan145	1980-10-17	nas@tam.net145	gg145	2020-01-27	74953222377	7
146	Ivan146	1978-04-03	nas@tam.net146	gg146	2020-10-11	74953222378	58
147	Ivan147	1980-02-03	nas@tam.net147	gg147	2020-12-21	74953222379	100
148	Ivan148	1976-08-16	nas@tam.net148	gg148	2020-03-21	74953222380	16
149	Ivan149	1995-12-27	nas@tam.net149	gg149	2020-05-06	74953222381	13
150	Ivan150	1965-08-21	nas@tam.net150	gg150	2020-01-16	74953222382	20
151	Ivan151	1978-08-09	nas@tam.net151	gg151	2020-09-21	74953222383	1
152	Ivan152	1968-12-25	nas@tam.net152	gg152	2020-02-15	74953222384	65
153	Ivan153	1996-07-29	nas@tam.net153	gg153	2020-10-13	74953222385	90
154	Ivan154	1980-05-10	nas@tam.net154	gg154	2020-08-12	74953222386	21
155	Ivan155	1991-02-09	nas@tam.net155	gg155	2020-03-08	74953222387	79
156	Ivan156	1968-07-17	nas@tam.net156	gg156	2020-06-02	74953222388	14
157	Ivan157	1963-07-14	nas@tam.net157	gg157	2020-05-27	74953222389	94
158	Ivan158	1962-11-02	nas@tam.net158	gg158	2020-10-05	74953222390	70
159	Ivan159	1988-10-01	nas@tam.net159	gg159	2020-01-07	74953222391	67
160	Ivan160	1956-12-16	nas@tam.net160	gg160	2020-02-29	74953222392	12
161	Ivan161	1978-09-02	nas@tam.net161	gg161	2020-08-11	74953222393	81
162	Ivan162	1972-10-15	nas@tam.net162	gg162	2020-09-27	74953222394	60
163	Ivan163	1993-05-20	nas@tam.net163	gg163	2020-03-04	74953222395	89
164	Ivan164	1975-01-27	nas@tam.net164	gg164	2020-01-03	74953222396	79
165	Ivan165	1994-02-03	nas@tam.net165	gg165	2020-09-22	74953222397	36
166	Ivan166	1955-05-15	nas@tam.net166	gg166	2020-07-17	74953222398	25
167	Ivan167	1968-03-16	nas@tam.net167	gg167	2020-06-11	74953222399	72
168	Ivan168	1953-10-04	nas@tam.net168	gg168	2020-07-04	74953222400	29
169	Ivan169	1995-01-06	nas@tam.net169	gg169	2020-06-03	74953222401	32
170	Ivan170	1959-10-07	nas@tam.net170	gg170	2020-10-09	74953222402	0
171	Ivan171	1991-06-02	nas@tam.net171	gg171	2020-10-04	74953222403	24
172	Ivan172	1990-06-24	nas@tam.net172	gg172	2020-11-04	74953222404	20
173	Ivan173	1971-05-11	nas@tam.net173	gg173	2020-12-10	74953222405	7
174	Ivan174	1954-03-05	nas@tam.net174	gg174	2020-02-16	74953222406	67
175	Ivan175	1997-01-16	nas@tam.net175	gg175	2020-12-18	74953222407	77
176	Ivan176	1983-10-05	nas@tam.net176	gg176	2020-11-08	74953222408	58
177	Ivan177	1979-03-18	nas@tam.net177	gg177	2020-04-23	74953222409	13
178	Ivan178	1982-02-12	nas@tam.net178	gg178	2020-07-02	74953222410	45
179	Ivan179	1961-12-26	nas@tam.net179	gg179	2020-01-08	74953222411	41
180	Ivan180	1992-02-14	nas@tam.net180	gg180	2020-08-21	74953222412	23
181	Ivan181	1957-12-04	nas@tam.net181	gg181	2020-08-26	74953222413	16
182	Ivan182	1963-07-18	nas@tam.net182	gg182	2020-01-31	74953222414	25
183	Ivan183	1953-03-06	nas@tam.net183	gg183	2020-12-06	74953222415	80
184	Ivan184	1950-09-30	nas@tam.net184	gg184	2020-07-21	74953222416	70
185	Ivan185	1977-08-27	nas@tam.net185	gg185	2020-10-10	74953222417	67
186	Ivan186	1957-11-05	nas@tam.net186	gg186	2020-06-07	74953222418	3
187	Ivan187	1951-08-31	nas@tam.net187	gg187	2020-10-27	74953222419	32
188	Ivan188	1992-03-31	nas@tam.net188	gg188	2020-02-29	74953222420	68
189	Ivan189	1999-04-23	nas@tam.net189	gg189	2020-03-20	74953222421	78
190	Ivan190	1956-12-23	nas@tam.net190	gg190	2020-01-25	74953222422	0
191	Ivan191	1967-12-22	nas@tam.net191	gg191	2020-06-08	74953222423	24
192	Ivan192	1973-07-26	nas@tam.net192	gg192	2020-08-07	74953222424	40
193	Ivan193	1983-02-18	nas@tam.net193	gg193	2020-08-16	74953222425	81
194	Ivan194	1975-03-21	nas@tam.net194	gg194	2020-08-01	74953222426	37
195	Ivan195	1960-01-09	nas@tam.net195	gg195	2020-07-01	74953222427	92
196	Ivan196	1953-07-25	nas@tam.net196	gg196	2020-10-19	74953222428	30
197	Ivan197	1988-04-14	nas@tam.net197	gg197	2020-09-21	74953222429	32
198	Ivan198	1982-11-16	nas@tam.net198	gg198	2020-04-16	74953222430	39
199	Ivan199	1999-10-28	nas@tam.net199	gg199	2020-07-11	74953222431	59
200	Ivan200	1992-08-17	nas@tam.net200	gg200	2020-10-26	74953222432	24
201	Ivan201	1998-11-30	nas@tam.net201	gg201	2020-04-28	74953222433	48
202	Ivan202	1999-11-15	nas@tam.net202	gg202	2020-02-10	74953222434	51
203	Ivan203	1951-10-26	nas@tam.net203	gg203	2020-05-21	74953222435	54
204	Ivan204	1994-10-09	nas@tam.net204	gg204	2020-10-24	74953222436	72
205	Ivan205	1994-05-30	nas@tam.net205	gg205	2020-10-26	74953222437	61
206	Ivan206	1963-04-06	nas@tam.net206	gg206	2020-09-27	74953222438	91
207	Ivan207	1955-01-06	nas@tam.net207	gg207	2020-12-18	74953222439	38
208	Ivan208	1969-12-31	nas@tam.net208	gg208	2020-02-05	74953222440	46
209	Ivan209	1963-08-14	nas@tam.net209	gg209	2020-09-03	74953222441	58
210	Ivan210	1979-01-30	nas@tam.net210	gg210	2020-09-07	74953222442	62
211	Ivan211	1993-09-19	nas@tam.net211	gg211	2020-06-28	74953222443	75
212	Ivan212	1950-02-13	nas@tam.net212	gg212	2020-01-18	74953222444	26
213	Ivan213	1979-10-12	nas@tam.net213	gg213	2020-09-29	74953222445	30
214	Ivan214	1989-06-28	nas@tam.net214	gg214	2020-08-16	74953222446	59
215	Ivan215	1993-02-06	nas@tam.net215	gg215	2020-01-05	74953222447	94
216	Ivan216	1953-06-16	nas@tam.net216	gg216	2020-05-12	74953222448	94
217	Ivan217	1967-06-28	nas@tam.net217	gg217	2020-02-29	74953222449	16
218	Ivan218	1956-11-20	nas@tam.net218	gg218	2020-11-22	74953222450	76
219	Ivan219	1973-10-05	nas@tam.net219	gg219	2020-11-07	74953222451	22
220	Ivan220	1965-06-15	nas@tam.net220	gg220	2020-12-14	74953222452	57
221	Ivan221	1966-02-23	nas@tam.net221	gg221	2020-06-21	74953222453	44
222	Ivan222	1960-11-07	nas@tam.net222	gg222	2020-07-05	74953222454	68
223	Ivan223	1980-12-03	nas@tam.net223	gg223	2020-03-21	74953222455	37
224	Ivan224	1984-06-13	nas@tam.net224	gg224	2020-02-04	74953222456	78
225	Ivan225	1953-10-01	nas@tam.net225	gg225	2020-10-04	74953222457	56
226	Ivan226	1997-03-26	nas@tam.net226	gg226	2020-07-24	74953222458	5
227	Ivan227	1953-08-20	nas@tam.net227	gg227	2020-04-10	74953222459	6
228	Ivan228	1983-09-27	nas@tam.net228	gg228	2020-04-17	74953222460	75
229	Ivan229	1976-08-05	nas@tam.net229	gg229	2020-05-01	74953222461	50
230	Ivan230	1991-06-16	nas@tam.net230	gg230	2020-07-07	74953222462	95
231	Ivan231	1960-05-02	nas@tam.net231	gg231	2020-06-05	74953222463	2
232	Ivan232	1998-01-01	nas@tam.net232	gg232	2020-07-23	74953222464	53
233	Ivan233	1993-03-22	nas@tam.net233	gg233	2020-08-29	74953222465	71
234	Ivan234	1953-06-24	nas@tam.net234	gg234	2020-10-09	74953222466	54
235	Ivan235	1985-01-08	nas@tam.net235	gg235	2020-09-13	74953222467	91
236	Ivan236	1980-04-13	nas@tam.net236	gg236	2020-09-05	74953222468	50
237	Ivan237	1990-12-06	nas@tam.net237	gg237	2020-01-14	74953222469	65
238	Ivan238	1987-10-24	nas@tam.net238	gg238	2020-11-29	74953222470	15
239	Ivan239	1969-03-27	nas@tam.net239	gg239	2020-07-09	74953222471	59
240	Ivan240	1979-05-05	nas@tam.net240	gg240	2020-08-19	74953222472	29
241	Ivan241	1988-05-22	nas@tam.net241	gg241	2020-06-27	74953222473	70
242	Ivan242	1976-11-21	nas@tam.net242	gg242	2020-07-30	74953222474	24
243	Ivan243	1967-06-02	nas@tam.net243	gg243	2020-11-20	74953222475	78
244	Ivan244	1959-07-20	nas@tam.net244	gg244	2020-02-12	74953222476	49
245	Ivan245	1973-01-26	nas@tam.net245	gg245	2020-05-15	74953222477	77
246	Ivan246	1950-03-01	nas@tam.net246	gg246	2020-07-23	74953222478	8
247	Ivan247	1975-05-25	nas@tam.net247	gg247	2020-07-04	74953222479	6
248	Ivan248	1964-08-01	nas@tam.net248	gg248	2020-12-30	74953222480	33
249	Ivan249	1981-10-01	nas@tam.net249	gg249	2020-11-24	74953222481	49
250	Ivan250	1979-04-26	nas@tam.net250	gg250	2020-11-22	74953222482	65
251	Ivan251	1955-12-15	nas@tam.net251	gg251	2020-10-17	74953222483	89
252	Ivan252	1961-04-06	nas@tam.net252	gg252	2020-01-05	74953222484	32
253	Ivan253	1957-09-25	nas@tam.net253	gg253	2020-06-16	74953222485	96
254	Ivan254	1954-12-01	nas@tam.net254	gg254	2020-07-20	74953222486	96
255	Ivan255	1972-09-06	nas@tam.net255	gg255	2020-07-03	74953222487	85
256	Ivan256	1956-08-15	nas@tam.net256	gg256	2020-10-07	74953222488	35
257	Ivan257	1951-02-09	nas@tam.net257	gg257	2020-03-01	74953222489	24
258	Ivan258	1995-10-27	nas@tam.net258	gg258	2020-04-14	74953222490	97
259	Ivan259	1955-02-09	nas@tam.net259	gg259	2020-06-02	74953222491	17
260	Ivan260	1992-05-18	nas@tam.net260	gg260	2020-12-25	74953222492	43
261	Ivan261	1973-01-13	nas@tam.net261	gg261	2020-11-01	74953222493	10
262	Ivan262	1992-07-15	nas@tam.net262	gg262	2020-03-04	74953222494	99
263	Ivan263	1953-07-03	nas@tam.net263	gg263	2020-05-20	74953222495	56
264	Ivan264	1990-08-28	nas@tam.net264	gg264	2020-03-08	74953222496	97
265	Ivan265	1967-11-14	nas@tam.net265	gg265	2020-07-03	74953222497	25
266	Ivan266	1979-02-26	nas@tam.net266	gg266	2020-01-01	74953222498	85
267	Ivan267	1976-03-07	nas@tam.net267	gg267	2020-07-03	74953222499	58
268	Ivan268	1966-07-01	nas@tam.net268	gg268	2020-01-23	74953222500	0
269	Ivan269	1976-09-22	nas@tam.net269	gg269	2020-06-18	74953222501	34
270	Ivan270	1969-04-12	nas@tam.net270	gg270	2020-02-23	74953222502	9
271	Ivan271	1992-10-27	nas@tam.net271	gg271	2020-03-05	74953222503	28
272	Ivan272	1977-04-03	nas@tam.net272	gg272	2020-04-03	74953222504	22
273	Ivan273	1980-05-24	nas@tam.net273	gg273	2020-06-30	74953222505	15
274	Ivan274	1965-03-08	nas@tam.net274	gg274	2020-12-04	74953222506	17
275	Ivan275	1968-07-31	nas@tam.net275	gg275	2020-08-28	74953222507	56
276	Ivan276	1988-02-13	nas@tam.net276	gg276	2020-08-24	74953222508	17
277	Ivan277	1953-08-29	nas@tam.net277	gg277	2020-10-31	74953222509	8
278	Ivan278	1990-03-14	nas@tam.net278	gg278	2020-08-20	74953222510	11
279	Ivan279	1980-06-06	nas@tam.net279	gg279	2020-03-18	74953222511	4
280	Ivan280	1959-12-26	nas@tam.net280	gg280	2020-03-03	74953222512	62
281	Ivan281	1980-09-11	nas@tam.net281	gg281	2020-07-06	74953222513	56
282	Ivan282	1982-01-10	nas@tam.net282	gg282	2020-08-20	74953222514	42
283	Ivan283	1975-03-24	nas@tam.net283	gg283	2020-11-03	74953222515	12
284	Ivan284	1992-08-20	nas@tam.net284	gg284	2020-02-27	74953222516	82
285	Ivan285	1968-12-03	nas@tam.net285	gg285	2020-07-27	74953222517	57
286	Ivan286	1957-10-28	nas@tam.net286	gg286	2020-10-15	74953222518	64
287	Ivan287	1952-12-12	nas@tam.net287	gg287	2020-12-29	74953222519	25
288	Ivan288	1962-10-26	nas@tam.net288	gg288	2020-11-20	74953222520	29
289	Ivan289	1966-05-15	nas@tam.net289	gg289	2020-12-03	74953222521	43
290	Ivan290	1953-09-26	nas@tam.net290	gg290	2020-11-13	74953222522	98
291	Ivan291	1980-12-25	nas@tam.net291	gg291	2020-11-14	74953222523	84
292	Ivan292	1959-02-21	nas@tam.net292	gg292	2020-03-11	74953222524	35
293	Ivan293	1952-01-17	nas@tam.net293	gg293	2020-01-13	74953222525	6
294	Ivan294	1974-02-20	nas@tam.net294	gg294	2020-01-06	74953222526	28
295	Ivan295	1985-05-18	nas@tam.net295	gg295	2020-03-09	74953222527	17
296	Ivan296	1971-10-28	nas@tam.net296	gg296	2020-06-27	74953222528	99
297	Ivan297	1953-11-14	nas@tam.net297	gg297	2020-06-20	74953222529	96
298	Ivan298	1982-01-27	nas@tam.net298	gg298	2020-12-31	74953222530	55
299	Ivan299	1997-04-14	nas@tam.net299	gg299	2020-04-01	74953222531	92
300	Ivan300	1972-04-11	nas@tam.net300	gg300	2020-11-25	74953222532	45
301	Ivan301	1959-09-21	nas@tam.net301	gg301	2020-10-15	74953222533	5
302	Ivan302	1960-06-08	nas@tam.net302	gg302	2020-02-16	74953222534	58
303	Ivan303	1984-08-30	nas@tam.net303	gg303	2020-02-27	74953222535	29
304	Ivan304	1995-07-08	nas@tam.net304	gg304	2020-08-06	74953222536	0
305	Ivan305	1951-12-15	nas@tam.net305	gg305	2020-10-03	74953222537	7
306	Ivan306	1951-01-01	nas@tam.net306	gg306	2020-06-15	74953222538	56
307	Ivan307	1966-07-19	nas@tam.net307	gg307	2020-01-28	74953222539	59
308	Ivan308	1986-08-02	nas@tam.net308	gg308	2020-03-07	74953222540	92
309	Ivan309	1984-01-22	nas@tam.net309	gg309	2020-01-31	74953222541	10
310	Ivan310	1978-10-28	nas@tam.net310	gg310	2020-05-07	74953222542	95
311	Ivan311	1951-11-14	nas@tam.net311	gg311	2020-09-28	74953222543	60
312	Ivan312	1981-09-24	nas@tam.net312	gg312	2020-04-17	74953222544	84
313	Ivan313	1991-07-08	nas@tam.net313	gg313	2020-09-06	74953222545	61
314	Ivan314	1976-05-11	nas@tam.net314	gg314	2020-11-14	74953222546	31
315	Ivan315	1950-02-03	nas@tam.net315	gg315	2020-07-24	74953222547	75
316	Ivan316	1975-07-18	nas@tam.net316	gg316	2020-09-18	74953222548	35
317	Ivan317	1961-02-03	nas@tam.net317	gg317	2020-06-20	74953222549	34
318	Ivan318	1982-09-14	nas@tam.net318	gg318	2020-03-02	74953222550	89
319	Ivan319	1970-05-16	nas@tam.net319	gg319	2020-05-12	74953222551	3
320	Ivan320	1988-05-28	nas@tam.net320	gg320	2020-11-13	74953222552	9
321	Ivan321	1976-09-09	nas@tam.net321	gg321	2020-03-03	74953222553	61
322	Ivan322	1969-09-29	nas@tam.net322	gg322	2020-01-29	74953222554	95
323	Ivan323	1970-09-09	nas@tam.net323	gg323	2020-04-17	74953222555	10
324	Ivan324	1952-07-07	nas@tam.net324	gg324	2020-07-18	74953222556	96
325	Ivan325	1993-12-01	nas@tam.net325	gg325	2020-10-11	74953222557	17
326	Ivan326	1977-06-12	nas@tam.net326	gg326	2020-08-11	74953222558	75
327	Ivan327	1960-03-13	nas@tam.net327	gg327	2020-02-22	74953222559	39
328	Ivan328	1983-08-28	nas@tam.net328	gg328	2020-12-11	74953222560	27
329	Ivan329	1987-07-12	nas@tam.net329	gg329	2020-06-26	74953222561	21
330	Ivan330	1992-07-15	nas@tam.net330	gg330	2020-03-17	74953222562	84
331	Ivan331	1988-04-24	nas@tam.net331	gg331	2020-11-19	74953222563	72
332	Ivan332	1959-12-12	nas@tam.net332	gg332	2020-06-19	74953222564	53
333	Ivan333	1952-03-15	nas@tam.net333	gg333	2020-07-09	74953222565	53
334	Ivan334	1961-06-07	nas@tam.net334	gg334	2020-01-13	74953222566	82
335	Ivan335	1962-04-03	nas@tam.net335	gg335	2020-11-02	74953222567	59
336	Ivan336	1958-06-12	nas@tam.net336	gg336	2020-05-28	74953222568	44
337	Ivan337	1953-12-06	nas@tam.net337	gg337	2020-05-06	74953222569	88
338	Ivan338	1966-03-30	nas@tam.net338	gg338	2020-07-30	74953222570	24
339	Ivan339	1959-03-19	nas@tam.net339	gg339	2020-01-18	74953222571	100
340	Ivan340	1960-11-02	nas@tam.net340	gg340	2020-10-21	74953222572	84
341	Ivan341	1988-02-17	nas@tam.net341	gg341	2020-09-01	74953222573	34
342	Ivan342	1982-07-02	nas@tam.net342	gg342	2020-10-16	74953222574	1
343	Ivan343	1970-01-10	nas@tam.net343	gg343	2020-04-26	74953222575	88
344	Ivan344	1979-08-21	nas@tam.net344	gg344	2020-07-11	74953222576	69
345	Ivan345	1977-05-26	nas@tam.net345	gg345	2020-08-09	74953222577	5
346	Ivan346	1957-05-12	nas@tam.net346	gg346	2020-05-26	74953222578	84
347	Ivan347	1987-09-15	nas@tam.net347	gg347	2020-12-30	74953222579	24
348	Ivan348	1950-05-16	nas@tam.net348	gg348	2020-07-21	74953222580	29
349	Ivan349	1958-07-04	nas@tam.net349	gg349	2020-10-13	74953222581	77
350	Ivan350	1990-03-03	nas@tam.net350	gg350	2020-06-21	74953222582	2
351	Ivan351	1957-03-18	nas@tam.net351	gg351	2020-03-10	74953222583	78
352	Ivan352	1968-06-30	nas@tam.net352	gg352	2020-06-12	74953222584	69
353	Ivan353	1990-05-16	nas@tam.net353	gg353	2020-11-10	74953222585	3
354	Ivan354	1950-11-23	nas@tam.net354	gg354	2020-05-27	74953222586	37
355	Ivan355	1993-06-11	nas@tam.net355	gg355	2020-05-10	74953222587	70
356	Ivan356	1960-02-07	nas@tam.net356	gg356	2020-05-14	74953222588	52
357	Ivan357	1956-07-01	nas@tam.net357	gg357	2020-12-13	74953222589	31
358	Ivan358	1976-05-08	nas@tam.net358	gg358	2020-05-05	74953222590	11
359	Ivan359	1954-09-06	nas@tam.net359	gg359	2020-11-27	74953222591	46
360	Ivan360	1952-11-10	nas@tam.net360	gg360	2020-03-01	74953222592	97
361	Ivan361	1983-05-17	nas@tam.net361	gg361	2020-04-24	74953222593	34
362	Ivan362	1997-08-12	nas@tam.net362	gg362	2020-12-18	74953222594	45
363	Ivan363	1966-03-31	nas@tam.net363	gg363	2020-05-02	74953222595	68
364	Ivan364	1971-05-23	nas@tam.net364	gg364	2020-02-14	74953222596	55
365	Ivan365	1951-08-22	nas@tam.net365	gg365	2020-05-25	74953222597	48
366	Ivan366	1997-09-09	nas@tam.net366	gg366	2020-11-01	74953222598	75
367	Ivan367	1989-07-09	nas@tam.net367	gg367	2020-01-05	74953222599	51
368	Ivan368	1994-10-28	nas@tam.net368	gg368	2020-11-16	74953222600	72
369	Ivan369	1979-05-08	nas@tam.net369	gg369	2020-08-13	74953222601	70
370	Ivan370	1984-03-12	nas@tam.net370	gg370	2020-09-26	74953222602	99
371	Ivan371	1996-11-09	nas@tam.net371	gg371	2020-03-20	74953222603	43
372	Ivan372	1971-03-16	nas@tam.net372	gg372	2020-03-27	74953222604	77
373	Ivan373	1971-09-11	nas@tam.net373	gg373	2020-04-22	74953222605	51
374	Ivan374	1964-09-01	nas@tam.net374	gg374	2020-07-20	74953222606	91
375	Ivan375	1962-10-02	nas@tam.net375	gg375	2020-03-22	74953222607	58
376	Ivan376	1989-09-13	nas@tam.net376	gg376	2020-05-04	74953222608	36
377	Ivan377	1992-05-29	nas@tam.net377	gg377	2020-01-21	74953222609	43
378	Ivan378	1962-02-16	nas@tam.net378	gg378	2020-10-02	74953222610	53
379	Ivan379	1959-05-06	nas@tam.net379	gg379	2020-12-31	74953222611	85
380	Ivan380	1979-06-26	nas@tam.net380	gg380	2020-10-03	74953222612	48
381	Ivan381	1954-01-06	nas@tam.net381	gg381	2020-06-18	74953222613	82
382	Ivan382	1953-02-24	nas@tam.net382	gg382	2020-03-17	74953222614	69
383	Ivan383	1994-08-07	nas@tam.net383	gg383	2020-11-30	74953222615	65
384	Ivan384	1954-10-18	nas@tam.net384	gg384	2020-02-01	74953222616	33
385	Ivan385	1971-04-19	nas@tam.net385	gg385	2020-03-30	74953222617	7
386	Ivan386	1956-04-29	nas@tam.net386	gg386	2020-02-14	74953222618	85
387	Ivan387	1979-09-27	nas@tam.net387	gg387	2020-10-27	74953222619	65
388	Ivan388	1956-12-20	nas@tam.net388	gg388	2020-09-12	74953222620	56
389	Ivan389	1976-07-19	nas@tam.net389	gg389	2020-05-26	74953222621	20
390	Ivan390	1962-08-09	nas@tam.net390	gg390	2020-01-12	74953222622	73
391	Ivan391	1977-06-16	nas@tam.net391	gg391	2020-09-12	74953222623	92
392	Ivan392	1989-03-27	nas@tam.net392	gg392	2020-01-03	74953222624	88
393	Ivan393	1993-12-21	nas@tam.net393	gg393	2020-12-21	74953222625	32
394	Ivan394	1978-06-01	nas@tam.net394	gg394	2020-10-07	74953222626	21
395	Ivan395	1994-12-16	nas@tam.net395	gg395	2020-04-21	74953222627	69
396	Ivan396	1999-01-23	nas@tam.net396	gg396	2020-07-22	74953222628	75
397	Ivan397	1984-05-23	nas@tam.net397	gg397	2020-12-20	74953222629	56
398	Ivan398	1957-02-11	nas@tam.net398	gg398	2020-11-23	74953222630	28
399	Ivan399	1956-01-30	nas@tam.net399	gg399	2020-01-13	74953222631	19
400	Ivan400	1962-12-24	nas@tam.net400	gg400	2020-10-03	74953222632	19
401	Ivan401	1989-06-16	nas@tam.net401	gg401	2020-08-22	74953222633	11
402	Ivan402	1971-05-03	nas@tam.net402	gg402	2020-01-19	74953222634	13
403	Ivan403	1987-02-04	nas@tam.net403	gg403	2020-11-10	74953222635	18
404	Ivan404	1972-08-15	nas@tam.net404	gg404	2020-03-13	74953222636	63
405	Ivan405	1994-02-18	nas@tam.net405	gg405	2020-03-24	74953222637	60
406	Ivan406	1984-05-24	nas@tam.net406	gg406	2020-07-16	74953222638	67
407	Ivan407	1973-03-30	nas@tam.net407	gg407	2020-06-25	74953222639	69
408	Ivan408	1978-05-22	nas@tam.net408	gg408	2020-05-23	74953222640	32
409	Ivan409	1961-02-27	nas@tam.net409	gg409	2020-06-05	74953222641	51
410	Ivan410	1980-01-19	nas@tam.net410	gg410	2020-02-01	74953222642	8
411	Ivan411	1953-03-04	nas@tam.net411	gg411	2020-08-11	74953222643	11
412	Ivan412	1995-09-14	nas@tam.net412	gg412	2020-08-23	74953222644	95
413	Ivan413	1963-04-28	nas@tam.net413	gg413	2020-09-17	74953222645	34
414	Ivan414	1956-06-04	nas@tam.net414	gg414	2020-08-28	74953222646	6
415	Ivan415	1989-07-24	nas@tam.net415	gg415	2020-05-20	74953222647	10
416	Ivan416	1956-09-02	nas@tam.net416	gg416	2020-07-20	74953222648	5
417	Ivan417	1953-10-05	nas@tam.net417	gg417	2020-03-24	74953222649	44
418	Ivan418	1958-10-08	nas@tam.net418	gg418	2020-09-04	74953222650	30
419	Ivan419	1954-01-02	nas@tam.net419	gg419	2020-06-06	74953222651	23
420	Ivan420	1995-12-22	nas@tam.net420	gg420	2020-03-17	74953222652	99
421	Ivan421	1969-01-06	nas@tam.net421	gg421	2020-05-12	74953222653	55
422	Ivan422	1963-06-08	nas@tam.net422	gg422	2020-10-20	74953222654	6
423	Ivan423	1956-11-03	nas@tam.net423	gg423	2020-05-08	74953222655	12
424	Ivan424	1994-07-22	nas@tam.net424	gg424	2020-04-15	74953222656	7
425	Ivan425	1979-04-02	nas@tam.net425	gg425	2020-10-21	74953222657	8
426	Ivan426	1989-04-14	nas@tam.net426	gg426	2020-07-12	74953222658	80
427	Ivan427	1962-11-14	nas@tam.net427	gg427	2020-08-20	74953222659	87
428	Ivan428	1971-01-10	nas@tam.net428	gg428	2020-04-07	74953222660	22
429	Ivan429	1986-07-30	nas@tam.net429	gg429	2020-10-28	74953222661	77
430	Ivan430	1963-12-30	nas@tam.net430	gg430	2020-10-14	74953222662	72
431	Ivan431	1957-09-24	nas@tam.net431	gg431	2020-11-03	74953222663	54
432	Ivan432	1980-11-04	nas@tam.net432	gg432	2020-10-10	74953222664	99
433	Ivan433	1971-01-20	nas@tam.net433	gg433	2020-10-26	74953222665	41
434	Ivan434	1981-08-11	nas@tam.net434	gg434	2020-10-30	74953222666	32
435	Ivan435	1979-12-26	nas@tam.net435	gg435	2020-11-13	74953222667	27
436	Ivan436	1971-03-14	nas@tam.net436	gg436	2020-05-09	74953222668	82
437	Ivan437	1990-03-07	nas@tam.net437	gg437	2020-10-29	74953222669	52
438	Ivan438	1978-10-22	nas@tam.net438	gg438	2020-12-26	74953222670	90
439	Ivan439	1969-03-17	nas@tam.net439	gg439	2020-12-18	74953222671	26
440	Ivan440	1950-04-23	nas@tam.net440	gg440	2020-08-15	74953222672	7
441	Ivan441	1981-08-03	nas@tam.net441	gg441	2020-11-22	74953222673	8
442	Ivan442	1953-09-25	nas@tam.net442	gg442	2020-10-02	74953222674	8
443	Ivan443	1957-09-09	nas@tam.net443	gg443	2020-08-16	74953222675	12
444	Ivan444	1984-11-13	nas@tam.net444	gg444	2020-08-20	74953222676	56
445	Ivan445	1975-10-02	nas@tam.net445	gg445	2020-05-02	74953222677	32
446	Ivan446	1997-04-26	nas@tam.net446	gg446	2020-08-17	74953222678	26
447	Ivan447	1970-12-12	nas@tam.net447	gg447	2020-03-26	74953222679	38
448	Ivan448	1978-06-12	nas@tam.net448	gg448	2020-12-18	74953222680	74
449	Ivan449	1995-08-09	nas@tam.net449	gg449	2020-12-21	74953222681	34
450	Ivan450	1986-09-12	nas@tam.net450	gg450	2020-04-29	74953222682	24
451	Ivan451	1976-09-18	nas@tam.net451	gg451	2020-02-19	74953222683	23
452	Ivan452	1952-12-29	nas@tam.net452	gg452	2020-02-10	74953222684	16
453	Ivan453	1989-01-10	nas@tam.net453	gg453	2020-05-18	74953222685	94
454	Ivan454	1995-06-17	nas@tam.net454	gg454	2020-06-21	74953222686	69
455	Ivan455	1996-10-22	nas@tam.net455	gg455	2020-04-06	74953222687	37
456	Ivan456	1966-08-09	nas@tam.net456	gg456	2020-07-17	74953222688	51
457	Ivan457	1958-03-26	nas@tam.net457	gg457	2020-05-31	74953222689	37
458	Ivan458	1973-05-24	nas@tam.net458	gg458	2020-08-24	74953222690	34
459	Ivan459	1970-03-12	nas@tam.net459	gg459	2020-04-01	74953222691	62
460	Ivan460	1996-05-23	nas@tam.net460	gg460	2020-05-17	74953222692	44
461	Ivan461	1950-03-10	nas@tam.net461	gg461	2020-04-10	74953222693	32
462	Ivan462	1961-11-28	nas@tam.net462	gg462	2020-09-20	74953222694	12
463	Ivan463	1987-10-15	nas@tam.net463	gg463	2020-12-11	74953222695	83
464	Ivan464	1991-10-11	nas@tam.net464	gg464	2020-08-11	74953222696	82
465	Ivan465	1986-05-23	nas@tam.net465	gg465	2020-01-20	74953222697	39
466	Ivan466	1966-04-08	nas@tam.net466	gg466	2020-11-11	74953222698	30
467	Ivan467	1971-03-14	nas@tam.net467	gg467	2020-10-29	74953222699	90
468	Ivan468	1981-08-06	nas@tam.net468	gg468	2020-06-16	74953222700	99
469	Ivan469	1962-03-17	nas@tam.net469	gg469	2020-03-20	74953222701	27
470	Ivan470	1980-11-17	nas@tam.net470	gg470	2020-01-21	74953222702	61
471	Ivan471	1953-07-17	nas@tam.net471	gg471	2020-03-03	74953222703	91
472	Ivan472	1953-11-19	nas@tam.net472	gg472	2020-12-08	74953222704	64
473	Ivan473	1967-03-25	nas@tam.net473	gg473	2020-04-04	74953222705	44
474	Ivan474	1957-01-05	nas@tam.net474	gg474	2020-11-23	74953222706	83
475	Ivan475	1965-06-23	nas@tam.net475	gg475	2020-02-27	74953222707	13
476	Ivan476	1954-01-01	nas@tam.net476	gg476	2020-04-21	74953222708	95
477	Ivan477	1996-12-08	nas@tam.net477	gg477	2020-01-07	74953222709	54
478	Ivan478	1956-04-25	nas@tam.net478	gg478	2020-07-04	74953222710	70
479	Ivan479	1953-04-03	nas@tam.net479	gg479	2020-11-09	74953222711	23
480	Ivan480	1992-05-15	nas@tam.net480	gg480	2020-11-26	74953222712	26
481	Ivan481	1988-01-29	nas@tam.net481	gg481	2020-09-30	74953222713	61
482	Ivan482	1953-01-05	nas@tam.net482	gg482	2020-05-12	74953222714	1
483	Ivan483	1982-06-03	nas@tam.net483	gg483	2020-03-29	74953222715	70
484	Ivan484	1987-01-02	nas@tam.net484	gg484	2020-09-17	74953222716	76
485	Ivan485	1951-10-12	nas@tam.net485	gg485	2020-10-07	74953222717	85
486	Ivan486	1980-02-20	nas@tam.net486	gg486	2020-09-18	74953222718	67
487	Ivan487	1974-11-04	nas@tam.net487	gg487	2020-06-19	74953222719	77
488	Ivan488	1981-09-11	nas@tam.net488	gg488	2020-04-05	74953222720	71
489	Ivan489	1983-02-20	nas@tam.net489	gg489	2020-06-19	74953222721	55
490	Ivan490	1986-05-12	nas@tam.net490	gg490	2020-08-05	74953222722	7
491	Ivan491	1968-10-23	nas@tam.net491	gg491	2020-01-04	74953222723	58
492	Ivan492	1996-08-14	nas@tam.net492	gg492	2020-11-10	74953222724	34
493	Ivan493	1995-10-21	nas@tam.net493	gg493	2020-05-17	74953222725	93
494	Ivan494	1974-03-17	nas@tam.net494	gg494	2020-07-12	74953222726	41
495	Ivan495	1962-03-21	nas@tam.net495	gg495	2020-07-13	74953222727	90
496	Ivan496	1997-08-06	nas@tam.net496	gg496	2020-11-14	74953222728	47
497	Ivan497	1979-12-21	nas@tam.net497	gg497	2020-08-11	74953222729	41
498	Ivan498	1956-10-30	nas@tam.net498	gg498	2020-02-03	74953222730	81
499	Ivan499	1963-04-01	nas@tam.net499	gg499	2020-01-09	74953222731	30
500	Ivan500	1994-06-11	nas@tam.net500	gg500	2020-09-22	74953222732	100
501	Ivan501	1999-12-22	nas@tam.net501	gg501	2020-10-23	74953222733	8
502	Ivan502	1954-09-14	nas@tam.net502	gg502	2020-11-12	74953222734	0
503	Ivan503	1959-07-15	nas@tam.net503	gg503	2020-07-22	74953222735	85
504	Ivan504	1987-09-20	nas@tam.net504	gg504	2020-06-24	74953222736	33
505	Ivan505	1953-06-04	nas@tam.net505	gg505	2020-11-20	74953222737	75
506	Ivan506	1981-10-09	nas@tam.net506	gg506	2020-06-13	74953222738	81
507	Ivan507	1966-03-30	nas@tam.net507	gg507	2020-01-31	74953222739	54
508	Ivan508	1971-12-03	nas@tam.net508	gg508	2020-02-28	74953222740	41
509	Ivan509	1975-07-19	nas@tam.net509	gg509	2020-11-10	74953222741	93
510	Ivan510	1976-06-23	nas@tam.net510	gg510	2020-04-10	74953222742	8
511	Ivan511	1976-07-04	nas@tam.net511	gg511	2020-05-28	74953222743	18
512	Ivan512	1956-07-13	nas@tam.net512	gg512	2020-01-05	74953222744	40
513	Ivan513	1975-03-03	nas@tam.net513	gg513	2020-09-07	74953222745	42
514	Ivan514	1954-02-28	nas@tam.net514	gg514	2020-10-03	74953222746	33
515	Ivan515	1981-08-15	nas@tam.net515	gg515	2020-11-17	74953222747	2
516	Ivan516	1966-08-03	nas@tam.net516	gg516	2020-02-13	74953222748	29
517	Ivan517	1998-08-30	nas@tam.net517	gg517	2020-11-28	74953222749	68
518	Ivan518	1962-12-19	nas@tam.net518	gg518	2020-10-25	74953222750	7
519	Ivan519	1950-08-03	nas@tam.net519	gg519	2020-01-10	74953222751	18
520	Ivan520	1990-01-31	nas@tam.net520	gg520	2020-11-20	74953222752	20
521	Ivan521	1976-02-01	nas@tam.net521	gg521	2020-10-21	74953222753	36
522	Ivan522	1987-03-09	nas@tam.net522	gg522	2020-11-12	74953222754	16
523	Ivan523	1992-06-05	nas@tam.net523	gg523	2020-10-17	74953222755	31
524	Ivan524	1952-07-16	nas@tam.net524	gg524	2020-03-06	74953222756	20
525	Ivan525	1954-04-22	nas@tam.net525	gg525	2020-08-30	74953222757	64
526	Ivan526	1951-01-18	nas@tam.net526	gg526	2020-11-12	74953222758	75
527	Ivan527	1974-11-04	nas@tam.net527	gg527	2020-11-04	74953222759	9
528	Ivan528	1978-02-19	nas@tam.net528	gg528	2020-09-03	74953222760	88
529	Ivan529	1951-07-24	nas@tam.net529	gg529	2020-03-01	74953222761	3
530	Ivan530	1980-03-27	nas@tam.net530	gg530	2020-05-03	74953222762	11
531	Ivan531	1958-01-23	nas@tam.net531	gg531	2020-07-27	74953222763	47
532	Ivan532	1975-12-22	nas@tam.net532	gg532	2020-01-10	74953222764	15
533	Ivan533	1982-12-07	nas@tam.net533	gg533	2020-03-11	74953222765	87
534	Ivan534	1989-02-14	nas@tam.net534	gg534	2020-07-08	74953222766	75
535	Ivan535	1956-06-22	nas@tam.net535	gg535	2020-05-03	74953222767	69
536	Ivan536	1969-01-01	nas@tam.net536	gg536	2020-02-04	74953222768	9
537	Ivan537	1990-08-17	nas@tam.net537	gg537	2020-11-21	74953222769	1
538	Ivan538	1997-01-02	nas@tam.net538	gg538	2020-09-26	74953222770	94
539	Ivan539	1952-01-28	nas@tam.net539	gg539	2020-02-26	74953222771	70
540	Ivan540	1962-12-21	nas@tam.net540	gg540	2020-06-06	74953222772	96
541	Ivan541	1991-05-30	nas@tam.net541	gg541	2020-04-12	74953222773	98
542	Ivan542	1998-12-05	nas@tam.net542	gg542	2020-02-19	74953222774	59
543	Ivan543	1979-05-26	nas@tam.net543	gg543	2020-11-27	74953222775	79
544	Ivan544	1971-08-29	nas@tam.net544	gg544	2020-02-28	74953222776	12
545	Ivan545	1993-10-20	nas@tam.net545	gg545	2020-04-18	74953222777	45
546	Ivan546	1999-07-05	nas@tam.net546	gg546	2020-04-18	74953222778	6
547	Ivan547	1962-12-07	nas@tam.net547	gg547	2020-04-02	74953222779	21
548	Ivan548	1953-03-19	nas@tam.net548	gg548	2020-07-11	74953222780	48
549	Ivan549	1970-07-29	nas@tam.net549	gg549	2020-09-21	74953222781	84
550	Ivan550	1961-03-31	nas@tam.net550	gg550	2020-12-04	74953222782	38
551	Ivan551	1968-04-29	nas@tam.net551	gg551	2020-11-07	74953222783	50
552	Ivan552	1952-06-20	nas@tam.net552	gg552	2020-11-19	74953222784	91
553	Ivan553	1982-05-10	nas@tam.net553	gg553	2020-10-05	74953222785	26
554	Ivan554	1987-07-21	nas@tam.net554	gg554	2020-08-26	74953222786	21
555	Ivan555	1991-09-07	nas@tam.net555	gg555	2020-04-17	74953222787	21
556	Ivan556	1992-02-02	nas@tam.net556	gg556	2020-02-02	74953222788	91
557	Ivan557	1975-05-11	nas@tam.net557	gg557	2020-04-10	74953222789	64
558	Ivan558	1979-11-15	nas@tam.net558	gg558	2020-01-25	74953222790	61
559	Ivan559	1959-05-31	nas@tam.net559	gg559	2020-10-02	74953222791	30
560	Ivan560	1968-06-27	nas@tam.net560	gg560	2020-10-19	74953222792	74
561	Ivan561	1976-10-05	nas@tam.net561	gg561	2020-02-23	74953222793	3
562	Ivan562	1996-11-14	nas@tam.net562	gg562	2020-03-17	74953222794	99
563	Ivan563	1966-03-27	nas@tam.net563	gg563	2020-11-13	74953222795	96
564	Ivan564	1957-05-05	nas@tam.net564	gg564	2020-02-04	74953222796	40
565	Ivan565	1982-04-14	nas@tam.net565	gg565	2020-06-23	74953222797	37
566	Ivan566	1985-05-23	nas@tam.net566	gg566	2020-04-15	74953222798	96
567	Ivan567	1963-12-17	nas@tam.net567	gg567	2020-10-01	74953222799	50
568	Ivan568	1955-05-12	nas@tam.net568	gg568	2020-10-20	74953222800	17
569	Ivan569	1988-01-02	nas@tam.net569	gg569	2020-05-28	74953222801	22
570	Ivan570	1991-10-04	nas@tam.net570	gg570	2020-11-28	74953222802	21
571	Ivan571	1997-10-01	nas@tam.net571	gg571	2020-01-23	74953222803	75
572	Ivan572	1953-06-19	nas@tam.net572	gg572	2020-04-07	74953222804	7
573	Ivan573	1952-05-04	nas@tam.net573	gg573	2020-01-01	74953222805	34
574	Ivan574	1990-08-11	nas@tam.net574	gg574	2020-02-06	74953222806	91
575	Ivan575	1996-01-29	nas@tam.net575	gg575	2020-06-15	74953222807	53
576	Ivan576	1975-12-02	nas@tam.net576	gg576	2020-04-27	74953222808	90
577	Ivan577	1957-06-18	nas@tam.net577	gg577	2020-01-12	74953222809	52
578	Ivan578	1950-01-03	nas@tam.net578	gg578	2020-11-24	74953222810	34
579	Ivan579	1972-01-22	nas@tam.net579	gg579	2020-01-12	74953222811	0
580	Ivan580	1997-03-27	nas@tam.net580	gg580	2020-11-06	74953222812	87
581	Ivan581	1959-04-28	nas@tam.net581	gg581	2020-12-01	74953222813	49
582	Ivan582	1990-01-15	nas@tam.net582	gg582	2020-05-08	74953222814	21
583	Ivan583	1993-10-23	nas@tam.net583	gg583	2020-03-01	74953222815	5
584	Ivan584	1955-06-17	nas@tam.net584	gg584	2020-01-21	74953222816	83
585	Ivan585	1953-10-06	nas@tam.net585	gg585	2020-10-18	74953222817	82
586	Ivan586	1964-12-30	nas@tam.net586	gg586	2020-01-18	74953222818	76
587	Ivan587	1984-11-21	nas@tam.net587	gg587	2020-01-08	74953222819	99
588	Ivan588	1953-04-25	nas@tam.net588	gg588	2020-01-01	74953222820	87
589	Ivan589	1987-09-21	nas@tam.net589	gg589	2020-09-24	74953222821	55
590	Ivan590	1952-11-02	nas@tam.net590	gg590	2020-06-05	74953222822	33
591	Ivan591	1983-05-07	nas@tam.net591	gg591	2020-12-03	74953222823	40
592	Ivan592	1981-10-23	nas@tam.net592	gg592	2020-11-26	74953222824	54
593	Ivan593	1977-07-10	nas@tam.net593	gg593	2020-01-21	74953222825	78
594	Ivan594	1985-11-12	nas@tam.net594	gg594	2020-05-19	74953222826	67
595	Ivan595	1988-06-27	nas@tam.net595	gg595	2020-05-04	74953222827	84
596	Ivan596	1955-09-04	nas@tam.net596	gg596	2020-04-27	74953222828	23
597	Ivan597	1993-08-08	nas@tam.net597	gg597	2020-03-03	74953222829	10
598	Ivan598	1968-06-03	nas@tam.net598	gg598	2020-07-19	74953222830	87
599	Ivan599	1954-07-08	nas@tam.net599	gg599	2020-08-22	74953222831	91
600	Ivan600	1988-08-10	nas@tam.net600	gg600	2020-02-22	74953222832	94
601	Ivan601	1958-04-27	nas@tam.net601	gg601	2020-12-30	74953222833	52
602	Ivan602	1970-06-02	nas@tam.net602	gg602	2020-05-14	74953222834	48
603	Ivan603	1972-05-22	nas@tam.net603	gg603	2020-12-20	74953222835	69
604	Ivan604	1971-06-21	nas@tam.net604	gg604	2020-05-19	74953222836	4
605	Ivan605	1988-01-28	nas@tam.net605	gg605	2020-04-09	74953222837	10
606	Ivan606	1959-08-12	nas@tam.net606	gg606	2020-11-12	74953222838	11
607	Ivan607	1980-04-09	nas@tam.net607	gg607	2020-05-20	74953222839	24
608	Ivan608	1970-07-31	nas@tam.net608	gg608	2020-09-11	74953222840	77
609	Ivan609	1958-04-01	nas@tam.net609	gg609	2020-03-31	74953222841	97
610	Ivan610	1976-10-12	nas@tam.net610	gg610	2020-12-10	74953222842	29
611	Ivan611	1967-06-09	nas@tam.net611	gg611	2020-03-19	74953222843	98
612	Ivan612	1968-01-09	nas@tam.net612	gg612	2020-10-21	74953222844	47
613	Ivan613	1987-07-12	nas@tam.net613	gg613	2020-09-20	74953222845	66
614	Ivan614	1951-08-02	nas@tam.net614	gg614	2020-05-16	74953222846	17
615	Ivan615	1978-01-15	nas@tam.net615	gg615	2020-09-11	74953222847	87
616	Ivan616	1999-04-04	nas@tam.net616	gg616	2020-02-03	74953222848	46
617	Ivan617	1986-08-07	nas@tam.net617	gg617	2020-10-15	74953222849	17
618	Ivan618	1993-08-11	nas@tam.net618	gg618	2020-07-26	74953222850	8
619	Ivan619	1983-02-04	nas@tam.net619	gg619	2020-01-24	74953222851	99
620	Ivan620	1960-04-19	nas@tam.net620	gg620	2020-06-22	74953222852	90
621	Ivan621	1971-02-26	nas@tam.net621	gg621	2020-01-28	74953222853	76
622	Ivan622	1974-10-21	nas@tam.net622	gg622	2020-07-30	74953222854	36
623	Ivan623	1997-04-13	nas@tam.net623	gg623	2020-05-15	74953222855	89
624	Ivan624	1988-03-22	nas@tam.net624	gg624	2020-03-18	74953222856	32
625	Ivan625	1964-02-24	nas@tam.net625	gg625	2020-08-04	74953222857	12
626	Ivan626	1954-11-10	nas@tam.net626	gg626	2020-11-17	74953222858	62
627	Ivan627	1979-11-04	nas@tam.net627	gg627	2020-06-26	74953222859	94
628	Ivan628	1998-02-22	nas@tam.net628	gg628	2020-01-22	74953222860	29
629	Ivan629	1976-05-15	nas@tam.net629	gg629	2020-02-17	74953222861	34
630	Ivan630	1970-12-04	nas@tam.net630	gg630	2020-06-17	74953222862	42
631	Ivan631	1969-10-07	nas@tam.net631	gg631	2020-09-05	74953222863	22
632	Ivan632	1983-08-13	nas@tam.net632	gg632	2020-08-03	74953222864	81
633	Ivan633	1966-03-19	nas@tam.net633	gg633	2020-06-15	74953222865	16
634	Ivan634	1965-02-15	nas@tam.net634	gg634	2020-04-08	74953222866	95
635	Ivan635	1999-08-26	nas@tam.net635	gg635	2020-10-18	74953222867	38
636	Ivan636	1955-05-22	nas@tam.net636	gg636	2020-07-23	74953222868	10
637	Ivan637	1952-02-17	nas@tam.net637	gg637	2020-12-04	74953222869	71
638	Ivan638	1971-11-03	nas@tam.net638	gg638	2020-05-18	74953222870	48
639	Ivan639	1955-11-14	nas@tam.net639	gg639	2020-12-15	74953222871	4
640	Ivan640	1972-05-29	nas@tam.net640	gg640	2020-03-20	74953222872	73
641	Ivan641	1958-07-25	nas@tam.net641	gg641	2020-05-17	74953222873	80
642	Ivan642	1979-08-09	nas@tam.net642	gg642	2020-08-01	74953222874	77
643	Ivan643	1986-01-04	nas@tam.net643	gg643	2020-10-07	74953222875	17
644	Ivan644	1997-03-03	nas@tam.net644	gg644	2020-04-04	74953222876	87
645	Ivan645	1961-03-20	nas@tam.net645	gg645	2020-10-02	74953222877	69
646	Ivan646	1953-10-23	nas@tam.net646	gg646	2020-07-14	74953222878	46
647	Ivan647	1966-06-08	nas@tam.net647	gg647	2020-05-13	74953222879	37
648	Ivan648	1976-11-11	nas@tam.net648	gg648	2020-08-01	74953222880	77
649	Ivan649	1994-01-07	nas@tam.net649	gg649	2020-11-05	74953222881	46
650	Ivan650	1957-04-16	nas@tam.net650	gg650	2020-08-01	74953222882	51
651	Ivan651	1950-07-09	nas@tam.net651	gg651	2020-09-13	74953222883	44
652	Ivan652	1982-08-26	nas@tam.net652	gg652	2020-04-05	74953222884	31
653	Ivan653	1973-12-22	nas@tam.net653	gg653	2020-01-07	74953222885	38
654	Ivan654	1983-01-25	nas@tam.net654	gg654	2020-09-24	74953222886	78
655	Ivan655	1979-08-23	nas@tam.net655	gg655	2020-04-20	74953222887	2
656	Ivan656	1997-05-13	nas@tam.net656	gg656	2020-04-25	74953222888	7
657	Ivan657	1950-11-08	nas@tam.net657	gg657	2020-01-31	74953222889	44
658	Ivan658	1987-06-05	nas@tam.net658	gg658	2020-06-06	74953222890	73
659	Ivan659	1987-04-25	nas@tam.net659	gg659	2020-07-16	74953222891	89
660	Ivan660	1962-06-14	nas@tam.net660	gg660	2020-09-24	74953222892	69
661	Ivan661	1972-08-09	nas@tam.net661	gg661	2020-01-01	74953222893	34
662	Ivan662	1985-01-31	nas@tam.net662	gg662	2020-04-20	74953222894	24
663	Ivan663	1998-05-23	nas@tam.net663	gg663	2020-06-25	74953222895	96
664	Ivan664	1963-06-02	nas@tam.net664	gg664	2020-11-03	74953222896	56
665	Ivan665	1981-07-21	nas@tam.net665	gg665	2020-08-27	74953222897	22
666	Ivan666	1990-06-14	nas@tam.net666	gg666	2020-03-24	74953222898	25
667	Ivan667	1961-03-22	nas@tam.net667	gg667	2020-07-11	74953222899	81
668	Ivan668	1979-12-23	nas@tam.net668	gg668	2020-06-26	74953222900	58
669	Ivan669	1989-11-30	nas@tam.net669	gg669	2020-11-26	74953222901	10
670	Ivan670	1998-02-28	nas@tam.net670	gg670	2020-07-03	74953222902	81
671	Ivan671	1988-02-13	nas@tam.net671	gg671	2020-06-29	74953222903	24
672	Ivan672	1990-01-07	nas@tam.net672	gg672	2020-04-19	74953222904	80
673	Ivan673	1965-07-26	nas@tam.net673	gg673	2020-11-26	74953222905	77
674	Ivan674	1959-12-26	nas@tam.net674	gg674	2020-01-25	74953222906	55
675	Ivan675	1967-06-19	nas@tam.net675	gg675	2020-12-01	74953222907	19
676	Ivan676	1993-07-06	nas@tam.net676	gg676	2020-09-04	74953222908	45
677	Ivan677	1998-04-07	nas@tam.net677	gg677	2020-04-15	74953222909	16
678	Ivan678	1951-08-24	nas@tam.net678	gg678	2020-11-24	74953222910	38
679	Ivan679	1984-05-16	nas@tam.net679	gg679	2020-09-06	74953222911	10
680	Ivan680	1983-12-17	nas@tam.net680	gg680	2020-09-23	74953222912	77
681	Ivan681	1971-12-13	nas@tam.net681	gg681	2020-12-01	74953222913	68
682	Ivan682	1994-08-27	nas@tam.net682	gg682	2020-07-22	74953222914	35
683	Ivan683	1979-01-24	nas@tam.net683	gg683	2020-08-27	74953222915	18
684	Ivan684	1961-06-28	nas@tam.net684	gg684	2020-02-23	74953222916	47
685	Ivan685	1993-01-06	nas@tam.net685	gg685	2020-05-11	74953222917	91
686	Ivan686	1998-07-27	nas@tam.net686	gg686	2020-02-25	74953222918	21
687	Ivan687	1958-05-31	nas@tam.net687	gg687	2020-03-22	74953222919	7
688	Ivan688	1981-05-31	nas@tam.net688	gg688	2020-07-24	74953222920	70
689	Ivan689	1962-04-18	nas@tam.net689	gg689	2020-09-08	74953222921	21
690	Ivan690	1962-04-29	nas@tam.net690	gg690	2020-12-16	74953222922	38
691	Ivan691	1984-07-13	nas@tam.net691	gg691	2020-10-26	74953222923	56
692	Ivan692	1980-04-10	nas@tam.net692	gg692	2020-11-08	74953222924	78
693	Ivan693	1952-07-16	nas@tam.net693	gg693	2020-04-06	74953222925	82
694	Ivan694	1998-03-09	nas@tam.net694	gg694	2020-02-20	74953222926	33
695	Ivan695	1954-10-26	nas@tam.net695	gg695	2020-03-01	74953222927	11
696	Ivan696	1966-08-12	nas@tam.net696	gg696	2020-07-22	74953222928	96
697	Ivan697	1954-03-01	nas@tam.net697	gg697	2020-10-23	74953222929	73
698	Ivan698	1987-04-08	nas@tam.net698	gg698	2020-12-05	74953222930	52
699	Ivan699	1958-02-09	nas@tam.net699	gg699	2020-08-16	74953222931	58
700	Ivan700	1975-08-10	nas@tam.net700	gg700	2020-02-23	74953222932	48
701	Ivan701	1965-02-24	nas@tam.net701	gg701	2020-08-27	74953222933	21
702	Ivan702	1963-01-19	nas@tam.net702	gg702	2020-09-22	74953222934	28
703	Ivan703	1974-04-03	nas@tam.net703	gg703	2020-05-04	74953222935	93
704	Ivan704	1961-11-10	nas@tam.net704	gg704	2020-06-21	74953222936	44
705	Ivan705	1991-01-04	nas@tam.net705	gg705	2020-09-24	74953222937	95
706	Ivan706	1956-03-17	nas@tam.net706	gg706	2021-01-01	74953222938	61
707	Ivan707	1961-09-19	nas@tam.net707	gg707	2020-08-05	74953222939	80
708	Ivan708	1982-05-05	nas@tam.net708	gg708	2020-08-09	74953222940	52
709	Ivan709	1966-09-08	nas@tam.net709	gg709	2020-03-16	74953222941	24
710	Ivan710	1999-05-13	nas@tam.net710	gg710	2020-03-15	74953222942	57
711	Ivan711	1960-03-27	nas@tam.net711	gg711	2020-10-24	74953222943	85
712	Ivan712	1973-02-23	nas@tam.net712	gg712	2020-11-08	74953222944	28
713	Ivan713	1953-09-02	nas@tam.net713	gg713	2020-08-14	74953222945	25
714	Ivan714	1963-10-12	nas@tam.net714	gg714	2020-10-15	74953222946	55
715	Ivan715	1960-12-27	nas@tam.net715	gg715	2020-10-22	74953222947	84
716	Ivan716	1976-10-27	nas@tam.net716	gg716	2020-03-23	74953222948	39
717	Ivan717	1961-03-24	nas@tam.net717	gg717	2020-06-23	74953222949	100
718	Ivan718	1952-09-22	nas@tam.net718	gg718	2020-11-06	74953222950	25
719	Ivan719	1951-10-02	nas@tam.net719	gg719	2020-07-12	74953222951	73
720	Ivan720	1981-06-25	nas@tam.net720	gg720	2020-01-29	74953222952	12
721	Ivan721	1967-02-12	nas@tam.net721	gg721	2020-08-28	74953222953	90
722	Ivan722	1963-08-31	nas@tam.net722	gg722	2020-09-28	74953222954	5
723	Ivan723	1957-06-06	nas@tam.net723	gg723	2020-08-19	74953222955	49
724	Ivan724	1973-10-02	nas@tam.net724	gg724	2020-03-17	74953222956	25
725	Ivan725	1976-10-26	nas@tam.net725	gg725	2020-08-23	74953222957	45
726	Ivan726	1972-03-27	nas@tam.net726	gg726	2020-11-11	74953222958	49
727	Ivan727	1954-12-27	nas@tam.net727	gg727	2020-02-17	74953222959	51
728	Ivan728	1999-12-28	nas@tam.net728	gg728	2020-07-27	74953222960	36
729	Ivan729	1983-06-30	nas@tam.net729	gg729	2020-07-03	74953222961	36
730	Ivan730	1976-08-29	nas@tam.net730	gg730	2020-05-13	74953222962	65
731	Ivan731	1959-06-20	nas@tam.net731	gg731	2020-03-30	74953222963	43
732	Ivan732	1967-02-18	nas@tam.net732	gg732	2020-05-26	74953222964	57
733	Ivan733	1980-11-01	nas@tam.net733	gg733	2020-05-06	74953222965	90
734	Ivan734	1950-11-07	nas@tam.net734	gg734	2020-06-02	74953222966	74
735	Ivan735	1971-01-06	nas@tam.net735	gg735	2020-07-15	74953222967	62
736	Ivan736	1962-01-18	nas@tam.net736	gg736	2020-10-03	74953222968	84
737	Ivan737	1959-04-20	nas@tam.net737	gg737	2020-09-07	74953222969	95
738	Ivan738	1983-07-20	nas@tam.net738	gg738	2020-06-23	74953222970	85
739	Ivan739	1960-03-26	nas@tam.net739	gg739	2020-01-01	74953222971	71
740	Ivan740	1956-09-09	nas@tam.net740	gg740	2020-07-27	74953222972	32
741	Ivan741	1964-06-26	nas@tam.net741	gg741	2020-05-19	74953222973	22
742	Ivan742	1972-07-13	nas@tam.net742	gg742	2020-09-19	74953222974	62
743	Ivan743	1988-05-04	nas@tam.net743	gg743	2020-03-09	74953222975	39
744	Ivan744	1953-11-13	nas@tam.net744	gg744	2020-02-20	74953222976	87
745	Ivan745	1979-11-01	nas@tam.net745	gg745	2020-11-25	74953222977	86
746	Ivan746	1984-12-06	nas@tam.net746	gg746	2020-11-23	74953222978	13
747	Ivan747	1993-05-14	nas@tam.net747	gg747	2020-11-12	74953222979	81
748	Ivan748	1979-01-05	nas@tam.net748	gg748	2020-04-05	74953222980	33
749	Ivan749	1959-10-06	nas@tam.net749	gg749	2020-04-20	74953222981	86
750	Ivan750	1967-11-23	nas@tam.net750	gg750	2020-06-23	74953222982	0
751	Ivan751	1984-01-05	nas@tam.net751	gg751	2020-11-16	74953222983	61
752	Ivan752	1970-08-31	nas@tam.net752	gg752	2020-12-07	74953222984	96
753	Ivan753	1965-01-04	nas@tam.net753	gg753	2020-04-22	74953222985	59
754	Ivan754	1974-08-17	nas@tam.net754	gg754	2020-05-10	74953222986	17
755	Ivan755	1974-10-12	nas@tam.net755	gg755	2020-07-21	74953222987	24
756	Ivan756	1960-11-05	nas@tam.net756	gg756	2020-03-26	74953222988	19
757	Ivan757	1952-04-06	nas@tam.net757	gg757	2020-10-01	74953222989	40
758	Ivan758	1975-10-22	nas@tam.net758	gg758	2020-04-16	74953222990	45
759	Ivan759	1964-05-31	nas@tam.net759	gg759	2020-07-18	74953222991	13
760	Ivan760	1952-06-14	nas@tam.net760	gg760	2020-03-08	74953222992	55
761	Ivan761	1989-12-22	nas@tam.net761	gg761	2020-05-21	74953222993	98
762	Ivan762	1953-01-02	nas@tam.net762	gg762	2020-11-26	74953222994	94
763	Ivan763	1980-04-13	nas@tam.net763	gg763	2020-07-04	74953222995	47
764	Ivan764	1966-12-22	nas@tam.net764	gg764	2020-09-28	74953222996	0
765	Ivan765	1981-02-23	nas@tam.net765	gg765	2020-12-22	74953222997	72
766	Ivan766	1952-12-05	nas@tam.net766	gg766	2020-11-30	74953222998	58
767	Ivan767	1956-07-10	nas@tam.net767	gg767	2020-07-18	74953222999	13
768	Ivan768	1953-02-24	nas@tam.net768	gg768	2020-06-26	74953223000	69
769	Ivan769	1998-05-21	nas@tam.net769	gg769	2020-05-26	74953223001	74
770	Ivan770	1980-06-03	nas@tam.net770	gg770	2020-08-16	74953223002	10
771	Ivan771	1983-03-24	nas@tam.net771	gg771	2020-11-12	74953223003	44
772	Ivan772	1974-09-10	nas@tam.net772	gg772	2020-11-01	74953223004	47
773	Ivan773	1992-11-14	nas@tam.net773	gg773	2020-01-13	74953223005	27
774	Ivan774	1987-12-19	nas@tam.net774	gg774	2020-07-02	74953223006	30
775	Ivan775	1964-10-19	nas@tam.net775	gg775	2020-10-05	74953223007	43
776	Ivan776	1981-08-05	nas@tam.net776	gg776	2020-08-11	74953223008	6
777	Ivan777	1985-11-10	nas@tam.net777	gg777	2020-02-08	74953223009	21
778	Ivan778	1975-03-17	nas@tam.net778	gg778	2020-05-07	74953223010	67
779	Ivan779	1979-05-23	nas@tam.net779	gg779	2020-06-26	74953223011	60
780	Ivan780	1964-01-22	nas@tam.net780	gg780	2020-11-27	74953223012	27
781	Ivan781	1987-03-25	nas@tam.net781	gg781	2020-06-03	74953223013	81
782	Ivan782	1950-03-21	nas@tam.net782	gg782	2020-06-25	74953223014	59
783	Ivan783	1989-06-10	nas@tam.net783	gg783	2020-05-27	74953223015	9
784	Ivan784	1974-08-07	nas@tam.net784	gg784	2020-11-21	74953223016	74
785	Ivan785	1960-02-02	nas@tam.net785	gg785	2020-06-05	74953223017	22
786	Ivan786	1968-07-20	nas@tam.net786	gg786	2020-03-04	74953223018	29
787	Ivan787	1977-07-05	nas@tam.net787	gg787	2020-07-20	74953223019	19
788	Ivan788	1960-11-15	nas@tam.net788	gg788	2020-12-06	74953223020	44
789	Ivan789	1964-07-12	nas@tam.net789	gg789	2020-01-12	74953223021	3
790	Ivan790	1991-12-26	nas@tam.net790	gg790	2020-07-10	74953223022	15
791	Ivan791	1994-10-12	nas@tam.net791	gg791	2020-12-26	74953223023	25
792	Ivan792	1955-07-18	nas@tam.net792	gg792	2020-04-23	74953223024	52
793	Ivan793	1980-08-20	nas@tam.net793	gg793	2020-06-01	74953223025	59
794	Ivan794	1990-01-13	nas@tam.net794	gg794	2020-08-29	74953223026	40
795	Ivan795	1995-09-18	nas@tam.net795	gg795	2020-02-08	74953223027	49
796	Ivan796	1982-12-18	nas@tam.net796	gg796	2020-05-27	74953223028	58
797	Ivan797	1992-05-21	nas@tam.net797	gg797	2020-04-05	74953223029	58
798	Ivan798	1975-03-25	nas@tam.net798	gg798	2020-09-24	74953223030	19
799	Ivan799	1985-03-09	nas@tam.net799	gg799	2020-02-25	74953223031	2
800	Ivan800	1962-09-12	nas@tam.net800	gg800	2020-07-02	74953223032	57
801	Ivan801	1970-10-18	nas@tam.net801	gg801	2020-05-02	74953223033	42
802	Ivan802	1973-03-13	nas@tam.net802	gg802	2020-04-21	74953223034	95
803	Ivan803	1964-05-19	nas@tam.net803	gg803	2020-01-15	74953223035	77
804	Ivan804	1970-08-12	nas@tam.net804	gg804	2020-06-19	74953223036	24
805	Ivan805	1993-05-21	nas@tam.net805	gg805	2020-10-27	74953223037	4
806	Ivan806	1994-10-04	nas@tam.net806	gg806	2020-12-02	74953223038	88
807	Ivan807	1961-07-15	nas@tam.net807	gg807	2020-01-10	74953223039	85
808	Ivan808	1991-02-27	nas@tam.net808	gg808	2020-10-05	74953223040	65
809	Ivan809	1976-03-06	nas@tam.net809	gg809	2020-12-02	74953223041	62
810	Ivan810	1972-10-18	nas@tam.net810	gg810	2020-12-23	74953223042	89
811	Ivan811	1984-02-16	nas@tam.net811	gg811	2020-12-15	74953223043	39
812	Ivan812	1968-03-31	nas@tam.net812	gg812	2020-10-27	74953223044	94
813	Ivan813	1978-01-02	nas@tam.net813	gg813	2020-11-10	74953223045	88
814	Ivan814	1965-08-21	nas@tam.net814	gg814	2020-01-29	74953223046	3
815	Ivan815	1976-03-15	nas@tam.net815	gg815	2020-05-20	74953223047	60
816	Ivan816	1958-06-19	nas@tam.net816	gg816	2020-05-29	74953223048	55
817	Ivan817	1963-01-24	nas@tam.net817	gg817	2020-03-08	74953223049	62
818	Ivan818	1978-11-19	nas@tam.net818	gg818	2020-05-10	74953223050	21
819	Ivan819	1983-02-26	nas@tam.net819	gg819	2020-06-12	74953223051	15
820	Ivan820	1976-07-23	nas@tam.net820	gg820	2020-10-22	74953223052	36
821	Ivan821	1953-11-30	nas@tam.net821	gg821	2020-06-22	74953223053	65
822	Ivan822	1952-05-31	nas@tam.net822	gg822	2020-07-26	74953223054	69
823	Ivan823	1967-05-11	nas@tam.net823	gg823	2020-09-14	74953223055	98
824	Ivan824	1991-07-31	nas@tam.net824	gg824	2020-09-23	74953223056	53
825	Ivan825	1991-03-13	nas@tam.net825	gg825	2020-08-27	74953223057	57
826	Ivan826	1983-09-30	nas@tam.net826	gg826	2020-10-06	74953223058	54
827	Ivan827	1977-07-13	nas@tam.net827	gg827	2020-12-18	74953223059	22
828	Ivan828	1965-06-09	nas@tam.net828	gg828	2020-02-07	74953223060	45
829	Ivan829	1974-01-10	nas@tam.net829	gg829	2020-07-09	74953223061	31
830	Ivan830	1953-01-04	nas@tam.net830	gg830	2020-02-15	74953223062	12
831	Ivan831	1972-05-02	nas@tam.net831	gg831	2020-09-24	74953223063	79
832	Ivan832	1956-02-12	nas@tam.net832	gg832	2020-12-13	74953223064	39
833	Ivan833	1989-10-04	nas@tam.net833	gg833	2020-12-06	74953223065	93
834	Ivan834	1982-10-21	nas@tam.net834	gg834	2020-04-13	74953223066	17
835	Ivan835	1952-12-05	nas@tam.net835	gg835	2020-01-20	74953223067	0
836	Ivan836	1980-01-30	nas@tam.net836	gg836	2020-01-06	74953223068	19
837	Ivan837	1993-12-17	nas@tam.net837	gg837	2020-07-23	74953223069	34
838	Ivan838	1983-10-11	nas@tam.net838	gg838	2020-02-16	74953223070	98
839	Ivan839	1989-09-15	nas@tam.net839	gg839	2020-10-10	74953223071	79
840	Ivan840	1999-12-02	nas@tam.net840	gg840	2020-09-06	74953223072	69
841	Ivan841	1985-10-02	nas@tam.net841	gg841	2020-04-28	74953223073	11
842	Ivan842	1962-11-17	nas@tam.net842	gg842	2020-05-31	74953223074	99
843	Ivan843	1981-01-19	nas@tam.net843	gg843	2020-10-11	74953223075	19
844	Ivan844	1961-01-04	nas@tam.net844	gg844	2020-10-31	74953223076	26
845	Ivan845	1984-05-18	nas@tam.net845	gg845	2020-01-12	74953223077	30
846	Ivan846	1977-10-19	nas@tam.net846	gg846	2020-01-10	74953223078	78
847	Ivan847	1988-12-31	nas@tam.net847	gg847	2020-12-12	74953223079	35
848	Ivan848	1993-06-11	nas@tam.net848	gg848	2020-08-20	74953223080	97
849	Ivan849	1991-06-28	nas@tam.net849	gg849	2020-05-06	74953223081	49
850	Ivan850	1955-02-24	nas@tam.net850	gg850	2020-04-23	74953223082	32
851	Ivan851	1965-02-18	nas@tam.net851	gg851	2020-05-15	74953223083	83
852	Ivan852	1998-09-24	nas@tam.net852	gg852	2020-07-23	74953223084	92
853	Ivan853	1999-11-22	nas@tam.net853	gg853	2020-06-19	74953223085	28
854	Ivan854	1998-12-09	nas@tam.net854	gg854	2020-09-16	74953223086	62
855	Ivan855	1959-01-22	nas@tam.net855	gg855	2020-06-26	74953223087	31
856	Ivan856	1959-01-16	nas@tam.net856	gg856	2020-09-21	74953223088	24
857	Ivan857	1960-01-29	nas@tam.net857	gg857	2020-06-20	74953223089	50
858	Ivan858	1989-04-23	nas@tam.net858	gg858	2020-12-26	74953223090	32
859	Ivan859	1970-08-04	nas@tam.net859	gg859	2020-06-27	74953223091	24
860	Ivan860	1999-11-22	nas@tam.net860	gg860	2020-03-06	74953223092	42
861	Ivan861	1991-03-06	nas@tam.net861	gg861	2020-04-09	74953223093	32
862	Ivan862	1971-10-13	nas@tam.net862	gg862	2020-08-18	74953223094	25
863	Ivan863	1983-05-15	nas@tam.net863	gg863	2020-08-22	74953223095	8
864	Ivan864	1970-01-23	nas@tam.net864	gg864	2020-07-18	74953223096	52
865	Ivan865	1994-10-15	nas@tam.net865	gg865	2020-04-10	74953223097	93
866	Ivan866	1985-02-05	nas@tam.net866	gg866	2020-02-24	74953223098	97
867	Ivan867	1963-05-29	nas@tam.net867	gg867	2020-10-01	74953223099	67
868	Ivan868	1974-02-13	nas@tam.net868	gg868	2020-12-22	74953223100	42
869	Ivan869	1959-06-15	nas@tam.net869	gg869	2020-01-30	74953223101	91
870	Ivan870	1968-01-17	nas@tam.net870	gg870	2020-03-16	74953223102	84
871	Ivan871	1962-08-13	nas@tam.net871	gg871	2020-02-28	74953223103	12
872	Ivan872	1970-05-30	nas@tam.net872	gg872	2020-01-18	74953223104	27
873	Ivan873	1981-01-29	nas@tam.net873	gg873	2020-04-02	74953223105	72
874	Ivan874	1978-09-21	nas@tam.net874	gg874	2020-09-05	74953223106	80
875	Ivan875	1965-05-06	nas@tam.net875	gg875	2020-12-27	74953223107	92
876	Ivan876	1974-04-03	nas@tam.net876	gg876	2020-08-09	74953223108	3
877	Ivan877	1965-12-08	nas@tam.net877	gg877	2020-01-02	74953223109	68
878	Ivan878	1979-06-09	nas@tam.net878	gg878	2020-06-22	74953223110	63
879	Ivan879	1972-03-30	nas@tam.net879	gg879	2020-09-27	74953223111	100
880	Ivan880	1995-10-01	nas@tam.net880	gg880	2020-11-16	74953223112	17
881	Ivan881	1959-06-19	nas@tam.net881	gg881	2020-09-21	74953223113	93
882	Ivan882	1976-03-27	nas@tam.net882	gg882	2020-10-04	74953223114	61
883	Ivan883	1988-11-21	nas@tam.net883	gg883	2020-01-31	74953223115	45
884	Ivan884	1972-08-17	nas@tam.net884	gg884	2020-09-04	74953223116	17
885	Ivan885	1996-04-29	nas@tam.net885	gg885	2020-08-05	74953223117	70
886	Ivan886	1991-12-31	nas@tam.net886	gg886	2020-12-08	74953223118	30
887	Ivan887	1950-09-28	nas@tam.net887	gg887	2020-01-20	74953223119	4
888	Ivan888	1997-01-19	nas@tam.net888	gg888	2020-11-26	74953223120	21
889	Ivan889	1982-10-03	nas@tam.net889	gg889	2020-08-23	74953223121	73
890	Ivan890	1995-10-09	nas@tam.net890	gg890	2020-01-02	74953223122	93
891	Ivan891	1965-12-16	nas@tam.net891	gg891	2020-09-23	74953223123	90
892	Ivan892	1963-12-11	nas@tam.net892	gg892	2020-09-20	74953223124	63
893	Ivan893	1992-11-02	nas@tam.net893	gg893	2020-05-18	74953223125	53
894	Ivan894	1964-07-12	nas@tam.net894	gg894	2020-02-09	74953223126	24
895	Ivan895	1968-07-03	nas@tam.net895	gg895	2021-01-01	74953223127	46
896	Ivan896	1990-03-02	nas@tam.net896	gg896	2020-08-13	74953223128	35
897	Ivan897	1962-03-11	nas@tam.net897	gg897	2020-01-15	74953223129	26
898	Ivan898	1964-04-10	nas@tam.net898	gg898	2020-11-23	74953223130	17
899	Ivan899	1989-08-10	nas@tam.net899	gg899	2020-10-10	74953223131	71
900	Ivan900	1959-02-06	nas@tam.net900	gg900	2020-04-23	74953223132	42
901	Ivan901	1990-04-01	nas@tam.net901	gg901	2020-06-16	74953223133	66
902	Ivan902	1974-09-19	nas@tam.net902	gg902	2020-02-22	74953223134	1
903	Ivan903	1979-01-23	nas@tam.net903	gg903	2020-07-29	74953223135	84
904	Ivan904	1974-12-15	nas@tam.net904	gg904	2020-04-29	74953223136	67
905	Ivan905	1986-04-26	nas@tam.net905	gg905	2020-03-08	74953223137	80
906	Ivan906	1989-01-29	nas@tam.net906	gg906	2020-12-30	74953223138	12
907	Ivan907	1994-04-27	nas@tam.net907	gg907	2020-03-25	74953223139	66
908	Ivan908	1982-10-30	nas@tam.net908	gg908	2020-05-03	74953223140	74
909	Ivan909	1974-11-01	nas@tam.net909	gg909	2020-08-04	74953223141	80
910	Ivan910	1965-04-11	nas@tam.net910	gg910	2020-11-24	74953223142	34
911	Ivan911	1996-10-01	nas@tam.net911	gg911	2020-04-11	74953223143	64
912	Ivan912	1950-04-27	nas@tam.net912	gg912	2020-11-08	74953223144	24
913	Ivan913	1971-09-05	nas@tam.net913	gg913	2020-01-14	74953223145	77
914	Ivan914	1997-12-16	nas@tam.net914	gg914	2020-03-16	74953223146	57
915	Ivan915	1998-07-27	nas@tam.net915	gg915	2020-09-14	74953223147	32
916	Ivan916	1956-04-23	nas@tam.net916	gg916	2020-06-14	74953223148	56
917	Ivan917	1976-06-17	nas@tam.net917	gg917	2020-09-20	74953223149	10
918	Ivan918	1963-04-01	nas@tam.net918	gg918	2020-01-29	74953223150	44
919	Ivan919	1973-06-25	nas@tam.net919	gg919	2020-08-28	74953223151	48
920	Ivan920	1970-12-24	nas@tam.net920	gg920	2020-10-29	74953223152	65
921	Ivan921	1990-07-04	nas@tam.net921	gg921	2020-05-23	74953223153	50
922	Ivan922	1964-08-23	nas@tam.net922	gg922	2020-03-18	74953223154	35
923	Ivan923	1972-04-08	nas@tam.net923	gg923	2020-10-13	74953223155	39
924	Ivan924	1973-12-18	nas@tam.net924	gg924	2020-05-31	74953223156	62
925	Ivan925	1965-02-09	nas@tam.net925	gg925	2020-03-03	74953223157	32
926	Ivan926	1968-09-01	nas@tam.net926	gg926	2020-02-29	74953223158	68
927	Ivan927	1967-04-11	nas@tam.net927	gg927	2020-03-29	74953223159	26
928	Ivan928	1977-10-18	nas@tam.net928	gg928	2020-02-27	74953223160	64
929	Ivan929	1992-09-03	nas@tam.net929	gg929	2020-03-03	74953223161	34
930	Ivan930	1965-08-03	nas@tam.net930	gg930	2020-10-13	74953223162	45
931	Ivan931	1956-02-02	nas@tam.net931	gg931	2020-04-29	74953223163	68
932	Ivan932	1965-12-14	nas@tam.net932	gg932	2020-11-25	74953223164	7
933	Ivan933	1960-01-01	nas@tam.net933	gg933	2020-02-09	74953223165	87
934	Ivan934	1981-01-22	nas@tam.net934	gg934	2020-11-20	74953223166	73
935	Ivan935	1970-04-29	nas@tam.net935	gg935	2020-11-28	74953223167	96
936	Ivan936	1995-01-20	nas@tam.net936	gg936	2020-07-25	74953223168	62
937	Ivan937	1993-06-30	nas@tam.net937	gg937	2020-08-15	74953223169	88
938	Ivan938	1995-12-08	nas@tam.net938	gg938	2020-05-15	74953223170	19
939	Ivan939	1993-09-04	nas@tam.net939	gg939	2020-03-07	74953223171	21
940	Ivan940	1981-01-12	nas@tam.net940	gg940	2020-06-04	74953223172	8
941	Ivan941	1987-07-24	nas@tam.net941	gg941	2020-12-06	74953223173	13
942	Ivan942	1957-07-12	nas@tam.net942	gg942	2020-10-02	74953223174	12
943	Ivan943	1974-05-12	nas@tam.net943	gg943	2020-01-27	74953223175	85
944	Ivan944	1983-05-13	nas@tam.net944	gg944	2020-12-14	74953223176	53
945	Ivan945	1964-10-20	nas@tam.net945	gg945	2020-07-30	74953223177	29
946	Ivan946	1978-01-21	nas@tam.net946	gg946	2020-12-30	74953223178	27
947	Ivan947	1957-11-21	nas@tam.net947	gg947	2020-11-28	74953223179	11
948	Ivan948	1994-05-21	nas@tam.net948	gg948	2020-09-11	74953223180	32
949	Ivan949	1951-10-26	nas@tam.net949	gg949	2020-04-28	74953223181	84
950	Ivan950	1972-08-11	nas@tam.net950	gg950	2020-04-08	74953223182	100
951	Ivan951	1968-02-21	nas@tam.net951	gg951	2020-04-25	74953223183	32
952	Ivan952	1998-01-08	nas@tam.net952	gg952	2020-04-10	74953223184	60
953	Ivan953	1967-02-04	nas@tam.net953	gg953	2020-09-23	74953223185	82
954	Ivan954	1991-07-10	nas@tam.net954	gg954	2020-12-14	74953223186	50
955	Ivan955	1955-08-31	nas@tam.net955	gg955	2020-09-22	74953223187	71
956	Ivan956	1964-06-10	nas@tam.net956	gg956	2020-09-30	74953223188	29
957	Ivan957	1954-04-27	nas@tam.net957	gg957	2020-04-28	74953223189	69
958	Ivan958	1994-10-07	nas@tam.net958	gg958	2020-05-30	74953223190	20
959	Ivan959	1989-11-17	nas@tam.net959	gg959	2020-07-25	74953223191	52
960	Ivan960	1995-06-13	nas@tam.net960	gg960	2020-07-25	74953223192	41
961	Ivan961	1986-01-15	nas@tam.net961	gg961	2020-09-25	74953223193	0
962	Ivan962	1960-12-31	nas@tam.net962	gg962	2020-03-26	74953223194	95
963	Ivan963	1956-01-09	nas@tam.net963	gg963	2020-02-02	74953223195	72
964	Ivan964	1955-05-02	nas@tam.net964	gg964	2020-08-08	74953223196	69
965	Ivan965	1970-07-07	nas@tam.net965	gg965	2020-01-31	74953223197	4
966	Ivan966	1959-05-26	nas@tam.net966	gg966	2020-05-13	74953223198	6
967	Ivan967	1995-03-03	nas@tam.net967	gg967	2020-07-12	74953223199	74
968	Ivan968	1986-12-18	nas@tam.net968	gg968	2020-08-07	74953223200	85
969	Ivan969	1994-01-02	nas@tam.net969	gg969	2020-02-13	74953223201	47
970	Ivan970	1962-01-13	nas@tam.net970	gg970	2020-06-10	74953223202	76
971	Ivan971	1959-10-21	nas@tam.net971	gg971	2020-09-10	74953223203	99
972	Ivan972	1953-07-18	nas@tam.net972	gg972	2020-05-15	74953223204	89
973	Ivan973	1991-06-26	nas@tam.net973	gg973	2020-06-07	74953223205	85
974	Ivan974	1966-03-06	nas@tam.net974	gg974	2020-09-18	74953223206	89
975	Ivan975	1973-08-12	nas@tam.net975	gg975	2020-08-05	74953223207	46
976	Ivan976	1983-04-05	nas@tam.net976	gg976	2020-05-08	74953223208	32
977	Ivan977	1998-10-17	nas@tam.net977	gg977	2020-12-10	74953223209	48
978	Ivan978	1960-05-05	nas@tam.net978	gg978	2020-07-22	74953223210	10
979	Ivan979	1984-12-30	nas@tam.net979	gg979	2020-08-08	74953223211	43
980	Ivan980	1966-10-11	nas@tam.net980	gg980	2020-05-05	74953223212	72
981	Ivan981	1952-06-29	nas@tam.net981	gg981	2020-03-13	74953223213	46
982	Ivan982	1971-07-18	nas@tam.net982	gg982	2020-04-07	74953223214	98
983	Ivan983	1990-06-20	nas@tam.net983	gg983	2020-05-18	74953223215	69
984	Ivan984	1950-10-23	nas@tam.net984	gg984	2020-07-09	74953223216	1
985	Ivan985	1986-01-07	nas@tam.net985	gg985	2020-03-07	74953223217	6
986	Ivan986	1969-07-03	nas@tam.net986	gg986	2020-12-16	74953223218	85
987	Ivan987	1988-09-26	nas@tam.net987	gg987	2020-07-27	74953223219	69
988	Ivan988	1968-06-07	nas@tam.net988	gg988	2020-06-20	74953223220	53
989	Ivan989	1996-10-20	nas@tam.net989	gg989	2020-01-04	74953223221	99
990	Ivan990	1980-02-26	nas@tam.net990	gg990	2020-10-08	74953223222	89
991	Ivan991	1985-04-27	nas@tam.net991	gg991	2020-03-06	74953223223	22
992	Ivan992	1993-11-10	nas@tam.net992	gg992	2020-10-25	74953223224	54
993	Ivan993	1991-10-02	nas@tam.net993	gg993	2020-08-09	74953223225	56
994	Ivan994	1991-09-05	nas@tam.net994	gg994	2020-02-27	74953223226	77
995	Ivan995	1984-01-30	nas@tam.net995	gg995	2021-01-01	74953223227	56
996	Ivan996	1969-07-17	nas@tam.net996	gg996	2020-08-25	74953223228	84
997	Ivan997	1952-03-06	nas@tam.net997	gg997	2020-10-29	74953223229	5
998	Ivan998	1985-12-03	nas@tam.net998	gg998	2020-01-18	74953223230	97
999	Ivan999	1968-02-12	nas@tam.net999	gg999	2020-10-12	74953223231	86
1000	Ivan1000	1997-02-06	nas@tam.net1000	gg1000	2020-04-05	74953223232	67
\.


--
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.logs (text, added) FROM stdin;
Remove user a	2021-11-13 20:30:44.714949
Add new order 1001	2021-11-13 20:45:17.12373
Remove order 1001	2021-11-13 20:46:34.737259
Add new order 1001	2021-11-13 21:57:09.818142
Remove order 1001	2021-11-13 21:58:49.584357
\.


--
-- Data for Name: managers; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.managers (manager_id, fio, email, passw, acces_card, contact_phone) FROM stdin;
1	manager1	man@nas.net1	mm1	323564	74993222233
2	manager2	man@nas.net2	mm2	44450	74993222234
3	manager3	man@nas.net3	mm3	44451	74993222235
4	manager4	man@nas.net4	mm4	44452	74993222236
5	manager5	man@nas.net5	mm5	44453	74993222237
6	manager6	man@nas.net6	mm6	44454	74993222238
7	manager7	man@nas.net7	mm7	44455	74993222239
8	manager8	man@nas.net8	mm8	44456	74993222240
9	manager9	man@nas.net9	mm9	44457	74993222241
10	manager10	man@nas.net10	mm10	44458	74993222242
11	manager11	man@nas.net11	mm11	44459	74993222243
12	manager12	man@nas.net12	mm12	44460	74993222244
13	manager13	man@nas.net13	mm13	44461	74993222245
14	manager14	man@nas.net14	mm14	44462	74993222246
15	manager15	man@nas.net15	mm15	44463	74993222247
16	manager16	man@nas.net16	mm16	44464	74993222248
17	manager17	man@nas.net17	mm17	44465	74993222249
18	manager18	man@nas.net18	mm18	44466	74993222250
19	manager19	man@nas.net19	mm19	44467	74993222251
20	manager20	man@nas.net20	mm20	44468	74993222252
21	manager21	man@nas.net21	mm21	44469	74993222253
22	manager22	man@nas.net22	mm22	44470	74993222254
23	manager23	man@nas.net23	mm23	44471	74993222255
24	manager24	man@nas.net24	mm24	44472	74993222256
25	manager25	man@nas.net25	mm25	44473	74993222257
26	manager26	man@nas.net26	mm26	44474	74993222258
27	manager27	man@nas.net27	mm27	44475	74993222259
28	manager28	man@nas.net28	mm28	44476	74993222260
29	manager29	man@nas.net29	mm29	44477	74993222261
30	manager30	man@nas.net30	mm30	44478	74993222262
31	manager31	man@nas.net31	mm31	44479	74993222263
32	manager32	man@nas.net32	mm32	44480	74993222264
33	manager33	man@nas.net33	mm33	44481	74993222265
34	manager34	man@nas.net34	mm34	44482	74993222266
35	manager35	man@nas.net35	mm35	44483	74993222267
36	manager36	man@nas.net36	mm36	44484	74993222268
37	manager37	man@nas.net37	mm37	44485	74993222269
38	manager38	man@nas.net38	mm38	44486	74993222270
39	manager39	man@nas.net39	mm39	44487	74993222271
40	manager40	man@nas.net40	mm40	44488	74993222272
41	manager41	man@nas.net41	mm41	44489	74993222273
42	manager42	man@nas.net42	mm42	44490	74993222274
43	manager43	man@nas.net43	mm43	44491	74993222275
44	manager44	man@nas.net44	mm44	44492	74993222276
45	manager45	man@nas.net45	mm45	44493	74993222277
46	manager46	man@nas.net46	mm46	44494	74993222278
47	manager47	man@nas.net47	mm47	44495	74993222279
48	manager48	man@nas.net48	mm48	44496	74993222280
49	manager49	man@nas.net49	mm49	44497	74993222281
50	manager50	man@nas.net50	mm50	44498	74993222282
51	manager51	man@nas.net51	mm51	44499	74993222283
52	manager52	man@nas.net52	mm52	44500	74993222284
53	manager53	man@nas.net53	mm53	44501	74993222285
54	manager54	man@nas.net54	mm54	44502	74993222286
55	manager55	man@nas.net55	mm55	44503	74993222287
56	manager56	man@nas.net56	mm56	44504	74993222288
57	manager57	man@nas.net57	mm57	44505	74993222289
58	manager58	man@nas.net58	mm58	44506	74993222290
59	manager59	man@nas.net59	mm59	44507	74993222291
60	manager60	man@nas.net60	mm60	44508	74993222292
61	manager61	man@nas.net61	mm61	44509	74993222293
62	manager62	man@nas.net62	mm62	44510	74993222294
63	manager63	man@nas.net63	mm63	44511	74993222295
64	manager64	man@nas.net64	mm64	44512	74993222296
65	manager65	man@nas.net65	mm65	44513	74993222297
66	manager66	man@nas.net66	mm66	44514	74993222298
67	manager67	man@nas.net67	mm67	44515	74993222299
68	manager68	man@nas.net68	mm68	44516	74993222300
69	manager69	man@nas.net69	mm69	44517	74993222301
70	manager70	man@nas.net70	mm70	44518	74993222302
71	manager71	man@nas.net71	mm71	44519	74993222303
72	manager72	man@nas.net72	mm72	44520	74993222304
73	manager73	man@nas.net73	mm73	44521	74993222305
74	manager74	man@nas.net74	mm74	44522	74993222306
75	manager75	man@nas.net75	mm75	44523	74993222307
76	manager76	man@nas.net76	mm76	44524	74993222308
77	manager77	man@nas.net77	mm77	44525	74993222309
78	manager78	man@nas.net78	mm78	44526	74993222310
79	manager79	man@nas.net79	mm79	44527	74993222311
80	manager80	man@nas.net80	mm80	44528	74993222312
81	manager81	man@nas.net81	mm81	44529	74993222313
82	manager82	man@nas.net82	mm82	44530	74993222314
83	manager83	man@nas.net83	mm83	44531	74993222315
84	manager84	man@nas.net84	mm84	44532	74993222316
85	manager85	man@nas.net85	mm85	44533	74993222317
86	manager86	man@nas.net86	mm86	44534	74993222318
87	manager87	man@nas.net87	mm87	44535	74993222319
88	manager88	man@nas.net88	mm88	44536	74993222320
89	manager89	man@nas.net89	mm89	44537	74993222321
90	manager90	man@nas.net90	mm90	44538	74993222322
91	manager91	man@nas.net91	mm91	44539	74993222323
92	manager92	man@nas.net92	mm92	44540	74993222324
93	manager93	man@nas.net93	mm93	44541	74993222325
94	manager94	man@nas.net94	mm94	44542	74993222326
95	manager95	man@nas.net95	mm95	44543	74993222327
96	manager96	man@nas.net96	mm96	44544	74993222328
97	manager97	man@nas.net97	mm97	44545	74993222329
98	manager98	man@nas.net98	mm98	44546	74993222330
99	manager99	man@nas.net99	mm99	44547	74993222331
100	manager100	man@nas.net100	mm100	44548	74993222332
101	manager101	man@nas.net101	mm101	44549	74993222333
102	manager102	man@nas.net102	mm102	44550	74993222334
103	manager103	man@nas.net103	mm103	44551	74993222335
104	manager104	man@nas.net104	mm104	44552	74993222336
105	manager105	man@nas.net105	mm105	44553	74993222337
106	manager106	man@nas.net106	mm106	44554	74993222338
107	manager107	man@nas.net107	mm107	44555	74993222339
108	manager108	man@nas.net108	mm108	44556	74993222340
109	manager109	man@nas.net109	mm109	44557	74993222341
110	manager110	man@nas.net110	mm110	44558	74993222342
111	manager111	man@nas.net111	mm111	44559	74993222343
112	manager112	man@nas.net112	mm112	44560	74993222344
113	manager113	man@nas.net113	mm113	44561	74993222345
114	manager114	man@nas.net114	mm114	44562	74993222346
115	manager115	man@nas.net115	mm115	44563	74993222347
116	manager116	man@nas.net116	mm116	44564	74993222348
117	manager117	man@nas.net117	mm117	44565	74993222349
118	manager118	man@nas.net118	mm118	44566	74993222350
119	manager119	man@nas.net119	mm119	44567	74993222351
120	manager120	man@nas.net120	mm120	44568	74993222352
121	manager121	man@nas.net121	mm121	44569	74993222353
122	manager122	man@nas.net122	mm122	44570	74993222354
123	manager123	man@nas.net123	mm123	44571	74993222355
124	manager124	man@nas.net124	mm124	44572	74993222356
125	manager125	man@nas.net125	mm125	44573	74993222357
126	manager126	man@nas.net126	mm126	44574	74993222358
127	manager127	man@nas.net127	mm127	44575	74993222359
128	manager128	man@nas.net128	mm128	44576	74993222360
129	manager129	man@nas.net129	mm129	44577	74993222361
130	manager130	man@nas.net130	mm130	44578	74993222362
131	manager131	man@nas.net131	mm131	44579	74993222363
132	manager132	man@nas.net132	mm132	44580	74993222364
133	manager133	man@nas.net133	mm133	44581	74993222365
134	manager134	man@nas.net134	mm134	44582	74993222366
135	manager135	man@nas.net135	mm135	44583	74993222367
136	manager136	man@nas.net136	mm136	44584	74993222368
137	manager137	man@nas.net137	mm137	44585	74993222369
138	manager138	man@nas.net138	mm138	44586	74993222370
139	manager139	man@nas.net139	mm139	44587	74993222371
140	manager140	man@nas.net140	mm140	44588	74993222372
141	manager141	man@nas.net141	mm141	44589	74993222373
142	manager142	man@nas.net142	mm142	44590	74993222374
143	manager143	man@nas.net143	mm143	44591	74993222375
144	manager144	man@nas.net144	mm144	44592	74993222376
145	manager145	man@nas.net145	mm145	44593	74993222377
146	manager146	man@nas.net146	mm146	44594	74993222378
147	manager147	man@nas.net147	mm147	44595	74993222379
148	manager148	man@nas.net148	mm148	44596	74993222380
149	manager149	man@nas.net149	mm149	44597	74993222381
150	manager150	man@nas.net150	mm150	44598	74993222382
151	manager151	man@nas.net151	mm151	44599	74993222383
152	manager152	man@nas.net152	mm152	44600	74993222384
153	manager153	man@nas.net153	mm153	44601	74993222385
154	manager154	man@nas.net154	mm154	44602	74993222386
155	manager155	man@nas.net155	mm155	44603	74993222387
156	manager156	man@nas.net156	mm156	44604	74993222388
157	manager157	man@nas.net157	mm157	44605	74993222389
158	manager158	man@nas.net158	mm158	44606	74993222390
159	manager159	man@nas.net159	mm159	44607	74993222391
160	manager160	man@nas.net160	mm160	44608	74993222392
161	manager161	man@nas.net161	mm161	44609	74993222393
162	manager162	man@nas.net162	mm162	44610	74993222394
163	manager163	man@nas.net163	mm163	44611	74993222395
164	manager164	man@nas.net164	mm164	44612	74993222396
165	manager165	man@nas.net165	mm165	44613	74993222397
166	manager166	man@nas.net166	mm166	44614	74993222398
167	manager167	man@nas.net167	mm167	44615	74993222399
168	manager168	man@nas.net168	mm168	44616	74993222400
169	manager169	man@nas.net169	mm169	44617	74993222401
170	manager170	man@nas.net170	mm170	44618	74993222402
171	manager171	man@nas.net171	mm171	44619	74993222403
172	manager172	man@nas.net172	mm172	44620	74993222404
173	manager173	man@nas.net173	mm173	44621	74993222405
174	manager174	man@nas.net174	mm174	44622	74993222406
175	manager175	man@nas.net175	mm175	44623	74993222407
176	manager176	man@nas.net176	mm176	44624	74993222408
177	manager177	man@nas.net177	mm177	44625	74993222409
178	manager178	man@nas.net178	mm178	44626	74993222410
179	manager179	man@nas.net179	mm179	44627	74993222411
180	manager180	man@nas.net180	mm180	44628	74993222412
181	manager181	man@nas.net181	mm181	44629	74993222413
182	manager182	man@nas.net182	mm182	44630	74993222414
183	manager183	man@nas.net183	mm183	44631	74993222415
184	manager184	man@nas.net184	mm184	44632	74993222416
185	manager185	man@nas.net185	mm185	44633	74993222417
186	manager186	man@nas.net186	mm186	44634	74993222418
187	manager187	man@nas.net187	mm187	44635	74993222419
188	manager188	man@nas.net188	mm188	44636	74993222420
189	manager189	man@nas.net189	mm189	44637	74993222421
190	manager190	man@nas.net190	mm190	44638	74993222422
191	manager191	man@nas.net191	mm191	44639	74993222423
192	manager192	man@nas.net192	mm192	44640	74993222424
193	manager193	man@nas.net193	mm193	44641	74993222425
194	manager194	man@nas.net194	mm194	44642	74993222426
195	manager195	man@nas.net195	mm195	44643	74993222427
196	manager196	man@nas.net196	mm196	44644	74993222428
197	manager197	man@nas.net197	mm197	44645	74993222429
198	manager198	man@nas.net198	mm198	44646	74993222430
199	manager199	man@nas.net199	mm199	44647	74993222431
200	manager200	man@nas.net200	mm200	44648	74993222432
201	manager201	man@nas.net201	mm201	44649	74993222433
202	manager202	man@nas.net202	mm202	44650	74993222434
203	manager203	man@nas.net203	mm203	44651	74993222435
204	manager204	man@nas.net204	mm204	44652	74993222436
205	manager205	man@nas.net205	mm205	44653	74993222437
206	manager206	man@nas.net206	mm206	44654	74993222438
207	manager207	man@nas.net207	mm207	44655	74993222439
208	manager208	man@nas.net208	mm208	44656	74993222440
209	manager209	man@nas.net209	mm209	44657	74993222441
210	manager210	man@nas.net210	mm210	44658	74993222442
211	manager211	man@nas.net211	mm211	44659	74993222443
212	manager212	man@nas.net212	mm212	44660	74993222444
213	manager213	man@nas.net213	mm213	44661	74993222445
214	manager214	man@nas.net214	mm214	44662	74993222446
215	manager215	man@nas.net215	mm215	44663	74993222447
216	manager216	man@nas.net216	mm216	44664	74993222448
217	manager217	man@nas.net217	mm217	44665	74993222449
218	manager218	man@nas.net218	mm218	44666	74993222450
219	manager219	man@nas.net219	mm219	44667	74993222451
220	manager220	man@nas.net220	mm220	44668	74993222452
221	manager221	man@nas.net221	mm221	44669	74993222453
222	manager222	man@nas.net222	mm222	44670	74993222454
223	manager223	man@nas.net223	mm223	44671	74993222455
224	manager224	man@nas.net224	mm224	44672	74993222456
225	manager225	man@nas.net225	mm225	44673	74993222457
226	manager226	man@nas.net226	mm226	44674	74993222458
227	manager227	man@nas.net227	mm227	44675	74993222459
228	manager228	man@nas.net228	mm228	44676	74993222460
229	manager229	man@nas.net229	mm229	44677	74993222461
230	manager230	man@nas.net230	mm230	44678	74993222462
231	manager231	man@nas.net231	mm231	44679	74993222463
232	manager232	man@nas.net232	mm232	44680	74993222464
233	manager233	man@nas.net233	mm233	44681	74993222465
234	manager234	man@nas.net234	mm234	44682	74993222466
235	manager235	man@nas.net235	mm235	44683	74993222467
236	manager236	man@nas.net236	mm236	44684	74993222468
237	manager237	man@nas.net237	mm237	44685	74993222469
238	manager238	man@nas.net238	mm238	44686	74993222470
239	manager239	man@nas.net239	mm239	44687	74993222471
240	manager240	man@nas.net240	mm240	44688	74993222472
241	manager241	man@nas.net241	mm241	44689	74993222473
242	manager242	man@nas.net242	mm242	44690	74993222474
243	manager243	man@nas.net243	mm243	44691	74993222475
244	manager244	man@nas.net244	mm244	44692	74993222476
245	manager245	man@nas.net245	mm245	44693	74993222477
246	manager246	man@nas.net246	mm246	44694	74993222478
247	manager247	man@nas.net247	mm247	44695	74993222479
248	manager248	man@nas.net248	mm248	44696	74993222480
249	manager249	man@nas.net249	mm249	44697	74993222481
250	manager250	man@nas.net250	mm250	44698	74993222482
251	manager251	man@nas.net251	mm251	44699	74993222483
252	manager252	man@nas.net252	mm252	44700	74993222484
253	manager253	man@nas.net253	mm253	44701	74993222485
254	manager254	man@nas.net254	mm254	44702	74993222486
255	manager255	man@nas.net255	mm255	44703	74993222487
256	manager256	man@nas.net256	mm256	44704	74993222488
257	manager257	man@nas.net257	mm257	44705	74993222489
258	manager258	man@nas.net258	mm258	44706	74993222490
259	manager259	man@nas.net259	mm259	44707	74993222491
260	manager260	man@nas.net260	mm260	44708	74993222492
261	manager261	man@nas.net261	mm261	44709	74993222493
262	manager262	man@nas.net262	mm262	44710	74993222494
263	manager263	man@nas.net263	mm263	44711	74993222495
264	manager264	man@nas.net264	mm264	44712	74993222496
265	manager265	man@nas.net265	mm265	44713	74993222497
266	manager266	man@nas.net266	mm266	44714	74993222498
267	manager267	man@nas.net267	mm267	44715	74993222499
268	manager268	man@nas.net268	mm268	44716	74993222500
269	manager269	man@nas.net269	mm269	44717	74993222501
270	manager270	man@nas.net270	mm270	44718	74993222502
271	manager271	man@nas.net271	mm271	44719	74993222503
272	manager272	man@nas.net272	mm272	44720	74993222504
273	manager273	man@nas.net273	mm273	44721	74993222505
274	manager274	man@nas.net274	mm274	44722	74993222506
275	manager275	man@nas.net275	mm275	44723	74993222507
276	manager276	man@nas.net276	mm276	44724	74993222508
277	manager277	man@nas.net277	mm277	44725	74993222509
278	manager278	man@nas.net278	mm278	44726	74993222510
279	manager279	man@nas.net279	mm279	44727	74993222511
280	manager280	man@nas.net280	mm280	44728	74993222512
281	manager281	man@nas.net281	mm281	44729	74993222513
282	manager282	man@nas.net282	mm282	44730	74993222514
283	manager283	man@nas.net283	mm283	44731	74993222515
284	manager284	man@nas.net284	mm284	44732	74993222516
285	manager285	man@nas.net285	mm285	44733	74993222517
286	manager286	man@nas.net286	mm286	44734	74993222518
287	manager287	man@nas.net287	mm287	44735	74993222519
288	manager288	man@nas.net288	mm288	44736	74993222520
289	manager289	man@nas.net289	mm289	44737	74993222521
290	manager290	man@nas.net290	mm290	44738	74993222522
291	manager291	man@nas.net291	mm291	44739	74993222523
292	manager292	man@nas.net292	mm292	44740	74993222524
293	manager293	man@nas.net293	mm293	44741	74993222525
294	manager294	man@nas.net294	mm294	44742	74993222526
295	manager295	man@nas.net295	mm295	44743	74993222527
296	manager296	man@nas.net296	mm296	44744	74993222528
297	manager297	man@nas.net297	mm297	44745	74993222529
298	manager298	man@nas.net298	mm298	44746	74993222530
299	manager299	man@nas.net299	mm299	44747	74993222531
300	manager300	man@nas.net300	mm300	44748	74993222532
301	manager301	man@nas.net301	mm301	44749	74993222533
302	manager302	man@nas.net302	mm302	44750	74993222534
303	manager303	man@nas.net303	mm303	44751	74993222535
304	manager304	man@nas.net304	mm304	44752	74993222536
305	manager305	man@nas.net305	mm305	44753	74993222537
306	manager306	man@nas.net306	mm306	44754	74993222538
307	manager307	man@nas.net307	mm307	44755	74993222539
308	manager308	man@nas.net308	mm308	44756	74993222540
309	manager309	man@nas.net309	mm309	44757	74993222541
310	manager310	man@nas.net310	mm310	44758	74993222542
311	manager311	man@nas.net311	mm311	44759	74993222543
312	manager312	man@nas.net312	mm312	44760	74993222544
313	manager313	man@nas.net313	mm313	44761	74993222545
314	manager314	man@nas.net314	mm314	44762	74993222546
315	manager315	man@nas.net315	mm315	44763	74993222547
316	manager316	man@nas.net316	mm316	44764	74993222548
317	manager317	man@nas.net317	mm317	44765	74993222549
318	manager318	man@nas.net318	mm318	44766	74993222550
319	manager319	man@nas.net319	mm319	44767	74993222551
320	manager320	man@nas.net320	mm320	44768	74993222552
321	manager321	man@nas.net321	mm321	44769	74993222553
322	manager322	man@nas.net322	mm322	44770	74993222554
323	manager323	man@nas.net323	mm323	44771	74993222555
324	manager324	man@nas.net324	mm324	44772	74993222556
325	manager325	man@nas.net325	mm325	44773	74993222557
326	manager326	man@nas.net326	mm326	44774	74993222558
327	manager327	man@nas.net327	mm327	44775	74993222559
328	manager328	man@nas.net328	mm328	44776	74993222560
329	manager329	man@nas.net329	mm329	44777	74993222561
330	manager330	man@nas.net330	mm330	44778	74993222562
331	manager331	man@nas.net331	mm331	44779	74993222563
332	manager332	man@nas.net332	mm332	44780	74993222564
333	manager333	man@nas.net333	mm333	44781	74993222565
334	manager334	man@nas.net334	mm334	44782	74993222566
335	manager335	man@nas.net335	mm335	44783	74993222567
336	manager336	man@nas.net336	mm336	44784	74993222568
337	manager337	man@nas.net337	mm337	44785	74993222569
338	manager338	man@nas.net338	mm338	44786	74993222570
339	manager339	man@nas.net339	mm339	44787	74993222571
340	manager340	man@nas.net340	mm340	44788	74993222572
341	manager341	man@nas.net341	mm341	44789	74993222573
342	manager342	man@nas.net342	mm342	44790	74993222574
343	manager343	man@nas.net343	mm343	44791	74993222575
344	manager344	man@nas.net344	mm344	44792	74993222576
345	manager345	man@nas.net345	mm345	44793	74993222577
346	manager346	man@nas.net346	mm346	44794	74993222578
347	manager347	man@nas.net347	mm347	44795	74993222579
348	manager348	man@nas.net348	mm348	44796	74993222580
349	manager349	man@nas.net349	mm349	44797	74993222581
350	manager350	man@nas.net350	mm350	44798	74993222582
351	manager351	man@nas.net351	mm351	44799	74993222583
352	manager352	man@nas.net352	mm352	44800	74993222584
353	manager353	man@nas.net353	mm353	44801	74993222585
354	manager354	man@nas.net354	mm354	44802	74993222586
355	manager355	man@nas.net355	mm355	44803	74993222587
356	manager356	man@nas.net356	mm356	44804	74993222588
357	manager357	man@nas.net357	mm357	44805	74993222589
358	manager358	man@nas.net358	mm358	44806	74993222590
359	manager359	man@nas.net359	mm359	44807	74993222591
360	manager360	man@nas.net360	mm360	44808	74993222592
361	manager361	man@nas.net361	mm361	44809	74993222593
362	manager362	man@nas.net362	mm362	44810	74993222594
363	manager363	man@nas.net363	mm363	44811	74993222595
364	manager364	man@nas.net364	mm364	44812	74993222596
365	manager365	man@nas.net365	mm365	44813	74993222597
366	manager366	man@nas.net366	mm366	44814	74993222598
367	manager367	man@nas.net367	mm367	44815	74993222599
368	manager368	man@nas.net368	mm368	44816	74993222600
369	manager369	man@nas.net369	mm369	44817	74993222601
370	manager370	man@nas.net370	mm370	44818	74993222602
371	manager371	man@nas.net371	mm371	44819	74993222603
372	manager372	man@nas.net372	mm372	44820	74993222604
373	manager373	man@nas.net373	mm373	44821	74993222605
374	manager374	man@nas.net374	mm374	44822	74993222606
375	manager375	man@nas.net375	mm375	44823	74993222607
376	manager376	man@nas.net376	mm376	44824	74993222608
377	manager377	man@nas.net377	mm377	44825	74993222609
378	manager378	man@nas.net378	mm378	44826	74993222610
379	manager379	man@nas.net379	mm379	44827	74993222611
380	manager380	man@nas.net380	mm380	44828	74993222612
381	manager381	man@nas.net381	mm381	44829	74993222613
382	manager382	man@nas.net382	mm382	44830	74993222614
383	manager383	man@nas.net383	mm383	44831	74993222615
384	manager384	man@nas.net384	mm384	44832	74993222616
385	manager385	man@nas.net385	mm385	44833	74993222617
386	manager386	man@nas.net386	mm386	44834	74993222618
387	manager387	man@nas.net387	mm387	44835	74993222619
388	manager388	man@nas.net388	mm388	44836	74993222620
389	manager389	man@nas.net389	mm389	44837	74993222621
390	manager390	man@nas.net390	mm390	44838	74993222622
391	manager391	man@nas.net391	mm391	44839	74993222623
392	manager392	man@nas.net392	mm392	44840	74993222624
393	manager393	man@nas.net393	mm393	44841	74993222625
394	manager394	man@nas.net394	mm394	44842	74993222626
395	manager395	man@nas.net395	mm395	44843	74993222627
396	manager396	man@nas.net396	mm396	44844	74993222628
397	manager397	man@nas.net397	mm397	44845	74993222629
398	manager398	man@nas.net398	mm398	44846	74993222630
399	manager399	man@nas.net399	mm399	44847	74993222631
400	manager400	man@nas.net400	mm400	44848	74993222632
401	manager401	man@nas.net401	mm401	44849	74993222633
402	manager402	man@nas.net402	mm402	44850	74993222634
403	manager403	man@nas.net403	mm403	44851	74993222635
404	manager404	man@nas.net404	mm404	44852	74993222636
405	manager405	man@nas.net405	mm405	44853	74993222637
406	manager406	man@nas.net406	mm406	44854	74993222638
407	manager407	man@nas.net407	mm407	44855	74993222639
408	manager408	man@nas.net408	mm408	44856	74993222640
409	manager409	man@nas.net409	mm409	44857	74993222641
410	manager410	man@nas.net410	mm410	44858	74993222642
411	manager411	man@nas.net411	mm411	44859	74993222643
412	manager412	man@nas.net412	mm412	44860	74993222644
413	manager413	man@nas.net413	mm413	44861	74993222645
414	manager414	man@nas.net414	mm414	44862	74993222646
415	manager415	man@nas.net415	mm415	44863	74993222647
416	manager416	man@nas.net416	mm416	44864	74993222648
417	manager417	man@nas.net417	mm417	44865	74993222649
418	manager418	man@nas.net418	mm418	44866	74993222650
419	manager419	man@nas.net419	mm419	44867	74993222651
420	manager420	man@nas.net420	mm420	44868	74993222652
421	manager421	man@nas.net421	mm421	44869	74993222653
422	manager422	man@nas.net422	mm422	44870	74993222654
423	manager423	man@nas.net423	mm423	44871	74993222655
424	manager424	man@nas.net424	mm424	44872	74993222656
425	manager425	man@nas.net425	mm425	44873	74993222657
426	manager426	man@nas.net426	mm426	44874	74993222658
427	manager427	man@nas.net427	mm427	44875	74993222659
428	manager428	man@nas.net428	mm428	44876	74993222660
429	manager429	man@nas.net429	mm429	44877	74993222661
430	manager430	man@nas.net430	mm430	44878	74993222662
431	manager431	man@nas.net431	mm431	44879	74993222663
432	manager432	man@nas.net432	mm432	44880	74993222664
433	manager433	man@nas.net433	mm433	44881	74993222665
434	manager434	man@nas.net434	mm434	44882	74993222666
435	manager435	man@nas.net435	mm435	44883	74993222667
436	manager436	man@nas.net436	mm436	44884	74993222668
437	manager437	man@nas.net437	mm437	44885	74993222669
438	manager438	man@nas.net438	mm438	44886	74993222670
439	manager439	man@nas.net439	mm439	44887	74993222671
440	manager440	man@nas.net440	mm440	44888	74993222672
441	manager441	man@nas.net441	mm441	44889	74993222673
442	manager442	man@nas.net442	mm442	44890	74993222674
443	manager443	man@nas.net443	mm443	44891	74993222675
444	manager444	man@nas.net444	mm444	44892	74993222676
445	manager445	man@nas.net445	mm445	44893	74993222677
446	manager446	man@nas.net446	mm446	44894	74993222678
447	manager447	man@nas.net447	mm447	44895	74993222679
448	manager448	man@nas.net448	mm448	44896	74993222680
449	manager449	man@nas.net449	mm449	44897	74993222681
450	manager450	man@nas.net450	mm450	44898	74993222682
451	manager451	man@nas.net451	mm451	44899	74993222683
452	manager452	man@nas.net452	mm452	44900	74993222684
453	manager453	man@nas.net453	mm453	44901	74993222685
454	manager454	man@nas.net454	mm454	44902	74993222686
455	manager455	man@nas.net455	mm455	44903	74993222687
456	manager456	man@nas.net456	mm456	44904	74993222688
457	manager457	man@nas.net457	mm457	44905	74993222689
458	manager458	man@nas.net458	mm458	44906	74993222690
459	manager459	man@nas.net459	mm459	44907	74993222691
460	manager460	man@nas.net460	mm460	44908	74993222692
461	manager461	man@nas.net461	mm461	44909	74993222693
462	manager462	man@nas.net462	mm462	44910	74993222694
463	manager463	man@nas.net463	mm463	44911	74993222695
464	manager464	man@nas.net464	mm464	44912	74993222696
465	manager465	man@nas.net465	mm465	44913	74993222697
466	manager466	man@nas.net466	mm466	44914	74993222698
467	manager467	man@nas.net467	mm467	44915	74993222699
468	manager468	man@nas.net468	mm468	44916	74993222700
469	manager469	man@nas.net469	mm469	44917	74993222701
470	manager470	man@nas.net470	mm470	44918	74993222702
471	manager471	man@nas.net471	mm471	44919	74993222703
472	manager472	man@nas.net472	mm472	44920	74993222704
473	manager473	man@nas.net473	mm473	44921	74993222705
474	manager474	man@nas.net474	mm474	44922	74993222706
475	manager475	man@nas.net475	mm475	44923	74993222707
476	manager476	man@nas.net476	mm476	44924	74993222708
477	manager477	man@nas.net477	mm477	44925	74993222709
478	manager478	man@nas.net478	mm478	44926	74993222710
479	manager479	man@nas.net479	mm479	44927	74993222711
480	manager480	man@nas.net480	mm480	44928	74993222712
481	manager481	man@nas.net481	mm481	44929	74993222713
482	manager482	man@nas.net482	mm482	44930	74993222714
483	manager483	man@nas.net483	mm483	44931	74993222715
484	manager484	man@nas.net484	mm484	44932	74993222716
485	manager485	man@nas.net485	mm485	44933	74993222717
486	manager486	man@nas.net486	mm486	44934	74993222718
487	manager487	man@nas.net487	mm487	44935	74993222719
488	manager488	man@nas.net488	mm488	44936	74993222720
489	manager489	man@nas.net489	mm489	44937	74993222721
490	manager490	man@nas.net490	mm490	44938	74993222722
491	manager491	man@nas.net491	mm491	44939	74993222723
492	manager492	man@nas.net492	mm492	44940	74993222724
493	manager493	man@nas.net493	mm493	44941	74993222725
494	manager494	man@nas.net494	mm494	44942	74993222726
495	manager495	man@nas.net495	mm495	44943	74993222727
496	manager496	man@nas.net496	mm496	44944	74993222728
497	manager497	man@nas.net497	mm497	44945	74993222729
498	manager498	man@nas.net498	mm498	44946	74993222730
499	manager499	man@nas.net499	mm499	44947	74993222731
500	manager500	man@nas.net500	mm500	44948	74993222732
501	manager501	man@nas.net501	mm501	44949	74993222733
502	manager502	man@nas.net502	mm502	44950	74993222734
503	manager503	man@nas.net503	mm503	44951	74993222735
504	manager504	man@nas.net504	mm504	44952	74993222736
505	manager505	man@nas.net505	mm505	44953	74993222737
506	manager506	man@nas.net506	mm506	44954	74993222738
507	manager507	man@nas.net507	mm507	44955	74993222739
508	manager508	man@nas.net508	mm508	44956	74993222740
509	manager509	man@nas.net509	mm509	44957	74993222741
510	manager510	man@nas.net510	mm510	44958	74993222742
511	manager511	man@nas.net511	mm511	44959	74993222743
512	manager512	man@nas.net512	mm512	44960	74993222744
513	manager513	man@nas.net513	mm513	44961	74993222745
514	manager514	man@nas.net514	mm514	44962	74993222746
515	manager515	man@nas.net515	mm515	44963	74993222747
516	manager516	man@nas.net516	mm516	44964	74993222748
517	manager517	man@nas.net517	mm517	44965	74993222749
518	manager518	man@nas.net518	mm518	44966	74993222750
519	manager519	man@nas.net519	mm519	44967	74993222751
520	manager520	man@nas.net520	mm520	44968	74993222752
521	manager521	man@nas.net521	mm521	44969	74993222753
522	manager522	man@nas.net522	mm522	44970	74993222754
523	manager523	man@nas.net523	mm523	44971	74993222755
524	manager524	man@nas.net524	mm524	44972	74993222756
525	manager525	man@nas.net525	mm525	44973	74993222757
526	manager526	man@nas.net526	mm526	44974	74993222758
527	manager527	man@nas.net527	mm527	44975	74993222759
528	manager528	man@nas.net528	mm528	44976	74993222760
529	manager529	man@nas.net529	mm529	44977	74993222761
530	manager530	man@nas.net530	mm530	44978	74993222762
531	manager531	man@nas.net531	mm531	44979	74993222763
532	manager532	man@nas.net532	mm532	44980	74993222764
533	manager533	man@nas.net533	mm533	44981	74993222765
534	manager534	man@nas.net534	mm534	44982	74993222766
535	manager535	man@nas.net535	mm535	44983	74993222767
536	manager536	man@nas.net536	mm536	44984	74993222768
537	manager537	man@nas.net537	mm537	44985	74993222769
538	manager538	man@nas.net538	mm538	44986	74993222770
539	manager539	man@nas.net539	mm539	44987	74993222771
540	manager540	man@nas.net540	mm540	44988	74993222772
541	manager541	man@nas.net541	mm541	44989	74993222773
542	manager542	man@nas.net542	mm542	44990	74993222774
543	manager543	man@nas.net543	mm543	44991	74993222775
544	manager544	man@nas.net544	mm544	44992	74993222776
545	manager545	man@nas.net545	mm545	44993	74993222777
546	manager546	man@nas.net546	mm546	44994	74993222778
547	manager547	man@nas.net547	mm547	44995	74993222779
548	manager548	man@nas.net548	mm548	44996	74993222780
549	manager549	man@nas.net549	mm549	44997	74993222781
550	manager550	man@nas.net550	mm550	44998	74993222782
551	manager551	man@nas.net551	mm551	44999	74993222783
552	manager552	man@nas.net552	mm552	45000	74993222784
553	manager553	man@nas.net553	mm553	45001	74993222785
554	manager554	man@nas.net554	mm554	45002	74993222786
555	manager555	man@nas.net555	mm555	45003	74993222787
556	manager556	man@nas.net556	mm556	45004	74993222788
557	manager557	man@nas.net557	mm557	45005	74993222789
558	manager558	man@nas.net558	mm558	45006	74993222790
559	manager559	man@nas.net559	mm559	45007	74993222791
560	manager560	man@nas.net560	mm560	45008	74993222792
561	manager561	man@nas.net561	mm561	45009	74993222793
562	manager562	man@nas.net562	mm562	45010	74993222794
563	manager563	man@nas.net563	mm563	45011	74993222795
564	manager564	man@nas.net564	mm564	45012	74993222796
565	manager565	man@nas.net565	mm565	45013	74993222797
566	manager566	man@nas.net566	mm566	45014	74993222798
567	manager567	man@nas.net567	mm567	45015	74993222799
568	manager568	man@nas.net568	mm568	45016	74993222800
569	manager569	man@nas.net569	mm569	45017	74993222801
570	manager570	man@nas.net570	mm570	45018	74993222802
571	manager571	man@nas.net571	mm571	45019	74993222803
572	manager572	man@nas.net572	mm572	45020	74993222804
573	manager573	man@nas.net573	mm573	45021	74993222805
574	manager574	man@nas.net574	mm574	45022	74993222806
575	manager575	man@nas.net575	mm575	45023	74993222807
576	manager576	man@nas.net576	mm576	45024	74993222808
577	manager577	man@nas.net577	mm577	45025	74993222809
578	manager578	man@nas.net578	mm578	45026	74993222810
579	manager579	man@nas.net579	mm579	45027	74993222811
580	manager580	man@nas.net580	mm580	45028	74993222812
581	manager581	man@nas.net581	mm581	45029	74993222813
582	manager582	man@nas.net582	mm582	45030	74993222814
583	manager583	man@nas.net583	mm583	45031	74993222815
584	manager584	man@nas.net584	mm584	45032	74993222816
585	manager585	man@nas.net585	mm585	45033	74993222817
586	manager586	man@nas.net586	mm586	45034	74993222818
587	manager587	man@nas.net587	mm587	45035	74993222819
588	manager588	man@nas.net588	mm588	45036	74993222820
589	manager589	man@nas.net589	mm589	45037	74993222821
590	manager590	man@nas.net590	mm590	45038	74993222822
591	manager591	man@nas.net591	mm591	45039	74993222823
592	manager592	man@nas.net592	mm592	45040	74993222824
593	manager593	man@nas.net593	mm593	45041	74993222825
594	manager594	man@nas.net594	mm594	45042	74993222826
595	manager595	man@nas.net595	mm595	45043	74993222827
596	manager596	man@nas.net596	mm596	45044	74993222828
597	manager597	man@nas.net597	mm597	45045	74993222829
598	manager598	man@nas.net598	mm598	45046	74993222830
599	manager599	man@nas.net599	mm599	45047	74993222831
600	manager600	man@nas.net600	mm600	45048	74993222832
601	manager601	man@nas.net601	mm601	45049	74993222833
602	manager602	man@nas.net602	mm602	45050	74993222834
603	manager603	man@nas.net603	mm603	45051	74993222835
604	manager604	man@nas.net604	mm604	45052	74993222836
605	manager605	man@nas.net605	mm605	45053	74993222837
606	manager606	man@nas.net606	mm606	45054	74993222838
607	manager607	man@nas.net607	mm607	45055	74993222839
608	manager608	man@nas.net608	mm608	45056	74993222840
609	manager609	man@nas.net609	mm609	45057	74993222841
610	manager610	man@nas.net610	mm610	45058	74993222842
611	manager611	man@nas.net611	mm611	45059	74993222843
612	manager612	man@nas.net612	mm612	45060	74993222844
613	manager613	man@nas.net613	mm613	45061	74993222845
614	manager614	man@nas.net614	mm614	45062	74993222846
615	manager615	man@nas.net615	mm615	45063	74993222847
616	manager616	man@nas.net616	mm616	45064	74993222848
617	manager617	man@nas.net617	mm617	45065	74993222849
618	manager618	man@nas.net618	mm618	45066	74993222850
619	manager619	man@nas.net619	mm619	45067	74993222851
620	manager620	man@nas.net620	mm620	45068	74993222852
621	manager621	man@nas.net621	mm621	45069	74993222853
622	manager622	man@nas.net622	mm622	45070	74993222854
623	manager623	man@nas.net623	mm623	45071	74993222855
624	manager624	man@nas.net624	mm624	45072	74993222856
625	manager625	man@nas.net625	mm625	45073	74993222857
626	manager626	man@nas.net626	mm626	45074	74993222858
627	manager627	man@nas.net627	mm627	45075	74993222859
628	manager628	man@nas.net628	mm628	45076	74993222860
629	manager629	man@nas.net629	mm629	45077	74993222861
630	manager630	man@nas.net630	mm630	45078	74993222862
631	manager631	man@nas.net631	mm631	45079	74993222863
632	manager632	man@nas.net632	mm632	45080	74993222864
633	manager633	man@nas.net633	mm633	45081	74993222865
634	manager634	man@nas.net634	mm634	45082	74993222866
635	manager635	man@nas.net635	mm635	45083	74993222867
636	manager636	man@nas.net636	mm636	45084	74993222868
637	manager637	man@nas.net637	mm637	45085	74993222869
638	manager638	man@nas.net638	mm638	45086	74993222870
639	manager639	man@nas.net639	mm639	45087	74993222871
640	manager640	man@nas.net640	mm640	45088	74993222872
641	manager641	man@nas.net641	mm641	45089	74993222873
642	manager642	man@nas.net642	mm642	45090	74993222874
643	manager643	man@nas.net643	mm643	45091	74993222875
644	manager644	man@nas.net644	mm644	45092	74993222876
645	manager645	man@nas.net645	mm645	45093	74993222877
646	manager646	man@nas.net646	mm646	45094	74993222878
647	manager647	man@nas.net647	mm647	45095	74993222879
648	manager648	man@nas.net648	mm648	45096	74993222880
649	manager649	man@nas.net649	mm649	45097	74993222881
650	manager650	man@nas.net650	mm650	45098	74993222882
651	manager651	man@nas.net651	mm651	45099	74993222883
652	manager652	man@nas.net652	mm652	45100	74993222884
653	manager653	man@nas.net653	mm653	45101	74993222885
654	manager654	man@nas.net654	mm654	45102	74993222886
655	manager655	man@nas.net655	mm655	45103	74993222887
656	manager656	man@nas.net656	mm656	45104	74993222888
657	manager657	man@nas.net657	mm657	45105	74993222889
658	manager658	man@nas.net658	mm658	45106	74993222890
659	manager659	man@nas.net659	mm659	45107	74993222891
660	manager660	man@nas.net660	mm660	45108	74993222892
661	manager661	man@nas.net661	mm661	45109	74993222893
662	manager662	man@nas.net662	mm662	45110	74993222894
663	manager663	man@nas.net663	mm663	45111	74993222895
664	manager664	man@nas.net664	mm664	45112	74993222896
665	manager665	man@nas.net665	mm665	45113	74993222897
666	manager666	man@nas.net666	mm666	45114	74993222898
667	manager667	man@nas.net667	mm667	45115	74993222899
668	manager668	man@nas.net668	mm668	45116	74993222900
669	manager669	man@nas.net669	mm669	45117	74993222901
670	manager670	man@nas.net670	mm670	45118	74993222902
671	manager671	man@nas.net671	mm671	45119	74993222903
672	manager672	man@nas.net672	mm672	45120	74993222904
673	manager673	man@nas.net673	mm673	45121	74993222905
674	manager674	man@nas.net674	mm674	45122	74993222906
675	manager675	man@nas.net675	mm675	45123	74993222907
676	manager676	man@nas.net676	mm676	45124	74993222908
677	manager677	man@nas.net677	mm677	45125	74993222909
678	manager678	man@nas.net678	mm678	45126	74993222910
679	manager679	man@nas.net679	mm679	45127	74993222911
680	manager680	man@nas.net680	mm680	45128	74993222912
681	manager681	man@nas.net681	mm681	45129	74993222913
682	manager682	man@nas.net682	mm682	45130	74993222914
683	manager683	man@nas.net683	mm683	45131	74993222915
684	manager684	man@nas.net684	mm684	45132	74993222916
685	manager685	man@nas.net685	mm685	45133	74993222917
686	manager686	man@nas.net686	mm686	45134	74993222918
687	manager687	man@nas.net687	mm687	45135	74993222919
688	manager688	man@nas.net688	mm688	45136	74993222920
689	manager689	man@nas.net689	mm689	45137	74993222921
690	manager690	man@nas.net690	mm690	45138	74993222922
691	manager691	man@nas.net691	mm691	45139	74993222923
692	manager692	man@nas.net692	mm692	45140	74993222924
693	manager693	man@nas.net693	mm693	45141	74993222925
694	manager694	man@nas.net694	mm694	45142	74993222926
695	manager695	man@nas.net695	mm695	45143	74993222927
696	manager696	man@nas.net696	mm696	45144	74993222928
697	manager697	man@nas.net697	mm697	45145	74993222929
698	manager698	man@nas.net698	mm698	45146	74993222930
699	manager699	man@nas.net699	mm699	45147	74993222931
700	manager700	man@nas.net700	mm700	45148	74993222932
701	manager701	man@nas.net701	mm701	45149	74993222933
702	manager702	man@nas.net702	mm702	45150	74993222934
703	manager703	man@nas.net703	mm703	45151	74993222935
704	manager704	man@nas.net704	mm704	45152	74993222936
705	manager705	man@nas.net705	mm705	45153	74993222937
706	manager706	man@nas.net706	mm706	45154	74993222938
707	manager707	man@nas.net707	mm707	45155	74993222939
708	manager708	man@nas.net708	mm708	45156	74993222940
709	manager709	man@nas.net709	mm709	45157	74993222941
710	manager710	man@nas.net710	mm710	45158	74993222942
711	manager711	man@nas.net711	mm711	45159	74993222943
712	manager712	man@nas.net712	mm712	45160	74993222944
713	manager713	man@nas.net713	mm713	45161	74993222945
714	manager714	man@nas.net714	mm714	45162	74993222946
715	manager715	man@nas.net715	mm715	45163	74993222947
716	manager716	man@nas.net716	mm716	45164	74993222948
717	manager717	man@nas.net717	mm717	45165	74993222949
718	manager718	man@nas.net718	mm718	45166	74993222950
719	manager719	man@nas.net719	mm719	45167	74993222951
720	manager720	man@nas.net720	mm720	45168	74993222952
721	manager721	man@nas.net721	mm721	45169	74993222953
722	manager722	man@nas.net722	mm722	45170	74993222954
723	manager723	man@nas.net723	mm723	45171	74993222955
724	manager724	man@nas.net724	mm724	45172	74993222956
725	manager725	man@nas.net725	mm725	45173	74993222957
726	manager726	man@nas.net726	mm726	45174	74993222958
727	manager727	man@nas.net727	mm727	45175	74993222959
728	manager728	man@nas.net728	mm728	45176	74993222960
729	manager729	man@nas.net729	mm729	45177	74993222961
730	manager730	man@nas.net730	mm730	45178	74993222962
731	manager731	man@nas.net731	mm731	45179	74993222963
732	manager732	man@nas.net732	mm732	45180	74993222964
733	manager733	man@nas.net733	mm733	45181	74993222965
734	manager734	man@nas.net734	mm734	45182	74993222966
735	manager735	man@nas.net735	mm735	45183	74993222967
736	manager736	man@nas.net736	mm736	45184	74993222968
737	manager737	man@nas.net737	mm737	45185	74993222969
738	manager738	man@nas.net738	mm738	45186	74993222970
739	manager739	man@nas.net739	mm739	45187	74993222971
740	manager740	man@nas.net740	mm740	45188	74993222972
741	manager741	man@nas.net741	mm741	45189	74993222973
742	manager742	man@nas.net742	mm742	45190	74993222974
743	manager743	man@nas.net743	mm743	45191	74993222975
744	manager744	man@nas.net744	mm744	45192	74993222976
745	manager745	man@nas.net745	mm745	45193	74993222977
746	manager746	man@nas.net746	mm746	45194	74993222978
747	manager747	man@nas.net747	mm747	45195	74993222979
748	manager748	man@nas.net748	mm748	45196	74993222980
749	manager749	man@nas.net749	mm749	45197	74993222981
750	manager750	man@nas.net750	mm750	45198	74993222982
751	manager751	man@nas.net751	mm751	45199	74993222983
752	manager752	man@nas.net752	mm752	45200	74993222984
753	manager753	man@nas.net753	mm753	45201	74993222985
754	manager754	man@nas.net754	mm754	45202	74993222986
755	manager755	man@nas.net755	mm755	45203	74993222987
756	manager756	man@nas.net756	mm756	45204	74993222988
757	manager757	man@nas.net757	mm757	45205	74993222989
758	manager758	man@nas.net758	mm758	45206	74993222990
759	manager759	man@nas.net759	mm759	45207	74993222991
760	manager760	man@nas.net760	mm760	45208	74993222992
761	manager761	man@nas.net761	mm761	45209	74993222993
762	manager762	man@nas.net762	mm762	45210	74993222994
763	manager763	man@nas.net763	mm763	45211	74993222995
764	manager764	man@nas.net764	mm764	45212	74993222996
765	manager765	man@nas.net765	mm765	45213	74993222997
766	manager766	man@nas.net766	mm766	45214	74993222998
767	manager767	man@nas.net767	mm767	45215	74993222999
768	manager768	man@nas.net768	mm768	45216	74993223000
769	manager769	man@nas.net769	mm769	45217	74993223001
770	manager770	man@nas.net770	mm770	45218	74993223002
771	manager771	man@nas.net771	mm771	45219	74993223003
772	manager772	man@nas.net772	mm772	45220	74993223004
773	manager773	man@nas.net773	mm773	45221	74993223005
774	manager774	man@nas.net774	mm774	45222	74993223006
775	manager775	man@nas.net775	mm775	45223	74993223007
776	manager776	man@nas.net776	mm776	45224	74993223008
777	manager777	man@nas.net777	mm777	45225	74993223009
778	manager778	man@nas.net778	mm778	45226	74993223010
779	manager779	man@nas.net779	mm779	45227	74993223011
780	manager780	man@nas.net780	mm780	45228	74993223012
781	manager781	man@nas.net781	mm781	45229	74993223013
782	manager782	man@nas.net782	mm782	45230	74993223014
783	manager783	man@nas.net783	mm783	45231	74993223015
784	manager784	man@nas.net784	mm784	45232	74993223016
785	manager785	man@nas.net785	mm785	45233	74993223017
786	manager786	man@nas.net786	mm786	45234	74993223018
787	manager787	man@nas.net787	mm787	45235	74993223019
788	manager788	man@nas.net788	mm788	45236	74993223020
789	manager789	man@nas.net789	mm789	45237	74993223021
790	manager790	man@nas.net790	mm790	45238	74993223022
791	manager791	man@nas.net791	mm791	45239	74993223023
792	manager792	man@nas.net792	mm792	45240	74993223024
793	manager793	man@nas.net793	mm793	45241	74993223025
794	manager794	man@nas.net794	mm794	45242	74993223026
795	manager795	man@nas.net795	mm795	45243	74993223027
796	manager796	man@nas.net796	mm796	45244	74993223028
797	manager797	man@nas.net797	mm797	45245	74993223029
798	manager798	man@nas.net798	mm798	45246	74993223030
799	manager799	man@nas.net799	mm799	45247	74993223031
800	manager800	man@nas.net800	mm800	45248	74993223032
801	manager801	man@nas.net801	mm801	45249	74993223033
802	manager802	man@nas.net802	mm802	45250	74993223034
803	manager803	man@nas.net803	mm803	45251	74993223035
804	manager804	man@nas.net804	mm804	45252	74993223036
805	manager805	man@nas.net805	mm805	45253	74993223037
806	manager806	man@nas.net806	mm806	45254	74993223038
807	manager807	man@nas.net807	mm807	45255	74993223039
808	manager808	man@nas.net808	mm808	45256	74993223040
809	manager809	man@nas.net809	mm809	45257	74993223041
810	manager810	man@nas.net810	mm810	45258	74993223042
811	manager811	man@nas.net811	mm811	45259	74993223043
812	manager812	man@nas.net812	mm812	45260	74993223044
813	manager813	man@nas.net813	mm813	45261	74993223045
814	manager814	man@nas.net814	mm814	45262	74993223046
815	manager815	man@nas.net815	mm815	45263	74993223047
816	manager816	man@nas.net816	mm816	45264	74993223048
817	manager817	man@nas.net817	mm817	45265	74993223049
818	manager818	man@nas.net818	mm818	45266	74993223050
819	manager819	man@nas.net819	mm819	45267	74993223051
820	manager820	man@nas.net820	mm820	45268	74993223052
821	manager821	man@nas.net821	mm821	45269	74993223053
822	manager822	man@nas.net822	mm822	45270	74993223054
823	manager823	man@nas.net823	mm823	45271	74993223055
824	manager824	man@nas.net824	mm824	45272	74993223056
825	manager825	man@nas.net825	mm825	45273	74993223057
826	manager826	man@nas.net826	mm826	45274	74993223058
827	manager827	man@nas.net827	mm827	45275	74993223059
828	manager828	man@nas.net828	mm828	45276	74993223060
829	manager829	man@nas.net829	mm829	45277	74993223061
830	manager830	man@nas.net830	mm830	45278	74993223062
831	manager831	man@nas.net831	mm831	45279	74993223063
832	manager832	man@nas.net832	mm832	45280	74993223064
833	manager833	man@nas.net833	mm833	45281	74993223065
834	manager834	man@nas.net834	mm834	45282	74993223066
835	manager835	man@nas.net835	mm835	45283	74993223067
836	manager836	man@nas.net836	mm836	45284	74993223068
837	manager837	man@nas.net837	mm837	45285	74993223069
838	manager838	man@nas.net838	mm838	45286	74993223070
839	manager839	man@nas.net839	mm839	45287	74993223071
840	manager840	man@nas.net840	mm840	45288	74993223072
841	manager841	man@nas.net841	mm841	45289	74993223073
842	manager842	man@nas.net842	mm842	45290	74993223074
843	manager843	man@nas.net843	mm843	45291	74993223075
844	manager844	man@nas.net844	mm844	45292	74993223076
845	manager845	man@nas.net845	mm845	45293	74993223077
846	manager846	man@nas.net846	mm846	45294	74993223078
847	manager847	man@nas.net847	mm847	45295	74993223079
848	manager848	man@nas.net848	mm848	45296	74993223080
849	manager849	man@nas.net849	mm849	45297	74993223081
850	manager850	man@nas.net850	mm850	45298	74993223082
851	manager851	man@nas.net851	mm851	45299	74993223083
852	manager852	man@nas.net852	mm852	45300	74993223084
853	manager853	man@nas.net853	mm853	45301	74993223085
854	manager854	man@nas.net854	mm854	45302	74993223086
855	manager855	man@nas.net855	mm855	45303	74993223087
856	manager856	man@nas.net856	mm856	45304	74993223088
857	manager857	man@nas.net857	mm857	45305	74993223089
858	manager858	man@nas.net858	mm858	45306	74993223090
859	manager859	man@nas.net859	mm859	45307	74993223091
860	manager860	man@nas.net860	mm860	45308	74993223092
861	manager861	man@nas.net861	mm861	45309	74993223093
862	manager862	man@nas.net862	mm862	45310	74993223094
863	manager863	man@nas.net863	mm863	45311	74993223095
864	manager864	man@nas.net864	mm864	45312	74993223096
865	manager865	man@nas.net865	mm865	45313	74993223097
866	manager866	man@nas.net866	mm866	45314	74993223098
867	manager867	man@nas.net867	mm867	45315	74993223099
868	manager868	man@nas.net868	mm868	45316	74993223100
869	manager869	man@nas.net869	mm869	45317	74993223101
870	manager870	man@nas.net870	mm870	45318	74993223102
871	manager871	man@nas.net871	mm871	45319	74993223103
872	manager872	man@nas.net872	mm872	45320	74993223104
873	manager873	man@nas.net873	mm873	45321	74993223105
874	manager874	man@nas.net874	mm874	45322	74993223106
875	manager875	man@nas.net875	mm875	45323	74993223107
876	manager876	man@nas.net876	mm876	45324	74993223108
877	manager877	man@nas.net877	mm877	45325	74993223109
878	manager878	man@nas.net878	mm878	45326	74993223110
879	manager879	man@nas.net879	mm879	45327	74993223111
880	manager880	man@nas.net880	mm880	45328	74993223112
881	manager881	man@nas.net881	mm881	45329	74993223113
882	manager882	man@nas.net882	mm882	45330	74993223114
883	manager883	man@nas.net883	mm883	45331	74993223115
884	manager884	man@nas.net884	mm884	45332	74993223116
885	manager885	man@nas.net885	mm885	45333	74993223117
886	manager886	man@nas.net886	mm886	45334	74993223118
887	manager887	man@nas.net887	mm887	45335	74993223119
888	manager888	man@nas.net888	mm888	45336	74993223120
889	manager889	man@nas.net889	mm889	45337	74993223121
890	manager890	man@nas.net890	mm890	45338	74993223122
891	manager891	man@nas.net891	mm891	45339	74993223123
892	manager892	man@nas.net892	mm892	45340	74993223124
893	manager893	man@nas.net893	mm893	45341	74993223125
894	manager894	man@nas.net894	mm894	45342	74993223126
895	manager895	man@nas.net895	mm895	45343	74993223127
896	manager896	man@nas.net896	mm896	45344	74993223128
897	manager897	man@nas.net897	mm897	45345	74993223129
898	manager898	man@nas.net898	mm898	45346	74993223130
899	manager899	man@nas.net899	mm899	45347	74993223131
900	manager900	man@nas.net900	mm900	45348	74993223132
901	manager901	man@nas.net901	mm901	45349	74993223133
902	manager902	man@nas.net902	mm902	45350	74993223134
903	manager903	man@nas.net903	mm903	45351	74993223135
904	manager904	man@nas.net904	mm904	45352	74993223136
905	manager905	man@nas.net905	mm905	45353	74993223137
906	manager906	man@nas.net906	mm906	45354	74993223138
907	manager907	man@nas.net907	mm907	45355	74993223139
908	manager908	man@nas.net908	mm908	45356	74993223140
909	manager909	man@nas.net909	mm909	45357	74993223141
910	manager910	man@nas.net910	mm910	45358	74993223142
911	manager911	man@nas.net911	mm911	45359	74993223143
912	manager912	man@nas.net912	mm912	45360	74993223144
913	manager913	man@nas.net913	mm913	45361	74993223145
914	manager914	man@nas.net914	mm914	45362	74993223146
915	manager915	man@nas.net915	mm915	45363	74993223147
916	manager916	man@nas.net916	mm916	45364	74993223148
917	manager917	man@nas.net917	mm917	45365	74993223149
918	manager918	man@nas.net918	mm918	45366	74993223150
919	manager919	man@nas.net919	mm919	45367	74993223151
920	manager920	man@nas.net920	mm920	45368	74993223152
921	manager921	man@nas.net921	mm921	45369	74993223153
922	manager922	man@nas.net922	mm922	45370	74993223154
923	manager923	man@nas.net923	mm923	45371	74993223155
924	manager924	man@nas.net924	mm924	45372	74993223156
925	manager925	man@nas.net925	mm925	45373	74993223157
926	manager926	man@nas.net926	mm926	45374	74993223158
927	manager927	man@nas.net927	mm927	45375	74993223159
928	manager928	man@nas.net928	mm928	45376	74993223160
929	manager929	man@nas.net929	mm929	45377	74993223161
930	manager930	man@nas.net930	mm930	45378	74993223162
931	manager931	man@nas.net931	mm931	45379	74993223163
932	manager932	man@nas.net932	mm932	45380	74993223164
933	manager933	man@nas.net933	mm933	45381	74993223165
934	manager934	man@nas.net934	mm934	45382	74993223166
935	manager935	man@nas.net935	mm935	45383	74993223167
936	manager936	man@nas.net936	mm936	45384	74993223168
937	manager937	man@nas.net937	mm937	45385	74993223169
938	manager938	man@nas.net938	mm938	45386	74993223170
939	manager939	man@nas.net939	mm939	45387	74993223171
940	manager940	man@nas.net940	mm940	45388	74993223172
941	manager941	man@nas.net941	mm941	45389	74993223173
942	manager942	man@nas.net942	mm942	45390	74993223174
943	manager943	man@nas.net943	mm943	45391	74993223175
944	manager944	man@nas.net944	mm944	45392	74993223176
945	manager945	man@nas.net945	mm945	45393	74993223177
946	manager946	man@nas.net946	mm946	45394	74993223178
947	manager947	man@nas.net947	mm947	45395	74993223179
948	manager948	man@nas.net948	mm948	45396	74993223180
949	manager949	man@nas.net949	mm949	45397	74993223181
950	manager950	man@nas.net950	mm950	45398	74993223182
951	manager951	man@nas.net951	mm951	45399	74993223183
952	manager952	man@nas.net952	mm952	45400	74993223184
953	manager953	man@nas.net953	mm953	45401	74993223185
954	manager954	man@nas.net954	mm954	45402	74993223186
955	manager955	man@nas.net955	mm955	45403	74993223187
956	manager956	man@nas.net956	mm956	45404	74993223188
957	manager957	man@nas.net957	mm957	45405	74993223189
958	manager958	man@nas.net958	mm958	45406	74993223190
959	manager959	man@nas.net959	mm959	45407	74993223191
960	manager960	man@nas.net960	mm960	45408	74993223192
961	manager961	man@nas.net961	mm961	45409	74993223193
962	manager962	man@nas.net962	mm962	45410	74993223194
963	manager963	man@nas.net963	mm963	45411	74993223195
964	manager964	man@nas.net964	mm964	45412	74993223196
965	manager965	man@nas.net965	mm965	45413	74993223197
966	manager966	man@nas.net966	mm966	45414	74993223198
967	manager967	man@nas.net967	mm967	45415	74993223199
968	manager968	man@nas.net968	mm968	45416	74993223200
969	manager969	man@nas.net969	mm969	45417	74993223201
970	manager970	man@nas.net970	mm970	45418	74993223202
971	manager971	man@nas.net971	mm971	45419	74993223203
972	manager972	man@nas.net972	mm972	45420	74993223204
973	manager973	man@nas.net973	mm973	45421	74993223205
974	manager974	man@nas.net974	mm974	45422	74993223206
975	manager975	man@nas.net975	mm975	45423	74993223207
976	manager976	man@nas.net976	mm976	45424	74993223208
977	manager977	man@nas.net977	mm977	45425	74993223209
978	manager978	man@nas.net978	mm978	45426	74993223210
979	manager979	man@nas.net979	mm979	45427	74993223211
980	manager980	man@nas.net980	mm980	45428	74993223212
981	manager981	man@nas.net981	mm981	45429	74993223213
982	manager982	man@nas.net982	mm982	45430	74993223214
983	manager983	man@nas.net983	mm983	45431	74993223215
984	manager984	man@nas.net984	mm984	45432	74993223216
985	manager985	man@nas.net985	mm985	45433	74993223217
986	manager986	man@nas.net986	mm986	45434	74993223218
987	manager987	man@nas.net987	mm987	45435	74993223219
988	manager988	man@nas.net988	mm988	45436	74993223220
989	manager989	man@nas.net989	mm989	45437	74993223221
990	manager990	man@nas.net990	mm990	45438	74993223222
991	manager991	man@nas.net991	mm991	45439	74993223223
992	manager992	man@nas.net992	mm992	45440	74993223224
993	manager993	man@nas.net993	mm993	45441	74993223225
994	manager994	man@nas.net994	mm994	45442	74993223226
995	manager995	man@nas.net995	mm995	45443	74993223227
996	manager996	man@nas.net996	mm996	45444	74993223228
997	manager997	man@nas.net997	mm997	45445	74993223229
998	manager998	man@nas.net998	mm998	45446	74993223230
999	manager999	man@nas.net999	mm999	45447	74993223231
1000	manager1000	man@nas.net1000	mm1000	45448	74993223232
\.


--
-- Data for Name: myemployees; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.myemployees (employeeid, firstname, lastname, title, deptid, managerid) FROM stdin;
1	Иван	Петров	Главный исполнительный директор	16	\N
\.


--
-- Data for Name: ord_status; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.ord_status (data) FROM stdin;
{"st_id" : "1", "status" : "Создан"}
{"st_id" : "2", "status" : "Оплачен"}
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.orders (order_id, date_of_shipping, addres, order_status, creation_time, source, prod_prod_id, cust_cust_id, man_man_id, qua) FROM stdin;
62	2018-07-23	moscow, ulica 62	4	2017-07-25 00:00:00	source62	110	414	198	27
49	2017-04-27	moscow, ulica 49	5	2018-12-21 00:00:00	source49	428	288	165	72
53	2018-03-25	moscow, ulica 53	1	2018-03-14 00:00:00	source53	468	438	12	80
421	2018-11-27	moscow, ulica 421	1	2017-03-25 00:00:00	source421	579	353	48	99
444	2018-11-21	moscow, ulica 444	2	2018-07-09 00:00:00	source444	673	824	630	86
388	2017-03-25	moscow, ulica 388	1	2018-02-02 00:00:00	source388	9	561	750	96
618	2017-07-14	moscow, ulica 618	2	2017-12-18 00:00:00	source618	980	914	92	98
855	2018-04-15	moscow, ulica 855	3	2018-05-28 00:00:00	source855	788	819	87	21
170	2017-11-04	moscow, ulica 170	1	2018-10-20 00:00:00	source170	983	184	645	3
156	2017-10-25	moscow, ulica 156	4	2017-08-31 00:00:00	source156	100	212	475	76
767	2018-01-25	moscow, ulica 767	3	2017-04-06 00:00:00	source767	773	545	285	17
704	2018-04-25	moscow, ulica 704	4	2018-12-01 00:00:00	source704	6	256	431	31
171	2018-03-27	moscow, ulica 171	5	2018-06-05 00:00:00	source171	541	462	191	3
166	2018-09-17	moscow, ulica 166	2	2017-08-07 00:00:00	source166	699	343	880	76
348	2017-03-18	moscow, ulica 348	1	2018-06-16 00:00:00	source348	815	994	338	10
995	2018-07-31	moscow, ulica 995	4	2018-02-15 00:00:00	source995	328	86	194	26
402	2017-09-17	moscow, ulica 402	3	2018-01-30 00:00:00	source402	685	881	480	85
498	2017-07-27	moscow, ulica 498	4	2017-05-05 00:00:00	source498	904	488	405	82
520	2018-08-20	moscow, ulica 520	3	2017-01-12 00:00:00	source520	746	620	484	18
320	2018-01-09	moscow, ulica 320	3	2018-09-17 00:00:00	source320	186	420	788	8
677	2018-11-19	moscow, ulica 677	1	2017-06-28 00:00:00	source677	136	572	948	20
620	2018-06-24	moscow, ulica 620	3	2017-03-25 00:00:00	source620	197	257	164	19
679	2017-12-19	moscow, ulica 679	2	2017-10-27 00:00:00	source679	388	824	386	100
423	2018-02-09	moscow, ulica 423	1	2017-10-06 00:00:00	source423	887	488	890	96
728	2017-02-19	moscow, ulica 728	4	2018-04-06 00:00:00	source728	997	996	648	4
131	2017-02-01	moscow, ulica 131	2	2018-02-19 00:00:00	source131	702	378	616	14
973	2017-03-19	moscow, ulica 973	5	2018-03-12 00:00:00	source973	283	698	63	71
544	2018-09-29	moscow, ulica 544	1	2017-01-14 00:00:00	source544	102	417	323	80
286	2018-01-30	moscow, ulica 286	1	2017-11-12 00:00:00	source286	573	615	316	72
848	2017-10-26	moscow, ulica 848	5	2018-12-12 00:00:00	source848	371	530	664	39
470	2018-01-16	moscow, ulica 470	5	2018-03-26 00:00:00	source470	71	443	93	23
204	2018-01-03	moscow, ulica 204	1	2018-10-22 00:00:00	source204	127	989	726	15
487	2017-10-05	moscow, ulica 487	1	2018-06-13 00:00:00	source487	869	722	782	83
98	2018-12-21	moscow, ulica 98	2	2017-02-25 00:00:00	source98	507	337	654	79
625	2017-10-01	moscow, ulica 625	2	2017-03-27 00:00:00	source625	826	438	205	95
766	2017-07-16	moscow, ulica 766	1	2017-11-23 00:00:00	source766	326	105	81	30
776	2018-07-25	moscow, ulica 776	4	2018-02-18 00:00:00	source776	917	608	153	26
849	2018-05-10	moscow, ulica 849	2	2017-09-30 00:00:00	source849	25	923	930	53
108	2018-06-02	moscow, ulica 108	2	2017-04-27 00:00:00	source108	196	525	829	30
540	2018-01-21	moscow, ulica 540	3	2018-04-22 00:00:00	source540	170	916	834	60
506	2018-10-29	moscow, ulica 506	4	2018-08-02 00:00:00	source506	732	52	521	49
187	2018-06-14	moscow, ulica 187	2	2017-10-22 00:00:00	source187	603	366	541	1
893	2018-11-04	moscow, ulica 893	5	2018-03-03 00:00:00	source893	559	232	713	47
670	2018-11-07	moscow, ulica 670	4	2018-11-08 00:00:00	source670	173	1	816	93
196	2017-06-03	moscow, ulica 196	5	2017-09-27 00:00:00	source196	578	252	333	13
589	2017-06-23	moscow, ulica 589	4	2018-12-08 00:00:00	source589	529	263	614	17
397	2017-02-19	moscow, ulica 397	3	2018-10-01 00:00:00	source397	618	566	827	23
450	2018-10-08	moscow, ulica 450	2	2017-07-09 00:00:00	source450	787	547	778	80
61	2017-06-15	moscow, ulica 61	2	2017-01-20 00:00:00	source61	751	78	952	5
992	2017-02-22	moscow, ulica 992	4	2018-11-10 00:00:00	source992	102	139	743	23
993	2018-05-24	moscow, ulica 993	3	2017-01-19 00:00:00	source993	603	625	794	54
994	2018-11-27	moscow, ulica 994	4	2018-12-27 00:00:00	source994	427	484	559	32
510	2018-10-13	moscow, ulica 510	2	2018-10-06 00:00:00	source510	595	851	610	82
784	2017-04-21	moscow, ulica 784	4	2017-03-03 00:00:00	source784	284	611	59	38
580	2017-06-24	moscow, ulica 580	3	2017-05-19 00:00:00	source580	493	530	905	39
917	2017-11-14	moscow, ulica 917	4	2018-03-06 00:00:00	source917	387	460	119	70
114	2018-03-22	moscow, ulica 114	3	2017-07-27 00:00:00	source114	244	889	439	3
868	2018-10-12	moscow, ulica 868	1	2018-06-22 00:00:00	source868	47	5	614	47
663	2018-04-22	moscow, ulica 663	1	2018-04-25 00:00:00	source663	488	16	65	7
806	2018-01-02	moscow, ulica 806	3	2017-12-17 00:00:00	source806	725	843	241	26
350	2017-11-14	moscow, ulica 350	3	2017-09-12 00:00:00	source350	316	947	19	8
882	2018-09-18	moscow, ulica 882	2	2018-12-18 00:00:00	source882	673	185	815	91
819	2018-07-13	moscow, ulica 819	5	2018-10-01 00:00:00	source819	239	445	816	58
7	2018-04-08	moscow, ulica 7	5	2018-08-25 00:00:00	source7	486	924	110	79
691	2017-02-18	moscow, ulica 691	2	2017-01-21 00:00:00	source691	824	376	64	47
455	2018-03-30	moscow, ulica 455	1	2017-10-18 00:00:00	source455	357	952	279	18
89	2017-11-30	moscow, ulica 89	5	2018-03-07 00:00:00	source89	613	341	128	1
167	2018-04-03	moscow, ulica 167	5	2017-11-02 00:00:00	source167	233	665	623	43
581	2018-02-09	moscow, ulica 581	2	2018-11-09 00:00:00	source581	787	133	236	37
722	2018-01-31	moscow, ulica 722	4	2017-01-01 00:00:00	source722	494	112	708	26
111	2017-12-15	moscow, ulica 111	5	2017-07-07 00:00:00	source111	853	973	879	79
452	2017-08-19	moscow, ulica 452	1	2017-08-20 00:00:00	source452	721	597	386	81
889	2017-12-26	moscow, ulica 889	5	2017-03-15 00:00:00	source889	64	885	668	25
469	2018-11-20	moscow, ulica 469	2	2017-03-28 00:00:00	source469	950	962	889	18
522	2017-08-28	moscow, ulica 522	5	2017-06-04 00:00:00	source522	960	129	18	95
454	2017-07-11	moscow, ulica 454	1	2017-11-21 00:00:00	source454	61	275	804	81
899	2017-09-07	moscow, ulica 899	2	2018-04-28 00:00:00	source899	93	98	306	78
690	2018-09-24	moscow, ulica 690	5	2017-09-14 00:00:00	source690	668	250	457	91
765	2018-09-16	moscow, ulica 765	1	2017-01-28 00:00:00	source765	601	992	632	28
768	2018-06-04	moscow, ulica 768	3	2018-02-21 00:00:00	source768	496	602	126	24
80	2018-11-13	moscow, ulica 80	1	2017-09-19 00:00:00	source80	192	155	687	1
896	2017-01-04	moscow, ulica 896	4	2018-12-17 00:00:00	source896	10	737	725	33
547	2018-11-08	moscow, ulica 547	5	2017-04-14 00:00:00	source547	98	995	35	62
303	2017-09-12	moscow, ulica 303	4	2017-01-05 00:00:00	source303	772	689	269	68
178	2017-11-07	moscow, ulica 178	1	2018-04-10 00:00:00	source178	62	858	574	14
52	2017-10-14	moscow, ulica 52	5	2018-08-10 00:00:00	source52	772	939	802	2
944	2018-12-19	moscow, ulica 944	5	2018-06-08 00:00:00	source944	783	476	912	82
39	2017-03-19	moscow, ulica 39	3	2018-03-28 00:00:00	source39	79	888	211	79
217	2018-02-21	moscow, ulica 217	5	2017-08-24 00:00:00	source217	866	660	612	96
657	2017-04-10	moscow, ulica 657	2	2017-10-04 00:00:00	source657	442	953	475	51
504	2018-05-20	moscow, ulica 504	4	2018-04-09 00:00:00	source504	978	738	337	80
489	2018-05-13	moscow, ulica 489	4	2017-04-08 00:00:00	source489	501	564	848	92
814	2018-06-18	moscow, ulica 814	2	2018-12-03 00:00:00	source814	154	47	74	85
519	2018-12-06	moscow, ulica 519	2	2017-10-23 00:00:00	source519	145	576	95	91
383	2018-09-12	moscow, ulica 383	1	2018-01-17 00:00:00	source383	346	784	807	84
976	2017-06-04	moscow, ulica 976	5	2017-12-24 00:00:00	source976	936	823	867	19
839	2017-02-06	moscow, ulica 839	2	2018-07-18 00:00:00	source839	927	777	931	79
224	2018-10-08	moscow, ulica 224	5	2017-02-25 00:00:00	source224	292	664	855	40
351	2018-03-27	moscow, ulica 351	5	2018-03-03 00:00:00	source351	264	92	311	6
51	2017-10-07	moscow, ulica 51	4	2018-08-19 00:00:00	source51	55	811	430	51
586	2018-11-29	moscow, ulica 586	1	2017-03-15 00:00:00	source586	459	425	909	90
188	2017-11-28	moscow, ulica 188	2	2017-07-15 00:00:00	source188	792	39	535	62
263	2018-06-28	moscow, ulica 263	2	2018-01-30 00:00:00	source263	529	191	421	85
186	2018-10-07	moscow, ulica 186	4	2017-09-15 00:00:00	source186	106	819	78	62
675	2018-01-09	moscow, ulica 675	5	2017-06-02 00:00:00	source675	106	633	912	27
989	2018-08-24	moscow, ulica 989	5	2018-02-02 00:00:00	source989	727	492	695	63
530	2018-10-15	moscow, ulica 530	1	2017-01-09 00:00:00	source530	372	363	729	93
1	2018-10-02	moscow, ulica 1	5	2017-02-22 00:00:00	source1	898	290	851	77
932	2017-11-18	moscow, ulica 932	2	2018-07-21 00:00:00	source932	101	608	444	47
590	2017-02-05	moscow, ulica 590	2	2018-05-20 00:00:00	source590	235	818	791	36
753	2017-09-04	moscow, ulica 753	1	2017-06-10 00:00:00	source753	174	622	866	69
6	2018-07-27	moscow, ulica 6	5	2017-06-15 00:00:00	source6	189	363	445	48
714	2017-06-23	moscow, ulica 714	5	2018-02-19 00:00:00	source714	487	873	705	99
928	2017-04-21	moscow, ulica 928	2	2018-02-24 00:00:00	source928	443	80	716	20
262	2018-11-12	moscow, ulica 262	5	2018-03-01 00:00:00	source262	470	346	183	68
279	2017-08-30	moscow, ulica 279	4	2017-07-27 00:00:00	source279	321	835	502	84
208	2018-02-07	moscow, ulica 208	2	2018-06-02 00:00:00	source208	279	682	231	59
933	2018-08-01	moscow, ulica 933	2	2017-06-28 00:00:00	source933	844	619	652	21
648	2017-02-19	moscow, ulica 648	4	2018-10-18 00:00:00	source648	681	725	213	89
150	2018-11-01	moscow, ulica 150	5	2017-05-05 00:00:00	source150	724	924	505	72
509	2017-11-08	moscow, ulica 509	5	2017-11-08 00:00:00	source509	160	424	234	81
394	2018-06-28	moscow, ulica 394	1	2018-10-17 00:00:00	source394	764	479	356	50
955	2017-03-09	moscow, ulica 955	5	2017-09-16 00:00:00	source955	316	756	306	5
486	2018-03-16	moscow, ulica 486	1	2017-01-05 00:00:00	source486	975	104	160	3
553	2018-02-15	moscow, ulica 553	2	2017-12-18 00:00:00	source553	96	394	69	49
250	2018-10-01	moscow, ulica 250	5	2017-05-10 00:00:00	source250	526	648	356	58
90	2018-08-25	moscow, ulica 90	1	2017-08-02 00:00:00	source90	368	508	919	74
25	2018-10-21	moscow, ulica 25	2	2018-08-11 00:00:00	source25	183	156	925	48
921	2017-06-30	moscow, ulica 921	5	2018-05-31 00:00:00	source921	789	326	766	58
533	2017-02-05	moscow, ulica 533	5	2017-07-13 00:00:00	source533	329	610	147	90
328	2018-07-13	moscow, ulica 328	5	2017-09-02 00:00:00	source328	618	34	24	7
720	2017-05-05	moscow, ulica 720	3	2017-08-30 00:00:00	source720	34	943	568	45
830	2018-03-31	moscow, ulica 830	3	2017-05-03 00:00:00	source830	702	786	677	37
829	2018-01-02	moscow, ulica 829	4	2018-06-14 00:00:00	source829	646	126	930	37
734	2018-04-01	moscow, ulica 734	4	2018-03-18 00:00:00	source734	512	905	870	58
43	2017-11-05	moscow, ulica 43	2	2017-02-20 00:00:00	source43	630	307	614	77
627	2018-06-02	moscow, ulica 627	2	2018-04-08 00:00:00	source627	878	544	758	71
305	2018-08-24	moscow, ulica 305	3	2018-07-17 00:00:00	source305	320	257	928	57
378	2018-03-07	moscow, ulica 378	2	2017-11-10 00:00:00	source378	702	129	363	7
183	2017-09-06	moscow, ulica 183	5	2018-02-27 00:00:00	source183	991	147	653	72
745	2018-08-26	moscow, ulica 745	3	2017-08-18 00:00:00	source745	537	965	397	39
934	2017-05-31	moscow, ulica 934	2	2017-12-01 00:00:00	source934	283	671	539	74
611	2018-03-17	moscow, ulica 611	4	2017-12-25 00:00:00	source611	71	897	874	91
915	2017-10-05	moscow, ulica 915	4	2017-06-17 00:00:00	source915	450	148	380	80
287	2018-08-11	moscow, ulica 287	1	2018-09-20 00:00:00	source287	965	642	569	85
744	2017-12-23	moscow, ulica 744	1	2018-01-10 00:00:00	source744	844	513	451	8
87	2017-09-03	moscow, ulica 87	1	2017-09-08 00:00:00	source87	940	20	172	75
638	2018-10-02	moscow, ulica 638	4	2017-11-17 00:00:00	source638	19	58	746	32
91	2018-01-26	moscow, ulica 91	5	2018-09-14 00:00:00	source91	602	658	221	46
571	2018-03-08	moscow, ulica 571	3	2017-02-26 00:00:00	source571	698	808	190	78
930	2017-03-14	moscow, ulica 930	1	2018-09-19 00:00:00	source930	412	911	845	82
324	2018-07-01	moscow, ulica 324	2	2017-08-23 00:00:00	source324	763	658	273	4
688	2017-09-21	moscow, ulica 688	4	2018-10-12 00:00:00	source688	989	764	962	69
671	2018-12-25	moscow, ulica 671	2	2017-12-21 00:00:00	source671	336	388	478	8
386	2017-12-14	moscow, ulica 386	1	2018-03-17 00:00:00	source386	122	916	960	44
548	2018-06-25	moscow, ulica 548	3	2017-07-23 00:00:00	source548	946	633	460	43
803	2017-07-14	moscow, ulica 803	3	2017-12-18 00:00:00	source803	644	575	123	59
826	2017-04-01	moscow, ulica 826	5	2018-08-13 00:00:00	source826	723	551	923	9
248	2017-11-08	moscow, ulica 248	3	2017-07-22 00:00:00	source248	86	538	749	47
812	2017-05-24	moscow, ulica 812	3	2018-12-08 00:00:00	source812	937	289	880	58
884	2017-09-08	moscow, ulica 884	2	2017-07-04 00:00:00	source884	647	386	715	37
600	2017-06-07	moscow, ulica 600	5	2018-03-21 00:00:00	source600	93	343	468	62
542	2018-08-24	moscow, ulica 542	2	2017-12-14 00:00:00	source542	901	519	872	71
83	2017-06-01	moscow, ulica 83	1	2018-09-02 00:00:00	source83	379	207	623	61
137	2017-06-19	moscow, ulica 137	2	2018-06-04 00:00:00	source137	485	782	596	39
570	2017-11-28	moscow, ulica 570	2	2017-08-09 00:00:00	source570	111	343	997	70
562	2017-10-13	moscow, ulica 562	2	2017-08-23 00:00:00	source562	813	702	708	42
448	2017-02-23	moscow, ulica 448	5	2017-02-16 00:00:00	source448	902	388	362	70
50	2017-07-03	moscow, ulica 50	2	2018-07-07 00:00:00	source50	86	710	923	62
610	2018-05-12	moscow, ulica 610	5	2017-04-22 00:00:00	source610	555	425	811	76
961	2017-09-28	moscow, ulica 961	3	2017-07-10 00:00:00	source961	725	358	891	89
308	2017-01-14	moscow, ulica 308	4	2017-09-09 00:00:00	source308	150	60	513	34
642	2017-08-17	moscow, ulica 642	3	2017-12-17 00:00:00	source642	106	263	91	75
511	2017-02-20	moscow, ulica 511	3	2017-05-18 00:00:00	source511	181	318	255	45
924	2018-05-03	moscow, ulica 924	3	2017-11-06 00:00:00	source924	199	331	932	19
919	2018-05-02	moscow, ulica 919	5	2018-12-21 00:00:00	source919	920	738	359	75
524	2018-12-17	moscow, ulica 524	2	2018-07-18 00:00:00	source524	605	856	633	41
92	2018-04-17	moscow, ulica 92	1	2017-04-10 00:00:00	source92	471	269	991	38
69	2018-12-22	moscow, ulica 69	5	2017-05-06 00:00:00	source69	283	224	73	61
472	2018-08-18	moscow, ulica 472	2	2017-08-20 00:00:00	source472	258	689	433	1
330	2017-11-03	moscow, ulica 330	5	2018-04-18 00:00:00	source330	297	796	490	47
878	2017-08-08	moscow, ulica 878	1	2017-04-03 00:00:00	source878	540	220	365	63
908	2017-12-30	moscow, ulica 908	5	2017-07-14 00:00:00	source908	305	400	610	17
640	2018-11-29	moscow, ulica 640	3	2018-06-09 00:00:00	source640	433	833	588	56
144	2017-03-18	moscow, ulica 144	3	2017-10-02 00:00:00	source144	204	248	421	56
787	2017-09-27	moscow, ulica 787	4	2017-12-01 00:00:00	source787	834	881	411	95
777	2018-03-15	moscow, ulica 777	2	2018-12-16 00:00:00	source777	722	843	423	8
877	2018-01-24	moscow, ulica 877	5	2018-02-23 00:00:00	source877	763	897	821	78
977	2017-11-13	moscow, ulica 977	3	2018-05-12 00:00:00	source977	303	103	914	87
912	2018-12-19	moscow, ulica 912	2	2018-09-16 00:00:00	source912	706	189	628	7
478	2017-03-11	moscow, ulica 478	5	2018-03-26 00:00:00	source478	355	11	697	70
603	2017-06-16	moscow, ulica 603	2	2018-12-28 00:00:00	source603	417	575	769	58
543	2017-04-20	moscow, ulica 543	3	2017-07-23 00:00:00	source543	178	245	860	40
175	2017-02-09	moscow, ulica 175	1	2018-03-30 00:00:00	source175	645	659	245	39
583	2017-01-07	moscow, ulica 583	3	2018-02-25 00:00:00	source583	251	773	28	52
516	2017-07-12	moscow, ulica 516	2	2017-07-06 00:00:00	source516	738	6	703	54
200	2018-04-22	moscow, ulica 200	3	2017-03-26 00:00:00	source200	599	489	408	6
986	2017-06-09	moscow, ulica 986	4	2018-03-22 00:00:00	source986	162	571	311	86
21	2017-06-17	moscow, ulica 21	1	2017-07-05 00:00:00	source21	786	426	401	89
459	2018-07-16	moscow, ulica 459	4	2018-04-16 00:00:00	source459	545	641	621	40
123	2018-05-21	moscow, ulica 123	4	2017-11-22 00:00:00	source123	397	998	896	38
567	2017-11-14	moscow, ulica 567	1	2017-03-09 00:00:00	source567	260	738	780	68
142	2018-10-04	moscow, ulica 142	5	2018-02-01 00:00:00	source142	619	667	614	56
725	2017-12-23	moscow, ulica 725	3	2018-11-28 00:00:00	source725	681	302	317	48
311	2017-04-03	moscow, ulica 311	1	2017-08-04 00:00:00	source311	678	29	841	4
431	2018-05-24	moscow, ulica 431	5	2018-05-24 00:00:00	source431	122	754	593	44
231	2018-05-25	moscow, ulica 231	5	2018-08-01 00:00:00	source231	595	76	546	34
428	2017-02-01	moscow, ulica 428	5	2018-02-09 00:00:00	source428	731	819	368	44
749	2018-11-25	moscow, ulica 749	1	2018-10-01 00:00:00	source749	633	996	230	74
18	2018-02-04	moscow, ulica 18	1	2018-04-12 00:00:00	source18	128	991	940	61
941	2018-06-01	moscow, ulica 941	5	2018-08-25 00:00:00	source941	223	485	536	17
479	2018-09-29	moscow, ulica 479	3	2018-05-25 00:00:00	source479	97	313	184	4
773	2018-03-01	moscow, ulica 773	2	2018-12-26 00:00:00	source773	254	875	796	62
783	2018-12-24	moscow, ulica 783	3	2018-02-25 00:00:00	source783	139	109	795	7
10	2018-05-08	moscow, ulica 10	3	2018-12-27 00:00:00	source10	818	408	956	89
304	2018-08-28	moscow, ulica 304	1	2018-03-20 00:00:00	source304	760	295	683	32
47	2017-01-01	moscow, ulica 47	3	2017-10-25 00:00:00	source47	683	652	295	88
813	2017-02-19	moscow, ulica 813	5	2018-04-13 00:00:00	source813	74	431	942	76
254	2018-10-04	moscow, ulica 254	5	2018-03-13 00:00:00	source254	789	387	294	6
837	2017-08-30	moscow, ulica 837	2	2018-10-11 00:00:00	source837	275	274	847	87
118	2017-08-04	moscow, ulica 118	3	2017-04-03 00:00:00	source118	453	478	529	39
152	2018-03-28	moscow, ulica 152	4	2017-03-11 00:00:00	source152	717	697	502	34
942	2018-03-21	moscow, ulica 942	5	2018-01-29 00:00:00	source942	201	17	558	71
202	2018-11-29	moscow, ulica 202	1	2018-05-09 00:00:00	source202	811	422	337	7
433	2018-05-13	moscow, ulica 433	2	2017-06-14 00:00:00	source433	897	101	187	70
552	2017-05-08	moscow, ulica 552	1	2017-05-02 00:00:00	source552	845	352	69	54
484	2018-04-25	moscow, ulica 484	3	2017-03-16 00:00:00	source484	799	255	877	40
750	2017-09-03	moscow, ulica 750	1	2017-12-19 00:00:00	source750	328	186	572	14
191	2018-10-10	moscow, ulica 191	4	2017-11-09 00:00:00	source191	556	390	524	37
93	2017-12-03	moscow, ulica 93	5	2017-12-02 00:00:00	source93	632	674	346	36
241	2017-10-19	moscow, ulica 241	1	2017-05-24 00:00:00	source241	879	338	442	6
740	2017-06-11	moscow, ulica 740	4	2017-12-29 00:00:00	source740	810	358	930	76
132	2017-03-29	moscow, ulica 132	4	2017-08-27 00:00:00	source132	341	411	91	35
982	2017-09-05	moscow, ulica 982	1	2018-07-26 00:00:00	source982	984	935	210	23
401	2017-02-17	moscow, ulica 401	1	2018-01-07 00:00:00	source401	349	431	515	42
974	2018-06-04	moscow, ulica 974	5	2017-10-19 00:00:00	source974	934	447	459	29
212	2018-08-15	moscow, ulica 212	1	2017-06-11 00:00:00	source212	370	271	216	4
40	2018-06-21	moscow, ulica 40	5	2018-08-05 00:00:00	source40	59	612	781	89
103	2018-04-08	moscow, ulica 103	5	2017-01-12 00:00:00	source103	634	906	229	39
370	2018-01-05	moscow, ulica 370	3	2018-08-03 00:00:00	source370	878	554	962	58
551	2018-07-05	moscow, ulica 551	2	2018-09-09 00:00:00	source551	334	455	757	10
275	2018-06-27	moscow, ulica 275	3	2018-06-30 00:00:00	source275	47	344	138	46
105	2017-04-12	moscow, ulica 105	4	2017-04-30 00:00:00	source105	776	506	790	98
274	2018-01-16	moscow, ulica 274	4	2018-09-22 00:00:00	source274	545	935	207	55
1000	2018-01-29	moscow, ulica 1000	2	2018-08-16 00:00:00	source1000	317	292	843	96
791	2017-07-11	moscow, ulica 791	4	2017-06-19 00:00:00	source791	586	567	424	85
238	2017-05-22	moscow, ulica 238	5	2017-03-14 00:00:00	source238	786	900	771	21
36	2017-06-15	moscow, ulica 36	5	2018-07-30 00:00:00	source36	399	789	42	61
629	2017-02-07	moscow, ulica 629	4	2018-01-19 00:00:00	source629	255	948	781	11
531	2017-07-08	moscow, ulica 531	3	2018-08-18 00:00:00	source531	658	900	313	10
972	2017-08-12	moscow, ulica 972	3	2018-03-09 00:00:00	source972	516	757	958	68
500	2018-01-09	moscow, ulica 500	4	2017-05-09 00:00:00	source500	130	368	540	15
864	2017-02-15	moscow, ulica 864	4	2017-04-20 00:00:00	source864	130	47	197	16
79	2017-03-27	moscow, ulica 79	5	2017-05-04 00:00:00	source79	544	406	530	56
597	2018-12-11	moscow, ulica 597	4	2018-12-22 00:00:00	source597	986	77	383	50
746	2018-10-05	moscow, ulica 746	4	2018-04-02 00:00:00	source746	397	306	36	36
845	2018-05-03	moscow, ulica 845	5	2017-10-19 00:00:00	source845	318	387	722	11
945	2018-08-28	moscow, ulica 945	4	2017-03-26 00:00:00	source945	439	449	35	86
106	2017-04-07	moscow, ulica 106	1	2018-09-09 00:00:00	source106	49	930	80	36
376	2017-02-06	moscow, ulica 376	3	2018-02-09 00:00:00	source376	551	975	491	61
476	2018-05-16	moscow, ulica 476	3	2018-10-12 00:00:00	source476	573	486	343	41
537	2018-04-06	moscow, ulica 537	5	2017-05-18 00:00:00	source537	218	644	685	4
979	2018-04-16	moscow, ulica 979	5	2017-09-21 00:00:00	source979	212	786	792	96
650	2017-12-29	moscow, ulica 650	5	2017-06-14 00:00:00	source650	599	2	887	8
194	2017-09-14	moscow, ulica 194	5	2017-12-29 00:00:00	source194	959	473	724	2
265	2018-09-25	moscow, ulica 265	4	2017-04-24 00:00:00	source265	233	977	316	3
74	2018-09-20	moscow, ulica 74	5	2017-12-15 00:00:00	source74	779	752	25	12
892	2017-11-04	moscow, ulica 892	1	2018-09-08 00:00:00	source892	384	80	767	73
233	2018-08-19	moscow, ulica 233	5	2017-11-26 00:00:00	source233	912	365	133	4
635	2017-01-25	moscow, ulica 635	4	2017-09-06 00:00:00	source635	985	938	526	8
535	2017-12-15	moscow, ulica 535	3	2018-04-07 00:00:00	source535	25	827	462	11
639	2018-09-30	moscow, ulica 639	2	2018-02-18 00:00:00	source639	289	736	890	62
804	2018-07-13	moscow, ulica 804	3	2018-10-21 00:00:00	source804	817	791	915	93
474	2017-10-20	moscow, ulica 474	4	2017-01-23 00:00:00	source474	230	655	583	13
429	2017-01-14	moscow, ulica 429	1	2018-02-14 00:00:00	source429	946	449	200	40
299	2018-12-18	moscow, ulica 299	1	2018-07-28 00:00:00	source299	168	218	721	16
863	2017-04-08	moscow, ulica 863	3	2017-05-08 00:00:00	source863	520	81	594	33
335	2017-10-06	moscow, ulica 335	3	2018-02-01 00:00:00	source335	783	1000	685	42
205	2018-03-28	moscow, ulica 205	1	2017-03-07 00:00:00	source205	420	300	278	19
821	2017-03-14	moscow, ulica 821	4	2017-10-30 00:00:00	source821	864	823	415	93
366	2017-11-24	moscow, ulica 366	3	2018-03-31 00:00:00	source366	337	968	757	30
641	2018-02-13	moscow, ulica 641	1	2017-11-22 00:00:00	source641	505	772	899	58
340	2017-12-24	moscow, ulica 340	4	2017-07-14 00:00:00	source340	612	459	942	31
343	2017-07-04	moscow, ulica 343	5	2018-12-12 00:00:00	source343	259	815	570	42
702	2017-03-25	moscow, ulica 702	3	2017-03-28 00:00:00	source702	146	47	740	26
312	2017-06-06	moscow, ulica 312	3	2018-01-25 00:00:00	source312	313	396	734	47
182	2017-02-17	moscow, ulica 182	1	2018-11-21 00:00:00	source182	524	881	422	23
257	2017-04-10	moscow, ulica 257	4	2018-07-14 00:00:00	source257	217	714	175	42
413	2017-02-21	moscow, ulica 413	1	2018-05-17 00:00:00	source413	366	504	510	28
148	2017-01-26	moscow, ulica 148	3	2018-11-12 00:00:00	source148	498	499	332	20
318	2018-01-05	moscow, ulica 318	3	2018-12-19 00:00:00	source318	553	703	166	19
971	2018-11-03	moscow, ulica 971	2	2017-01-27 00:00:00	source971	183	459	452	39
158	2018-04-27	moscow, ulica 158	1	2018-07-27 00:00:00	source158	588	587	310	20
869	2017-07-25	moscow, ulica 869	4	2018-11-27 00:00:00	source869	580	190	717	99
843	2018-09-28	moscow, ulica 843	1	2017-09-22 00:00:00	source843	15	3	656	58
462	2018-09-17	moscow, ulica 462	4	2018-04-05 00:00:00	source462	763	609	483	28
197	2017-01-13	moscow, ulica 197	3	2018-06-23 00:00:00	source197	375	882	605	19
913	2018-04-02	moscow, ulica 913	1	2018-12-12 00:00:00	source913	803	794	2	81
965	2017-03-10	moscow, ulica 965	1	2017-06-24 00:00:00	source965	844	299	141	39
872	2018-06-24	moscow, ulica 872	5	2018-02-24 00:00:00	source872	363	856	435	12
764	2017-06-05	moscow, ulica 764	3	2017-08-20 00:00:00	source764	366	904	232	62
833	2017-10-06	moscow, ulica 833	4	2017-03-30 00:00:00	source833	291	842	908	56
471	2018-08-26	moscow, ulica 471	4	2018-02-11 00:00:00	source471	391	72	14	24
404	2017-10-11	moscow, ulica 404	2	2018-11-12 00:00:00	source404	807	952	623	26
174	2018-04-13	moscow, ulica 174	1	2018-02-08 00:00:00	source174	568	254	646	32
95	2017-08-15	moscow, ulica 95	2	2017-07-10 00:00:00	source95	302	206	168	66
141	2018-05-16	moscow, ulica 141	3	2018-03-06 00:00:00	source141	837	874	726	33
276	2017-07-12	moscow, ulica 276	1	2017-11-11 00:00:00	source276	76	773	756	30
477	2017-09-05	moscow, ulica 477	1	2018-10-29 00:00:00	source477	952	857	721	55
809	2018-06-28	moscow, ulica 809	5	2018-06-28 00:00:00	source809	621	234	847	24
20	2018-10-29	moscow, ulica 20	2	2018-03-08 00:00:00	source20	637	135	936	37
112	2018-02-12	moscow, ulica 112	3	2018-07-28 00:00:00	source112	519	863	550	23
879	2018-05-19	moscow, ulica 879	3	2017-10-01 00:00:00	source879	789	458	812	90
149	2018-11-10	moscow, ulica 149	2	2017-03-31 00:00:00	source149	637	331	355	33
121	2017-12-11	moscow, ulica 121	1	2017-11-20 00:00:00	source121	574	596	732	35
347	2017-03-01	moscow, ulica 347	1	2017-03-23 00:00:00	source347	980	180	134	31
55	2018-03-19	moscow, ulica 55	3	2017-07-10 00:00:00	source55	804	350	583	8
832	2017-07-06	moscow, ulica 832	5	2017-01-22 00:00:00	source832	805	135	665	58
473	2017-11-27	moscow, ulica 473	5	2017-10-27 00:00:00	source473	77	760	329	73
332	2018-06-10	moscow, ulica 332	1	2017-12-21 00:00:00	source332	676	172	673	19
160	2017-04-18	moscow, ulica 160	5	2018-11-06 00:00:00	source160	768	266	20	21
22	2017-12-12	moscow, ulica 22	5	2018-01-04 00:00:00	source22	271	447	677	96
859	2018-09-17	moscow, ulica 859	4	2017-04-14 00:00:00	source859	603	379	731	57
396	2017-09-25	moscow, ulica 396	5	2017-06-06 00:00:00	source396	231	766	581	55
558	2017-04-26	moscow, ulica 558	5	2017-04-28 00:00:00	source558	913	543	155	50
866	2017-07-15	moscow, ulica 866	5	2017-06-06 00:00:00	source866	469	144	73	48
712	2018-12-27	moscow, ulica 712	5	2017-08-03 00:00:00	source712	324	136	441	3
359	2018-10-13	moscow, ulica 359	5	2018-12-26 00:00:00	source359	170	726	668	31
333	2017-07-08	moscow, ulica 333	5	2018-06-16 00:00:00	source333	253	928	366	41
781	2018-04-01	moscow, ulica 781	4	2018-07-16 00:00:00	source781	229	432	877	98
29	2017-11-16	moscow, ulica 29	5	2017-07-09 00:00:00	source29	571	957	797	97
285	2017-02-04	moscow, ulica 285	1	2018-12-17 00:00:00	source285	862	312	520	23
739	2017-09-29	moscow, ulica 739	4	2017-06-25 00:00:00	source739	141	567	933	60
439	2018-01-12	moscow, ulica 439	1	2017-02-18 00:00:00	source439	864	167	133	41
236	2017-07-27	moscow, ulica 236	1	2018-05-26 00:00:00	source236	873	773	618	16
215	2017-07-03	moscow, ulica 215	5	2017-07-27 00:00:00	source215	92	889	897	44
505	2018-04-25	moscow, ulica 505	2	2017-04-25 00:00:00	source505	933	230	868	24
11	2017-02-10	moscow, ulica 11	3	2017-10-02 00:00:00	source11	451	294	875	23
794	2017-11-30	moscow, ulica 794	5	2018-03-03 00:00:00	source794	168	230	780	99
614	2018-05-05	moscow, ulica 614	5	2018-02-25 00:00:00	source614	973	696	913	48
3	2017-01-12	moscow, ulica 3	5	2017-06-01 00:00:00	source3	822	935	153	41
445	2018-12-08	moscow, ulica 445	3	2017-03-21 00:00:00	source445	335	93	952	41
801	2017-02-04	moscow, ulica 801	4	2018-09-26 00:00:00	source801	906	688	635	43
888	2018-10-02	moscow, ulica 888	1	2018-04-16 00:00:00	source888	414	389	387	1
779	2017-10-08	moscow, ulica 779	4	2018-06-20 00:00:00	source779	78	865	29	36
419	2017-11-05	moscow, ulica 419	2	2017-12-21 00:00:00	source419	907	188	690	26
407	2017-10-20	moscow, ulica 407	3	2018-10-10 00:00:00	source407	784	474	336	39
94	2017-07-02	moscow, ulica 94	3	2018-10-03 00:00:00	source94	209	146	897	20
412	2017-10-29	moscow, ulica 412	4	2017-08-18 00:00:00	source412	422	361	48	2
133	2017-11-09	moscow, ulica 133	5	2018-01-12 00:00:00	source133	621	202	483	19
82	2018-06-22	moscow, ulica 82	5	2018-09-11 00:00:00	source82	253	992	722	41
117	2017-09-09	moscow, ulica 117	3	2017-07-21 00:00:00	source117	899	704	629	80
538	2017-09-11	moscow, ulica 538	4	2018-08-13 00:00:00	source538	137	714	732	14
406	2018-02-07	moscow, ulica 406	2	2017-03-06 00:00:00	source406	993	164	312	42
587	2017-05-20	moscow, ulica 587	3	2017-10-08 00:00:00	source587	913	469	709	33
268	2017-12-31	moscow, ulica 268	3	2018-01-03 00:00:00	source268	967	407	581	28
946	2017-04-11	moscow, ulica 946	4	2018-02-08 00:00:00	source946	686	1000	567	83
724	2017-08-22	moscow, ulica 724	3	2017-02-20 00:00:00	source724	303	161	860	45
556	2017-07-06	moscow, ulica 556	5	2018-09-08 00:00:00	source556	323	26	81	34
243	2017-02-02	moscow, ulica 243	4	2018-11-22 00:00:00	source243	464	289	816	17
307	2017-11-02	moscow, ulica 307	3	2018-09-20 00:00:00	source307	378	612	116	31
630	2017-11-02	moscow, ulica 630	1	2017-01-10 00:00:00	source630	268	378	894	14
628	2018-06-26	moscow, ulica 628	4	2018-11-02 00:00:00	source628	869	957	612	32
539	2017-07-05	moscow, ulica 539	5	2017-12-24 00:00:00	source539	25	354	25	32
258	2017-08-23	moscow, ulica 258	5	2017-08-30 00:00:00	source258	590	677	979	28
409	2018-01-07	moscow, ulica 409	3	2018-04-16 00:00:00	source409	169	863	580	36
852	2017-11-01	moscow, ulica 852	1	2017-09-23 00:00:00	source852	834	467	972	69
19	2017-11-07	moscow, ulica 19	3	2018-09-15 00:00:00	source19	832	843	513	80
797	2018-02-15	moscow, ulica 797	2	2018-05-09 00:00:00	source797	472	356	245	81
27	2018-04-25	moscow, ulica 27	1	2017-01-16 00:00:00	source27	342	138	176	23
988	2017-09-17	moscow, ulica 988	5	2017-05-01 00:00:00	source988	636	589	28	78
871	2017-12-21	moscow, ulica 871	3	2017-01-07 00:00:00	source871	755	3	760	57
808	2018-06-02	moscow, ulica 808	5	2017-10-21 00:00:00	source808	9	906	856	99
834	2018-04-16	moscow, ulica 834	4	2018-04-12 00:00:00	source834	888	603	148	33
651	2017-11-13	moscow, ulica 651	1	2018-02-25 00:00:00	source651	291	948	808	65
438	2017-05-06	moscow, ulica 438	3	2018-07-23 00:00:00	source438	340	41	145	24
660	2017-08-08	moscow, ulica 660	1	2018-11-16 00:00:00	source660	28	231	181	44
115	2018-01-26	moscow, ulica 115	4	2017-03-29 00:00:00	source115	408	324	637	18
762	2018-02-23	moscow, ulica 762	3	2018-11-07 00:00:00	source762	368	10	853	45
501	2017-09-25	moscow, ulica 501	2	2017-05-25 00:00:00	source501	255	699	8	19
669	2017-04-13	moscow, ulica 669	1	2018-07-18 00:00:00	source669	800	904	939	26
341	2017-04-04	moscow, ulica 341	5	2017-06-13 00:00:00	source341	781	346	531	39
405	2017-11-19	moscow, ulica 405	5	2017-06-28 00:00:00	source405	381	331	114	37
694	2018-08-23	moscow, ulica 694	3	2017-06-03 00:00:00	source694	228	186	513	39
873	2018-05-01	moscow, ulica 873	4	2017-10-24 00:00:00	source873	874	717	961	55
198	2017-11-25	moscow, ulica 198	1	2017-08-12 00:00:00	source198	314	832	116	31
329	2017-04-07	moscow, ulica 329	4	2018-01-29 00:00:00	source329	64	351	879	27
84	2018-05-05	moscow, ulica 84	3	2017-12-21 00:00:00	source84	462	231	149	95
354	2017-02-01	moscow, ulica 354	2	2018-10-30 00:00:00	source354	480	468	67	39
252	2017-06-22	moscow, ulica 252	5	2018-08-03 00:00:00	source252	975	765	448	90
453	2017-10-24	moscow, ulica 453	2	2018-08-06 00:00:00	source453	594	258	876	32
616	2017-05-22	moscow, ulica 616	4	2018-05-11 00:00:00	source616	7	424	135	30
488	2018-01-15	moscow, ulica 488	3	2017-09-19 00:00:00	source488	927	878	357	47
122	2018-05-10	moscow, ulica 122	5	2018-09-15 00:00:00	source122	411	185	192	81
327	2018-11-09	moscow, ulica 327	1	2018-09-28 00:00:00	source327	892	208	418	32
528	2018-09-09	moscow, ulica 528	2	2017-11-27 00:00:00	source528	398	386	554	33
717	2017-04-27	moscow, ulica 717	2	2017-02-09 00:00:00	source717	264	79	904	52
856	2017-05-12	moscow, ulica 856	4	2018-02-13 00:00:00	source856	912	125	637	55
416	2017-05-17	moscow, ulica 416	5	2017-08-14 00:00:00	source416	270	131	997	76
68	2018-08-24	moscow, ulica 68	1	2017-10-04 00:00:00	source68	641	367	165	95
929	2018-01-16	moscow, ulica 929	2	2017-10-24 00:00:00	source929	961	311	945	66
840	2018-11-13	moscow, ulica 840	5	2018-07-23 00:00:00	source840	491	368	763	16
85	2018-05-07	moscow, ulica 85	3	2017-02-10 00:00:00	source85	181	936	130	16
759	2017-12-06	moscow, ulica 759	1	2018-10-23 00:00:00	source759	978	11	686	99
155	2017-04-14	moscow, ulica 155	2	2018-12-05 00:00:00	source155	209	49	319	17
824	2018-07-17	moscow, ulica 824	2	2018-09-01 00:00:00	source824	185	501	453	24
909	2017-09-17	moscow, ulica 909	4	2018-10-09 00:00:00	source909	511	905	226	65
736	2017-09-08	moscow, ulica 736	3	2018-06-20 00:00:00	source736	748	178	656	40
754	2017-10-27	moscow, ulica 754	2	2017-08-04 00:00:00	source754	512	63	41	26
608	2018-02-05	moscow, ulica 608	2	2018-03-30 00:00:00	source608	536	357	775	44
786	2017-12-25	moscow, ulica 786	3	2017-10-17 00:00:00	source786	99	277	786	76
451	2017-06-26	moscow, ulica 451	5	2017-06-12 00:00:00	source451	551	561	962	33
644	2018-11-12	moscow, ulica 644	4	2017-06-07 00:00:00	source644	687	489	621	99
136	2018-09-29	moscow, ulica 136	1	2017-06-03 00:00:00	source136	422	164	147	30
119	2017-02-03	moscow, ulica 119	1	2018-09-02 00:00:00	source119	927	85	103	95
582	2018-03-13	moscow, ulica 582	3	2017-06-19 00:00:00	source582	32	706	992	73
619	2018-07-03	moscow, ulica 619	3	2017-07-28 00:00:00	source619	311	371	806	72
719	2017-03-11	moscow, ulica 719	4	2018-04-03 00:00:00	source719	213	996	451	85
937	2017-04-28	moscow, ulica 937	4	2018-04-04 00:00:00	source937	203	587	650	94
911	2017-02-01	moscow, ulica 911	3	2017-10-04 00:00:00	source911	681	772	202	1
850	2017-05-29	moscow, ulica 850	2	2017-05-15 00:00:00	source850	941	550	675	51
818	2018-02-22	moscow, ulica 818	5	2018-01-28 00:00:00	source818	596	41	842	83
788	2018-06-09	moscow, ulica 788	3	2018-01-23 00:00:00	source788	820	969	26	83
81	2017-12-24	moscow, ulica 81	2	2017-05-21 00:00:00	source81	360	82	155	17
529	2017-07-09	moscow, ulica 529	3	2018-11-01 00:00:00	source529	899	331	867	74
219	2018-03-06	moscow, ulica 219	2	2018-01-09 00:00:00	source219	375	866	195	29
774	2017-10-17	moscow, ulica 774	2	2018-07-10 00:00:00	source774	309	805	317	53
227	2017-11-30	moscow, ulica 227	1	2017-08-06 00:00:00	source227	181	80	215	71
943	2018-01-22	moscow, ulica 943	5	2017-01-10 00:00:00	source943	595	769	126	52
805	2018-11-27	moscow, ulica 805	1	2018-02-14 00:00:00	source805	820	558	675	55
954	2017-09-28	moscow, ulica 954	4	2018-04-28 00:00:00	source954	556	767	406	12
502	2018-05-02	moscow, ulica 502	1	2018-05-27 00:00:00	source502	192	164	467	79
226	2017-06-14	moscow, ulica 226	4	2018-10-05 00:00:00	source226	875	309	952	28
906	2018-04-26	moscow, ulica 906	5	2018-09-18 00:00:00	source906	685	534	59	1
13	2017-06-01	moscow, ulica 13	2	2017-08-30 00:00:00	source13	257	562	469	16
147	2018-10-09	moscow, ulica 147	2	2017-09-23 00:00:00	source147	562	955	919	91
707	2017-12-06	moscow, ulica 707	5	2017-10-06 00:00:00	source707	416	830	645	85
615	2017-06-26	moscow, ulica 615	3	2017-02-28 00:00:00	source615	775	481	416	45
294	2017-06-17	moscow, ulica 294	1	2018-07-15 00:00:00	source294	868	383	525	26
710	2018-03-15	moscow, ulica 710	4	2018-01-01 00:00:00	source710	761	561	65	66
189	2017-03-10	moscow, ulica 189	2	2017-06-12 00:00:00	source189	790	687	677	90
513	2018-07-17	moscow, ulica 513	2	2018-12-20 00:00:00	source513	457	958	357	72
983	2018-11-15	moscow, ulica 983	3	2018-09-29 00:00:00	source983	277	229	912	62
352	2018-09-24	moscow, ulica 352	5	2017-12-19 00:00:00	source352	48	450	977	65
870	2018-06-19	moscow, ulica 870	3	2018-02-01 00:00:00	source870	952	85	185	36
457	2017-06-14	moscow, ulica 457	4	2017-03-02 00:00:00	source457	298	811	993	77
555	2018-07-16	moscow, ulica 555	5	2017-08-06 00:00:00	source555	889	981	487	46
554	2018-09-21	moscow, ulica 554	2	2017-08-27 00:00:00	source554	595	556	171	46
67	2017-12-24	moscow, ulica 67	5	2018-09-02 00:00:00	source67	448	452	183	93
527	2017-02-21	moscow, ulica 527	5	2017-06-11 00:00:00	source527	632	269	609	72
895	2018-02-03	moscow, ulica 895	5	2018-06-27 00:00:00	source895	898	758	577	52
940	2017-07-22	moscow, ulica 940	2	2018-11-28 00:00:00	source940	547	712	509	51
656	2017-10-08	moscow, ulica 656	2	2018-05-13 00:00:00	source656	937	144	511	84
584	2018-11-21	moscow, ulica 584	4	2017-07-14 00:00:00	source584	430	285	979	73
708	2018-04-15	moscow, ulica 708	1	2018-02-02 00:00:00	source708	382	954	494	23
154	2018-11-21	moscow, ulica 154	2	2017-01-03 00:00:00	source154	498	202	251	31
799	2018-09-09	moscow, ulica 799	2	2018-09-26 00:00:00	source799	209	215	7	54
673	2017-12-06	moscow, ulica 673	3	2018-08-19 00:00:00	source673	730	75	158	40
637	2017-01-08	moscow, ulica 637	5	2018-12-04 00:00:00	source637	32	104	374	45
161	2018-02-04	moscow, ulica 161	3	2018-02-24 00:00:00	source161	957	257	202	31
159	2018-06-19	moscow, ulica 159	3	2017-04-20 00:00:00	source159	993	728	564	31
211	2018-12-02	moscow, ulica 211	2	2018-04-13 00:00:00	source211	362	781	772	69
220	2018-06-04	moscow, ulica 220	1	2017-02-14 00:00:00	source220	968	21	666	38
761	2017-04-10	moscow, ulica 761	4	2018-11-25 00:00:00	source761	489	140	794	8
696	2018-11-13	moscow, ulica 696	2	2018-06-12 00:00:00	source696	328	207	854	10
685	2017-06-20	moscow, ulica 685	3	2018-11-13 00:00:00	source685	46	689	492	28
292	2017-03-07	moscow, ulica 292	4	2017-06-17 00:00:00	source292	171	744	308	39
128	2017-06-02	moscow, ulica 128	5	2018-11-12 00:00:00	source128	438	150	363	88
842	2018-05-08	moscow, ulica 842	5	2017-03-21 00:00:00	source842	201	455	124	74
790	2017-04-04	moscow, ulica 790	4	2017-08-15 00:00:00	source790	830	666	621	97
732	2018-11-26	moscow, ulica 732	4	2018-01-17 00:00:00	source732	884	465	352	71
532	2017-03-02	moscow, ulica 532	5	2017-02-10 00:00:00	source532	143	493	617	17
601	2017-07-28	moscow, ulica 601	4	2018-03-20 00:00:00	source601	243	585	377	42
169	2018-01-30	moscow, ulica 169	2	2018-02-05 00:00:00	source169	234	65	542	91
591	2018-02-06	moscow, ulica 591	5	2017-04-30 00:00:00	source591	326	64	928	87
206	2018-02-24	moscow, ulica 206	1	2017-06-24 00:00:00	source206	244	807	554	38
569	2017-10-31	moscow, ulica 569	2	2017-01-17 00:00:00	source569	599	652	532	19
177	2017-03-04	moscow, ulica 177	4	2018-11-22 00:00:00	source177	592	90	581	17
278	2018-11-09	moscow, ulica 278	2	2017-12-13 00:00:00	source278	351	952	849	37
143	2017-01-02	moscow, ulica 143	5	2017-05-29 00:00:00	source143	10	115	803	68
817	2018-03-20	moscow, ulica 817	3	2017-06-13 00:00:00	source817	15	52	859	57
417	2018-03-08	moscow, ulica 417	1	2017-03-20 00:00:00	source417	181	170	549	68
242	2017-01-24	moscow, ulica 242	3	2017-08-10 00:00:00	source242	237	428	616	69
88	2018-07-08	moscow, ulica 88	3	2017-06-30 00:00:00	source88	954	727	247	91
559	2018-07-09	moscow, ulica 559	2	2017-12-03 00:00:00	source559	348	983	907	32
393	2018-04-17	moscow, ulica 393	2	2018-05-07 00:00:00	source393	851	773	331	46
362	2017-03-05	moscow, ulica 362	3	2018-06-20 00:00:00	source362	361	987	974	26
422	2018-07-16	moscow, ulica 422	3	2017-04-01 00:00:00	source422	299	852	512	33
260	2017-04-29	moscow, ulica 260	3	2017-09-16 00:00:00	source260	282	790	619	22
468	2017-02-14	moscow, ulica 468	5	2018-05-06 00:00:00	source468	927	47	306	4
789	2017-01-23	moscow, ulica 789	1	2017-08-21 00:00:00	source789	204	755	84	53
785	2018-09-25	moscow, ulica 785	5	2017-10-24 00:00:00	source785	267	232	669	22
435	2018-01-15	moscow, ulica 435	1	2018-10-31 00:00:00	source435	20	98	635	32
33	2017-08-01	moscow, ulica 33	5	2017-01-08 00:00:00	source33	250	628	711	1
578	2017-01-27	moscow, ulica 578	3	2017-12-09 00:00:00	source578	359	810	464	79
338	2018-01-07	moscow, ulica 338	5	2017-01-14 00:00:00	source338	991	7	355	20
936	2018-10-30	moscow, ulica 936	5	2018-09-02 00:00:00	source936	211	608	595	53
466	2017-01-27	moscow, ulica 466	5	2017-11-14 00:00:00	source466	85	116	548	34
234	2018-10-03	moscow, ulica 234	1	2017-08-22 00:00:00	source234	88	851	306	66
14	2017-06-18	moscow, ulica 14	2	2018-08-03 00:00:00	source14	669	505	390	90
15	2018-07-01	moscow, ulica 15	3	2018-09-19 00:00:00	source15	387	765	634	1
701	2017-12-12	moscow, ulica 701	5	2018-11-23 00:00:00	source701	201	221	68	84
568	2017-08-10	moscow, ulica 568	3	2017-03-16 00:00:00	source568	212	159	288	72
918	2018-12-22	moscow, ulica 918	1	2017-03-12 00:00:00	source918	71	553	972	63
541	2018-11-04	moscow, ulica 541	5	2017-01-05 00:00:00	source541	923	813	309	73
253	2017-09-30	moscow, ulica 253	5	2017-10-17 00:00:00	source253	838	854	537	10
424	2018-12-01	moscow, ulica 424	1	2018-11-05 00:00:00	source424	19	67	101	18
361	2018-06-08	moscow, ulica 361	2	2018-01-07 00:00:00	source361	447	98	855	35
358	2017-04-29	moscow, ulica 358	1	2018-03-11 00:00:00	source358	563	495	878	76
721	2018-01-30	moscow, ulica 721	1	2017-03-17 00:00:00	source721	726	622	808	81
266	2018-09-20	moscow, ulica 266	2	2017-11-19 00:00:00	source266	808	915	431	34
858	2017-01-31	moscow, ulica 858	3	2017-03-23 00:00:00	source858	485	584	637	20
634	2017-09-11	moscow, ulica 634	4	2018-01-21 00:00:00	source634	567	394	690	49
390	2018-07-28	moscow, ulica 390	4	2017-04-21 00:00:00	source390	807	202	307	35
741	2018-05-05	moscow, ulica 741	5	2017-10-28 00:00:00	source741	330	562	740	42
606	2017-10-24	moscow, ulica 606	2	2018-07-23 00:00:00	source606	192	273	223	40
297	2018-04-05	moscow, ulica 297	1	2018-07-22 00:00:00	source297	978	258	340	65
820	2018-06-30	moscow, ulica 820	4	2017-09-23 00:00:00	source820	907	315	532	62
865	2017-06-23	moscow, ulica 865	3	2018-11-15 00:00:00	source865	934	393	123	92
499	2018-02-05	moscow, ulica 499	3	2018-01-28 00:00:00	source499	898	824	534	75
302	2017-02-25	moscow, ulica 302	5	2018-09-11 00:00:00	source302	291	688	223	51
990	2018-01-09	moscow, ulica 990	4	2018-02-08 00:00:00	source990	887	238	227	53
731	2017-04-26	moscow, ulica 731	3	2017-02-01 00:00:00	source731	778	829	199	2
970	2018-12-04	moscow, ulica 970	4	2018-12-07 00:00:00	source970	560	959	751	34
693	2018-02-24	moscow, ulica 693	3	2019-01-01 00:00:00	source693	722	722	429	39
907	2017-09-01	moscow, ulica 907	1	2017-10-16 00:00:00	source907	624	241	287	66
901	2018-11-13	moscow, ulica 901	1	2018-12-14 00:00:00	source901	830	713	587	9
716	2018-06-18	moscow, ulica 716	4	2018-06-23 00:00:00	source716	633	924	797	94
577	2017-11-21	moscow, ulica 577	4	2017-10-06 00:00:00	source577	678	695	523	7
321	2018-04-15	moscow, ulica 321	4	2018-02-11 00:00:00	source321	680	360	291	21
26	2018-03-31	moscow, ulica 26	2	2017-08-18 00:00:00	source26	162	445	7	71
282	2017-11-10	moscow, ulica 282	1	2018-07-03 00:00:00	source282	365	99	769	51
256	2017-03-19	moscow, ulica 256	4	2017-07-28 00:00:00	source256	233	786	737	76
490	2017-10-06	moscow, ulica 490	3	2017-02-03 00:00:00	source490	610	21	472	24
60	2018-06-09	moscow, ulica 60	5	2018-08-28 00:00:00	source60	415	992	755	9
692	2018-01-27	moscow, ulica 692	5	2018-05-24 00:00:00	source692	795	168	512	27
31	2018-02-22	moscow, ulica 31	1	2017-11-30 00:00:00	source31	51	885	218	15
566	2018-06-27	moscow, ulica 566	2	2017-07-06 00:00:00	source566	669	333	61	31
165	2018-05-28	moscow, ulica 165	5	2018-01-24 00:00:00	source165	400	838	956	67
493	2017-06-28	moscow, ulica 493	3	2017-01-20 00:00:00	source493	269	937	467	73
138	2018-04-11	moscow, ulica 138	2	2017-05-29 00:00:00	source138	619	690	45	67
432	2018-09-24	moscow, ulica 432	4	2018-10-05 00:00:00	source432	8	159	818	74
465	2017-01-03	moscow, ulica 465	4	2018-03-10 00:00:00	source465	179	723	956	73
436	2017-03-05	moscow, ulica 436	5	2018-01-06 00:00:00	source436	665	42	776	31
655	2017-11-04	moscow, ulica 655	2	2018-01-12 00:00:00	source655	791	18	601	69
34	2017-12-26	moscow, ulica 34	2	2017-04-23 00:00:00	source34	463	246	116	40
134	2017-12-19	moscow, ulica 134	3	2018-07-18 00:00:00	source134	593	265	774	53
890	2018-03-05	moscow, ulica 890	2	2017-11-07 00:00:00	source890	479	990	744	14
176	2017-05-25	moscow, ulica 176	4	2018-10-07 00:00:00	source176	179	788	401	66
78	2017-10-04	moscow, ulica 78	4	2017-02-22 00:00:00	source78	673	353	957	69
534	2017-11-20	moscow, ulica 534	3	2017-07-01 00:00:00	source534	690	931	140	57
960	2018-08-01	moscow, ulica 960	4	2017-11-21 00:00:00	source960	875	96	47	40
210	2017-09-18	moscow, ulica 210	4	2017-05-17 00:00:00	source210	918	145	432	51
443	2018-01-11	moscow, ulica 443	5	2017-01-01 00:00:00	source443	164	627	682	74
349	2018-08-02	moscow, ulica 349	2	2017-10-17 00:00:00	source349	582	922	956	21
617	2017-05-30	moscow, ulica 617	2	2018-03-09 00:00:00	source617	627	699	848	82
682	2017-12-01	moscow, ulica 682	4	2018-02-14 00:00:00	source682	121	244	793	80
442	2017-01-13	moscow, ulica 442	1	2017-02-27 00:00:00	source442	685	575	603	60
375	2018-04-08	moscow, ulica 375	5	2018-11-04 00:00:00	source375	2	353	777	62
44	2017-06-17	moscow, ulica 44	4	2017-04-16 00:00:00	source44	174	611	409	40
399	2018-03-13	moscow, ulica 399	4	2018-12-27 00:00:00	source399	627	563	498	55
48	2018-05-03	moscow, ulica 48	5	2018-09-28 00:00:00	source48	911	213	595	43
130	2017-02-09	moscow, ulica 130	1	2017-10-09 00:00:00	source130	398	658	301	65
28	2017-03-06	moscow, ulica 28	2	2017-10-25 00:00:00	source28	329	17	641	68
827	2018-07-04	moscow, ulica 827	3	2017-10-04 00:00:00	source827	894	763	280	92
698	2017-01-20	moscow, ulica 698	5	2018-03-01 00:00:00	source698	416	621	650	24
336	2018-04-14	moscow, ulica 336	2	2017-08-05 00:00:00	source336	729	141	255	19
157	2018-12-07	moscow, ulica 157	2	2017-09-24 00:00:00	source157	545	457	46	52
368	2018-09-27	moscow, ulica 368	2	2017-07-01 00:00:00	source368	400	441	289	77
229	2017-09-30	moscow, ulica 229	3	2018-11-11 00:00:00	source229	502	842	354	50
300	2017-11-09	moscow, ulica 300	3	2017-09-14 00:00:00	source300	825	387	574	79
9	2017-02-19	moscow, ulica 9	3	2017-02-11 00:00:00	source9	573	703	217	13
997	2017-08-19	moscow, ulica 997	5	2018-06-17 00:00:00	source997	118	197	627	33
497	2018-09-24	moscow, ulica 497	4	2018-08-22 00:00:00	source497	612	369	736	59
775	2018-04-13	moscow, ulica 775	3	2018-07-20 00:00:00	source775	266	458	186	1
75	2018-06-30	moscow, ulica 75	5	2017-01-01 00:00:00	source75	964	442	860	52
935	2018-08-27	moscow, ulica 935	3	2017-09-19 00:00:00	source935	494	116	45	97
515	2018-08-06	moscow, ulica 515	5	2017-08-31 00:00:00	source515	140	645	13	85
514	2017-10-25	moscow, ulica 514	5	2017-09-26 00:00:00	source514	975	976	451	85
482	2017-03-29	moscow, ulica 482	4	2018-06-10 00:00:00	source482	857	611	464	30
291	2018-01-21	moscow, ulica 291	2	2018-06-04 00:00:00	source291	551	874	738	20
564	2017-01-11	moscow, ulica 564	4	2017-07-03 00:00:00	source564	206	259	626	52
214	2018-10-31	moscow, ulica 214	1	2018-08-07 00:00:00	source214	439	630	351	48
410	2018-02-15	moscow, ulica 410	4	2018-04-08 00:00:00	source410	500	699	857	58
392	2018-06-16	moscow, ulica 392	3	2017-01-12 00:00:00	source392	319	646	566	86
379	2018-10-29	moscow, ulica 379	5	2017-09-16 00:00:00	source379	218	251	245	62
975	2018-05-14	moscow, ulica 975	5	2018-11-21 00:00:00	source975	294	197	672	78
748	2018-04-13	moscow, ulica 748	3	2017-07-22 00:00:00	source748	63	275	822	3
203	2018-05-09	moscow, ulica 203	4	2017-02-25 00:00:00	source203	620	529	451	76
35	2017-02-23	moscow, ulica 35	2	2018-03-26 00:00:00	source35	214	33	867	69
104	2017-01-12	moscow, ulica 104	4	2017-10-09 00:00:00	source104	62	641	569	11
949	2017-07-08	moscow, ulica 949	5	2017-01-22 00:00:00	source949	499	498	695	13
894	2018-02-11	moscow, ulica 894	3	2018-09-07 00:00:00	source894	736	196	987	90
113	2018-08-26	moscow, ulica 113	2	2017-01-11 00:00:00	source113	251	447	820	10
999	2017-09-01	moscow, ulica 999	2	2017-07-08 00:00:00	source999	299	81	436	99
857	2017-08-28	moscow, ulica 857	2	2017-12-16 00:00:00	source857	509	930	665	100
364	2018-03-22	moscow, ulica 364	2	2018-05-08 00:00:00	source364	46	295	368	60
769	2018-06-23	moscow, ulica 769	2	2018-10-13 00:00:00	source769	765	118	246	12
485	2017-05-27	moscow, ulica 485	1	2018-01-04 00:00:00	source485	944	881	239	31
968	2017-06-01	moscow, ulica 968	1	2018-04-27 00:00:00	source968	250	141	318	7
602	2018-03-11	moscow, ulica 602	5	2018-09-23 00:00:00	source602	868	21	759	64
665	2017-01-28	moscow, ulica 665	5	2017-02-05 00:00:00	source665	741	930	256	48
16	2017-06-10	moscow, ulica 16	2	2018-01-19 00:00:00	source16	957	429	307	55
411	2017-10-24	moscow, ulica 411	3	2018-09-13 00:00:00	source411	112	393	490	59
430	2017-12-25	moscow, ulica 430	4	2017-07-08 00:00:00	source430	684	437	815	40
467	2018-12-02	moscow, ulica 467	3	2018-08-13 00:00:00	source467	764	253	308	29
689	2018-07-18	moscow, ulica 689	1	2018-06-07 00:00:00	source689	924	181	894	48
97	2017-07-11	moscow, ulica 97	2	2017-09-14 00:00:00	source97	950	532	431	96
387	2018-05-12	moscow, ulica 387	1	2018-12-13 00:00:00	source387	418	452	716	59
678	2017-09-17	moscow, ulica 678	4	2017-05-17 00:00:00	source678	274	692	940	78
356	2017-04-29	moscow, ulica 356	2	2017-06-14 00:00:00	source356	34	101	346	60
815	2018-02-01	moscow, ulica 815	4	2017-09-25 00:00:00	source815	983	501	878	11
963	2018-11-13	moscow, ulica 963	5	2018-07-28 00:00:00	source963	144	327	221	44
525	2017-08-21	moscow, ulica 525	2	2018-08-14 00:00:00	source525	236	850	949	66
458	2018-04-22	moscow, ulica 458	5	2017-11-05 00:00:00	source458	262	21	798	68
213	2017-07-10	moscow, ulica 213	4	2017-02-08 00:00:00	source213	109	944	710	20
838	2018-01-28	moscow, ulica 838	1	2018-12-27 00:00:00	source838	80	798	917	11
384	2017-01-22	moscow, ulica 384	2	2018-03-21 00:00:00	source384	7	458	459	31
146	2017-12-13	moscow, ulica 146	1	2017-08-07 00:00:00	source146	145	635	720	97
565	2017-06-15	moscow, ulica 565	5	2018-05-07 00:00:00	source565	402	589	865	35
508	2018-05-26	moscow, ulica 508	5	2018-12-01 00:00:00	source508	307	203	963	57
573	2017-12-08	moscow, ulica 573	2	2017-09-18 00:00:00	source573	567	948	648	7
585	2018-03-20	moscow, ulica 585	5	2018-05-11 00:00:00	source585	112	859	252	25
847	2018-12-15	moscow, ulica 847	4	2017-12-30 00:00:00	source847	446	737	681	85
546	2018-04-02	moscow, ulica 546	3	2017-06-21 00:00:00	source546	928	504	266	4
816	2018-12-14	moscow, ulica 816	5	2017-07-07 00:00:00	source816	130	71	224	6
346	2017-01-04	moscow, ulica 346	2	2018-04-01 00:00:00	source346	238	850	421	58
572	2018-10-30	moscow, ulica 572	5	2018-03-13 00:00:00	source572	240	520	876	13
667	2018-12-12	moscow, ulica 667	4	2017-09-06 00:00:00	source667	846	855	438	22
984	2018-02-10	moscow, ulica 984	5	2017-05-15 00:00:00	source984	966	586	263	1
980	2018-01-11	moscow, ulica 980	5	2017-07-02 00:00:00	source980	584	33	891	97
293	2017-06-08	moscow, ulica 293	4	2018-07-11 00:00:00	source293	839	437	480	63
854	2017-07-09	moscow, ulica 854	5	2018-04-24 00:00:00	source854	731	847	608	10
958	2018-04-04	moscow, ulica 958	3	2018-02-13 00:00:00	source958	123	866	352	11
626	2017-02-24	moscow, ulica 626	1	2018-03-30 00:00:00	source626	315	632	338	5
605	2017-04-19	moscow, ulica 605	3	2017-04-05 00:00:00	source605	687	814	538	93
209	2018-07-20	moscow, ulica 209	2	2017-05-07 00:00:00	source209	720	216	790	58
851	2018-01-23	moscow, ulica 851	3	2017-02-21 00:00:00	source851	787	232	408	88
12	2018-10-12	moscow, ulica 12	2	2018-09-22 00:00:00	source12	28	550	970	53
757	2018-09-13	moscow, ulica 757	5	2018-03-04 00:00:00	source757	989	772	38	76
172	2017-05-10	moscow, ulica 172	2	2017-04-07 00:00:00	source172	707	965	730	48
792	2018-07-19	moscow, ulica 792	1	2017-10-23 00:00:00	source792	678	576	624	77
686	2017-03-02	moscow, ulica 686	3	2017-03-10 00:00:00	source686	257	170	174	64
425	2018-12-29	moscow, ulica 425	4	2018-05-12 00:00:00	source425	536	682	619	31
795	2017-05-29	moscow, ulica 795	4	2017-11-02 00:00:00	source795	33	325	973	62
168	2018-02-07	moscow, ulica 168	5	2018-12-18 00:00:00	source168	135	632	264	37
947	2017-07-25	moscow, ulica 947	3	2017-07-17 00:00:00	source947	377	718	104	72
102	2018-02-13	moscow, ulica 102	2	2017-02-26 00:00:00	source102	214	190	824	58
914	2018-11-08	moscow, ulica 914	3	2018-04-10 00:00:00	source914	635	683	855	9
846	2018-01-31	moscow, ulica 846	3	2018-08-18 00:00:00	source846	28	416	246	87
237	2017-07-06	moscow, ulica 237	3	2018-02-19 00:00:00	source237	7	532	58	6
190	2017-06-27	moscow, ulica 190	2	2017-06-21 00:00:00	source190	121	896	680	37
195	2018-12-13	moscow, ulica 195	1	2017-10-01 00:00:00	source195	776	457	423	33
521	2018-06-30	moscow, ulica 521	2	2019-01-01 00:00:00	source521	822	525	916	5
58	2017-08-27	moscow, ulica 58	5	2017-12-12 00:00:00	source58	408	868	352	24
162	2018-12-10	moscow, ulica 162	1	2018-04-21 00:00:00	source162	642	336	560	48
593	2017-07-22	moscow, ulica 593	4	2017-04-13 00:00:00	source593	324	172	519	11
400	2018-10-26	moscow, ulica 400	1	2017-09-03 00:00:00	source400	439	937	37	57
223	2017-05-28	moscow, ulica 223	3	2017-01-03 00:00:00	source223	565	50	227	7
441	2018-02-11	moscow, ulica 441	5	2017-01-02 00:00:00	source441	412	18	95	96
622	2018-02-18	moscow, ulica 622	3	2018-03-18 00:00:00	source622	69	392	487	11
771	2018-03-03	moscow, ulica 771	1	2018-09-06 00:00:00	source771	3	708	665	15
37	2017-03-31	moscow, ulica 37	2	2017-11-23 00:00:00	source37	776	454	446	53
464	2018-10-26	moscow, ulica 464	5	2017-02-22 00:00:00	source464	286	966	951	66
317	2018-07-31	moscow, ulica 317	4	2018-06-01 00:00:00	source317	341	675	704	100
180	2018-01-05	moscow, ulica 180	2	2017-04-30 00:00:00	source180	157	103	428	49
632	2017-10-12	moscow, ulica 632	3	2017-06-25 00:00:00	source632	142	373	24	52
310	2018-04-25	moscow, ulica 310	2	2017-12-12 00:00:00	source310	109	161	223	61
45	2017-03-13	moscow, ulica 45	3	2017-07-10 00:00:00	source45	451	607	434	53
382	2017-10-15	moscow, ulica 382	2	2017-06-25 00:00:00	source382	65	285	126	59
517	2017-03-17	moscow, ulica 517	3	2017-06-12 00:00:00	source517	720	281	552	3
811	2017-06-13	moscow, ulica 811	2	2018-05-12 00:00:00	source811	21	265	704	10
991	2017-02-19	moscow, ulica 991	5	2018-11-14 00:00:00	source991	837	31	338	69
323	2018-04-04	moscow, ulica 323	1	2017-03-16 00:00:00	source323	652	464	100	56
891	2017-01-17	moscow, ulica 891	5	2017-10-17 00:00:00	source891	7	541	867	33
446	2018-01-09	moscow, ulica 446	1	2018-06-22 00:00:00	source446	441	555	369	68
760	2018-01-07	moscow, ulica 760	3	2017-12-25 00:00:00	source760	783	186	93	37
862	2018-01-05	moscow, ulica 862	1	2018-03-24 00:00:00	source862	584	851	20	69
998	2017-04-11	moscow, ulica 998	3	2017-10-01 00:00:00	source998	501	724	570	86
985	2018-09-07	moscow, ulica 985	2	2017-06-29 00:00:00	source985	168	650	680	5
621	2017-06-17	moscow, ulica 621	4	2018-01-12 00:00:00	source621	211	400	253	78
588	2017-01-30	moscow, ulica 588	5	2018-05-30 00:00:00	source588	394	143	226	79
715	2018-05-24	moscow, ulica 715	4	2017-02-15 00:00:00	source715	827	846	868	48
920	2017-11-11	moscow, ulica 920	3	2017-05-02 00:00:00	source920	272	900	1	17
623	2017-06-15	moscow, ulica 623	5	2018-09-21 00:00:00	source623	742	981	635	78
987	2017-04-12	moscow, ulica 987	3	2018-02-02 00:00:00	source987	701	505	987	83
738	2017-06-22	moscow, ulica 738	4	2017-02-15 00:00:00	source738	542	199	509	88
398	2017-10-08	moscow, ulica 398	1	2017-12-24 00:00:00	source398	934	508	445	69
703	2017-09-12	moscow, ulica 703	2	2018-07-24 00:00:00	source703	555	549	654	14
676	2017-07-26	moscow, ulica 676	4	2018-01-23 00:00:00	source676	253	493	177	83
647	2018-11-07	moscow, ulica 647	5	2018-12-08 00:00:00	source647	582	861	243	12
646	2017-07-30	moscow, ulica 646	2	2018-04-15 00:00:00	source646	350	19	672	12
179	2018-11-16	moscow, ulica 179	2	2017-12-12 00:00:00	source179	676	248	104	62
277	2017-09-24	moscow, ulica 277	2	2018-06-20 00:00:00	source277	726	464	36	70
264	2017-05-19	moscow, ulica 264	5	2017-08-05 00:00:00	source264	236	151	451	98
381	2018-09-19	moscow, ulica 381	2	2018-11-05 00:00:00	source381	130	600	70	56
116	2018-10-22	moscow, ulica 116	2	2017-10-21 00:00:00	source116	955	526	866	48
76	2017-09-08	moscow, ulica 76	4	2018-06-09 00:00:00	source76	513	200	667	61
24	2017-12-09	moscow, ulica 24	1	2018-07-12 00:00:00	source24	334	954	556	50
365	2017-05-20	moscow, ulica 365	3	2018-12-09 00:00:00	source365	961	176	742	4
185	2017-12-30	moscow, ulica 185	3	2017-02-06 00:00:00	source185	220	581	708	49
64	2018-10-19	moscow, ulica 64	1	2018-07-04 00:00:00	source64	101	683	674	49
886	2018-07-03	moscow, ulica 886	1	2018-12-11 00:00:00	source886	120	175	310	8
860	2017-01-04	moscow, ulica 860	2	2017-06-25 00:00:00	source860	140	633	380	9
652	2018-03-11	moscow, ulica 652	2	2018-12-18 00:00:00	source652	547	725	243	75
96	2018-03-29	moscow, ulica 96	1	2017-11-29 00:00:00	source96	355	258	254	48
853	2017-03-13	moscow, ulica 853	2	2018-02-04 00:00:00	source853	523	418	110	84
796	2017-07-29	moscow, ulica 796	2	2017-05-02 00:00:00	source796	469	311	511	11
953	2017-03-02	moscow, ulica 953	4	2017-12-26 00:00:00	source953	321	924	600	77
867	2018-01-23	moscow, ulica 867	1	2017-07-02 00:00:00	source867	952	424	366	64
221	2018-06-10	moscow, ulica 221	5	2017-10-19 00:00:00	source221	872	158	157	45
822	2017-10-07	moscow, ulica 822	2	2018-03-02 00:00:00	source822	657	338	564	59
355	2017-12-02	moscow, ulica 355	5	2018-06-15 00:00:00	source355	756	233	263	97
645	2017-12-21	moscow, ulica 645	5	2017-10-16 00:00:00	source645	638	866	83	24
232	2018-07-30	moscow, ulica 232	3	2017-09-07 00:00:00	source232	585	382	474	45
883	2018-09-01	moscow, ulica 883	5	2018-06-13 00:00:00	source883	348	50	206	11
306	2017-02-08	moscow, ulica 306	5	2017-09-10 00:00:00	source306	550	24	307	22
967	2017-09-22	moscow, ulica 967	1	2018-07-07 00:00:00	source967	596	677	375	17
951	2017-09-18	moscow, ulica 951	2	2017-05-02 00:00:00	source951	652	306	534	63
273	2018-07-23	moscow, ulica 273	2	2017-08-03 00:00:00	source273	233	2	131	43
887	2017-10-11	moscow, ulica 887	3	2018-10-05 00:00:00	source887	431	647	542	19
110	2018-05-24	moscow, ulica 110	2	2018-10-07 00:00:00	source110	357	503	685	32
523	2018-11-14	moscow, ulica 523	4	2018-09-02 00:00:00	source523	428	408	385	76
925	2017-07-31	moscow, ulica 925	3	2018-06-03 00:00:00	source925	956	728	765	18
377	2017-03-15	moscow, ulica 377	2	2018-10-31 00:00:00	source377	469	489	660	40
981	2018-11-29	moscow, ulica 981	3	2017-05-12 00:00:00	source981	511	827	44	58
549	2018-10-15	moscow, ulica 549	5	2018-08-09 00:00:00	source549	475	237	461	51
325	2018-06-02	moscow, ulica 325	1	2017-07-17 00:00:00	source325	529	669	514	69
810	2018-01-26	moscow, ulica 810	1	2018-04-01 00:00:00	source810	224	426	368	22
151	2017-07-01	moscow, ulica 151	3	2018-06-19 00:00:00	source151	165	689	712	58
563	2017-08-04	moscow, ulica 563	1	2018-08-24 00:00:00	source563	839	575	601	78
876	2018-10-14	moscow, ulica 876	5	2018-10-07 00:00:00	source876	753	106	905	27
280	2017-07-04	moscow, ulica 280	2	2018-01-26 00:00:00	source280	503	813	566	6
752	2017-08-23	moscow, ulica 752	1	2018-12-24 00:00:00	source752	605	69	132	27
272	2017-04-08	moscow, ulica 272	4	2017-06-28 00:00:00	source272	870	66	402	71
607	2017-11-07	moscow, ulica 607	3	2017-09-23 00:00:00	source607	334	68	386	74
372	2017-05-30	moscow, ulica 372	4	2018-01-02 00:00:00	source372	216	774	104	41
244	2018-01-25	moscow, ulica 244	2	2017-02-24 00:00:00	source244	201	737	775	52
267	2017-04-22	moscow, ulica 267	5	2017-04-03 00:00:00	source267	180	802	621	86
575	2018-06-27	moscow, ulica 575	2	2018-09-22 00:00:00	source575	358	993	627	58
550	2017-05-14	moscow, ulica 550	3	2017-11-17 00:00:00	source550	248	254	864	76
643	2018-08-15	moscow, ulica 643	5	2018-06-30 00:00:00	source643	532	88	922	61
705	2017-10-27	moscow, ulica 705	1	2017-01-25 00:00:00	source705	900	961	419	28
193	2017-11-17	moscow, ulica 193	4	2018-07-23 00:00:00	source193	636	80	531	71
956	2017-06-09	moscow, ulica 956	2	2018-07-10 00:00:00	source956	229	538	687	26
959	2017-03-03	moscow, ulica 959	3	2018-06-05 00:00:00	source959	206	699	379	33
54	2018-05-15	moscow, ulica 54	2	2018-04-10 00:00:00	source54	92	233	989	35
756	2017-03-23	moscow, ulica 756	5	2018-06-23 00:00:00	source756	136	285	544	30
962	2018-01-14	moscow, ulica 962	5	2017-07-27 00:00:00	source962	606	189	55	23
594	2018-08-15	moscow, ulica 594	3	2018-09-05 00:00:00	source594	754	583	467	19
780	2018-09-15	moscow, ulica 780	4	2017-11-07 00:00:00	source780	16	672	292	6
415	2018-10-21	moscow, ulica 415	4	2017-02-06 00:00:00	source415	749	905	968	5
447	2018-09-20	moscow, ulica 447	3	2017-01-13 00:00:00	source447	390	38	128	83
875	2018-06-25	moscow, ulica 875	3	2018-07-13 00:00:00	source875	680	192	474	99
723	2018-02-27	moscow, ulica 723	3	2018-04-02 00:00:00	source723	613	267	220	88
526	2017-09-02	moscow, ulica 526	5	2017-07-22 00:00:00	source526	205	297	368	62
371	2018-02-27	moscow, ulica 371	1	2018-05-04 00:00:00	source371	165	101	299	69
598	2017-06-15	moscow, ulica 598	3	2017-08-25 00:00:00	source598	999	10	83	60
503	2017-11-06	moscow, ulica 503	4	2018-02-05 00:00:00	source503	371	77	228	2
668	2017-01-05	moscow, ulica 668	3	2017-08-20 00:00:00	source668	701	802	148	58
978	2017-05-24	moscow, ulica 978	2	2017-10-21 00:00:00	source978	433	147	42	83
109	2017-02-27	moscow, ulica 109	5	2017-02-22 00:00:00	source109	691	956	738	46
758	2017-08-07	moscow, ulica 758	3	2017-01-12 00:00:00	source758	672	763	721	36
624	2018-12-07	moscow, ulica 624	1	2018-10-21 00:00:00	source624	651	559	666	88
687	2017-11-23	moscow, ulica 687	5	2017-08-25 00:00:00	source687	350	290	728	15
507	2017-09-22	moscow, ulica 507	3	2018-07-01 00:00:00	source507	175	642	525	50
283	2017-05-09	moscow, ulica 283	4	2017-09-08 00:00:00	source283	55	862	995	41
836	2018-09-30	moscow, ulica 836	5	2017-05-18 00:00:00	source836	978	794	18	46
711	2017-04-23	moscow, ulica 711	4	2017-11-24 00:00:00	source711	548	307	278	21
426	2018-01-28	moscow, ulica 426	1	2017-11-28 00:00:00	source426	169	847	500	64
440	2018-03-31	moscow, ulica 440	4	2018-10-03 00:00:00	source440	423	251	105	94
681	2017-11-07	moscow, ulica 681	2	2017-07-06 00:00:00	source681	480	735	348	61
706	2017-11-02	moscow, ulica 706	2	2017-11-15 00:00:00	source706	102	749	291	34
778	2018-07-31	moscow, ulica 778	2	2017-08-05 00:00:00	source778	565	205	601	35
331	2018-04-03	moscow, ulica 331	1	2018-12-27 00:00:00	source331	713	267	528	67
181	2017-02-11	moscow, ulica 181	2	2017-01-17 00:00:00	source181	79	234	233	63
230	2018-07-09	moscow, ulica 230	4	2018-09-29 00:00:00	source230	294	89	507	40
284	2017-07-22	moscow, ulica 284	3	2018-07-11 00:00:00	source284	669	607	659	82
228	2018-03-03	moscow, ulica 228	2	2018-01-21 00:00:00	source228	675	506	428	40
957	2018-10-17	moscow, ulica 957	5	2017-06-29 00:00:00	source957	103	133	39	49
770	2017-03-03	moscow, ulica 770	2	2018-11-13 00:00:00	source770	505	807	575	82
353	2018-05-08	moscow, ulica 353	5	2018-08-23 00:00:00	source353	563	161	751	80
437	2018-12-16	moscow, ulica 437	5	2018-05-22 00:00:00	source437	499	64	136	50
654	2018-09-17	moscow, ulica 654	5	2017-03-16 00:00:00	source654	979	519	693	1
140	2017-12-24	moscow, ulica 140	1	2017-04-28 00:00:00	source140	412	960	62	43
316	2018-02-09	moscow, ulica 316	4	2017-08-06 00:00:00	source316	470	64	134	10
290	2018-07-25	moscow, ulica 290	5	2018-06-04 00:00:00	source290	804	660	484	82
201	2018-03-16	moscow, ulica 201	4	2017-10-09 00:00:00	source201	311	233	718	82
666	2018-05-03	moscow, ulica 666	5	2018-12-14 00:00:00	source666	926	514	432	79
841	2018-01-22	moscow, ulica 841	3	2017-04-10 00:00:00	source841	938	237	39	78
235	2018-11-12	moscow, ulica 235	1	2017-06-10 00:00:00	source235	663	732	284	85
966	2018-12-07	moscow, ulica 966	2	2017-03-11 00:00:00	source966	721	662	709	45
483	2017-02-11	moscow, ulica 483	5	2017-03-06 00:00:00	source483	235	931	686	48
927	2017-08-20	moscow, ulica 927	4	2018-01-05 00:00:00	source927	806	536	764	84
41	2017-08-02	moscow, ulica 41	3	2018-06-27 00:00:00	source41	455	943	740	75
369	2017-06-24	moscow, ulica 369	2	2018-03-22 00:00:00	source369	99	316	743	81
153	2018-11-15	moscow, ulica 153	4	2018-11-09 00:00:00	source153	991	821	604	99
938	2018-03-04	moscow, ulica 938	4	2017-01-01 00:00:00	source938	515	360	457	44
727	2018-01-22	moscow, ulica 727	4	2018-11-04 00:00:00	source727	15	240	928	69
414	2018-05-16	moscow, ulica 414	1	2017-06-18 00:00:00	source414	840	433	379	95
561	2017-04-17	moscow, ulica 561	1	2018-11-09 00:00:00	source561	902	1	603	63
807	2018-01-22	moscow, ulica 807	3	2017-04-25 00:00:00	source807	735	55	343	38
828	2018-11-09	moscow, ulica 828	1	2018-09-15 00:00:00	source828	825	918	891	7
334	2018-06-24	moscow, ulica 334	5	2017-10-23 00:00:00	source334	166	112	385	50
255	2017-02-18	moscow, ulica 255	4	2017-10-17 00:00:00	source255	804	827	878	12
360	2018-09-12	moscow, ulica 360	3	2018-04-10 00:00:00	source360	33	585	182	81
595	2018-10-02	moscow, ulica 595	4	2017-07-17 00:00:00	source595	446	873	230	18
344	2017-10-22	moscow, ulica 344	3	2017-10-17 00:00:00	source344	167	802	514	53
145	2017-12-15	moscow, ulica 145	2	2017-12-24 00:00:00	source145	362	282	395	43
496	2018-04-25	moscow, ulica 496	5	2018-02-11 00:00:00	source496	952	174	844	90
42	2017-02-11	moscow, ulica 42	4	2018-11-10 00:00:00	source42	225	338	996	46
612	2017-10-11	moscow, ulica 612	3	2018-08-06 00:00:00	source612	111	890	699	61
743	2018-07-01	moscow, ulica 743	3	2018-06-27 00:00:00	source743	954	898	275	57
631	2018-01-30	moscow, ulica 631	3	2018-10-26 00:00:00	source631	84	147	717	38
737	2017-06-10	moscow, ulica 737	3	2017-09-22 00:00:00	source737	491	430	725	93
246	2017-12-10	moscow, ulica 246	2	2018-09-26 00:00:00	source246	840	993	674	96
636	2018-02-16	moscow, ulica 636	1	2017-12-13 00:00:00	source636	627	53	269	38
613	2018-02-06	moscow, ulica 613	3	2018-12-31 00:00:00	source613	677	839	361	61
844	2018-08-07	moscow, ulica 844	5	2018-09-29 00:00:00	source844	124	666	960	92
288	2018-03-08	moscow, ulica 288	5	2017-11-27 00:00:00	source288	559	999	270	55
697	2017-03-15	moscow, ulica 697	3	2018-02-28 00:00:00	source697	55	351	465	30
380	2018-09-24	moscow, ulica 380	1	2018-04-29 00:00:00	source380	288	279	7	78
881	2018-01-21	moscow, ulica 881	1	2017-04-04 00:00:00	source881	210	934	543	39
281	2018-06-28	moscow, ulica 281	5	2018-07-01 00:00:00	source281	186	582	420	80
874	2017-03-18	moscow, ulica 874	2	2017-08-09 00:00:00	source874	497	486	31	46
373	2018-07-04	moscow, ulica 373	4	2018-05-08 00:00:00	source373	347	550	522	65
923	2018-02-26	moscow, ulica 923	2	2018-03-15 00:00:00	source923	651	667	859	69
747	2018-07-13	moscow, ulica 747	1	2017-06-09 00:00:00	source747	727	718	259	34
800	2018-05-11	moscow, ulica 800	2	2017-03-07 00:00:00	source800	318	947	805	5
733	2017-04-21	moscow, ulica 733	1	2017-09-17 00:00:00	source733	113	450	482	7
367	2018-05-16	moscow, ulica 367	3	2017-08-12 00:00:00	source367	555	211	634	50
948	2017-03-31	moscow, ulica 948	4	2017-06-13 00:00:00	source948	98	349	190	44
772	2017-10-22	moscow, ulica 772	3	2017-10-23 00:00:00	source772	855	354	637	2
342	2018-02-28	moscow, ulica 342	3	2017-08-16 00:00:00	source342	522	239	297	13
4	2018-07-22	moscow, ulica 4	1	2017-09-14 00:00:00	source4	136	789	269	100
240	2017-12-18	moscow, ulica 240	4	2018-06-30 00:00:00	source240	58	25	795	26
950	2018-11-05	moscow, ulica 950	3	2018-02-03 00:00:00	source950	803	682	362	87
475	2018-06-22	moscow, ulica 475	1	2017-10-19 00:00:00	source475	84	345	184	62
135	2018-10-30	moscow, ulica 135	3	2018-03-23 00:00:00	source135	328	892	807	82
926	2018-06-21	moscow, ulica 926	2	2017-10-24 00:00:00	source926	591	437	875	42
216	2018-02-13	moscow, ulica 216	2	2018-03-20 00:00:00	source216	238	772	298	54
699	2017-01-26	moscow, ulica 699	3	2018-05-06 00:00:00	source699	188	258	546	37
782	2018-06-27	moscow, ulica 782	4	2018-08-27 00:00:00	source782	571	886	969	25
23	2017-08-28	moscow, ulica 23	5	2018-10-06 00:00:00	source23	515	691	172	44
57	2017-03-26	moscow, ulica 57	5	2018-12-27 00:00:00	source57	260	967	244	92
222	2017-03-19	moscow, ulica 222	3	2017-05-01 00:00:00	source222	921	857	518	54
674	2017-01-09	moscow, ulica 674	4	2018-01-05 00:00:00	source674	409	556	510	34
249	2018-02-27	moscow, ulica 249	2	2018-02-20 00:00:00	source249	821	819	285	82
659	2017-06-19	moscow, ulica 659	3	2018-01-31 00:00:00	source659	602	571	975	30
460	2017-10-08	moscow, ulica 460	3	2017-09-04 00:00:00	source460	369	813	506	60
269	2017-11-30	moscow, ulica 269	3	2018-12-27 00:00:00	source269	572	340	878	50
574	2018-05-05	moscow, ulica 574	2	2017-01-11 00:00:00	source574	186	696	254	100
129	2017-06-21	moscow, ulica 129	2	2018-07-30 00:00:00	source129	704	678	775	29
2	2018-01-31	moscow, ulica 2	5	2017-06-21 00:00:00	source2	806	958	62	42
449	2017-06-21	moscow, ulica 449	1	2017-08-05 00:00:00	source449	640	506	856	100
763	2018-11-27	moscow, ulica 763	4	2017-10-07 00:00:00	source763	455	13	983	7
207	2017-10-09	moscow, ulica 207	1	2017-12-06 00:00:00	source207	676	921	655	10
755	2018-10-31	moscow, ulica 755	2	2017-11-18 00:00:00	source755	659	833	29	35
916	2017-01-07	moscow, ulica 916	4	2017-05-23 00:00:00	source916	799	209	252	35
70	2018-11-06	moscow, ulica 70	4	2018-01-26 00:00:00	source70	85	403	961	85
315	2017-12-02	moscow, ulica 315	3	2018-10-14 00:00:00	source315	775	803	863	52
46	2017-11-10	moscow, ulica 46	4	2018-01-01 00:00:00	source46	991	994	141	17
729	2017-12-19	moscow, ulica 729	4	2017-10-20 00:00:00	source729	24	438	152	91
17	2018-02-05	moscow, ulica 17	3	2017-12-18 00:00:00	source17	158	855	145	45
900	2018-08-04	moscow, ulica 900	5	2017-12-31 00:00:00	source900	121	762	12	40
592	2018-11-04	moscow, ulica 592	3	2017-04-11 00:00:00	source592	645	391	57	95
247	2018-05-29	moscow, ulica 247	3	2018-07-02 00:00:00	source247	636	142	834	27
861	2017-02-02	moscow, ulica 861	5	2018-05-29 00:00:00	source861	959	379	480	93
99	2018-06-04	moscow, ulica 99	3	2017-08-21 00:00:00	source99	875	804	716	40
952	2018-02-26	moscow, ulica 952	2	2018-11-28 00:00:00	source952	989	738	904	96
922	2017-05-27	moscow, ulica 922	4	2017-08-28 00:00:00	source922	270	850	648	25
199	2018-07-22	moscow, ulica 199	4	2017-09-06 00:00:00	source199	300	870	981	24
163	2018-11-29	moscow, ulica 163	5	2017-06-12 00:00:00	source163	356	508	690	29
964	2018-08-18	moscow, ulica 964	4	2017-08-06 00:00:00	source964	235	502	639	10
910	2017-05-19	moscow, ulica 910	4	2017-10-07 00:00:00	source910	461	861	26	36
100	2017-09-19	moscow, ulica 100	1	2018-10-17 00:00:00	source100	949	155	324	40
239	2018-02-16	moscow, ulica 239	2	2018-07-02 00:00:00	source239	152	80	591	52
59	2017-09-26	moscow, ulica 59	2	2018-01-30 00:00:00	source59	285	66	307	73
596	2018-10-28	moscow, ulica 596	2	2018-05-22 00:00:00	source596	999	190	701	37
793	2017-02-19	moscow, ulica 793	4	2017-08-15 00:00:00	source793	525	7	431	47
898	2018-12-08	moscow, ulica 898	5	2018-02-21 00:00:00	source898	651	771	854	37
301	2017-06-23	moscow, ulica 301	2	2018-03-25 00:00:00	source301	745	871	841	95
403	2018-04-23	moscow, ulica 403	1	2017-04-02 00:00:00	source403	995	786	664	61
835	2017-05-06	moscow, ulica 835	4	2018-08-18 00:00:00	source835	211	702	22	26
385	2018-08-25	moscow, ulica 385	5	2018-02-04 00:00:00	source385	518	915	354	99
124	2017-02-17	moscow, ulica 124	2	2018-02-21 00:00:00	source124	66	848	898	64
86	2018-03-10	moscow, ulica 86	4	2017-03-25 00:00:00	source86	273	248	726	29
658	2017-09-29	moscow, ulica 658	2	2017-04-30 00:00:00	source658	1	820	21	92
557	2018-05-11	moscow, ulica 557	3	2017-10-31 00:00:00	source557	64	884	830	58
296	2017-07-18	moscow, ulica 296	5	2017-07-07 00:00:00	source296	162	939	869	15
579	2018-11-08	moscow, ulica 579	1	2018-05-28 00:00:00	source579	585	740	377	35
713	2017-04-17	moscow, ulica 713	1	2018-02-10 00:00:00	source713	113	959	322	19
649	2017-09-19	moscow, ulica 649	1	2018-11-06 00:00:00	source649	958	657	586	95
322	2017-08-31	moscow, ulica 322	4	2018-04-21 00:00:00	source322	527	943	913	15
418	2017-04-04	moscow, ulica 418	5	2018-02-01 00:00:00	source418	693	218	677	12
456	2017-08-04	moscow, ulica 456	2	2018-09-10 00:00:00	source456	789	501	771	38
389	2017-11-10	moscow, ulica 389	4	2018-04-07 00:00:00	source389	199	190	361	88
903	2018-11-09	moscow, ulica 903	2	2017-06-20 00:00:00	source903	666	424	811	39
261	2017-08-03	moscow, ulica 261	3	2018-08-24 00:00:00	source261	880	331	791	92
751	2018-10-17	moscow, ulica 751	4	2018-05-15 00:00:00	source751	226	224	540	16
127	2017-01-17	moscow, ulica 127	1	2018-05-20 00:00:00	source127	461	171	527	57
662	2017-10-08	moscow, ulica 662	5	2017-08-07 00:00:00	source662	467	597	392	32
661	2018-03-15	moscow, ulica 661	5	2018-10-21 00:00:00	source661	310	764	758	32
295	2017-04-03	moscow, ulica 295	2	2018-09-19 00:00:00	source295	35	473	92	95
56	2018-09-14	moscow, ulica 56	4	2017-10-26 00:00:00	source56	167	803	938	18
72	2018-10-23	moscow, ulica 72	3	2017-03-01 00:00:00	source72	36	387	56	83
461	2017-03-03	moscow, ulica 461	2	2017-02-21 00:00:00	source461	88	489	832	85
969	2018-12-05	moscow, ulica 969	4	2018-08-15 00:00:00	source969	66	869	855	24
480	2017-01-17	moscow, ulica 480	4	2017-06-21 00:00:00	source480	308	460	388	36
996	2018-11-12	moscow, ulica 996	4	2017-09-11 00:00:00	source996	129	903	488	2
259	2017-04-20	moscow, ulica 259	1	2018-03-10 00:00:00	source259	936	268	976	90
536	2018-12-09	moscow, ulica 536	2	2018-12-18 00:00:00	source536	617	811	156	8
576	2017-10-27	moscow, ulica 576	1	2017-04-27 00:00:00	source576	145	503	788	32
463	2017-09-25	moscow, ulica 463	3	2017-01-04 00:00:00	source463	191	22	457	98
313	2017-08-03	moscow, ulica 313	2	2018-03-13 00:00:00	source313	962	262	656	92
218	2018-10-05	moscow, ulica 218	3	2018-12-18 00:00:00	source218	498	406	774	3
718	2017-09-08	moscow, ulica 718	4	2018-03-30 00:00:00	source718	844	900	502	47
184	2018-05-06	moscow, ulica 184	1	2017-11-27 00:00:00	source184	206	38	709	5
653	2018-06-18	moscow, ulica 653	5	2018-08-30 00:00:00	source653	172	161	967	18
225	2018-10-24	moscow, ulica 225	4	2018-06-06 00:00:00	source225	799	258	676	94
251	2017-06-26	moscow, ulica 251	3	2017-06-15 00:00:00	source251	272	631	132	2
319	2017-03-06	moscow, ulica 319	2	2017-05-16 00:00:00	source319	180	331	535	95
66	2017-07-03	moscow, ulica 66	1	2018-03-26 00:00:00	source66	31	269	83	83
173	2017-10-25	moscow, ulica 173	2	2018-09-30 00:00:00	source173	907	395	698	4
289	2018-03-23	moscow, ulica 289	3	2018-03-25 00:00:00	source289	749	514	296	1
518	2018-01-05	moscow, ulica 518	5	2018-05-16 00:00:00	source518	665	145	111	23
8	2018-10-12	moscow, ulica 8	5	2017-08-30 00:00:00	source8	563	619	217	71
495	2018-07-17	moscow, ulica 495	3	2018-06-09 00:00:00	source495	330	368	897	38
339	2018-07-09	moscow, ulica 339	2	2017-02-20 00:00:00	source339	110	841	364	96
700	2017-04-05	moscow, ulica 700	1	2017-04-29 00:00:00	source700	55	560	471	33
107	2018-01-21	moscow, ulica 107	5	2018-11-24 00:00:00	source107	742	909	158	6
164	2018-04-28	moscow, ulica 164	1	2017-11-17 00:00:00	source164	466	913	477	4
798	2017-07-02	moscow, ulica 798	3	2018-08-27 00:00:00	source798	270	357	233	42
374	2018-08-25	moscow, ulica 374	3	2018-01-15 00:00:00	source374	115	446	359	91
77	2018-07-22	moscow, ulica 77	4	2018-08-28 00:00:00	source77	441	548	765	13
599	2018-09-05	moscow, ulica 599	4	2017-10-31 00:00:00	source599	66	761	680	23
512	2018-10-03	moscow, ulica 512	3	2018-07-05 00:00:00	source512	771	24	519	5
434	2017-03-24	moscow, ulica 434	2	2018-07-10 00:00:00	source434	805	999	243	89
735	2018-03-12	moscow, ulica 735	1	2018-10-17 00:00:00	source735	19	616	777	19
270	2017-12-01	moscow, ulica 270	2	2018-09-12 00:00:00	source270	35	963	138	1
345	2018-01-20	moscow, ulica 345	2	2018-10-26 00:00:00	source345	552	759	528	15
314	2017-08-24	moscow, ulica 314	1	2018-06-12 00:00:00	source314	992	877	922	93
65	2018-05-23	moscow, ulica 65	5	2017-03-24 00:00:00	source65	357	680	785	27
38	2018-03-23	moscow, ulica 38	3	2018-06-06 00:00:00	source38	487	156	449	85
120	2018-08-02	moscow, ulica 120	4	2017-01-16 00:00:00	source120	749	19	850	82
695	2018-05-17	moscow, ulica 695	5	2017-06-22 00:00:00	source695	856	132	790	98
32	2017-11-18	moscow, ulica 32	2	2018-01-23 00:00:00	source32	16	699	509	57
684	2017-06-20	moscow, ulica 684	3	2017-08-18 00:00:00	source684	379	218	13	18
63	2018-12-14	moscow, ulica 63	4	2018-11-30 00:00:00	source63	617	726	500	31
357	2018-05-18	moscow, ulica 357	3	2017-05-19 00:00:00	source357	406	5	853	15
337	2018-09-03	moscow, ulica 337	3	2018-09-05 00:00:00	source337	277	420	848	88
904	2018-11-22	moscow, ulica 904	4	2017-01-14 00:00:00	source904	648	575	885	55
326	2017-03-20	moscow, ulica 326	1	2017-04-11 00:00:00	source326	531	395	894	13
494	2017-08-18	moscow, ulica 494	2	2017-08-22 00:00:00	source494	528	397	940	8
492	2017-11-12	moscow, ulica 492	5	2018-03-11 00:00:00	source492	995	831	464	8
825	2018-02-08	moscow, ulica 825	1	2018-08-15 00:00:00	source825	978	347	252	45
664	2018-10-20	moscow, ulica 664	1	2017-05-03 00:00:00	source664	18	836	500	18
633	2017-08-25	moscow, ulica 633	1	2018-11-12 00:00:00	source633	265	561	184	97
363	2017-11-22	moscow, ulica 363	1	2017-11-23 00:00:00	source363	132	375	745	15
823	2018-12-02	moscow, ulica 823	1	2018-04-13 00:00:00	source823	320	117	345	85
931	2018-12-16	moscow, ulica 931	5	2018-08-18 00:00:00	source931	176	377	193	26
709	2018-07-23	moscow, ulica 709	5	2018-11-22 00:00:00	source709	788	768	486	44
609	2017-02-06	moscow, ulica 609	4	2018-07-14 00:00:00	source609	332	342	864	35
126	2017-07-30	moscow, ulica 126	2	2018-06-18 00:00:00	source126	466	801	809	27
125	2018-12-31	moscow, ulica 125	1	2018-05-04 00:00:00	source125	370	120	817	27
245	2018-03-30	moscow, ulica 245	4	2017-11-27 00:00:00	source245	169	736	240	3
71	2017-01-20	moscow, ulica 71	5	2017-08-21 00:00:00	source71	663	710	935	65
902	2018-10-08	moscow, ulica 902	2	2018-10-08 00:00:00	source902	827	969	63	39
680	2017-04-13	moscow, ulica 680	3	2017-01-17 00:00:00	source680	457	956	218	19
481	2017-09-30	moscow, ulica 481	2	2018-01-27 00:00:00	source481	70	769	391	9
604	2018-10-10	moscow, ulica 604	1	2018-05-04 00:00:00	source604	224	970	508	97
192	2018-09-29	moscow, ulica 192	4	2017-09-21 00:00:00	source192	591	410	452	14
683	2018-09-20	moscow, ulica 683	4	2018-12-06 00:00:00	source683	635	367	573	19
395	2018-09-11	moscow, ulica 395	4	2018-02-07 00:00:00	source395	720	821	672	8
73	2017-07-28	moscow, ulica 73	1	2017-11-29 00:00:00	source73	733	513	433	24
672	2017-07-18	moscow, ulica 672	4	2018-01-21 00:00:00	source672	604	92	675	20
885	2017-10-13	moscow, ulica 885	1	2017-08-29 00:00:00	source885	312	281	583	29
391	2018-07-11	moscow, ulica 391	1	2018-11-05 00:00:00	source391	902	223	63	98
726	2018-05-07	moscow, ulica 726	5	2017-08-17 00:00:00	source726	262	847	660	30
560	2017-02-01	moscow, ulica 560	1	2018-01-03 00:00:00	source560	704	438	876	97
897	2018-07-03	moscow, ulica 897	1	2018-06-28 00:00:00	source897	301	794	858	24
420	2017-10-23	moscow, ulica 420	5	2018-08-01 00:00:00	source420	60	896	405	87
491	2018-11-29	moscow, ulica 491	1	2017-11-24 00:00:00	source491	495	450	2	85
271	2017-06-13	moscow, ulica 271	1	2018-07-30 00:00:00	source271	394	500	384	15
309	2018-08-04	moscow, ulica 309	1	2017-03-12 00:00:00	source309	316	996	45	14
298	2017-06-20	moscow, ulica 298	1	2017-07-25 00:00:00	source298	764	321	408	75
408	2017-08-22	moscow, ulica 408	3	2017-01-14 00:00:00	source408	448	444	172	11
939	2017-09-02	moscow, ulica 939	1	2018-01-17 00:00:00	source939	895	108	7	40
831	2017-11-16	moscow, ulica 831	4	2018-02-17 00:00:00	source831	345	758	705	47
139	2018-04-21	moscow, ulica 139	2	2017-06-26 00:00:00	source139	694	230	566	76
742	2018-06-21	moscow, ulica 742	1	2017-04-15 00:00:00	source742	371	236	282	17
5	2017-01-17	moscow, ulica 5	3	2018-04-19 00:00:00	source5	398	394	671	64
880	2017-02-13	moscow, ulica 880	2	2018-10-09 00:00:00	source880	278	50	141	31
30	2017-08-02	moscow, ulica 30	2	2017-11-10 00:00:00	source30	86	75	282	26
905	2017-09-15	moscow, ulica 905	3	2018-06-24 00:00:00	source905	377	224	745	29
101	2017-05-12	moscow, ulica 101	5	2018-08-14 00:00:00	source101	688	764	692	31
730	2018-06-23	moscow, ulica 730	1	2018-05-14 00:00:00	source730	847	349	568	96
545	2017-01-22	moscow, ulica 545	5	2017-05-14 00:00:00	source545	25	871	616	99
802	2018-01-15	moscow, ulica 802	2	2018-12-08 00:00:00	source802	3	192	346	69
427	2017-12-09	moscow, ulica 427	3	2017-05-30 00:00:00	source427	350	625	545	8
\.


--
-- Data for Name: orders_id_date; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.orders_id_date (orders_id, date_of_shipping) FROM stdin;
\.


--
-- Data for Name: orders_import; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.orders_import (doc) FROM stdin;
{"order_id":62,"date_of_shipping":"2018-07-23","addres":"moscow, ulica 62","order_status":4,"creation_time":"2017-07-25T00:00:00","source":"source62","prod_prod_id":110,"cust_cust_id":414,"man_man_id":198,"qua":27}
{"order_id":49,"date_of_shipping":"2017-04-27","addres":"moscow, ulica 49","order_status":5,"creation_time":"2018-12-21T00:00:00","source":"source49","prod_prod_id":428,"cust_cust_id":288,"man_man_id":165,"qua":72}
{"order_id":53,"date_of_shipping":"2018-03-25","addres":"moscow, ulica 53","order_status":1,"creation_time":"2018-03-14T00:00:00","source":"source53","prod_prod_id":468,"cust_cust_id":438,"man_man_id":12,"qua":80}
{"order_id":421,"date_of_shipping":"2018-11-27","addres":"moscow, ulica 421","order_status":1,"creation_time":"2017-03-25T00:00:00","source":"source421","prod_prod_id":579,"cust_cust_id":353,"man_man_id":48,"qua":99}
{"order_id":444,"date_of_shipping":"2018-11-21","addres":"moscow, ulica 444","order_status":2,"creation_time":"2018-07-09T00:00:00","source":"source444","prod_prod_id":673,"cust_cust_id":824,"man_man_id":630,"qua":86}
{"order_id":388,"date_of_shipping":"2017-03-25","addres":"moscow, ulica 388","order_status":1,"creation_time":"2018-02-02T00:00:00","source":"source388","prod_prod_id":9,"cust_cust_id":561,"man_man_id":750,"qua":96}
{"order_id":618,"date_of_shipping":"2017-07-14","addres":"moscow, ulica 618","order_status":2,"creation_time":"2017-12-18T00:00:00","source":"source618","prod_prod_id":980,"cust_cust_id":914,"man_man_id":92,"qua":98}
{"order_id":855,"date_of_shipping":"2018-04-15","addres":"moscow, ulica 855","order_status":3,"creation_time":"2018-05-28T00:00:00","source":"source855","prod_prod_id":788,"cust_cust_id":819,"man_man_id":87,"qua":21}
{"order_id":170,"date_of_shipping":"2017-11-04","addres":"moscow, ulica 170","order_status":1,"creation_time":"2018-10-20T00:00:00","source":"source170","prod_prod_id":983,"cust_cust_id":184,"man_man_id":645,"qua":3}
{"order_id":156,"date_of_shipping":"2017-10-25","addres":"moscow, ulica 156","order_status":4,"creation_time":"2017-08-31T00:00:00","source":"source156","prod_prod_id":100,"cust_cust_id":212,"man_man_id":475,"qua":76}
{"order_id":767,"date_of_shipping":"2018-01-25","addres":"moscow, ulica 767","order_status":3,"creation_time":"2017-04-06T00:00:00","source":"source767","prod_prod_id":773,"cust_cust_id":545,"man_man_id":285,"qua":17}
{"order_id":704,"date_of_shipping":"2018-04-25","addres":"moscow, ulica 704","order_status":4,"creation_time":"2018-12-01T00:00:00","source":"source704","prod_prod_id":6,"cust_cust_id":256,"man_man_id":431,"qua":31}
{"order_id":171,"date_of_shipping":"2018-03-27","addres":"moscow, ulica 171","order_status":5,"creation_time":"2018-06-05T00:00:00","source":"source171","prod_prod_id":541,"cust_cust_id":462,"man_man_id":191,"qua":3}
{"order_id":166,"date_of_shipping":"2018-09-17","addres":"moscow, ulica 166","order_status":2,"creation_time":"2017-08-07T00:00:00","source":"source166","prod_prod_id":699,"cust_cust_id":343,"man_man_id":880,"qua":76}
{"order_id":348,"date_of_shipping":"2017-03-18","addres":"moscow, ulica 348","order_status":1,"creation_time":"2018-06-16T00:00:00","source":"source348","prod_prod_id":815,"cust_cust_id":994,"man_man_id":338,"qua":10}
{"order_id":995,"date_of_shipping":"2018-07-31","addres":"moscow, ulica 995","order_status":4,"creation_time":"2018-02-15T00:00:00","source":"source995","prod_prod_id":328,"cust_cust_id":86,"man_man_id":194,"qua":26}
{"order_id":402,"date_of_shipping":"2017-09-17","addres":"moscow, ulica 402","order_status":3,"creation_time":"2018-01-30T00:00:00","source":"source402","prod_prod_id":685,"cust_cust_id":881,"man_man_id":480,"qua":85}
{"order_id":498,"date_of_shipping":"2017-07-27","addres":"moscow, ulica 498","order_status":4,"creation_time":"2017-05-05T00:00:00","source":"source498","prod_prod_id":904,"cust_cust_id":488,"man_man_id":405,"qua":82}
{"order_id":520,"date_of_shipping":"2018-08-20","addres":"moscow, ulica 520","order_status":3,"creation_time":"2017-01-12T00:00:00","source":"source520","prod_prod_id":746,"cust_cust_id":620,"man_man_id":484,"qua":18}
{"order_id":320,"date_of_shipping":"2018-01-09","addres":"moscow, ulica 320","order_status":3,"creation_time":"2018-09-17T00:00:00","source":"source320","prod_prod_id":186,"cust_cust_id":420,"man_man_id":788,"qua":8}
{"order_id":677,"date_of_shipping":"2018-11-19","addres":"moscow, ulica 677","order_status":1,"creation_time":"2017-06-28T00:00:00","source":"source677","prod_prod_id":136,"cust_cust_id":572,"man_man_id":948,"qua":20}
{"order_id":620,"date_of_shipping":"2018-06-24","addres":"moscow, ulica 620","order_status":3,"creation_time":"2017-03-25T00:00:00","source":"source620","prod_prod_id":197,"cust_cust_id":257,"man_man_id":164,"qua":19}
{"order_id":679,"date_of_shipping":"2017-12-19","addres":"moscow, ulica 679","order_status":2,"creation_time":"2017-10-27T00:00:00","source":"source679","prod_prod_id":388,"cust_cust_id":824,"man_man_id":386,"qua":100}
{"order_id":423,"date_of_shipping":"2018-02-09","addres":"moscow, ulica 423","order_status":1,"creation_time":"2017-10-06T00:00:00","source":"source423","prod_prod_id":887,"cust_cust_id":488,"man_man_id":890,"qua":96}
{"order_id":728,"date_of_shipping":"2017-02-19","addres":"moscow, ulica 728","order_status":4,"creation_time":"2018-04-06T00:00:00","source":"source728","prod_prod_id":997,"cust_cust_id":996,"man_man_id":648,"qua":4}
{"order_id":131,"date_of_shipping":"2017-02-01","addres":"moscow, ulica 131","order_status":2,"creation_time":"2018-02-19T00:00:00","source":"source131","prod_prod_id":702,"cust_cust_id":378,"man_man_id":616,"qua":14}
{"order_id":973,"date_of_shipping":"2017-03-19","addres":"moscow, ulica 973","order_status":5,"creation_time":"2018-03-12T00:00:00","source":"source973","prod_prod_id":283,"cust_cust_id":698,"man_man_id":63,"qua":71}
{"order_id":544,"date_of_shipping":"2018-09-29","addres":"moscow, ulica 544","order_status":1,"creation_time":"2017-01-14T00:00:00","source":"source544","prod_prod_id":102,"cust_cust_id":417,"man_man_id":323,"qua":80}
{"order_id":286,"date_of_shipping":"2018-01-30","addres":"moscow, ulica 286","order_status":1,"creation_time":"2017-11-12T00:00:00","source":"source286","prod_prod_id":573,"cust_cust_id":615,"man_man_id":316,"qua":72}
{"order_id":848,"date_of_shipping":"2017-10-26","addres":"moscow, ulica 848","order_status":5,"creation_time":"2018-12-12T00:00:00","source":"source848","prod_prod_id":371,"cust_cust_id":530,"man_man_id":664,"qua":39}
{"order_id":470,"date_of_shipping":"2018-01-16","addres":"moscow, ulica 470","order_status":5,"creation_time":"2018-03-26T00:00:00","source":"source470","prod_prod_id":71,"cust_cust_id":443,"man_man_id":93,"qua":23}
{"order_id":204,"date_of_shipping":"2018-01-03","addres":"moscow, ulica 204","order_status":1,"creation_time":"2018-10-22T00:00:00","source":"source204","prod_prod_id":127,"cust_cust_id":989,"man_man_id":726,"qua":15}
{"order_id":487,"date_of_shipping":"2017-10-05","addres":"moscow, ulica 487","order_status":1,"creation_time":"2018-06-13T00:00:00","source":"source487","prod_prod_id":869,"cust_cust_id":722,"man_man_id":782,"qua":83}
{"order_id":98,"date_of_shipping":"2018-12-21","addres":"moscow, ulica 98","order_status":2,"creation_time":"2017-02-25T00:00:00","source":"source98","prod_prod_id":507,"cust_cust_id":337,"man_man_id":654,"qua":79}
{"order_id":625,"date_of_shipping":"2017-10-01","addres":"moscow, ulica 625","order_status":2,"creation_time":"2017-03-27T00:00:00","source":"source625","prod_prod_id":826,"cust_cust_id":438,"man_man_id":205,"qua":95}
{"order_id":766,"date_of_shipping":"2017-07-16","addres":"moscow, ulica 766","order_status":1,"creation_time":"2017-11-23T00:00:00","source":"source766","prod_prod_id":326,"cust_cust_id":105,"man_man_id":81,"qua":30}
{"order_id":776,"date_of_shipping":"2018-07-25","addres":"moscow, ulica 776","order_status":4,"creation_time":"2018-02-18T00:00:00","source":"source776","prod_prod_id":917,"cust_cust_id":608,"man_man_id":153,"qua":26}
{"order_id":849,"date_of_shipping":"2018-05-10","addres":"moscow, ulica 849","order_status":2,"creation_time":"2017-09-30T00:00:00","source":"source849","prod_prod_id":25,"cust_cust_id":923,"man_man_id":930,"qua":53}
{"order_id":108,"date_of_shipping":"2018-06-02","addres":"moscow, ulica 108","order_status":2,"creation_time":"2017-04-27T00:00:00","source":"source108","prod_prod_id":196,"cust_cust_id":525,"man_man_id":829,"qua":30}
{"order_id":540,"date_of_shipping":"2018-01-21","addres":"moscow, ulica 540","order_status":3,"creation_time":"2018-04-22T00:00:00","source":"source540","prod_prod_id":170,"cust_cust_id":916,"man_man_id":834,"qua":60}
{"order_id":506,"date_of_shipping":"2018-10-29","addres":"moscow, ulica 506","order_status":4,"creation_time":"2018-08-02T00:00:00","source":"source506","prod_prod_id":732,"cust_cust_id":52,"man_man_id":521,"qua":49}
{"order_id":187,"date_of_shipping":"2018-06-14","addres":"moscow, ulica 187","order_status":2,"creation_time":"2017-10-22T00:00:00","source":"source187","prod_prod_id":603,"cust_cust_id":366,"man_man_id":541,"qua":1}
{"order_id":893,"date_of_shipping":"2018-11-04","addres":"moscow, ulica 893","order_status":5,"creation_time":"2018-03-03T00:00:00","source":"source893","prod_prod_id":559,"cust_cust_id":232,"man_man_id":713,"qua":47}
{"order_id":670,"date_of_shipping":"2018-11-07","addres":"moscow, ulica 670","order_status":4,"creation_time":"2018-11-08T00:00:00","source":"source670","prod_prod_id":173,"cust_cust_id":1,"man_man_id":816,"qua":93}
{"order_id":196,"date_of_shipping":"2017-06-03","addres":"moscow, ulica 196","order_status":5,"creation_time":"2017-09-27T00:00:00","source":"source196","prod_prod_id":578,"cust_cust_id":252,"man_man_id":333,"qua":13}
{"order_id":589,"date_of_shipping":"2017-06-23","addres":"moscow, ulica 589","order_status":4,"creation_time":"2018-12-08T00:00:00","source":"source589","prod_prod_id":529,"cust_cust_id":263,"man_man_id":614,"qua":17}
{"order_id":397,"date_of_shipping":"2017-02-19","addres":"moscow, ulica 397","order_status":3,"creation_time":"2018-10-01T00:00:00","source":"source397","prod_prod_id":618,"cust_cust_id":566,"man_man_id":827,"qua":23}
{"order_id":450,"date_of_shipping":"2018-10-08","addres":"moscow, ulica 450","order_status":2,"creation_time":"2017-07-09T00:00:00","source":"source450","prod_prod_id":787,"cust_cust_id":547,"man_man_id":778,"qua":80}
{"order_id":61,"date_of_shipping":"2017-06-15","addres":"moscow, ulica 61","order_status":2,"creation_time":"2017-01-20T00:00:00","source":"source61","prod_prod_id":751,"cust_cust_id":78,"man_man_id":952,"qua":5}
{"order_id":992,"date_of_shipping":"2017-02-22","addres":"moscow, ulica 992","order_status":4,"creation_time":"2018-11-10T00:00:00","source":"source992","prod_prod_id":102,"cust_cust_id":139,"man_man_id":743,"qua":23}
{"order_id":993,"date_of_shipping":"2018-05-24","addres":"moscow, ulica 993","order_status":3,"creation_time":"2017-01-19T00:00:00","source":"source993","prod_prod_id":603,"cust_cust_id":625,"man_man_id":794,"qua":54}
{"order_id":994,"date_of_shipping":"2018-11-27","addres":"moscow, ulica 994","order_status":4,"creation_time":"2018-12-27T00:00:00","source":"source994","prod_prod_id":427,"cust_cust_id":484,"man_man_id":559,"qua":32}
{"order_id":510,"date_of_shipping":"2018-10-13","addres":"moscow, ulica 510","order_status":2,"creation_time":"2018-10-06T00:00:00","source":"source510","prod_prod_id":595,"cust_cust_id":851,"man_man_id":610,"qua":82}
{"order_id":784,"date_of_shipping":"2017-04-21","addres":"moscow, ulica 784","order_status":4,"creation_time":"2017-03-03T00:00:00","source":"source784","prod_prod_id":284,"cust_cust_id":611,"man_man_id":59,"qua":38}
{"order_id":580,"date_of_shipping":"2017-06-24","addres":"moscow, ulica 580","order_status":3,"creation_time":"2017-05-19T00:00:00","source":"source580","prod_prod_id":493,"cust_cust_id":530,"man_man_id":905,"qua":39}
{"order_id":917,"date_of_shipping":"2017-11-14","addres":"moscow, ulica 917","order_status":4,"creation_time":"2018-03-06T00:00:00","source":"source917","prod_prod_id":387,"cust_cust_id":460,"man_man_id":119,"qua":70}
{"order_id":114,"date_of_shipping":"2018-03-22","addres":"moscow, ulica 114","order_status":3,"creation_time":"2017-07-27T00:00:00","source":"source114","prod_prod_id":244,"cust_cust_id":889,"man_man_id":439,"qua":3}
{"order_id":868,"date_of_shipping":"2018-10-12","addres":"moscow, ulica 868","order_status":1,"creation_time":"2018-06-22T00:00:00","source":"source868","prod_prod_id":47,"cust_cust_id":5,"man_man_id":614,"qua":47}
{"order_id":663,"date_of_shipping":"2018-04-22","addres":"moscow, ulica 663","order_status":1,"creation_time":"2018-04-25T00:00:00","source":"source663","prod_prod_id":488,"cust_cust_id":16,"man_man_id":65,"qua":7}
{"order_id":806,"date_of_shipping":"2018-01-02","addres":"moscow, ulica 806","order_status":3,"creation_time":"2017-12-17T00:00:00","source":"source806","prod_prod_id":725,"cust_cust_id":843,"man_man_id":241,"qua":26}
{"order_id":350,"date_of_shipping":"2017-11-14","addres":"moscow, ulica 350","order_status":3,"creation_time":"2017-09-12T00:00:00","source":"source350","prod_prod_id":316,"cust_cust_id":947,"man_man_id":19,"qua":8}
{"order_id":882,"date_of_shipping":"2018-09-18","addres":"moscow, ulica 882","order_status":2,"creation_time":"2018-12-18T00:00:00","source":"source882","prod_prod_id":673,"cust_cust_id":185,"man_man_id":815,"qua":91}
{"order_id":819,"date_of_shipping":"2018-07-13","addres":"moscow, ulica 819","order_status":5,"creation_time":"2018-10-01T00:00:00","source":"source819","prod_prod_id":239,"cust_cust_id":445,"man_man_id":816,"qua":58}
{"order_id":7,"date_of_shipping":"2018-04-08","addres":"moscow, ulica 7","order_status":5,"creation_time":"2018-08-25T00:00:00","source":"source7","prod_prod_id":486,"cust_cust_id":924,"man_man_id":110,"qua":79}
{"order_id":691,"date_of_shipping":"2017-02-18","addres":"moscow, ulica 691","order_status":2,"creation_time":"2017-01-21T00:00:00","source":"source691","prod_prod_id":824,"cust_cust_id":376,"man_man_id":64,"qua":47}
{"order_id":455,"date_of_shipping":"2018-03-30","addres":"moscow, ulica 455","order_status":1,"creation_time":"2017-10-18T00:00:00","source":"source455","prod_prod_id":357,"cust_cust_id":952,"man_man_id":279,"qua":18}
{"order_id":89,"date_of_shipping":"2017-11-30","addres":"moscow, ulica 89","order_status":5,"creation_time":"2018-03-07T00:00:00","source":"source89","prod_prod_id":613,"cust_cust_id":341,"man_man_id":128,"qua":1}
{"order_id":167,"date_of_shipping":"2018-04-03","addres":"moscow, ulica 167","order_status":5,"creation_time":"2017-11-02T00:00:00","source":"source167","prod_prod_id":233,"cust_cust_id":665,"man_man_id":623,"qua":43}
{"order_id":581,"date_of_shipping":"2018-02-09","addres":"moscow, ulica 581","order_status":2,"creation_time":"2018-11-09T00:00:00","source":"source581","prod_prod_id":787,"cust_cust_id":133,"man_man_id":236,"qua":37}
{"order_id":722,"date_of_shipping":"2018-01-31","addres":"moscow, ulica 722","order_status":4,"creation_time":"2017-01-01T00:00:00","source":"source722","prod_prod_id":494,"cust_cust_id":112,"man_man_id":708,"qua":26}
{"order_id":111,"date_of_shipping":"2017-12-15","addres":"moscow, ulica 111","order_status":5,"creation_time":"2017-07-07T00:00:00","source":"source111","prod_prod_id":853,"cust_cust_id":973,"man_man_id":879,"qua":79}
{"order_id":452,"date_of_shipping":"2017-08-19","addres":"moscow, ulica 452","order_status":1,"creation_time":"2017-08-20T00:00:00","source":"source452","prod_prod_id":721,"cust_cust_id":597,"man_man_id":386,"qua":81}
{"order_id":889,"date_of_shipping":"2017-12-26","addres":"moscow, ulica 889","order_status":5,"creation_time":"2017-03-15T00:00:00","source":"source889","prod_prod_id":64,"cust_cust_id":885,"man_man_id":668,"qua":25}
{"order_id":469,"date_of_shipping":"2018-11-20","addres":"moscow, ulica 469","order_status":2,"creation_time":"2017-03-28T00:00:00","source":"source469","prod_prod_id":950,"cust_cust_id":962,"man_man_id":889,"qua":18}
{"order_id":522,"date_of_shipping":"2017-08-28","addres":"moscow, ulica 522","order_status":5,"creation_time":"2017-06-04T00:00:00","source":"source522","prod_prod_id":960,"cust_cust_id":129,"man_man_id":18,"qua":95}
{"order_id":454,"date_of_shipping":"2017-07-11","addres":"moscow, ulica 454","order_status":1,"creation_time":"2017-11-21T00:00:00","source":"source454","prod_prod_id":61,"cust_cust_id":275,"man_man_id":804,"qua":81}
{"order_id":899,"date_of_shipping":"2017-09-07","addres":"moscow, ulica 899","order_status":2,"creation_time":"2018-04-28T00:00:00","source":"source899","prod_prod_id":93,"cust_cust_id":98,"man_man_id":306,"qua":78}
{"order_id":690,"date_of_shipping":"2018-09-24","addres":"moscow, ulica 690","order_status":5,"creation_time":"2017-09-14T00:00:00","source":"source690","prod_prod_id":668,"cust_cust_id":250,"man_man_id":457,"qua":91}
{"order_id":765,"date_of_shipping":"2018-09-16","addres":"moscow, ulica 765","order_status":1,"creation_time":"2017-01-28T00:00:00","source":"source765","prod_prod_id":601,"cust_cust_id":992,"man_man_id":632,"qua":28}
{"order_id":768,"date_of_shipping":"2018-06-04","addres":"moscow, ulica 768","order_status":3,"creation_time":"2018-02-21T00:00:00","source":"source768","prod_prod_id":496,"cust_cust_id":602,"man_man_id":126,"qua":24}
{"order_id":80,"date_of_shipping":"2018-11-13","addres":"moscow, ulica 80","order_status":1,"creation_time":"2017-09-19T00:00:00","source":"source80","prod_prod_id":192,"cust_cust_id":155,"man_man_id":687,"qua":1}
{"order_id":896,"date_of_shipping":"2017-01-04","addres":"moscow, ulica 896","order_status":4,"creation_time":"2018-12-17T00:00:00","source":"source896","prod_prod_id":10,"cust_cust_id":737,"man_man_id":725,"qua":33}
{"order_id":547,"date_of_shipping":"2018-11-08","addres":"moscow, ulica 547","order_status":5,"creation_time":"2017-04-14T00:00:00","source":"source547","prod_prod_id":98,"cust_cust_id":995,"man_man_id":35,"qua":62}
{"order_id":303,"date_of_shipping":"2017-09-12","addres":"moscow, ulica 303","order_status":4,"creation_time":"2017-01-05T00:00:00","source":"source303","prod_prod_id":772,"cust_cust_id":689,"man_man_id":269,"qua":68}
{"order_id":178,"date_of_shipping":"2017-11-07","addres":"moscow, ulica 178","order_status":1,"creation_time":"2018-04-10T00:00:00","source":"source178","prod_prod_id":62,"cust_cust_id":858,"man_man_id":574,"qua":14}
{"order_id":52,"date_of_shipping":"2017-10-14","addres":"moscow, ulica 52","order_status":5,"creation_time":"2018-08-10T00:00:00","source":"source52","prod_prod_id":772,"cust_cust_id":939,"man_man_id":802,"qua":2}
{"order_id":944,"date_of_shipping":"2018-12-19","addres":"moscow, ulica 944","order_status":5,"creation_time":"2018-06-08T00:00:00","source":"source944","prod_prod_id":783,"cust_cust_id":476,"man_man_id":912,"qua":82}
{"order_id":39,"date_of_shipping":"2017-03-19","addres":"moscow, ulica 39","order_status":3,"creation_time":"2018-03-28T00:00:00","source":"source39","prod_prod_id":79,"cust_cust_id":888,"man_man_id":211,"qua":79}
{"order_id":217,"date_of_shipping":"2018-02-21","addres":"moscow, ulica 217","order_status":5,"creation_time":"2017-08-24T00:00:00","source":"source217","prod_prod_id":866,"cust_cust_id":660,"man_man_id":612,"qua":96}
{"order_id":657,"date_of_shipping":"2017-04-10","addres":"moscow, ulica 657","order_status":2,"creation_time":"2017-10-04T00:00:00","source":"source657","prod_prod_id":442,"cust_cust_id":953,"man_man_id":475,"qua":51}
{"order_id":504,"date_of_shipping":"2018-05-20","addres":"moscow, ulica 504","order_status":4,"creation_time":"2018-04-09T00:00:00","source":"source504","prod_prod_id":978,"cust_cust_id":738,"man_man_id":337,"qua":80}
{"order_id":489,"date_of_shipping":"2018-05-13","addres":"moscow, ulica 489","order_status":4,"creation_time":"2017-04-08T00:00:00","source":"source489","prod_prod_id":501,"cust_cust_id":564,"man_man_id":848,"qua":92}
{"order_id":814,"date_of_shipping":"2018-06-18","addres":"moscow, ulica 814","order_status":2,"creation_time":"2018-12-03T00:00:00","source":"source814","prod_prod_id":154,"cust_cust_id":47,"man_man_id":74,"qua":85}
{"order_id":519,"date_of_shipping":"2018-12-06","addres":"moscow, ulica 519","order_status":2,"creation_time":"2017-10-23T00:00:00","source":"source519","prod_prod_id":145,"cust_cust_id":576,"man_man_id":95,"qua":91}
{"order_id":383,"date_of_shipping":"2018-09-12","addres":"moscow, ulica 383","order_status":1,"creation_time":"2018-01-17T00:00:00","source":"source383","prod_prod_id":346,"cust_cust_id":784,"man_man_id":807,"qua":84}
{"order_id":976,"date_of_shipping":"2017-06-04","addres":"moscow, ulica 976","order_status":5,"creation_time":"2017-12-24T00:00:00","source":"source976","prod_prod_id":936,"cust_cust_id":823,"man_man_id":867,"qua":19}
{"order_id":839,"date_of_shipping":"2017-02-06","addres":"moscow, ulica 839","order_status":2,"creation_time":"2018-07-18T00:00:00","source":"source839","prod_prod_id":927,"cust_cust_id":777,"man_man_id":931,"qua":79}
{"order_id":224,"date_of_shipping":"2018-10-08","addres":"moscow, ulica 224","order_status":5,"creation_time":"2017-02-25T00:00:00","source":"source224","prod_prod_id":292,"cust_cust_id":664,"man_man_id":855,"qua":40}
{"order_id":351,"date_of_shipping":"2018-03-27","addres":"moscow, ulica 351","order_status":5,"creation_time":"2018-03-03T00:00:00","source":"source351","prod_prod_id":264,"cust_cust_id":92,"man_man_id":311,"qua":6}
{"order_id":51,"date_of_shipping":"2017-10-07","addres":"moscow, ulica 51","order_status":4,"creation_time":"2018-08-19T00:00:00","source":"source51","prod_prod_id":55,"cust_cust_id":811,"man_man_id":430,"qua":51}
{"order_id":586,"date_of_shipping":"2018-11-29","addres":"moscow, ulica 586","order_status":1,"creation_time":"2017-03-15T00:00:00","source":"source586","prod_prod_id":459,"cust_cust_id":425,"man_man_id":909,"qua":90}
{"order_id":188,"date_of_shipping":"2017-11-28","addres":"moscow, ulica 188","order_status":2,"creation_time":"2017-07-15T00:00:00","source":"source188","prod_prod_id":792,"cust_cust_id":39,"man_man_id":535,"qua":62}
{"order_id":263,"date_of_shipping":"2018-06-28","addres":"moscow, ulica 263","order_status":2,"creation_time":"2018-01-30T00:00:00","source":"source263","prod_prod_id":529,"cust_cust_id":191,"man_man_id":421,"qua":85}
{"order_id":186,"date_of_shipping":"2018-10-07","addres":"moscow, ulica 186","order_status":4,"creation_time":"2017-09-15T00:00:00","source":"source186","prod_prod_id":106,"cust_cust_id":819,"man_man_id":78,"qua":62}
{"order_id":675,"date_of_shipping":"2018-01-09","addres":"moscow, ulica 675","order_status":5,"creation_time":"2017-06-02T00:00:00","source":"source675","prod_prod_id":106,"cust_cust_id":633,"man_man_id":912,"qua":27}
{"order_id":989,"date_of_shipping":"2018-08-24","addres":"moscow, ulica 989","order_status":5,"creation_time":"2018-02-02T00:00:00","source":"source989","prod_prod_id":727,"cust_cust_id":492,"man_man_id":695,"qua":63}
{"order_id":530,"date_of_shipping":"2018-10-15","addres":"moscow, ulica 530","order_status":1,"creation_time":"2017-01-09T00:00:00","source":"source530","prod_prod_id":372,"cust_cust_id":363,"man_man_id":729,"qua":93}
{"order_id":1,"date_of_shipping":"2018-10-02","addres":"moscow, ulica 1","order_status":5,"creation_time":"2017-02-22T00:00:00","source":"source1","prod_prod_id":898,"cust_cust_id":290,"man_man_id":851,"qua":77}
{"order_id":932,"date_of_shipping":"2017-11-18","addres":"moscow, ulica 932","order_status":2,"creation_time":"2018-07-21T00:00:00","source":"source932","prod_prod_id":101,"cust_cust_id":608,"man_man_id":444,"qua":47}
{"order_id":590,"date_of_shipping":"2017-02-05","addres":"moscow, ulica 590","order_status":2,"creation_time":"2018-05-20T00:00:00","source":"source590","prod_prod_id":235,"cust_cust_id":818,"man_man_id":791,"qua":36}
{"order_id":753,"date_of_shipping":"2017-09-04","addres":"moscow, ulica 753","order_status":1,"creation_time":"2017-06-10T00:00:00","source":"source753","prod_prod_id":174,"cust_cust_id":622,"man_man_id":866,"qua":69}
{"order_id":6,"date_of_shipping":"2018-07-27","addres":"moscow, ulica 6","order_status":5,"creation_time":"2017-06-15T00:00:00","source":"source6","prod_prod_id":189,"cust_cust_id":363,"man_man_id":445,"qua":48}
{"order_id":714,"date_of_shipping":"2017-06-23","addres":"moscow, ulica 714","order_status":5,"creation_time":"2018-02-19T00:00:00","source":"source714","prod_prod_id":487,"cust_cust_id":873,"man_man_id":705,"qua":99}
{"order_id":928,"date_of_shipping":"2017-04-21","addres":"moscow, ulica 928","order_status":2,"creation_time":"2018-02-24T00:00:00","source":"source928","prod_prod_id":443,"cust_cust_id":80,"man_man_id":716,"qua":20}
{"order_id":262,"date_of_shipping":"2018-11-12","addres":"moscow, ulica 262","order_status":5,"creation_time":"2018-03-01T00:00:00","source":"source262","prod_prod_id":470,"cust_cust_id":346,"man_man_id":183,"qua":68}
{"order_id":279,"date_of_shipping":"2017-08-30","addres":"moscow, ulica 279","order_status":4,"creation_time":"2017-07-27T00:00:00","source":"source279","prod_prod_id":321,"cust_cust_id":835,"man_man_id":502,"qua":84}
{"order_id":208,"date_of_shipping":"2018-02-07","addres":"moscow, ulica 208","order_status":2,"creation_time":"2018-06-02T00:00:00","source":"source208","prod_prod_id":279,"cust_cust_id":682,"man_man_id":231,"qua":59}
{"order_id":933,"date_of_shipping":"2018-08-01","addres":"moscow, ulica 933","order_status":2,"creation_time":"2017-06-28T00:00:00","source":"source933","prod_prod_id":844,"cust_cust_id":619,"man_man_id":652,"qua":21}
{"order_id":648,"date_of_shipping":"2017-02-19","addres":"moscow, ulica 648","order_status":4,"creation_time":"2018-10-18T00:00:00","source":"source648","prod_prod_id":681,"cust_cust_id":725,"man_man_id":213,"qua":89}
{"order_id":150,"date_of_shipping":"2018-11-01","addres":"moscow, ulica 150","order_status":5,"creation_time":"2017-05-05T00:00:00","source":"source150","prod_prod_id":724,"cust_cust_id":924,"man_man_id":505,"qua":72}
{"order_id":509,"date_of_shipping":"2017-11-08","addres":"moscow, ulica 509","order_status":5,"creation_time":"2017-11-08T00:00:00","source":"source509","prod_prod_id":160,"cust_cust_id":424,"man_man_id":234,"qua":81}
{"order_id":394,"date_of_shipping":"2018-06-28","addres":"moscow, ulica 394","order_status":1,"creation_time":"2018-10-17T00:00:00","source":"source394","prod_prod_id":764,"cust_cust_id":479,"man_man_id":356,"qua":50}
{"order_id":955,"date_of_shipping":"2017-03-09","addres":"moscow, ulica 955","order_status":5,"creation_time":"2017-09-16T00:00:00","source":"source955","prod_prod_id":316,"cust_cust_id":756,"man_man_id":306,"qua":5}
{"order_id":486,"date_of_shipping":"2018-03-16","addres":"moscow, ulica 486","order_status":1,"creation_time":"2017-01-05T00:00:00","source":"source486","prod_prod_id":975,"cust_cust_id":104,"man_man_id":160,"qua":3}
{"order_id":553,"date_of_shipping":"2018-02-15","addres":"moscow, ulica 553","order_status":2,"creation_time":"2017-12-18T00:00:00","source":"source553","prod_prod_id":96,"cust_cust_id":394,"man_man_id":69,"qua":49}
{"order_id":250,"date_of_shipping":"2018-10-01","addres":"moscow, ulica 250","order_status":5,"creation_time":"2017-05-10T00:00:00","source":"source250","prod_prod_id":526,"cust_cust_id":648,"man_man_id":356,"qua":58}
{"order_id":90,"date_of_shipping":"2018-08-25","addres":"moscow, ulica 90","order_status":1,"creation_time":"2017-08-02T00:00:00","source":"source90","prod_prod_id":368,"cust_cust_id":508,"man_man_id":919,"qua":74}
{"order_id":25,"date_of_shipping":"2018-10-21","addres":"moscow, ulica 25","order_status":2,"creation_time":"2018-08-11T00:00:00","source":"source25","prod_prod_id":183,"cust_cust_id":156,"man_man_id":925,"qua":48}
{"order_id":921,"date_of_shipping":"2017-06-30","addres":"moscow, ulica 921","order_status":5,"creation_time":"2018-05-31T00:00:00","source":"source921","prod_prod_id":789,"cust_cust_id":326,"man_man_id":766,"qua":58}
{"order_id":533,"date_of_shipping":"2017-02-05","addres":"moscow, ulica 533","order_status":5,"creation_time":"2017-07-13T00:00:00","source":"source533","prod_prod_id":329,"cust_cust_id":610,"man_man_id":147,"qua":90}
{"order_id":328,"date_of_shipping":"2018-07-13","addres":"moscow, ulica 328","order_status":5,"creation_time":"2017-09-02T00:00:00","source":"source328","prod_prod_id":618,"cust_cust_id":34,"man_man_id":24,"qua":7}
{"order_id":720,"date_of_shipping":"2017-05-05","addres":"moscow, ulica 720","order_status":3,"creation_time":"2017-08-30T00:00:00","source":"source720","prod_prod_id":34,"cust_cust_id":943,"man_man_id":568,"qua":45}
{"order_id":830,"date_of_shipping":"2018-03-31","addres":"moscow, ulica 830","order_status":3,"creation_time":"2017-05-03T00:00:00","source":"source830","prod_prod_id":702,"cust_cust_id":786,"man_man_id":677,"qua":37}
{"order_id":829,"date_of_shipping":"2018-01-02","addres":"moscow, ulica 829","order_status":4,"creation_time":"2018-06-14T00:00:00","source":"source829","prod_prod_id":646,"cust_cust_id":126,"man_man_id":930,"qua":37}
{"order_id":734,"date_of_shipping":"2018-04-01","addres":"moscow, ulica 734","order_status":4,"creation_time":"2018-03-18T00:00:00","source":"source734","prod_prod_id":512,"cust_cust_id":905,"man_man_id":870,"qua":58}
{"order_id":43,"date_of_shipping":"2017-11-05","addres":"moscow, ulica 43","order_status":2,"creation_time":"2017-02-20T00:00:00","source":"source43","prod_prod_id":630,"cust_cust_id":307,"man_man_id":614,"qua":77}
{"order_id":627,"date_of_shipping":"2018-06-02","addres":"moscow, ulica 627","order_status":2,"creation_time":"2018-04-08T00:00:00","source":"source627","prod_prod_id":878,"cust_cust_id":544,"man_man_id":758,"qua":71}
{"order_id":305,"date_of_shipping":"2018-08-24","addres":"moscow, ulica 305","order_status":3,"creation_time":"2018-07-17T00:00:00","source":"source305","prod_prod_id":320,"cust_cust_id":257,"man_man_id":928,"qua":57}
{"order_id":378,"date_of_shipping":"2018-03-07","addres":"moscow, ulica 378","order_status":2,"creation_time":"2017-11-10T00:00:00","source":"source378","prod_prod_id":702,"cust_cust_id":129,"man_man_id":363,"qua":7}
{"order_id":183,"date_of_shipping":"2017-09-06","addres":"moscow, ulica 183","order_status":5,"creation_time":"2018-02-27T00:00:00","source":"source183","prod_prod_id":991,"cust_cust_id":147,"man_man_id":653,"qua":72}
{"order_id":745,"date_of_shipping":"2018-08-26","addres":"moscow, ulica 745","order_status":3,"creation_time":"2017-08-18T00:00:00","source":"source745","prod_prod_id":537,"cust_cust_id":965,"man_man_id":397,"qua":39}
{"order_id":934,"date_of_shipping":"2017-05-31","addres":"moscow, ulica 934","order_status":2,"creation_time":"2017-12-01T00:00:00","source":"source934","prod_prod_id":283,"cust_cust_id":671,"man_man_id":539,"qua":74}
{"order_id":611,"date_of_shipping":"2018-03-17","addres":"moscow, ulica 611","order_status":4,"creation_time":"2017-12-25T00:00:00","source":"source611","prod_prod_id":71,"cust_cust_id":897,"man_man_id":874,"qua":91}
{"order_id":915,"date_of_shipping":"2017-10-05","addres":"moscow, ulica 915","order_status":4,"creation_time":"2017-06-17T00:00:00","source":"source915","prod_prod_id":450,"cust_cust_id":148,"man_man_id":380,"qua":80}
{"order_id":287,"date_of_shipping":"2018-08-11","addres":"moscow, ulica 287","order_status":1,"creation_time":"2018-09-20T00:00:00","source":"source287","prod_prod_id":965,"cust_cust_id":642,"man_man_id":569,"qua":85}
{"order_id":744,"date_of_shipping":"2017-12-23","addres":"moscow, ulica 744","order_status":1,"creation_time":"2018-01-10T00:00:00","source":"source744","prod_prod_id":844,"cust_cust_id":513,"man_man_id":451,"qua":8}
{"order_id":87,"date_of_shipping":"2017-09-03","addres":"moscow, ulica 87","order_status":1,"creation_time":"2017-09-08T00:00:00","source":"source87","prod_prod_id":940,"cust_cust_id":20,"man_man_id":172,"qua":75}
{"order_id":638,"date_of_shipping":"2018-10-02","addres":"moscow, ulica 638","order_status":4,"creation_time":"2017-11-17T00:00:00","source":"source638","prod_prod_id":19,"cust_cust_id":58,"man_man_id":746,"qua":32}
{"order_id":91,"date_of_shipping":"2018-01-26","addres":"moscow, ulica 91","order_status":5,"creation_time":"2018-09-14T00:00:00","source":"source91","prod_prod_id":602,"cust_cust_id":658,"man_man_id":221,"qua":46}
{"order_id":571,"date_of_shipping":"2018-03-08","addres":"moscow, ulica 571","order_status":3,"creation_time":"2017-02-26T00:00:00","source":"source571","prod_prod_id":698,"cust_cust_id":808,"man_man_id":190,"qua":78}
{"order_id":930,"date_of_shipping":"2017-03-14","addres":"moscow, ulica 930","order_status":1,"creation_time":"2018-09-19T00:00:00","source":"source930","prod_prod_id":412,"cust_cust_id":911,"man_man_id":845,"qua":82}
{"order_id":324,"date_of_shipping":"2018-07-01","addres":"moscow, ulica 324","order_status":2,"creation_time":"2017-08-23T00:00:00","source":"source324","prod_prod_id":763,"cust_cust_id":658,"man_man_id":273,"qua":4}
{"order_id":688,"date_of_shipping":"2017-09-21","addres":"moscow, ulica 688","order_status":4,"creation_time":"2018-10-12T00:00:00","source":"source688","prod_prod_id":989,"cust_cust_id":764,"man_man_id":962,"qua":69}
{"order_id":671,"date_of_shipping":"2018-12-25","addres":"moscow, ulica 671","order_status":2,"creation_time":"2017-12-21T00:00:00","source":"source671","prod_prod_id":336,"cust_cust_id":388,"man_man_id":478,"qua":8}
{"order_id":386,"date_of_shipping":"2017-12-14","addres":"moscow, ulica 386","order_status":1,"creation_time":"2018-03-17T00:00:00","source":"source386","prod_prod_id":122,"cust_cust_id":916,"man_man_id":960,"qua":44}
{"order_id":548,"date_of_shipping":"2018-06-25","addres":"moscow, ulica 548","order_status":3,"creation_time":"2017-07-23T00:00:00","source":"source548","prod_prod_id":946,"cust_cust_id":633,"man_man_id":460,"qua":43}
{"order_id":803,"date_of_shipping":"2017-07-14","addres":"moscow, ulica 803","order_status":3,"creation_time":"2017-12-18T00:00:00","source":"source803","prod_prod_id":644,"cust_cust_id":575,"man_man_id":123,"qua":59}
{"order_id":826,"date_of_shipping":"2017-04-01","addres":"moscow, ulica 826","order_status":5,"creation_time":"2018-08-13T00:00:00","source":"source826","prod_prod_id":723,"cust_cust_id":551,"man_man_id":923,"qua":9}
{"order_id":248,"date_of_shipping":"2017-11-08","addres":"moscow, ulica 248","order_status":3,"creation_time":"2017-07-22T00:00:00","source":"source248","prod_prod_id":86,"cust_cust_id":538,"man_man_id":749,"qua":47}
{"order_id":812,"date_of_shipping":"2017-05-24","addres":"moscow, ulica 812","order_status":3,"creation_time":"2018-12-08T00:00:00","source":"source812","prod_prod_id":937,"cust_cust_id":289,"man_man_id":880,"qua":58}
{"order_id":884,"date_of_shipping":"2017-09-08","addres":"moscow, ulica 884","order_status":2,"creation_time":"2017-07-04T00:00:00","source":"source884","prod_prod_id":647,"cust_cust_id":386,"man_man_id":715,"qua":37}
{"order_id":600,"date_of_shipping":"2017-06-07","addres":"moscow, ulica 600","order_status":5,"creation_time":"2018-03-21T00:00:00","source":"source600","prod_prod_id":93,"cust_cust_id":343,"man_man_id":468,"qua":62}
{"order_id":542,"date_of_shipping":"2018-08-24","addres":"moscow, ulica 542","order_status":2,"creation_time":"2017-12-14T00:00:00","source":"source542","prod_prod_id":901,"cust_cust_id":519,"man_man_id":872,"qua":71}
{"order_id":83,"date_of_shipping":"2017-06-01","addres":"moscow, ulica 83","order_status":1,"creation_time":"2018-09-02T00:00:00","source":"source83","prod_prod_id":379,"cust_cust_id":207,"man_man_id":623,"qua":61}
{"order_id":137,"date_of_shipping":"2017-06-19","addres":"moscow, ulica 137","order_status":2,"creation_time":"2018-06-04T00:00:00","source":"source137","prod_prod_id":485,"cust_cust_id":782,"man_man_id":596,"qua":39}
{"order_id":570,"date_of_shipping":"2017-11-28","addres":"moscow, ulica 570","order_status":2,"creation_time":"2017-08-09T00:00:00","source":"source570","prod_prod_id":111,"cust_cust_id":343,"man_man_id":997,"qua":70}
{"order_id":562,"date_of_shipping":"2017-10-13","addres":"moscow, ulica 562","order_status":2,"creation_time":"2017-08-23T00:00:00","source":"source562","prod_prod_id":813,"cust_cust_id":702,"man_man_id":708,"qua":42}
{"order_id":448,"date_of_shipping":"2017-02-23","addres":"moscow, ulica 448","order_status":5,"creation_time":"2017-02-16T00:00:00","source":"source448","prod_prod_id":902,"cust_cust_id":388,"man_man_id":362,"qua":70}
{"order_id":50,"date_of_shipping":"2017-07-03","addres":"moscow, ulica 50","order_status":2,"creation_time":"2018-07-07T00:00:00","source":"source50","prod_prod_id":86,"cust_cust_id":710,"man_man_id":923,"qua":62}
{"order_id":610,"date_of_shipping":"2018-05-12","addres":"moscow, ulica 610","order_status":5,"creation_time":"2017-04-22T00:00:00","source":"source610","prod_prod_id":555,"cust_cust_id":425,"man_man_id":811,"qua":76}
{"order_id":961,"date_of_shipping":"2017-09-28","addres":"moscow, ulica 961","order_status":3,"creation_time":"2017-07-10T00:00:00","source":"source961","prod_prod_id":725,"cust_cust_id":358,"man_man_id":891,"qua":89}
{"order_id":308,"date_of_shipping":"2017-01-14","addres":"moscow, ulica 308","order_status":4,"creation_time":"2017-09-09T00:00:00","source":"source308","prod_prod_id":150,"cust_cust_id":60,"man_man_id":513,"qua":34}
{"order_id":642,"date_of_shipping":"2017-08-17","addres":"moscow, ulica 642","order_status":3,"creation_time":"2017-12-17T00:00:00","source":"source642","prod_prod_id":106,"cust_cust_id":263,"man_man_id":91,"qua":75}
{"order_id":511,"date_of_shipping":"2017-02-20","addres":"moscow, ulica 511","order_status":3,"creation_time":"2017-05-18T00:00:00","source":"source511","prod_prod_id":181,"cust_cust_id":318,"man_man_id":255,"qua":45}
{"order_id":924,"date_of_shipping":"2018-05-03","addres":"moscow, ulica 924","order_status":3,"creation_time":"2017-11-06T00:00:00","source":"source924","prod_prod_id":199,"cust_cust_id":331,"man_man_id":932,"qua":19}
{"order_id":919,"date_of_shipping":"2018-05-02","addres":"moscow, ulica 919","order_status":5,"creation_time":"2018-12-21T00:00:00","source":"source919","prod_prod_id":920,"cust_cust_id":738,"man_man_id":359,"qua":75}
{"order_id":524,"date_of_shipping":"2018-12-17","addres":"moscow, ulica 524","order_status":2,"creation_time":"2018-07-18T00:00:00","source":"source524","prod_prod_id":605,"cust_cust_id":856,"man_man_id":633,"qua":41}
{"order_id":92,"date_of_shipping":"2018-04-17","addres":"moscow, ulica 92","order_status":1,"creation_time":"2017-04-10T00:00:00","source":"source92","prod_prod_id":471,"cust_cust_id":269,"man_man_id":991,"qua":38}
{"order_id":69,"date_of_shipping":"2018-12-22","addres":"moscow, ulica 69","order_status":5,"creation_time":"2017-05-06T00:00:00","source":"source69","prod_prod_id":283,"cust_cust_id":224,"man_man_id":73,"qua":61}
{"order_id":472,"date_of_shipping":"2018-08-18","addres":"moscow, ulica 472","order_status":2,"creation_time":"2017-08-20T00:00:00","source":"source472","prod_prod_id":258,"cust_cust_id":689,"man_man_id":433,"qua":1}
{"order_id":330,"date_of_shipping":"2017-11-03","addres":"moscow, ulica 330","order_status":5,"creation_time":"2018-04-18T00:00:00","source":"source330","prod_prod_id":297,"cust_cust_id":796,"man_man_id":490,"qua":47}
{"order_id":878,"date_of_shipping":"2017-08-08","addres":"moscow, ulica 878","order_status":1,"creation_time":"2017-04-03T00:00:00","source":"source878","prod_prod_id":540,"cust_cust_id":220,"man_man_id":365,"qua":63}
{"order_id":908,"date_of_shipping":"2017-12-30","addres":"moscow, ulica 908","order_status":5,"creation_time":"2017-07-14T00:00:00","source":"source908","prod_prod_id":305,"cust_cust_id":400,"man_man_id":610,"qua":17}
{"order_id":640,"date_of_shipping":"2018-11-29","addres":"moscow, ulica 640","order_status":3,"creation_time":"2018-06-09T00:00:00","source":"source640","prod_prod_id":433,"cust_cust_id":833,"man_man_id":588,"qua":56}
{"order_id":144,"date_of_shipping":"2017-03-18","addres":"moscow, ulica 144","order_status":3,"creation_time":"2017-10-02T00:00:00","source":"source144","prod_prod_id":204,"cust_cust_id":248,"man_man_id":421,"qua":56}
{"order_id":787,"date_of_shipping":"2017-09-27","addres":"moscow, ulica 787","order_status":4,"creation_time":"2017-12-01T00:00:00","source":"source787","prod_prod_id":834,"cust_cust_id":881,"man_man_id":411,"qua":95}
{"order_id":777,"date_of_shipping":"2018-03-15","addres":"moscow, ulica 777","order_status":2,"creation_time":"2018-12-16T00:00:00","source":"source777","prod_prod_id":722,"cust_cust_id":843,"man_man_id":423,"qua":8}
{"order_id":877,"date_of_shipping":"2018-01-24","addres":"moscow, ulica 877","order_status":5,"creation_time":"2018-02-23T00:00:00","source":"source877","prod_prod_id":763,"cust_cust_id":897,"man_man_id":821,"qua":78}
{"order_id":977,"date_of_shipping":"2017-11-13","addres":"moscow, ulica 977","order_status":3,"creation_time":"2018-05-12T00:00:00","source":"source977","prod_prod_id":303,"cust_cust_id":103,"man_man_id":914,"qua":87}
{"order_id":912,"date_of_shipping":"2018-12-19","addres":"moscow, ulica 912","order_status":2,"creation_time":"2018-09-16T00:00:00","source":"source912","prod_prod_id":706,"cust_cust_id":189,"man_man_id":628,"qua":7}
{"order_id":478,"date_of_shipping":"2017-03-11","addres":"moscow, ulica 478","order_status":5,"creation_time":"2018-03-26T00:00:00","source":"source478","prod_prod_id":355,"cust_cust_id":11,"man_man_id":697,"qua":70}
{"order_id":603,"date_of_shipping":"2017-06-16","addres":"moscow, ulica 603","order_status":2,"creation_time":"2018-12-28T00:00:00","source":"source603","prod_prod_id":417,"cust_cust_id":575,"man_man_id":769,"qua":58}
{"order_id":543,"date_of_shipping":"2017-04-20","addres":"moscow, ulica 543","order_status":3,"creation_time":"2017-07-23T00:00:00","source":"source543","prod_prod_id":178,"cust_cust_id":245,"man_man_id":860,"qua":40}
{"order_id":175,"date_of_shipping":"2017-02-09","addres":"moscow, ulica 175","order_status":1,"creation_time":"2018-03-30T00:00:00","source":"source175","prod_prod_id":645,"cust_cust_id":659,"man_man_id":245,"qua":39}
{"order_id":583,"date_of_shipping":"2017-01-07","addres":"moscow, ulica 583","order_status":3,"creation_time":"2018-02-25T00:00:00","source":"source583","prod_prod_id":251,"cust_cust_id":773,"man_man_id":28,"qua":52}
{"order_id":516,"date_of_shipping":"2017-07-12","addres":"moscow, ulica 516","order_status":2,"creation_time":"2017-07-06T00:00:00","source":"source516","prod_prod_id":738,"cust_cust_id":6,"man_man_id":703,"qua":54}
{"order_id":200,"date_of_shipping":"2018-04-22","addres":"moscow, ulica 200","order_status":3,"creation_time":"2017-03-26T00:00:00","source":"source200","prod_prod_id":599,"cust_cust_id":489,"man_man_id":408,"qua":6}
{"order_id":986,"date_of_shipping":"2017-06-09","addres":"moscow, ulica 986","order_status":4,"creation_time":"2018-03-22T00:00:00","source":"source986","prod_prod_id":162,"cust_cust_id":571,"man_man_id":311,"qua":86}
{"order_id":21,"date_of_shipping":"2017-06-17","addres":"moscow, ulica 21","order_status":1,"creation_time":"2017-07-05T00:00:00","source":"source21","prod_prod_id":786,"cust_cust_id":426,"man_man_id":401,"qua":89}
{"order_id":459,"date_of_shipping":"2018-07-16","addres":"moscow, ulica 459","order_status":4,"creation_time":"2018-04-16T00:00:00","source":"source459","prod_prod_id":545,"cust_cust_id":641,"man_man_id":621,"qua":40}
{"order_id":123,"date_of_shipping":"2018-05-21","addres":"moscow, ulica 123","order_status":4,"creation_time":"2017-11-22T00:00:00","source":"source123","prod_prod_id":397,"cust_cust_id":998,"man_man_id":896,"qua":38}
{"order_id":567,"date_of_shipping":"2017-11-14","addres":"moscow, ulica 567","order_status":1,"creation_time":"2017-03-09T00:00:00","source":"source567","prod_prod_id":260,"cust_cust_id":738,"man_man_id":780,"qua":68}
{"order_id":142,"date_of_shipping":"2018-10-04","addres":"moscow, ulica 142","order_status":5,"creation_time":"2018-02-01T00:00:00","source":"source142","prod_prod_id":619,"cust_cust_id":667,"man_man_id":614,"qua":56}
{"order_id":725,"date_of_shipping":"2017-12-23","addres":"moscow, ulica 725","order_status":3,"creation_time":"2018-11-28T00:00:00","source":"source725","prod_prod_id":681,"cust_cust_id":302,"man_man_id":317,"qua":48}
{"order_id":311,"date_of_shipping":"2017-04-03","addres":"moscow, ulica 311","order_status":1,"creation_time":"2017-08-04T00:00:00","source":"source311","prod_prod_id":678,"cust_cust_id":29,"man_man_id":841,"qua":4}
{"order_id":431,"date_of_shipping":"2018-05-24","addres":"moscow, ulica 431","order_status":5,"creation_time":"2018-05-24T00:00:00","source":"source431","prod_prod_id":122,"cust_cust_id":754,"man_man_id":593,"qua":44}
{"order_id":231,"date_of_shipping":"2018-05-25","addres":"moscow, ulica 231","order_status":5,"creation_time":"2018-08-01T00:00:00","source":"source231","prod_prod_id":595,"cust_cust_id":76,"man_man_id":546,"qua":34}
{"order_id":428,"date_of_shipping":"2017-02-01","addres":"moscow, ulica 428","order_status":5,"creation_time":"2018-02-09T00:00:00","source":"source428","prod_prod_id":731,"cust_cust_id":819,"man_man_id":368,"qua":44}
{"order_id":749,"date_of_shipping":"2018-11-25","addres":"moscow, ulica 749","order_status":1,"creation_time":"2018-10-01T00:00:00","source":"source749","prod_prod_id":633,"cust_cust_id":996,"man_man_id":230,"qua":74}
{"order_id":18,"date_of_shipping":"2018-02-04","addres":"moscow, ulica 18","order_status":1,"creation_time":"2018-04-12T00:00:00","source":"source18","prod_prod_id":128,"cust_cust_id":991,"man_man_id":940,"qua":61}
{"order_id":941,"date_of_shipping":"2018-06-01","addres":"moscow, ulica 941","order_status":5,"creation_time":"2018-08-25T00:00:00","source":"source941","prod_prod_id":223,"cust_cust_id":485,"man_man_id":536,"qua":17}
{"order_id":479,"date_of_shipping":"2018-09-29","addres":"moscow, ulica 479","order_status":3,"creation_time":"2018-05-25T00:00:00","source":"source479","prod_prod_id":97,"cust_cust_id":313,"man_man_id":184,"qua":4}
{"order_id":773,"date_of_shipping":"2018-03-01","addres":"moscow, ulica 773","order_status":2,"creation_time":"2018-12-26T00:00:00","source":"source773","prod_prod_id":254,"cust_cust_id":875,"man_man_id":796,"qua":62}
{"order_id":783,"date_of_shipping":"2018-12-24","addres":"moscow, ulica 783","order_status":3,"creation_time":"2018-02-25T00:00:00","source":"source783","prod_prod_id":139,"cust_cust_id":109,"man_man_id":795,"qua":7}
{"order_id":10,"date_of_shipping":"2018-05-08","addres":"moscow, ulica 10","order_status":3,"creation_time":"2018-12-27T00:00:00","source":"source10","prod_prod_id":818,"cust_cust_id":408,"man_man_id":956,"qua":89}
{"order_id":304,"date_of_shipping":"2018-08-28","addres":"moscow, ulica 304","order_status":1,"creation_time":"2018-03-20T00:00:00","source":"source304","prod_prod_id":760,"cust_cust_id":295,"man_man_id":683,"qua":32}
{"order_id":47,"date_of_shipping":"2017-01-01","addres":"moscow, ulica 47","order_status":3,"creation_time":"2017-10-25T00:00:00","source":"source47","prod_prod_id":683,"cust_cust_id":652,"man_man_id":295,"qua":88}
{"order_id":813,"date_of_shipping":"2017-02-19","addres":"moscow, ulica 813","order_status":5,"creation_time":"2018-04-13T00:00:00","source":"source813","prod_prod_id":74,"cust_cust_id":431,"man_man_id":942,"qua":76}
{"order_id":254,"date_of_shipping":"2018-10-04","addres":"moscow, ulica 254","order_status":5,"creation_time":"2018-03-13T00:00:00","source":"source254","prod_prod_id":789,"cust_cust_id":387,"man_man_id":294,"qua":6}
{"order_id":837,"date_of_shipping":"2017-08-30","addres":"moscow, ulica 837","order_status":2,"creation_time":"2018-10-11T00:00:00","source":"source837","prod_prod_id":275,"cust_cust_id":274,"man_man_id":847,"qua":87}
{"order_id":118,"date_of_shipping":"2017-08-04","addres":"moscow, ulica 118","order_status":3,"creation_time":"2017-04-03T00:00:00","source":"source118","prod_prod_id":453,"cust_cust_id":478,"man_man_id":529,"qua":39}
{"order_id":152,"date_of_shipping":"2018-03-28","addres":"moscow, ulica 152","order_status":4,"creation_time":"2017-03-11T00:00:00","source":"source152","prod_prod_id":717,"cust_cust_id":697,"man_man_id":502,"qua":34}
{"order_id":942,"date_of_shipping":"2018-03-21","addres":"moscow, ulica 942","order_status":5,"creation_time":"2018-01-29T00:00:00","source":"source942","prod_prod_id":201,"cust_cust_id":17,"man_man_id":558,"qua":71}
{"order_id":202,"date_of_shipping":"2018-11-29","addres":"moscow, ulica 202","order_status":1,"creation_time":"2018-05-09T00:00:00","source":"source202","prod_prod_id":811,"cust_cust_id":422,"man_man_id":337,"qua":7}
{"order_id":433,"date_of_shipping":"2018-05-13","addres":"moscow, ulica 433","order_status":2,"creation_time":"2017-06-14T00:00:00","source":"source433","prod_prod_id":897,"cust_cust_id":101,"man_man_id":187,"qua":70}
{"order_id":552,"date_of_shipping":"2017-05-08","addres":"moscow, ulica 552","order_status":1,"creation_time":"2017-05-02T00:00:00","source":"source552","prod_prod_id":845,"cust_cust_id":352,"man_man_id":69,"qua":54}
{"order_id":484,"date_of_shipping":"2018-04-25","addres":"moscow, ulica 484","order_status":3,"creation_time":"2017-03-16T00:00:00","source":"source484","prod_prod_id":799,"cust_cust_id":255,"man_man_id":877,"qua":40}
{"order_id":750,"date_of_shipping":"2017-09-03","addres":"moscow, ulica 750","order_status":1,"creation_time":"2017-12-19T00:00:00","source":"source750","prod_prod_id":328,"cust_cust_id":186,"man_man_id":572,"qua":14}
{"order_id":191,"date_of_shipping":"2018-10-10","addres":"moscow, ulica 191","order_status":4,"creation_time":"2017-11-09T00:00:00","source":"source191","prod_prod_id":556,"cust_cust_id":390,"man_man_id":524,"qua":37}
{"order_id":93,"date_of_shipping":"2017-12-03","addres":"moscow, ulica 93","order_status":5,"creation_time":"2017-12-02T00:00:00","source":"source93","prod_prod_id":632,"cust_cust_id":674,"man_man_id":346,"qua":36}
{"order_id":241,"date_of_shipping":"2017-10-19","addres":"moscow, ulica 241","order_status":1,"creation_time":"2017-05-24T00:00:00","source":"source241","prod_prod_id":879,"cust_cust_id":338,"man_man_id":442,"qua":6}
{"order_id":740,"date_of_shipping":"2017-06-11","addres":"moscow, ulica 740","order_status":4,"creation_time":"2017-12-29T00:00:00","source":"source740","prod_prod_id":810,"cust_cust_id":358,"man_man_id":930,"qua":76}
{"order_id":132,"date_of_shipping":"2017-03-29","addres":"moscow, ulica 132","order_status":4,"creation_time":"2017-08-27T00:00:00","source":"source132","prod_prod_id":341,"cust_cust_id":411,"man_man_id":91,"qua":35}
{"order_id":982,"date_of_shipping":"2017-09-05","addres":"moscow, ulica 982","order_status":1,"creation_time":"2018-07-26T00:00:00","source":"source982","prod_prod_id":984,"cust_cust_id":935,"man_man_id":210,"qua":23}
{"order_id":401,"date_of_shipping":"2017-02-17","addres":"moscow, ulica 401","order_status":1,"creation_time":"2018-01-07T00:00:00","source":"source401","prod_prod_id":349,"cust_cust_id":431,"man_man_id":515,"qua":42}
{"order_id":974,"date_of_shipping":"2018-06-04","addres":"moscow, ulica 974","order_status":5,"creation_time":"2017-10-19T00:00:00","source":"source974","prod_prod_id":934,"cust_cust_id":447,"man_man_id":459,"qua":29}
{"order_id":212,"date_of_shipping":"2018-08-15","addres":"moscow, ulica 212","order_status":1,"creation_time":"2017-06-11T00:00:00","source":"source212","prod_prod_id":370,"cust_cust_id":271,"man_man_id":216,"qua":4}
{"order_id":40,"date_of_shipping":"2018-06-21","addres":"moscow, ulica 40","order_status":5,"creation_time":"2018-08-05T00:00:00","source":"source40","prod_prod_id":59,"cust_cust_id":612,"man_man_id":781,"qua":89}
{"order_id":103,"date_of_shipping":"2018-04-08","addres":"moscow, ulica 103","order_status":5,"creation_time":"2017-01-12T00:00:00","source":"source103","prod_prod_id":634,"cust_cust_id":906,"man_man_id":229,"qua":39}
{"order_id":370,"date_of_shipping":"2018-01-05","addres":"moscow, ulica 370","order_status":3,"creation_time":"2018-08-03T00:00:00","source":"source370","prod_prod_id":878,"cust_cust_id":554,"man_man_id":962,"qua":58}
{"order_id":551,"date_of_shipping":"2018-07-05","addres":"moscow, ulica 551","order_status":2,"creation_time":"2018-09-09T00:00:00","source":"source551","prod_prod_id":334,"cust_cust_id":455,"man_man_id":757,"qua":10}
{"order_id":275,"date_of_shipping":"2018-06-27","addres":"moscow, ulica 275","order_status":3,"creation_time":"2018-06-30T00:00:00","source":"source275","prod_prod_id":47,"cust_cust_id":344,"man_man_id":138,"qua":46}
{"order_id":105,"date_of_shipping":"2017-04-12","addres":"moscow, ulica 105","order_status":4,"creation_time":"2017-04-30T00:00:00","source":"source105","prod_prod_id":776,"cust_cust_id":506,"man_man_id":790,"qua":98}
{"order_id":274,"date_of_shipping":"2018-01-16","addres":"moscow, ulica 274","order_status":4,"creation_time":"2018-09-22T00:00:00","source":"source274","prod_prod_id":545,"cust_cust_id":935,"man_man_id":207,"qua":55}
{"order_id":1000,"date_of_shipping":"2018-01-29","addres":"moscow, ulica 1000","order_status":2,"creation_time":"2018-08-16T00:00:00","source":"source1000","prod_prod_id":317,"cust_cust_id":292,"man_man_id":843,"qua":96}
{"order_id":791,"date_of_shipping":"2017-07-11","addres":"moscow, ulica 791","order_status":4,"creation_time":"2017-06-19T00:00:00","source":"source791","prod_prod_id":586,"cust_cust_id":567,"man_man_id":424,"qua":85}
{"order_id":238,"date_of_shipping":"2017-05-22","addres":"moscow, ulica 238","order_status":5,"creation_time":"2017-03-14T00:00:00","source":"source238","prod_prod_id":786,"cust_cust_id":900,"man_man_id":771,"qua":21}
{"order_id":36,"date_of_shipping":"2017-06-15","addres":"moscow, ulica 36","order_status":5,"creation_time":"2018-07-30T00:00:00","source":"source36","prod_prod_id":399,"cust_cust_id":789,"man_man_id":42,"qua":61}
{"order_id":629,"date_of_shipping":"2017-02-07","addres":"moscow, ulica 629","order_status":4,"creation_time":"2018-01-19T00:00:00","source":"source629","prod_prod_id":255,"cust_cust_id":948,"man_man_id":781,"qua":11}
{"order_id":531,"date_of_shipping":"2017-07-08","addres":"moscow, ulica 531","order_status":3,"creation_time":"2018-08-18T00:00:00","source":"source531","prod_prod_id":658,"cust_cust_id":900,"man_man_id":313,"qua":10}
{"order_id":972,"date_of_shipping":"2017-08-12","addres":"moscow, ulica 972","order_status":3,"creation_time":"2018-03-09T00:00:00","source":"source972","prod_prod_id":516,"cust_cust_id":757,"man_man_id":958,"qua":68}
{"order_id":500,"date_of_shipping":"2018-01-09","addres":"moscow, ulica 500","order_status":4,"creation_time":"2017-05-09T00:00:00","source":"source500","prod_prod_id":130,"cust_cust_id":368,"man_man_id":540,"qua":15}
{"order_id":864,"date_of_shipping":"2017-02-15","addres":"moscow, ulica 864","order_status":4,"creation_time":"2017-04-20T00:00:00","source":"source864","prod_prod_id":130,"cust_cust_id":47,"man_man_id":197,"qua":16}
{"order_id":79,"date_of_shipping":"2017-03-27","addres":"moscow, ulica 79","order_status":5,"creation_time":"2017-05-04T00:00:00","source":"source79","prod_prod_id":544,"cust_cust_id":406,"man_man_id":530,"qua":56}
{"order_id":597,"date_of_shipping":"2018-12-11","addres":"moscow, ulica 597","order_status":4,"creation_time":"2018-12-22T00:00:00","source":"source597","prod_prod_id":986,"cust_cust_id":77,"man_man_id":383,"qua":50}
{"order_id":746,"date_of_shipping":"2018-10-05","addres":"moscow, ulica 746","order_status":4,"creation_time":"2018-04-02T00:00:00","source":"source746","prod_prod_id":397,"cust_cust_id":306,"man_man_id":36,"qua":36}
{"order_id":845,"date_of_shipping":"2018-05-03","addres":"moscow, ulica 845","order_status":5,"creation_time":"2017-10-19T00:00:00","source":"source845","prod_prod_id":318,"cust_cust_id":387,"man_man_id":722,"qua":11}
{"order_id":945,"date_of_shipping":"2018-08-28","addres":"moscow, ulica 945","order_status":4,"creation_time":"2017-03-26T00:00:00","source":"source945","prod_prod_id":439,"cust_cust_id":449,"man_man_id":35,"qua":86}
{"order_id":106,"date_of_shipping":"2017-04-07","addres":"moscow, ulica 106","order_status":1,"creation_time":"2018-09-09T00:00:00","source":"source106","prod_prod_id":49,"cust_cust_id":930,"man_man_id":80,"qua":36}
{"order_id":376,"date_of_shipping":"2017-02-06","addres":"moscow, ulica 376","order_status":3,"creation_time":"2018-02-09T00:00:00","source":"source376","prod_prod_id":551,"cust_cust_id":975,"man_man_id":491,"qua":61}
{"order_id":476,"date_of_shipping":"2018-05-16","addres":"moscow, ulica 476","order_status":3,"creation_time":"2018-10-12T00:00:00","source":"source476","prod_prod_id":573,"cust_cust_id":486,"man_man_id":343,"qua":41}
{"order_id":537,"date_of_shipping":"2018-04-06","addres":"moscow, ulica 537","order_status":5,"creation_time":"2017-05-18T00:00:00","source":"source537","prod_prod_id":218,"cust_cust_id":644,"man_man_id":685,"qua":4}
{"order_id":979,"date_of_shipping":"2018-04-16","addres":"moscow, ulica 979","order_status":5,"creation_time":"2017-09-21T00:00:00","source":"source979","prod_prod_id":212,"cust_cust_id":786,"man_man_id":792,"qua":96}
{"order_id":650,"date_of_shipping":"2017-12-29","addres":"moscow, ulica 650","order_status":5,"creation_time":"2017-06-14T00:00:00","source":"source650","prod_prod_id":599,"cust_cust_id":2,"man_man_id":887,"qua":8}
{"order_id":194,"date_of_shipping":"2017-09-14","addres":"moscow, ulica 194","order_status":5,"creation_time":"2017-12-29T00:00:00","source":"source194","prod_prod_id":959,"cust_cust_id":473,"man_man_id":724,"qua":2}
{"order_id":265,"date_of_shipping":"2018-09-25","addres":"moscow, ulica 265","order_status":4,"creation_time":"2017-04-24T00:00:00","source":"source265","prod_prod_id":233,"cust_cust_id":977,"man_man_id":316,"qua":3}
{"order_id":74,"date_of_shipping":"2018-09-20","addres":"moscow, ulica 74","order_status":5,"creation_time":"2017-12-15T00:00:00","source":"source74","prod_prod_id":779,"cust_cust_id":752,"man_man_id":25,"qua":12}
{"order_id":892,"date_of_shipping":"2017-11-04","addres":"moscow, ulica 892","order_status":1,"creation_time":"2018-09-08T00:00:00","source":"source892","prod_prod_id":384,"cust_cust_id":80,"man_man_id":767,"qua":73}
{"order_id":233,"date_of_shipping":"2018-08-19","addres":"moscow, ulica 233","order_status":5,"creation_time":"2017-11-26T00:00:00","source":"source233","prod_prod_id":912,"cust_cust_id":365,"man_man_id":133,"qua":4}
{"order_id":635,"date_of_shipping":"2017-01-25","addres":"moscow, ulica 635","order_status":4,"creation_time":"2017-09-06T00:00:00","source":"source635","prod_prod_id":985,"cust_cust_id":938,"man_man_id":526,"qua":8}
{"order_id":535,"date_of_shipping":"2017-12-15","addres":"moscow, ulica 535","order_status":3,"creation_time":"2018-04-07T00:00:00","source":"source535","prod_prod_id":25,"cust_cust_id":827,"man_man_id":462,"qua":11}
{"order_id":639,"date_of_shipping":"2018-09-30","addres":"moscow, ulica 639","order_status":2,"creation_time":"2018-02-18T00:00:00","source":"source639","prod_prod_id":289,"cust_cust_id":736,"man_man_id":890,"qua":62}
{"order_id":804,"date_of_shipping":"2018-07-13","addres":"moscow, ulica 804","order_status":3,"creation_time":"2018-10-21T00:00:00","source":"source804","prod_prod_id":817,"cust_cust_id":791,"man_man_id":915,"qua":93}
{"order_id":474,"date_of_shipping":"2017-10-20","addres":"moscow, ulica 474","order_status":4,"creation_time":"2017-01-23T00:00:00","source":"source474","prod_prod_id":230,"cust_cust_id":655,"man_man_id":583,"qua":13}
{"order_id":429,"date_of_shipping":"2017-01-14","addres":"moscow, ulica 429","order_status":1,"creation_time":"2018-02-14T00:00:00","source":"source429","prod_prod_id":946,"cust_cust_id":449,"man_man_id":200,"qua":40}
{"order_id":299,"date_of_shipping":"2018-12-18","addres":"moscow, ulica 299","order_status":1,"creation_time":"2018-07-28T00:00:00","source":"source299","prod_prod_id":168,"cust_cust_id":218,"man_man_id":721,"qua":16}
{"order_id":863,"date_of_shipping":"2017-04-08","addres":"moscow, ulica 863","order_status":3,"creation_time":"2017-05-08T00:00:00","source":"source863","prod_prod_id":520,"cust_cust_id":81,"man_man_id":594,"qua":33}
{"order_id":335,"date_of_shipping":"2017-10-06","addres":"moscow, ulica 335","order_status":3,"creation_time":"2018-02-01T00:00:00","source":"source335","prod_prod_id":783,"cust_cust_id":1000,"man_man_id":685,"qua":42}
{"order_id":205,"date_of_shipping":"2018-03-28","addres":"moscow, ulica 205","order_status":1,"creation_time":"2017-03-07T00:00:00","source":"source205","prod_prod_id":420,"cust_cust_id":300,"man_man_id":278,"qua":19}
{"order_id":821,"date_of_shipping":"2017-03-14","addres":"moscow, ulica 821","order_status":4,"creation_time":"2017-10-30T00:00:00","source":"source821","prod_prod_id":864,"cust_cust_id":823,"man_man_id":415,"qua":93}
{"order_id":366,"date_of_shipping":"2017-11-24","addres":"moscow, ulica 366","order_status":3,"creation_time":"2018-03-31T00:00:00","source":"source366","prod_prod_id":337,"cust_cust_id":968,"man_man_id":757,"qua":30}
{"order_id":641,"date_of_shipping":"2018-02-13","addres":"moscow, ulica 641","order_status":1,"creation_time":"2017-11-22T00:00:00","source":"source641","prod_prod_id":505,"cust_cust_id":772,"man_man_id":899,"qua":58}
{"order_id":340,"date_of_shipping":"2017-12-24","addres":"moscow, ulica 340","order_status":4,"creation_time":"2017-07-14T00:00:00","source":"source340","prod_prod_id":612,"cust_cust_id":459,"man_man_id":942,"qua":31}
{"order_id":343,"date_of_shipping":"2017-07-04","addres":"moscow, ulica 343","order_status":5,"creation_time":"2018-12-12T00:00:00","source":"source343","prod_prod_id":259,"cust_cust_id":815,"man_man_id":570,"qua":42}
{"order_id":702,"date_of_shipping":"2017-03-25","addres":"moscow, ulica 702","order_status":3,"creation_time":"2017-03-28T00:00:00","source":"source702","prod_prod_id":146,"cust_cust_id":47,"man_man_id":740,"qua":26}
{"order_id":312,"date_of_shipping":"2017-06-06","addres":"moscow, ulica 312","order_status":3,"creation_time":"2018-01-25T00:00:00","source":"source312","prod_prod_id":313,"cust_cust_id":396,"man_man_id":734,"qua":47}
{"order_id":182,"date_of_shipping":"2017-02-17","addres":"moscow, ulica 182","order_status":1,"creation_time":"2018-11-21T00:00:00","source":"source182","prod_prod_id":524,"cust_cust_id":881,"man_man_id":422,"qua":23}
{"order_id":257,"date_of_shipping":"2017-04-10","addres":"moscow, ulica 257","order_status":4,"creation_time":"2018-07-14T00:00:00","source":"source257","prod_prod_id":217,"cust_cust_id":714,"man_man_id":175,"qua":42}
{"order_id":413,"date_of_shipping":"2017-02-21","addres":"moscow, ulica 413","order_status":1,"creation_time":"2018-05-17T00:00:00","source":"source413","prod_prod_id":366,"cust_cust_id":504,"man_man_id":510,"qua":28}
{"order_id":148,"date_of_shipping":"2017-01-26","addres":"moscow, ulica 148","order_status":3,"creation_time":"2018-11-12T00:00:00","source":"source148","prod_prod_id":498,"cust_cust_id":499,"man_man_id":332,"qua":20}
{"order_id":318,"date_of_shipping":"2018-01-05","addres":"moscow, ulica 318","order_status":3,"creation_time":"2018-12-19T00:00:00","source":"source318","prod_prod_id":553,"cust_cust_id":703,"man_man_id":166,"qua":19}
{"order_id":971,"date_of_shipping":"2018-11-03","addres":"moscow, ulica 971","order_status":2,"creation_time":"2017-01-27T00:00:00","source":"source971","prod_prod_id":183,"cust_cust_id":459,"man_man_id":452,"qua":39}
{"order_id":158,"date_of_shipping":"2018-04-27","addres":"moscow, ulica 158","order_status":1,"creation_time":"2018-07-27T00:00:00","source":"source158","prod_prod_id":588,"cust_cust_id":587,"man_man_id":310,"qua":20}
{"order_id":869,"date_of_shipping":"2017-07-25","addres":"moscow, ulica 869","order_status":4,"creation_time":"2018-11-27T00:00:00","source":"source869","prod_prod_id":580,"cust_cust_id":190,"man_man_id":717,"qua":99}
{"order_id":843,"date_of_shipping":"2018-09-28","addres":"moscow, ulica 843","order_status":1,"creation_time":"2017-09-22T00:00:00","source":"source843","prod_prod_id":15,"cust_cust_id":3,"man_man_id":656,"qua":58}
{"order_id":462,"date_of_shipping":"2018-09-17","addres":"moscow, ulica 462","order_status":4,"creation_time":"2018-04-05T00:00:00","source":"source462","prod_prod_id":763,"cust_cust_id":609,"man_man_id":483,"qua":28}
{"order_id":197,"date_of_shipping":"2017-01-13","addres":"moscow, ulica 197","order_status":3,"creation_time":"2018-06-23T00:00:00","source":"source197","prod_prod_id":375,"cust_cust_id":882,"man_man_id":605,"qua":19}
{"order_id":913,"date_of_shipping":"2018-04-02","addres":"moscow, ulica 913","order_status":1,"creation_time":"2018-12-12T00:00:00","source":"source913","prod_prod_id":803,"cust_cust_id":794,"man_man_id":2,"qua":81}
{"order_id":965,"date_of_shipping":"2017-03-10","addres":"moscow, ulica 965","order_status":1,"creation_time":"2017-06-24T00:00:00","source":"source965","prod_prod_id":844,"cust_cust_id":299,"man_man_id":141,"qua":39}
{"order_id":872,"date_of_shipping":"2018-06-24","addres":"moscow, ulica 872","order_status":5,"creation_time":"2018-02-24T00:00:00","source":"source872","prod_prod_id":363,"cust_cust_id":856,"man_man_id":435,"qua":12}
{"order_id":764,"date_of_shipping":"2017-06-05","addres":"moscow, ulica 764","order_status":3,"creation_time":"2017-08-20T00:00:00","source":"source764","prod_prod_id":366,"cust_cust_id":904,"man_man_id":232,"qua":62}
{"order_id":833,"date_of_shipping":"2017-10-06","addres":"moscow, ulica 833","order_status":4,"creation_time":"2017-03-30T00:00:00","source":"source833","prod_prod_id":291,"cust_cust_id":842,"man_man_id":908,"qua":56}
{"order_id":471,"date_of_shipping":"2018-08-26","addres":"moscow, ulica 471","order_status":4,"creation_time":"2018-02-11T00:00:00","source":"source471","prod_prod_id":391,"cust_cust_id":72,"man_man_id":14,"qua":24}
{"order_id":404,"date_of_shipping":"2017-10-11","addres":"moscow, ulica 404","order_status":2,"creation_time":"2018-11-12T00:00:00","source":"source404","prod_prod_id":807,"cust_cust_id":952,"man_man_id":623,"qua":26}
{"order_id":174,"date_of_shipping":"2018-04-13","addres":"moscow, ulica 174","order_status":1,"creation_time":"2018-02-08T00:00:00","source":"source174","prod_prod_id":568,"cust_cust_id":254,"man_man_id":646,"qua":32}
{"order_id":95,"date_of_shipping":"2017-08-15","addres":"moscow, ulica 95","order_status":2,"creation_time":"2017-07-10T00:00:00","source":"source95","prod_prod_id":302,"cust_cust_id":206,"man_man_id":168,"qua":66}
{"order_id":141,"date_of_shipping":"2018-05-16","addres":"moscow, ulica 141","order_status":3,"creation_time":"2018-03-06T00:00:00","source":"source141","prod_prod_id":837,"cust_cust_id":874,"man_man_id":726,"qua":33}
{"order_id":276,"date_of_shipping":"2017-07-12","addres":"moscow, ulica 276","order_status":1,"creation_time":"2017-11-11T00:00:00","source":"source276","prod_prod_id":76,"cust_cust_id":773,"man_man_id":756,"qua":30}
{"order_id":477,"date_of_shipping":"2017-09-05","addres":"moscow, ulica 477","order_status":1,"creation_time":"2018-10-29T00:00:00","source":"source477","prod_prod_id":952,"cust_cust_id":857,"man_man_id":721,"qua":55}
{"order_id":809,"date_of_shipping":"2018-06-28","addres":"moscow, ulica 809","order_status":5,"creation_time":"2018-06-28T00:00:00","source":"source809","prod_prod_id":621,"cust_cust_id":234,"man_man_id":847,"qua":24}
{"order_id":20,"date_of_shipping":"2018-10-29","addres":"moscow, ulica 20","order_status":2,"creation_time":"2018-03-08T00:00:00","source":"source20","prod_prod_id":637,"cust_cust_id":135,"man_man_id":936,"qua":37}
{"order_id":112,"date_of_shipping":"2018-02-12","addres":"moscow, ulica 112","order_status":3,"creation_time":"2018-07-28T00:00:00","source":"source112","prod_prod_id":519,"cust_cust_id":863,"man_man_id":550,"qua":23}
{"order_id":879,"date_of_shipping":"2018-05-19","addres":"moscow, ulica 879","order_status":3,"creation_time":"2017-10-01T00:00:00","source":"source879","prod_prod_id":789,"cust_cust_id":458,"man_man_id":812,"qua":90}
{"order_id":149,"date_of_shipping":"2018-11-10","addres":"moscow, ulica 149","order_status":2,"creation_time":"2017-03-31T00:00:00","source":"source149","prod_prod_id":637,"cust_cust_id":331,"man_man_id":355,"qua":33}
{"order_id":121,"date_of_shipping":"2017-12-11","addres":"moscow, ulica 121","order_status":1,"creation_time":"2017-11-20T00:00:00","source":"source121","prod_prod_id":574,"cust_cust_id":596,"man_man_id":732,"qua":35}
{"order_id":347,"date_of_shipping":"2017-03-01","addres":"moscow, ulica 347","order_status":1,"creation_time":"2017-03-23T00:00:00","source":"source347","prod_prod_id":980,"cust_cust_id":180,"man_man_id":134,"qua":31}
{"order_id":55,"date_of_shipping":"2018-03-19","addres":"moscow, ulica 55","order_status":3,"creation_time":"2017-07-10T00:00:00","source":"source55","prod_prod_id":804,"cust_cust_id":350,"man_man_id":583,"qua":8}
{"order_id":832,"date_of_shipping":"2017-07-06","addres":"moscow, ulica 832","order_status":5,"creation_time":"2017-01-22T00:00:00","source":"source832","prod_prod_id":805,"cust_cust_id":135,"man_man_id":665,"qua":58}
{"order_id":473,"date_of_shipping":"2017-11-27","addres":"moscow, ulica 473","order_status":5,"creation_time":"2017-10-27T00:00:00","source":"source473","prod_prod_id":77,"cust_cust_id":760,"man_man_id":329,"qua":73}
{"order_id":332,"date_of_shipping":"2018-06-10","addres":"moscow, ulica 332","order_status":1,"creation_time":"2017-12-21T00:00:00","source":"source332","prod_prod_id":676,"cust_cust_id":172,"man_man_id":673,"qua":19}
{"order_id":160,"date_of_shipping":"2017-04-18","addres":"moscow, ulica 160","order_status":5,"creation_time":"2018-11-06T00:00:00","source":"source160","prod_prod_id":768,"cust_cust_id":266,"man_man_id":20,"qua":21}
{"order_id":22,"date_of_shipping":"2017-12-12","addres":"moscow, ulica 22","order_status":5,"creation_time":"2018-01-04T00:00:00","source":"source22","prod_prod_id":271,"cust_cust_id":447,"man_man_id":677,"qua":96}
{"order_id":859,"date_of_shipping":"2018-09-17","addres":"moscow, ulica 859","order_status":4,"creation_time":"2017-04-14T00:00:00","source":"source859","prod_prod_id":603,"cust_cust_id":379,"man_man_id":731,"qua":57}
{"order_id":396,"date_of_shipping":"2017-09-25","addres":"moscow, ulica 396","order_status":5,"creation_time":"2017-06-06T00:00:00","source":"source396","prod_prod_id":231,"cust_cust_id":766,"man_man_id":581,"qua":55}
{"order_id":558,"date_of_shipping":"2017-04-26","addres":"moscow, ulica 558","order_status":5,"creation_time":"2017-04-28T00:00:00","source":"source558","prod_prod_id":913,"cust_cust_id":543,"man_man_id":155,"qua":50}
{"order_id":866,"date_of_shipping":"2017-07-15","addres":"moscow, ulica 866","order_status":5,"creation_time":"2017-06-06T00:00:00","source":"source866","prod_prod_id":469,"cust_cust_id":144,"man_man_id":73,"qua":48}
{"order_id":712,"date_of_shipping":"2018-12-27","addres":"moscow, ulica 712","order_status":5,"creation_time":"2017-08-03T00:00:00","source":"source712","prod_prod_id":324,"cust_cust_id":136,"man_man_id":441,"qua":3}
{"order_id":359,"date_of_shipping":"2018-10-13","addres":"moscow, ulica 359","order_status":5,"creation_time":"2018-12-26T00:00:00","source":"source359","prod_prod_id":170,"cust_cust_id":726,"man_man_id":668,"qua":31}
{"order_id":333,"date_of_shipping":"2017-07-08","addres":"moscow, ulica 333","order_status":5,"creation_time":"2018-06-16T00:00:00","source":"source333","prod_prod_id":253,"cust_cust_id":928,"man_man_id":366,"qua":41}
{"order_id":781,"date_of_shipping":"2018-04-01","addres":"moscow, ulica 781","order_status":4,"creation_time":"2018-07-16T00:00:00","source":"source781","prod_prod_id":229,"cust_cust_id":432,"man_man_id":877,"qua":98}
{"order_id":29,"date_of_shipping":"2017-11-16","addres":"moscow, ulica 29","order_status":5,"creation_time":"2017-07-09T00:00:00","source":"source29","prod_prod_id":571,"cust_cust_id":957,"man_man_id":797,"qua":97}
{"order_id":285,"date_of_shipping":"2017-02-04","addres":"moscow, ulica 285","order_status":1,"creation_time":"2018-12-17T00:00:00","source":"source285","prod_prod_id":862,"cust_cust_id":312,"man_man_id":520,"qua":23}
{"order_id":739,"date_of_shipping":"2017-09-29","addres":"moscow, ulica 739","order_status":4,"creation_time":"2017-06-25T00:00:00","source":"source739","prod_prod_id":141,"cust_cust_id":567,"man_man_id":933,"qua":60}
{"order_id":439,"date_of_shipping":"2018-01-12","addres":"moscow, ulica 439","order_status":1,"creation_time":"2017-02-18T00:00:00","source":"source439","prod_prod_id":864,"cust_cust_id":167,"man_man_id":133,"qua":41}
{"order_id":236,"date_of_shipping":"2017-07-27","addres":"moscow, ulica 236","order_status":1,"creation_time":"2018-05-26T00:00:00","source":"source236","prod_prod_id":873,"cust_cust_id":773,"man_man_id":618,"qua":16}
{"order_id":215,"date_of_shipping":"2017-07-03","addres":"moscow, ulica 215","order_status":5,"creation_time":"2017-07-27T00:00:00","source":"source215","prod_prod_id":92,"cust_cust_id":889,"man_man_id":897,"qua":44}
{"order_id":505,"date_of_shipping":"2018-04-25","addres":"moscow, ulica 505","order_status":2,"creation_time":"2017-04-25T00:00:00","source":"source505","prod_prod_id":933,"cust_cust_id":230,"man_man_id":868,"qua":24}
{"order_id":11,"date_of_shipping":"2017-02-10","addres":"moscow, ulica 11","order_status":3,"creation_time":"2017-10-02T00:00:00","source":"source11","prod_prod_id":451,"cust_cust_id":294,"man_man_id":875,"qua":23}
{"order_id":794,"date_of_shipping":"2017-11-30","addres":"moscow, ulica 794","order_status":5,"creation_time":"2018-03-03T00:00:00","source":"source794","prod_prod_id":168,"cust_cust_id":230,"man_man_id":780,"qua":99}
{"order_id":614,"date_of_shipping":"2018-05-05","addres":"moscow, ulica 614","order_status":5,"creation_time":"2018-02-25T00:00:00","source":"source614","prod_prod_id":973,"cust_cust_id":696,"man_man_id":913,"qua":48}
{"order_id":3,"date_of_shipping":"2017-01-12","addres":"moscow, ulica 3","order_status":5,"creation_time":"2017-06-01T00:00:00","source":"source3","prod_prod_id":822,"cust_cust_id":935,"man_man_id":153,"qua":41}
{"order_id":445,"date_of_shipping":"2018-12-08","addres":"moscow, ulica 445","order_status":3,"creation_time":"2017-03-21T00:00:00","source":"source445","prod_prod_id":335,"cust_cust_id":93,"man_man_id":952,"qua":41}
{"order_id":801,"date_of_shipping":"2017-02-04","addres":"moscow, ulica 801","order_status":4,"creation_time":"2018-09-26T00:00:00","source":"source801","prod_prod_id":906,"cust_cust_id":688,"man_man_id":635,"qua":43}
{"order_id":888,"date_of_shipping":"2018-10-02","addres":"moscow, ulica 888","order_status":1,"creation_time":"2018-04-16T00:00:00","source":"source888","prod_prod_id":414,"cust_cust_id":389,"man_man_id":387,"qua":1}
{"order_id":779,"date_of_shipping":"2017-10-08","addres":"moscow, ulica 779","order_status":4,"creation_time":"2018-06-20T00:00:00","source":"source779","prod_prod_id":78,"cust_cust_id":865,"man_man_id":29,"qua":36}
{"order_id":419,"date_of_shipping":"2017-11-05","addres":"moscow, ulica 419","order_status":2,"creation_time":"2017-12-21T00:00:00","source":"source419","prod_prod_id":907,"cust_cust_id":188,"man_man_id":690,"qua":26}
{"order_id":407,"date_of_shipping":"2017-10-20","addres":"moscow, ulica 407","order_status":3,"creation_time":"2018-10-10T00:00:00","source":"source407","prod_prod_id":784,"cust_cust_id":474,"man_man_id":336,"qua":39}
{"order_id":94,"date_of_shipping":"2017-07-02","addres":"moscow, ulica 94","order_status":3,"creation_time":"2018-10-03T00:00:00","source":"source94","prod_prod_id":209,"cust_cust_id":146,"man_man_id":897,"qua":20}
{"order_id":412,"date_of_shipping":"2017-10-29","addres":"moscow, ulica 412","order_status":4,"creation_time":"2017-08-18T00:00:00","source":"source412","prod_prod_id":422,"cust_cust_id":361,"man_man_id":48,"qua":2}
{"order_id":133,"date_of_shipping":"2017-11-09","addres":"moscow, ulica 133","order_status":5,"creation_time":"2018-01-12T00:00:00","source":"source133","prod_prod_id":621,"cust_cust_id":202,"man_man_id":483,"qua":19}
{"order_id":82,"date_of_shipping":"2018-06-22","addres":"moscow, ulica 82","order_status":5,"creation_time":"2018-09-11T00:00:00","source":"source82","prod_prod_id":253,"cust_cust_id":992,"man_man_id":722,"qua":41}
{"order_id":117,"date_of_shipping":"2017-09-09","addres":"moscow, ulica 117","order_status":3,"creation_time":"2017-07-21T00:00:00","source":"source117","prod_prod_id":899,"cust_cust_id":704,"man_man_id":629,"qua":80}
{"order_id":538,"date_of_shipping":"2017-09-11","addres":"moscow, ulica 538","order_status":4,"creation_time":"2018-08-13T00:00:00","source":"source538","prod_prod_id":137,"cust_cust_id":714,"man_man_id":732,"qua":14}
{"order_id":406,"date_of_shipping":"2018-02-07","addres":"moscow, ulica 406","order_status":2,"creation_time":"2017-03-06T00:00:00","source":"source406","prod_prod_id":993,"cust_cust_id":164,"man_man_id":312,"qua":42}
{"order_id":587,"date_of_shipping":"2017-05-20","addres":"moscow, ulica 587","order_status":3,"creation_time":"2017-10-08T00:00:00","source":"source587","prod_prod_id":913,"cust_cust_id":469,"man_man_id":709,"qua":33}
{"order_id":268,"date_of_shipping":"2017-12-31","addres":"moscow, ulica 268","order_status":3,"creation_time":"2018-01-03T00:00:00","source":"source268","prod_prod_id":967,"cust_cust_id":407,"man_man_id":581,"qua":28}
{"order_id":946,"date_of_shipping":"2017-04-11","addres":"moscow, ulica 946","order_status":4,"creation_time":"2018-02-08T00:00:00","source":"source946","prod_prod_id":686,"cust_cust_id":1000,"man_man_id":567,"qua":83}
{"order_id":724,"date_of_shipping":"2017-08-22","addres":"moscow, ulica 724","order_status":3,"creation_time":"2017-02-20T00:00:00","source":"source724","prod_prod_id":303,"cust_cust_id":161,"man_man_id":860,"qua":45}
{"order_id":556,"date_of_shipping":"2017-07-06","addres":"moscow, ulica 556","order_status":5,"creation_time":"2018-09-08T00:00:00","source":"source556","prod_prod_id":323,"cust_cust_id":26,"man_man_id":81,"qua":34}
{"order_id":243,"date_of_shipping":"2017-02-02","addres":"moscow, ulica 243","order_status":4,"creation_time":"2018-11-22T00:00:00","source":"source243","prod_prod_id":464,"cust_cust_id":289,"man_man_id":816,"qua":17}
{"order_id":307,"date_of_shipping":"2017-11-02","addres":"moscow, ulica 307","order_status":3,"creation_time":"2018-09-20T00:00:00","source":"source307","prod_prod_id":378,"cust_cust_id":612,"man_man_id":116,"qua":31}
{"order_id":630,"date_of_shipping":"2017-11-02","addres":"moscow, ulica 630","order_status":1,"creation_time":"2017-01-10T00:00:00","source":"source630","prod_prod_id":268,"cust_cust_id":378,"man_man_id":894,"qua":14}
{"order_id":628,"date_of_shipping":"2018-06-26","addres":"moscow, ulica 628","order_status":4,"creation_time":"2018-11-02T00:00:00","source":"source628","prod_prod_id":869,"cust_cust_id":957,"man_man_id":612,"qua":32}
{"order_id":539,"date_of_shipping":"2017-07-05","addres":"moscow, ulica 539","order_status":5,"creation_time":"2017-12-24T00:00:00","source":"source539","prod_prod_id":25,"cust_cust_id":354,"man_man_id":25,"qua":32}
{"order_id":258,"date_of_shipping":"2017-08-23","addres":"moscow, ulica 258","order_status":5,"creation_time":"2017-08-30T00:00:00","source":"source258","prod_prod_id":590,"cust_cust_id":677,"man_man_id":979,"qua":28}
{"order_id":409,"date_of_shipping":"2018-01-07","addres":"moscow, ulica 409","order_status":3,"creation_time":"2018-04-16T00:00:00","source":"source409","prod_prod_id":169,"cust_cust_id":863,"man_man_id":580,"qua":36}
{"order_id":852,"date_of_shipping":"2017-11-01","addres":"moscow, ulica 852","order_status":1,"creation_time":"2017-09-23T00:00:00","source":"source852","prod_prod_id":834,"cust_cust_id":467,"man_man_id":972,"qua":69}
{"order_id":19,"date_of_shipping":"2017-11-07","addres":"moscow, ulica 19","order_status":3,"creation_time":"2018-09-15T00:00:00","source":"source19","prod_prod_id":832,"cust_cust_id":843,"man_man_id":513,"qua":80}
{"order_id":797,"date_of_shipping":"2018-02-15","addres":"moscow, ulica 797","order_status":2,"creation_time":"2018-05-09T00:00:00","source":"source797","prod_prod_id":472,"cust_cust_id":356,"man_man_id":245,"qua":81}
{"order_id":27,"date_of_shipping":"2018-04-25","addres":"moscow, ulica 27","order_status":1,"creation_time":"2017-01-16T00:00:00","source":"source27","prod_prod_id":342,"cust_cust_id":138,"man_man_id":176,"qua":23}
{"order_id":988,"date_of_shipping":"2017-09-17","addres":"moscow, ulica 988","order_status":5,"creation_time":"2017-05-01T00:00:00","source":"source988","prod_prod_id":636,"cust_cust_id":589,"man_man_id":28,"qua":78}
{"order_id":871,"date_of_shipping":"2017-12-21","addres":"moscow, ulica 871","order_status":3,"creation_time":"2017-01-07T00:00:00","source":"source871","prod_prod_id":755,"cust_cust_id":3,"man_man_id":760,"qua":57}
{"order_id":808,"date_of_shipping":"2018-06-02","addres":"moscow, ulica 808","order_status":5,"creation_time":"2017-10-21T00:00:00","source":"source808","prod_prod_id":9,"cust_cust_id":906,"man_man_id":856,"qua":99}
{"order_id":834,"date_of_shipping":"2018-04-16","addres":"moscow, ulica 834","order_status":4,"creation_time":"2018-04-12T00:00:00","source":"source834","prod_prod_id":888,"cust_cust_id":603,"man_man_id":148,"qua":33}
{"order_id":651,"date_of_shipping":"2017-11-13","addres":"moscow, ulica 651","order_status":1,"creation_time":"2018-02-25T00:00:00","source":"source651","prod_prod_id":291,"cust_cust_id":948,"man_man_id":808,"qua":65}
{"order_id":438,"date_of_shipping":"2017-05-06","addres":"moscow, ulica 438","order_status":3,"creation_time":"2018-07-23T00:00:00","source":"source438","prod_prod_id":340,"cust_cust_id":41,"man_man_id":145,"qua":24}
{"order_id":660,"date_of_shipping":"2017-08-08","addres":"moscow, ulica 660","order_status":1,"creation_time":"2018-11-16T00:00:00","source":"source660","prod_prod_id":28,"cust_cust_id":231,"man_man_id":181,"qua":44}
{"order_id":115,"date_of_shipping":"2018-01-26","addres":"moscow, ulica 115","order_status":4,"creation_time":"2017-03-29T00:00:00","source":"source115","prod_prod_id":408,"cust_cust_id":324,"man_man_id":637,"qua":18}
{"order_id":762,"date_of_shipping":"2018-02-23","addres":"moscow, ulica 762","order_status":3,"creation_time":"2018-11-07T00:00:00","source":"source762","prod_prod_id":368,"cust_cust_id":10,"man_man_id":853,"qua":45}
{"order_id":501,"date_of_shipping":"2017-09-25","addres":"moscow, ulica 501","order_status":2,"creation_time":"2017-05-25T00:00:00","source":"source501","prod_prod_id":255,"cust_cust_id":699,"man_man_id":8,"qua":19}
{"order_id":669,"date_of_shipping":"2017-04-13","addres":"moscow, ulica 669","order_status":1,"creation_time":"2018-07-18T00:00:00","source":"source669","prod_prod_id":800,"cust_cust_id":904,"man_man_id":939,"qua":26}
{"order_id":341,"date_of_shipping":"2017-04-04","addres":"moscow, ulica 341","order_status":5,"creation_time":"2017-06-13T00:00:00","source":"source341","prod_prod_id":781,"cust_cust_id":346,"man_man_id":531,"qua":39}
{"order_id":405,"date_of_shipping":"2017-11-19","addres":"moscow, ulica 405","order_status":5,"creation_time":"2017-06-28T00:00:00","source":"source405","prod_prod_id":381,"cust_cust_id":331,"man_man_id":114,"qua":37}
{"order_id":694,"date_of_shipping":"2018-08-23","addres":"moscow, ulica 694","order_status":3,"creation_time":"2017-06-03T00:00:00","source":"source694","prod_prod_id":228,"cust_cust_id":186,"man_man_id":513,"qua":39}
{"order_id":873,"date_of_shipping":"2018-05-01","addres":"moscow, ulica 873","order_status":4,"creation_time":"2017-10-24T00:00:00","source":"source873","prod_prod_id":874,"cust_cust_id":717,"man_man_id":961,"qua":55}
{"order_id":198,"date_of_shipping":"2017-11-25","addres":"moscow, ulica 198","order_status":1,"creation_time":"2017-08-12T00:00:00","source":"source198","prod_prod_id":314,"cust_cust_id":832,"man_man_id":116,"qua":31}
{"order_id":329,"date_of_shipping":"2017-04-07","addres":"moscow, ulica 329","order_status":4,"creation_time":"2018-01-29T00:00:00","source":"source329","prod_prod_id":64,"cust_cust_id":351,"man_man_id":879,"qua":27}
{"order_id":84,"date_of_shipping":"2018-05-05","addres":"moscow, ulica 84","order_status":3,"creation_time":"2017-12-21T00:00:00","source":"source84","prod_prod_id":462,"cust_cust_id":231,"man_man_id":149,"qua":95}
{"order_id":354,"date_of_shipping":"2017-02-01","addres":"moscow, ulica 354","order_status":2,"creation_time":"2018-10-30T00:00:00","source":"source354","prod_prod_id":480,"cust_cust_id":468,"man_man_id":67,"qua":39}
{"order_id":252,"date_of_shipping":"2017-06-22","addres":"moscow, ulica 252","order_status":5,"creation_time":"2018-08-03T00:00:00","source":"source252","prod_prod_id":975,"cust_cust_id":765,"man_man_id":448,"qua":90}
{"order_id":453,"date_of_shipping":"2017-10-24","addres":"moscow, ulica 453","order_status":2,"creation_time":"2018-08-06T00:00:00","source":"source453","prod_prod_id":594,"cust_cust_id":258,"man_man_id":876,"qua":32}
{"order_id":616,"date_of_shipping":"2017-05-22","addres":"moscow, ulica 616","order_status":4,"creation_time":"2018-05-11T00:00:00","source":"source616","prod_prod_id":7,"cust_cust_id":424,"man_man_id":135,"qua":30}
{"order_id":488,"date_of_shipping":"2018-01-15","addres":"moscow, ulica 488","order_status":3,"creation_time":"2017-09-19T00:00:00","source":"source488","prod_prod_id":927,"cust_cust_id":878,"man_man_id":357,"qua":47}
{"order_id":122,"date_of_shipping":"2018-05-10","addres":"moscow, ulica 122","order_status":5,"creation_time":"2018-09-15T00:00:00","source":"source122","prod_prod_id":411,"cust_cust_id":185,"man_man_id":192,"qua":81}
{"order_id":327,"date_of_shipping":"2018-11-09","addres":"moscow, ulica 327","order_status":1,"creation_time":"2018-09-28T00:00:00","source":"source327","prod_prod_id":892,"cust_cust_id":208,"man_man_id":418,"qua":32}
{"order_id":528,"date_of_shipping":"2018-09-09","addres":"moscow, ulica 528","order_status":2,"creation_time":"2017-11-27T00:00:00","source":"source528","prod_prod_id":398,"cust_cust_id":386,"man_man_id":554,"qua":33}
{"order_id":717,"date_of_shipping":"2017-04-27","addres":"moscow, ulica 717","order_status":2,"creation_time":"2017-02-09T00:00:00","source":"source717","prod_prod_id":264,"cust_cust_id":79,"man_man_id":904,"qua":52}
{"order_id":856,"date_of_shipping":"2017-05-12","addres":"moscow, ulica 856","order_status":4,"creation_time":"2018-02-13T00:00:00","source":"source856","prod_prod_id":912,"cust_cust_id":125,"man_man_id":637,"qua":55}
{"order_id":416,"date_of_shipping":"2017-05-17","addres":"moscow, ulica 416","order_status":5,"creation_time":"2017-08-14T00:00:00","source":"source416","prod_prod_id":270,"cust_cust_id":131,"man_man_id":997,"qua":76}
{"order_id":68,"date_of_shipping":"2018-08-24","addres":"moscow, ulica 68","order_status":1,"creation_time":"2017-10-04T00:00:00","source":"source68","prod_prod_id":641,"cust_cust_id":367,"man_man_id":165,"qua":95}
{"order_id":929,"date_of_shipping":"2018-01-16","addres":"moscow, ulica 929","order_status":2,"creation_time":"2017-10-24T00:00:00","source":"source929","prod_prod_id":961,"cust_cust_id":311,"man_man_id":945,"qua":66}
{"order_id":840,"date_of_shipping":"2018-11-13","addres":"moscow, ulica 840","order_status":5,"creation_time":"2018-07-23T00:00:00","source":"source840","prod_prod_id":491,"cust_cust_id":368,"man_man_id":763,"qua":16}
{"order_id":85,"date_of_shipping":"2018-05-07","addres":"moscow, ulica 85","order_status":3,"creation_time":"2017-02-10T00:00:00","source":"source85","prod_prod_id":181,"cust_cust_id":936,"man_man_id":130,"qua":16}
{"order_id":759,"date_of_shipping":"2017-12-06","addres":"moscow, ulica 759","order_status":1,"creation_time":"2018-10-23T00:00:00","source":"source759","prod_prod_id":978,"cust_cust_id":11,"man_man_id":686,"qua":99}
{"order_id":155,"date_of_shipping":"2017-04-14","addres":"moscow, ulica 155","order_status":2,"creation_time":"2018-12-05T00:00:00","source":"source155","prod_prod_id":209,"cust_cust_id":49,"man_man_id":319,"qua":17}
{"order_id":824,"date_of_shipping":"2018-07-17","addres":"moscow, ulica 824","order_status":2,"creation_time":"2018-09-01T00:00:00","source":"source824","prod_prod_id":185,"cust_cust_id":501,"man_man_id":453,"qua":24}
{"order_id":909,"date_of_shipping":"2017-09-17","addres":"moscow, ulica 909","order_status":4,"creation_time":"2018-10-09T00:00:00","source":"source909","prod_prod_id":511,"cust_cust_id":905,"man_man_id":226,"qua":65}
{"order_id":736,"date_of_shipping":"2017-09-08","addres":"moscow, ulica 736","order_status":3,"creation_time":"2018-06-20T00:00:00","source":"source736","prod_prod_id":748,"cust_cust_id":178,"man_man_id":656,"qua":40}
{"order_id":754,"date_of_shipping":"2017-10-27","addres":"moscow, ulica 754","order_status":2,"creation_time":"2017-08-04T00:00:00","source":"source754","prod_prod_id":512,"cust_cust_id":63,"man_man_id":41,"qua":26}
{"order_id":608,"date_of_shipping":"2018-02-05","addres":"moscow, ulica 608","order_status":2,"creation_time":"2018-03-30T00:00:00","source":"source608","prod_prod_id":536,"cust_cust_id":357,"man_man_id":775,"qua":44}
{"order_id":786,"date_of_shipping":"2017-12-25","addres":"moscow, ulica 786","order_status":3,"creation_time":"2017-10-17T00:00:00","source":"source786","prod_prod_id":99,"cust_cust_id":277,"man_man_id":786,"qua":76}
{"order_id":451,"date_of_shipping":"2017-06-26","addres":"moscow, ulica 451","order_status":5,"creation_time":"2017-06-12T00:00:00","source":"source451","prod_prod_id":551,"cust_cust_id":561,"man_man_id":962,"qua":33}
{"order_id":644,"date_of_shipping":"2018-11-12","addres":"moscow, ulica 644","order_status":4,"creation_time":"2017-06-07T00:00:00","source":"source644","prod_prod_id":687,"cust_cust_id":489,"man_man_id":621,"qua":99}
{"order_id":136,"date_of_shipping":"2018-09-29","addres":"moscow, ulica 136","order_status":1,"creation_time":"2017-06-03T00:00:00","source":"source136","prod_prod_id":422,"cust_cust_id":164,"man_man_id":147,"qua":30}
{"order_id":119,"date_of_shipping":"2017-02-03","addres":"moscow, ulica 119","order_status":1,"creation_time":"2018-09-02T00:00:00","source":"source119","prod_prod_id":927,"cust_cust_id":85,"man_man_id":103,"qua":95}
{"order_id":582,"date_of_shipping":"2018-03-13","addres":"moscow, ulica 582","order_status":3,"creation_time":"2017-06-19T00:00:00","source":"source582","prod_prod_id":32,"cust_cust_id":706,"man_man_id":992,"qua":73}
{"order_id":619,"date_of_shipping":"2018-07-03","addres":"moscow, ulica 619","order_status":3,"creation_time":"2017-07-28T00:00:00","source":"source619","prod_prod_id":311,"cust_cust_id":371,"man_man_id":806,"qua":72}
{"order_id":719,"date_of_shipping":"2017-03-11","addres":"moscow, ulica 719","order_status":4,"creation_time":"2018-04-03T00:00:00","source":"source719","prod_prod_id":213,"cust_cust_id":996,"man_man_id":451,"qua":85}
{"order_id":937,"date_of_shipping":"2017-04-28","addres":"moscow, ulica 937","order_status":4,"creation_time":"2018-04-04T00:00:00","source":"source937","prod_prod_id":203,"cust_cust_id":587,"man_man_id":650,"qua":94}
{"order_id":911,"date_of_shipping":"2017-02-01","addres":"moscow, ulica 911","order_status":3,"creation_time":"2017-10-04T00:00:00","source":"source911","prod_prod_id":681,"cust_cust_id":772,"man_man_id":202,"qua":1}
{"order_id":850,"date_of_shipping":"2017-05-29","addres":"moscow, ulica 850","order_status":2,"creation_time":"2017-05-15T00:00:00","source":"source850","prod_prod_id":941,"cust_cust_id":550,"man_man_id":675,"qua":51}
{"order_id":818,"date_of_shipping":"2018-02-22","addres":"moscow, ulica 818","order_status":5,"creation_time":"2018-01-28T00:00:00","source":"source818","prod_prod_id":596,"cust_cust_id":41,"man_man_id":842,"qua":83}
{"order_id":788,"date_of_shipping":"2018-06-09","addres":"moscow, ulica 788","order_status":3,"creation_time":"2018-01-23T00:00:00","source":"source788","prod_prod_id":820,"cust_cust_id":969,"man_man_id":26,"qua":83}
{"order_id":81,"date_of_shipping":"2017-12-24","addres":"moscow, ulica 81","order_status":2,"creation_time":"2017-05-21T00:00:00","source":"source81","prod_prod_id":360,"cust_cust_id":82,"man_man_id":155,"qua":17}
{"order_id":529,"date_of_shipping":"2017-07-09","addres":"moscow, ulica 529","order_status":3,"creation_time":"2018-11-01T00:00:00","source":"source529","prod_prod_id":899,"cust_cust_id":331,"man_man_id":867,"qua":74}
{"order_id":219,"date_of_shipping":"2018-03-06","addres":"moscow, ulica 219","order_status":2,"creation_time":"2018-01-09T00:00:00","source":"source219","prod_prod_id":375,"cust_cust_id":866,"man_man_id":195,"qua":29}
{"order_id":774,"date_of_shipping":"2017-10-17","addres":"moscow, ulica 774","order_status":2,"creation_time":"2018-07-10T00:00:00","source":"source774","prod_prod_id":309,"cust_cust_id":805,"man_man_id":317,"qua":53}
{"order_id":227,"date_of_shipping":"2017-11-30","addres":"moscow, ulica 227","order_status":1,"creation_time":"2017-08-06T00:00:00","source":"source227","prod_prod_id":181,"cust_cust_id":80,"man_man_id":215,"qua":71}
{"order_id":943,"date_of_shipping":"2018-01-22","addres":"moscow, ulica 943","order_status":5,"creation_time":"2017-01-10T00:00:00","source":"source943","prod_prod_id":595,"cust_cust_id":769,"man_man_id":126,"qua":52}
{"order_id":805,"date_of_shipping":"2018-11-27","addres":"moscow, ulica 805","order_status":1,"creation_time":"2018-02-14T00:00:00","source":"source805","prod_prod_id":820,"cust_cust_id":558,"man_man_id":675,"qua":55}
{"order_id":954,"date_of_shipping":"2017-09-28","addres":"moscow, ulica 954","order_status":4,"creation_time":"2018-04-28T00:00:00","source":"source954","prod_prod_id":556,"cust_cust_id":767,"man_man_id":406,"qua":12}
{"order_id":502,"date_of_shipping":"2018-05-02","addres":"moscow, ulica 502","order_status":1,"creation_time":"2018-05-27T00:00:00","source":"source502","prod_prod_id":192,"cust_cust_id":164,"man_man_id":467,"qua":79}
{"order_id":226,"date_of_shipping":"2017-06-14","addres":"moscow, ulica 226","order_status":4,"creation_time":"2018-10-05T00:00:00","source":"source226","prod_prod_id":875,"cust_cust_id":309,"man_man_id":952,"qua":28}
{"order_id":906,"date_of_shipping":"2018-04-26","addres":"moscow, ulica 906","order_status":5,"creation_time":"2018-09-18T00:00:00","source":"source906","prod_prod_id":685,"cust_cust_id":534,"man_man_id":59,"qua":1}
{"order_id":13,"date_of_shipping":"2017-06-01","addres":"moscow, ulica 13","order_status":2,"creation_time":"2017-08-30T00:00:00","source":"source13","prod_prod_id":257,"cust_cust_id":562,"man_man_id":469,"qua":16}
{"order_id":147,"date_of_shipping":"2018-10-09","addres":"moscow, ulica 147","order_status":2,"creation_time":"2017-09-23T00:00:00","source":"source147","prod_prod_id":562,"cust_cust_id":955,"man_man_id":919,"qua":91}
{"order_id":707,"date_of_shipping":"2017-12-06","addres":"moscow, ulica 707","order_status":5,"creation_time":"2017-10-06T00:00:00","source":"source707","prod_prod_id":416,"cust_cust_id":830,"man_man_id":645,"qua":85}
{"order_id":615,"date_of_shipping":"2017-06-26","addres":"moscow, ulica 615","order_status":3,"creation_time":"2017-02-28T00:00:00","source":"source615","prod_prod_id":775,"cust_cust_id":481,"man_man_id":416,"qua":45}
{"order_id":294,"date_of_shipping":"2017-06-17","addres":"moscow, ulica 294","order_status":1,"creation_time":"2018-07-15T00:00:00","source":"source294","prod_prod_id":868,"cust_cust_id":383,"man_man_id":525,"qua":26}
{"order_id":710,"date_of_shipping":"2018-03-15","addres":"moscow, ulica 710","order_status":4,"creation_time":"2018-01-01T00:00:00","source":"source710","prod_prod_id":761,"cust_cust_id":561,"man_man_id":65,"qua":66}
{"order_id":189,"date_of_shipping":"2017-03-10","addres":"moscow, ulica 189","order_status":2,"creation_time":"2017-06-12T00:00:00","source":"source189","prod_prod_id":790,"cust_cust_id":687,"man_man_id":677,"qua":90}
{"order_id":513,"date_of_shipping":"2018-07-17","addres":"moscow, ulica 513","order_status":2,"creation_time":"2018-12-20T00:00:00","source":"source513","prod_prod_id":457,"cust_cust_id":958,"man_man_id":357,"qua":72}
{"order_id":983,"date_of_shipping":"2018-11-15","addres":"moscow, ulica 983","order_status":3,"creation_time":"2018-09-29T00:00:00","source":"source983","prod_prod_id":277,"cust_cust_id":229,"man_man_id":912,"qua":62}
{"order_id":352,"date_of_shipping":"2018-09-24","addres":"moscow, ulica 352","order_status":5,"creation_time":"2017-12-19T00:00:00","source":"source352","prod_prod_id":48,"cust_cust_id":450,"man_man_id":977,"qua":65}
{"order_id":870,"date_of_shipping":"2018-06-19","addres":"moscow, ulica 870","order_status":3,"creation_time":"2018-02-01T00:00:00","source":"source870","prod_prod_id":952,"cust_cust_id":85,"man_man_id":185,"qua":36}
{"order_id":457,"date_of_shipping":"2017-06-14","addres":"moscow, ulica 457","order_status":4,"creation_time":"2017-03-02T00:00:00","source":"source457","prod_prod_id":298,"cust_cust_id":811,"man_man_id":993,"qua":77}
{"order_id":555,"date_of_shipping":"2018-07-16","addres":"moscow, ulica 555","order_status":5,"creation_time":"2017-08-06T00:00:00","source":"source555","prod_prod_id":889,"cust_cust_id":981,"man_man_id":487,"qua":46}
{"order_id":554,"date_of_shipping":"2018-09-21","addres":"moscow, ulica 554","order_status":2,"creation_time":"2017-08-27T00:00:00","source":"source554","prod_prod_id":595,"cust_cust_id":556,"man_man_id":171,"qua":46}
{"order_id":67,"date_of_shipping":"2017-12-24","addres":"moscow, ulica 67","order_status":5,"creation_time":"2018-09-02T00:00:00","source":"source67","prod_prod_id":448,"cust_cust_id":452,"man_man_id":183,"qua":93}
{"order_id":527,"date_of_shipping":"2017-02-21","addres":"moscow, ulica 527","order_status":5,"creation_time":"2017-06-11T00:00:00","source":"source527","prod_prod_id":632,"cust_cust_id":269,"man_man_id":609,"qua":72}
{"order_id":895,"date_of_shipping":"2018-02-03","addres":"moscow, ulica 895","order_status":5,"creation_time":"2018-06-27T00:00:00","source":"source895","prod_prod_id":898,"cust_cust_id":758,"man_man_id":577,"qua":52}
{"order_id":940,"date_of_shipping":"2017-07-22","addres":"moscow, ulica 940","order_status":2,"creation_time":"2018-11-28T00:00:00","source":"source940","prod_prod_id":547,"cust_cust_id":712,"man_man_id":509,"qua":51}
{"order_id":656,"date_of_shipping":"2017-10-08","addres":"moscow, ulica 656","order_status":2,"creation_time":"2018-05-13T00:00:00","source":"source656","prod_prod_id":937,"cust_cust_id":144,"man_man_id":511,"qua":84}
{"order_id":584,"date_of_shipping":"2018-11-21","addres":"moscow, ulica 584","order_status":4,"creation_time":"2017-07-14T00:00:00","source":"source584","prod_prod_id":430,"cust_cust_id":285,"man_man_id":979,"qua":73}
{"order_id":708,"date_of_shipping":"2018-04-15","addres":"moscow, ulica 708","order_status":1,"creation_time":"2018-02-02T00:00:00","source":"source708","prod_prod_id":382,"cust_cust_id":954,"man_man_id":494,"qua":23}
{"order_id":154,"date_of_shipping":"2018-11-21","addres":"moscow, ulica 154","order_status":2,"creation_time":"2017-01-03T00:00:00","source":"source154","prod_prod_id":498,"cust_cust_id":202,"man_man_id":251,"qua":31}
{"order_id":799,"date_of_shipping":"2018-09-09","addres":"moscow, ulica 799","order_status":2,"creation_time":"2018-09-26T00:00:00","source":"source799","prod_prod_id":209,"cust_cust_id":215,"man_man_id":7,"qua":54}
{"order_id":673,"date_of_shipping":"2017-12-06","addres":"moscow, ulica 673","order_status":3,"creation_time":"2018-08-19T00:00:00","source":"source673","prod_prod_id":730,"cust_cust_id":75,"man_man_id":158,"qua":40}
{"order_id":637,"date_of_shipping":"2017-01-08","addres":"moscow, ulica 637","order_status":5,"creation_time":"2018-12-04T00:00:00","source":"source637","prod_prod_id":32,"cust_cust_id":104,"man_man_id":374,"qua":45}
{"order_id":161,"date_of_shipping":"2018-02-04","addres":"moscow, ulica 161","order_status":3,"creation_time":"2018-02-24T00:00:00","source":"source161","prod_prod_id":957,"cust_cust_id":257,"man_man_id":202,"qua":31}
{"order_id":159,"date_of_shipping":"2018-06-19","addres":"moscow, ulica 159","order_status":3,"creation_time":"2017-04-20T00:00:00","source":"source159","prod_prod_id":993,"cust_cust_id":728,"man_man_id":564,"qua":31}
{"order_id":211,"date_of_shipping":"2018-12-02","addres":"moscow, ulica 211","order_status":2,"creation_time":"2018-04-13T00:00:00","source":"source211","prod_prod_id":362,"cust_cust_id":781,"man_man_id":772,"qua":69}
{"order_id":220,"date_of_shipping":"2018-06-04","addres":"moscow, ulica 220","order_status":1,"creation_time":"2017-02-14T00:00:00","source":"source220","prod_prod_id":968,"cust_cust_id":21,"man_man_id":666,"qua":38}
{"order_id":761,"date_of_shipping":"2017-04-10","addres":"moscow, ulica 761","order_status":4,"creation_time":"2018-11-25T00:00:00","source":"source761","prod_prod_id":489,"cust_cust_id":140,"man_man_id":794,"qua":8}
{"order_id":696,"date_of_shipping":"2018-11-13","addres":"moscow, ulica 696","order_status":2,"creation_time":"2018-06-12T00:00:00","source":"source696","prod_prod_id":328,"cust_cust_id":207,"man_man_id":854,"qua":10}
{"order_id":685,"date_of_shipping":"2017-06-20","addres":"moscow, ulica 685","order_status":3,"creation_time":"2018-11-13T00:00:00","source":"source685","prod_prod_id":46,"cust_cust_id":689,"man_man_id":492,"qua":28}
{"order_id":292,"date_of_shipping":"2017-03-07","addres":"moscow, ulica 292","order_status":4,"creation_time":"2017-06-17T00:00:00","source":"source292","prod_prod_id":171,"cust_cust_id":744,"man_man_id":308,"qua":39}
{"order_id":128,"date_of_shipping":"2017-06-02","addres":"moscow, ulica 128","order_status":5,"creation_time":"2018-11-12T00:00:00","source":"source128","prod_prod_id":438,"cust_cust_id":150,"man_man_id":363,"qua":88}
{"order_id":842,"date_of_shipping":"2018-05-08","addres":"moscow, ulica 842","order_status":5,"creation_time":"2017-03-21T00:00:00","source":"source842","prod_prod_id":201,"cust_cust_id":455,"man_man_id":124,"qua":74}
{"order_id":790,"date_of_shipping":"2017-04-04","addres":"moscow, ulica 790","order_status":4,"creation_time":"2017-08-15T00:00:00","source":"source790","prod_prod_id":830,"cust_cust_id":666,"man_man_id":621,"qua":97}
{"order_id":732,"date_of_shipping":"2018-11-26","addres":"moscow, ulica 732","order_status":4,"creation_time":"2018-01-17T00:00:00","source":"source732","prod_prod_id":884,"cust_cust_id":465,"man_man_id":352,"qua":71}
{"order_id":532,"date_of_shipping":"2017-03-02","addres":"moscow, ulica 532","order_status":5,"creation_time":"2017-02-10T00:00:00","source":"source532","prod_prod_id":143,"cust_cust_id":493,"man_man_id":617,"qua":17}
{"order_id":601,"date_of_shipping":"2017-07-28","addres":"moscow, ulica 601","order_status":4,"creation_time":"2018-03-20T00:00:00","source":"source601","prod_prod_id":243,"cust_cust_id":585,"man_man_id":377,"qua":42}
{"order_id":169,"date_of_shipping":"2018-01-30","addres":"moscow, ulica 169","order_status":2,"creation_time":"2018-02-05T00:00:00","source":"source169","prod_prod_id":234,"cust_cust_id":65,"man_man_id":542,"qua":91}
{"order_id":591,"date_of_shipping":"2018-02-06","addres":"moscow, ulica 591","order_status":5,"creation_time":"2017-04-30T00:00:00","source":"source591","prod_prod_id":326,"cust_cust_id":64,"man_man_id":928,"qua":87}
{"order_id":206,"date_of_shipping":"2018-02-24","addres":"moscow, ulica 206","order_status":1,"creation_time":"2017-06-24T00:00:00","source":"source206","prod_prod_id":244,"cust_cust_id":807,"man_man_id":554,"qua":38}
{"order_id":569,"date_of_shipping":"2017-10-31","addres":"moscow, ulica 569","order_status":2,"creation_time":"2017-01-17T00:00:00","source":"source569","prod_prod_id":599,"cust_cust_id":652,"man_man_id":532,"qua":19}
{"order_id":177,"date_of_shipping":"2017-03-04","addres":"moscow, ulica 177","order_status":4,"creation_time":"2018-11-22T00:00:00","source":"source177","prod_prod_id":592,"cust_cust_id":90,"man_man_id":581,"qua":17}
{"order_id":278,"date_of_shipping":"2018-11-09","addres":"moscow, ulica 278","order_status":2,"creation_time":"2017-12-13T00:00:00","source":"source278","prod_prod_id":351,"cust_cust_id":952,"man_man_id":849,"qua":37}
{"order_id":143,"date_of_shipping":"2017-01-02","addres":"moscow, ulica 143","order_status":5,"creation_time":"2017-05-29T00:00:00","source":"source143","prod_prod_id":10,"cust_cust_id":115,"man_man_id":803,"qua":68}
{"order_id":817,"date_of_shipping":"2018-03-20","addres":"moscow, ulica 817","order_status":3,"creation_time":"2017-06-13T00:00:00","source":"source817","prod_prod_id":15,"cust_cust_id":52,"man_man_id":859,"qua":57}
{"order_id":417,"date_of_shipping":"2018-03-08","addres":"moscow, ulica 417","order_status":1,"creation_time":"2017-03-20T00:00:00","source":"source417","prod_prod_id":181,"cust_cust_id":170,"man_man_id":549,"qua":68}
{"order_id":242,"date_of_shipping":"2017-01-24","addres":"moscow, ulica 242","order_status":3,"creation_time":"2017-08-10T00:00:00","source":"source242","prod_prod_id":237,"cust_cust_id":428,"man_man_id":616,"qua":69}
{"order_id":88,"date_of_shipping":"2018-07-08","addres":"moscow, ulica 88","order_status":3,"creation_time":"2017-06-30T00:00:00","source":"source88","prod_prod_id":954,"cust_cust_id":727,"man_man_id":247,"qua":91}
{"order_id":559,"date_of_shipping":"2018-07-09","addres":"moscow, ulica 559","order_status":2,"creation_time":"2017-12-03T00:00:00","source":"source559","prod_prod_id":348,"cust_cust_id":983,"man_man_id":907,"qua":32}
{"order_id":393,"date_of_shipping":"2018-04-17","addres":"moscow, ulica 393","order_status":2,"creation_time":"2018-05-07T00:00:00","source":"source393","prod_prod_id":851,"cust_cust_id":773,"man_man_id":331,"qua":46}
{"order_id":362,"date_of_shipping":"2017-03-05","addres":"moscow, ulica 362","order_status":3,"creation_time":"2018-06-20T00:00:00","source":"source362","prod_prod_id":361,"cust_cust_id":987,"man_man_id":974,"qua":26}
{"order_id":422,"date_of_shipping":"2018-07-16","addres":"moscow, ulica 422","order_status":3,"creation_time":"2017-04-01T00:00:00","source":"source422","prod_prod_id":299,"cust_cust_id":852,"man_man_id":512,"qua":33}
{"order_id":260,"date_of_shipping":"2017-04-29","addres":"moscow, ulica 260","order_status":3,"creation_time":"2017-09-16T00:00:00","source":"source260","prod_prod_id":282,"cust_cust_id":790,"man_man_id":619,"qua":22}
{"order_id":468,"date_of_shipping":"2017-02-14","addres":"moscow, ulica 468","order_status":5,"creation_time":"2018-05-06T00:00:00","source":"source468","prod_prod_id":927,"cust_cust_id":47,"man_man_id":306,"qua":4}
{"order_id":789,"date_of_shipping":"2017-01-23","addres":"moscow, ulica 789","order_status":1,"creation_time":"2017-08-21T00:00:00","source":"source789","prod_prod_id":204,"cust_cust_id":755,"man_man_id":84,"qua":53}
{"order_id":785,"date_of_shipping":"2018-09-25","addres":"moscow, ulica 785","order_status":5,"creation_time":"2017-10-24T00:00:00","source":"source785","prod_prod_id":267,"cust_cust_id":232,"man_man_id":669,"qua":22}
{"order_id":435,"date_of_shipping":"2018-01-15","addres":"moscow, ulica 435","order_status":1,"creation_time":"2018-10-31T00:00:00","source":"source435","prod_prod_id":20,"cust_cust_id":98,"man_man_id":635,"qua":32}
{"order_id":33,"date_of_shipping":"2017-08-01","addres":"moscow, ulica 33","order_status":5,"creation_time":"2017-01-08T00:00:00","source":"source33","prod_prod_id":250,"cust_cust_id":628,"man_man_id":711,"qua":1}
{"order_id":578,"date_of_shipping":"2017-01-27","addres":"moscow, ulica 578","order_status":3,"creation_time":"2017-12-09T00:00:00","source":"source578","prod_prod_id":359,"cust_cust_id":810,"man_man_id":464,"qua":79}
{"order_id":338,"date_of_shipping":"2018-01-07","addres":"moscow, ulica 338","order_status":5,"creation_time":"2017-01-14T00:00:00","source":"source338","prod_prod_id":991,"cust_cust_id":7,"man_man_id":355,"qua":20}
{"order_id":936,"date_of_shipping":"2018-10-30","addres":"moscow, ulica 936","order_status":5,"creation_time":"2018-09-02T00:00:00","source":"source936","prod_prod_id":211,"cust_cust_id":608,"man_man_id":595,"qua":53}
{"order_id":466,"date_of_shipping":"2017-01-27","addres":"moscow, ulica 466","order_status":5,"creation_time":"2017-11-14T00:00:00","source":"source466","prod_prod_id":85,"cust_cust_id":116,"man_man_id":548,"qua":34}
{"order_id":234,"date_of_shipping":"2018-10-03","addres":"moscow, ulica 234","order_status":1,"creation_time":"2017-08-22T00:00:00","source":"source234","prod_prod_id":88,"cust_cust_id":851,"man_man_id":306,"qua":66}
{"order_id":14,"date_of_shipping":"2017-06-18","addres":"moscow, ulica 14","order_status":2,"creation_time":"2018-08-03T00:00:00","source":"source14","prod_prod_id":669,"cust_cust_id":505,"man_man_id":390,"qua":90}
{"order_id":15,"date_of_shipping":"2018-07-01","addres":"moscow, ulica 15","order_status":3,"creation_time":"2018-09-19T00:00:00","source":"source15","prod_prod_id":387,"cust_cust_id":765,"man_man_id":634,"qua":1}
{"order_id":701,"date_of_shipping":"2017-12-12","addres":"moscow, ulica 701","order_status":5,"creation_time":"2018-11-23T00:00:00","source":"source701","prod_prod_id":201,"cust_cust_id":221,"man_man_id":68,"qua":84}
{"order_id":568,"date_of_shipping":"2017-08-10","addres":"moscow, ulica 568","order_status":3,"creation_time":"2017-03-16T00:00:00","source":"source568","prod_prod_id":212,"cust_cust_id":159,"man_man_id":288,"qua":72}
{"order_id":918,"date_of_shipping":"2018-12-22","addres":"moscow, ulica 918","order_status":1,"creation_time":"2017-03-12T00:00:00","source":"source918","prod_prod_id":71,"cust_cust_id":553,"man_man_id":972,"qua":63}
{"order_id":541,"date_of_shipping":"2018-11-04","addres":"moscow, ulica 541","order_status":5,"creation_time":"2017-01-05T00:00:00","source":"source541","prod_prod_id":923,"cust_cust_id":813,"man_man_id":309,"qua":73}
{"order_id":253,"date_of_shipping":"2017-09-30","addres":"moscow, ulica 253","order_status":5,"creation_time":"2017-10-17T00:00:00","source":"source253","prod_prod_id":838,"cust_cust_id":854,"man_man_id":537,"qua":10}
{"order_id":424,"date_of_shipping":"2018-12-01","addres":"moscow, ulica 424","order_status":1,"creation_time":"2018-11-05T00:00:00","source":"source424","prod_prod_id":19,"cust_cust_id":67,"man_man_id":101,"qua":18}
{"order_id":361,"date_of_shipping":"2018-06-08","addres":"moscow, ulica 361","order_status":2,"creation_time":"2018-01-07T00:00:00","source":"source361","prod_prod_id":447,"cust_cust_id":98,"man_man_id":855,"qua":35}
{"order_id":358,"date_of_shipping":"2017-04-29","addres":"moscow, ulica 358","order_status":1,"creation_time":"2018-03-11T00:00:00","source":"source358","prod_prod_id":563,"cust_cust_id":495,"man_man_id":878,"qua":76}
{"order_id":721,"date_of_shipping":"2018-01-30","addres":"moscow, ulica 721","order_status":1,"creation_time":"2017-03-17T00:00:00","source":"source721","prod_prod_id":726,"cust_cust_id":622,"man_man_id":808,"qua":81}
{"order_id":266,"date_of_shipping":"2018-09-20","addres":"moscow, ulica 266","order_status":2,"creation_time":"2017-11-19T00:00:00","source":"source266","prod_prod_id":808,"cust_cust_id":915,"man_man_id":431,"qua":34}
{"order_id":858,"date_of_shipping":"2017-01-31","addres":"moscow, ulica 858","order_status":3,"creation_time":"2017-03-23T00:00:00","source":"source858","prod_prod_id":485,"cust_cust_id":584,"man_man_id":637,"qua":20}
{"order_id":634,"date_of_shipping":"2017-09-11","addres":"moscow, ulica 634","order_status":4,"creation_time":"2018-01-21T00:00:00","source":"source634","prod_prod_id":567,"cust_cust_id":394,"man_man_id":690,"qua":49}
{"order_id":390,"date_of_shipping":"2018-07-28","addres":"moscow, ulica 390","order_status":4,"creation_time":"2017-04-21T00:00:00","source":"source390","prod_prod_id":807,"cust_cust_id":202,"man_man_id":307,"qua":35}
{"order_id":741,"date_of_shipping":"2018-05-05","addres":"moscow, ulica 741","order_status":5,"creation_time":"2017-10-28T00:00:00","source":"source741","prod_prod_id":330,"cust_cust_id":562,"man_man_id":740,"qua":42}
{"order_id":606,"date_of_shipping":"2017-10-24","addres":"moscow, ulica 606","order_status":2,"creation_time":"2018-07-23T00:00:00","source":"source606","prod_prod_id":192,"cust_cust_id":273,"man_man_id":223,"qua":40}
{"order_id":297,"date_of_shipping":"2018-04-05","addres":"moscow, ulica 297","order_status":1,"creation_time":"2018-07-22T00:00:00","source":"source297","prod_prod_id":978,"cust_cust_id":258,"man_man_id":340,"qua":65}
{"order_id":820,"date_of_shipping":"2018-06-30","addres":"moscow, ulica 820","order_status":4,"creation_time":"2017-09-23T00:00:00","source":"source820","prod_prod_id":907,"cust_cust_id":315,"man_man_id":532,"qua":62}
{"order_id":865,"date_of_shipping":"2017-06-23","addres":"moscow, ulica 865","order_status":3,"creation_time":"2018-11-15T00:00:00","source":"source865","prod_prod_id":934,"cust_cust_id":393,"man_man_id":123,"qua":92}
{"order_id":499,"date_of_shipping":"2018-02-05","addres":"moscow, ulica 499","order_status":3,"creation_time":"2018-01-28T00:00:00","source":"source499","prod_prod_id":898,"cust_cust_id":824,"man_man_id":534,"qua":75}
{"order_id":302,"date_of_shipping":"2017-02-25","addres":"moscow, ulica 302","order_status":5,"creation_time":"2018-09-11T00:00:00","source":"source302","prod_prod_id":291,"cust_cust_id":688,"man_man_id":223,"qua":51}
{"order_id":990,"date_of_shipping":"2018-01-09","addres":"moscow, ulica 990","order_status":4,"creation_time":"2018-02-08T00:00:00","source":"source990","prod_prod_id":887,"cust_cust_id":238,"man_man_id":227,"qua":53}
{"order_id":731,"date_of_shipping":"2017-04-26","addres":"moscow, ulica 731","order_status":3,"creation_time":"2017-02-01T00:00:00","source":"source731","prod_prod_id":778,"cust_cust_id":829,"man_man_id":199,"qua":2}
{"order_id":970,"date_of_shipping":"2018-12-04","addres":"moscow, ulica 970","order_status":4,"creation_time":"2018-12-07T00:00:00","source":"source970","prod_prod_id":560,"cust_cust_id":959,"man_man_id":751,"qua":34}
{"order_id":693,"date_of_shipping":"2018-02-24","addres":"moscow, ulica 693","order_status":3,"creation_time":"2019-01-01T00:00:00","source":"source693","prod_prod_id":722,"cust_cust_id":722,"man_man_id":429,"qua":39}
{"order_id":907,"date_of_shipping":"2017-09-01","addres":"moscow, ulica 907","order_status":1,"creation_time":"2017-10-16T00:00:00","source":"source907","prod_prod_id":624,"cust_cust_id":241,"man_man_id":287,"qua":66}
{"order_id":901,"date_of_shipping":"2018-11-13","addres":"moscow, ulica 901","order_status":1,"creation_time":"2018-12-14T00:00:00","source":"source901","prod_prod_id":830,"cust_cust_id":713,"man_man_id":587,"qua":9}
{"order_id":716,"date_of_shipping":"2018-06-18","addres":"moscow, ulica 716","order_status":4,"creation_time":"2018-06-23T00:00:00","source":"source716","prod_prod_id":633,"cust_cust_id":924,"man_man_id":797,"qua":94}
{"order_id":577,"date_of_shipping":"2017-11-21","addres":"moscow, ulica 577","order_status":4,"creation_time":"2017-10-06T00:00:00","source":"source577","prod_prod_id":678,"cust_cust_id":695,"man_man_id":523,"qua":7}
{"order_id":321,"date_of_shipping":"2018-04-15","addres":"moscow, ulica 321","order_status":4,"creation_time":"2018-02-11T00:00:00","source":"source321","prod_prod_id":680,"cust_cust_id":360,"man_man_id":291,"qua":21}
{"order_id":26,"date_of_shipping":"2018-03-31","addres":"moscow, ulica 26","order_status":2,"creation_time":"2017-08-18T00:00:00","source":"source26","prod_prod_id":162,"cust_cust_id":445,"man_man_id":7,"qua":71}
{"order_id":282,"date_of_shipping":"2017-11-10","addres":"moscow, ulica 282","order_status":1,"creation_time":"2018-07-03T00:00:00","source":"source282","prod_prod_id":365,"cust_cust_id":99,"man_man_id":769,"qua":51}
{"order_id":256,"date_of_shipping":"2017-03-19","addres":"moscow, ulica 256","order_status":4,"creation_time":"2017-07-28T00:00:00","source":"source256","prod_prod_id":233,"cust_cust_id":786,"man_man_id":737,"qua":76}
{"order_id":490,"date_of_shipping":"2017-10-06","addres":"moscow, ulica 490","order_status":3,"creation_time":"2017-02-03T00:00:00","source":"source490","prod_prod_id":610,"cust_cust_id":21,"man_man_id":472,"qua":24}
{"order_id":60,"date_of_shipping":"2018-06-09","addres":"moscow, ulica 60","order_status":5,"creation_time":"2018-08-28T00:00:00","source":"source60","prod_prod_id":415,"cust_cust_id":992,"man_man_id":755,"qua":9}
{"order_id":692,"date_of_shipping":"2018-01-27","addres":"moscow, ulica 692","order_status":5,"creation_time":"2018-05-24T00:00:00","source":"source692","prod_prod_id":795,"cust_cust_id":168,"man_man_id":512,"qua":27}
{"order_id":31,"date_of_shipping":"2018-02-22","addres":"moscow, ulica 31","order_status":1,"creation_time":"2017-11-30T00:00:00","source":"source31","prod_prod_id":51,"cust_cust_id":885,"man_man_id":218,"qua":15}
{"order_id":566,"date_of_shipping":"2018-06-27","addres":"moscow, ulica 566","order_status":2,"creation_time":"2017-07-06T00:00:00","source":"source566","prod_prod_id":669,"cust_cust_id":333,"man_man_id":61,"qua":31}
{"order_id":165,"date_of_shipping":"2018-05-28","addres":"moscow, ulica 165","order_status":5,"creation_time":"2018-01-24T00:00:00","source":"source165","prod_prod_id":400,"cust_cust_id":838,"man_man_id":956,"qua":67}
{"order_id":493,"date_of_shipping":"2017-06-28","addres":"moscow, ulica 493","order_status":3,"creation_time":"2017-01-20T00:00:00","source":"source493","prod_prod_id":269,"cust_cust_id":937,"man_man_id":467,"qua":73}
{"order_id":138,"date_of_shipping":"2018-04-11","addres":"moscow, ulica 138","order_status":2,"creation_time":"2017-05-29T00:00:00","source":"source138","prod_prod_id":619,"cust_cust_id":690,"man_man_id":45,"qua":67}
{"order_id":432,"date_of_shipping":"2018-09-24","addres":"moscow, ulica 432","order_status":4,"creation_time":"2018-10-05T00:00:00","source":"source432","prod_prod_id":8,"cust_cust_id":159,"man_man_id":818,"qua":74}
{"order_id":465,"date_of_shipping":"2017-01-03","addres":"moscow, ulica 465","order_status":4,"creation_time":"2018-03-10T00:00:00","source":"source465","prod_prod_id":179,"cust_cust_id":723,"man_man_id":956,"qua":73}
{"order_id":436,"date_of_shipping":"2017-03-05","addres":"moscow, ulica 436","order_status":5,"creation_time":"2018-01-06T00:00:00","source":"source436","prod_prod_id":665,"cust_cust_id":42,"man_man_id":776,"qua":31}
{"order_id":655,"date_of_shipping":"2017-11-04","addres":"moscow, ulica 655","order_status":2,"creation_time":"2018-01-12T00:00:00","source":"source655","prod_prod_id":791,"cust_cust_id":18,"man_man_id":601,"qua":69}
{"order_id":34,"date_of_shipping":"2017-12-26","addres":"moscow, ulica 34","order_status":2,"creation_time":"2017-04-23T00:00:00","source":"source34","prod_prod_id":463,"cust_cust_id":246,"man_man_id":116,"qua":40}
{"order_id":134,"date_of_shipping":"2017-12-19","addres":"moscow, ulica 134","order_status":3,"creation_time":"2018-07-18T00:00:00","source":"source134","prod_prod_id":593,"cust_cust_id":265,"man_man_id":774,"qua":53}
{"order_id":890,"date_of_shipping":"2018-03-05","addres":"moscow, ulica 890","order_status":2,"creation_time":"2017-11-07T00:00:00","source":"source890","prod_prod_id":479,"cust_cust_id":990,"man_man_id":744,"qua":14}
{"order_id":176,"date_of_shipping":"2017-05-25","addres":"moscow, ulica 176","order_status":4,"creation_time":"2018-10-07T00:00:00","source":"source176","prod_prod_id":179,"cust_cust_id":788,"man_man_id":401,"qua":66}
{"order_id":78,"date_of_shipping":"2017-10-04","addres":"moscow, ulica 78","order_status":4,"creation_time":"2017-02-22T00:00:00","source":"source78","prod_prod_id":673,"cust_cust_id":353,"man_man_id":957,"qua":69}
{"order_id":534,"date_of_shipping":"2017-11-20","addres":"moscow, ulica 534","order_status":3,"creation_time":"2017-07-01T00:00:00","source":"source534","prod_prod_id":690,"cust_cust_id":931,"man_man_id":140,"qua":57}
{"order_id":960,"date_of_shipping":"2018-08-01","addres":"moscow, ulica 960","order_status":4,"creation_time":"2017-11-21T00:00:00","source":"source960","prod_prod_id":875,"cust_cust_id":96,"man_man_id":47,"qua":40}
{"order_id":210,"date_of_shipping":"2017-09-18","addres":"moscow, ulica 210","order_status":4,"creation_time":"2017-05-17T00:00:00","source":"source210","prod_prod_id":918,"cust_cust_id":145,"man_man_id":432,"qua":51}
{"order_id":443,"date_of_shipping":"2018-01-11","addres":"moscow, ulica 443","order_status":5,"creation_time":"2017-01-01T00:00:00","source":"source443","prod_prod_id":164,"cust_cust_id":627,"man_man_id":682,"qua":74}
{"order_id":349,"date_of_shipping":"2018-08-02","addres":"moscow, ulica 349","order_status":2,"creation_time":"2017-10-17T00:00:00","source":"source349","prod_prod_id":582,"cust_cust_id":922,"man_man_id":956,"qua":21}
{"order_id":617,"date_of_shipping":"2017-05-30","addres":"moscow, ulica 617","order_status":2,"creation_time":"2018-03-09T00:00:00","source":"source617","prod_prod_id":627,"cust_cust_id":699,"man_man_id":848,"qua":82}
{"order_id":682,"date_of_shipping":"2017-12-01","addres":"moscow, ulica 682","order_status":4,"creation_time":"2018-02-14T00:00:00","source":"source682","prod_prod_id":121,"cust_cust_id":244,"man_man_id":793,"qua":80}
{"order_id":442,"date_of_shipping":"2017-01-13","addres":"moscow, ulica 442","order_status":1,"creation_time":"2017-02-27T00:00:00","source":"source442","prod_prod_id":685,"cust_cust_id":575,"man_man_id":603,"qua":60}
{"order_id":375,"date_of_shipping":"2018-04-08","addres":"moscow, ulica 375","order_status":5,"creation_time":"2018-11-04T00:00:00","source":"source375","prod_prod_id":2,"cust_cust_id":353,"man_man_id":777,"qua":62}
{"order_id":44,"date_of_shipping":"2017-06-17","addres":"moscow, ulica 44","order_status":4,"creation_time":"2017-04-16T00:00:00","source":"source44","prod_prod_id":174,"cust_cust_id":611,"man_man_id":409,"qua":40}
{"order_id":399,"date_of_shipping":"2018-03-13","addres":"moscow, ulica 399","order_status":4,"creation_time":"2018-12-27T00:00:00","source":"source399","prod_prod_id":627,"cust_cust_id":563,"man_man_id":498,"qua":55}
{"order_id":48,"date_of_shipping":"2018-05-03","addres":"moscow, ulica 48","order_status":5,"creation_time":"2018-09-28T00:00:00","source":"source48","prod_prod_id":911,"cust_cust_id":213,"man_man_id":595,"qua":43}
{"order_id":130,"date_of_shipping":"2017-02-09","addres":"moscow, ulica 130","order_status":1,"creation_time":"2017-10-09T00:00:00","source":"source130","prod_prod_id":398,"cust_cust_id":658,"man_man_id":301,"qua":65}
{"order_id":28,"date_of_shipping":"2017-03-06","addres":"moscow, ulica 28","order_status":2,"creation_time":"2017-10-25T00:00:00","source":"source28","prod_prod_id":329,"cust_cust_id":17,"man_man_id":641,"qua":68}
{"order_id":827,"date_of_shipping":"2018-07-04","addres":"moscow, ulica 827","order_status":3,"creation_time":"2017-10-04T00:00:00","source":"source827","prod_prod_id":894,"cust_cust_id":763,"man_man_id":280,"qua":92}
{"order_id":698,"date_of_shipping":"2017-01-20","addres":"moscow, ulica 698","order_status":5,"creation_time":"2018-03-01T00:00:00","source":"source698","prod_prod_id":416,"cust_cust_id":621,"man_man_id":650,"qua":24}
{"order_id":336,"date_of_shipping":"2018-04-14","addres":"moscow, ulica 336","order_status":2,"creation_time":"2017-08-05T00:00:00","source":"source336","prod_prod_id":729,"cust_cust_id":141,"man_man_id":255,"qua":19}
{"order_id":157,"date_of_shipping":"2018-12-07","addres":"moscow, ulica 157","order_status":2,"creation_time":"2017-09-24T00:00:00","source":"source157","prod_prod_id":545,"cust_cust_id":457,"man_man_id":46,"qua":52}
{"order_id":368,"date_of_shipping":"2018-09-27","addres":"moscow, ulica 368","order_status":2,"creation_time":"2017-07-01T00:00:00","source":"source368","prod_prod_id":400,"cust_cust_id":441,"man_man_id":289,"qua":77}
{"order_id":229,"date_of_shipping":"2017-09-30","addres":"moscow, ulica 229","order_status":3,"creation_time":"2018-11-11T00:00:00","source":"source229","prod_prod_id":502,"cust_cust_id":842,"man_man_id":354,"qua":50}
{"order_id":300,"date_of_shipping":"2017-11-09","addres":"moscow, ulica 300","order_status":3,"creation_time":"2017-09-14T00:00:00","source":"source300","prod_prod_id":825,"cust_cust_id":387,"man_man_id":574,"qua":79}
{"order_id":9,"date_of_shipping":"2017-02-19","addres":"moscow, ulica 9","order_status":3,"creation_time":"2017-02-11T00:00:00","source":"source9","prod_prod_id":573,"cust_cust_id":703,"man_man_id":217,"qua":13}
{"order_id":997,"date_of_shipping":"2017-08-19","addres":"moscow, ulica 997","order_status":5,"creation_time":"2018-06-17T00:00:00","source":"source997","prod_prod_id":118,"cust_cust_id":197,"man_man_id":627,"qua":33}
{"order_id":497,"date_of_shipping":"2018-09-24","addres":"moscow, ulica 497","order_status":4,"creation_time":"2018-08-22T00:00:00","source":"source497","prod_prod_id":612,"cust_cust_id":369,"man_man_id":736,"qua":59}
{"order_id":775,"date_of_shipping":"2018-04-13","addres":"moscow, ulica 775","order_status":3,"creation_time":"2018-07-20T00:00:00","source":"source775","prod_prod_id":266,"cust_cust_id":458,"man_man_id":186,"qua":1}
{"order_id":75,"date_of_shipping":"2018-06-30","addres":"moscow, ulica 75","order_status":5,"creation_time":"2017-01-01T00:00:00","source":"source75","prod_prod_id":964,"cust_cust_id":442,"man_man_id":860,"qua":52}
{"order_id":935,"date_of_shipping":"2018-08-27","addres":"moscow, ulica 935","order_status":3,"creation_time":"2017-09-19T00:00:00","source":"source935","prod_prod_id":494,"cust_cust_id":116,"man_man_id":45,"qua":97}
{"order_id":515,"date_of_shipping":"2018-08-06","addres":"moscow, ulica 515","order_status":5,"creation_time":"2017-08-31T00:00:00","source":"source515","prod_prod_id":140,"cust_cust_id":645,"man_man_id":13,"qua":85}
{"order_id":514,"date_of_shipping":"2017-10-25","addres":"moscow, ulica 514","order_status":5,"creation_time":"2017-09-26T00:00:00","source":"source514","prod_prod_id":975,"cust_cust_id":976,"man_man_id":451,"qua":85}
{"order_id":482,"date_of_shipping":"2017-03-29","addres":"moscow, ulica 482","order_status":4,"creation_time":"2018-06-10T00:00:00","source":"source482","prod_prod_id":857,"cust_cust_id":611,"man_man_id":464,"qua":30}
{"order_id":291,"date_of_shipping":"2018-01-21","addres":"moscow, ulica 291","order_status":2,"creation_time":"2018-06-04T00:00:00","source":"source291","prod_prod_id":551,"cust_cust_id":874,"man_man_id":738,"qua":20}
{"order_id":564,"date_of_shipping":"2017-01-11","addres":"moscow, ulica 564","order_status":4,"creation_time":"2017-07-03T00:00:00","source":"source564","prod_prod_id":206,"cust_cust_id":259,"man_man_id":626,"qua":52}
{"order_id":214,"date_of_shipping":"2018-10-31","addres":"moscow, ulica 214","order_status":1,"creation_time":"2018-08-07T00:00:00","source":"source214","prod_prod_id":439,"cust_cust_id":630,"man_man_id":351,"qua":48}
{"order_id":410,"date_of_shipping":"2018-02-15","addres":"moscow, ulica 410","order_status":4,"creation_time":"2018-04-08T00:00:00","source":"source410","prod_prod_id":500,"cust_cust_id":699,"man_man_id":857,"qua":58}
{"order_id":392,"date_of_shipping":"2018-06-16","addres":"moscow, ulica 392","order_status":3,"creation_time":"2017-01-12T00:00:00","source":"source392","prod_prod_id":319,"cust_cust_id":646,"man_man_id":566,"qua":86}
{"order_id":379,"date_of_shipping":"2018-10-29","addres":"moscow, ulica 379","order_status":5,"creation_time":"2017-09-16T00:00:00","source":"source379","prod_prod_id":218,"cust_cust_id":251,"man_man_id":245,"qua":62}
{"order_id":975,"date_of_shipping":"2018-05-14","addres":"moscow, ulica 975","order_status":5,"creation_time":"2018-11-21T00:00:00","source":"source975","prod_prod_id":294,"cust_cust_id":197,"man_man_id":672,"qua":78}
{"order_id":748,"date_of_shipping":"2018-04-13","addres":"moscow, ulica 748","order_status":3,"creation_time":"2017-07-22T00:00:00","source":"source748","prod_prod_id":63,"cust_cust_id":275,"man_man_id":822,"qua":3}
{"order_id":203,"date_of_shipping":"2018-05-09","addres":"moscow, ulica 203","order_status":4,"creation_time":"2017-02-25T00:00:00","source":"source203","prod_prod_id":620,"cust_cust_id":529,"man_man_id":451,"qua":76}
{"order_id":35,"date_of_shipping":"2017-02-23","addres":"moscow, ulica 35","order_status":2,"creation_time":"2018-03-26T00:00:00","source":"source35","prod_prod_id":214,"cust_cust_id":33,"man_man_id":867,"qua":69}
{"order_id":104,"date_of_shipping":"2017-01-12","addres":"moscow, ulica 104","order_status":4,"creation_time":"2017-10-09T00:00:00","source":"source104","prod_prod_id":62,"cust_cust_id":641,"man_man_id":569,"qua":11}
{"order_id":949,"date_of_shipping":"2017-07-08","addres":"moscow, ulica 949","order_status":5,"creation_time":"2017-01-22T00:00:00","source":"source949","prod_prod_id":499,"cust_cust_id":498,"man_man_id":695,"qua":13}
{"order_id":894,"date_of_shipping":"2018-02-11","addres":"moscow, ulica 894","order_status":3,"creation_time":"2018-09-07T00:00:00","source":"source894","prod_prod_id":736,"cust_cust_id":196,"man_man_id":987,"qua":90}
{"order_id":113,"date_of_shipping":"2018-08-26","addres":"moscow, ulica 113","order_status":2,"creation_time":"2017-01-11T00:00:00","source":"source113","prod_prod_id":251,"cust_cust_id":447,"man_man_id":820,"qua":10}
{"order_id":999,"date_of_shipping":"2017-09-01","addres":"moscow, ulica 999","order_status":2,"creation_time":"2017-07-08T00:00:00","source":"source999","prod_prod_id":299,"cust_cust_id":81,"man_man_id":436,"qua":99}
{"order_id":857,"date_of_shipping":"2017-08-28","addres":"moscow, ulica 857","order_status":2,"creation_time":"2017-12-16T00:00:00","source":"source857","prod_prod_id":509,"cust_cust_id":930,"man_man_id":665,"qua":100}
{"order_id":364,"date_of_shipping":"2018-03-22","addres":"moscow, ulica 364","order_status":2,"creation_time":"2018-05-08T00:00:00","source":"source364","prod_prod_id":46,"cust_cust_id":295,"man_man_id":368,"qua":60}
{"order_id":769,"date_of_shipping":"2018-06-23","addres":"moscow, ulica 769","order_status":2,"creation_time":"2018-10-13T00:00:00","source":"source769","prod_prod_id":765,"cust_cust_id":118,"man_man_id":246,"qua":12}
{"order_id":485,"date_of_shipping":"2017-05-27","addres":"moscow, ulica 485","order_status":1,"creation_time":"2018-01-04T00:00:00","source":"source485","prod_prod_id":944,"cust_cust_id":881,"man_man_id":239,"qua":31}
{"order_id":968,"date_of_shipping":"2017-06-01","addres":"moscow, ulica 968","order_status":1,"creation_time":"2018-04-27T00:00:00","source":"source968","prod_prod_id":250,"cust_cust_id":141,"man_man_id":318,"qua":7}
{"order_id":602,"date_of_shipping":"2018-03-11","addres":"moscow, ulica 602","order_status":5,"creation_time":"2018-09-23T00:00:00","source":"source602","prod_prod_id":868,"cust_cust_id":21,"man_man_id":759,"qua":64}
{"order_id":665,"date_of_shipping":"2017-01-28","addres":"moscow, ulica 665","order_status":5,"creation_time":"2017-02-05T00:00:00","source":"source665","prod_prod_id":741,"cust_cust_id":930,"man_man_id":256,"qua":48}
{"order_id":16,"date_of_shipping":"2017-06-10","addres":"moscow, ulica 16","order_status":2,"creation_time":"2018-01-19T00:00:00","source":"source16","prod_prod_id":957,"cust_cust_id":429,"man_man_id":307,"qua":55}
{"order_id":411,"date_of_shipping":"2017-10-24","addres":"moscow, ulica 411","order_status":3,"creation_time":"2018-09-13T00:00:00","source":"source411","prod_prod_id":112,"cust_cust_id":393,"man_man_id":490,"qua":59}
{"order_id":430,"date_of_shipping":"2017-12-25","addres":"moscow, ulica 430","order_status":4,"creation_time":"2017-07-08T00:00:00","source":"source430","prod_prod_id":684,"cust_cust_id":437,"man_man_id":815,"qua":40}
{"order_id":467,"date_of_shipping":"2018-12-02","addres":"moscow, ulica 467","order_status":3,"creation_time":"2018-08-13T00:00:00","source":"source467","prod_prod_id":764,"cust_cust_id":253,"man_man_id":308,"qua":29}
{"order_id":689,"date_of_shipping":"2018-07-18","addres":"moscow, ulica 689","order_status":1,"creation_time":"2018-06-07T00:00:00","source":"source689","prod_prod_id":924,"cust_cust_id":181,"man_man_id":894,"qua":48}
{"order_id":97,"date_of_shipping":"2017-07-11","addres":"moscow, ulica 97","order_status":2,"creation_time":"2017-09-14T00:00:00","source":"source97","prod_prod_id":950,"cust_cust_id":532,"man_man_id":431,"qua":96}
{"order_id":387,"date_of_shipping":"2018-05-12","addres":"moscow, ulica 387","order_status":1,"creation_time":"2018-12-13T00:00:00","source":"source387","prod_prod_id":418,"cust_cust_id":452,"man_man_id":716,"qua":59}
{"order_id":678,"date_of_shipping":"2017-09-17","addres":"moscow, ulica 678","order_status":4,"creation_time":"2017-05-17T00:00:00","source":"source678","prod_prod_id":274,"cust_cust_id":692,"man_man_id":940,"qua":78}
{"order_id":356,"date_of_shipping":"2017-04-29","addres":"moscow, ulica 356","order_status":2,"creation_time":"2017-06-14T00:00:00","source":"source356","prod_prod_id":34,"cust_cust_id":101,"man_man_id":346,"qua":60}
{"order_id":815,"date_of_shipping":"2018-02-01","addres":"moscow, ulica 815","order_status":4,"creation_time":"2017-09-25T00:00:00","source":"source815","prod_prod_id":983,"cust_cust_id":501,"man_man_id":878,"qua":11}
{"order_id":963,"date_of_shipping":"2018-11-13","addres":"moscow, ulica 963","order_status":5,"creation_time":"2018-07-28T00:00:00","source":"source963","prod_prod_id":144,"cust_cust_id":327,"man_man_id":221,"qua":44}
{"order_id":525,"date_of_shipping":"2017-08-21","addres":"moscow, ulica 525","order_status":2,"creation_time":"2018-08-14T00:00:00","source":"source525","prod_prod_id":236,"cust_cust_id":850,"man_man_id":949,"qua":66}
{"order_id":458,"date_of_shipping":"2018-04-22","addres":"moscow, ulica 458","order_status":5,"creation_time":"2017-11-05T00:00:00","source":"source458","prod_prod_id":262,"cust_cust_id":21,"man_man_id":798,"qua":68}
{"order_id":213,"date_of_shipping":"2017-07-10","addres":"moscow, ulica 213","order_status":4,"creation_time":"2017-02-08T00:00:00","source":"source213","prod_prod_id":109,"cust_cust_id":944,"man_man_id":710,"qua":20}
{"order_id":838,"date_of_shipping":"2018-01-28","addres":"moscow, ulica 838","order_status":1,"creation_time":"2018-12-27T00:00:00","source":"source838","prod_prod_id":80,"cust_cust_id":798,"man_man_id":917,"qua":11}
{"order_id":384,"date_of_shipping":"2017-01-22","addres":"moscow, ulica 384","order_status":2,"creation_time":"2018-03-21T00:00:00","source":"source384","prod_prod_id":7,"cust_cust_id":458,"man_man_id":459,"qua":31}
{"order_id":146,"date_of_shipping":"2017-12-13","addres":"moscow, ulica 146","order_status":1,"creation_time":"2017-08-07T00:00:00","source":"source146","prod_prod_id":145,"cust_cust_id":635,"man_man_id":720,"qua":97}
{"order_id":565,"date_of_shipping":"2017-06-15","addres":"moscow, ulica 565","order_status":5,"creation_time":"2018-05-07T00:00:00","source":"source565","prod_prod_id":402,"cust_cust_id":589,"man_man_id":865,"qua":35}
{"order_id":508,"date_of_shipping":"2018-05-26","addres":"moscow, ulica 508","order_status":5,"creation_time":"2018-12-01T00:00:00","source":"source508","prod_prod_id":307,"cust_cust_id":203,"man_man_id":963,"qua":57}
{"order_id":573,"date_of_shipping":"2017-12-08","addres":"moscow, ulica 573","order_status":2,"creation_time":"2017-09-18T00:00:00","source":"source573","prod_prod_id":567,"cust_cust_id":948,"man_man_id":648,"qua":7}
{"order_id":585,"date_of_shipping":"2018-03-20","addres":"moscow, ulica 585","order_status":5,"creation_time":"2018-05-11T00:00:00","source":"source585","prod_prod_id":112,"cust_cust_id":859,"man_man_id":252,"qua":25}
{"order_id":847,"date_of_shipping":"2018-12-15","addres":"moscow, ulica 847","order_status":4,"creation_time":"2017-12-30T00:00:00","source":"source847","prod_prod_id":446,"cust_cust_id":737,"man_man_id":681,"qua":85}
{"order_id":546,"date_of_shipping":"2018-04-02","addres":"moscow, ulica 546","order_status":3,"creation_time":"2017-06-21T00:00:00","source":"source546","prod_prod_id":928,"cust_cust_id":504,"man_man_id":266,"qua":4}
{"order_id":816,"date_of_shipping":"2018-12-14","addres":"moscow, ulica 816","order_status":5,"creation_time":"2017-07-07T00:00:00","source":"source816","prod_prod_id":130,"cust_cust_id":71,"man_man_id":224,"qua":6}
{"order_id":346,"date_of_shipping":"2017-01-04","addres":"moscow, ulica 346","order_status":2,"creation_time":"2018-04-01T00:00:00","source":"source346","prod_prod_id":238,"cust_cust_id":850,"man_man_id":421,"qua":58}
{"order_id":572,"date_of_shipping":"2018-10-30","addres":"moscow, ulica 572","order_status":5,"creation_time":"2018-03-13T00:00:00","source":"source572","prod_prod_id":240,"cust_cust_id":520,"man_man_id":876,"qua":13}
{"order_id":667,"date_of_shipping":"2018-12-12","addres":"moscow, ulica 667","order_status":4,"creation_time":"2017-09-06T00:00:00","source":"source667","prod_prod_id":846,"cust_cust_id":855,"man_man_id":438,"qua":22}
{"order_id":984,"date_of_shipping":"2018-02-10","addres":"moscow, ulica 984","order_status":5,"creation_time":"2017-05-15T00:00:00","source":"source984","prod_prod_id":966,"cust_cust_id":586,"man_man_id":263,"qua":1}
{"order_id":980,"date_of_shipping":"2018-01-11","addres":"moscow, ulica 980","order_status":5,"creation_time":"2017-07-02T00:00:00","source":"source980","prod_prod_id":584,"cust_cust_id":33,"man_man_id":891,"qua":97}
{"order_id":293,"date_of_shipping":"2017-06-08","addres":"moscow, ulica 293","order_status":4,"creation_time":"2018-07-11T00:00:00","source":"source293","prod_prod_id":839,"cust_cust_id":437,"man_man_id":480,"qua":63}
{"order_id":854,"date_of_shipping":"2017-07-09","addres":"moscow, ulica 854","order_status":5,"creation_time":"2018-04-24T00:00:00","source":"source854","prod_prod_id":731,"cust_cust_id":847,"man_man_id":608,"qua":10}
{"order_id":958,"date_of_shipping":"2018-04-04","addres":"moscow, ulica 958","order_status":3,"creation_time":"2018-02-13T00:00:00","source":"source958","prod_prod_id":123,"cust_cust_id":866,"man_man_id":352,"qua":11}
{"order_id":626,"date_of_shipping":"2017-02-24","addres":"moscow, ulica 626","order_status":1,"creation_time":"2018-03-30T00:00:00","source":"source626","prod_prod_id":315,"cust_cust_id":632,"man_man_id":338,"qua":5}
{"order_id":605,"date_of_shipping":"2017-04-19","addres":"moscow, ulica 605","order_status":3,"creation_time":"2017-04-05T00:00:00","source":"source605","prod_prod_id":687,"cust_cust_id":814,"man_man_id":538,"qua":93}
{"order_id":209,"date_of_shipping":"2018-07-20","addres":"moscow, ulica 209","order_status":2,"creation_time":"2017-05-07T00:00:00","source":"source209","prod_prod_id":720,"cust_cust_id":216,"man_man_id":790,"qua":58}
{"order_id":851,"date_of_shipping":"2018-01-23","addres":"moscow, ulica 851","order_status":3,"creation_time":"2017-02-21T00:00:00","source":"source851","prod_prod_id":787,"cust_cust_id":232,"man_man_id":408,"qua":88}
{"order_id":12,"date_of_shipping":"2018-10-12","addres":"moscow, ulica 12","order_status":2,"creation_time":"2018-09-22T00:00:00","source":"source12","prod_prod_id":28,"cust_cust_id":550,"man_man_id":970,"qua":53}
{"order_id":757,"date_of_shipping":"2018-09-13","addres":"moscow, ulica 757","order_status":5,"creation_time":"2018-03-04T00:00:00","source":"source757","prod_prod_id":989,"cust_cust_id":772,"man_man_id":38,"qua":76}
{"order_id":172,"date_of_shipping":"2017-05-10","addres":"moscow, ulica 172","order_status":2,"creation_time":"2017-04-07T00:00:00","source":"source172","prod_prod_id":707,"cust_cust_id":965,"man_man_id":730,"qua":48}
{"order_id":792,"date_of_shipping":"2018-07-19","addres":"moscow, ulica 792","order_status":1,"creation_time":"2017-10-23T00:00:00","source":"source792","prod_prod_id":678,"cust_cust_id":576,"man_man_id":624,"qua":77}
{"order_id":686,"date_of_shipping":"2017-03-02","addres":"moscow, ulica 686","order_status":3,"creation_time":"2017-03-10T00:00:00","source":"source686","prod_prod_id":257,"cust_cust_id":170,"man_man_id":174,"qua":64}
{"order_id":425,"date_of_shipping":"2018-12-29","addres":"moscow, ulica 425","order_status":4,"creation_time":"2018-05-12T00:00:00","source":"source425","prod_prod_id":536,"cust_cust_id":682,"man_man_id":619,"qua":31}
{"order_id":795,"date_of_shipping":"2017-05-29","addres":"moscow, ulica 795","order_status":4,"creation_time":"2017-11-02T00:00:00","source":"source795","prod_prod_id":33,"cust_cust_id":325,"man_man_id":973,"qua":62}
{"order_id":168,"date_of_shipping":"2018-02-07","addres":"moscow, ulica 168","order_status":5,"creation_time":"2018-12-18T00:00:00","source":"source168","prod_prod_id":135,"cust_cust_id":632,"man_man_id":264,"qua":37}
{"order_id":947,"date_of_shipping":"2017-07-25","addres":"moscow, ulica 947","order_status":3,"creation_time":"2017-07-17T00:00:00","source":"source947","prod_prod_id":377,"cust_cust_id":718,"man_man_id":104,"qua":72}
{"order_id":102,"date_of_shipping":"2018-02-13","addres":"moscow, ulica 102","order_status":2,"creation_time":"2017-02-26T00:00:00","source":"source102","prod_prod_id":214,"cust_cust_id":190,"man_man_id":824,"qua":58}
{"order_id":914,"date_of_shipping":"2018-11-08","addres":"moscow, ulica 914","order_status":3,"creation_time":"2018-04-10T00:00:00","source":"source914","prod_prod_id":635,"cust_cust_id":683,"man_man_id":855,"qua":9}
{"order_id":846,"date_of_shipping":"2018-01-31","addres":"moscow, ulica 846","order_status":3,"creation_time":"2018-08-18T00:00:00","source":"source846","prod_prod_id":28,"cust_cust_id":416,"man_man_id":246,"qua":87}
{"order_id":237,"date_of_shipping":"2017-07-06","addres":"moscow, ulica 237","order_status":3,"creation_time":"2018-02-19T00:00:00","source":"source237","prod_prod_id":7,"cust_cust_id":532,"man_man_id":58,"qua":6}
{"order_id":190,"date_of_shipping":"2017-06-27","addres":"moscow, ulica 190","order_status":2,"creation_time":"2017-06-21T00:00:00","source":"source190","prod_prod_id":121,"cust_cust_id":896,"man_man_id":680,"qua":37}
{"order_id":195,"date_of_shipping":"2018-12-13","addres":"moscow, ulica 195","order_status":1,"creation_time":"2017-10-01T00:00:00","source":"source195","prod_prod_id":776,"cust_cust_id":457,"man_man_id":423,"qua":33}
{"order_id":521,"date_of_shipping":"2018-06-30","addres":"moscow, ulica 521","order_status":2,"creation_time":"2019-01-01T00:00:00","source":"source521","prod_prod_id":822,"cust_cust_id":525,"man_man_id":916,"qua":5}
{"order_id":58,"date_of_shipping":"2017-08-27","addres":"moscow, ulica 58","order_status":5,"creation_time":"2017-12-12T00:00:00","source":"source58","prod_prod_id":408,"cust_cust_id":868,"man_man_id":352,"qua":24}
{"order_id":162,"date_of_shipping":"2018-12-10","addres":"moscow, ulica 162","order_status":1,"creation_time":"2018-04-21T00:00:00","source":"source162","prod_prod_id":642,"cust_cust_id":336,"man_man_id":560,"qua":48}
{"order_id":593,"date_of_shipping":"2017-07-22","addres":"moscow, ulica 593","order_status":4,"creation_time":"2017-04-13T00:00:00","source":"source593","prod_prod_id":324,"cust_cust_id":172,"man_man_id":519,"qua":11}
{"order_id":400,"date_of_shipping":"2018-10-26","addres":"moscow, ulica 400","order_status":1,"creation_time":"2017-09-03T00:00:00","source":"source400","prod_prod_id":439,"cust_cust_id":937,"man_man_id":37,"qua":57}
{"order_id":223,"date_of_shipping":"2017-05-28","addres":"moscow, ulica 223","order_status":3,"creation_time":"2017-01-03T00:00:00","source":"source223","prod_prod_id":565,"cust_cust_id":50,"man_man_id":227,"qua":7}
{"order_id":441,"date_of_shipping":"2018-02-11","addres":"moscow, ulica 441","order_status":5,"creation_time":"2017-01-02T00:00:00","source":"source441","prod_prod_id":412,"cust_cust_id":18,"man_man_id":95,"qua":96}
{"order_id":622,"date_of_shipping":"2018-02-18","addres":"moscow, ulica 622","order_status":3,"creation_time":"2018-03-18T00:00:00","source":"source622","prod_prod_id":69,"cust_cust_id":392,"man_man_id":487,"qua":11}
{"order_id":771,"date_of_shipping":"2018-03-03","addres":"moscow, ulica 771","order_status":1,"creation_time":"2018-09-06T00:00:00","source":"source771","prod_prod_id":3,"cust_cust_id":708,"man_man_id":665,"qua":15}
{"order_id":37,"date_of_shipping":"2017-03-31","addres":"moscow, ulica 37","order_status":2,"creation_time":"2017-11-23T00:00:00","source":"source37","prod_prod_id":776,"cust_cust_id":454,"man_man_id":446,"qua":53}
{"order_id":464,"date_of_shipping":"2018-10-26","addres":"moscow, ulica 464","order_status":5,"creation_time":"2017-02-22T00:00:00","source":"source464","prod_prod_id":286,"cust_cust_id":966,"man_man_id":951,"qua":66}
{"order_id":317,"date_of_shipping":"2018-07-31","addres":"moscow, ulica 317","order_status":4,"creation_time":"2018-06-01T00:00:00","source":"source317","prod_prod_id":341,"cust_cust_id":675,"man_man_id":704,"qua":100}
{"order_id":180,"date_of_shipping":"2018-01-05","addres":"moscow, ulica 180","order_status":2,"creation_time":"2017-04-30T00:00:00","source":"source180","prod_prod_id":157,"cust_cust_id":103,"man_man_id":428,"qua":49}
{"order_id":632,"date_of_shipping":"2017-10-12","addres":"moscow, ulica 632","order_status":3,"creation_time":"2017-06-25T00:00:00","source":"source632","prod_prod_id":142,"cust_cust_id":373,"man_man_id":24,"qua":52}
{"order_id":310,"date_of_shipping":"2018-04-25","addres":"moscow, ulica 310","order_status":2,"creation_time":"2017-12-12T00:00:00","source":"source310","prod_prod_id":109,"cust_cust_id":161,"man_man_id":223,"qua":61}
{"order_id":45,"date_of_shipping":"2017-03-13","addres":"moscow, ulica 45","order_status":3,"creation_time":"2017-07-10T00:00:00","source":"source45","prod_prod_id":451,"cust_cust_id":607,"man_man_id":434,"qua":53}
{"order_id":382,"date_of_shipping":"2017-10-15","addres":"moscow, ulica 382","order_status":2,"creation_time":"2017-06-25T00:00:00","source":"source382","prod_prod_id":65,"cust_cust_id":285,"man_man_id":126,"qua":59}
{"order_id":517,"date_of_shipping":"2017-03-17","addres":"moscow, ulica 517","order_status":3,"creation_time":"2017-06-12T00:00:00","source":"source517","prod_prod_id":720,"cust_cust_id":281,"man_man_id":552,"qua":3}
{"order_id":811,"date_of_shipping":"2017-06-13","addres":"moscow, ulica 811","order_status":2,"creation_time":"2018-05-12T00:00:00","source":"source811","prod_prod_id":21,"cust_cust_id":265,"man_man_id":704,"qua":10}
{"order_id":991,"date_of_shipping":"2017-02-19","addres":"moscow, ulica 991","order_status":5,"creation_time":"2018-11-14T00:00:00","source":"source991","prod_prod_id":837,"cust_cust_id":31,"man_man_id":338,"qua":69}
{"order_id":323,"date_of_shipping":"2018-04-04","addres":"moscow, ulica 323","order_status":1,"creation_time":"2017-03-16T00:00:00","source":"source323","prod_prod_id":652,"cust_cust_id":464,"man_man_id":100,"qua":56}
{"order_id":891,"date_of_shipping":"2017-01-17","addres":"moscow, ulica 891","order_status":5,"creation_time":"2017-10-17T00:00:00","source":"source891","prod_prod_id":7,"cust_cust_id":541,"man_man_id":867,"qua":33}
{"order_id":446,"date_of_shipping":"2018-01-09","addres":"moscow, ulica 446","order_status":1,"creation_time":"2018-06-22T00:00:00","source":"source446","prod_prod_id":441,"cust_cust_id":555,"man_man_id":369,"qua":68}
{"order_id":760,"date_of_shipping":"2018-01-07","addres":"moscow, ulica 760","order_status":3,"creation_time":"2017-12-25T00:00:00","source":"source760","prod_prod_id":783,"cust_cust_id":186,"man_man_id":93,"qua":37}
{"order_id":862,"date_of_shipping":"2018-01-05","addres":"moscow, ulica 862","order_status":1,"creation_time":"2018-03-24T00:00:00","source":"source862","prod_prod_id":584,"cust_cust_id":851,"man_man_id":20,"qua":69}
{"order_id":998,"date_of_shipping":"2017-04-11","addres":"moscow, ulica 998","order_status":3,"creation_time":"2017-10-01T00:00:00","source":"source998","prod_prod_id":501,"cust_cust_id":724,"man_man_id":570,"qua":86}
{"order_id":985,"date_of_shipping":"2018-09-07","addres":"moscow, ulica 985","order_status":2,"creation_time":"2017-06-29T00:00:00","source":"source985","prod_prod_id":168,"cust_cust_id":650,"man_man_id":680,"qua":5}
{"order_id":621,"date_of_shipping":"2017-06-17","addres":"moscow, ulica 621","order_status":4,"creation_time":"2018-01-12T00:00:00","source":"source621","prod_prod_id":211,"cust_cust_id":400,"man_man_id":253,"qua":78}
{"order_id":588,"date_of_shipping":"2017-01-30","addres":"moscow, ulica 588","order_status":5,"creation_time":"2018-05-30T00:00:00","source":"source588","prod_prod_id":394,"cust_cust_id":143,"man_man_id":226,"qua":79}
{"order_id":715,"date_of_shipping":"2018-05-24","addres":"moscow, ulica 715","order_status":4,"creation_time":"2017-02-15T00:00:00","source":"source715","prod_prod_id":827,"cust_cust_id":846,"man_man_id":868,"qua":48}
{"order_id":920,"date_of_shipping":"2017-11-11","addres":"moscow, ulica 920","order_status":3,"creation_time":"2017-05-02T00:00:00","source":"source920","prod_prod_id":272,"cust_cust_id":900,"man_man_id":1,"qua":17}
{"order_id":623,"date_of_shipping":"2017-06-15","addres":"moscow, ulica 623","order_status":5,"creation_time":"2018-09-21T00:00:00","source":"source623","prod_prod_id":742,"cust_cust_id":981,"man_man_id":635,"qua":78}
{"order_id":987,"date_of_shipping":"2017-04-12","addres":"moscow, ulica 987","order_status":3,"creation_time":"2018-02-02T00:00:00","source":"source987","prod_prod_id":701,"cust_cust_id":505,"man_man_id":987,"qua":83}
{"order_id":738,"date_of_shipping":"2017-06-22","addres":"moscow, ulica 738","order_status":4,"creation_time":"2017-02-15T00:00:00","source":"source738","prod_prod_id":542,"cust_cust_id":199,"man_man_id":509,"qua":88}
{"order_id":398,"date_of_shipping":"2017-10-08","addres":"moscow, ulica 398","order_status":1,"creation_time":"2017-12-24T00:00:00","source":"source398","prod_prod_id":934,"cust_cust_id":508,"man_man_id":445,"qua":69}
{"order_id":703,"date_of_shipping":"2017-09-12","addres":"moscow, ulica 703","order_status":2,"creation_time":"2018-07-24T00:00:00","source":"source703","prod_prod_id":555,"cust_cust_id":549,"man_man_id":654,"qua":14}
{"order_id":676,"date_of_shipping":"2017-07-26","addres":"moscow, ulica 676","order_status":4,"creation_time":"2018-01-23T00:00:00","source":"source676","prod_prod_id":253,"cust_cust_id":493,"man_man_id":177,"qua":83}
{"order_id":647,"date_of_shipping":"2018-11-07","addres":"moscow, ulica 647","order_status":5,"creation_time":"2018-12-08T00:00:00","source":"source647","prod_prod_id":582,"cust_cust_id":861,"man_man_id":243,"qua":12}
{"order_id":646,"date_of_shipping":"2017-07-30","addres":"moscow, ulica 646","order_status":2,"creation_time":"2018-04-15T00:00:00","source":"source646","prod_prod_id":350,"cust_cust_id":19,"man_man_id":672,"qua":12}
{"order_id":179,"date_of_shipping":"2018-11-16","addres":"moscow, ulica 179","order_status":2,"creation_time":"2017-12-12T00:00:00","source":"source179","prod_prod_id":676,"cust_cust_id":248,"man_man_id":104,"qua":62}
{"order_id":277,"date_of_shipping":"2017-09-24","addres":"moscow, ulica 277","order_status":2,"creation_time":"2018-06-20T00:00:00","source":"source277","prod_prod_id":726,"cust_cust_id":464,"man_man_id":36,"qua":70}
{"order_id":264,"date_of_shipping":"2017-05-19","addres":"moscow, ulica 264","order_status":5,"creation_time":"2017-08-05T00:00:00","source":"source264","prod_prod_id":236,"cust_cust_id":151,"man_man_id":451,"qua":98}
{"order_id":381,"date_of_shipping":"2018-09-19","addres":"moscow, ulica 381","order_status":2,"creation_time":"2018-11-05T00:00:00","source":"source381","prod_prod_id":130,"cust_cust_id":600,"man_man_id":70,"qua":56}
{"order_id":116,"date_of_shipping":"2018-10-22","addres":"moscow, ulica 116","order_status":2,"creation_time":"2017-10-21T00:00:00","source":"source116","prod_prod_id":955,"cust_cust_id":526,"man_man_id":866,"qua":48}
{"order_id":76,"date_of_shipping":"2017-09-08","addres":"moscow, ulica 76","order_status":4,"creation_time":"2018-06-09T00:00:00","source":"source76","prod_prod_id":513,"cust_cust_id":200,"man_man_id":667,"qua":61}
{"order_id":24,"date_of_shipping":"2017-12-09","addres":"moscow, ulica 24","order_status":1,"creation_time":"2018-07-12T00:00:00","source":"source24","prod_prod_id":334,"cust_cust_id":954,"man_man_id":556,"qua":50}
{"order_id":365,"date_of_shipping":"2017-05-20","addres":"moscow, ulica 365","order_status":3,"creation_time":"2018-12-09T00:00:00","source":"source365","prod_prod_id":961,"cust_cust_id":176,"man_man_id":742,"qua":4}
{"order_id":185,"date_of_shipping":"2017-12-30","addres":"moscow, ulica 185","order_status":3,"creation_time":"2017-02-06T00:00:00","source":"source185","prod_prod_id":220,"cust_cust_id":581,"man_man_id":708,"qua":49}
{"order_id":64,"date_of_shipping":"2018-10-19","addres":"moscow, ulica 64","order_status":1,"creation_time":"2018-07-04T00:00:00","source":"source64","prod_prod_id":101,"cust_cust_id":683,"man_man_id":674,"qua":49}
{"order_id":886,"date_of_shipping":"2018-07-03","addres":"moscow, ulica 886","order_status":1,"creation_time":"2018-12-11T00:00:00","source":"source886","prod_prod_id":120,"cust_cust_id":175,"man_man_id":310,"qua":8}
{"order_id":860,"date_of_shipping":"2017-01-04","addres":"moscow, ulica 860","order_status":2,"creation_time":"2017-06-25T00:00:00","source":"source860","prod_prod_id":140,"cust_cust_id":633,"man_man_id":380,"qua":9}
{"order_id":652,"date_of_shipping":"2018-03-11","addres":"moscow, ulica 652","order_status":2,"creation_time":"2018-12-18T00:00:00","source":"source652","prod_prod_id":547,"cust_cust_id":725,"man_man_id":243,"qua":75}
{"order_id":96,"date_of_shipping":"2018-03-29","addres":"moscow, ulica 96","order_status":1,"creation_time":"2017-11-29T00:00:00","source":"source96","prod_prod_id":355,"cust_cust_id":258,"man_man_id":254,"qua":48}
{"order_id":853,"date_of_shipping":"2017-03-13","addres":"moscow, ulica 853","order_status":2,"creation_time":"2018-02-04T00:00:00","source":"source853","prod_prod_id":523,"cust_cust_id":418,"man_man_id":110,"qua":84}
{"order_id":796,"date_of_shipping":"2017-07-29","addres":"moscow, ulica 796","order_status":2,"creation_time":"2017-05-02T00:00:00","source":"source796","prod_prod_id":469,"cust_cust_id":311,"man_man_id":511,"qua":11}
{"order_id":953,"date_of_shipping":"2017-03-02","addres":"moscow, ulica 953","order_status":4,"creation_time":"2017-12-26T00:00:00","source":"source953","prod_prod_id":321,"cust_cust_id":924,"man_man_id":600,"qua":77}
{"order_id":867,"date_of_shipping":"2018-01-23","addres":"moscow, ulica 867","order_status":1,"creation_time":"2017-07-02T00:00:00","source":"source867","prod_prod_id":952,"cust_cust_id":424,"man_man_id":366,"qua":64}
{"order_id":221,"date_of_shipping":"2018-06-10","addres":"moscow, ulica 221","order_status":5,"creation_time":"2017-10-19T00:00:00","source":"source221","prod_prod_id":872,"cust_cust_id":158,"man_man_id":157,"qua":45}
{"order_id":822,"date_of_shipping":"2017-10-07","addres":"moscow, ulica 822","order_status":2,"creation_time":"2018-03-02T00:00:00","source":"source822","prod_prod_id":657,"cust_cust_id":338,"man_man_id":564,"qua":59}
{"order_id":355,"date_of_shipping":"2017-12-02","addres":"moscow, ulica 355","order_status":5,"creation_time":"2018-06-15T00:00:00","source":"source355","prod_prod_id":756,"cust_cust_id":233,"man_man_id":263,"qua":97}
{"order_id":645,"date_of_shipping":"2017-12-21","addres":"moscow, ulica 645","order_status":5,"creation_time":"2017-10-16T00:00:00","source":"source645","prod_prod_id":638,"cust_cust_id":866,"man_man_id":83,"qua":24}
{"order_id":232,"date_of_shipping":"2018-07-30","addres":"moscow, ulica 232","order_status":3,"creation_time":"2017-09-07T00:00:00","source":"source232","prod_prod_id":585,"cust_cust_id":382,"man_man_id":474,"qua":45}
{"order_id":883,"date_of_shipping":"2018-09-01","addres":"moscow, ulica 883","order_status":5,"creation_time":"2018-06-13T00:00:00","source":"source883","prod_prod_id":348,"cust_cust_id":50,"man_man_id":206,"qua":11}
{"order_id":306,"date_of_shipping":"2017-02-08","addres":"moscow, ulica 306","order_status":5,"creation_time":"2017-09-10T00:00:00","source":"source306","prod_prod_id":550,"cust_cust_id":24,"man_man_id":307,"qua":22}
{"order_id":967,"date_of_shipping":"2017-09-22","addres":"moscow, ulica 967","order_status":1,"creation_time":"2018-07-07T00:00:00","source":"source967","prod_prod_id":596,"cust_cust_id":677,"man_man_id":375,"qua":17}
{"order_id":951,"date_of_shipping":"2017-09-18","addres":"moscow, ulica 951","order_status":2,"creation_time":"2017-05-02T00:00:00","source":"source951","prod_prod_id":652,"cust_cust_id":306,"man_man_id":534,"qua":63}
{"order_id":273,"date_of_shipping":"2018-07-23","addres":"moscow, ulica 273","order_status":2,"creation_time":"2017-08-03T00:00:00","source":"source273","prod_prod_id":233,"cust_cust_id":2,"man_man_id":131,"qua":43}
{"order_id":887,"date_of_shipping":"2017-10-11","addres":"moscow, ulica 887","order_status":3,"creation_time":"2018-10-05T00:00:00","source":"source887","prod_prod_id":431,"cust_cust_id":647,"man_man_id":542,"qua":19}
{"order_id":110,"date_of_shipping":"2018-05-24","addres":"moscow, ulica 110","order_status":2,"creation_time":"2018-10-07T00:00:00","source":"source110","prod_prod_id":357,"cust_cust_id":503,"man_man_id":685,"qua":32}
{"order_id":523,"date_of_shipping":"2018-11-14","addres":"moscow, ulica 523","order_status":4,"creation_time":"2018-09-02T00:00:00","source":"source523","prod_prod_id":428,"cust_cust_id":408,"man_man_id":385,"qua":76}
{"order_id":925,"date_of_shipping":"2017-07-31","addres":"moscow, ulica 925","order_status":3,"creation_time":"2018-06-03T00:00:00","source":"source925","prod_prod_id":956,"cust_cust_id":728,"man_man_id":765,"qua":18}
{"order_id":377,"date_of_shipping":"2017-03-15","addres":"moscow, ulica 377","order_status":2,"creation_time":"2018-10-31T00:00:00","source":"source377","prod_prod_id":469,"cust_cust_id":489,"man_man_id":660,"qua":40}
{"order_id":981,"date_of_shipping":"2018-11-29","addres":"moscow, ulica 981","order_status":3,"creation_time":"2017-05-12T00:00:00","source":"source981","prod_prod_id":511,"cust_cust_id":827,"man_man_id":44,"qua":58}
{"order_id":549,"date_of_shipping":"2018-10-15","addres":"moscow, ulica 549","order_status":5,"creation_time":"2018-08-09T00:00:00","source":"source549","prod_prod_id":475,"cust_cust_id":237,"man_man_id":461,"qua":51}
{"order_id":325,"date_of_shipping":"2018-06-02","addres":"moscow, ulica 325","order_status":1,"creation_time":"2017-07-17T00:00:00","source":"source325","prod_prod_id":529,"cust_cust_id":669,"man_man_id":514,"qua":69}
{"order_id":810,"date_of_shipping":"2018-01-26","addres":"moscow, ulica 810","order_status":1,"creation_time":"2018-04-01T00:00:00","source":"source810","prod_prod_id":224,"cust_cust_id":426,"man_man_id":368,"qua":22}
{"order_id":151,"date_of_shipping":"2017-07-01","addres":"moscow, ulica 151","order_status":3,"creation_time":"2018-06-19T00:00:00","source":"source151","prod_prod_id":165,"cust_cust_id":689,"man_man_id":712,"qua":58}
{"order_id":563,"date_of_shipping":"2017-08-04","addres":"moscow, ulica 563","order_status":1,"creation_time":"2018-08-24T00:00:00","source":"source563","prod_prod_id":839,"cust_cust_id":575,"man_man_id":601,"qua":78}
{"order_id":876,"date_of_shipping":"2018-10-14","addres":"moscow, ulica 876","order_status":5,"creation_time":"2018-10-07T00:00:00","source":"source876","prod_prod_id":753,"cust_cust_id":106,"man_man_id":905,"qua":27}
{"order_id":280,"date_of_shipping":"2017-07-04","addres":"moscow, ulica 280","order_status":2,"creation_time":"2018-01-26T00:00:00","source":"source280","prod_prod_id":503,"cust_cust_id":813,"man_man_id":566,"qua":6}
{"order_id":752,"date_of_shipping":"2017-08-23","addres":"moscow, ulica 752","order_status":1,"creation_time":"2018-12-24T00:00:00","source":"source752","prod_prod_id":605,"cust_cust_id":69,"man_man_id":132,"qua":27}
{"order_id":272,"date_of_shipping":"2017-04-08","addres":"moscow, ulica 272","order_status":4,"creation_time":"2017-06-28T00:00:00","source":"source272","prod_prod_id":870,"cust_cust_id":66,"man_man_id":402,"qua":71}
{"order_id":607,"date_of_shipping":"2017-11-07","addres":"moscow, ulica 607","order_status":3,"creation_time":"2017-09-23T00:00:00","source":"source607","prod_prod_id":334,"cust_cust_id":68,"man_man_id":386,"qua":74}
{"order_id":372,"date_of_shipping":"2017-05-30","addres":"moscow, ulica 372","order_status":4,"creation_time":"2018-01-02T00:00:00","source":"source372","prod_prod_id":216,"cust_cust_id":774,"man_man_id":104,"qua":41}
{"order_id":244,"date_of_shipping":"2018-01-25","addres":"moscow, ulica 244","order_status":2,"creation_time":"2017-02-24T00:00:00","source":"source244","prod_prod_id":201,"cust_cust_id":737,"man_man_id":775,"qua":52}
{"order_id":267,"date_of_shipping":"2017-04-22","addres":"moscow, ulica 267","order_status":5,"creation_time":"2017-04-03T00:00:00","source":"source267","prod_prod_id":180,"cust_cust_id":802,"man_man_id":621,"qua":86}
{"order_id":575,"date_of_shipping":"2018-06-27","addres":"moscow, ulica 575","order_status":2,"creation_time":"2018-09-22T00:00:00","source":"source575","prod_prod_id":358,"cust_cust_id":993,"man_man_id":627,"qua":58}
{"order_id":550,"date_of_shipping":"2017-05-14","addres":"moscow, ulica 550","order_status":3,"creation_time":"2017-11-17T00:00:00","source":"source550","prod_prod_id":248,"cust_cust_id":254,"man_man_id":864,"qua":76}
{"order_id":643,"date_of_shipping":"2018-08-15","addres":"moscow, ulica 643","order_status":5,"creation_time":"2018-06-30T00:00:00","source":"source643","prod_prod_id":532,"cust_cust_id":88,"man_man_id":922,"qua":61}
{"order_id":705,"date_of_shipping":"2017-10-27","addres":"moscow, ulica 705","order_status":1,"creation_time":"2017-01-25T00:00:00","source":"source705","prod_prod_id":900,"cust_cust_id":961,"man_man_id":419,"qua":28}
{"order_id":193,"date_of_shipping":"2017-11-17","addres":"moscow, ulica 193","order_status":4,"creation_time":"2018-07-23T00:00:00","source":"source193","prod_prod_id":636,"cust_cust_id":80,"man_man_id":531,"qua":71}
{"order_id":956,"date_of_shipping":"2017-06-09","addres":"moscow, ulica 956","order_status":2,"creation_time":"2018-07-10T00:00:00","source":"source956","prod_prod_id":229,"cust_cust_id":538,"man_man_id":687,"qua":26}
{"order_id":959,"date_of_shipping":"2017-03-03","addres":"moscow, ulica 959","order_status":3,"creation_time":"2018-06-05T00:00:00","source":"source959","prod_prod_id":206,"cust_cust_id":699,"man_man_id":379,"qua":33}
{"order_id":54,"date_of_shipping":"2018-05-15","addres":"moscow, ulica 54","order_status":2,"creation_time":"2018-04-10T00:00:00","source":"source54","prod_prod_id":92,"cust_cust_id":233,"man_man_id":989,"qua":35}
{"order_id":756,"date_of_shipping":"2017-03-23","addres":"moscow, ulica 756","order_status":5,"creation_time":"2018-06-23T00:00:00","source":"source756","prod_prod_id":136,"cust_cust_id":285,"man_man_id":544,"qua":30}
{"order_id":962,"date_of_shipping":"2018-01-14","addres":"moscow, ulica 962","order_status":5,"creation_time":"2017-07-27T00:00:00","source":"source962","prod_prod_id":606,"cust_cust_id":189,"man_man_id":55,"qua":23}
{"order_id":594,"date_of_shipping":"2018-08-15","addres":"moscow, ulica 594","order_status":3,"creation_time":"2018-09-05T00:00:00","source":"source594","prod_prod_id":754,"cust_cust_id":583,"man_man_id":467,"qua":19}
{"order_id":780,"date_of_shipping":"2018-09-15","addres":"moscow, ulica 780","order_status":4,"creation_time":"2017-11-07T00:00:00","source":"source780","prod_prod_id":16,"cust_cust_id":672,"man_man_id":292,"qua":6}
{"order_id":415,"date_of_shipping":"2018-10-21","addres":"moscow, ulica 415","order_status":4,"creation_time":"2017-02-06T00:00:00","source":"source415","prod_prod_id":749,"cust_cust_id":905,"man_man_id":968,"qua":5}
{"order_id":447,"date_of_shipping":"2018-09-20","addres":"moscow, ulica 447","order_status":3,"creation_time":"2017-01-13T00:00:00","source":"source447","prod_prod_id":390,"cust_cust_id":38,"man_man_id":128,"qua":83}
{"order_id":875,"date_of_shipping":"2018-06-25","addres":"moscow, ulica 875","order_status":3,"creation_time":"2018-07-13T00:00:00","source":"source875","prod_prod_id":680,"cust_cust_id":192,"man_man_id":474,"qua":99}
{"order_id":723,"date_of_shipping":"2018-02-27","addres":"moscow, ulica 723","order_status":3,"creation_time":"2018-04-02T00:00:00","source":"source723","prod_prod_id":613,"cust_cust_id":267,"man_man_id":220,"qua":88}
{"order_id":526,"date_of_shipping":"2017-09-02","addres":"moscow, ulica 526","order_status":5,"creation_time":"2017-07-22T00:00:00","source":"source526","prod_prod_id":205,"cust_cust_id":297,"man_man_id":368,"qua":62}
{"order_id":371,"date_of_shipping":"2018-02-27","addres":"moscow, ulica 371","order_status":1,"creation_time":"2018-05-04T00:00:00","source":"source371","prod_prod_id":165,"cust_cust_id":101,"man_man_id":299,"qua":69}
{"order_id":598,"date_of_shipping":"2017-06-15","addres":"moscow, ulica 598","order_status":3,"creation_time":"2017-08-25T00:00:00","source":"source598","prod_prod_id":999,"cust_cust_id":10,"man_man_id":83,"qua":60}
{"order_id":503,"date_of_shipping":"2017-11-06","addres":"moscow, ulica 503","order_status":4,"creation_time":"2018-02-05T00:00:00","source":"source503","prod_prod_id":371,"cust_cust_id":77,"man_man_id":228,"qua":2}
{"order_id":668,"date_of_shipping":"2017-01-05","addres":"moscow, ulica 668","order_status":3,"creation_time":"2017-08-20T00:00:00","source":"source668","prod_prod_id":701,"cust_cust_id":802,"man_man_id":148,"qua":58}
{"order_id":978,"date_of_shipping":"2017-05-24","addres":"moscow, ulica 978","order_status":2,"creation_time":"2017-10-21T00:00:00","source":"source978","prod_prod_id":433,"cust_cust_id":147,"man_man_id":42,"qua":83}
{"order_id":109,"date_of_shipping":"2017-02-27","addres":"moscow, ulica 109","order_status":5,"creation_time":"2017-02-22T00:00:00","source":"source109","prod_prod_id":691,"cust_cust_id":956,"man_man_id":738,"qua":46}
{"order_id":758,"date_of_shipping":"2017-08-07","addres":"moscow, ulica 758","order_status":3,"creation_time":"2017-01-12T00:00:00","source":"source758","prod_prod_id":672,"cust_cust_id":763,"man_man_id":721,"qua":36}
{"order_id":624,"date_of_shipping":"2018-12-07","addres":"moscow, ulica 624","order_status":1,"creation_time":"2018-10-21T00:00:00","source":"source624","prod_prod_id":651,"cust_cust_id":559,"man_man_id":666,"qua":88}
{"order_id":687,"date_of_shipping":"2017-11-23","addres":"moscow, ulica 687","order_status":5,"creation_time":"2017-08-25T00:00:00","source":"source687","prod_prod_id":350,"cust_cust_id":290,"man_man_id":728,"qua":15}
{"order_id":507,"date_of_shipping":"2017-09-22","addres":"moscow, ulica 507","order_status":3,"creation_time":"2018-07-01T00:00:00","source":"source507","prod_prod_id":175,"cust_cust_id":642,"man_man_id":525,"qua":50}
{"order_id":283,"date_of_shipping":"2017-05-09","addres":"moscow, ulica 283","order_status":4,"creation_time":"2017-09-08T00:00:00","source":"source283","prod_prod_id":55,"cust_cust_id":862,"man_man_id":995,"qua":41}
{"order_id":836,"date_of_shipping":"2018-09-30","addres":"moscow, ulica 836","order_status":5,"creation_time":"2017-05-18T00:00:00","source":"source836","prod_prod_id":978,"cust_cust_id":794,"man_man_id":18,"qua":46}
{"order_id":711,"date_of_shipping":"2017-04-23","addres":"moscow, ulica 711","order_status":4,"creation_time":"2017-11-24T00:00:00","source":"source711","prod_prod_id":548,"cust_cust_id":307,"man_man_id":278,"qua":21}
{"order_id":426,"date_of_shipping":"2018-01-28","addres":"moscow, ulica 426","order_status":1,"creation_time":"2017-11-28T00:00:00","source":"source426","prod_prod_id":169,"cust_cust_id":847,"man_man_id":500,"qua":64}
{"order_id":440,"date_of_shipping":"2018-03-31","addres":"moscow, ulica 440","order_status":4,"creation_time":"2018-10-03T00:00:00","source":"source440","prod_prod_id":423,"cust_cust_id":251,"man_man_id":105,"qua":94}
{"order_id":681,"date_of_shipping":"2017-11-07","addres":"moscow, ulica 681","order_status":2,"creation_time":"2017-07-06T00:00:00","source":"source681","prod_prod_id":480,"cust_cust_id":735,"man_man_id":348,"qua":61}
{"order_id":706,"date_of_shipping":"2017-11-02","addres":"moscow, ulica 706","order_status":2,"creation_time":"2017-11-15T00:00:00","source":"source706","prod_prod_id":102,"cust_cust_id":749,"man_man_id":291,"qua":34}
{"order_id":778,"date_of_shipping":"2018-07-31","addres":"moscow, ulica 778","order_status":2,"creation_time":"2017-08-05T00:00:00","source":"source778","prod_prod_id":565,"cust_cust_id":205,"man_man_id":601,"qua":35}
{"order_id":331,"date_of_shipping":"2018-04-03","addres":"moscow, ulica 331","order_status":1,"creation_time":"2018-12-27T00:00:00","source":"source331","prod_prod_id":713,"cust_cust_id":267,"man_man_id":528,"qua":67}
{"order_id":181,"date_of_shipping":"2017-02-11","addres":"moscow, ulica 181","order_status":2,"creation_time":"2017-01-17T00:00:00","source":"source181","prod_prod_id":79,"cust_cust_id":234,"man_man_id":233,"qua":63}
{"order_id":230,"date_of_shipping":"2018-07-09","addres":"moscow, ulica 230","order_status":4,"creation_time":"2018-09-29T00:00:00","source":"source230","prod_prod_id":294,"cust_cust_id":89,"man_man_id":507,"qua":40}
{"order_id":284,"date_of_shipping":"2017-07-22","addres":"moscow, ulica 284","order_status":3,"creation_time":"2018-07-11T00:00:00","source":"source284","prod_prod_id":669,"cust_cust_id":607,"man_man_id":659,"qua":82}
{"order_id":228,"date_of_shipping":"2018-03-03","addres":"moscow, ulica 228","order_status":2,"creation_time":"2018-01-21T00:00:00","source":"source228","prod_prod_id":675,"cust_cust_id":506,"man_man_id":428,"qua":40}
{"order_id":957,"date_of_shipping":"2018-10-17","addres":"moscow, ulica 957","order_status":5,"creation_time":"2017-06-29T00:00:00","source":"source957","prod_prod_id":103,"cust_cust_id":133,"man_man_id":39,"qua":49}
{"order_id":770,"date_of_shipping":"2017-03-03","addres":"moscow, ulica 770","order_status":2,"creation_time":"2018-11-13T00:00:00","source":"source770","prod_prod_id":505,"cust_cust_id":807,"man_man_id":575,"qua":82}
{"order_id":353,"date_of_shipping":"2018-05-08","addres":"moscow, ulica 353","order_status":5,"creation_time":"2018-08-23T00:00:00","source":"source353","prod_prod_id":563,"cust_cust_id":161,"man_man_id":751,"qua":80}
{"order_id":437,"date_of_shipping":"2018-12-16","addres":"moscow, ulica 437","order_status":5,"creation_time":"2018-05-22T00:00:00","source":"source437","prod_prod_id":499,"cust_cust_id":64,"man_man_id":136,"qua":50}
{"order_id":654,"date_of_shipping":"2018-09-17","addres":"moscow, ulica 654","order_status":5,"creation_time":"2017-03-16T00:00:00","source":"source654","prod_prod_id":979,"cust_cust_id":519,"man_man_id":693,"qua":1}
{"order_id":140,"date_of_shipping":"2017-12-24","addres":"moscow, ulica 140","order_status":1,"creation_time":"2017-04-28T00:00:00","source":"source140","prod_prod_id":412,"cust_cust_id":960,"man_man_id":62,"qua":43}
{"order_id":316,"date_of_shipping":"2018-02-09","addres":"moscow, ulica 316","order_status":4,"creation_time":"2017-08-06T00:00:00","source":"source316","prod_prod_id":470,"cust_cust_id":64,"man_man_id":134,"qua":10}
{"order_id":290,"date_of_shipping":"2018-07-25","addres":"moscow, ulica 290","order_status":5,"creation_time":"2018-06-04T00:00:00","source":"source290","prod_prod_id":804,"cust_cust_id":660,"man_man_id":484,"qua":82}
{"order_id":201,"date_of_shipping":"2018-03-16","addres":"moscow, ulica 201","order_status":4,"creation_time":"2017-10-09T00:00:00","source":"source201","prod_prod_id":311,"cust_cust_id":233,"man_man_id":718,"qua":82}
{"order_id":666,"date_of_shipping":"2018-05-03","addres":"moscow, ulica 666","order_status":5,"creation_time":"2018-12-14T00:00:00","source":"source666","prod_prod_id":926,"cust_cust_id":514,"man_man_id":432,"qua":79}
{"order_id":841,"date_of_shipping":"2018-01-22","addres":"moscow, ulica 841","order_status":3,"creation_time":"2017-04-10T00:00:00","source":"source841","prod_prod_id":938,"cust_cust_id":237,"man_man_id":39,"qua":78}
{"order_id":235,"date_of_shipping":"2018-11-12","addres":"moscow, ulica 235","order_status":1,"creation_time":"2017-06-10T00:00:00","source":"source235","prod_prod_id":663,"cust_cust_id":732,"man_man_id":284,"qua":85}
{"order_id":966,"date_of_shipping":"2018-12-07","addres":"moscow, ulica 966","order_status":2,"creation_time":"2017-03-11T00:00:00","source":"source966","prod_prod_id":721,"cust_cust_id":662,"man_man_id":709,"qua":45}
{"order_id":483,"date_of_shipping":"2017-02-11","addres":"moscow, ulica 483","order_status":5,"creation_time":"2017-03-06T00:00:00","source":"source483","prod_prod_id":235,"cust_cust_id":931,"man_man_id":686,"qua":48}
{"order_id":927,"date_of_shipping":"2017-08-20","addres":"moscow, ulica 927","order_status":4,"creation_time":"2018-01-05T00:00:00","source":"source927","prod_prod_id":806,"cust_cust_id":536,"man_man_id":764,"qua":84}
{"order_id":41,"date_of_shipping":"2017-08-02","addres":"moscow, ulica 41","order_status":3,"creation_time":"2018-06-27T00:00:00","source":"source41","prod_prod_id":455,"cust_cust_id":943,"man_man_id":740,"qua":75}
{"order_id":369,"date_of_shipping":"2017-06-24","addres":"moscow, ulica 369","order_status":2,"creation_time":"2018-03-22T00:00:00","source":"source369","prod_prod_id":99,"cust_cust_id":316,"man_man_id":743,"qua":81}
{"order_id":153,"date_of_shipping":"2018-11-15","addres":"moscow, ulica 153","order_status":4,"creation_time":"2018-11-09T00:00:00","source":"source153","prod_prod_id":991,"cust_cust_id":821,"man_man_id":604,"qua":99}
{"order_id":938,"date_of_shipping":"2018-03-04","addres":"moscow, ulica 938","order_status":4,"creation_time":"2017-01-01T00:00:00","source":"source938","prod_prod_id":515,"cust_cust_id":360,"man_man_id":457,"qua":44}
{"order_id":727,"date_of_shipping":"2018-01-22","addres":"moscow, ulica 727","order_status":4,"creation_time":"2018-11-04T00:00:00","source":"source727","prod_prod_id":15,"cust_cust_id":240,"man_man_id":928,"qua":69}
{"order_id":414,"date_of_shipping":"2018-05-16","addres":"moscow, ulica 414","order_status":1,"creation_time":"2017-06-18T00:00:00","source":"source414","prod_prod_id":840,"cust_cust_id":433,"man_man_id":379,"qua":95}
{"order_id":561,"date_of_shipping":"2017-04-17","addres":"moscow, ulica 561","order_status":1,"creation_time":"2018-11-09T00:00:00","source":"source561","prod_prod_id":902,"cust_cust_id":1,"man_man_id":603,"qua":63}
{"order_id":807,"date_of_shipping":"2018-01-22","addres":"moscow, ulica 807","order_status":3,"creation_time":"2017-04-25T00:00:00","source":"source807","prod_prod_id":735,"cust_cust_id":55,"man_man_id":343,"qua":38}
{"order_id":828,"date_of_shipping":"2018-11-09","addres":"moscow, ulica 828","order_status":1,"creation_time":"2018-09-15T00:00:00","source":"source828","prod_prod_id":825,"cust_cust_id":918,"man_man_id":891,"qua":7}
{"order_id":334,"date_of_shipping":"2018-06-24","addres":"moscow, ulica 334","order_status":5,"creation_time":"2017-10-23T00:00:00","source":"source334","prod_prod_id":166,"cust_cust_id":112,"man_man_id":385,"qua":50}
{"order_id":255,"date_of_shipping":"2017-02-18","addres":"moscow, ulica 255","order_status":4,"creation_time":"2017-10-17T00:00:00","source":"source255","prod_prod_id":804,"cust_cust_id":827,"man_man_id":878,"qua":12}
{"order_id":360,"date_of_shipping":"2018-09-12","addres":"moscow, ulica 360","order_status":3,"creation_time":"2018-04-10T00:00:00","source":"source360","prod_prod_id":33,"cust_cust_id":585,"man_man_id":182,"qua":81}
{"order_id":595,"date_of_shipping":"2018-10-02","addres":"moscow, ulica 595","order_status":4,"creation_time":"2017-07-17T00:00:00","source":"source595","prod_prod_id":446,"cust_cust_id":873,"man_man_id":230,"qua":18}
{"order_id":344,"date_of_shipping":"2017-10-22","addres":"moscow, ulica 344","order_status":3,"creation_time":"2017-10-17T00:00:00","source":"source344","prod_prod_id":167,"cust_cust_id":802,"man_man_id":514,"qua":53}
{"order_id":145,"date_of_shipping":"2017-12-15","addres":"moscow, ulica 145","order_status":2,"creation_time":"2017-12-24T00:00:00","source":"source145","prod_prod_id":362,"cust_cust_id":282,"man_man_id":395,"qua":43}
{"order_id":496,"date_of_shipping":"2018-04-25","addres":"moscow, ulica 496","order_status":5,"creation_time":"2018-02-11T00:00:00","source":"source496","prod_prod_id":952,"cust_cust_id":174,"man_man_id":844,"qua":90}
{"order_id":42,"date_of_shipping":"2017-02-11","addres":"moscow, ulica 42","order_status":4,"creation_time":"2018-11-10T00:00:00","source":"source42","prod_prod_id":225,"cust_cust_id":338,"man_man_id":996,"qua":46}
{"order_id":612,"date_of_shipping":"2017-10-11","addres":"moscow, ulica 612","order_status":3,"creation_time":"2018-08-06T00:00:00","source":"source612","prod_prod_id":111,"cust_cust_id":890,"man_man_id":699,"qua":61}
{"order_id":743,"date_of_shipping":"2018-07-01","addres":"moscow, ulica 743","order_status":3,"creation_time":"2018-06-27T00:00:00","source":"source743","prod_prod_id":954,"cust_cust_id":898,"man_man_id":275,"qua":57}
{"order_id":631,"date_of_shipping":"2018-01-30","addres":"moscow, ulica 631","order_status":3,"creation_time":"2018-10-26T00:00:00","source":"source631","prod_prod_id":84,"cust_cust_id":147,"man_man_id":717,"qua":38}
{"order_id":737,"date_of_shipping":"2017-06-10","addres":"moscow, ulica 737","order_status":3,"creation_time":"2017-09-22T00:00:00","source":"source737","prod_prod_id":491,"cust_cust_id":430,"man_man_id":725,"qua":93}
{"order_id":246,"date_of_shipping":"2017-12-10","addres":"moscow, ulica 246","order_status":2,"creation_time":"2018-09-26T00:00:00","source":"source246","prod_prod_id":840,"cust_cust_id":993,"man_man_id":674,"qua":96}
{"order_id":636,"date_of_shipping":"2018-02-16","addres":"moscow, ulica 636","order_status":1,"creation_time":"2017-12-13T00:00:00","source":"source636","prod_prod_id":627,"cust_cust_id":53,"man_man_id":269,"qua":38}
{"order_id":613,"date_of_shipping":"2018-02-06","addres":"moscow, ulica 613","order_status":3,"creation_time":"2018-12-31T00:00:00","source":"source613","prod_prod_id":677,"cust_cust_id":839,"man_man_id":361,"qua":61}
{"order_id":844,"date_of_shipping":"2018-08-07","addres":"moscow, ulica 844","order_status":5,"creation_time":"2018-09-29T00:00:00","source":"source844","prod_prod_id":124,"cust_cust_id":666,"man_man_id":960,"qua":92}
{"order_id":288,"date_of_shipping":"2018-03-08","addres":"moscow, ulica 288","order_status":5,"creation_time":"2017-11-27T00:00:00","source":"source288","prod_prod_id":559,"cust_cust_id":999,"man_man_id":270,"qua":55}
{"order_id":697,"date_of_shipping":"2017-03-15","addres":"moscow, ulica 697","order_status":3,"creation_time":"2018-02-28T00:00:00","source":"source697","prod_prod_id":55,"cust_cust_id":351,"man_man_id":465,"qua":30}
{"order_id":380,"date_of_shipping":"2018-09-24","addres":"moscow, ulica 380","order_status":1,"creation_time":"2018-04-29T00:00:00","source":"source380","prod_prod_id":288,"cust_cust_id":279,"man_man_id":7,"qua":78}
{"order_id":881,"date_of_shipping":"2018-01-21","addres":"moscow, ulica 881","order_status":1,"creation_time":"2017-04-04T00:00:00","source":"source881","prod_prod_id":210,"cust_cust_id":934,"man_man_id":543,"qua":39}
{"order_id":281,"date_of_shipping":"2018-06-28","addres":"moscow, ulica 281","order_status":5,"creation_time":"2018-07-01T00:00:00","source":"source281","prod_prod_id":186,"cust_cust_id":582,"man_man_id":420,"qua":80}
{"order_id":874,"date_of_shipping":"2017-03-18","addres":"moscow, ulica 874","order_status":2,"creation_time":"2017-08-09T00:00:00","source":"source874","prod_prod_id":497,"cust_cust_id":486,"man_man_id":31,"qua":46}
{"order_id":373,"date_of_shipping":"2018-07-04","addres":"moscow, ulica 373","order_status":4,"creation_time":"2018-05-08T00:00:00","source":"source373","prod_prod_id":347,"cust_cust_id":550,"man_man_id":522,"qua":65}
{"order_id":923,"date_of_shipping":"2018-02-26","addres":"moscow, ulica 923","order_status":2,"creation_time":"2018-03-15T00:00:00","source":"source923","prod_prod_id":651,"cust_cust_id":667,"man_man_id":859,"qua":69}
{"order_id":747,"date_of_shipping":"2018-07-13","addres":"moscow, ulica 747","order_status":1,"creation_time":"2017-06-09T00:00:00","source":"source747","prod_prod_id":727,"cust_cust_id":718,"man_man_id":259,"qua":34}
{"order_id":800,"date_of_shipping":"2018-05-11","addres":"moscow, ulica 800","order_status":2,"creation_time":"2017-03-07T00:00:00","source":"source800","prod_prod_id":318,"cust_cust_id":947,"man_man_id":805,"qua":5}
{"order_id":733,"date_of_shipping":"2017-04-21","addres":"moscow, ulica 733","order_status":1,"creation_time":"2017-09-17T00:00:00","source":"source733","prod_prod_id":113,"cust_cust_id":450,"man_man_id":482,"qua":7}
{"order_id":367,"date_of_shipping":"2018-05-16","addres":"moscow, ulica 367","order_status":3,"creation_time":"2017-08-12T00:00:00","source":"source367","prod_prod_id":555,"cust_cust_id":211,"man_man_id":634,"qua":50}
{"order_id":948,"date_of_shipping":"2017-03-31","addres":"moscow, ulica 948","order_status":4,"creation_time":"2017-06-13T00:00:00","source":"source948","prod_prod_id":98,"cust_cust_id":349,"man_man_id":190,"qua":44}
{"order_id":772,"date_of_shipping":"2017-10-22","addres":"moscow, ulica 772","order_status":3,"creation_time":"2017-10-23T00:00:00","source":"source772","prod_prod_id":855,"cust_cust_id":354,"man_man_id":637,"qua":2}
{"order_id":342,"date_of_shipping":"2018-02-28","addres":"moscow, ulica 342","order_status":3,"creation_time":"2017-08-16T00:00:00","source":"source342","prod_prod_id":522,"cust_cust_id":239,"man_man_id":297,"qua":13}
{"order_id":4,"date_of_shipping":"2018-07-22","addres":"moscow, ulica 4","order_status":1,"creation_time":"2017-09-14T00:00:00","source":"source4","prod_prod_id":136,"cust_cust_id":789,"man_man_id":269,"qua":100}
{"order_id":240,"date_of_shipping":"2017-12-18","addres":"moscow, ulica 240","order_status":4,"creation_time":"2018-06-30T00:00:00","source":"source240","prod_prod_id":58,"cust_cust_id":25,"man_man_id":795,"qua":26}
{"order_id":950,"date_of_shipping":"2018-11-05","addres":"moscow, ulica 950","order_status":3,"creation_time":"2018-02-03T00:00:00","source":"source950","prod_prod_id":803,"cust_cust_id":682,"man_man_id":362,"qua":87}
{"order_id":475,"date_of_shipping":"2018-06-22","addres":"moscow, ulica 475","order_status":1,"creation_time":"2017-10-19T00:00:00","source":"source475","prod_prod_id":84,"cust_cust_id":345,"man_man_id":184,"qua":62}
{"order_id":135,"date_of_shipping":"2018-10-30","addres":"moscow, ulica 135","order_status":3,"creation_time":"2018-03-23T00:00:00","source":"source135","prod_prod_id":328,"cust_cust_id":892,"man_man_id":807,"qua":82}
{"order_id":926,"date_of_shipping":"2018-06-21","addres":"moscow, ulica 926","order_status":2,"creation_time":"2017-10-24T00:00:00","source":"source926","prod_prod_id":591,"cust_cust_id":437,"man_man_id":875,"qua":42}
{"order_id":216,"date_of_shipping":"2018-02-13","addres":"moscow, ulica 216","order_status":2,"creation_time":"2018-03-20T00:00:00","source":"source216","prod_prod_id":238,"cust_cust_id":772,"man_man_id":298,"qua":54}
{"order_id":699,"date_of_shipping":"2017-01-26","addres":"moscow, ulica 699","order_status":3,"creation_time":"2018-05-06T00:00:00","source":"source699","prod_prod_id":188,"cust_cust_id":258,"man_man_id":546,"qua":37}
{"order_id":782,"date_of_shipping":"2018-06-27","addres":"moscow, ulica 782","order_status":4,"creation_time":"2018-08-27T00:00:00","source":"source782","prod_prod_id":571,"cust_cust_id":886,"man_man_id":969,"qua":25}
{"order_id":23,"date_of_shipping":"2017-08-28","addres":"moscow, ulica 23","order_status":5,"creation_time":"2018-10-06T00:00:00","source":"source23","prod_prod_id":515,"cust_cust_id":691,"man_man_id":172,"qua":44}
{"order_id":57,"date_of_shipping":"2017-03-26","addres":"moscow, ulica 57","order_status":5,"creation_time":"2018-12-27T00:00:00","source":"source57","prod_prod_id":260,"cust_cust_id":967,"man_man_id":244,"qua":92}
{"order_id":222,"date_of_shipping":"2017-03-19","addres":"moscow, ulica 222","order_status":3,"creation_time":"2017-05-01T00:00:00","source":"source222","prod_prod_id":921,"cust_cust_id":857,"man_man_id":518,"qua":54}
{"order_id":674,"date_of_shipping":"2017-01-09","addres":"moscow, ulica 674","order_status":4,"creation_time":"2018-01-05T00:00:00","source":"source674","prod_prod_id":409,"cust_cust_id":556,"man_man_id":510,"qua":34}
{"order_id":249,"date_of_shipping":"2018-02-27","addres":"moscow, ulica 249","order_status":2,"creation_time":"2018-02-20T00:00:00","source":"source249","prod_prod_id":821,"cust_cust_id":819,"man_man_id":285,"qua":82}
{"order_id":659,"date_of_shipping":"2017-06-19","addres":"moscow, ulica 659","order_status":3,"creation_time":"2018-01-31T00:00:00","source":"source659","prod_prod_id":602,"cust_cust_id":571,"man_man_id":975,"qua":30}
{"order_id":460,"date_of_shipping":"2017-10-08","addres":"moscow, ulica 460","order_status":3,"creation_time":"2017-09-04T00:00:00","source":"source460","prod_prod_id":369,"cust_cust_id":813,"man_man_id":506,"qua":60}
{"order_id":269,"date_of_shipping":"2017-11-30","addres":"moscow, ulica 269","order_status":3,"creation_time":"2018-12-27T00:00:00","source":"source269","prod_prod_id":572,"cust_cust_id":340,"man_man_id":878,"qua":50}
{"order_id":574,"date_of_shipping":"2018-05-05","addres":"moscow, ulica 574","order_status":2,"creation_time":"2017-01-11T00:00:00","source":"source574","prod_prod_id":186,"cust_cust_id":696,"man_man_id":254,"qua":100}
{"order_id":129,"date_of_shipping":"2017-06-21","addres":"moscow, ulica 129","order_status":2,"creation_time":"2018-07-30T00:00:00","source":"source129","prod_prod_id":704,"cust_cust_id":678,"man_man_id":775,"qua":29}
{"order_id":2,"date_of_shipping":"2018-01-31","addres":"moscow, ulica 2","order_status":5,"creation_time":"2017-06-21T00:00:00","source":"source2","prod_prod_id":806,"cust_cust_id":958,"man_man_id":62,"qua":42}
{"order_id":449,"date_of_shipping":"2017-06-21","addres":"moscow, ulica 449","order_status":1,"creation_time":"2017-08-05T00:00:00","source":"source449","prod_prod_id":640,"cust_cust_id":506,"man_man_id":856,"qua":100}
{"order_id":763,"date_of_shipping":"2018-11-27","addres":"moscow, ulica 763","order_status":4,"creation_time":"2017-10-07T00:00:00","source":"source763","prod_prod_id":455,"cust_cust_id":13,"man_man_id":983,"qua":7}
{"order_id":207,"date_of_shipping":"2017-10-09","addres":"moscow, ulica 207","order_status":1,"creation_time":"2017-12-06T00:00:00","source":"source207","prod_prod_id":676,"cust_cust_id":921,"man_man_id":655,"qua":10}
{"order_id":755,"date_of_shipping":"2018-10-31","addres":"moscow, ulica 755","order_status":2,"creation_time":"2017-11-18T00:00:00","source":"source755","prod_prod_id":659,"cust_cust_id":833,"man_man_id":29,"qua":35}
{"order_id":916,"date_of_shipping":"2017-01-07","addres":"moscow, ulica 916","order_status":4,"creation_time":"2017-05-23T00:00:00","source":"source916","prod_prod_id":799,"cust_cust_id":209,"man_man_id":252,"qua":35}
{"order_id":70,"date_of_shipping":"2018-11-06","addres":"moscow, ulica 70","order_status":4,"creation_time":"2018-01-26T00:00:00","source":"source70","prod_prod_id":85,"cust_cust_id":403,"man_man_id":961,"qua":85}
{"order_id":315,"date_of_shipping":"2017-12-02","addres":"moscow, ulica 315","order_status":3,"creation_time":"2018-10-14T00:00:00","source":"source315","prod_prod_id":775,"cust_cust_id":803,"man_man_id":863,"qua":52}
{"order_id":46,"date_of_shipping":"2017-11-10","addres":"moscow, ulica 46","order_status":4,"creation_time":"2018-01-01T00:00:00","source":"source46","prod_prod_id":991,"cust_cust_id":994,"man_man_id":141,"qua":17}
{"order_id":729,"date_of_shipping":"2017-12-19","addres":"moscow, ulica 729","order_status":4,"creation_time":"2017-10-20T00:00:00","source":"source729","prod_prod_id":24,"cust_cust_id":438,"man_man_id":152,"qua":91}
{"order_id":17,"date_of_shipping":"2018-02-05","addres":"moscow, ulica 17","order_status":3,"creation_time":"2017-12-18T00:00:00","source":"source17","prod_prod_id":158,"cust_cust_id":855,"man_man_id":145,"qua":45}
{"order_id":900,"date_of_shipping":"2018-08-04","addres":"moscow, ulica 900","order_status":5,"creation_time":"2017-12-31T00:00:00","source":"source900","prod_prod_id":121,"cust_cust_id":762,"man_man_id":12,"qua":40}
{"order_id":592,"date_of_shipping":"2018-11-04","addres":"moscow, ulica 592","order_status":3,"creation_time":"2017-04-11T00:00:00","source":"source592","prod_prod_id":645,"cust_cust_id":391,"man_man_id":57,"qua":95}
{"order_id":247,"date_of_shipping":"2018-05-29","addres":"moscow, ulica 247","order_status":3,"creation_time":"2018-07-02T00:00:00","source":"source247","prod_prod_id":636,"cust_cust_id":142,"man_man_id":834,"qua":27}
{"order_id":861,"date_of_shipping":"2017-02-02","addres":"moscow, ulica 861","order_status":5,"creation_time":"2018-05-29T00:00:00","source":"source861","prod_prod_id":959,"cust_cust_id":379,"man_man_id":480,"qua":93}
{"order_id":99,"date_of_shipping":"2018-06-04","addres":"moscow, ulica 99","order_status":3,"creation_time":"2017-08-21T00:00:00","source":"source99","prod_prod_id":875,"cust_cust_id":804,"man_man_id":716,"qua":40}
{"order_id":952,"date_of_shipping":"2018-02-26","addres":"moscow, ulica 952","order_status":2,"creation_time":"2018-11-28T00:00:00","source":"source952","prod_prod_id":989,"cust_cust_id":738,"man_man_id":904,"qua":96}
{"order_id":922,"date_of_shipping":"2017-05-27","addres":"moscow, ulica 922","order_status":4,"creation_time":"2017-08-28T00:00:00","source":"source922","prod_prod_id":270,"cust_cust_id":850,"man_man_id":648,"qua":25}
{"order_id":199,"date_of_shipping":"2018-07-22","addres":"moscow, ulica 199","order_status":4,"creation_time":"2017-09-06T00:00:00","source":"source199","prod_prod_id":300,"cust_cust_id":870,"man_man_id":981,"qua":24}
{"order_id":163,"date_of_shipping":"2018-11-29","addres":"moscow, ulica 163","order_status":5,"creation_time":"2017-06-12T00:00:00","source":"source163","prod_prod_id":356,"cust_cust_id":508,"man_man_id":690,"qua":29}
{"order_id":964,"date_of_shipping":"2018-08-18","addres":"moscow, ulica 964","order_status":4,"creation_time":"2017-08-06T00:00:00","source":"source964","prod_prod_id":235,"cust_cust_id":502,"man_man_id":639,"qua":10}
{"order_id":910,"date_of_shipping":"2017-05-19","addres":"moscow, ulica 910","order_status":4,"creation_time":"2017-10-07T00:00:00","source":"source910","prod_prod_id":461,"cust_cust_id":861,"man_man_id":26,"qua":36}
{"order_id":100,"date_of_shipping":"2017-09-19","addres":"moscow, ulica 100","order_status":1,"creation_time":"2018-10-17T00:00:00","source":"source100","prod_prod_id":949,"cust_cust_id":155,"man_man_id":324,"qua":40}
{"order_id":239,"date_of_shipping":"2018-02-16","addres":"moscow, ulica 239","order_status":2,"creation_time":"2018-07-02T00:00:00","source":"source239","prod_prod_id":152,"cust_cust_id":80,"man_man_id":591,"qua":52}
{"order_id":59,"date_of_shipping":"2017-09-26","addres":"moscow, ulica 59","order_status":2,"creation_time":"2018-01-30T00:00:00","source":"source59","prod_prod_id":285,"cust_cust_id":66,"man_man_id":307,"qua":73}
{"order_id":596,"date_of_shipping":"2018-10-28","addres":"moscow, ulica 596","order_status":2,"creation_time":"2018-05-22T00:00:00","source":"source596","prod_prod_id":999,"cust_cust_id":190,"man_man_id":701,"qua":37}
{"order_id":793,"date_of_shipping":"2017-02-19","addres":"moscow, ulica 793","order_status":4,"creation_time":"2017-08-15T00:00:00","source":"source793","prod_prod_id":525,"cust_cust_id":7,"man_man_id":431,"qua":47}
{"order_id":898,"date_of_shipping":"2018-12-08","addres":"moscow, ulica 898","order_status":5,"creation_time":"2018-02-21T00:00:00","source":"source898","prod_prod_id":651,"cust_cust_id":771,"man_man_id":854,"qua":37}
{"order_id":301,"date_of_shipping":"2017-06-23","addres":"moscow, ulica 301","order_status":2,"creation_time":"2018-03-25T00:00:00","source":"source301","prod_prod_id":745,"cust_cust_id":871,"man_man_id":841,"qua":95}
{"order_id":403,"date_of_shipping":"2018-04-23","addres":"moscow, ulica 403","order_status":1,"creation_time":"2017-04-02T00:00:00","source":"source403","prod_prod_id":995,"cust_cust_id":786,"man_man_id":664,"qua":61}
{"order_id":835,"date_of_shipping":"2017-05-06","addres":"moscow, ulica 835","order_status":4,"creation_time":"2018-08-18T00:00:00","source":"source835","prod_prod_id":211,"cust_cust_id":702,"man_man_id":22,"qua":26}
{"order_id":385,"date_of_shipping":"2018-08-25","addres":"moscow, ulica 385","order_status":5,"creation_time":"2018-02-04T00:00:00","source":"source385","prod_prod_id":518,"cust_cust_id":915,"man_man_id":354,"qua":99}
{"order_id":124,"date_of_shipping":"2017-02-17","addres":"moscow, ulica 124","order_status":2,"creation_time":"2018-02-21T00:00:00","source":"source124","prod_prod_id":66,"cust_cust_id":848,"man_man_id":898,"qua":64}
{"order_id":86,"date_of_shipping":"2018-03-10","addres":"moscow, ulica 86","order_status":4,"creation_time":"2017-03-25T00:00:00","source":"source86","prod_prod_id":273,"cust_cust_id":248,"man_man_id":726,"qua":29}
{"order_id":658,"date_of_shipping":"2017-09-29","addres":"moscow, ulica 658","order_status":2,"creation_time":"2017-04-30T00:00:00","source":"source658","prod_prod_id":1,"cust_cust_id":820,"man_man_id":21,"qua":92}
{"order_id":557,"date_of_shipping":"2018-05-11","addres":"moscow, ulica 557","order_status":3,"creation_time":"2017-10-31T00:00:00","source":"source557","prod_prod_id":64,"cust_cust_id":884,"man_man_id":830,"qua":58}
{"order_id":296,"date_of_shipping":"2017-07-18","addres":"moscow, ulica 296","order_status":5,"creation_time":"2017-07-07T00:00:00","source":"source296","prod_prod_id":162,"cust_cust_id":939,"man_man_id":869,"qua":15}
{"order_id":579,"date_of_shipping":"2018-11-08","addres":"moscow, ulica 579","order_status":1,"creation_time":"2018-05-28T00:00:00","source":"source579","prod_prod_id":585,"cust_cust_id":740,"man_man_id":377,"qua":35}
{"order_id":713,"date_of_shipping":"2017-04-17","addres":"moscow, ulica 713","order_status":1,"creation_time":"2018-02-10T00:00:00","source":"source713","prod_prod_id":113,"cust_cust_id":959,"man_man_id":322,"qua":19}
{"order_id":649,"date_of_shipping":"2017-09-19","addres":"moscow, ulica 649","order_status":1,"creation_time":"2018-11-06T00:00:00","source":"source649","prod_prod_id":958,"cust_cust_id":657,"man_man_id":586,"qua":95}
{"order_id":322,"date_of_shipping":"2017-08-31","addres":"moscow, ulica 322","order_status":4,"creation_time":"2018-04-21T00:00:00","source":"source322","prod_prod_id":527,"cust_cust_id":943,"man_man_id":913,"qua":15}
{"order_id":418,"date_of_shipping":"2017-04-04","addres":"moscow, ulica 418","order_status":5,"creation_time":"2018-02-01T00:00:00","source":"source418","prod_prod_id":693,"cust_cust_id":218,"man_man_id":677,"qua":12}
{"order_id":456,"date_of_shipping":"2017-08-04","addres":"moscow, ulica 456","order_status":2,"creation_time":"2018-09-10T00:00:00","source":"source456","prod_prod_id":789,"cust_cust_id":501,"man_man_id":771,"qua":38}
{"order_id":389,"date_of_shipping":"2017-11-10","addres":"moscow, ulica 389","order_status":4,"creation_time":"2018-04-07T00:00:00","source":"source389","prod_prod_id":199,"cust_cust_id":190,"man_man_id":361,"qua":88}
{"order_id":903,"date_of_shipping":"2018-11-09","addres":"moscow, ulica 903","order_status":2,"creation_time":"2017-06-20T00:00:00","source":"source903","prod_prod_id":666,"cust_cust_id":424,"man_man_id":811,"qua":39}
{"order_id":261,"date_of_shipping":"2017-08-03","addres":"moscow, ulica 261","order_status":3,"creation_time":"2018-08-24T00:00:00","source":"source261","prod_prod_id":880,"cust_cust_id":331,"man_man_id":791,"qua":92}
{"order_id":751,"date_of_shipping":"2018-10-17","addres":"moscow, ulica 751","order_status":4,"creation_time":"2018-05-15T00:00:00","source":"source751","prod_prod_id":226,"cust_cust_id":224,"man_man_id":540,"qua":16}
{"order_id":127,"date_of_shipping":"2017-01-17","addres":"moscow, ulica 127","order_status":1,"creation_time":"2018-05-20T00:00:00","source":"source127","prod_prod_id":461,"cust_cust_id":171,"man_man_id":527,"qua":57}
{"order_id":662,"date_of_shipping":"2017-10-08","addres":"moscow, ulica 662","order_status":5,"creation_time":"2017-08-07T00:00:00","source":"source662","prod_prod_id":467,"cust_cust_id":597,"man_man_id":392,"qua":32}
{"order_id":661,"date_of_shipping":"2018-03-15","addres":"moscow, ulica 661","order_status":5,"creation_time":"2018-10-21T00:00:00","source":"source661","prod_prod_id":310,"cust_cust_id":764,"man_man_id":758,"qua":32}
{"order_id":295,"date_of_shipping":"2017-04-03","addres":"moscow, ulica 295","order_status":2,"creation_time":"2018-09-19T00:00:00","source":"source295","prod_prod_id":35,"cust_cust_id":473,"man_man_id":92,"qua":95}
{"order_id":56,"date_of_shipping":"2018-09-14","addres":"moscow, ulica 56","order_status":4,"creation_time":"2017-10-26T00:00:00","source":"source56","prod_prod_id":167,"cust_cust_id":803,"man_man_id":938,"qua":18}
{"order_id":72,"date_of_shipping":"2018-10-23","addres":"moscow, ulica 72","order_status":3,"creation_time":"2017-03-01T00:00:00","source":"source72","prod_prod_id":36,"cust_cust_id":387,"man_man_id":56,"qua":83}
{"order_id":461,"date_of_shipping":"2017-03-03","addres":"moscow, ulica 461","order_status":2,"creation_time":"2017-02-21T00:00:00","source":"source461","prod_prod_id":88,"cust_cust_id":489,"man_man_id":832,"qua":85}
{"order_id":969,"date_of_shipping":"2018-12-05","addres":"moscow, ulica 969","order_status":4,"creation_time":"2018-08-15T00:00:00","source":"source969","prod_prod_id":66,"cust_cust_id":869,"man_man_id":855,"qua":24}
{"order_id":480,"date_of_shipping":"2017-01-17","addres":"moscow, ulica 480","order_status":4,"creation_time":"2017-06-21T00:00:00","source":"source480","prod_prod_id":308,"cust_cust_id":460,"man_man_id":388,"qua":36}
{"order_id":996,"date_of_shipping":"2018-11-12","addres":"moscow, ulica 996","order_status":4,"creation_time":"2017-09-11T00:00:00","source":"source996","prod_prod_id":129,"cust_cust_id":903,"man_man_id":488,"qua":2}
{"order_id":259,"date_of_shipping":"2017-04-20","addres":"moscow, ulica 259","order_status":1,"creation_time":"2018-03-10T00:00:00","source":"source259","prod_prod_id":936,"cust_cust_id":268,"man_man_id":976,"qua":90}
{"order_id":536,"date_of_shipping":"2018-12-09","addres":"moscow, ulica 536","order_status":2,"creation_time":"2018-12-18T00:00:00","source":"source536","prod_prod_id":617,"cust_cust_id":811,"man_man_id":156,"qua":8}
{"order_id":576,"date_of_shipping":"2017-10-27","addres":"moscow, ulica 576","order_status":1,"creation_time":"2017-04-27T00:00:00","source":"source576","prod_prod_id":145,"cust_cust_id":503,"man_man_id":788,"qua":32}
{"order_id":463,"date_of_shipping":"2017-09-25","addres":"moscow, ulica 463","order_status":3,"creation_time":"2017-01-04T00:00:00","source":"source463","prod_prod_id":191,"cust_cust_id":22,"man_man_id":457,"qua":98}
{"order_id":313,"date_of_shipping":"2017-08-03","addres":"moscow, ulica 313","order_status":2,"creation_time":"2018-03-13T00:00:00","source":"source313","prod_prod_id":962,"cust_cust_id":262,"man_man_id":656,"qua":92}
{"order_id":218,"date_of_shipping":"2018-10-05","addres":"moscow, ulica 218","order_status":3,"creation_time":"2018-12-18T00:00:00","source":"source218","prod_prod_id":498,"cust_cust_id":406,"man_man_id":774,"qua":3}
{"order_id":718,"date_of_shipping":"2017-09-08","addres":"moscow, ulica 718","order_status":4,"creation_time":"2018-03-30T00:00:00","source":"source718","prod_prod_id":844,"cust_cust_id":900,"man_man_id":502,"qua":47}
{"order_id":184,"date_of_shipping":"2018-05-06","addres":"moscow, ulica 184","order_status":1,"creation_time":"2017-11-27T00:00:00","source":"source184","prod_prod_id":206,"cust_cust_id":38,"man_man_id":709,"qua":5}
{"order_id":653,"date_of_shipping":"2018-06-18","addres":"moscow, ulica 653","order_status":5,"creation_time":"2018-08-30T00:00:00","source":"source653","prod_prod_id":172,"cust_cust_id":161,"man_man_id":967,"qua":18}
{"order_id":225,"date_of_shipping":"2018-10-24","addres":"moscow, ulica 225","order_status":4,"creation_time":"2018-06-06T00:00:00","source":"source225","prod_prod_id":799,"cust_cust_id":258,"man_man_id":676,"qua":94}
{"order_id":251,"date_of_shipping":"2017-06-26","addres":"moscow, ulica 251","order_status":3,"creation_time":"2017-06-15T00:00:00","source":"source251","prod_prod_id":272,"cust_cust_id":631,"man_man_id":132,"qua":2}
{"order_id":319,"date_of_shipping":"2017-03-06","addres":"moscow, ulica 319","order_status":2,"creation_time":"2017-05-16T00:00:00","source":"source319","prod_prod_id":180,"cust_cust_id":331,"man_man_id":535,"qua":95}
{"order_id":66,"date_of_shipping":"2017-07-03","addres":"moscow, ulica 66","order_status":1,"creation_time":"2018-03-26T00:00:00","source":"source66","prod_prod_id":31,"cust_cust_id":269,"man_man_id":83,"qua":83}
{"order_id":173,"date_of_shipping":"2017-10-25","addres":"moscow, ulica 173","order_status":2,"creation_time":"2018-09-30T00:00:00","source":"source173","prod_prod_id":907,"cust_cust_id":395,"man_man_id":698,"qua":4}
{"order_id":289,"date_of_shipping":"2018-03-23","addres":"moscow, ulica 289","order_status":3,"creation_time":"2018-03-25T00:00:00","source":"source289","prod_prod_id":749,"cust_cust_id":514,"man_man_id":296,"qua":1}
{"order_id":518,"date_of_shipping":"2018-01-05","addres":"moscow, ulica 518","order_status":5,"creation_time":"2018-05-16T00:00:00","source":"source518","prod_prod_id":665,"cust_cust_id":145,"man_man_id":111,"qua":23}
{"order_id":8,"date_of_shipping":"2018-10-12","addres":"moscow, ulica 8","order_status":5,"creation_time":"2017-08-30T00:00:00","source":"source8","prod_prod_id":563,"cust_cust_id":619,"man_man_id":217,"qua":71}
{"order_id":495,"date_of_shipping":"2018-07-17","addres":"moscow, ulica 495","order_status":3,"creation_time":"2018-06-09T00:00:00","source":"source495","prod_prod_id":330,"cust_cust_id":368,"man_man_id":897,"qua":38}
{"order_id":339,"date_of_shipping":"2018-07-09","addres":"moscow, ulica 339","order_status":2,"creation_time":"2017-02-20T00:00:00","source":"source339","prod_prod_id":110,"cust_cust_id":841,"man_man_id":364,"qua":96}
{"order_id":700,"date_of_shipping":"2017-04-05","addres":"moscow, ulica 700","order_status":1,"creation_time":"2017-04-29T00:00:00","source":"source700","prod_prod_id":55,"cust_cust_id":560,"man_man_id":471,"qua":33}
{"order_id":107,"date_of_shipping":"2018-01-21","addres":"moscow, ulica 107","order_status":5,"creation_time":"2018-11-24T00:00:00","source":"source107","prod_prod_id":742,"cust_cust_id":909,"man_man_id":158,"qua":6}
{"order_id":164,"date_of_shipping":"2018-04-28","addres":"moscow, ulica 164","order_status":1,"creation_time":"2017-11-17T00:00:00","source":"source164","prod_prod_id":466,"cust_cust_id":913,"man_man_id":477,"qua":4}
{"order_id":798,"date_of_shipping":"2017-07-02","addres":"moscow, ulica 798","order_status":3,"creation_time":"2018-08-27T00:00:00","source":"source798","prod_prod_id":270,"cust_cust_id":357,"man_man_id":233,"qua":42}
{"order_id":374,"date_of_shipping":"2018-08-25","addres":"moscow, ulica 374","order_status":3,"creation_time":"2018-01-15T00:00:00","source":"source374","prod_prod_id":115,"cust_cust_id":446,"man_man_id":359,"qua":91}
{"order_id":77,"date_of_shipping":"2018-07-22","addres":"moscow, ulica 77","order_status":4,"creation_time":"2018-08-28T00:00:00","source":"source77","prod_prod_id":441,"cust_cust_id":548,"man_man_id":765,"qua":13}
{"order_id":599,"date_of_shipping":"2018-09-05","addres":"moscow, ulica 599","order_status":4,"creation_time":"2017-10-31T00:00:00","source":"source599","prod_prod_id":66,"cust_cust_id":761,"man_man_id":680,"qua":23}
{"order_id":512,"date_of_shipping":"2018-10-03","addres":"moscow, ulica 512","order_status":3,"creation_time":"2018-07-05T00:00:00","source":"source512","prod_prod_id":771,"cust_cust_id":24,"man_man_id":519,"qua":5}
{"order_id":434,"date_of_shipping":"2017-03-24","addres":"moscow, ulica 434","order_status":2,"creation_time":"2018-07-10T00:00:00","source":"source434","prod_prod_id":805,"cust_cust_id":999,"man_man_id":243,"qua":89}
{"order_id":735,"date_of_shipping":"2018-03-12","addres":"moscow, ulica 735","order_status":1,"creation_time":"2018-10-17T00:00:00","source":"source735","prod_prod_id":19,"cust_cust_id":616,"man_man_id":777,"qua":19}
{"order_id":270,"date_of_shipping":"2017-12-01","addres":"moscow, ulica 270","order_status":2,"creation_time":"2018-09-12T00:00:00","source":"source270","prod_prod_id":35,"cust_cust_id":963,"man_man_id":138,"qua":1}
{"order_id":345,"date_of_shipping":"2018-01-20","addres":"moscow, ulica 345","order_status":2,"creation_time":"2018-10-26T00:00:00","source":"source345","prod_prod_id":552,"cust_cust_id":759,"man_man_id":528,"qua":15}
{"order_id":314,"date_of_shipping":"2017-08-24","addres":"moscow, ulica 314","order_status":1,"creation_time":"2018-06-12T00:00:00","source":"source314","prod_prod_id":992,"cust_cust_id":877,"man_man_id":922,"qua":93}
{"order_id":65,"date_of_shipping":"2018-05-23","addres":"moscow, ulica 65","order_status":5,"creation_time":"2017-03-24T00:00:00","source":"source65","prod_prod_id":357,"cust_cust_id":680,"man_man_id":785,"qua":27}
{"order_id":38,"date_of_shipping":"2018-03-23","addres":"moscow, ulica 38","order_status":3,"creation_time":"2018-06-06T00:00:00","source":"source38","prod_prod_id":487,"cust_cust_id":156,"man_man_id":449,"qua":85}
{"order_id":120,"date_of_shipping":"2018-08-02","addres":"moscow, ulica 120","order_status":4,"creation_time":"2017-01-16T00:00:00","source":"source120","prod_prod_id":749,"cust_cust_id":19,"man_man_id":850,"qua":82}
{"order_id":695,"date_of_shipping":"2018-05-17","addres":"moscow, ulica 695","order_status":5,"creation_time":"2017-06-22T00:00:00","source":"source695","prod_prod_id":856,"cust_cust_id":132,"man_man_id":790,"qua":98}
{"order_id":32,"date_of_shipping":"2017-11-18","addres":"moscow, ulica 32","order_status":2,"creation_time":"2018-01-23T00:00:00","source":"source32","prod_prod_id":16,"cust_cust_id":699,"man_man_id":509,"qua":57}
{"order_id":684,"date_of_shipping":"2017-06-20","addres":"moscow, ulica 684","order_status":3,"creation_time":"2017-08-18T00:00:00","source":"source684","prod_prod_id":379,"cust_cust_id":218,"man_man_id":13,"qua":18}
{"order_id":63,"date_of_shipping":"2018-12-14","addres":"moscow, ulica 63","order_status":4,"creation_time":"2018-11-30T00:00:00","source":"source63","prod_prod_id":617,"cust_cust_id":726,"man_man_id":500,"qua":31}
{"order_id":357,"date_of_shipping":"2018-05-18","addres":"moscow, ulica 357","order_status":3,"creation_time":"2017-05-19T00:00:00","source":"source357","prod_prod_id":406,"cust_cust_id":5,"man_man_id":853,"qua":15}
{"order_id":337,"date_of_shipping":"2018-09-03","addres":"moscow, ulica 337","order_status":3,"creation_time":"2018-09-05T00:00:00","source":"source337","prod_prod_id":277,"cust_cust_id":420,"man_man_id":848,"qua":88}
{"order_id":904,"date_of_shipping":"2018-11-22","addres":"moscow, ulica 904","order_status":4,"creation_time":"2017-01-14T00:00:00","source":"source904","prod_prod_id":648,"cust_cust_id":575,"man_man_id":885,"qua":55}
{"order_id":326,"date_of_shipping":"2017-03-20","addres":"moscow, ulica 326","order_status":1,"creation_time":"2017-04-11T00:00:00","source":"source326","prod_prod_id":531,"cust_cust_id":395,"man_man_id":894,"qua":13}
{"order_id":494,"date_of_shipping":"2017-08-18","addres":"moscow, ulica 494","order_status":2,"creation_time":"2017-08-22T00:00:00","source":"source494","prod_prod_id":528,"cust_cust_id":397,"man_man_id":940,"qua":8}
{"order_id":492,"date_of_shipping":"2017-11-12","addres":"moscow, ulica 492","order_status":5,"creation_time":"2018-03-11T00:00:00","source":"source492","prod_prod_id":995,"cust_cust_id":831,"man_man_id":464,"qua":8}
{"order_id":825,"date_of_shipping":"2018-02-08","addres":"moscow, ulica 825","order_status":1,"creation_time":"2018-08-15T00:00:00","source":"source825","prod_prod_id":978,"cust_cust_id":347,"man_man_id":252,"qua":45}
{"order_id":664,"date_of_shipping":"2018-10-20","addres":"moscow, ulica 664","order_status":1,"creation_time":"2017-05-03T00:00:00","source":"source664","prod_prod_id":18,"cust_cust_id":836,"man_man_id":500,"qua":18}
{"order_id":633,"date_of_shipping":"2017-08-25","addres":"moscow, ulica 633","order_status":1,"creation_time":"2018-11-12T00:00:00","source":"source633","prod_prod_id":265,"cust_cust_id":561,"man_man_id":184,"qua":97}
{"order_id":363,"date_of_shipping":"2017-11-22","addres":"moscow, ulica 363","order_status":1,"creation_time":"2017-11-23T00:00:00","source":"source363","prod_prod_id":132,"cust_cust_id":375,"man_man_id":745,"qua":15}
{"order_id":823,"date_of_shipping":"2018-12-02","addres":"moscow, ulica 823","order_status":1,"creation_time":"2018-04-13T00:00:00","source":"source823","prod_prod_id":320,"cust_cust_id":117,"man_man_id":345,"qua":85}
{"order_id":931,"date_of_shipping":"2018-12-16","addres":"moscow, ulica 931","order_status":5,"creation_time":"2018-08-18T00:00:00","source":"source931","prod_prod_id":176,"cust_cust_id":377,"man_man_id":193,"qua":26}
{"order_id":709,"date_of_shipping":"2018-07-23","addres":"moscow, ulica 709","order_status":5,"creation_time":"2018-11-22T00:00:00","source":"source709","prod_prod_id":788,"cust_cust_id":768,"man_man_id":486,"qua":44}
{"order_id":609,"date_of_shipping":"2017-02-06","addres":"moscow, ulica 609","order_status":4,"creation_time":"2018-07-14T00:00:00","source":"source609","prod_prod_id":332,"cust_cust_id":342,"man_man_id":864,"qua":35}
{"order_id":126,"date_of_shipping":"2017-07-30","addres":"moscow, ulica 126","order_status":2,"creation_time":"2018-06-18T00:00:00","source":"source126","prod_prod_id":466,"cust_cust_id":801,"man_man_id":809,"qua":27}
{"order_id":125,"date_of_shipping":"2018-12-31","addres":"moscow, ulica 125","order_status":1,"creation_time":"2018-05-04T00:00:00","source":"source125","prod_prod_id":370,"cust_cust_id":120,"man_man_id":817,"qua":27}
{"order_id":245,"date_of_shipping":"2018-03-30","addres":"moscow, ulica 245","order_status":4,"creation_time":"2017-11-27T00:00:00","source":"source245","prod_prod_id":169,"cust_cust_id":736,"man_man_id":240,"qua":3}
{"order_id":71,"date_of_shipping":"2017-01-20","addres":"moscow, ulica 71","order_status":5,"creation_time":"2017-08-21T00:00:00","source":"source71","prod_prod_id":663,"cust_cust_id":710,"man_man_id":935,"qua":65}
{"order_id":902,"date_of_shipping":"2018-10-08","addres":"moscow, ulica 902","order_status":2,"creation_time":"2018-10-08T00:00:00","source":"source902","prod_prod_id":827,"cust_cust_id":969,"man_man_id":63,"qua":39}
{"order_id":680,"date_of_shipping":"2017-04-13","addres":"moscow, ulica 680","order_status":3,"creation_time":"2017-01-17T00:00:00","source":"source680","prod_prod_id":457,"cust_cust_id":956,"man_man_id":218,"qua":19}
{"order_id":481,"date_of_shipping":"2017-09-30","addres":"moscow, ulica 481","order_status":2,"creation_time":"2018-01-27T00:00:00","source":"source481","prod_prod_id":70,"cust_cust_id":769,"man_man_id":391,"qua":9}
{"order_id":604,"date_of_shipping":"2018-10-10","addres":"moscow, ulica 604","order_status":1,"creation_time":"2018-05-04T00:00:00","source":"source604","prod_prod_id":224,"cust_cust_id":970,"man_man_id":508,"qua":97}
{"order_id":192,"date_of_shipping":"2018-09-29","addres":"moscow, ulica 192","order_status":4,"creation_time":"2017-09-21T00:00:00","source":"source192","prod_prod_id":591,"cust_cust_id":410,"man_man_id":452,"qua":14}
{"order_id":683,"date_of_shipping":"2018-09-20","addres":"moscow, ulica 683","order_status":4,"creation_time":"2018-12-06T00:00:00","source":"source683","prod_prod_id":635,"cust_cust_id":367,"man_man_id":573,"qua":19}
{"order_id":395,"date_of_shipping":"2018-09-11","addres":"moscow, ulica 395","order_status":4,"creation_time":"2018-02-07T00:00:00","source":"source395","prod_prod_id":720,"cust_cust_id":821,"man_man_id":672,"qua":8}
{"order_id":73,"date_of_shipping":"2017-07-28","addres":"moscow, ulica 73","order_status":1,"creation_time":"2017-11-29T00:00:00","source":"source73","prod_prod_id":733,"cust_cust_id":513,"man_man_id":433,"qua":24}
{"order_id":672,"date_of_shipping":"2017-07-18","addres":"moscow, ulica 672","order_status":4,"creation_time":"2018-01-21T00:00:00","source":"source672","prod_prod_id":604,"cust_cust_id":92,"man_man_id":675,"qua":20}
{"order_id":885,"date_of_shipping":"2017-10-13","addres":"moscow, ulica 885","order_status":1,"creation_time":"2017-08-29T00:00:00","source":"source885","prod_prod_id":312,"cust_cust_id":281,"man_man_id":583,"qua":29}
{"order_id":391,"date_of_shipping":"2018-07-11","addres":"moscow, ulica 391","order_status":1,"creation_time":"2018-11-05T00:00:00","source":"source391","prod_prod_id":902,"cust_cust_id":223,"man_man_id":63,"qua":98}
{"order_id":726,"date_of_shipping":"2018-05-07","addres":"moscow, ulica 726","order_status":5,"creation_time":"2017-08-17T00:00:00","source":"source726","prod_prod_id":262,"cust_cust_id":847,"man_man_id":660,"qua":30}
{"order_id":560,"date_of_shipping":"2017-02-01","addres":"moscow, ulica 560","order_status":1,"creation_time":"2018-01-03T00:00:00","source":"source560","prod_prod_id":704,"cust_cust_id":438,"man_man_id":876,"qua":97}
{"order_id":897,"date_of_shipping":"2018-07-03","addres":"moscow, ulica 897","order_status":1,"creation_time":"2018-06-28T00:00:00","source":"source897","prod_prod_id":301,"cust_cust_id":794,"man_man_id":858,"qua":24}
{"order_id":420,"date_of_shipping":"2017-10-23","addres":"moscow, ulica 420","order_status":5,"creation_time":"2018-08-01T00:00:00","source":"source420","prod_prod_id":60,"cust_cust_id":896,"man_man_id":405,"qua":87}
{"order_id":491,"date_of_shipping":"2018-11-29","addres":"moscow, ulica 491","order_status":1,"creation_time":"2017-11-24T00:00:00","source":"source491","prod_prod_id":495,"cust_cust_id":450,"man_man_id":2,"qua":85}
{"order_id":271,"date_of_shipping":"2017-06-13","addres":"moscow, ulica 271","order_status":1,"creation_time":"2018-07-30T00:00:00","source":"source271","prod_prod_id":394,"cust_cust_id":500,"man_man_id":384,"qua":15}
{"order_id":309,"date_of_shipping":"2018-08-04","addres":"moscow, ulica 309","order_status":1,"creation_time":"2017-03-12T00:00:00","source":"source309","prod_prod_id":316,"cust_cust_id":996,"man_man_id":45,"qua":14}
{"order_id":298,"date_of_shipping":"2017-06-20","addres":"moscow, ulica 298","order_status":1,"creation_time":"2017-07-25T00:00:00","source":"source298","prod_prod_id":764,"cust_cust_id":321,"man_man_id":408,"qua":75}
{"order_id":408,"date_of_shipping":"2017-08-22","addres":"moscow, ulica 408","order_status":3,"creation_time":"2017-01-14T00:00:00","source":"source408","prod_prod_id":448,"cust_cust_id":444,"man_man_id":172,"qua":11}
{"order_id":939,"date_of_shipping":"2017-09-02","addres":"moscow, ulica 939","order_status":1,"creation_time":"2018-01-17T00:00:00","source":"source939","prod_prod_id":895,"cust_cust_id":108,"man_man_id":7,"qua":40}
{"order_id":831,"date_of_shipping":"2017-11-16","addres":"moscow, ulica 831","order_status":4,"creation_time":"2018-02-17T00:00:00","source":"source831","prod_prod_id":345,"cust_cust_id":758,"man_man_id":705,"qua":47}
{"order_id":139,"date_of_shipping":"2018-04-21","addres":"moscow, ulica 139","order_status":2,"creation_time":"2017-06-26T00:00:00","source":"source139","prod_prod_id":694,"cust_cust_id":230,"man_man_id":566,"qua":76}
{"order_id":742,"date_of_shipping":"2018-06-21","addres":"moscow, ulica 742","order_status":1,"creation_time":"2017-04-15T00:00:00","source":"source742","prod_prod_id":371,"cust_cust_id":236,"man_man_id":282,"qua":17}
{"order_id":5,"date_of_shipping":"2017-01-17","addres":"moscow, ulica 5","order_status":3,"creation_time":"2018-04-19T00:00:00","source":"source5","prod_prod_id":398,"cust_cust_id":394,"man_man_id":671,"qua":64}
{"order_id":880,"date_of_shipping":"2017-02-13","addres":"moscow, ulica 880","order_status":2,"creation_time":"2018-10-09T00:00:00","source":"source880","prod_prod_id":278,"cust_cust_id":50,"man_man_id":141,"qua":31}
{"order_id":30,"date_of_shipping":"2017-08-02","addres":"moscow, ulica 30","order_status":2,"creation_time":"2017-11-10T00:00:00","source":"source30","prod_prod_id":86,"cust_cust_id":75,"man_man_id":282,"qua":26}
{"order_id":905,"date_of_shipping":"2017-09-15","addres":"moscow, ulica 905","order_status":3,"creation_time":"2018-06-24T00:00:00","source":"source905","prod_prod_id":377,"cust_cust_id":224,"man_man_id":745,"qua":29}
{"order_id":101,"date_of_shipping":"2017-05-12","addres":"moscow, ulica 101","order_status":5,"creation_time":"2018-08-14T00:00:00","source":"source101","prod_prod_id":688,"cust_cust_id":764,"man_man_id":692,"qua":31}
{"order_id":730,"date_of_shipping":"2018-06-23","addres":"moscow, ulica 730","order_status":1,"creation_time":"2018-05-14T00:00:00","source":"source730","prod_prod_id":847,"cust_cust_id":349,"man_man_id":568,"qua":96}
{"order_id":545,"date_of_shipping":"2017-01-22","addres":"moscow, ulica 545","order_status":5,"creation_time":"2017-05-14T00:00:00","source":"source545","prod_prod_id":25,"cust_cust_id":871,"man_man_id":616,"qua":99}
{"order_id":802,"date_of_shipping":"2018-01-15","addres":"moscow, ulica 802","order_status":2,"creation_time":"2018-12-08T00:00:00","source":"source802","prod_prod_id":3,"cust_cust_id":192,"man_man_id":346,"qua":69}
{"order_id":427,"date_of_shipping":"2017-12-09","addres":"moscow, ulica 427","order_status":3,"creation_time":"2017-05-30T00:00:00","source":"source427","prod_prod_id":350,"cust_cust_id":625,"man_man_id":545,"qua":8}
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.products (product_id, articul, nme, category, weigth, dateofrelease, price) FROM stdin;
1	100001	product 1	cat 1	2217	2017-08-25	40890
2	100002	product 2	cat 1	1478	2018-10-13	12868
3	100003	product 3	cat 1	4067	2017-09-19	83130
4	100004	product 4	cat 1	891	2018-03-24	29065
5	100005	product 5	cat 1	3461	2017-11-02	55762
6	100006	product 6	cat 5	3013	2017-10-22	3517
7	100007	product 7	cat 1	3133	2018-01-12	48307
8	100008	product 8	cat 1	4079	2018-07-20	10489
9	100009	product 9	cat 1	223	2018-10-11	14850
10	100010	product 10	cat 1	1472	2018-08-09	53288
11	100011	product 11	cat 1	1545	2018-06-12	35615
12	100012	product 12	cat 1	3504	2017-06-26	48884
13	100013	product 13	cat 2	2490	2017-05-24	50650
14	100014	product 14	cat 3	2102	2018-11-22	51137
15	100015	product 15	cat 4	3358	2018-12-12	12356
16	100016	product 16	cat 5	3230	2018-10-15	13848
17	100017	product 17	cat 6	486	2018-12-04	9315
18	100018	product 18	cat 7	4042	2017-08-15	58536
19	100019	product 19	cat 8	2818	2017-06-01	56768
20	100020	product 20	cat 9	3101	2017-02-19	22987
21	100021	product 21	cat 10	923	2018-06-12	50075
22	100022	product 22	cat 11	100	2017-09-25	61492
23	100023	product 23	cat 3	2790	2018-09-03	45941
24	100024	product 24	cat 3	923	2017-02-23	45488
25	100025	product 25	cat 14	4188	2018-09-25	26131
26	100026	product 26	cat 15	2744	2018-01-15	62478
27	100027	product 27	cat 16	1742	2018-06-23	39292
28	100028	product 28	cat 17	1384	2017-02-17	40104
29	100029	product 29	cat 18	2578	2017-05-11	2206
30	100030	product 30	cat 19	799	2017-08-04	69769
31	100031	product 31	cat 20	512	2017-09-02	79784
32	100032	product 32	cat 21	2660	2018-12-29	52813
33	100033	product 33	cat 22	940	2018-04-01	22741
34	100034	product 34	cat 23	4006	2017-03-12	52340
35	100035	product 35	cat 24	2581	2017-01-17	1057
36	100036	product 36	cat 25	2927	2018-12-10	62869
37	100037	product 37	cat 26	246	2017-02-25	27696
38	100038	product 38	cat 27	2056	2018-12-13	89570
39	100039	product 39	cat 28	2459	2017-01-28	15703
40	100040	product 40	cat 29	3021	2017-11-29	13802
41	100041	product 41	cat 30	3418	2018-01-09	6014
42	100042	product 42	cat 31	4204	2018-02-21	57104
43	100043	product 43	cat 32	318	2018-08-16	60644
44	100044	product 44	cat 33	2091	2018-04-25	47436
45	100045	product 45	cat 34	4922	2017-03-30	46786
46	100046	product 46	cat 35	4351	2018-04-16	46491
47	100047	product 47	cat 36	734	2017-07-17	8441
48	100048	product 48	cat 37	4359	2017-01-31	80265
49	100049	product 49	cat 38	2763	2018-05-11	33361
50	100050	product 50	cat 39	4288	2018-07-13	85890
51	100051	product 51	cat 40	808	2018-06-24	745
52	100052	product 52	cat 41	1577	2017-01-11	1054
53	100053	product 53	cat 42	4057	2018-04-25	66276
54	100054	product 54	cat 43	1054	2018-10-18	22147
55	100055	product 55	cat 44	814	2018-07-03	48080
56	100056	product 56	cat 45	1685	2018-12-14	6014
57	100057	product 57	cat 46	4605	2017-01-02	72577
58	100058	product 58	cat 47	907	2018-06-27	73060
59	100059	product 59	cat 48	2678	2017-08-11	27411
60	100060	product 60	cat 49	3033	2017-03-08	52146
61	100061	product 61	cat 50	1228	2017-04-25	51119
62	100062	product 62	cat 51	4585	2017-01-18	53785
63	100063	product 63	cat 52	213	2018-01-23	55836
64	100064	product 64	cat 53	3373	2018-04-12	57653
65	100065	product 65	cat 54	4403	2018-05-22	86056
66	100066	product 66	cat 55	3071	2017-04-06	27295
67	100067	product 67	cat 56	1828	2017-06-18	14105
68	100068	product 68	cat 57	3344	2018-12-14	24852
69	100069	product 69	cat 58	1292	2018-10-17	40917
70	100070	product 70	cat 59	2021	2018-05-11	69720
71	100071	product 71	cat 60	2139	2018-11-24	54352
72	100072	product 72	cat 61	1505	2017-02-13	89446
73	100073	product 73	cat 62	4154	2018-01-18	80453
74	100074	product 74	cat 63	151	2018-09-25	28118
75	100075	product 75	cat 64	3762	2018-04-12	18306
76	100076	product 76	cat 65	3877	2017-01-11	26071
77	100077	product 77	cat 66	3484	2018-07-28	64245
78	100078	product 78	cat 67	4627	2017-03-31	71997
79	100079	product 79	cat 68	4752	2018-10-11	43496
80	100080	product 80	cat 69	1058	2017-06-23	26998
81	100081	product 81	cat 70	2692	2018-06-14	31141
82	100082	product 82	cat 71	1657	2018-10-16	45991
83	100083	product 83	cat 72	4025	2017-10-01	31476
84	100084	product 84	cat 73	1097	2018-07-18	53647
85	100085	product 85	cat 74	3268	2018-11-28	6287
86	100086	product 86	cat 75	428	2018-09-30	67949
87	100087	product 87	cat 76	2067	2017-04-12	81133
88	100088	product 88	cat 77	4177	2018-07-07	20473
89	100089	product 89	cat 78	4998	2017-03-22	7809
90	100090	product 90	cat 79	1534	2018-04-21	3719
91	100091	product 91	cat 80	2435	2017-04-30	66379
92	100092	product 92	cat 81	1204	2018-05-27	69573
93	100093	product 93	cat 82	2407	2017-06-17	64884
94	100094	product 94	cat 83	2907	2017-01-05	65490
95	100095	product 95	cat 84	432	2018-07-31	37808
96	100096	product 96	cat 85	1652	2017-12-18	14303
97	100097	product 97	cat 86	165	2018-04-01	28090
98	100098	product 98	cat 87	1031	2017-03-04	29748
99	100099	product 99	cat 88	2627	2017-01-09	45728
100	100100	product 100	cat 89	4301	2018-04-06	24694
101	100101	product 101	cat 90	4954	2018-04-15	80315
102	100102	product 102	cat 91	2867	2018-10-10	32126
103	100103	product 103	cat 92	4757	2018-03-13	837
104	100104	product 104	cat 93	2681	2018-11-23	77596
105	100105	product 105	cat 94	2816	2018-01-23	4041
106	100106	product 106	cat 95	4365	2017-01-21	73523
107	100107	product 107	cat 96	2936	2018-04-29	82203
108	100108	product 108	cat 97	1714	2017-02-22	14253
109	100109	product 109	cat 98	4333	2018-06-15	69014
110	100110	product 110	cat 99	1908	2017-06-05	5449
111	100111	product 111	cat 100	106	2018-05-21	57082
112	100112	product 112	cat 101	2379	2018-12-02	41194
113	100113	product 113	cat 102	1349	2018-04-29	39165
114	100114	product 114	cat 103	4301	2018-04-12	48160
115	100115	product 115	cat 104	152	2018-02-07	87506
116	100116	product 116	cat 105	1471	2017-08-09	4391
117	100117	product 117	cat 106	204	2017-04-14	8987
118	100118	product 118	cat 107	284	2018-11-22	11475
119	100119	product 119	cat 108	4881	2018-12-22	63081
120	100120	product 120	cat 109	2045	2017-03-27	83026
121	100121	product 121	cat 110	3254	2018-05-03	66400
122	100122	product 122	cat 111	4405	2017-01-18	7211
123	100123	product 123	cat 112	3174	2017-10-23	36121
124	100124	product 124	cat 113	1031	2018-10-06	57790
125	100125	product 125	cat 114	1584	2017-03-30	22108
126	100126	product 126	cat 115	4397	2017-01-05	3369
127	100127	product 127	cat 116	2285	2018-03-14	47360
128	100128	product 128	cat 117	4588	2018-02-03	6942
129	100129	product 129	cat 118	1918	2018-05-22	83596
130	100130	product 130	cat 119	2477	2017-02-21	18866
131	100131	product 131	cat 120	4836	2017-11-19	16385
132	100132	product 132	cat 121	229	2018-03-26	7246
133	100133	product 133	cat 122	1786	2017-10-28	36536
134	100134	product 134	cat 123	2564	2018-05-02	84204
135	100135	product 135	cat 124	3742	2018-12-09	87553
136	100136	product 136	cat 125	3795	2017-03-09	77932
137	100137	product 137	cat 126	237	2018-10-29	12542
138	100138	product 138	cat 127	3146	2018-08-09	60005
139	100139	product 139	cat 128	2594	2018-02-19	7708
140	100140	product 140	cat 129	2319	2018-05-08	68758
141	100141	product 141	cat 130	1345	2017-03-07	13441
142	100142	product 142	cat 131	756	2018-11-18	75431
143	100143	product 143	cat 132	4792	2018-01-07	46533
144	100144	product 144	cat 133	2344	2018-09-14	75916
145	100145	product 145	cat 134	4222	2018-11-06	14784
146	100146	product 146	cat 135	4117	2017-04-15	1404
147	100147	product 147	cat 136	730	2018-03-06	29458
148	100148	product 148	cat 137	1999	2018-01-17	80239
149	100149	product 149	cat 138	3000	2017-12-23	7011
150	100150	product 150	cat 139	1413	2017-08-12	3595
151	100151	product 151	cat 140	1010	2018-08-27	35847
152	100152	product 152	cat 141	827	2017-10-23	70118
153	100153	product 153	cat 142	1049	2017-04-17	57297
154	100154	product 154	cat 143	2616	2018-10-11	79101
155	100155	product 155	cat 144	3898	2018-03-28	65948
156	100156	product 156	cat 145	322	2017-05-08	16222
157	100157	product 157	cat 146	3391	2017-10-26	28625
158	100158	product 158	cat 147	3344	2017-06-23	86233
159	100159	product 159	cat 148	2568	2018-04-10	2066
160	100160	product 160	cat 149	326	2017-06-21	65097
161	100161	product 161	cat 150	2885	2017-09-16	75682
162	100162	product 162	cat 151	1677	2017-04-22	34341
163	100163	product 163	cat 152	4445	2017-12-13	55914
164	100164	product 164	cat 153	3141	2018-08-11	11827
165	100165	product 165	cat 154	2019	2018-08-31	25830
166	100166	product 166	cat 155	4341	2018-10-07	20434
167	100167	product 167	cat 156	2146	2017-01-20	61713
168	100168	product 168	cat 157	2133	2017-11-16	32659
169	100169	product 169	cat 158	2783	2018-11-16	81385
170	100170	product 170	cat 159	2986	2017-05-21	75816
171	100171	product 171	cat 160	162	2017-05-05	37676
172	100172	product 172	cat 161	2055	2018-07-05	42947
173	100173	product 173	cat 162	989	2017-08-21	58624
174	100174	product 174	cat 163	2536	2018-10-17	63353
175	100175	product 175	cat 164	3475	2018-09-08	43854
176	100176	product 176	cat 165	1198	2017-08-05	19945
177	100177	product 177	cat 166	2061	2018-06-22	65819
178	100178	product 178	cat 167	4082	2018-09-15	66953
179	100179	product 179	cat 168	864	2017-06-15	85356
180	100180	product 180	cat 169	324	2017-05-02	42420
181	100181	product 181	cat 170	2262	2017-02-05	15839
182	100182	product 182	cat 171	1041	2018-03-19	46661
183	100183	product 183	cat 172	4968	2018-12-18	22489
184	100184	product 184	cat 173	1824	2018-05-23	87946
185	100185	product 185	cat 174	2044	2017-06-04	33172
186	100186	product 186	cat 175	4591	2018-10-24	69677
187	100187	product 187	cat 176	4633	2018-12-18	25235
188	100188	product 188	cat 177	4672	2017-07-16	41028
189	100189	product 189	cat 178	1600	2017-04-26	17935
190	100190	product 190	cat 179	2302	2017-07-01	61173
191	100191	product 191	cat 180	4576	2017-06-17	71562
192	100192	product 192	cat 181	2985	2018-06-25	85707
193	100193	product 193	cat 182	3393	2017-03-21	58741
194	100194	product 194	cat 183	3675	2017-10-29	48752
195	100195	product 195	cat 184	645	2018-11-29	24224
196	100196	product 196	cat 185	2344	2017-11-01	26270
197	100197	product 197	cat 186	1600	2018-08-11	58293
198	100198	product 198	cat 187	1110	2017-01-04	54329
199	100199	product 199	cat 188	840	2017-09-20	42581
200	100200	product 200	cat 189	4621	2018-09-02	15734
201	100201	product 201	cat 190	2351	2018-04-10	27429
202	100202	product 202	cat 191	1961	2018-09-13	24434
203	100203	product 203	cat 192	4872	2017-10-06	46866
204	100204	product 204	cat 193	1815	2017-10-30	72079
205	100205	product 205	cat 194	3353	2017-09-02	14157
206	100206	product 206	cat 195	1519	2018-09-09	17268
207	100207	product 207	cat 196	395	2017-03-05	75495
208	100208	product 208	cat 197	4407	2018-01-10	81278
209	100209	product 209	cat 198	1414	2017-04-05	7505
210	100210	product 210	cat 199	4288	2017-09-04	5855
211	100211	product 211	cat 200	4559	2018-09-21	39414
212	100212	product 212	cat 201	4640	2018-02-27	38815
213	100213	product 213	cat 202	3335	2017-03-22	1737
214	100214	product 214	cat 203	3482	2018-02-21	41640
215	100215	product 215	cat 204	4648	2017-04-05	49687
216	100216	product 216	cat 205	1968	2017-02-17	1884
217	100217	product 217	cat 206	3519	2018-10-12	24597
218	100218	product 218	cat 207	3687	2018-01-13	85209
219	100219	product 219	cat 208	452	2018-02-12	15039
220	100220	product 220	cat 209	4645	2018-12-27	88050
221	100221	product 221	cat 210	3318	2018-12-12	73835
222	100222	product 222	cat 211	4945	2017-01-15	84260
223	100223	product 223	cat 212	3108	2017-10-18	15733
224	100224	product 224	cat 213	2149	2017-01-27	47302
225	100225	product 225	cat 214	1901	2017-11-13	47662
226	100226	product 226	cat 215	1563	2017-11-13	80548
227	100227	product 227	cat 216	1723	2018-08-14	15688
228	100228	product 228	cat 217	3474	2018-06-20	6755
229	100229	product 229	cat 218	1635	2018-03-19	41118
230	100230	product 230	cat 219	1324	2017-01-17	1432
231	100231	product 231	cat 220	3143	2017-04-09	64698
232	100232	product 232	cat 221	4163	2017-05-20	66924
233	100233	product 233	cat 222	639	2017-02-19	37695
234	100234	product 234	cat 223	4385	2018-05-05	48328
235	100235	product 235	cat 224	3889	2017-04-30	68323
236	100236	product 236	cat 225	1870	2017-02-18	88651
237	100237	product 237	cat 226	1516	2018-03-26	45854
238	100238	product 238	cat 227	3968	2017-04-09	12337
239	100239	product 239	cat 228	1840	2018-06-05	28518
240	100240	product 240	cat 229	920	2017-12-22	73440
241	100241	product 241	cat 230	197	2017-09-27	34407
242	100242	product 242	cat 231	1437	2018-12-11	62595
243	100243	product 243	cat 232	2942	2018-10-30	30568
244	100244	product 244	cat 233	4395	2018-03-07	74969
245	100245	product 245	cat 234	311	2017-05-07	32953
246	100246	product 246	cat 235	1372	2017-10-07	24941
247	100247	product 247	cat 236	125	2018-10-01	35144
248	100248	product 248	cat 237	1182	2018-07-06	71422
249	100249	product 249	cat 238	4893	2018-04-19	74558
250	100250	product 250	cat 239	1136	2018-03-19	26178
251	100251	product 251	cat 240	4483	2018-07-12	32629
252	100252	product 252	cat 241	2905	2018-12-24	62337
253	100253	product 253	cat 242	626	2018-04-16	61919
254	100254	product 254	cat 243	4316	2018-08-10	657
255	100255	product 255	cat 244	3293	2018-07-13	58536
256	100256	product 256	cat 245	2551	2018-03-16	43921
257	100257	product 257	cat 246	2205	2017-06-30	37984
258	100258	product 258	cat 247	3532	2017-11-01	47495
259	100259	product 259	cat 248	3620	2018-01-11	14978
260	100260	product 260	cat 249	217	2017-03-11	62067
261	100261	product 261	cat 250	4842	2017-06-10	43457
262	100262	product 262	cat 251	2841	2017-05-09	81961
263	100263	product 263	cat 252	2279	2018-12-19	63966
264	100264	product 264	cat 253	1608	2018-06-05	9052
265	100265	product 265	cat 254	1082	2017-01-22	1006
266	100266	product 266	cat 255	3377	2018-06-20	64748
267	100267	product 267	cat 256	2563	2018-06-24	1156
268	100268	product 268	cat 257	4729	2017-10-31	73833
269	100269	product 269	cat 258	2247	2017-08-05	23697
270	100270	product 270	cat 259	1912	2017-07-16	35431
271	100271	product 271	cat 260	3796	2018-06-30	59137
272	100272	product 272	cat 261	3453	2017-09-19	84489
273	100273	product 273	cat 262	4371	2018-04-14	4122
274	100274	product 274	cat 263	1196	2018-01-23	17656
275	100275	product 275	cat 264	778	2017-09-20	83349
276	100276	product 276	cat 265	1582	2018-04-24	64301
277	100277	product 277	cat 266	1630	2018-05-11	6496
278	100278	product 278	cat 267	245	2017-12-23	65495
279	100279	product 279	cat 268	3595	2017-05-20	68416
280	100280	product 280	cat 269	3005	2018-03-10	31412
281	100281	product 281	cat 270	3568	2018-03-15	8687
282	100282	product 282	cat 271	2102	2017-07-08	80076
283	100283	product 283	cat 272	4653	2018-07-14	43372
284	100284	product 284	cat 273	1257	2018-04-26	11179
285	100285	product 285	cat 274	4803	2017-12-13	81356
286	100286	product 286	cat 275	1422	2018-06-26	73939
287	100287	product 287	cat 276	4646	2018-02-25	7236
288	100288	product 288	cat 277	3135	2017-12-21	38838
289	100289	product 289	cat 278	3104	2018-07-19	58902
290	100290	product 290	cat 279	2978	2018-01-03	22684
291	100291	product 291	cat 280	4327	2018-12-08	24205
292	100292	product 292	cat 281	3079	2018-04-10	72048
293	100293	product 293	cat 282	685	2018-09-25	27670
294	100294	product 294	cat 283	583	2018-05-31	1204
295	100295	product 295	cat 284	2495	2018-07-30	525
296	100296	product 296	cat 285	2800	2017-02-12	9908
297	100297	product 297	cat 286	943	2018-03-31	3903
298	100298	product 298	cat 287	4022	2017-09-08	18441
299	100299	product 299	cat 288	2007	2018-07-25	22310
300	100300	product 300	cat 289	2760	2017-09-08	3262
301	100301	product 301	cat 290	4807	2018-01-31	11644
302	100302	product 302	cat 291	2168	2017-02-22	89687
303	100303	product 303	cat 292	2610	2018-05-21	418
304	100304	product 304	cat 293	1713	2017-08-13	9371
305	100305	product 305	cat 294	2539	2018-04-23	69525
306	100306	product 306	cat 295	1421	2018-05-06	8001
307	100307	product 307	cat 296	3295	2018-12-16	62818
308	100308	product 308	cat 297	1671	2018-05-30	14655
309	100309	product 309	cat 298	1259	2017-11-26	7010
310	100310	product 310	cat 299	1793	2018-10-16	87048
311	100311	product 311	cat 300	4284	2018-11-22	68466
312	100312	product 312	cat 301	884	2017-10-16	67472
313	100313	product 313	cat 302	1621	2018-05-16	7669
314	100314	product 314	cat 303	565	2018-07-28	13372
315	100315	product 315	cat 304	3765	2018-10-15	61532
316	100316	product 316	cat 305	136	2017-02-19	38357
317	100317	product 317	cat 306	4626	2017-08-14	21815
318	100318	product 318	cat 307	425	2017-05-27	74805
319	100319	product 319	cat 308	3077	2017-05-05	41643
320	100320	product 320	cat 309	4689	2017-03-23	63250
321	100321	product 321	cat 310	4780	2017-09-23	9170
322	100322	product 322	cat 311	1332	2017-03-15	60414
323	100323	product 323	cat 312	2490	2018-11-30	63870
324	100324	product 324	cat 313	4682	2017-07-24	56297
325	100325	product 325	cat 314	2254	2017-09-14	29731
326	100326	product 326	cat 315	3956	2017-05-23	5094
327	100327	product 327	cat 316	3778	2017-06-17	24730
328	100328	product 328	cat 317	4531	2018-09-24	88722
329	100329	product 329	cat 318	3847	2017-02-13	56517
330	100330	product 330	cat 319	2752	2017-01-15	54281
331	100331	product 331	cat 320	1110	2018-08-01	22637
332	100332	product 332	cat 321	1512	2018-08-30	41725
333	100333	product 333	cat 322	657	2017-02-14	10487
334	100334	product 334	cat 323	3260	2017-03-05	27777
335	100335	product 335	cat 324	282	2018-11-22	68425
336	100336	product 336	cat 325	783	2018-08-06	61727
337	100337	product 337	cat 326	552	2018-09-02	71663
338	100338	product 338	cat 327	3777	2017-04-29	56277
339	100339	product 339	cat 328	1415	2017-04-07	56876
340	100340	product 340	cat 329	3748	2017-10-23	12109
341	100341	product 341	cat 330	2875	2018-04-02	16586
342	100342	product 342	cat 331	4236	2017-07-15	18478
343	100343	product 343	cat 332	3560	2017-06-04	81031
344	100344	product 344	cat 333	4497	2018-11-15	82396
345	100345	product 345	cat 334	284	2017-05-11	11045
346	100346	product 346	cat 335	2166	2017-03-15	35990
347	100347	product 347	cat 336	4704	2018-02-06	60186
348	100348	product 348	cat 337	3147	2017-08-17	43914
349	100349	product 349	cat 338	607	2018-04-04	33847
350	100350	product 350	cat 339	2958	2017-12-11	52406
351	100351	product 351	cat 340	3856	2017-02-06	75870
352	100352	product 352	cat 341	4791	2018-09-07	88967
353	100353	product 353	cat 342	3379	2017-08-21	9352
354	100354	product 354	cat 343	3064	2017-02-07	43134
355	100355	product 355	cat 344	1429	2017-06-24	14670
356	100356	product 356	cat 345	3403	2017-12-06	79734
357	100357	product 357	cat 346	370	2018-05-12	63484
358	100358	product 358	cat 347	213	2017-05-06	64481
359	100359	product 359	cat 348	146	2018-12-27	89304
360	100360	product 360	cat 349	4608	2017-11-07	22506
361	100361	product 361	cat 350	4283	2018-08-19	54174
362	100362	product 362	cat 351	3462	2018-01-29	20489
363	100363	product 363	cat 352	4104	2017-06-20	18953
364	100364	product 364	cat 353	3400	2017-06-30	8825
365	100365	product 365	cat 354	4011	2018-04-13	63282
366	100366	product 366	cat 355	3347	2017-12-07	34000
367	100367	product 367	cat 356	513	2017-09-04	20688
368	100368	product 368	cat 357	2728	2018-11-23	28326
369	100369	product 369	cat 358	3308	2018-12-16	383
370	100370	product 370	cat 359	2232	2017-07-16	62094
371	100371	product 371	cat 360	3386	2017-12-12	60653
372	100372	product 372	cat 361	1688	2018-07-19	46986
373	100373	product 373	cat 362	3160	2017-06-07	47865
374	100374	product 374	cat 363	4041	2017-02-16	70170
375	100375	product 375	cat 364	365	2017-03-07	3486
376	100376	product 376	cat 365	603	2018-10-25	78024
377	100377	product 377	cat 366	3784	2018-04-01	6925
378	100378	product 378	cat 367	2777	2017-12-13	87056
379	100379	product 379	cat 368	4346	2017-11-24	70741
380	100380	product 380	cat 369	3970	2017-11-15	84623
381	100381	product 381	cat 370	1103	2018-06-17	50272
382	100382	product 382	cat 371	2697	2018-03-21	17008
383	100383	product 383	cat 372	2616	2018-12-11	82331
384	100384	product 384	cat 373	2038	2018-11-07	25070
385	100385	product 385	cat 374	310	2018-12-06	59101
386	100386	product 386	cat 375	1165	2018-03-03	62355
387	100387	product 387	cat 376	4310	2017-06-21	87742
388	100388	product 388	cat 377	2966	2017-05-02	44016
389	100389	product 389	cat 378	3323	2017-12-31	58410
390	100390	product 390	cat 379	1282	2017-08-25	20083
391	100391	product 391	cat 380	4678	2017-06-08	67069
392	100392	product 392	cat 381	4784	2018-09-15	3909
393	100393	product 393	cat 382	3222	2018-12-25	29891
394	100394	product 394	cat 383	2792	2017-11-06	55454
395	100395	product 395	cat 384	4195	2018-06-15	80033
396	100396	product 396	cat 385	4867	2018-11-28	49899
397	100397	product 397	cat 386	1881	2018-07-03	7451
398	100398	product 398	cat 387	3139	2018-08-06	53748
399	100399	product 399	cat 388	4052	2018-07-19	70029
400	100400	product 400	cat 389	1397	2018-10-24	59590
401	100401	product 401	cat 390	2178	2018-05-31	77866
402	100402	product 402	cat 391	2196	2017-07-10	54798
403	100403	product 403	cat 392	681	2017-08-24	82275
404	100404	product 404	cat 393	2546	2017-08-09	33257
405	100405	product 405	cat 394	1066	2017-11-17	17849
406	100406	product 406	cat 395	4832	2018-08-30	80942
407	100407	product 407	cat 396	4512	2018-03-03	74825
408	100408	product 408	cat 397	2801	2018-03-03	4046
409	100409	product 409	cat 398	2507	2017-12-22	2913
410	100410	product 410	cat 399	4834	2018-08-16	2443
411	100411	product 411	cat 400	913	2018-12-11	17573
412	100412	product 412	cat 401	1148	2017-02-14	41132
413	100413	product 413	cat 402	3565	2017-01-20	4936
414	100414	product 414	cat 403	680	2018-06-07	47451
415	100415	product 415	cat 404	1511	2017-07-25	72742
416	100416	product 416	cat 405	4520	2017-05-12	26133
417	100417	product 417	cat 406	1315	2017-05-17	89448
418	100418	product 418	cat 407	1532	2018-03-10	19883
419	100419	product 419	cat 408	3376	2017-02-23	81925
420	100420	product 420	cat 409	2551	2017-08-16	43635
421	100421	product 421	cat 410	4066	2017-08-21	15962
422	100422	product 422	cat 411	1035	2018-10-03	66619
423	100423	product 423	cat 412	3965	2018-05-14	66634
424	100424	product 424	cat 413	2098	2018-08-23	68598
425	100425	product 425	cat 414	3897	2018-03-28	27085
426	100426	product 426	cat 415	3844	2018-04-23	80613
427	100427	product 427	cat 416	3598	2017-08-28	47028
428	100428	product 428	cat 417	4021	2018-12-30	35434
429	100429	product 429	cat 418	2485	2018-06-24	37675
430	100430	product 430	cat 419	3728	2017-12-01	83573
431	100431	product 431	cat 420	2746	2017-04-03	19509
432	100432	product 432	cat 421	3680	2017-07-23	77697
433	100433	product 433	cat 422	133	2017-11-29	81447
434	100434	product 434	cat 423	2198	2017-06-13	76650
435	100435	product 435	cat 424	3434	2017-02-06	43327
436	100436	product 436	cat 425	3420	2017-09-10	2375
437	100437	product 437	cat 426	4314	2018-12-28	75727
438	100438	product 438	cat 427	1477	2018-11-07	86060
439	100439	product 439	cat 428	2629	2017-11-23	68402
440	100440	product 440	cat 429	3418	2018-05-02	6840
441	100441	product 441	cat 430	3387	2017-08-08	81070
442	100442	product 442	cat 431	4084	2017-08-15	3642
443	100443	product 443	cat 432	4394	2017-11-04	10056
444	100444	product 444	cat 433	733	2018-10-27	80855
445	100445	product 445	cat 434	303	2017-07-29	40971
446	100446	product 446	cat 435	1095	2017-01-31	54456
447	100447	product 447	cat 436	1603	2017-04-07	43397
448	100448	product 448	cat 437	1348	2018-04-20	22254
449	100449	product 449	cat 438	3505	2017-03-17	64454
450	100450	product 450	cat 439	706	2018-10-05	34062
451	100451	product 451	cat 440	869	2017-09-25	26556
452	100452	product 452	cat 441	325	2017-12-09	86340
453	100453	product 453	cat 442	2662	2018-08-05	77337
454	100454	product 454	cat 443	2923	2018-04-30	24061
455	100455	product 455	cat 444	3104	2018-07-26	86984
456	100456	product 456	cat 445	3121	2017-02-10	79061
457	100457	product 457	cat 446	2160	2017-06-15	61847
458	100458	product 458	cat 447	4244	2017-10-22	48175
459	100459	product 459	cat 448	129	2018-04-03	4363
460	100460	product 460	cat 449	4583	2017-09-13	11694
461	100461	product 461	cat 450	1438	2017-10-05	52068
462	100462	product 462	cat 451	4333	2017-06-21	81659
463	100463	product 463	cat 452	3058	2017-12-19	33523
464	100464	product 464	cat 453	4192	2017-12-11	81403
465	100465	product 465	cat 454	1393	2017-08-07	89234
466	100466	product 466	cat 455	706	2018-11-03	30380
467	100467	product 467	cat 456	532	2018-01-02	68232
468	100468	product 468	cat 457	487	2018-12-03	15391
469	100469	product 469	cat 458	1432	2018-02-03	88440
470	100470	product 470	cat 459	3020	2018-04-16	51097
471	100471	product 471	cat 460	3225	2018-03-20	73157
472	100472	product 472	cat 461	3503	2017-09-18	62730
473	100473	product 473	cat 462	2585	2018-12-20	42861
474	100474	product 474	cat 463	4824	2017-09-13	57686
475	100475	product 475	cat 464	263	2017-05-30	62906
476	100476	product 476	cat 465	1765	2018-04-08	53378
477	100477	product 477	cat 466	4190	2017-11-10	25194
478	100478	product 478	cat 467	3537	2017-12-07	44895
479	100479	product 479	cat 468	3954	2017-06-06	2316
480	100480	product 480	cat 469	1750	2017-09-27	281
481	100481	product 481	cat 470	3836	2018-02-22	5973
482	100482	product 482	cat 471	3454	2017-09-06	22297
483	100483	product 483	cat 472	4479	2018-10-21	48809
484	100484	product 484	cat 473	1661	2018-04-19	17326
485	100485	product 485	cat 474	1518	2017-11-29	19977
486	100486	product 486	cat 475	1251	2017-03-07	44008
487	100487	product 487	cat 476	2346	2018-05-09	12662
488	100488	product 488	cat 477	1166	2018-04-30	62067
489	100489	product 489	cat 478	1800	2017-11-07	47483
490	100490	product 490	cat 479	1421	2018-03-08	10627
491	100491	product 491	cat 480	375	2017-05-25	24028
492	100492	product 492	cat 481	2028	2018-07-11	41659
493	100493	product 493	cat 482	809	2018-12-27	5711
494	100494	product 494	cat 483	390	2018-04-27	63100
495	100495	product 495	cat 484	3670	2018-07-20	64585
496	100496	product 496	cat 485	4695	2018-08-17	70035
497	100497	product 497	cat 486	1222	2017-08-24	51083
498	100498	product 498	cat 487	1942	2018-04-29	11419
499	100499	product 499	cat 488	3032	2018-10-31	77110
500	100500	product 500	cat 489	3417	2017-01-25	50505
501	100501	product 501	cat 490	4006	2017-05-26	45245
502	100502	product 502	cat 491	439	2018-05-27	75941
503	100503	product 503	cat 492	3122	2017-01-01	11408
504	100504	product 504	cat 493	1666	2018-03-07	61134
505	100505	product 505	cat 494	1212	2018-07-20	31810
506	100506	product 506	cat 495	1474	2018-10-15	30646
507	100507	product 507	cat 496	4159	2017-10-24	6446
508	100508	product 508	cat 497	4739	2017-01-24	4569
509	100509	product 509	cat 498	2836	2017-09-08	17098
510	100510	product 510	cat 499	4030	2018-08-15	35209
511	100511	product 511	cat 500	1330	2018-08-30	87707
512	100512	product 512	cat 501	3426	2017-11-26	49295
513	100513	product 513	cat 502	3033	2017-09-29	1109
514	100514	product 514	cat 503	4971	2018-08-15	41796
515	100515	product 515	cat 504	4384	2017-06-03	69044
516	100516	product 516	cat 505	932	2018-03-18	75406
517	100517	product 517	cat 506	1048	2017-05-12	44455
518	100518	product 518	cat 507	2848	2017-04-10	12756
519	100519	product 519	cat 508	211	2017-10-17	54853
520	100520	product 520	cat 509	2920	2018-06-08	59379
521	100521	product 521	cat 510	2601	2018-03-27	37270
522	100522	product 522	cat 511	241	2017-10-14	14424
523	100523	product 523	cat 512	830	2018-04-21	53735
524	100524	product 524	cat 513	3927	2018-12-02	11582
525	100525	product 525	cat 514	1263	2017-04-13	84271
526	100526	product 526	cat 515	3595	2018-07-31	8420
527	100527	product 527	cat 516	4204	2018-07-21	89477
528	100528	product 528	cat 517	1626	2018-12-13	51831
529	100529	product 529	cat 518	451	2017-04-07	29393
530	100530	product 530	cat 519	503	2017-06-09	32517
531	100531	product 531	cat 520	2822	2017-11-15	87518
532	100532	product 532	cat 521	4052	2018-02-17	44532
533	100533	product 533	cat 522	487	2018-03-01	79758
534	100534	product 534	cat 523	4911	2017-09-24	17756
535	100535	product 535	cat 524	956	2018-05-09	54882
536	100536	product 536	cat 525	3633	2017-10-24	36714
537	100537	product 537	cat 526	4140	2018-04-04	69731
538	100538	product 538	cat 527	1808	2017-03-27	35373
539	100539	product 539	cat 528	2779	2018-10-11	35559
540	100540	product 540	cat 529	3721	2017-09-03	9654
541	100541	product 541	cat 530	980	2017-06-24	47652
542	100542	product 542	cat 531	3821	2017-02-23	80594
543	100543	product 543	cat 532	1412	2017-04-29	78522
544	100544	product 544	cat 533	2725	2018-04-02	63914
545	100545	product 545	cat 534	4826	2017-02-20	9144
546	100546	product 546	cat 535	3070	2017-07-13	75324
547	100547	product 547	cat 536	3371	2018-09-25	19300
548	100548	product 548	cat 537	1319	2017-06-19	2492
549	100549	product 549	cat 538	393	2017-04-15	18674
550	100550	product 550	cat 539	2357	2018-07-26	20015
551	100551	product 551	cat 540	3375	2018-11-06	54943
552	100552	product 552	cat 541	190	2017-09-02	85561
553	100553	product 553	cat 542	4757	2017-06-28	76641
554	100554	product 554	cat 543	990	2017-02-24	70300
555	100555	product 555	cat 544	4495	2017-02-27	47099
556	100556	product 556	cat 545	2291	2018-06-02	29221
557	100557	product 557	cat 546	1302	2017-07-05	59092
558	100558	product 558	cat 547	1981	2018-07-21	45611
559	100559	product 559	cat 548	1250	2018-12-27	78380
560	100560	product 560	cat 549	2457	2017-06-15	31113
561	100561	product 561	cat 550	303	2017-03-31	3779
562	100562	product 562	cat 551	1632	2017-02-16	85585
563	100563	product 563	cat 552	2308	2017-05-17	55145
564	100564	product 564	cat 553	4875	2018-01-16	53936
565	100565	product 565	cat 554	4103	2018-06-30	60709
566	100566	product 566	cat 555	3681	2018-06-25	53545
567	100567	product 567	cat 556	956	2017-06-18	78230
568	100568	product 568	cat 557	3097	2018-10-25	53359
569	100569	product 569	cat 558	2307	2017-08-17	43692
570	100570	product 570	cat 559	732	2018-09-28	49758
571	100571	product 571	cat 560	4546	2017-11-19	73573
572	100572	product 572	cat 561	3260	2017-01-08	86059
573	100573	product 573	cat 562	1362	2017-05-09	1093
574	100574	product 574	cat 563	4706	2017-05-09	40723
575	100575	product 575	cat 564	4746	2018-07-11	22465
576	100576	product 576	cat 565	1002	2018-04-03	5601
577	100577	product 577	cat 566	4894	2018-07-18	40763
578	100578	product 578	cat 567	3843	2018-04-18	86077
579	100579	product 579	cat 568	3912	2018-03-14	26644
580	100580	product 580	cat 569	4316	2018-03-07	87548
581	100581	product 581	cat 570	4516	2018-03-31	31587
582	100582	product 582	cat 571	1258	2018-07-21	78058
583	100583	product 583	cat 572	2165	2017-03-19	11415
584	100584	product 584	cat 573	2139	2017-04-28	74599
585	100585	product 585	cat 574	1911	2017-03-12	24913
586	100586	product 586	cat 575	4334	2018-04-02	88710
587	100587	product 587	cat 576	4555	2018-05-04	66521
588	100588	product 588	cat 577	160	2018-09-20	81543
589	100589	product 589	cat 578	4030	2018-04-04	76919
590	100590	product 590	cat 579	4489	2018-07-14	84586
591	100591	product 591	cat 580	1687	2018-07-05	10429
592	100592	product 592	cat 581	2766	2018-01-26	796
593	100593	product 593	cat 582	853	2017-07-18	47969
594	100594	product 594	cat 583	4250	2017-01-09	44042
595	100595	product 595	cat 584	3568	2018-05-20	2552
596	100596	product 596	cat 585	4588	2017-11-09	88614
597	100597	product 597	cat 586	3562	2017-12-04	12171
598	100598	product 598	cat 587	977	2017-02-07	31040
599	100599	product 599	cat 588	106	2017-12-22	21304
600	100600	product 600	cat 589	1877	2017-11-28	87005
601	100601	product 601	cat 590	4586	2017-08-17	47332
602	100602	product 602	cat 591	2365	2018-04-17	48989
603	100603	product 603	cat 592	2676	2017-05-21	36549
604	100604	product 604	cat 593	1802	2018-11-17	6397
605	100605	product 605	cat 594	2332	2017-12-11	7382
606	100606	product 606	cat 595	1370	2017-02-04	28286
607	100607	product 607	cat 596	2481	2018-02-02	41450
608	100608	product 608	cat 597	932	2017-02-13	16735
609	100609	product 609	cat 598	4539	2018-11-05	46819
610	100610	product 610	cat 599	3043	2018-10-21	53979
611	100611	product 611	cat 600	4865	2018-04-13	45099
612	100612	product 612	cat 601	1054	2017-03-17	52315
613	100613	product 613	cat 602	4763	2017-11-03	14424
614	100614	product 614	cat 603	1385	2018-06-04	73374
615	100615	product 615	cat 604	1214	2018-11-20	81805
616	100616	product 616	cat 605	2000	2017-07-16	6024
617	100617	product 617	cat 606	505	2017-07-09	60421
618	100618	product 618	cat 607	757	2018-06-22	65431
619	100619	product 619	cat 608	3044	2018-01-14	34011
620	100620	product 620	cat 609	1601	2018-06-30	27513
621	100621	product 621	cat 610	4816	2017-10-09	46622
622	100622	product 622	cat 611	1328	2018-09-07	68125
623	100623	product 623	cat 612	3767	2017-01-11	75115
624	100624	product 624	cat 613	1288	2017-12-24	77924
625	100625	product 625	cat 614	129	2017-12-03	16942
626	100626	product 626	cat 615	2220	2017-01-21	52621
627	100627	product 627	cat 616	3495	2017-06-29	7712
628	100628	product 628	cat 617	3966	2018-05-14	6709
629	100629	product 629	cat 618	3426	2017-09-13	84984
630	100630	product 630	cat 619	3112	2018-03-10	88151
631	100631	product 631	cat 620	1149	2017-04-21	5390
632	100632	product 632	cat 621	2260	2017-11-18	15871
633	100633	product 633	cat 622	1224	2017-08-27	70239
634	100634	product 634	cat 623	2758	2018-06-25	86273
635	100635	product 635	cat 624	4969	2017-05-22	4925
636	100636	product 636	cat 625	4214	2017-06-01	20168
637	100637	product 637	cat 626	269	2018-09-07	65878
638	100638	product 638	cat 627	784	2018-11-28	31965
639	100639	product 639	cat 628	998	2018-07-02	6327
640	100640	product 640	cat 629	3200	2017-05-18	74207
641	100641	product 641	cat 630	4305	2018-06-16	5712
642	100642	product 642	cat 631	3131	2018-05-23	35120
643	100643	product 643	cat 632	4969	2018-03-04	52604
644	100644	product 644	cat 633	4411	2017-05-24	5623
645	100645	product 645	cat 634	620	2018-03-01	26034
646	100646	product 646	cat 635	4037	2018-05-27	61011
647	100647	product 647	cat 636	3239	2017-03-16	2344
648	100648	product 648	cat 637	4928	2017-01-08	58453
649	100649	product 649	cat 638	1520	2018-06-12	32603
650	100650	product 650	cat 639	1188	2017-07-29	33948
651	100651	product 651	cat 640	3988	2017-10-24	88589
652	100652	product 652	cat 641	1264	2018-06-29	64042
653	100653	product 653	cat 642	4714	2018-01-04	85665
654	100654	product 654	cat 643	444	2018-10-27	66174
655	100655	product 655	cat 644	3725	2018-11-28	21179
656	100656	product 656	cat 645	287	2017-12-13	22683
657	100657	product 657	cat 646	3917	2017-02-12	59271
658	100658	product 658	cat 647	4146	2017-07-30	38801
659	100659	product 659	cat 648	850	2017-04-07	76841
660	100660	product 660	cat 649	1719	2017-05-29	29737
661	100661	product 661	cat 650	2059	2017-09-06	22098
662	100662	product 662	cat 651	1797	2017-12-12	49900
663	100663	product 663	cat 652	119	2018-05-11	59246
664	100664	product 664	cat 653	960	2017-08-08	61083
665	100665	product 665	cat 654	4805	2017-09-04	28351
666	100666	product 666	cat 655	4702	2017-04-15	18457
667	100667	product 667	cat 656	319	2017-09-20	68266
668	100668	product 668	cat 657	2709	2017-05-06	19575
669	100669	product 669	cat 658	3247	2018-01-31	59859
670	100670	product 670	cat 659	4717	2017-12-12	37947
671	100671	product 671	cat 660	1927	2018-08-16	89834
672	100672	product 672	cat 661	4483	2017-11-12	18313
673	100673	product 673	cat 662	3082	2018-09-01	68778
674	100674	product 674	cat 663	1768	2018-06-18	31744
675	100675	product 675	cat 664	4852	2017-12-27	48770
676	100676	product 676	cat 665	4038	2017-08-03	53560
677	100677	product 677	cat 666	4846	2017-05-11	45112
678	100678	product 678	cat 667	184	2017-04-28	16626
679	100679	product 679	cat 668	1157	2017-05-28	57767
680	100680	product 680	cat 669	3364	2017-03-17	20475
681	100681	product 681	cat 670	1149	2018-01-31	72734
682	100682	product 682	cat 671	4228	2017-03-31	35522
683	100683	product 683	cat 672	3886	2017-04-09	64848
684	100684	product 684	cat 673	1126	2018-02-23	29325
685	100685	product 685	cat 674	379	2017-04-18	73466
686	100686	product 686	cat 675	3772	2018-10-15	67902
687	100687	product 687	cat 676	3529	2018-12-24	40396
688	100688	product 688	cat 677	4765	2017-01-29	64170
689	100689	product 689	cat 678	1914	2018-04-30	35797
690	100690	product 690	cat 679	2367	2017-09-25	55419
691	100691	product 691	cat 680	2111	2017-08-14	46635
692	100692	product 692	cat 681	4155	2018-07-15	82627
693	100693	product 693	cat 682	1387	2017-10-03	15224
694	100694	product 694	cat 683	4126	2017-12-31	6455
695	100695	product 695	cat 684	1308	2017-11-03	41393
696	100696	product 696	cat 685	2910	2018-04-26	77632
697	100697	product 697	cat 686	2631	2018-11-17	56031
698	100698	product 698	cat 687	3391	2017-10-02	30549
699	100699	product 699	cat 688	248	2018-04-29	1394
700	100700	product 700	cat 689	123	2018-03-27	84421
701	100701	product 701	cat 690	2610	2017-04-11	32761
702	100702	product 702	cat 691	1384	2018-11-23	13744
703	100703	product 703	cat 692	1394	2018-04-03	72608
704	100704	product 704	cat 693	680	2018-06-15	87512
705	100705	product 705	cat 694	4269	2017-07-14	40593
706	100706	product 706	cat 695	1849	2018-03-28	48515
707	100707	product 707	cat 696	1413	2018-12-17	18919
708	100708	product 708	cat 697	1507	2017-02-19	76785
709	100709	product 709	cat 698	4978	2018-12-18	13975
710	100710	product 710	cat 699	4749	2017-10-29	86970
711	100711	product 711	cat 700	3910	2017-09-25	2320
712	100712	product 712	cat 701	2956	2017-12-29	72006
713	100713	product 713	cat 702	2474	2017-11-09	66808
714	100714	product 714	cat 703	2621	2018-02-24	58830
715	100715	product 715	cat 704	1524	2018-12-09	44404
716	100716	product 716	cat 705	4870	2018-05-11	38934
717	100717	product 717	cat 706	2738	2017-04-26	35118
718	100718	product 718	cat 707	3544	2018-11-19	83786
719	100719	product 719	cat 708	959	2018-04-09	1894
720	100720	product 720	cat 709	1605	2018-02-07	83440
721	100721	product 721	cat 710	4200	2018-05-06	980
722	100722	product 722	cat 711	3193	2017-09-20	21845
723	100723	product 723	cat 712	392	2017-08-13	48800
724	100724	product 724	cat 713	4165	2018-09-04	88889
725	100725	product 725	cat 714	3568	2017-10-14	24434
726	100726	product 726	cat 715	2540	2017-01-31	66972
727	100727	product 727	cat 716	2358	2018-08-10	6179
728	100728	product 728	cat 717	2084	2017-10-15	47070
729	100729	product 729	cat 718	2379	2018-06-10	22932
730	100730	product 730	cat 719	639	2018-01-14	7150
731	100731	product 731	cat 720	3934	2017-07-16	62710
732	100732	product 732	cat 721	1359	2018-07-17	21936
733	100733	product 733	cat 722	4652	2019-01-01	51762
734	100734	product 734	cat 723	1297	2018-05-19	17545
735	100735	product 735	cat 724	3724	2018-01-18	82212
736	100736	product 736	cat 725	936	2018-04-30	87218
737	100737	product 737	cat 726	1360	2017-07-18	45331
738	100738	product 738	cat 727	3175	2017-03-07	45237
739	100739	product 739	cat 728	693	2018-01-28	74142
740	100740	product 740	cat 729	2988	2017-10-13	31036
741	100741	product 741	cat 730	520	2017-03-10	20478
742	100742	product 742	cat 731	4983	2018-05-23	48708
743	100743	product 743	cat 732	519	2017-06-10	21868
744	100744	product 744	cat 733	3958	2017-01-15	5764
745	100745	product 745	cat 734	1126	2017-12-27	7762
746	100746	product 746	cat 735	1159	2018-07-05	26563
747	100747	product 747	cat 736	3442	2018-04-25	36289
748	100748	product 748	cat 737	3865	2017-03-26	7140
749	100749	product 749	cat 738	1549	2017-06-07	83618
750	100750	product 750	cat 739	2110	2018-07-12	14050
751	100751	product 751	cat 740	1886	2017-04-10	68539
752	100752	product 752	cat 741	4805	2018-10-26	85760
753	100753	product 753	cat 742	155	2018-12-19	60648
754	100754	product 754	cat 743	3017	2017-09-08	165
755	100755	product 755	cat 744	228	2017-03-04	29925
756	100756	product 756	cat 745	2207	2018-11-12	5464
757	100757	product 757	cat 746	4884	2017-04-20	55325
758	100758	product 758	cat 747	903	2017-06-02	72193
759	100759	product 759	cat 748	2165	2017-03-24	84456
760	100760	product 760	cat 749	3480	2018-12-09	43647
761	100761	product 761	cat 750	3040	2018-12-09	59322
762	100762	product 762	cat 751	720	2018-12-14	48035
763	100763	product 763	cat 752	814	2018-10-26	68616
764	100764	product 764	cat 753	1274	2017-09-17	22536
765	100765	product 765	cat 754	2155	2017-04-29	9068
766	100766	product 766	cat 755	4478	2018-09-22	25965
767	100767	product 767	cat 756	3285	2018-10-04	4192
768	100768	product 768	cat 757	1902	2017-08-22	23237
769	100769	product 769	cat 758	239	2017-09-01	16847
770	100770	product 770	cat 759	2197	2017-06-16	87088
771	100771	product 771	cat 760	1411	2018-04-15	46978
772	100772	product 772	cat 761	767	2017-08-04	52038
773	100773	product 773	cat 762	2737	2018-09-06	31533
774	100774	product 774	cat 763	3284	2017-11-14	87423
775	100775	product 775	cat 764	1316	2017-02-27	1048
776	100776	product 776	cat 765	4414	2017-01-03	34781
777	100777	product 777	cat 766	985	2018-08-04	75375
778	100778	product 778	cat 767	1449	2018-07-14	75587
779	100779	product 779	cat 768	697	2018-03-21	39051
780	100780	product 780	cat 769	2890	2018-03-21	31275
781	100781	product 781	cat 770	4070	2018-06-06	65470
782	100782	product 782	cat 771	4226	2017-11-07	40616
783	100783	product 783	cat 772	4289	2018-06-30	1672
784	100784	product 784	cat 773	3831	2017-09-19	69272
785	100785	product 785	cat 774	1871	2018-08-11	79048
786	100786	product 786	cat 775	1555	2017-10-25	35197
787	100787	product 787	cat 776	3178	2017-09-17	8604
788	100788	product 788	cat 777	1930	2018-04-14	82384
789	100789	product 789	cat 778	4998	2017-11-04	83401
790	100790	product 790	cat 779	164	2018-10-13	34954
791	100791	product 791	cat 780	4687	2018-04-08	22583
792	100792	product 792	cat 781	1392	2018-01-29	80464
793	100793	product 793	cat 782	305	2017-11-07	16443
794	100794	product 794	cat 783	1809	2018-02-11	52595
795	100795	product 795	cat 784	2571	2017-04-05	16078
796	100796	product 796	cat 785	4293	2018-04-23	64914
797	100797	product 797	cat 786	2732	2017-02-21	71477
798	100798	product 798	cat 787	1521	2018-01-27	86257
799	100799	product 799	cat 788	639	2018-05-04	25635
800	100800	product 800	cat 789	3443	2018-09-15	36212
801	100801	product 801	cat 790	889	2018-12-12	50174
802	100802	product 802	cat 791	1879	2017-12-23	10535
803	100803	product 803	cat 792	3122	2018-04-22	3761
804	100804	product 804	cat 793	3043	2018-03-29	25852
805	100805	product 805	cat 794	3377	2017-11-16	50484
806	100806	product 806	cat 795	1392	2017-05-14	31703
807	100807	product 807	cat 796	447	2018-01-04	68133
808	100808	product 808	cat 797	1260	2018-09-07	7831
809	100809	product 809	cat 798	780	2017-10-27	56819
810	100810	product 810	cat 799	3089	2017-07-07	19548
811	100811	product 811	cat 800	2176	2018-03-26	83876
812	100812	product 812	cat 801	4206	2018-08-21	47979
813	100813	product 813	cat 802	3682	2017-05-17	73809
814	100814	product 814	cat 803	2558	2017-12-05	21099
815	100815	product 815	cat 804	1595	2017-07-08	42142
816	100816	product 816	cat 805	1653	2018-07-15	41008
817	100817	product 817	cat 806	230	2018-08-19	48364
818	100818	product 818	cat 807	1584	2017-04-18	69757
819	100819	product 819	cat 808	2140	2017-12-24	652
820	100820	product 820	cat 809	637	2018-04-23	89275
821	100821	product 821	cat 810	573	2018-01-05	60790
822	100822	product 822	cat 811	4668	2017-06-30	34274
823	100823	product 823	cat 812	4748	2018-01-07	52238
824	100824	product 824	cat 813	3643	2017-08-06	73100
825	100825	product 825	cat 814	4621	2017-11-16	44301
826	100826	product 826	cat 815	3674	2018-07-08	38184
827	100827	product 827	cat 816	1566	2018-03-17	57415
828	100828	product 828	cat 817	3692	2017-07-13	66639
829	100829	product 829	cat 818	3512	2017-04-09	41722
830	100830	product 830	cat 819	2911	2018-04-13	47104
831	100831	product 831	cat 820	3307	2018-03-08	28412
832	100832	product 832	cat 821	173	2017-08-15	22366
833	100833	product 833	cat 822	1991	2017-06-29	80352
834	100834	product 834	cat 823	1445	2017-02-10	9450
835	100835	product 835	cat 824	2369	2018-05-03	61405
836	100836	product 836	cat 825	2159	2017-12-21	75625
837	100837	product 837	cat 826	2918	2018-01-23	11642
838	100838	product 838	cat 827	2869	2018-03-20	21312
839	100839	product 839	cat 828	3742	2018-10-18	73871
840	100840	product 840	cat 829	3177	2018-08-04	41300
841	100841	product 841	cat 830	3365	2017-03-25	71084
842	100842	product 842	cat 831	3557	2018-09-14	87090
843	100843	product 843	cat 832	2897	2018-05-25	14553
844	100844	product 844	cat 833	4783	2017-08-11	80947
845	100845	product 845	cat 834	4722	2018-03-24	1036
846	100846	product 846	cat 835	2119	2017-01-02	86156
847	100847	product 847	cat 836	2309	2017-10-05	25378
848	100848	product 848	cat 837	445	2018-02-06	76199
849	100849	product 849	cat 838	2653	2018-12-09	9675
850	100850	product 850	cat 839	1003	2018-07-29	44844
851	100851	product 851	cat 840	2263	2017-05-22	8074
852	100852	product 852	cat 841	3534	2018-02-09	15868
853	100853	product 853	cat 842	4900	2018-03-14	70990
854	100854	product 854	cat 843	3234	2018-04-09	14984
855	100855	product 855	cat 844	2355	2017-12-05	53101
856	100856	product 856	cat 845	3084	2017-07-29	33537
857	100857	product 857	cat 846	5000	2018-12-07	3197
858	100858	product 858	cat 847	1960	2018-08-05	11326
859	100859	product 859	cat 848	1879	2018-09-23	67677
860	100860	product 860	cat 849	4958	2018-04-10	56262
861	100861	product 861	cat 850	808	2018-10-20	1909
862	100862	product 862	cat 851	3217	2018-02-22	23749
863	100863	product 863	cat 852	2368	2018-01-17	43801
864	100864	product 864	cat 853	4339	2017-05-12	36003
865	100865	product 865	cat 854	2941	2018-10-18	4983
866	100866	product 866	cat 855	2260	2017-09-30	46526
867	100867	product 867	cat 856	2165	2018-04-14	70843
868	100868	product 868	cat 857	1377	2017-01-06	80010
869	100869	product 869	cat 858	2675	2018-09-27	70655
870	100870	product 870	cat 859	697	2017-04-07	79903
871	100871	product 871	cat 860	3543	2018-02-07	70849
872	100872	product 872	cat 861	3264	2018-09-08	56028
873	100873	product 873	cat 862	484	2017-08-25	54590
874	100874	product 874	cat 863	1454	2018-08-11	84486
875	100875	product 875	cat 864	631	2017-04-25	89196
876	100876	product 876	cat 865	2095	2017-09-13	37411
877	100877	product 877	cat 866	1911	2018-11-18	72700
878	100878	product 878	cat 867	1115	2018-05-08	78493
879	100879	product 879	cat 868	921	2017-03-19	47975
880	100880	product 880	cat 869	1312	2018-12-30	28553
881	100881	product 881	cat 870	2774	2017-08-20	89847
882	100882	product 882	cat 871	1428	2018-01-26	15953
883	100883	product 883	cat 872	1453	2017-04-09	45142
884	100884	product 884	cat 873	1858	2017-12-04	88494
885	100885	product 885	cat 874	520	2017-06-15	46995
886	100886	product 886	cat 875	3113	2018-05-06	10213
887	100887	product 887	cat 876	4502	2018-10-24	51630
888	100888	product 888	cat 877	2050	2018-12-18	1498
889	100889	product 889	cat 878	3874	2018-02-15	22779
890	100890	product 890	cat 879	4225	2017-05-09	7320
891	100891	product 891	cat 880	4004	2018-03-02	62528
892	100892	product 892	cat 881	1636	2017-06-24	76036
893	100893	product 893	cat 882	1633	2018-09-14	2302
894	100894	product 894	cat 883	340	2018-12-04	13087
895	100895	product 895	cat 884	1067	2018-08-10	54077
896	100896	product 896	cat 885	2870	2018-03-13	66800
897	100897	product 897	cat 886	3304	2017-04-25	31771
898	100898	product 898	cat 887	1063	2017-07-31	79303
899	100899	product 899	cat 888	2281	2018-06-22	50977
900	100900	product 900	cat 889	2464	2017-12-04	82887
901	100901	product 901	cat 890	1945	2017-07-01	42609
902	100902	product 902	cat 891	2407	2018-04-27	18894
903	100903	product 903	cat 892	3035	2018-11-07	46684
904	100904	product 904	cat 893	2071	2018-10-27	9297
905	100905	product 905	cat 894	2025	2018-04-26	6940
906	100906	product 906	cat 895	3068	2017-12-07	84178
907	100907	product 907	cat 896	2370	2017-04-06	27325
908	100908	product 908	cat 897	1750	2018-09-05	2245
909	100909	product 909	cat 898	3682	2017-10-06	28399
910	100910	product 910	cat 899	639	2018-02-06	658
911	100911	product 911	cat 900	768	2018-11-24	32885
912	100912	product 912	cat 901	3791	2017-07-07	58470
913	100913	product 913	cat 902	4682	2017-09-14	40786
914	100914	product 914	cat 903	3462	2017-06-13	8719
915	100915	product 915	cat 904	2333	2018-05-30	20352
916	100916	product 916	cat 905	3968	2018-05-22	65474
917	100917	product 917	cat 906	3762	2018-03-26	79423
918	100918	product 918	cat 907	3196	2017-02-25	43697
919	100919	product 919	cat 908	851	2017-11-11	36113
920	100920	product 920	cat 909	2569	2017-01-16	47586
921	100921	product 921	cat 910	1125	2017-08-01	19049
922	100922	product 922	cat 911	791	2018-09-22	29668
923	100923	product 923	cat 912	829	2017-05-31	12395
924	100924	product 924	cat 913	2206	2018-05-25	34984
925	100925	product 925	cat 914	3705	2017-06-27	73437
926	100926	product 926	cat 915	763	2018-09-02	15323
927	100927	product 927	cat 916	930	2018-11-12	11916
928	100928	product 928	cat 917	3831	2018-02-13	79314
929	100929	product 929	cat 918	3496	2018-01-27	47774
930	100930	product 930	cat 919	3406	2017-01-16	42977
931	100931	product 931	cat 920	209	2017-07-11	65299
932	100932	product 932	cat 921	1310	2017-04-03	79904
933	100933	product 933	cat 922	3171	2018-03-19	7086
934	100934	product 934	cat 923	960	2017-04-12	73467
935	100935	product 935	cat 924	4830	2018-01-11	32942
936	100936	product 936	cat 925	4007	2018-04-14	76530
937	100937	product 937	cat 926	1479	2017-01-27	8417
938	100938	product 938	cat 927	4499	2018-08-28	36686
939	100939	product 939	cat 928	719	2018-03-16	72212
940	100940	product 940	cat 929	1539	2017-12-13	82307
941	100941	product 941	cat 930	2766	2018-03-28	4422
942	100942	product 942	cat 931	1054	2017-08-14	32513
943	100943	product 943	cat 932	2340	2018-09-17	54457
944	100944	product 944	cat 933	1984	2018-12-08	40246
945	100945	product 945	cat 934	1188	2018-03-15	70560
946	100946	product 946	cat 935	2517	2017-10-18	67713
947	100947	product 947	cat 936	4889	2018-12-07	17979
948	100948	product 948	cat 937	2907	2018-09-16	58922
949	100949	product 949	cat 938	1297	2018-07-25	46591
950	100950	product 950	cat 939	3466	2017-08-09	54646
951	100951	product 951	cat 940	1890	2018-09-01	12359
952	100952	product 952	cat 941	4965	2017-09-24	11979
953	100953	product 953	cat 942	3685	2018-09-18	72469
954	100954	product 954	cat 943	1437	2017-01-12	57590
955	100955	product 955	cat 944	3942	2017-06-26	19732
956	100956	product 956	cat 945	4362	2017-10-11	53563
957	100957	product 957	cat 946	230	2017-07-29	49679
958	100958	product 958	cat 947	2861	2017-03-16	59412
959	100959	product 959	cat 948	4561	2017-04-02	61723
960	100960	product 960	cat 949	4742	2017-11-21	75563
961	100961	product 961	cat 950	4112	2017-01-08	62527
962	100962	product 962	cat 951	361	2018-12-22	557
963	100963	product 963	cat 952	2241	2018-02-01	69669
964	100964	product 964	cat 953	4851	2018-04-13	60745
965	100965	product 965	cat 954	1075	2018-02-11	81788
966	100966	product 966	cat 955	2159	2017-06-16	75454
967	100967	product 967	cat 956	2954	2018-02-15	32855
968	100968	product 968	cat 957	969	2017-08-14	33850
969	100969	product 969	cat 958	4557	2017-08-04	48678
970	100970	product 970	cat 959	4370	2017-05-19	16724
971	100971	product 971	cat 960	3612	2018-08-22	12077
972	100972	product 972	cat 961	3991	2017-04-23	70916
973	100973	product 973	cat 962	738	2017-07-28	81317
974	100974	product 974	cat 963	562	2018-11-02	7818
975	100975	product 975	cat 964	441	2017-01-14	71424
976	100976	product 976	cat 965	2348	2017-11-01	25462
977	100977	product 977	cat 966	584	2017-08-16	85443
978	100978	product 978	cat 967	2452	2018-10-18	69449
979	100979	product 979	cat 968	1957	2017-07-29	60713
980	100980	product 980	cat 969	2488	2018-01-22	11198
981	100981	product 981	cat 970	4931	2018-01-29	56940
982	100982	product 982	cat 971	1629	2017-05-25	11140
983	100983	product 983	cat 972	999	2017-02-01	27796
984	100984	product 984	cat 973	1499	2018-03-12	65274
985	100985	product 985	cat 974	1633	2017-01-07	85226
986	100986	product 986	cat 975	2661	2018-04-25	11681
987	100987	product 987	cat 976	1359	2017-07-18	22890
988	100988	product 988	cat 977	1466	2017-12-26	33939
989	100989	product 989	cat 978	2249	2017-09-08	52622
990	100990	product 990	cat 979	4520	2017-10-11	51026
991	100991	product 991	cat 980	3756	2017-05-11	80777
992	100992	product 992	cat 981	2187	2018-09-11	81388
993	100993	product 993	cat 982	2207	2017-07-17	15870
994	100994	product 994	cat 983	3476	2017-05-14	43829
995	100995	product 995	cat 984	1086	2018-04-29	34350
996	100996	product 996	cat 985	1643	2017-05-21	43318
997	100997	product 997	cat 986	2279	2018-01-03	25698
998	100998	product 998	cat 987	2533	2018-01-27	70115
999	100999	product 999	cat 988	2568	2017-08-23	23054
1000	101000	product 1000	cat 989	1201	2018-10-18	6698
\.


--
-- Data for Name: sub; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.sub (id, count) FROM stdin;
1	20
2	21
3	22
\.


--
-- Data for Name: table1; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.table1 (id, var1, valid_from_dttm, valid_to_dttm) FROM stdin;
1	A	2018-09-01	2018-09-15
1	B	2018-09-16	5999-12-31
\.


--
-- Data for Name: table2; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.table2 (id, var2, valid_from_dttm, valid_to_dttm) FROM stdin;
1	A	2018-09-01	2018-09-18
1	B	2018-09-19	5999-12-31
\.


--
-- Data for Name: temp; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.temp (tmp) FROM stdin;
1
2
1
2
1
2
1
2
3
8
\.


--
-- Data for Name: temp1; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.temp1 (tmp1, tmp2, tmp3) FROM stdin;
1	2018-10-02	5
2	2018-01-31	5
53	2018-03-25	1
421	2018-11-27	1
388	2017-03-25	1
170	2017-11-04	1
348	2017-03-18	1
677	2018-11-19	1
423	2018-02-09	1
544	2018-09-29	1
286	2018-01-30	1
204	2018-01-03	1
487	2017-10-05	1
766	2017-07-16	1
868	2018-10-12	1
663	2018-04-22	1
455	2018-03-30	1
452	2017-08-19	1
454	2017-07-11	1
765	2018-09-16	1
80	2018-11-13	1
178	2017-11-07	1
383	2018-09-12	1
586	2018-11-29	1
530	2018-10-15	1
753	2017-09-04	1
394	2018-06-28	1
486	2018-03-16	1
90	2018-08-25	1
287	2018-08-11	1
744	2017-12-23	1
87	2017-09-03	1
930	2017-03-14	1
386	2017-12-14	1
83	2017-06-01	1
92	2018-04-17	1
878	2017-08-08	1
175	2017-02-09	1
21	2017-06-17	1
567	2017-11-14	1
311	2017-04-03	1
749	2018-11-25	1
18	2018-02-04	1
304	2018-08-28	1
202	2018-11-29	1
552	2017-05-08	1
750	2017-09-03	1
241	2017-10-19	1
982	2017-09-05	1
401	2017-02-17	1
212	2018-08-15	1
106	2017-04-07	1
892	2017-11-04	1
429	2017-01-14	1
299	2018-12-18	1
205	2018-03-28	1
641	2018-02-13	1
182	2017-02-17	1
413	2017-02-21	1
158	2018-04-27	1
843	2018-09-28	1
913	2018-04-02	1
965	2017-03-10	1
174	2018-04-13	1
276	2017-07-12	1
477	2017-09-05	1
121	2017-12-11	1
347	2017-03-01	1
332	2018-06-10	1
285	2017-02-04	1
439	2018-01-12	1
236	2017-07-27	1
888	2018-10-02	1
630	2017-11-02	1
852	2017-11-01	1
27	2018-04-25	1
651	2017-11-13	1
660	2017-08-08	1
669	2017-04-13	1
198	2017-11-25	1
327	2018-11-09	1
68	2018-08-24	1
759	2017-12-06	1
136	2018-09-29	1
119	2017-02-03	1
227	2017-11-30	1
805	2018-11-27	1
502	2018-05-02	1
294	2017-06-17	1
708	2018-04-15	1
220	2018-06-04	1
206	2018-02-24	1
417	2018-03-08	1
789	2017-01-23	1
435	2018-01-15	1
234	2018-10-03	1
918	2018-12-22	1
424	2018-12-01	1
358	2017-04-29	1
721	2018-01-30	1
297	2018-04-05	1
907	2017-09-01	1
901	2018-11-13	1
282	2017-11-10	1
31	2018-02-22	1
442	2017-01-13	1
130	2017-02-09	1
214	2018-10-31	1
485	2017-05-27	1
968	2017-06-01	1
689	2018-07-18	1
387	2018-05-12	1
838	2018-01-28	1
146	2017-12-13	1
626	2017-02-24	1
792	2018-07-19	1
195	2018-12-13	1
162	2018-12-10	1
400	2018-10-26	1
771	2018-03-03	1
323	2018-04-04	1
446	2018-01-09	1
862	2018-01-05	1
398	2017-10-08	1
24	2017-12-09	1
64	2018-10-19	1
886	2018-07-03	1
96	2018-03-29	1
867	2018-01-23	1
967	2017-09-22	1
325	2018-06-02	1
810	2018-01-26	1
563	2017-08-04	1
752	2017-08-23	1
705	2017-10-27	1
371	2018-02-27	1
624	2018-12-07	1
426	2018-01-28	1
331	2018-04-03	1
140	2017-12-24	1
235	2018-11-12	1
414	2018-05-16	1
561	2017-04-17	1
828	2018-11-09	1
636	2018-02-16	1
380	2018-09-24	1
881	2018-01-21	1
747	2018-07-13	1
733	2017-04-21	1
4	2018-07-22	1
475	2018-06-22	1
449	2017-06-21	1
207	2017-10-09	1
100	2017-09-19	1
403	2018-04-23	1
579	2018-11-08	1
713	2017-04-17	1
649	2017-09-19	1
127	2017-01-17	1
259	2017-04-20	1
576	2017-10-27	1
184	2018-05-06	1
66	2017-07-03	1
700	2017-04-05	1
164	2018-04-28	1
735	2018-03-12	1
314	2017-08-24	1
326	2017-03-20	1
825	2018-02-08	1
664	2018-10-20	1
633	2017-08-25	1
363	2017-11-22	1
823	2018-12-02	1
125	2018-12-31	1
604	2018-10-10	1
73	2017-07-28	1
885	2017-10-13	1
391	2018-07-11	1
560	2017-02-01	1
897	2018-07-03	1
491	2018-11-29	1
271	2017-06-13	1
309	2018-08-04	1
298	2017-06-20	1
939	2017-09-02	1
742	2018-06-21	1
730	2018-06-23	1
62	2018-07-23	4
49	2017-04-27	5
53	2018-03-25	1
421	2018-11-27	1
444	2018-11-21	2
388	2017-03-25	1
618	2017-07-14	2
855	2018-04-15	3
170	2017-11-04	1
156	2017-10-25	4
767	2018-01-25	3
704	2018-04-25	4
171	2018-03-27	5
166	2018-09-17	2
348	2017-03-18	1
995	2018-07-31	4
402	2017-09-17	3
498	2017-07-27	4
520	2018-08-20	3
320	2018-01-09	3
677	2018-11-19	1
620	2018-06-24	3
679	2017-12-19	2
423	2018-02-09	1
728	2017-02-19	4
131	2017-02-01	2
973	2017-03-19	5
544	2018-09-29	1
286	2018-01-30	1
848	2017-10-26	5
470	2018-01-16	5
204	2018-01-03	1
487	2017-10-05	1
98	2018-12-21	2
625	2017-10-01	2
766	2017-07-16	1
776	2018-07-25	4
849	2018-05-10	2
108	2018-06-02	2
540	2018-01-21	3
506	2018-10-29	4
187	2018-06-14	2
893	2018-11-04	5
670	2018-11-07	4
196	2017-06-03	5
589	2017-06-23	4
397	2017-02-19	3
450	2018-10-08	2
61	2017-06-15	2
992	2017-02-22	4
993	2018-05-24	3
994	2018-11-27	4
510	2018-10-13	2
784	2017-04-21	4
580	2017-06-24	3
917	2017-11-14	4
114	2018-03-22	3
868	2018-10-12	1
663	2018-04-22	1
806	2018-01-02	3
350	2017-11-14	3
882	2018-09-18	2
819	2018-07-13	5
7	2018-04-08	5
691	2017-02-18	2
455	2018-03-30	1
89	2017-11-30	5
167	2018-04-03	5
581	2018-02-09	2
722	2018-01-31	4
111	2017-12-15	5
452	2017-08-19	1
889	2017-12-26	5
469	2018-11-20	2
522	2017-08-28	5
454	2017-07-11	1
899	2017-09-07	2
690	2018-09-24	5
765	2018-09-16	1
768	2018-06-04	3
80	2018-11-13	1
896	2017-01-04	4
547	2018-11-08	5
303	2017-09-12	4
178	2017-11-07	1
52	2017-10-14	5
944	2018-12-19	5
39	2017-03-19	3
217	2018-02-21	5
657	2017-04-10	2
504	2018-05-20	4
489	2018-05-13	4
814	2018-06-18	2
519	2018-12-06	2
383	2018-09-12	1
976	2017-06-04	5
839	2017-02-06	2
224	2018-10-08	5
351	2018-03-27	5
51	2017-10-07	4
586	2018-11-29	1
188	2017-11-28	2
263	2018-06-28	2
186	2018-10-07	4
675	2018-01-09	5
989	2018-08-24	5
530	2018-10-15	1
1	2018-10-02	5
932	2017-11-18	2
590	2017-02-05	2
753	2017-09-04	1
6	2018-07-27	5
714	2017-06-23	5
928	2017-04-21	2
262	2018-11-12	5
279	2017-08-30	4
208	2018-02-07	2
933	2018-08-01	2
648	2017-02-19	4
150	2018-11-01	5
509	2017-11-08	5
394	2018-06-28	1
955	2017-03-09	5
486	2018-03-16	1
553	2018-02-15	2
250	2018-10-01	5
90	2018-08-25	1
25	2018-10-21	2
921	2017-06-30	5
533	2017-02-05	5
328	2018-07-13	5
720	2017-05-05	3
830	2018-03-31	3
829	2018-01-02	4
734	2018-04-01	4
43	2017-11-05	2
627	2018-06-02	2
305	2018-08-24	3
378	2018-03-07	2
183	2017-09-06	5
745	2018-08-26	3
934	2017-05-31	2
611	2018-03-17	4
915	2017-10-05	4
287	2018-08-11	1
744	2017-12-23	1
87	2017-09-03	1
638	2018-10-02	4
91	2018-01-26	5
571	2018-03-08	3
930	2017-03-14	1
324	2018-07-01	2
688	2017-09-21	4
671	2018-12-25	2
386	2017-12-14	1
548	2018-06-25	3
803	2017-07-14	3
826	2017-04-01	5
248	2017-11-08	3
812	2017-05-24	3
884	2017-09-08	2
600	2017-06-07	5
542	2018-08-24	2
83	2017-06-01	1
137	2017-06-19	2
570	2017-11-28	2
562	2017-10-13	2
448	2017-02-23	5
50	2017-07-03	2
610	2018-05-12	5
961	2017-09-28	3
308	2017-01-14	4
642	2017-08-17	3
511	2017-02-20	3
924	2018-05-03	3
919	2018-05-02	5
524	2018-12-17	2
92	2018-04-17	1
69	2018-12-22	5
472	2018-08-18	2
330	2017-11-03	5
878	2017-08-08	1
908	2017-12-30	5
640	2018-11-29	3
144	2017-03-18	3
787	2017-09-27	4
777	2018-03-15	2
877	2018-01-24	5
977	2017-11-13	3
912	2018-12-19	2
478	2017-03-11	5
603	2017-06-16	2
543	2017-04-20	3
175	2017-02-09	1
583	2017-01-07	3
516	2017-07-12	2
200	2018-04-22	3
986	2017-06-09	4
21	2017-06-17	1
459	2018-07-16	4
123	2018-05-21	4
567	2017-11-14	1
142	2018-10-04	5
725	2017-12-23	3
311	2017-04-03	1
431	2018-05-24	5
231	2018-05-25	5
428	2017-02-01	5
749	2018-11-25	1
18	2018-02-04	1
941	2018-06-01	5
479	2018-09-29	3
773	2018-03-01	2
783	2018-12-24	3
10	2018-05-08	3
304	2018-08-28	1
47	2017-01-01	3
813	2017-02-19	5
254	2018-10-04	5
837	2017-08-30	2
118	2017-08-04	3
152	2018-03-28	4
942	2018-03-21	5
202	2018-11-29	1
433	2018-05-13	2
552	2017-05-08	1
484	2018-04-25	3
750	2017-09-03	1
191	2018-10-10	4
93	2017-12-03	5
241	2017-10-19	1
740	2017-06-11	4
132	2017-03-29	4
982	2017-09-05	1
401	2017-02-17	1
974	2018-06-04	5
212	2018-08-15	1
40	2018-06-21	5
103	2018-04-08	5
370	2018-01-05	3
551	2018-07-05	2
275	2018-06-27	3
105	2017-04-12	4
274	2018-01-16	4
1000	2018-01-29	2
791	2017-07-11	4
238	2017-05-22	5
36	2017-06-15	5
629	2017-02-07	4
531	2017-07-08	3
972	2017-08-12	3
500	2018-01-09	4
864	2017-02-15	4
79	2017-03-27	5
597	2018-12-11	4
746	2018-10-05	4
845	2018-05-03	5
945	2018-08-28	4
106	2017-04-07	1
376	2017-02-06	3
476	2018-05-16	3
537	2018-04-06	5
979	2018-04-16	5
650	2017-12-29	5
194	2017-09-14	5
265	2018-09-25	4
74	2018-09-20	5
892	2017-11-04	1
233	2018-08-19	5
635	2017-01-25	4
535	2017-12-15	3
639	2018-09-30	2
804	2018-07-13	3
474	2017-10-20	4
429	2017-01-14	1
299	2018-12-18	1
863	2017-04-08	3
335	2017-10-06	3
205	2018-03-28	1
821	2017-03-14	4
366	2017-11-24	3
641	2018-02-13	1
340	2017-12-24	4
343	2017-07-04	5
702	2017-03-25	3
312	2017-06-06	3
182	2017-02-17	1
257	2017-04-10	4
413	2017-02-21	1
148	2017-01-26	3
318	2018-01-05	3
971	2018-11-03	2
158	2018-04-27	1
869	2017-07-25	4
843	2018-09-28	1
462	2018-09-17	4
197	2017-01-13	3
913	2018-04-02	1
965	2017-03-10	1
872	2018-06-24	5
764	2017-06-05	3
833	2017-10-06	4
471	2018-08-26	4
404	2017-10-11	2
174	2018-04-13	1
95	2017-08-15	2
141	2018-05-16	3
276	2017-07-12	1
477	2017-09-05	1
809	2018-06-28	5
20	2018-10-29	2
112	2018-02-12	3
879	2018-05-19	3
149	2018-11-10	2
121	2017-12-11	1
347	2017-03-01	1
55	2018-03-19	3
832	2017-07-06	5
473	2017-11-27	5
332	2018-06-10	1
160	2017-04-18	5
22	2017-12-12	5
859	2018-09-17	4
396	2017-09-25	5
558	2017-04-26	5
866	2017-07-15	5
712	2018-12-27	5
359	2018-10-13	5
333	2017-07-08	5
781	2018-04-01	4
29	2017-11-16	5
285	2017-02-04	1
739	2017-09-29	4
439	2018-01-12	1
236	2017-07-27	1
215	2017-07-03	5
505	2018-04-25	2
11	2017-02-10	3
794	2017-11-30	5
614	2018-05-05	5
3	2017-01-12	5
445	2018-12-08	3
801	2017-02-04	4
888	2018-10-02	1
779	2017-10-08	4
419	2017-11-05	2
407	2017-10-20	3
94	2017-07-02	3
412	2017-10-29	4
133	2017-11-09	5
82	2018-06-22	5
117	2017-09-09	3
538	2017-09-11	4
406	2018-02-07	2
587	2017-05-20	3
268	2017-12-31	3
946	2017-04-11	4
724	2017-08-22	3
556	2017-07-06	5
243	2017-02-02	4
307	2017-11-02	3
630	2017-11-02	1
628	2018-06-26	4
539	2017-07-05	5
258	2017-08-23	5
409	2018-01-07	3
852	2017-11-01	1
19	2017-11-07	3
797	2018-02-15	2
27	2018-04-25	1
988	2017-09-17	5
871	2017-12-21	3
808	2018-06-02	5
834	2018-04-16	4
651	2017-11-13	1
438	2017-05-06	3
660	2017-08-08	1
115	2018-01-26	4
762	2018-02-23	3
501	2017-09-25	2
669	2017-04-13	1
341	2017-04-04	5
405	2017-11-19	5
694	2018-08-23	3
873	2018-05-01	4
198	2017-11-25	1
329	2017-04-07	4
84	2018-05-05	3
354	2017-02-01	2
252	2017-06-22	5
453	2017-10-24	2
616	2017-05-22	4
488	2018-01-15	3
122	2018-05-10	5
327	2018-11-09	1
528	2018-09-09	2
717	2017-04-27	2
856	2017-05-12	4
416	2017-05-17	5
68	2018-08-24	1
929	2018-01-16	2
840	2018-11-13	5
85	2018-05-07	3
759	2017-12-06	1
155	2017-04-14	2
824	2018-07-17	2
909	2017-09-17	4
736	2017-09-08	3
754	2017-10-27	2
608	2018-02-05	2
786	2017-12-25	3
451	2017-06-26	5
644	2018-11-12	4
136	2018-09-29	1
119	2017-02-03	1
582	2018-03-13	3
619	2018-07-03	3
719	2017-03-11	4
937	2017-04-28	4
911	2017-02-01	3
850	2017-05-29	2
818	2018-02-22	5
788	2018-06-09	3
81	2017-12-24	2
529	2017-07-09	3
219	2018-03-06	2
774	2017-10-17	2
227	2017-11-30	1
943	2018-01-22	5
805	2018-11-27	1
954	2017-09-28	4
502	2018-05-02	1
226	2017-06-14	4
906	2018-04-26	5
13	2017-06-01	2
147	2018-10-09	2
707	2017-12-06	5
615	2017-06-26	3
294	2017-06-17	1
710	2018-03-15	4
189	2017-03-10	2
513	2018-07-17	2
983	2018-11-15	3
352	2018-09-24	5
870	2018-06-19	3
457	2017-06-14	4
555	2018-07-16	5
554	2018-09-21	2
67	2017-12-24	5
527	2017-02-21	5
895	2018-02-03	5
940	2017-07-22	2
656	2017-10-08	2
584	2018-11-21	4
708	2018-04-15	1
154	2018-11-21	2
799	2018-09-09	2
673	2017-12-06	3
637	2017-01-08	5
161	2018-02-04	3
159	2018-06-19	3
211	2018-12-02	2
220	2018-06-04	1
761	2017-04-10	4
696	2018-11-13	2
685	2017-06-20	3
292	2017-03-07	4
128	2017-06-02	5
842	2018-05-08	5
790	2017-04-04	4
732	2018-11-26	4
532	2017-03-02	5
601	2017-07-28	4
169	2018-01-30	2
591	2018-02-06	5
206	2018-02-24	1
569	2017-10-31	2
177	2017-03-04	4
278	2018-11-09	2
143	2017-01-02	5
817	2018-03-20	3
417	2018-03-08	1
242	2017-01-24	3
88	2018-07-08	3
559	2018-07-09	2
393	2018-04-17	2
362	2017-03-05	3
422	2018-07-16	3
260	2017-04-29	3
468	2017-02-14	5
789	2017-01-23	1
785	2018-09-25	5
435	2018-01-15	1
33	2017-08-01	5
578	2017-01-27	3
338	2018-01-07	5
936	2018-10-30	5
466	2017-01-27	5
234	2018-10-03	1
14	2017-06-18	2
15	2018-07-01	3
701	2017-12-12	5
568	2017-08-10	3
918	2018-12-22	1
541	2018-11-04	5
253	2017-09-30	5
424	2018-12-01	1
361	2018-06-08	2
358	2017-04-29	1
721	2018-01-30	1
266	2018-09-20	2
858	2017-01-31	3
634	2017-09-11	4
390	2018-07-28	4
741	2018-05-05	5
606	2017-10-24	2
297	2018-04-05	1
820	2018-06-30	4
865	2017-06-23	3
499	2018-02-05	3
302	2017-02-25	5
990	2018-01-09	4
731	2017-04-26	3
970	2018-12-04	4
693	2018-02-24	3
907	2017-09-01	1
901	2018-11-13	1
716	2018-06-18	4
577	2017-11-21	4
321	2018-04-15	4
26	2018-03-31	2
282	2017-11-10	1
256	2017-03-19	4
490	2017-10-06	3
60	2018-06-09	5
692	2018-01-27	5
31	2018-02-22	1
566	2018-06-27	2
165	2018-05-28	5
493	2017-06-28	3
138	2018-04-11	2
432	2018-09-24	4
465	2017-01-03	4
436	2017-03-05	5
655	2017-11-04	2
34	2017-12-26	2
134	2017-12-19	3
890	2018-03-05	2
176	2017-05-25	4
78	2017-10-04	4
534	2017-11-20	3
960	2018-08-01	4
210	2017-09-18	4
443	2018-01-11	5
349	2018-08-02	2
617	2017-05-30	2
682	2017-12-01	4
442	2017-01-13	1
375	2018-04-08	5
44	2017-06-17	4
399	2018-03-13	4
48	2018-05-03	5
130	2017-02-09	1
28	2017-03-06	2
827	2018-07-04	3
698	2017-01-20	5
336	2018-04-14	2
157	2018-12-07	2
368	2018-09-27	2
229	2017-09-30	3
300	2017-11-09	3
9	2017-02-19	3
997	2017-08-19	5
497	2018-09-24	4
775	2018-04-13	3
75	2018-06-30	5
935	2018-08-27	3
515	2018-08-06	5
514	2017-10-25	5
482	2017-03-29	4
291	2018-01-21	2
564	2017-01-11	4
214	2018-10-31	1
410	2018-02-15	4
392	2018-06-16	3
379	2018-10-29	5
975	2018-05-14	5
748	2018-04-13	3
203	2018-05-09	4
35	2017-02-23	2
104	2017-01-12	4
949	2017-07-08	5
894	2018-02-11	3
113	2018-08-26	2
999	2017-09-01	2
857	2017-08-28	2
364	2018-03-22	2
769	2018-06-23	2
485	2017-05-27	1
968	2017-06-01	1
602	2018-03-11	5
665	2017-01-28	5
16	2017-06-10	2
411	2017-10-24	3
430	2017-12-25	4
467	2018-12-02	3
689	2018-07-18	1
97	2017-07-11	2
387	2018-05-12	1
678	2017-09-17	4
356	2017-04-29	2
815	2018-02-01	4
963	2018-11-13	5
525	2017-08-21	2
458	2018-04-22	5
213	2017-07-10	4
838	2018-01-28	1
384	2017-01-22	2
146	2017-12-13	1
565	2017-06-15	5
508	2018-05-26	5
573	2017-12-08	2
585	2018-03-20	5
847	2018-12-15	4
546	2018-04-02	3
816	2018-12-14	5
346	2017-01-04	2
572	2018-10-30	5
667	2018-12-12	4
984	2018-02-10	5
980	2018-01-11	5
293	2017-06-08	4
854	2017-07-09	5
958	2018-04-04	3
626	2017-02-24	1
605	2017-04-19	3
209	2018-07-20	2
851	2018-01-23	3
12	2018-10-12	2
757	2018-09-13	5
172	2017-05-10	2
792	2018-07-19	1
686	2017-03-02	3
425	2018-12-29	4
795	2017-05-29	4
168	2018-02-07	5
947	2017-07-25	3
102	2018-02-13	2
914	2018-11-08	3
846	2018-01-31	3
237	2017-07-06	3
190	2017-06-27	2
195	2018-12-13	1
521	2018-06-30	2
58	2017-08-27	5
162	2018-12-10	1
593	2017-07-22	4
400	2018-10-26	1
223	2017-05-28	3
441	2018-02-11	5
622	2018-02-18	3
771	2018-03-03	1
37	2017-03-31	2
464	2018-10-26	5
317	2018-07-31	4
180	2018-01-05	2
632	2017-10-12	3
310	2018-04-25	2
45	2017-03-13	3
382	2017-10-15	2
517	2017-03-17	3
811	2017-06-13	2
991	2017-02-19	5
323	2018-04-04	1
891	2017-01-17	5
446	2018-01-09	1
760	2018-01-07	3
862	2018-01-05	1
998	2017-04-11	3
985	2018-09-07	2
621	2017-06-17	4
588	2017-01-30	5
715	2018-05-24	4
920	2017-11-11	3
623	2017-06-15	5
987	2017-04-12	3
738	2017-06-22	4
398	2017-10-08	1
703	2017-09-12	2
676	2017-07-26	4
647	2018-11-07	5
646	2017-07-30	2
179	2018-11-16	2
277	2017-09-24	2
264	2017-05-19	5
381	2018-09-19	2
116	2018-10-22	2
76	2017-09-08	4
24	2017-12-09	1
365	2017-05-20	3
185	2017-12-30	3
64	2018-10-19	1
886	2018-07-03	1
860	2017-01-04	2
652	2018-03-11	2
96	2018-03-29	1
853	2017-03-13	2
796	2017-07-29	2
953	2017-03-02	4
867	2018-01-23	1
221	2018-06-10	5
822	2017-10-07	2
355	2017-12-02	5
645	2017-12-21	5
232	2018-07-30	3
883	2018-09-01	5
306	2017-02-08	5
967	2017-09-22	1
951	2017-09-18	2
273	2018-07-23	2
887	2017-10-11	3
110	2018-05-24	2
523	2018-11-14	4
925	2017-07-31	3
377	2017-03-15	2
981	2018-11-29	3
549	2018-10-15	5
325	2018-06-02	1
810	2018-01-26	1
151	2017-07-01	3
563	2017-08-04	1
876	2018-10-14	5
280	2017-07-04	2
752	2017-08-23	1
272	2017-04-08	4
607	2017-11-07	3
372	2017-05-30	4
244	2018-01-25	2
267	2017-04-22	5
575	2018-06-27	2
550	2017-05-14	3
643	2018-08-15	5
705	2017-10-27	1
193	2017-11-17	4
956	2017-06-09	2
959	2017-03-03	3
54	2018-05-15	2
756	2017-03-23	5
962	2018-01-14	5
594	2018-08-15	3
780	2018-09-15	4
415	2018-10-21	4
447	2018-09-20	3
875	2018-06-25	3
723	2018-02-27	3
526	2017-09-02	5
371	2018-02-27	1
598	2017-06-15	3
503	2017-11-06	4
668	2017-01-05	3
978	2017-05-24	2
109	2017-02-27	5
758	2017-08-07	3
624	2018-12-07	1
687	2017-11-23	5
507	2017-09-22	3
283	2017-05-09	4
836	2018-09-30	5
711	2017-04-23	4
426	2018-01-28	1
440	2018-03-31	4
681	2017-11-07	2
706	2017-11-02	2
778	2018-07-31	2
331	2018-04-03	1
181	2017-02-11	2
230	2018-07-09	4
284	2017-07-22	3
228	2018-03-03	2
957	2018-10-17	5
770	2017-03-03	2
353	2018-05-08	5
437	2018-12-16	5
654	2018-09-17	5
140	2017-12-24	1
316	2018-02-09	4
290	2018-07-25	5
201	2018-03-16	4
666	2018-05-03	5
841	2018-01-22	3
235	2018-11-12	1
966	2018-12-07	2
483	2017-02-11	5
927	2017-08-20	4
41	2017-08-02	3
369	2017-06-24	2
153	2018-11-15	4
938	2018-03-04	4
727	2018-01-22	4
414	2018-05-16	1
561	2017-04-17	1
807	2018-01-22	3
828	2018-11-09	1
334	2018-06-24	5
255	2017-02-18	4
360	2018-09-12	3
595	2018-10-02	4
344	2017-10-22	3
145	2017-12-15	2
496	2018-04-25	5
42	2017-02-11	4
612	2017-10-11	3
743	2018-07-01	3
631	2018-01-30	3
737	2017-06-10	3
246	2017-12-10	2
636	2018-02-16	1
613	2018-02-06	3
844	2018-08-07	5
288	2018-03-08	5
697	2017-03-15	3
380	2018-09-24	1
881	2018-01-21	1
281	2018-06-28	5
874	2017-03-18	2
373	2018-07-04	4
923	2018-02-26	2
747	2018-07-13	1
800	2018-05-11	2
733	2017-04-21	1
367	2018-05-16	3
948	2017-03-31	4
772	2017-10-22	3
342	2018-02-28	3
4	2018-07-22	1
240	2017-12-18	4
950	2018-11-05	3
475	2018-06-22	1
135	2018-10-30	3
926	2018-06-21	2
216	2018-02-13	2
699	2017-01-26	3
782	2018-06-27	4
23	2017-08-28	5
57	2017-03-26	5
222	2017-03-19	3
674	2017-01-09	4
249	2018-02-27	2
659	2017-06-19	3
460	2017-10-08	3
269	2017-11-30	3
574	2018-05-05	2
129	2017-06-21	2
2	2018-01-31	5
449	2017-06-21	1
763	2018-11-27	4
207	2017-10-09	1
755	2018-10-31	2
916	2017-01-07	4
70	2018-11-06	4
315	2017-12-02	3
46	2017-11-10	4
729	2017-12-19	4
17	2018-02-05	3
900	2018-08-04	5
592	2018-11-04	3
247	2018-05-29	3
861	2017-02-02	5
99	2018-06-04	3
952	2018-02-26	2
922	2017-05-27	4
199	2018-07-22	4
163	2018-11-29	5
964	2018-08-18	4
910	2017-05-19	4
100	2017-09-19	1
239	2018-02-16	2
59	2017-09-26	2
596	2018-10-28	2
793	2017-02-19	4
898	2018-12-08	5
301	2017-06-23	2
403	2018-04-23	1
835	2017-05-06	4
385	2018-08-25	5
124	2017-02-17	2
86	2018-03-10	4
658	2017-09-29	2
557	2018-05-11	3
296	2017-07-18	5
579	2018-11-08	1
713	2017-04-17	1
649	2017-09-19	1
322	2017-08-31	4
418	2017-04-04	5
456	2017-08-04	2
389	2017-11-10	4
903	2018-11-09	2
261	2017-08-03	3
751	2018-10-17	4
127	2017-01-17	1
662	2017-10-08	5
661	2018-03-15	5
295	2017-04-03	2
56	2018-09-14	4
72	2018-10-23	3
461	2017-03-03	2
969	2018-12-05	4
480	2017-01-17	4
996	2018-11-12	4
259	2017-04-20	1
536	2018-12-09	2
576	2017-10-27	1
463	2017-09-25	3
313	2017-08-03	2
218	2018-10-05	3
718	2017-09-08	4
184	2018-05-06	1
653	2018-06-18	5
225	2018-10-24	4
251	2017-06-26	3
319	2017-03-06	2
66	2017-07-03	1
173	2017-10-25	2
289	2018-03-23	3
518	2018-01-05	5
8	2018-10-12	5
495	2018-07-17	3
339	2018-07-09	2
700	2017-04-05	1
107	2018-01-21	5
164	2018-04-28	1
798	2017-07-02	3
374	2018-08-25	3
77	2018-07-22	4
599	2018-09-05	4
512	2018-10-03	3
434	2017-03-24	2
735	2018-03-12	1
270	2017-12-01	2
345	2018-01-20	2
314	2017-08-24	1
65	2018-05-23	5
38	2018-03-23	3
120	2018-08-02	4
695	2018-05-17	5
32	2017-11-18	2
684	2017-06-20	3
63	2018-12-14	4
357	2018-05-18	3
337	2018-09-03	3
904	2018-11-22	4
326	2017-03-20	1
494	2017-08-18	2
492	2017-11-12	5
825	2018-02-08	1
664	2018-10-20	1
633	2017-08-25	1
363	2017-11-22	1
823	2018-12-02	1
931	2018-12-16	5
709	2018-07-23	5
609	2017-02-06	4
126	2017-07-30	2
125	2018-12-31	1
245	2018-03-30	4
71	2017-01-20	5
902	2018-10-08	2
680	2017-04-13	3
481	2017-09-30	2
604	2018-10-10	1
192	2018-09-29	4
683	2018-09-20	4
395	2018-09-11	4
73	2017-07-28	1
672	2017-07-18	4
885	2017-10-13	1
391	2018-07-11	1
726	2018-05-07	5
560	2017-02-01	1
897	2018-07-03	1
420	2017-10-23	5
491	2018-11-29	1
271	2017-06-13	1
309	2018-08-04	1
298	2017-06-20	1
408	2017-08-22	3
939	2017-09-02	1
831	2017-11-16	4
139	2018-04-21	2
742	2018-06-21	1
5	2017-01-17	3
880	2017-02-13	2
30	2017-08-02	2
905	2017-09-15	3
101	2017-05-12	5
730	2018-06-23	1
545	2017-01-22	5
802	2018-01-15	2
427	2017-12-09	3
53	2018-03-25	1
421	2018-11-27	1
388	2017-03-25	1
170	2017-11-04	1
348	2017-03-18	1
677	2018-11-19	1
423	2018-02-09	1
544	2018-09-29	1
286	2018-01-30	1
204	2018-01-03	1
487	2017-10-05	1
766	2017-07-16	1
868	2018-10-12	1
663	2018-04-22	1
455	2018-03-30	1
452	2017-08-19	1
454	2017-07-11	1
765	2018-09-16	1
80	2018-11-13	1
178	2017-11-07	1
383	2018-09-12	1
586	2018-11-29	1
530	2018-10-15	1
753	2017-09-04	1
394	2018-06-28	1
486	2018-03-16	1
90	2018-08-25	1
287	2018-08-11	1
744	2017-12-23	1
87	2017-09-03	1
930	2017-03-14	1
386	2017-12-14	1
83	2017-06-01	1
92	2018-04-17	1
878	2017-08-08	1
175	2017-02-09	1
21	2017-06-17	1
567	2017-11-14	1
311	2017-04-03	1
749	2018-11-25	1
18	2018-02-04	1
304	2018-08-28	1
202	2018-11-29	1
552	2017-05-08	1
750	2017-09-03	1
241	2017-10-19	1
982	2017-09-05	1
401	2017-02-17	1
212	2018-08-15	1
106	2017-04-07	1
892	2017-11-04	1
429	2017-01-14	1
299	2018-12-18	1
205	2018-03-28	1
641	2018-02-13	1
182	2017-02-17	1
413	2017-02-21	1
158	2018-04-27	1
843	2018-09-28	1
913	2018-04-02	1
965	2017-03-10	1
174	2018-04-13	1
276	2017-07-12	1
477	2017-09-05	1
121	2017-12-11	1
347	2017-03-01	1
332	2018-06-10	1
285	2017-02-04	1
439	2018-01-12	1
236	2017-07-27	1
888	2018-10-02	1
630	2017-11-02	1
852	2017-11-01	1
27	2018-04-25	1
651	2017-11-13	1
660	2017-08-08	1
669	2017-04-13	1
198	2017-11-25	1
327	2018-11-09	1
68	2018-08-24	1
759	2017-12-06	1
136	2018-09-29	1
119	2017-02-03	1
227	2017-11-30	1
805	2018-11-27	1
502	2018-05-02	1
294	2017-06-17	1
708	2018-04-15	1
220	2018-06-04	1
206	2018-02-24	1
417	2018-03-08	1
789	2017-01-23	1
435	2018-01-15	1
234	2018-10-03	1
918	2018-12-22	1
424	2018-12-01	1
358	2017-04-29	1
721	2018-01-30	1
297	2018-04-05	1
907	2017-09-01	1
901	2018-11-13	1
282	2017-11-10	1
31	2018-02-22	1
442	2017-01-13	1
130	2017-02-09	1
214	2018-10-31	1
485	2017-05-27	1
968	2017-06-01	1
689	2018-07-18	1
387	2018-05-12	1
838	2018-01-28	1
146	2017-12-13	1
626	2017-02-24	1
792	2018-07-19	1
195	2018-12-13	1
162	2018-12-10	1
400	2018-10-26	1
771	2018-03-03	1
323	2018-04-04	1
446	2018-01-09	1
862	2018-01-05	1
398	2017-10-08	1
24	2017-12-09	1
64	2018-10-19	1
886	2018-07-03	1
96	2018-03-29	1
867	2018-01-23	1
967	2017-09-22	1
325	2018-06-02	1
810	2018-01-26	1
563	2017-08-04	1
752	2017-08-23	1
705	2017-10-27	1
371	2018-02-27	1
624	2018-12-07	1
426	2018-01-28	1
331	2018-04-03	1
140	2017-12-24	1
235	2018-11-12	1
414	2018-05-16	1
561	2017-04-17	1
828	2018-11-09	1
636	2018-02-16	1
380	2018-09-24	1
881	2018-01-21	1
747	2018-07-13	1
733	2017-04-21	1
4	2018-07-22	1
475	2018-06-22	1
449	2017-06-21	1
207	2017-10-09	1
100	2017-09-19	1
403	2018-04-23	1
579	2018-11-08	1
713	2017-04-17	1
649	2017-09-19	1
127	2017-01-17	1
259	2017-04-20	1
576	2017-10-27	1
184	2018-05-06	1
66	2017-07-03	1
700	2017-04-05	1
164	2018-04-28	1
735	2018-03-12	1
314	2017-08-24	1
326	2017-03-20	1
825	2018-02-08	1
664	2018-10-20	1
633	2017-08-25	1
363	2017-11-22	1
823	2018-12-02	1
125	2018-12-31	1
604	2018-10-10	1
73	2017-07-28	1
885	2017-10-13	1
391	2018-07-11	1
560	2017-02-01	1
897	2018-07-03	1
491	2018-11-29	1
271	2017-06-13	1
309	2018-08-04	1
298	2017-06-20	1
939	2017-09-02	1
742	2018-06-21	1
730	2018-06-23	1
62	2018-07-23	4
49	2017-04-27	5
53	2018-03-25	1
421	2018-11-27	1
444	2018-11-21	2
388	2017-03-25	1
618	2017-07-14	2
855	2018-04-15	3
170	2017-11-04	1
156	2017-10-25	4
767	2018-01-25	3
704	2018-04-25	4
171	2018-03-27	5
166	2018-09-17	2
348	2017-03-18	1
995	2018-07-31	4
402	2017-09-17	3
498	2017-07-27	4
520	2018-08-20	3
320	2018-01-09	3
677	2018-11-19	1
620	2018-06-24	3
679	2017-12-19	2
423	2018-02-09	1
728	2017-02-19	4
131	2017-02-01	2
973	2017-03-19	5
544	2018-09-29	1
286	2018-01-30	1
848	2017-10-26	5
470	2018-01-16	5
204	2018-01-03	1
487	2017-10-05	1
98	2018-12-21	2
625	2017-10-01	2
766	2017-07-16	1
776	2018-07-25	4
849	2018-05-10	2
108	2018-06-02	2
540	2018-01-21	3
506	2018-10-29	4
187	2018-06-14	2
893	2018-11-04	5
670	2018-11-07	4
196	2017-06-03	5
589	2017-06-23	4
397	2017-02-19	3
450	2018-10-08	2
61	2017-06-15	2
992	2017-02-22	4
993	2018-05-24	3
994	2018-11-27	4
510	2018-10-13	2
784	2017-04-21	4
580	2017-06-24	3
917	2017-11-14	4
114	2018-03-22	3
868	2018-10-12	1
663	2018-04-22	1
806	2018-01-02	3
350	2017-11-14	3
882	2018-09-18	2
819	2018-07-13	5
7	2018-04-08	5
691	2017-02-18	2
455	2018-03-30	1
89	2017-11-30	5
167	2018-04-03	5
581	2018-02-09	2
722	2018-01-31	4
111	2017-12-15	5
452	2017-08-19	1
889	2017-12-26	5
469	2018-11-20	2
522	2017-08-28	5
454	2017-07-11	1
899	2017-09-07	2
690	2018-09-24	5
765	2018-09-16	1
768	2018-06-04	3
80	2018-11-13	1
896	2017-01-04	4
547	2018-11-08	5
303	2017-09-12	4
178	2017-11-07	1
52	2017-10-14	5
944	2018-12-19	5
39	2017-03-19	3
217	2018-02-21	5
657	2017-04-10	2
504	2018-05-20	4
489	2018-05-13	4
814	2018-06-18	2
519	2018-12-06	2
383	2018-09-12	1
976	2017-06-04	5
839	2017-02-06	2
224	2018-10-08	5
351	2018-03-27	5
51	2017-10-07	4
586	2018-11-29	1
188	2017-11-28	2
263	2018-06-28	2
186	2018-10-07	4
675	2018-01-09	5
989	2018-08-24	5
530	2018-10-15	1
1	2018-10-02	5
932	2017-11-18	2
590	2017-02-05	2
753	2017-09-04	1
6	2018-07-27	5
714	2017-06-23	5
928	2017-04-21	2
262	2018-11-12	5
279	2017-08-30	4
208	2018-02-07	2
933	2018-08-01	2
648	2017-02-19	4
150	2018-11-01	5
509	2017-11-08	5
394	2018-06-28	1
955	2017-03-09	5
486	2018-03-16	1
553	2018-02-15	2
250	2018-10-01	5
90	2018-08-25	1
25	2018-10-21	2
921	2017-06-30	5
533	2017-02-05	5
328	2018-07-13	5
720	2017-05-05	3
830	2018-03-31	3
829	2018-01-02	4
734	2018-04-01	4
43	2017-11-05	2
627	2018-06-02	2
305	2018-08-24	3
378	2018-03-07	2
183	2017-09-06	5
745	2018-08-26	3
934	2017-05-31	2
611	2018-03-17	4
915	2017-10-05	4
287	2018-08-11	1
744	2017-12-23	1
87	2017-09-03	1
638	2018-10-02	4
91	2018-01-26	5
571	2018-03-08	3
930	2017-03-14	1
324	2018-07-01	2
688	2017-09-21	4
671	2018-12-25	2
386	2017-12-14	1
548	2018-06-25	3
803	2017-07-14	3
826	2017-04-01	5
248	2017-11-08	3
812	2017-05-24	3
884	2017-09-08	2
600	2017-06-07	5
542	2018-08-24	2
83	2017-06-01	1
137	2017-06-19	2
570	2017-11-28	2
562	2017-10-13	2
448	2017-02-23	5
50	2017-07-03	2
610	2018-05-12	5
961	2017-09-28	3
308	2017-01-14	4
642	2017-08-17	3
511	2017-02-20	3
924	2018-05-03	3
919	2018-05-02	5
524	2018-12-17	2
92	2018-04-17	1
69	2018-12-22	5
472	2018-08-18	2
330	2017-11-03	5
878	2017-08-08	1
908	2017-12-30	5
640	2018-11-29	3
144	2017-03-18	3
787	2017-09-27	4
777	2018-03-15	2
877	2018-01-24	5
977	2017-11-13	3
912	2018-12-19	2
478	2017-03-11	5
603	2017-06-16	2
543	2017-04-20	3
175	2017-02-09	1
583	2017-01-07	3
516	2017-07-12	2
200	2018-04-22	3
986	2017-06-09	4
21	2017-06-17	1
459	2018-07-16	4
123	2018-05-21	4
567	2017-11-14	1
142	2018-10-04	5
725	2017-12-23	3
311	2017-04-03	1
431	2018-05-24	5
231	2018-05-25	5
428	2017-02-01	5
749	2018-11-25	1
18	2018-02-04	1
941	2018-06-01	5
479	2018-09-29	3
773	2018-03-01	2
783	2018-12-24	3
10	2018-05-08	3
304	2018-08-28	1
47	2017-01-01	3
813	2017-02-19	5
254	2018-10-04	5
837	2017-08-30	2
118	2017-08-04	3
152	2018-03-28	4
942	2018-03-21	5
202	2018-11-29	1
433	2018-05-13	2
552	2017-05-08	1
484	2018-04-25	3
750	2017-09-03	1
191	2018-10-10	4
93	2017-12-03	5
241	2017-10-19	1
740	2017-06-11	4
132	2017-03-29	4
982	2017-09-05	1
401	2017-02-17	1
974	2018-06-04	5
212	2018-08-15	1
40	2018-06-21	5
103	2018-04-08	5
370	2018-01-05	3
551	2018-07-05	2
275	2018-06-27	3
105	2017-04-12	4
274	2018-01-16	4
1000	2018-01-29	2
791	2017-07-11	4
238	2017-05-22	5
36	2017-06-15	5
629	2017-02-07	4
531	2017-07-08	3
972	2017-08-12	3
500	2018-01-09	4
864	2017-02-15	4
79	2017-03-27	5
597	2018-12-11	4
746	2018-10-05	4
845	2018-05-03	5
945	2018-08-28	4
106	2017-04-07	1
376	2017-02-06	3
476	2018-05-16	3
537	2018-04-06	5
979	2018-04-16	5
650	2017-12-29	5
194	2017-09-14	5
265	2018-09-25	4
74	2018-09-20	5
892	2017-11-04	1
233	2018-08-19	5
635	2017-01-25	4
535	2017-12-15	3
639	2018-09-30	2
804	2018-07-13	3
474	2017-10-20	4
429	2017-01-14	1
299	2018-12-18	1
863	2017-04-08	3
335	2017-10-06	3
205	2018-03-28	1
821	2017-03-14	4
366	2017-11-24	3
641	2018-02-13	1
340	2017-12-24	4
343	2017-07-04	5
702	2017-03-25	3
312	2017-06-06	3
182	2017-02-17	1
257	2017-04-10	4
413	2017-02-21	1
148	2017-01-26	3
318	2018-01-05	3
971	2018-11-03	2
158	2018-04-27	1
869	2017-07-25	4
843	2018-09-28	1
462	2018-09-17	4
197	2017-01-13	3
913	2018-04-02	1
965	2017-03-10	1
872	2018-06-24	5
764	2017-06-05	3
833	2017-10-06	4
471	2018-08-26	4
404	2017-10-11	2
174	2018-04-13	1
95	2017-08-15	2
141	2018-05-16	3
276	2017-07-12	1
477	2017-09-05	1
809	2018-06-28	5
20	2018-10-29	2
112	2018-02-12	3
879	2018-05-19	3
149	2018-11-10	2
121	2017-12-11	1
347	2017-03-01	1
55	2018-03-19	3
832	2017-07-06	5
473	2017-11-27	5
332	2018-06-10	1
160	2017-04-18	5
22	2017-12-12	5
859	2018-09-17	4
396	2017-09-25	5
558	2017-04-26	5
866	2017-07-15	5
712	2018-12-27	5
359	2018-10-13	5
333	2017-07-08	5
781	2018-04-01	4
29	2017-11-16	5
285	2017-02-04	1
739	2017-09-29	4
439	2018-01-12	1
236	2017-07-27	1
215	2017-07-03	5
505	2018-04-25	2
11	2017-02-10	3
794	2017-11-30	5
614	2018-05-05	5
3	2017-01-12	5
445	2018-12-08	3
801	2017-02-04	4
888	2018-10-02	1
779	2017-10-08	4
419	2017-11-05	2
407	2017-10-20	3
94	2017-07-02	3
412	2017-10-29	4
133	2017-11-09	5
82	2018-06-22	5
117	2017-09-09	3
538	2017-09-11	4
406	2018-02-07	2
587	2017-05-20	3
268	2017-12-31	3
946	2017-04-11	4
724	2017-08-22	3
556	2017-07-06	5
243	2017-02-02	4
307	2017-11-02	3
630	2017-11-02	1
628	2018-06-26	4
539	2017-07-05	5
258	2017-08-23	5
409	2018-01-07	3
852	2017-11-01	1
19	2017-11-07	3
797	2018-02-15	2
27	2018-04-25	1
988	2017-09-17	5
871	2017-12-21	3
808	2018-06-02	5
834	2018-04-16	4
651	2017-11-13	1
438	2017-05-06	3
660	2017-08-08	1
115	2018-01-26	4
762	2018-02-23	3
501	2017-09-25	2
669	2017-04-13	1
341	2017-04-04	5
405	2017-11-19	5
694	2018-08-23	3
873	2018-05-01	4
198	2017-11-25	1
329	2017-04-07	4
84	2018-05-05	3
354	2017-02-01	2
252	2017-06-22	5
453	2017-10-24	2
616	2017-05-22	4
488	2018-01-15	3
122	2018-05-10	5
327	2018-11-09	1
528	2018-09-09	2
717	2017-04-27	2
856	2017-05-12	4
416	2017-05-17	5
68	2018-08-24	1
929	2018-01-16	2
840	2018-11-13	5
85	2018-05-07	3
759	2017-12-06	1
155	2017-04-14	2
824	2018-07-17	2
909	2017-09-17	4
736	2017-09-08	3
754	2017-10-27	2
608	2018-02-05	2
786	2017-12-25	3
451	2017-06-26	5
644	2018-11-12	4
136	2018-09-29	1
119	2017-02-03	1
582	2018-03-13	3
619	2018-07-03	3
719	2017-03-11	4
937	2017-04-28	4
911	2017-02-01	3
850	2017-05-29	2
818	2018-02-22	5
788	2018-06-09	3
81	2017-12-24	2
529	2017-07-09	3
219	2018-03-06	2
774	2017-10-17	2
227	2017-11-30	1
943	2018-01-22	5
805	2018-11-27	1
954	2017-09-28	4
502	2018-05-02	1
226	2017-06-14	4
906	2018-04-26	5
13	2017-06-01	2
147	2018-10-09	2
707	2017-12-06	5
615	2017-06-26	3
294	2017-06-17	1
710	2018-03-15	4
189	2017-03-10	2
513	2018-07-17	2
983	2018-11-15	3
352	2018-09-24	5
870	2018-06-19	3
457	2017-06-14	4
555	2018-07-16	5
554	2018-09-21	2
67	2017-12-24	5
527	2017-02-21	5
895	2018-02-03	5
940	2017-07-22	2
656	2017-10-08	2
584	2018-11-21	4
708	2018-04-15	1
154	2018-11-21	2
799	2018-09-09	2
673	2017-12-06	3
637	2017-01-08	5
161	2018-02-04	3
159	2018-06-19	3
211	2018-12-02	2
220	2018-06-04	1
761	2017-04-10	4
696	2018-11-13	2
685	2017-06-20	3
292	2017-03-07	4
128	2017-06-02	5
842	2018-05-08	5
790	2017-04-04	4
732	2018-11-26	4
532	2017-03-02	5
601	2017-07-28	4
169	2018-01-30	2
591	2018-02-06	5
206	2018-02-24	1
569	2017-10-31	2
177	2017-03-04	4
278	2018-11-09	2
143	2017-01-02	5
817	2018-03-20	3
417	2018-03-08	1
242	2017-01-24	3
88	2018-07-08	3
559	2018-07-09	2
393	2018-04-17	2
362	2017-03-05	3
422	2018-07-16	3
260	2017-04-29	3
468	2017-02-14	5
789	2017-01-23	1
785	2018-09-25	5
435	2018-01-15	1
33	2017-08-01	5
578	2017-01-27	3
338	2018-01-07	5
936	2018-10-30	5
466	2017-01-27	5
234	2018-10-03	1
14	2017-06-18	2
15	2018-07-01	3
701	2017-12-12	5
568	2017-08-10	3
918	2018-12-22	1
541	2018-11-04	5
253	2017-09-30	5
424	2018-12-01	1
361	2018-06-08	2
358	2017-04-29	1
721	2018-01-30	1
266	2018-09-20	2
858	2017-01-31	3
634	2017-09-11	4
390	2018-07-28	4
741	2018-05-05	5
606	2017-10-24	2
297	2018-04-05	1
820	2018-06-30	4
865	2017-06-23	3
499	2018-02-05	3
302	2017-02-25	5
990	2018-01-09	4
731	2017-04-26	3
970	2018-12-04	4
693	2018-02-24	3
907	2017-09-01	1
901	2018-11-13	1
716	2018-06-18	4
577	2017-11-21	4
321	2018-04-15	4
26	2018-03-31	2
282	2017-11-10	1
256	2017-03-19	4
490	2017-10-06	3
60	2018-06-09	5
692	2018-01-27	5
31	2018-02-22	1
566	2018-06-27	2
165	2018-05-28	5
493	2017-06-28	3
138	2018-04-11	2
432	2018-09-24	4
465	2017-01-03	4
436	2017-03-05	5
655	2017-11-04	2
34	2017-12-26	2
134	2017-12-19	3
890	2018-03-05	2
176	2017-05-25	4
78	2017-10-04	4
534	2017-11-20	3
960	2018-08-01	4
210	2017-09-18	4
443	2018-01-11	5
349	2018-08-02	2
617	2017-05-30	2
682	2017-12-01	4
442	2017-01-13	1
375	2018-04-08	5
44	2017-06-17	4
399	2018-03-13	4
48	2018-05-03	5
130	2017-02-09	1
28	2017-03-06	2
827	2018-07-04	3
698	2017-01-20	5
336	2018-04-14	2
157	2018-12-07	2
368	2018-09-27	2
229	2017-09-30	3
300	2017-11-09	3
9	2017-02-19	3
997	2017-08-19	5
497	2018-09-24	4
775	2018-04-13	3
75	2018-06-30	5
935	2018-08-27	3
515	2018-08-06	5
514	2017-10-25	5
482	2017-03-29	4
291	2018-01-21	2
564	2017-01-11	4
214	2018-10-31	1
410	2018-02-15	4
392	2018-06-16	3
379	2018-10-29	5
975	2018-05-14	5
748	2018-04-13	3
203	2018-05-09	4
35	2017-02-23	2
104	2017-01-12	4
949	2017-07-08	5
894	2018-02-11	3
113	2018-08-26	2
999	2017-09-01	2
857	2017-08-28	2
364	2018-03-22	2
769	2018-06-23	2
485	2017-05-27	1
968	2017-06-01	1
602	2018-03-11	5
665	2017-01-28	5
16	2017-06-10	2
411	2017-10-24	3
430	2017-12-25	4
467	2018-12-02	3
689	2018-07-18	1
97	2017-07-11	2
387	2018-05-12	1
678	2017-09-17	4
356	2017-04-29	2
815	2018-02-01	4
963	2018-11-13	5
525	2017-08-21	2
458	2018-04-22	5
213	2017-07-10	4
838	2018-01-28	1
384	2017-01-22	2
146	2017-12-13	1
565	2017-06-15	5
508	2018-05-26	5
573	2017-12-08	2
585	2018-03-20	5
847	2018-12-15	4
546	2018-04-02	3
816	2018-12-14	5
346	2017-01-04	2
572	2018-10-30	5
667	2018-12-12	4
984	2018-02-10	5
980	2018-01-11	5
293	2017-06-08	4
854	2017-07-09	5
958	2018-04-04	3
626	2017-02-24	1
605	2017-04-19	3
209	2018-07-20	2
851	2018-01-23	3
12	2018-10-12	2
757	2018-09-13	5
172	2017-05-10	2
792	2018-07-19	1
686	2017-03-02	3
425	2018-12-29	4
795	2017-05-29	4
168	2018-02-07	5
947	2017-07-25	3
102	2018-02-13	2
914	2018-11-08	3
846	2018-01-31	3
237	2017-07-06	3
190	2017-06-27	2
195	2018-12-13	1
521	2018-06-30	2
58	2017-08-27	5
162	2018-12-10	1
593	2017-07-22	4
400	2018-10-26	1
223	2017-05-28	3
441	2018-02-11	5
622	2018-02-18	3
771	2018-03-03	1
37	2017-03-31	2
464	2018-10-26	5
317	2018-07-31	4
180	2018-01-05	2
632	2017-10-12	3
310	2018-04-25	2
45	2017-03-13	3
382	2017-10-15	2
517	2017-03-17	3
811	2017-06-13	2
991	2017-02-19	5
323	2018-04-04	1
891	2017-01-17	5
446	2018-01-09	1
760	2018-01-07	3
862	2018-01-05	1
998	2017-04-11	3
985	2018-09-07	2
621	2017-06-17	4
588	2017-01-30	5
715	2018-05-24	4
920	2017-11-11	3
623	2017-06-15	5
987	2017-04-12	3
738	2017-06-22	4
398	2017-10-08	1
703	2017-09-12	2
676	2017-07-26	4
647	2018-11-07	5
646	2017-07-30	2
179	2018-11-16	2
277	2017-09-24	2
264	2017-05-19	5
381	2018-09-19	2
116	2018-10-22	2
76	2017-09-08	4
24	2017-12-09	1
365	2017-05-20	3
185	2017-12-30	3
64	2018-10-19	1
886	2018-07-03	1
860	2017-01-04	2
652	2018-03-11	2
96	2018-03-29	1
853	2017-03-13	2
796	2017-07-29	2
953	2017-03-02	4
867	2018-01-23	1
221	2018-06-10	5
822	2017-10-07	2
355	2017-12-02	5
645	2017-12-21	5
232	2018-07-30	3
883	2018-09-01	5
306	2017-02-08	5
967	2017-09-22	1
951	2017-09-18	2
273	2018-07-23	2
887	2017-10-11	3
110	2018-05-24	2
523	2018-11-14	4
925	2017-07-31	3
377	2017-03-15	2
981	2018-11-29	3
549	2018-10-15	5
325	2018-06-02	1
810	2018-01-26	1
151	2017-07-01	3
563	2017-08-04	1
876	2018-10-14	5
280	2017-07-04	2
752	2017-08-23	1
272	2017-04-08	4
607	2017-11-07	3
372	2017-05-30	4
244	2018-01-25	2
267	2017-04-22	5
575	2018-06-27	2
550	2017-05-14	3
643	2018-08-15	5
705	2017-10-27	1
193	2017-11-17	4
956	2017-06-09	2
959	2017-03-03	3
54	2018-05-15	2
756	2017-03-23	5
962	2018-01-14	5
594	2018-08-15	3
780	2018-09-15	4
415	2018-10-21	4
447	2018-09-20	3
875	2018-06-25	3
723	2018-02-27	3
526	2017-09-02	5
371	2018-02-27	1
598	2017-06-15	3
503	2017-11-06	4
668	2017-01-05	3
978	2017-05-24	2
109	2017-02-27	5
758	2017-08-07	3
624	2018-12-07	1
687	2017-11-23	5
507	2017-09-22	3
283	2017-05-09	4
836	2018-09-30	5
711	2017-04-23	4
426	2018-01-28	1
440	2018-03-31	4
681	2017-11-07	2
706	2017-11-02	2
778	2018-07-31	2
331	2018-04-03	1
181	2017-02-11	2
230	2018-07-09	4
284	2017-07-22	3
228	2018-03-03	2
957	2018-10-17	5
770	2017-03-03	2
353	2018-05-08	5
437	2018-12-16	5
654	2018-09-17	5
140	2017-12-24	1
316	2018-02-09	4
290	2018-07-25	5
201	2018-03-16	4
666	2018-05-03	5
841	2018-01-22	3
235	2018-11-12	1
966	2018-12-07	2
483	2017-02-11	5
927	2017-08-20	4
41	2017-08-02	3
369	2017-06-24	2
153	2018-11-15	4
938	2018-03-04	4
727	2018-01-22	4
414	2018-05-16	1
561	2017-04-17	1
807	2018-01-22	3
828	2018-11-09	1
334	2018-06-24	5
255	2017-02-18	4
360	2018-09-12	3
595	2018-10-02	4
344	2017-10-22	3
145	2017-12-15	2
496	2018-04-25	5
42	2017-02-11	4
612	2017-10-11	3
743	2018-07-01	3
631	2018-01-30	3
737	2017-06-10	3
246	2017-12-10	2
636	2018-02-16	1
613	2018-02-06	3
844	2018-08-07	5
288	2018-03-08	5
697	2017-03-15	3
380	2018-09-24	1
881	2018-01-21	1
281	2018-06-28	5
874	2017-03-18	2
373	2018-07-04	4
923	2018-02-26	2
747	2018-07-13	1
800	2018-05-11	2
733	2017-04-21	1
367	2018-05-16	3
948	2017-03-31	4
772	2017-10-22	3
342	2018-02-28	3
4	2018-07-22	1
240	2017-12-18	4
950	2018-11-05	3
475	2018-06-22	1
135	2018-10-30	3
926	2018-06-21	2
216	2018-02-13	2
699	2017-01-26	3
782	2018-06-27	4
23	2017-08-28	5
57	2017-03-26	5
222	2017-03-19	3
674	2017-01-09	4
249	2018-02-27	2
659	2017-06-19	3
460	2017-10-08	3
269	2017-11-30	3
574	2018-05-05	2
129	2017-06-21	2
2	2018-01-31	5
449	2017-06-21	1
763	2018-11-27	4
207	2017-10-09	1
755	2018-10-31	2
916	2017-01-07	4
70	2018-11-06	4
315	2017-12-02	3
46	2017-11-10	4
729	2017-12-19	4
17	2018-02-05	3
900	2018-08-04	5
592	2018-11-04	3
247	2018-05-29	3
861	2017-02-02	5
99	2018-06-04	3
952	2018-02-26	2
922	2017-05-27	4
199	2018-07-22	4
163	2018-11-29	5
964	2018-08-18	4
910	2017-05-19	4
100	2017-09-19	1
239	2018-02-16	2
59	2017-09-26	2
596	2018-10-28	2
793	2017-02-19	4
898	2018-12-08	5
301	2017-06-23	2
403	2018-04-23	1
835	2017-05-06	4
385	2018-08-25	5
124	2017-02-17	2
86	2018-03-10	4
658	2017-09-29	2
557	2018-05-11	3
296	2017-07-18	5
579	2018-11-08	1
713	2017-04-17	1
649	2017-09-19	1
322	2017-08-31	4
418	2017-04-04	5
456	2017-08-04	2
389	2017-11-10	4
903	2018-11-09	2
261	2017-08-03	3
751	2018-10-17	4
127	2017-01-17	1
662	2017-10-08	5
661	2018-03-15	5
295	2017-04-03	2
56	2018-09-14	4
72	2018-10-23	3
461	2017-03-03	2
969	2018-12-05	4
480	2017-01-17	4
996	2018-11-12	4
259	2017-04-20	1
536	2018-12-09	2
576	2017-10-27	1
463	2017-09-25	3
313	2017-08-03	2
218	2018-10-05	3
718	2017-09-08	4
184	2018-05-06	1
653	2018-06-18	5
225	2018-10-24	4
251	2017-06-26	3
319	2017-03-06	2
66	2017-07-03	1
173	2017-10-25	2
289	2018-03-23	3
518	2018-01-05	5
8	2018-10-12	5
495	2018-07-17	3
339	2018-07-09	2
700	2017-04-05	1
107	2018-01-21	5
164	2018-04-28	1
798	2017-07-02	3
374	2018-08-25	3
77	2018-07-22	4
599	2018-09-05	4
512	2018-10-03	3
434	2017-03-24	2
735	2018-03-12	1
270	2017-12-01	2
345	2018-01-20	2
314	2017-08-24	1
65	2018-05-23	5
38	2018-03-23	3
120	2018-08-02	4
695	2018-05-17	5
32	2017-11-18	2
684	2017-06-20	3
63	2018-12-14	4
357	2018-05-18	3
337	2018-09-03	3
904	2018-11-22	4
326	2017-03-20	1
494	2017-08-18	2
492	2017-11-12	5
825	2018-02-08	1
664	2018-10-20	1
633	2017-08-25	1
363	2017-11-22	1
823	2018-12-02	1
931	2018-12-16	5
709	2018-07-23	5
609	2017-02-06	4
126	2017-07-30	2
125	2018-12-31	1
245	2018-03-30	4
71	2017-01-20	5
902	2018-10-08	2
680	2017-04-13	3
481	2017-09-30	2
604	2018-10-10	1
192	2018-09-29	4
683	2018-09-20	4
395	2018-09-11	4
73	2017-07-28	1
672	2017-07-18	4
885	2017-10-13	1
391	2018-07-11	1
726	2018-05-07	5
560	2017-02-01	1
897	2018-07-03	1
420	2017-10-23	5
491	2018-11-29	1
271	2017-06-13	1
309	2018-08-04	1
298	2017-06-20	1
408	2017-08-22	3
939	2017-09-02	1
831	2017-11-16	4
139	2018-04-21	2
742	2018-06-21	1
5	2017-01-17	3
880	2017-02-13	2
30	2017-08-02	2
905	2017-09-15	3
101	2017-05-12	5
730	2018-06-23	1
545	2017-01-22	5
802	2018-01-15	2
427	2017-12-09	3
53	2018-03-25	1
421	2018-11-27	1
388	2017-03-25	1
170	2017-11-04	1
348	2017-03-18	1
677	2018-11-19	1
423	2018-02-09	1
544	2018-09-29	1
286	2018-01-30	1
204	2018-01-03	1
487	2017-10-05	1
766	2017-07-16	1
868	2018-10-12	1
663	2018-04-22	1
455	2018-03-30	1
452	2017-08-19	1
454	2017-07-11	1
765	2018-09-16	1
80	2018-11-13	1
178	2017-11-07	1
383	2018-09-12	1
586	2018-11-29	1
530	2018-10-15	1
753	2017-09-04	1
394	2018-06-28	1
486	2018-03-16	1
90	2018-08-25	1
287	2018-08-11	1
744	2017-12-23	1
87	2017-09-03	1
930	2017-03-14	1
386	2017-12-14	1
83	2017-06-01	1
92	2018-04-17	1
878	2017-08-08	1
175	2017-02-09	1
21	2017-06-17	1
567	2017-11-14	1
311	2017-04-03	1
749	2018-11-25	1
18	2018-02-04	1
304	2018-08-28	1
202	2018-11-29	1
552	2017-05-08	1
750	2017-09-03	1
241	2017-10-19	1
982	2017-09-05	1
401	2017-02-17	1
212	2018-08-15	1
106	2017-04-07	1
892	2017-11-04	1
429	2017-01-14	1
299	2018-12-18	1
205	2018-03-28	1
641	2018-02-13	1
182	2017-02-17	1
413	2017-02-21	1
158	2018-04-27	1
843	2018-09-28	1
913	2018-04-02	1
965	2017-03-10	1
174	2018-04-13	1
276	2017-07-12	1
477	2017-09-05	1
121	2017-12-11	1
347	2017-03-01	1
332	2018-06-10	1
285	2017-02-04	1
439	2018-01-12	1
236	2017-07-27	1
888	2018-10-02	1
630	2017-11-02	1
852	2017-11-01	1
27	2018-04-25	1
651	2017-11-13	1
660	2017-08-08	1
669	2017-04-13	1
198	2017-11-25	1
327	2018-11-09	1
68	2018-08-24	1
759	2017-12-06	1
136	2018-09-29	1
119	2017-02-03	1
227	2017-11-30	1
805	2018-11-27	1
502	2018-05-02	1
294	2017-06-17	1
708	2018-04-15	1
220	2018-06-04	1
206	2018-02-24	1
417	2018-03-08	1
789	2017-01-23	1
435	2018-01-15	1
234	2018-10-03	1
918	2018-12-22	1
424	2018-12-01	1
358	2017-04-29	1
721	2018-01-30	1
297	2018-04-05	1
907	2017-09-01	1
901	2018-11-13	1
282	2017-11-10	1
31	2018-02-22	1
442	2017-01-13	1
130	2017-02-09	1
214	2018-10-31	1
485	2017-05-27	1
968	2017-06-01	1
689	2018-07-18	1
387	2018-05-12	1
838	2018-01-28	1
146	2017-12-13	1
626	2017-02-24	1
792	2018-07-19	1
195	2018-12-13	1
162	2018-12-10	1
400	2018-10-26	1
771	2018-03-03	1
323	2018-04-04	1
446	2018-01-09	1
862	2018-01-05	1
398	2017-10-08	1
24	2017-12-09	1
64	2018-10-19	1
886	2018-07-03	1
96	2018-03-29	1
867	2018-01-23	1
967	2017-09-22	1
325	2018-06-02	1
810	2018-01-26	1
563	2017-08-04	1
752	2017-08-23	1
705	2017-10-27	1
371	2018-02-27	1
624	2018-12-07	1
426	2018-01-28	1
331	2018-04-03	1
140	2017-12-24	1
235	2018-11-12	1
414	2018-05-16	1
561	2017-04-17	1
828	2018-11-09	1
636	2018-02-16	1
380	2018-09-24	1
881	2018-01-21	1
747	2018-07-13	1
733	2017-04-21	1
4	2018-07-22	1
475	2018-06-22	1
449	2017-06-21	1
207	2017-10-09	1
100	2017-09-19	1
403	2018-04-23	1
579	2018-11-08	1
713	2017-04-17	1
649	2017-09-19	1
127	2017-01-17	1
259	2017-04-20	1
576	2017-10-27	1
184	2018-05-06	1
66	2017-07-03	1
700	2017-04-05	1
164	2018-04-28	1
735	2018-03-12	1
314	2017-08-24	1
326	2017-03-20	1
825	2018-02-08	1
664	2018-10-20	1
633	2017-08-25	1
363	2017-11-22	1
823	2018-12-02	1
125	2018-12-31	1
604	2018-10-10	1
73	2017-07-28	1
885	2017-10-13	1
391	2018-07-11	1
560	2017-02-01	1
897	2018-07-03	1
491	2018-11-29	1
271	2017-06-13	1
309	2018-08-04	1
298	2017-06-20	1
939	2017-09-02	1
742	2018-06-21	1
730	2018-06-23	1
62	2018-07-23	4
49	2017-04-27	5
53	2018-03-25	1
421	2018-11-27	1
444	2018-11-21	2
388	2017-03-25	1
618	2017-07-14	2
855	2018-04-15	3
170	2017-11-04	1
156	2017-10-25	4
767	2018-01-25	3
704	2018-04-25	4
171	2018-03-27	5
166	2018-09-17	2
348	2017-03-18	1
995	2018-07-31	4
402	2017-09-17	3
498	2017-07-27	4
520	2018-08-20	3
320	2018-01-09	3
677	2018-11-19	1
620	2018-06-24	3
679	2017-12-19	2
423	2018-02-09	1
728	2017-02-19	4
131	2017-02-01	2
973	2017-03-19	5
544	2018-09-29	1
286	2018-01-30	1
848	2017-10-26	5
470	2018-01-16	5
204	2018-01-03	1
487	2017-10-05	1
98	2018-12-21	2
625	2017-10-01	2
766	2017-07-16	1
776	2018-07-25	4
849	2018-05-10	2
108	2018-06-02	2
540	2018-01-21	3
506	2018-10-29	4
187	2018-06-14	2
893	2018-11-04	5
670	2018-11-07	4
196	2017-06-03	5
589	2017-06-23	4
397	2017-02-19	3
450	2018-10-08	2
61	2017-06-15	2
992	2017-02-22	4
993	2018-05-24	3
994	2018-11-27	4
510	2018-10-13	2
784	2017-04-21	4
580	2017-06-24	3
917	2017-11-14	4
114	2018-03-22	3
868	2018-10-12	1
663	2018-04-22	1
806	2018-01-02	3
350	2017-11-14	3
882	2018-09-18	2
819	2018-07-13	5
7	2018-04-08	5
691	2017-02-18	2
455	2018-03-30	1
89	2017-11-30	5
167	2018-04-03	5
581	2018-02-09	2
722	2018-01-31	4
111	2017-12-15	5
452	2017-08-19	1
889	2017-12-26	5
469	2018-11-20	2
522	2017-08-28	5
454	2017-07-11	1
899	2017-09-07	2
690	2018-09-24	5
765	2018-09-16	1
768	2018-06-04	3
80	2018-11-13	1
896	2017-01-04	4
547	2018-11-08	5
303	2017-09-12	4
178	2017-11-07	1
52	2017-10-14	5
944	2018-12-19	5
39	2017-03-19	3
217	2018-02-21	5
657	2017-04-10	2
504	2018-05-20	4
489	2018-05-13	4
814	2018-06-18	2
519	2018-12-06	2
383	2018-09-12	1
976	2017-06-04	5
839	2017-02-06	2
224	2018-10-08	5
351	2018-03-27	5
51	2017-10-07	4
586	2018-11-29	1
188	2017-11-28	2
263	2018-06-28	2
186	2018-10-07	4
675	2018-01-09	5
989	2018-08-24	5
530	2018-10-15	1
1	2018-10-02	5
932	2017-11-18	2
590	2017-02-05	2
753	2017-09-04	1
6	2018-07-27	5
714	2017-06-23	5
928	2017-04-21	2
262	2018-11-12	5
279	2017-08-30	4
208	2018-02-07	2
933	2018-08-01	2
648	2017-02-19	4
150	2018-11-01	5
509	2017-11-08	5
394	2018-06-28	1
955	2017-03-09	5
486	2018-03-16	1
553	2018-02-15	2
250	2018-10-01	5
90	2018-08-25	1
25	2018-10-21	2
921	2017-06-30	5
533	2017-02-05	5
328	2018-07-13	5
720	2017-05-05	3
830	2018-03-31	3
829	2018-01-02	4
734	2018-04-01	4
43	2017-11-05	2
627	2018-06-02	2
305	2018-08-24	3
378	2018-03-07	2
183	2017-09-06	5
745	2018-08-26	3
934	2017-05-31	2
611	2018-03-17	4
915	2017-10-05	4
287	2018-08-11	1
744	2017-12-23	1
87	2017-09-03	1
638	2018-10-02	4
91	2018-01-26	5
571	2018-03-08	3
930	2017-03-14	1
324	2018-07-01	2
688	2017-09-21	4
671	2018-12-25	2
386	2017-12-14	1
548	2018-06-25	3
803	2017-07-14	3
826	2017-04-01	5
248	2017-11-08	3
812	2017-05-24	3
884	2017-09-08	2
600	2017-06-07	5
542	2018-08-24	2
83	2017-06-01	1
137	2017-06-19	2
570	2017-11-28	2
562	2017-10-13	2
448	2017-02-23	5
50	2017-07-03	2
610	2018-05-12	5
961	2017-09-28	3
308	2017-01-14	4
642	2017-08-17	3
511	2017-02-20	3
924	2018-05-03	3
919	2018-05-02	5
524	2018-12-17	2
92	2018-04-17	1
69	2018-12-22	5
472	2018-08-18	2
330	2017-11-03	5
878	2017-08-08	1
908	2017-12-30	5
640	2018-11-29	3
144	2017-03-18	3
787	2017-09-27	4
777	2018-03-15	2
877	2018-01-24	5
977	2017-11-13	3
912	2018-12-19	2
478	2017-03-11	5
603	2017-06-16	2
543	2017-04-20	3
175	2017-02-09	1
583	2017-01-07	3
516	2017-07-12	2
200	2018-04-22	3
986	2017-06-09	4
21	2017-06-17	1
459	2018-07-16	4
123	2018-05-21	4
567	2017-11-14	1
142	2018-10-04	5
725	2017-12-23	3
311	2017-04-03	1
431	2018-05-24	5
231	2018-05-25	5
428	2017-02-01	5
749	2018-11-25	1
18	2018-02-04	1
941	2018-06-01	5
479	2018-09-29	3
773	2018-03-01	2
783	2018-12-24	3
10	2018-05-08	3
304	2018-08-28	1
47	2017-01-01	3
813	2017-02-19	5
254	2018-10-04	5
837	2017-08-30	2
118	2017-08-04	3
152	2018-03-28	4
942	2018-03-21	5
202	2018-11-29	1
433	2018-05-13	2
552	2017-05-08	1
484	2018-04-25	3
750	2017-09-03	1
191	2018-10-10	4
93	2017-12-03	5
241	2017-10-19	1
740	2017-06-11	4
132	2017-03-29	4
982	2017-09-05	1
401	2017-02-17	1
974	2018-06-04	5
212	2018-08-15	1
40	2018-06-21	5
103	2018-04-08	5
370	2018-01-05	3
551	2018-07-05	2
275	2018-06-27	3
105	2017-04-12	4
274	2018-01-16	4
1000	2018-01-29	2
791	2017-07-11	4
238	2017-05-22	5
36	2017-06-15	5
629	2017-02-07	4
531	2017-07-08	3
972	2017-08-12	3
500	2018-01-09	4
864	2017-02-15	4
79	2017-03-27	5
597	2018-12-11	4
746	2018-10-05	4
845	2018-05-03	5
945	2018-08-28	4
106	2017-04-07	1
376	2017-02-06	3
476	2018-05-16	3
537	2018-04-06	5
979	2018-04-16	5
650	2017-12-29	5
194	2017-09-14	5
265	2018-09-25	4
74	2018-09-20	5
892	2017-11-04	1
233	2018-08-19	5
635	2017-01-25	4
535	2017-12-15	3
639	2018-09-30	2
804	2018-07-13	3
474	2017-10-20	4
429	2017-01-14	1
299	2018-12-18	1
863	2017-04-08	3
335	2017-10-06	3
205	2018-03-28	1
821	2017-03-14	4
366	2017-11-24	3
641	2018-02-13	1
340	2017-12-24	4
343	2017-07-04	5
702	2017-03-25	3
312	2017-06-06	3
182	2017-02-17	1
257	2017-04-10	4
413	2017-02-21	1
148	2017-01-26	3
318	2018-01-05	3
971	2018-11-03	2
158	2018-04-27	1
869	2017-07-25	4
843	2018-09-28	1
462	2018-09-17	4
197	2017-01-13	3
913	2018-04-02	1
965	2017-03-10	1
872	2018-06-24	5
764	2017-06-05	3
833	2017-10-06	4
471	2018-08-26	4
404	2017-10-11	2
174	2018-04-13	1
95	2017-08-15	2
141	2018-05-16	3
276	2017-07-12	1
477	2017-09-05	1
809	2018-06-28	5
20	2018-10-29	2
112	2018-02-12	3
879	2018-05-19	3
149	2018-11-10	2
121	2017-12-11	1
347	2017-03-01	1
55	2018-03-19	3
832	2017-07-06	5
473	2017-11-27	5
332	2018-06-10	1
160	2017-04-18	5
22	2017-12-12	5
859	2018-09-17	4
396	2017-09-25	5
558	2017-04-26	5
866	2017-07-15	5
712	2018-12-27	5
359	2018-10-13	5
333	2017-07-08	5
781	2018-04-01	4
29	2017-11-16	5
285	2017-02-04	1
739	2017-09-29	4
439	2018-01-12	1
236	2017-07-27	1
215	2017-07-03	5
505	2018-04-25	2
11	2017-02-10	3
794	2017-11-30	5
614	2018-05-05	5
3	2017-01-12	5
445	2018-12-08	3
801	2017-02-04	4
888	2018-10-02	1
779	2017-10-08	4
419	2017-11-05	2
407	2017-10-20	3
94	2017-07-02	3
412	2017-10-29	4
133	2017-11-09	5
82	2018-06-22	5
117	2017-09-09	3
538	2017-09-11	4
406	2018-02-07	2
587	2017-05-20	3
268	2017-12-31	3
946	2017-04-11	4
724	2017-08-22	3
556	2017-07-06	5
243	2017-02-02	4
307	2017-11-02	3
630	2017-11-02	1
628	2018-06-26	4
539	2017-07-05	5
258	2017-08-23	5
409	2018-01-07	3
852	2017-11-01	1
19	2017-11-07	3
797	2018-02-15	2
27	2018-04-25	1
988	2017-09-17	5
871	2017-12-21	3
808	2018-06-02	5
834	2018-04-16	4
651	2017-11-13	1
438	2017-05-06	3
660	2017-08-08	1
115	2018-01-26	4
762	2018-02-23	3
501	2017-09-25	2
669	2017-04-13	1
341	2017-04-04	5
405	2017-11-19	5
694	2018-08-23	3
873	2018-05-01	4
198	2017-11-25	1
329	2017-04-07	4
84	2018-05-05	3
354	2017-02-01	2
252	2017-06-22	5
453	2017-10-24	2
616	2017-05-22	4
488	2018-01-15	3
122	2018-05-10	5
327	2018-11-09	1
528	2018-09-09	2
717	2017-04-27	2
856	2017-05-12	4
416	2017-05-17	5
68	2018-08-24	1
929	2018-01-16	2
840	2018-11-13	5
85	2018-05-07	3
759	2017-12-06	1
155	2017-04-14	2
824	2018-07-17	2
909	2017-09-17	4
736	2017-09-08	3
754	2017-10-27	2
608	2018-02-05	2
786	2017-12-25	3
451	2017-06-26	5
644	2018-11-12	4
136	2018-09-29	1
119	2017-02-03	1
582	2018-03-13	3
619	2018-07-03	3
719	2017-03-11	4
937	2017-04-28	4
911	2017-02-01	3
850	2017-05-29	2
818	2018-02-22	5
788	2018-06-09	3
81	2017-12-24	2
529	2017-07-09	3
219	2018-03-06	2
774	2017-10-17	2
227	2017-11-30	1
943	2018-01-22	5
805	2018-11-27	1
954	2017-09-28	4
502	2018-05-02	1
226	2017-06-14	4
906	2018-04-26	5
13	2017-06-01	2
147	2018-10-09	2
707	2017-12-06	5
615	2017-06-26	3
294	2017-06-17	1
710	2018-03-15	4
189	2017-03-10	2
513	2018-07-17	2
983	2018-11-15	3
352	2018-09-24	5
870	2018-06-19	3
457	2017-06-14	4
555	2018-07-16	5
554	2018-09-21	2
67	2017-12-24	5
527	2017-02-21	5
895	2018-02-03	5
940	2017-07-22	2
656	2017-10-08	2
584	2018-11-21	4
708	2018-04-15	1
154	2018-11-21	2
799	2018-09-09	2
673	2017-12-06	3
637	2017-01-08	5
161	2018-02-04	3
159	2018-06-19	3
211	2018-12-02	2
220	2018-06-04	1
761	2017-04-10	4
696	2018-11-13	2
685	2017-06-20	3
292	2017-03-07	4
128	2017-06-02	5
842	2018-05-08	5
790	2017-04-04	4
732	2018-11-26	4
532	2017-03-02	5
601	2017-07-28	4
169	2018-01-30	2
591	2018-02-06	5
206	2018-02-24	1
569	2017-10-31	2
177	2017-03-04	4
278	2018-11-09	2
143	2017-01-02	5
817	2018-03-20	3
417	2018-03-08	1
242	2017-01-24	3
88	2018-07-08	3
559	2018-07-09	2
393	2018-04-17	2
362	2017-03-05	3
422	2018-07-16	3
260	2017-04-29	3
468	2017-02-14	5
789	2017-01-23	1
785	2018-09-25	5
435	2018-01-15	1
33	2017-08-01	5
578	2017-01-27	3
338	2018-01-07	5
936	2018-10-30	5
466	2017-01-27	5
234	2018-10-03	1
14	2017-06-18	2
15	2018-07-01	3
701	2017-12-12	5
568	2017-08-10	3
918	2018-12-22	1
541	2018-11-04	5
253	2017-09-30	5
424	2018-12-01	1
361	2018-06-08	2
358	2017-04-29	1
721	2018-01-30	1
266	2018-09-20	2
858	2017-01-31	3
634	2017-09-11	4
390	2018-07-28	4
741	2018-05-05	5
606	2017-10-24	2
297	2018-04-05	1
820	2018-06-30	4
865	2017-06-23	3
499	2018-02-05	3
302	2017-02-25	5
990	2018-01-09	4
731	2017-04-26	3
970	2018-12-04	4
693	2018-02-24	3
907	2017-09-01	1
901	2018-11-13	1
716	2018-06-18	4
577	2017-11-21	4
321	2018-04-15	4
26	2018-03-31	2
282	2017-11-10	1
256	2017-03-19	4
490	2017-10-06	3
60	2018-06-09	5
692	2018-01-27	5
31	2018-02-22	1
566	2018-06-27	2
165	2018-05-28	5
493	2017-06-28	3
138	2018-04-11	2
432	2018-09-24	4
465	2017-01-03	4
436	2017-03-05	5
655	2017-11-04	2
34	2017-12-26	2
134	2017-12-19	3
890	2018-03-05	2
176	2017-05-25	4
78	2017-10-04	4
534	2017-11-20	3
960	2018-08-01	4
210	2017-09-18	4
443	2018-01-11	5
349	2018-08-02	2
617	2017-05-30	2
682	2017-12-01	4
442	2017-01-13	1
375	2018-04-08	5
44	2017-06-17	4
399	2018-03-13	4
48	2018-05-03	5
130	2017-02-09	1
28	2017-03-06	2
827	2018-07-04	3
698	2017-01-20	5
336	2018-04-14	2
157	2018-12-07	2
368	2018-09-27	2
229	2017-09-30	3
300	2017-11-09	3
9	2017-02-19	3
997	2017-08-19	5
497	2018-09-24	4
775	2018-04-13	3
75	2018-06-30	5
935	2018-08-27	3
515	2018-08-06	5
514	2017-10-25	5
482	2017-03-29	4
291	2018-01-21	2
564	2017-01-11	4
214	2018-10-31	1
410	2018-02-15	4
392	2018-06-16	3
379	2018-10-29	5
975	2018-05-14	5
748	2018-04-13	3
203	2018-05-09	4
35	2017-02-23	2
104	2017-01-12	4
949	2017-07-08	5
894	2018-02-11	3
113	2018-08-26	2
999	2017-09-01	2
857	2017-08-28	2
364	2018-03-22	2
769	2018-06-23	2
485	2017-05-27	1
968	2017-06-01	1
602	2018-03-11	5
665	2017-01-28	5
16	2017-06-10	2
411	2017-10-24	3
430	2017-12-25	4
467	2018-12-02	3
689	2018-07-18	1
97	2017-07-11	2
387	2018-05-12	1
678	2017-09-17	4
356	2017-04-29	2
815	2018-02-01	4
963	2018-11-13	5
525	2017-08-21	2
458	2018-04-22	5
213	2017-07-10	4
838	2018-01-28	1
384	2017-01-22	2
146	2017-12-13	1
565	2017-06-15	5
508	2018-05-26	5
573	2017-12-08	2
585	2018-03-20	5
847	2018-12-15	4
546	2018-04-02	3
816	2018-12-14	5
346	2017-01-04	2
572	2018-10-30	5
667	2018-12-12	4
984	2018-02-10	5
980	2018-01-11	5
293	2017-06-08	4
854	2017-07-09	5
958	2018-04-04	3
626	2017-02-24	1
605	2017-04-19	3
209	2018-07-20	2
851	2018-01-23	3
12	2018-10-12	2
757	2018-09-13	5
172	2017-05-10	2
792	2018-07-19	1
686	2017-03-02	3
425	2018-12-29	4
795	2017-05-29	4
168	2018-02-07	5
947	2017-07-25	3
102	2018-02-13	2
914	2018-11-08	3
846	2018-01-31	3
237	2017-07-06	3
190	2017-06-27	2
195	2018-12-13	1
521	2018-06-30	2
58	2017-08-27	5
162	2018-12-10	1
593	2017-07-22	4
400	2018-10-26	1
223	2017-05-28	3
441	2018-02-11	5
622	2018-02-18	3
771	2018-03-03	1
37	2017-03-31	2
464	2018-10-26	5
317	2018-07-31	4
180	2018-01-05	2
632	2017-10-12	3
310	2018-04-25	2
45	2017-03-13	3
382	2017-10-15	2
517	2017-03-17	3
811	2017-06-13	2
991	2017-02-19	5
323	2018-04-04	1
891	2017-01-17	5
446	2018-01-09	1
760	2018-01-07	3
862	2018-01-05	1
998	2017-04-11	3
985	2018-09-07	2
621	2017-06-17	4
588	2017-01-30	5
715	2018-05-24	4
920	2017-11-11	3
623	2017-06-15	5
987	2017-04-12	3
738	2017-06-22	4
398	2017-10-08	1
703	2017-09-12	2
676	2017-07-26	4
647	2018-11-07	5
646	2017-07-30	2
179	2018-11-16	2
277	2017-09-24	2
264	2017-05-19	5
381	2018-09-19	2
116	2018-10-22	2
76	2017-09-08	4
24	2017-12-09	1
365	2017-05-20	3
185	2017-12-30	3
64	2018-10-19	1
886	2018-07-03	1
860	2017-01-04	2
652	2018-03-11	2
96	2018-03-29	1
853	2017-03-13	2
796	2017-07-29	2
953	2017-03-02	4
867	2018-01-23	1
221	2018-06-10	5
822	2017-10-07	2
355	2017-12-02	5
645	2017-12-21	5
232	2018-07-30	3
883	2018-09-01	5
306	2017-02-08	5
967	2017-09-22	1
951	2017-09-18	2
273	2018-07-23	2
887	2017-10-11	3
110	2018-05-24	2
523	2018-11-14	4
925	2017-07-31	3
377	2017-03-15	2
981	2018-11-29	3
549	2018-10-15	5
325	2018-06-02	1
810	2018-01-26	1
151	2017-07-01	3
563	2017-08-04	1
876	2018-10-14	5
280	2017-07-04	2
752	2017-08-23	1
272	2017-04-08	4
607	2017-11-07	3
372	2017-05-30	4
244	2018-01-25	2
267	2017-04-22	5
575	2018-06-27	2
550	2017-05-14	3
643	2018-08-15	5
705	2017-10-27	1
193	2017-11-17	4
956	2017-06-09	2
959	2017-03-03	3
54	2018-05-15	2
756	2017-03-23	5
962	2018-01-14	5
594	2018-08-15	3
780	2018-09-15	4
415	2018-10-21	4
447	2018-09-20	3
875	2018-06-25	3
723	2018-02-27	3
526	2017-09-02	5
371	2018-02-27	1
598	2017-06-15	3
503	2017-11-06	4
668	2017-01-05	3
978	2017-05-24	2
109	2017-02-27	5
758	2017-08-07	3
624	2018-12-07	1
687	2017-11-23	5
507	2017-09-22	3
283	2017-05-09	4
836	2018-09-30	5
711	2017-04-23	4
426	2018-01-28	1
440	2018-03-31	4
681	2017-11-07	2
706	2017-11-02	2
778	2018-07-31	2
331	2018-04-03	1
181	2017-02-11	2
230	2018-07-09	4
284	2017-07-22	3
228	2018-03-03	2
957	2018-10-17	5
770	2017-03-03	2
353	2018-05-08	5
437	2018-12-16	5
654	2018-09-17	5
140	2017-12-24	1
316	2018-02-09	4
290	2018-07-25	5
201	2018-03-16	4
666	2018-05-03	5
841	2018-01-22	3
235	2018-11-12	1
966	2018-12-07	2
483	2017-02-11	5
927	2017-08-20	4
41	2017-08-02	3
369	2017-06-24	2
153	2018-11-15	4
938	2018-03-04	4
727	2018-01-22	4
414	2018-05-16	1
561	2017-04-17	1
807	2018-01-22	3
828	2018-11-09	1
334	2018-06-24	5
255	2017-02-18	4
360	2018-09-12	3
595	2018-10-02	4
344	2017-10-22	3
145	2017-12-15	2
496	2018-04-25	5
42	2017-02-11	4
612	2017-10-11	3
743	2018-07-01	3
631	2018-01-30	3
737	2017-06-10	3
246	2017-12-10	2
636	2018-02-16	1
613	2018-02-06	3
844	2018-08-07	5
288	2018-03-08	5
697	2017-03-15	3
380	2018-09-24	1
881	2018-01-21	1
281	2018-06-28	5
874	2017-03-18	2
373	2018-07-04	4
923	2018-02-26	2
747	2018-07-13	1
800	2018-05-11	2
733	2017-04-21	1
367	2018-05-16	3
948	2017-03-31	4
772	2017-10-22	3
342	2018-02-28	3
4	2018-07-22	1
240	2017-12-18	4
950	2018-11-05	3
475	2018-06-22	1
135	2018-10-30	3
926	2018-06-21	2
216	2018-02-13	2
699	2017-01-26	3
782	2018-06-27	4
23	2017-08-28	5
57	2017-03-26	5
222	2017-03-19	3
674	2017-01-09	4
249	2018-02-27	2
659	2017-06-19	3
460	2017-10-08	3
269	2017-11-30	3
574	2018-05-05	2
129	2017-06-21	2
2	2018-01-31	5
449	2017-06-21	1
763	2018-11-27	4
207	2017-10-09	1
755	2018-10-31	2
916	2017-01-07	4
70	2018-11-06	4
315	2017-12-02	3
46	2017-11-10	4
729	2017-12-19	4
17	2018-02-05	3
900	2018-08-04	5
592	2018-11-04	3
247	2018-05-29	3
861	2017-02-02	5
99	2018-06-04	3
952	2018-02-26	2
922	2017-05-27	4
199	2018-07-22	4
163	2018-11-29	5
964	2018-08-18	4
910	2017-05-19	4
100	2017-09-19	1
239	2018-02-16	2
59	2017-09-26	2
596	2018-10-28	2
793	2017-02-19	4
898	2018-12-08	5
301	2017-06-23	2
403	2018-04-23	1
835	2017-05-06	4
385	2018-08-25	5
124	2017-02-17	2
86	2018-03-10	4
658	2017-09-29	2
557	2018-05-11	3
296	2017-07-18	5
579	2018-11-08	1
713	2017-04-17	1
649	2017-09-19	1
322	2017-08-31	4
418	2017-04-04	5
456	2017-08-04	2
389	2017-11-10	4
903	2018-11-09	2
261	2017-08-03	3
751	2018-10-17	4
127	2017-01-17	1
662	2017-10-08	5
661	2018-03-15	5
295	2017-04-03	2
56	2018-09-14	4
72	2018-10-23	3
461	2017-03-03	2
969	2018-12-05	4
480	2017-01-17	4
996	2018-11-12	4
259	2017-04-20	1
536	2018-12-09	2
576	2017-10-27	1
463	2017-09-25	3
313	2017-08-03	2
218	2018-10-05	3
718	2017-09-08	4
184	2018-05-06	1
653	2018-06-18	5
225	2018-10-24	4
251	2017-06-26	3
319	2017-03-06	2
66	2017-07-03	1
173	2017-10-25	2
289	2018-03-23	3
518	2018-01-05	5
8	2018-10-12	5
495	2018-07-17	3
339	2018-07-09	2
700	2017-04-05	1
107	2018-01-21	5
164	2018-04-28	1
798	2017-07-02	3
374	2018-08-25	3
77	2018-07-22	4
599	2018-09-05	4
512	2018-10-03	3
434	2017-03-24	2
735	2018-03-12	1
270	2017-12-01	2
345	2018-01-20	2
314	2017-08-24	1
65	2018-05-23	5
38	2018-03-23	3
120	2018-08-02	4
695	2018-05-17	5
32	2017-11-18	2
684	2017-06-20	3
63	2018-12-14	4
357	2018-05-18	3
337	2018-09-03	3
904	2018-11-22	4
326	2017-03-20	1
494	2017-08-18	2
492	2017-11-12	5
825	2018-02-08	1
664	2018-10-20	1
633	2017-08-25	1
363	2017-11-22	1
823	2018-12-02	1
931	2018-12-16	5
709	2018-07-23	5
609	2017-02-06	4
126	2017-07-30	2
125	2018-12-31	1
245	2018-03-30	4
71	2017-01-20	5
902	2018-10-08	2
680	2017-04-13	3
481	2017-09-30	2
604	2018-10-10	1
192	2018-09-29	4
683	2018-09-20	4
395	2018-09-11	4
73	2017-07-28	1
672	2017-07-18	4
885	2017-10-13	1
391	2018-07-11	1
726	2018-05-07	5
560	2017-02-01	1
897	2018-07-03	1
420	2017-10-23	5
491	2018-11-29	1
271	2017-06-13	1
309	2018-08-04	1
298	2017-06-20	1
408	2017-08-22	3
939	2017-09-02	1
831	2017-11-16	4
139	2018-04-21	2
742	2018-06-21	1
5	2017-01-17	3
880	2017-02-13	2
30	2017-08-02	2
905	2017-09-15	3
101	2017-05-12	5
730	2018-06-23	1
545	2017-01-22	5
802	2018-01-15	2
427	2017-12-09	3
53	2018-03-25	1
421	2018-11-27	1
388	2017-03-25	1
170	2017-11-04	1
348	2017-03-18	1
677	2018-11-19	1
423	2018-02-09	1
544	2018-09-29	1
286	2018-01-30	1
204	2018-01-03	1
487	2017-10-05	1
766	2017-07-16	1
868	2018-10-12	1
663	2018-04-22	1
455	2018-03-30	1
452	2017-08-19	1
454	2017-07-11	1
765	2018-09-16	1
80	2018-11-13	1
178	2017-11-07	1
383	2018-09-12	1
586	2018-11-29	1
530	2018-10-15	1
753	2017-09-04	1
394	2018-06-28	1
486	2018-03-16	1
90	2018-08-25	1
287	2018-08-11	1
744	2017-12-23	1
87	2017-09-03	1
930	2017-03-14	1
386	2017-12-14	1
83	2017-06-01	1
92	2018-04-17	1
878	2017-08-08	1
175	2017-02-09	1
21	2017-06-17	1
567	2017-11-14	1
311	2017-04-03	1
749	2018-11-25	1
18	2018-02-04	1
304	2018-08-28	1
202	2018-11-29	1
552	2017-05-08	1
750	2017-09-03	1
241	2017-10-19	1
982	2017-09-05	1
401	2017-02-17	1
212	2018-08-15	1
106	2017-04-07	1
892	2017-11-04	1
429	2017-01-14	1
299	2018-12-18	1
205	2018-03-28	1
641	2018-02-13	1
182	2017-02-17	1
413	2017-02-21	1
158	2018-04-27	1
843	2018-09-28	1
913	2018-04-02	1
965	2017-03-10	1
174	2018-04-13	1
276	2017-07-12	1
477	2017-09-05	1
121	2017-12-11	1
347	2017-03-01	1
332	2018-06-10	1
285	2017-02-04	1
439	2018-01-12	1
236	2017-07-27	1
888	2018-10-02	1
630	2017-11-02	1
852	2017-11-01	1
27	2018-04-25	1
651	2017-11-13	1
660	2017-08-08	1
669	2017-04-13	1
198	2017-11-25	1
327	2018-11-09	1
68	2018-08-24	1
759	2017-12-06	1
136	2018-09-29	1
119	2017-02-03	1
227	2017-11-30	1
805	2018-11-27	1
502	2018-05-02	1
294	2017-06-17	1
708	2018-04-15	1
220	2018-06-04	1
206	2018-02-24	1
417	2018-03-08	1
789	2017-01-23	1
435	2018-01-15	1
234	2018-10-03	1
918	2018-12-22	1
424	2018-12-01	1
358	2017-04-29	1
721	2018-01-30	1
297	2018-04-05	1
907	2017-09-01	1
901	2018-11-13	1
282	2017-11-10	1
31	2018-02-22	1
442	2017-01-13	1
130	2017-02-09	1
214	2018-10-31	1
485	2017-05-27	1
968	2017-06-01	1
689	2018-07-18	1
387	2018-05-12	1
838	2018-01-28	1
146	2017-12-13	1
626	2017-02-24	1
792	2018-07-19	1
195	2018-12-13	1
162	2018-12-10	1
400	2018-10-26	1
771	2018-03-03	1
323	2018-04-04	1
446	2018-01-09	1
862	2018-01-05	1
398	2017-10-08	1
24	2017-12-09	1
64	2018-10-19	1
886	2018-07-03	1
96	2018-03-29	1
867	2018-01-23	1
967	2017-09-22	1
325	2018-06-02	1
810	2018-01-26	1
563	2017-08-04	1
752	2017-08-23	1
705	2017-10-27	1
371	2018-02-27	1
624	2018-12-07	1
426	2018-01-28	1
331	2018-04-03	1
140	2017-12-24	1
235	2018-11-12	1
414	2018-05-16	1
561	2017-04-17	1
828	2018-11-09	1
636	2018-02-16	1
380	2018-09-24	1
881	2018-01-21	1
747	2018-07-13	1
733	2017-04-21	1
4	2018-07-22	1
475	2018-06-22	1
449	2017-06-21	1
207	2017-10-09	1
100	2017-09-19	1
403	2018-04-23	1
579	2018-11-08	1
713	2017-04-17	1
649	2017-09-19	1
127	2017-01-17	1
259	2017-04-20	1
576	2017-10-27	1
184	2018-05-06	1
66	2017-07-03	1
700	2017-04-05	1
164	2018-04-28	1
735	2018-03-12	1
314	2017-08-24	1
326	2017-03-20	1
825	2018-02-08	1
664	2018-10-20	1
633	2017-08-25	1
363	2017-11-22	1
823	2018-12-02	1
125	2018-12-31	1
604	2018-10-10	1
73	2017-07-28	1
885	2017-10-13	1
391	2018-07-11	1
560	2017-02-01	1
897	2018-07-03	1
491	2018-11-29	1
271	2017-06-13	1
309	2018-08-04	1
298	2017-06-20	1
939	2017-09-02	1
742	2018-06-21	1
730	2018-06-23	1
62	2018-07-23	4
49	2017-04-27	5
53	2018-03-25	1
421	2018-11-27	1
444	2018-11-21	2
388	2017-03-25	1
618	2017-07-14	2
855	2018-04-15	3
170	2017-11-04	1
156	2017-10-25	4
767	2018-01-25	3
704	2018-04-25	4
171	2018-03-27	5
166	2018-09-17	2
348	2017-03-18	1
995	2018-07-31	4
402	2017-09-17	3
498	2017-07-27	4
520	2018-08-20	3
320	2018-01-09	3
677	2018-11-19	1
620	2018-06-24	3
679	2017-12-19	2
423	2018-02-09	1
728	2017-02-19	4
131	2017-02-01	2
973	2017-03-19	5
544	2018-09-29	1
286	2018-01-30	1
848	2017-10-26	5
470	2018-01-16	5
204	2018-01-03	1
487	2017-10-05	1
98	2018-12-21	2
625	2017-10-01	2
766	2017-07-16	1
776	2018-07-25	4
849	2018-05-10	2
108	2018-06-02	2
540	2018-01-21	3
506	2018-10-29	4
187	2018-06-14	2
893	2018-11-04	5
670	2018-11-07	4
196	2017-06-03	5
589	2017-06-23	4
397	2017-02-19	3
450	2018-10-08	2
61	2017-06-15	2
992	2017-02-22	4
993	2018-05-24	3
994	2018-11-27	4
510	2018-10-13	2
784	2017-04-21	4
580	2017-06-24	3
917	2017-11-14	4
114	2018-03-22	3
868	2018-10-12	1
663	2018-04-22	1
806	2018-01-02	3
350	2017-11-14	3
882	2018-09-18	2
819	2018-07-13	5
7	2018-04-08	5
691	2017-02-18	2
455	2018-03-30	1
89	2017-11-30	5
167	2018-04-03	5
581	2018-02-09	2
722	2018-01-31	4
111	2017-12-15	5
452	2017-08-19	1
889	2017-12-26	5
469	2018-11-20	2
522	2017-08-28	5
454	2017-07-11	1
899	2017-09-07	2
690	2018-09-24	5
765	2018-09-16	1
768	2018-06-04	3
80	2018-11-13	1
896	2017-01-04	4
547	2018-11-08	5
303	2017-09-12	4
178	2017-11-07	1
52	2017-10-14	5
944	2018-12-19	5
39	2017-03-19	3
217	2018-02-21	5
657	2017-04-10	2
504	2018-05-20	4
489	2018-05-13	4
814	2018-06-18	2
519	2018-12-06	2
383	2018-09-12	1
976	2017-06-04	5
839	2017-02-06	2
224	2018-10-08	5
351	2018-03-27	5
51	2017-10-07	4
586	2018-11-29	1
188	2017-11-28	2
263	2018-06-28	2
186	2018-10-07	4
675	2018-01-09	5
989	2018-08-24	5
530	2018-10-15	1
1	2018-10-02	5
932	2017-11-18	2
590	2017-02-05	2
753	2017-09-04	1
6	2018-07-27	5
714	2017-06-23	5
928	2017-04-21	2
262	2018-11-12	5
279	2017-08-30	4
208	2018-02-07	2
933	2018-08-01	2
648	2017-02-19	4
150	2018-11-01	5
509	2017-11-08	5
394	2018-06-28	1
955	2017-03-09	5
486	2018-03-16	1
553	2018-02-15	2
250	2018-10-01	5
90	2018-08-25	1
25	2018-10-21	2
921	2017-06-30	5
533	2017-02-05	5
328	2018-07-13	5
720	2017-05-05	3
830	2018-03-31	3
829	2018-01-02	4
734	2018-04-01	4
43	2017-11-05	2
627	2018-06-02	2
305	2018-08-24	3
378	2018-03-07	2
183	2017-09-06	5
745	2018-08-26	3
934	2017-05-31	2
611	2018-03-17	4
915	2017-10-05	4
287	2018-08-11	1
744	2017-12-23	1
87	2017-09-03	1
638	2018-10-02	4
91	2018-01-26	5
571	2018-03-08	3
930	2017-03-14	1
324	2018-07-01	2
688	2017-09-21	4
671	2018-12-25	2
386	2017-12-14	1
548	2018-06-25	3
803	2017-07-14	3
826	2017-04-01	5
248	2017-11-08	3
812	2017-05-24	3
884	2017-09-08	2
600	2017-06-07	5
542	2018-08-24	2
83	2017-06-01	1
137	2017-06-19	2
570	2017-11-28	2
562	2017-10-13	2
448	2017-02-23	5
50	2017-07-03	2
610	2018-05-12	5
961	2017-09-28	3
308	2017-01-14	4
642	2017-08-17	3
511	2017-02-20	3
924	2018-05-03	3
919	2018-05-02	5
524	2018-12-17	2
92	2018-04-17	1
69	2018-12-22	5
472	2018-08-18	2
330	2017-11-03	5
878	2017-08-08	1
908	2017-12-30	5
640	2018-11-29	3
144	2017-03-18	3
787	2017-09-27	4
777	2018-03-15	2
877	2018-01-24	5
977	2017-11-13	3
912	2018-12-19	2
478	2017-03-11	5
603	2017-06-16	2
543	2017-04-20	3
175	2017-02-09	1
583	2017-01-07	3
516	2017-07-12	2
200	2018-04-22	3
986	2017-06-09	4
21	2017-06-17	1
459	2018-07-16	4
123	2018-05-21	4
567	2017-11-14	1
142	2018-10-04	5
725	2017-12-23	3
311	2017-04-03	1
431	2018-05-24	5
231	2018-05-25	5
428	2017-02-01	5
749	2018-11-25	1
18	2018-02-04	1
941	2018-06-01	5
479	2018-09-29	3
773	2018-03-01	2
783	2018-12-24	3
10	2018-05-08	3
304	2018-08-28	1
47	2017-01-01	3
813	2017-02-19	5
254	2018-10-04	5
837	2017-08-30	2
118	2017-08-04	3
152	2018-03-28	4
942	2018-03-21	5
202	2018-11-29	1
433	2018-05-13	2
552	2017-05-08	1
484	2018-04-25	3
750	2017-09-03	1
191	2018-10-10	4
93	2017-12-03	5
241	2017-10-19	1
740	2017-06-11	4
132	2017-03-29	4
982	2017-09-05	1
401	2017-02-17	1
974	2018-06-04	5
212	2018-08-15	1
40	2018-06-21	5
103	2018-04-08	5
370	2018-01-05	3
551	2018-07-05	2
275	2018-06-27	3
105	2017-04-12	4
274	2018-01-16	4
1000	2018-01-29	2
791	2017-07-11	4
238	2017-05-22	5
36	2017-06-15	5
629	2017-02-07	4
531	2017-07-08	3
972	2017-08-12	3
500	2018-01-09	4
864	2017-02-15	4
79	2017-03-27	5
597	2018-12-11	4
746	2018-10-05	4
845	2018-05-03	5
945	2018-08-28	4
106	2017-04-07	1
376	2017-02-06	3
476	2018-05-16	3
537	2018-04-06	5
979	2018-04-16	5
650	2017-12-29	5
194	2017-09-14	5
265	2018-09-25	4
74	2018-09-20	5
892	2017-11-04	1
233	2018-08-19	5
635	2017-01-25	4
535	2017-12-15	3
639	2018-09-30	2
804	2018-07-13	3
474	2017-10-20	4
429	2017-01-14	1
299	2018-12-18	1
863	2017-04-08	3
335	2017-10-06	3
205	2018-03-28	1
821	2017-03-14	4
366	2017-11-24	3
641	2018-02-13	1
340	2017-12-24	4
343	2017-07-04	5
702	2017-03-25	3
312	2017-06-06	3
182	2017-02-17	1
257	2017-04-10	4
413	2017-02-21	1
148	2017-01-26	3
318	2018-01-05	3
971	2018-11-03	2
158	2018-04-27	1
869	2017-07-25	4
843	2018-09-28	1
462	2018-09-17	4
197	2017-01-13	3
913	2018-04-02	1
965	2017-03-10	1
872	2018-06-24	5
764	2017-06-05	3
833	2017-10-06	4
471	2018-08-26	4
404	2017-10-11	2
174	2018-04-13	1
95	2017-08-15	2
141	2018-05-16	3
276	2017-07-12	1
477	2017-09-05	1
809	2018-06-28	5
20	2018-10-29	2
112	2018-02-12	3
879	2018-05-19	3
149	2018-11-10	2
121	2017-12-11	1
347	2017-03-01	1
55	2018-03-19	3
832	2017-07-06	5
473	2017-11-27	5
332	2018-06-10	1
160	2017-04-18	5
22	2017-12-12	5
859	2018-09-17	4
396	2017-09-25	5
558	2017-04-26	5
866	2017-07-15	5
712	2018-12-27	5
359	2018-10-13	5
333	2017-07-08	5
781	2018-04-01	4
29	2017-11-16	5
285	2017-02-04	1
739	2017-09-29	4
439	2018-01-12	1
236	2017-07-27	1
215	2017-07-03	5
505	2018-04-25	2
11	2017-02-10	3
794	2017-11-30	5
614	2018-05-05	5
3	2017-01-12	5
445	2018-12-08	3
801	2017-02-04	4
888	2018-10-02	1
779	2017-10-08	4
419	2017-11-05	2
407	2017-10-20	3
94	2017-07-02	3
412	2017-10-29	4
133	2017-11-09	5
82	2018-06-22	5
117	2017-09-09	3
538	2017-09-11	4
406	2018-02-07	2
587	2017-05-20	3
268	2017-12-31	3
946	2017-04-11	4
724	2017-08-22	3
556	2017-07-06	5
243	2017-02-02	4
307	2017-11-02	3
630	2017-11-02	1
628	2018-06-26	4
539	2017-07-05	5
258	2017-08-23	5
409	2018-01-07	3
852	2017-11-01	1
19	2017-11-07	3
797	2018-02-15	2
27	2018-04-25	1
988	2017-09-17	5
871	2017-12-21	3
808	2018-06-02	5
834	2018-04-16	4
651	2017-11-13	1
438	2017-05-06	3
660	2017-08-08	1
115	2018-01-26	4
762	2018-02-23	3
501	2017-09-25	2
669	2017-04-13	1
341	2017-04-04	5
405	2017-11-19	5
694	2018-08-23	3
873	2018-05-01	4
198	2017-11-25	1
329	2017-04-07	4
84	2018-05-05	3
354	2017-02-01	2
252	2017-06-22	5
453	2017-10-24	2
616	2017-05-22	4
488	2018-01-15	3
122	2018-05-10	5
327	2018-11-09	1
528	2018-09-09	2
717	2017-04-27	2
856	2017-05-12	4
416	2017-05-17	5
68	2018-08-24	1
929	2018-01-16	2
840	2018-11-13	5
85	2018-05-07	3
759	2017-12-06	1
155	2017-04-14	2
824	2018-07-17	2
909	2017-09-17	4
736	2017-09-08	3
754	2017-10-27	2
608	2018-02-05	2
786	2017-12-25	3
451	2017-06-26	5
644	2018-11-12	4
136	2018-09-29	1
119	2017-02-03	1
582	2018-03-13	3
619	2018-07-03	3
719	2017-03-11	4
937	2017-04-28	4
911	2017-02-01	3
850	2017-05-29	2
818	2018-02-22	5
788	2018-06-09	3
81	2017-12-24	2
529	2017-07-09	3
219	2018-03-06	2
774	2017-10-17	2
227	2017-11-30	1
943	2018-01-22	5
805	2018-11-27	1
954	2017-09-28	4
502	2018-05-02	1
226	2017-06-14	4
906	2018-04-26	5
13	2017-06-01	2
147	2018-10-09	2
707	2017-12-06	5
615	2017-06-26	3
294	2017-06-17	1
710	2018-03-15	4
189	2017-03-10	2
513	2018-07-17	2
983	2018-11-15	3
352	2018-09-24	5
870	2018-06-19	3
457	2017-06-14	4
555	2018-07-16	5
554	2018-09-21	2
67	2017-12-24	5
527	2017-02-21	5
895	2018-02-03	5
940	2017-07-22	2
656	2017-10-08	2
584	2018-11-21	4
708	2018-04-15	1
154	2018-11-21	2
799	2018-09-09	2
673	2017-12-06	3
637	2017-01-08	5
161	2018-02-04	3
159	2018-06-19	3
211	2018-12-02	2
220	2018-06-04	1
761	2017-04-10	4
696	2018-11-13	2
685	2017-06-20	3
292	2017-03-07	4
128	2017-06-02	5
842	2018-05-08	5
790	2017-04-04	4
732	2018-11-26	4
532	2017-03-02	5
601	2017-07-28	4
169	2018-01-30	2
591	2018-02-06	5
206	2018-02-24	1
569	2017-10-31	2
177	2017-03-04	4
278	2018-11-09	2
143	2017-01-02	5
817	2018-03-20	3
417	2018-03-08	1
242	2017-01-24	3
88	2018-07-08	3
559	2018-07-09	2
393	2018-04-17	2
362	2017-03-05	3
422	2018-07-16	3
260	2017-04-29	3
468	2017-02-14	5
789	2017-01-23	1
785	2018-09-25	5
435	2018-01-15	1
33	2017-08-01	5
578	2017-01-27	3
338	2018-01-07	5
936	2018-10-30	5
466	2017-01-27	5
234	2018-10-03	1
14	2017-06-18	2
15	2018-07-01	3
701	2017-12-12	5
568	2017-08-10	3
918	2018-12-22	1
541	2018-11-04	5
253	2017-09-30	5
424	2018-12-01	1
361	2018-06-08	2
358	2017-04-29	1
721	2018-01-30	1
266	2018-09-20	2
858	2017-01-31	3
634	2017-09-11	4
390	2018-07-28	4
741	2018-05-05	5
606	2017-10-24	2
297	2018-04-05	1
820	2018-06-30	4
865	2017-06-23	3
499	2018-02-05	3
302	2017-02-25	5
990	2018-01-09	4
731	2017-04-26	3
970	2018-12-04	4
693	2018-02-24	3
907	2017-09-01	1
901	2018-11-13	1
716	2018-06-18	4
577	2017-11-21	4
321	2018-04-15	4
26	2018-03-31	2
282	2017-11-10	1
256	2017-03-19	4
490	2017-10-06	3
60	2018-06-09	5
692	2018-01-27	5
31	2018-02-22	1
566	2018-06-27	2
165	2018-05-28	5
493	2017-06-28	3
138	2018-04-11	2
432	2018-09-24	4
465	2017-01-03	4
436	2017-03-05	5
655	2017-11-04	2
34	2017-12-26	2
134	2017-12-19	3
890	2018-03-05	2
176	2017-05-25	4
78	2017-10-04	4
534	2017-11-20	3
960	2018-08-01	4
210	2017-09-18	4
443	2018-01-11	5
349	2018-08-02	2
617	2017-05-30	2
682	2017-12-01	4
442	2017-01-13	1
375	2018-04-08	5
44	2017-06-17	4
399	2018-03-13	4
48	2018-05-03	5
130	2017-02-09	1
28	2017-03-06	2
827	2018-07-04	3
698	2017-01-20	5
336	2018-04-14	2
157	2018-12-07	2
368	2018-09-27	2
229	2017-09-30	3
300	2017-11-09	3
9	2017-02-19	3
997	2017-08-19	5
497	2018-09-24	4
775	2018-04-13	3
75	2018-06-30	5
935	2018-08-27	3
515	2018-08-06	5
514	2017-10-25	5
482	2017-03-29	4
291	2018-01-21	2
564	2017-01-11	4
214	2018-10-31	1
410	2018-02-15	4
392	2018-06-16	3
379	2018-10-29	5
975	2018-05-14	5
748	2018-04-13	3
203	2018-05-09	4
35	2017-02-23	2
104	2017-01-12	4
949	2017-07-08	5
894	2018-02-11	3
113	2018-08-26	2
999	2017-09-01	2
857	2017-08-28	2
364	2018-03-22	2
769	2018-06-23	2
485	2017-05-27	1
968	2017-06-01	1
602	2018-03-11	5
665	2017-01-28	5
16	2017-06-10	2
411	2017-10-24	3
430	2017-12-25	4
467	2018-12-02	3
689	2018-07-18	1
97	2017-07-11	2
387	2018-05-12	1
678	2017-09-17	4
356	2017-04-29	2
815	2018-02-01	4
963	2018-11-13	5
525	2017-08-21	2
458	2018-04-22	5
213	2017-07-10	4
838	2018-01-28	1
384	2017-01-22	2
146	2017-12-13	1
565	2017-06-15	5
508	2018-05-26	5
573	2017-12-08	2
585	2018-03-20	5
847	2018-12-15	4
546	2018-04-02	3
816	2018-12-14	5
346	2017-01-04	2
572	2018-10-30	5
667	2018-12-12	4
984	2018-02-10	5
980	2018-01-11	5
293	2017-06-08	4
854	2017-07-09	5
958	2018-04-04	3
626	2017-02-24	1
605	2017-04-19	3
209	2018-07-20	2
851	2018-01-23	3
12	2018-10-12	2
757	2018-09-13	5
172	2017-05-10	2
792	2018-07-19	1
686	2017-03-02	3
425	2018-12-29	4
795	2017-05-29	4
168	2018-02-07	5
947	2017-07-25	3
102	2018-02-13	2
914	2018-11-08	3
846	2018-01-31	3
237	2017-07-06	3
190	2017-06-27	2
195	2018-12-13	1
521	2018-06-30	2
58	2017-08-27	5
162	2018-12-10	1
593	2017-07-22	4
400	2018-10-26	1
223	2017-05-28	3
441	2018-02-11	5
622	2018-02-18	3
771	2018-03-03	1
37	2017-03-31	2
464	2018-10-26	5
317	2018-07-31	4
180	2018-01-05	2
632	2017-10-12	3
310	2018-04-25	2
45	2017-03-13	3
382	2017-10-15	2
517	2017-03-17	3
811	2017-06-13	2
991	2017-02-19	5
323	2018-04-04	1
891	2017-01-17	5
446	2018-01-09	1
760	2018-01-07	3
862	2018-01-05	1
998	2017-04-11	3
985	2018-09-07	2
621	2017-06-17	4
588	2017-01-30	5
715	2018-05-24	4
920	2017-11-11	3
623	2017-06-15	5
987	2017-04-12	3
738	2017-06-22	4
398	2017-10-08	1
703	2017-09-12	2
676	2017-07-26	4
647	2018-11-07	5
646	2017-07-30	2
179	2018-11-16	2
277	2017-09-24	2
264	2017-05-19	5
381	2018-09-19	2
116	2018-10-22	2
76	2017-09-08	4
24	2017-12-09	1
365	2017-05-20	3
185	2017-12-30	3
64	2018-10-19	1
886	2018-07-03	1
860	2017-01-04	2
652	2018-03-11	2
96	2018-03-29	1
853	2017-03-13	2
796	2017-07-29	2
953	2017-03-02	4
867	2018-01-23	1
221	2018-06-10	5
822	2017-10-07	2
355	2017-12-02	5
645	2017-12-21	5
232	2018-07-30	3
883	2018-09-01	5
306	2017-02-08	5
967	2017-09-22	1
951	2017-09-18	2
273	2018-07-23	2
887	2017-10-11	3
110	2018-05-24	2
523	2018-11-14	4
925	2017-07-31	3
377	2017-03-15	2
981	2018-11-29	3
549	2018-10-15	5
325	2018-06-02	1
810	2018-01-26	1
151	2017-07-01	3
563	2017-08-04	1
876	2018-10-14	5
280	2017-07-04	2
752	2017-08-23	1
272	2017-04-08	4
607	2017-11-07	3
372	2017-05-30	4
244	2018-01-25	2
267	2017-04-22	5
575	2018-06-27	2
550	2017-05-14	3
643	2018-08-15	5
705	2017-10-27	1
193	2017-11-17	4
956	2017-06-09	2
959	2017-03-03	3
54	2018-05-15	2
756	2017-03-23	5
962	2018-01-14	5
594	2018-08-15	3
780	2018-09-15	4
415	2018-10-21	4
447	2018-09-20	3
875	2018-06-25	3
723	2018-02-27	3
526	2017-09-02	5
371	2018-02-27	1
598	2017-06-15	3
503	2017-11-06	4
668	2017-01-05	3
978	2017-05-24	2
109	2017-02-27	5
758	2017-08-07	3
624	2018-12-07	1
687	2017-11-23	5
507	2017-09-22	3
283	2017-05-09	4
836	2018-09-30	5
711	2017-04-23	4
426	2018-01-28	1
440	2018-03-31	4
681	2017-11-07	2
706	2017-11-02	2
778	2018-07-31	2
331	2018-04-03	1
181	2017-02-11	2
230	2018-07-09	4
284	2017-07-22	3
228	2018-03-03	2
957	2018-10-17	5
770	2017-03-03	2
353	2018-05-08	5
437	2018-12-16	5
654	2018-09-17	5
140	2017-12-24	1
316	2018-02-09	4
290	2018-07-25	5
201	2018-03-16	4
666	2018-05-03	5
841	2018-01-22	3
235	2018-11-12	1
966	2018-12-07	2
483	2017-02-11	5
927	2017-08-20	4
41	2017-08-02	3
369	2017-06-24	2
153	2018-11-15	4
938	2018-03-04	4
727	2018-01-22	4
414	2018-05-16	1
561	2017-04-17	1
807	2018-01-22	3
828	2018-11-09	1
334	2018-06-24	5
255	2017-02-18	4
360	2018-09-12	3
595	2018-10-02	4
344	2017-10-22	3
145	2017-12-15	2
496	2018-04-25	5
42	2017-02-11	4
612	2017-10-11	3
743	2018-07-01	3
631	2018-01-30	3
737	2017-06-10	3
246	2017-12-10	2
636	2018-02-16	1
613	2018-02-06	3
844	2018-08-07	5
288	2018-03-08	5
697	2017-03-15	3
380	2018-09-24	1
881	2018-01-21	1
281	2018-06-28	5
874	2017-03-18	2
373	2018-07-04	4
923	2018-02-26	2
747	2018-07-13	1
800	2018-05-11	2
733	2017-04-21	1
367	2018-05-16	3
948	2017-03-31	4
772	2017-10-22	3
342	2018-02-28	3
4	2018-07-22	1
240	2017-12-18	4
950	2018-11-05	3
475	2018-06-22	1
135	2018-10-30	3
926	2018-06-21	2
216	2018-02-13	2
699	2017-01-26	3
782	2018-06-27	4
23	2017-08-28	5
57	2017-03-26	5
222	2017-03-19	3
674	2017-01-09	4
249	2018-02-27	2
659	2017-06-19	3
460	2017-10-08	3
269	2017-11-30	3
574	2018-05-05	2
129	2017-06-21	2
2	2018-01-31	5
449	2017-06-21	1
763	2018-11-27	4
207	2017-10-09	1
755	2018-10-31	2
916	2017-01-07	4
70	2018-11-06	4
315	2017-12-02	3
46	2017-11-10	4
729	2017-12-19	4
17	2018-02-05	3
900	2018-08-04	5
592	2018-11-04	3
247	2018-05-29	3
861	2017-02-02	5
99	2018-06-04	3
952	2018-02-26	2
922	2017-05-27	4
199	2018-07-22	4
163	2018-11-29	5
964	2018-08-18	4
910	2017-05-19	4
100	2017-09-19	1
239	2018-02-16	2
59	2017-09-26	2
596	2018-10-28	2
793	2017-02-19	4
898	2018-12-08	5
301	2017-06-23	2
403	2018-04-23	1
835	2017-05-06	4
385	2018-08-25	5
124	2017-02-17	2
86	2018-03-10	4
658	2017-09-29	2
557	2018-05-11	3
296	2017-07-18	5
579	2018-11-08	1
713	2017-04-17	1
649	2017-09-19	1
322	2017-08-31	4
418	2017-04-04	5
456	2017-08-04	2
389	2017-11-10	4
903	2018-11-09	2
261	2017-08-03	3
751	2018-10-17	4
127	2017-01-17	1
662	2017-10-08	5
661	2018-03-15	5
295	2017-04-03	2
56	2018-09-14	4
72	2018-10-23	3
461	2017-03-03	2
969	2018-12-05	4
480	2017-01-17	4
996	2018-11-12	4
259	2017-04-20	1
536	2018-12-09	2
576	2017-10-27	1
463	2017-09-25	3
313	2017-08-03	2
218	2018-10-05	3
718	2017-09-08	4
184	2018-05-06	1
653	2018-06-18	5
225	2018-10-24	4
251	2017-06-26	3
319	2017-03-06	2
66	2017-07-03	1
173	2017-10-25	2
289	2018-03-23	3
518	2018-01-05	5
8	2018-10-12	5
495	2018-07-17	3
339	2018-07-09	2
700	2017-04-05	1
107	2018-01-21	5
164	2018-04-28	1
798	2017-07-02	3
374	2018-08-25	3
77	2018-07-22	4
599	2018-09-05	4
512	2018-10-03	3
434	2017-03-24	2
735	2018-03-12	1
270	2017-12-01	2
345	2018-01-20	2
314	2017-08-24	1
65	2018-05-23	5
38	2018-03-23	3
120	2018-08-02	4
695	2018-05-17	5
32	2017-11-18	2
684	2017-06-20	3
63	2018-12-14	4
357	2018-05-18	3
337	2018-09-03	3
904	2018-11-22	4
326	2017-03-20	1
494	2017-08-18	2
492	2017-11-12	5
825	2018-02-08	1
664	2018-10-20	1
633	2017-08-25	1
363	2017-11-22	1
823	2018-12-02	1
931	2018-12-16	5
709	2018-07-23	5
609	2017-02-06	4
126	2017-07-30	2
125	2018-12-31	1
245	2018-03-30	4
71	2017-01-20	5
902	2018-10-08	2
680	2017-04-13	3
481	2017-09-30	2
604	2018-10-10	1
192	2018-09-29	4
683	2018-09-20	4
395	2018-09-11	4
73	2017-07-28	1
672	2017-07-18	4
885	2017-10-13	1
391	2018-07-11	1
726	2018-05-07	5
560	2017-02-01	1
897	2018-07-03	1
420	2017-10-23	5
491	2018-11-29	1
271	2017-06-13	1
309	2018-08-04	1
298	2017-06-20	1
408	2017-08-22	3
939	2017-09-02	1
831	2017-11-16	4
139	2018-04-21	2
742	2018-06-21	1
5	2017-01-17	3
880	2017-02-13	2
30	2017-08-02	2
905	2017-09-15	3
101	2017-05-12	5
730	2018-06-23	1
545	2017-01-22	5
802	2018-01-15	2
427	2017-12-09	3
\.


--
-- Data for Name: tr; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.tr (nam, kol) FROM stdin;
A	1
A	1
A	1
A	2
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.users (name) FROM stdin;
11
11
\.


--
-- Data for Name: users_info_plus; Type: TABLE DATA; Schema: public; Owner: alexey
--

COPY public.users_info_plus (doc) FROM stdin;
[{"user_id": 1, "family": 1},\n  {"user_id": 2, "family": 1}, {"user_id": 3, "family": 0}]
\.


--
-- Name: base base_pkey; Type: CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.base
    ADD CONSTRAINT base_pkey PRIMARY KEY (id);


--
-- Name: copy_orders copy_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.copy_orders
    ADD CONSTRAINT copy_orders_pkey PRIMARY KEY (order_id);


--
-- Name: customers customers_contact_phone_key; Type: CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_contact_phone_key UNIQUE (contact_phone);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (userr_id);


--
-- Name: managers managers_acces_card_key; Type: CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.managers
    ADD CONSTRAINT managers_acces_card_key UNIQUE (acces_card);


--
-- Name: managers managers_contact_phone_key; Type: CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.managers
    ADD CONSTRAINT managers_contact_phone_key UNIQUE (contact_phone);


--
-- Name: managers managers_email_key; Type: CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.managers
    ADD CONSTRAINT managers_email_key UNIQUE (email);


--
-- Name: managers managers_pkey; Type: CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.managers
    ADD CONSTRAINT managers_pkey PRIMARY KEY (manager_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: myemployees pk_employeeid; Type: CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.myemployees
    ADD CONSTRAINT pk_employeeid PRIMARY KEY (employeeid);


--
-- Name: products products_articul_key; Type: CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_articul_key UNIQUE (articul);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: sub sub_pkey; Type: CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.sub
    ADD CONSTRAINT sub_pkey PRIMARY KEY (id);


--
-- Name: a t_user; Type: TRIGGER; Schema: public; Owner: alexey
--

CREATE TRIGGER t_user AFTER INSERT OR DELETE OR UPDATE ON public.a FOR EACH ROW EXECUTE FUNCTION public.work9();


--
-- Name: orders t_user; Type: TRIGGER; Schema: public; Owner: alexey
--

CREATE TRIGGER t_user AFTER INSERT OR DELETE OR UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.work9();


--
-- Name: wr10 wk10; Type: TRIGGER; Schema: public; Owner: alexey
--

CREATE TRIGGER wk10 INSTEAD OF INSERT OR DELETE OR UPDATE ON public.wr10 FOR EACH ROW EXECUTE FUNCTION public.work10();


--
-- Name: copy_orders copy_orders_cust_cust_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.copy_orders
    ADD CONSTRAINT copy_orders_cust_cust_id_fkey FOREIGN KEY (cust_cust_id) REFERENCES public.customers(userr_id);


--
-- Name: copy_orders copy_orders_man_man_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.copy_orders
    ADD CONSTRAINT copy_orders_man_man_id_fkey FOREIGN KEY (man_man_id) REFERENCES public.managers(manager_id);


--
-- Name: copy_orders copy_orders_prod_prod_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.copy_orders
    ADD CONSTRAINT copy_orders_prod_prod_id_fkey FOREIGN KEY (prod_prod_id) REFERENCES public.products(product_id);


--
-- Name: orders orders_cust_cust_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_cust_cust_id_fkey FOREIGN KEY (cust_cust_id) REFERENCES public.customers(userr_id);


--
-- Name: orders orders_man_man_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_man_man_id_fkey FOREIGN KEY (man_man_id) REFERENCES public.managers(manager_id);


--
-- Name: orders orders_prod_prod_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_prod_prod_id_fkey FOREIGN KEY (prod_prod_id) REFERENCES public.products(product_id);


--
-- Name: sub sub_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: alexey
--

ALTER TABLE ONLY public.sub
    ADD CONSTRAINT sub_id_fkey FOREIGN KEY (id) REFERENCES public.base(id);


--
-- PostgreSQL database dump complete
--

