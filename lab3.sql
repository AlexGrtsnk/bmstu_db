
-- work 1
CREATE OR REPLACE FUNCTION work1(i varchar) RETURNS integer AS $$
        BEGIN
                RETURN (select min(price) from products where category like i);
                --RETURN i + 1;
        END;
$$ LANGUAGE plpgsql;

select * from work1('%cat 1%')

-- work 2
CREATE OR REPLACE FUNCTION work2() RETURNS TABLE(price1 int, kolvo int) as $$
    BEGIN
    return QUERY ( SELECT price, qua from orders inner join products p on p.product_id = orders.prod_prod_id);
    END;
$$ LANGUAGE plpgsql;

select * from work2()

-- no work 3

-- no work 4
CREATE OR REPLACE FUNCTION work4() RETURNS TABLE(ommmm int, shippingnn date, statunns int)
as $$
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
$$ LANGUAGE plpgsql;


select * from work4();

-- work 5
CREATE or replace PROCEDURE work5(a integer, b integer)
LANGUAGE SQL
AS $$
INSERT INTO temp VALUES (a);
INSERT INTO temp VALUES (b);
$$;

CALL work5(1, 2);

-- work 6

create or replace procedure work6()
language plpgsql
as $$
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

call work6();




-- work 7

cREATE OR REPLACE procedure work7(numeric)
 AS
   $BODY$
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
   $BODY$
     LANGUAGE 'plpgsql';
call work7(2);



-- no work 8





-- work 9
CREATE TRIGGER t_user
AFTER INSERT OR UPDATE OR DELETE ON orders FOR EACH ROW EXECUTE PROCEDURE work9();



CREATE OR REPLACE FUNCTION work9() RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

insert into orders values (1001,'2018-01-29','moscow, ulica 1000',2,'2018-08-16 00:00:00.000000','source1000',317,292,843,96);
);

delete from orders where order_id = 1001;



-- work 10
CREATE VIEW wr10 AS
    SELECT p.product_id FROM orders o
    JOIN products p ON p.product_id = o.prod_prod_id;


CREATE OR REPLACE FUNCTION work10()
  RETURNS trigger AS
$$
BEGIN
    IF TG_OP = 'DELETE' THEN
        DELETE FROM orders WHERE prod_prod_id = OLD.product_id;
        DELETE FROM products WHERE product_id = OLD.product_id;
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER wk10
    INSTEAD OF INSERT OR UPDATE OR DELETE ON
      wr10 FOR EACH ROW
      EXECUTE PROCEDURE work10();

insert into orders values (1001,'2018-01-29','moscow, ulica 1000',2,'2018-08-16 00:00:00.000000','source1000',1001,292,843,96);
);

insert into products values (1001,101001,'product 1001','cat 990',1202,'2018-10-18',6698);

select * from wr10;

delete from wr10 where product_id = 1001;

