CREATE TRIGGER create_reservation AFTER INSERT ON SHOPPING_CART
FOR EACH ROW
DECLARE
    grand_total FLOAT;
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    SELECT SUM(:NEW.QUANTITY * FOOD.FOOD_PRICE) INTO grand_total
        FROM SHOPPING_CART
        INNER JOIN FOOD ON :NEW.FOOD_ID = FOOD.FOOD_ID
        WHERE SHOPPING_CART_ID = :NEW.SHOPPING_CART_ID;
    --INSERT INTO DOES_IT_WORK(TOTAL)
    --VALUES(GRAND_TOTAL);
    INSERT INTO RESERVATION(SHOPPING_CART_ID, NET_AMOUNT, TOTAL_AMOUNT, ORDER_TIME, RESERVATION_STATUS)
    VALUES(15, grand_total, grand_total*1.06, CURRENT_TIMESTAMP, '''SUBMITTED''');
    COMMIT;
END;
/

CREATE TRIGGER finalize_order AFTER UPDATE ON RESERVATION
FOR EACH ROW
BEGIN
    IF :NEW.PAYMENTS_DETAILS IS NOT NULL AND :NEW.ORDER_DETAILS IS NOT NULL THEN
      UPDATE RESERVATION
          SET ORDER_STATUS = '''COMPLETE'''
          WHERE RESERVATION_ID = :NEW.RESERVATION_ID;
    END IF;
END;
/

CREATE TRIGGER archive_order AFTER UPDATE ON RESERVATION
FOR EACH ROW
BEGIN
    IF :NEW.ORDER_STATUS = '''COMPLETE''' THEN
      INSERT INTO ORDER_HISTORY(RESERVATION_ID)
      VALUES(:NEW.RESERVATION_ID);
    END IF;
END;
/
