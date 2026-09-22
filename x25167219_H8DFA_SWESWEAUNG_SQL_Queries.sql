-- =============================================================================
-- PHASE 3
-- Student: SWE SWE AUNG
-- Student ID: x25167219
-- Domain: Transportation and Logistics System
-- =============================================================================

-- The complete Task 4-6 setup is contained in:
-- x25167219_H8DFA_SWESWEAUNG_DatabaseSetup.sql

-- =============================================================================
-- TASK 7: UPDATE QUERY
-- Business question: Identify unpaid invoices that become overdue after their due date.
-- =============================================================================
BEGIN;
UPDATE Invoice
SET    payment_status = 'Overdue'
WHERE  payment_status = 'Unpaid'
  AND  due_date < CURRENT_DATE
RETURNING invoice_id, shipment_id, due_date, payment_status;
ROLLBACK;

-- =============================================================================
-- TASK 8: DELETE QUERY
-- Business question: Remove old cancellations that is no longer needed for futher operation.
-- =============================================================================
BEGIN;
DELETE FROM Orders o
WHERE o.order_status = 'Cancelled'
  AND NOT EXISTS (SELECT 1 FROM SHIPMENT AS s WHERE o.order_id=s.order_id)
RETURNING o.order_id, o.customer_id, o.order_date, o.order_status;
ROLLBACK;

-- =============================================================================
-- TASK 9: FILTERING AND SORTING QUERY
-- Business question: Which invoices are still outstanding, soonest due first?
-- =============================================================================

SELECT
    invoice_id,
    shipment_id,
    due_date,
    total_amount,
	payment_status
FROM Invoice
WHERE payment_status='Overdue'
ORDER BY due_date DESC;


-- =============================================================================
-- TASK 10: AGGREGATION QUERY
-- Business question: Summarise the overall shipment position.
-- =============================================================================

SELECT
    COUNT(*) AS Total_Shipments,
    COUNT(*) FILTER (WHERE shipment_status = 'Delivered') AS Delivered_Shipments,
    COUNT(*) FILTER (WHERE actual_delivery_date IS NULL AND shipment_status<> 'Failed') AS Not_delivered_yet_Shipments,
	COUNT(*) FILTER (WHERE actual_delivery_date > expected_delivery_date) AS Late_Delivered_Shipments,
    ROUND(AVG(actual_delivery_date - shipment_date)
          FILTER (WHERE actual_delivery_date IS NOT NULL), 2) AS Avg_Delivered_days
FROM shipment;


-- =============================================================================
-- TASK 11: GROUPING QUERY
-- Business question: How is shipment delivered across transport types,
-- and how many in each type have been delivered?
-- =============================================================================

SELECT
    transportation_type, COUNT(*) AS shipments,
    COUNT(*) FILTER (WHERE shipment_status = 'Delivered') AS delivered
FROM Shipment
GROUP BY transportation_type
ORDER BY shipments DESC;


-- =============================================================================
-- TASK 12: PATTERN MATCHING QUERY
-- Business question: Find every Insulin product in the medicine.
-- =============================================================================
SELECT
    medicine_id,
    medicine_name,
	medicine_category,
    storage_condition
FROM medicine
WHERE medicine_name ILIKE 'Insulin%'
ORDER BY medicine_name;


-- =============================================================================
-- TASK 13: FIVE-TABLE JOIN QUERY  
-- Business question: For every temperature-sensitive medicine shipped, confirm
-- that the assigned carrier holds the exact matching storage capability (Rule 8).
-- =============================================================================
SELECT
   sh.shipment_id,
   sp.supplier_id,
   sp.supplier_name,
   m.medicine_id,
   m.medicine_name,
   m.storage_condition,
   spc.capability_type
FROM shipment AS sh
JOIN shipmentitem As si
    ON si.shipment_id = sh.shipment_id
JOIN medicine AS m
	ON m.medicine_id = si.medicine_id
JOIN supplier AS sp
    ON sp.supplier_id = sh.supplier_id
JOIN suppliercapability AS spc
    ON spc.supplier_id = sp.supplier_id	
	AND spc.capability_type IN ('Cold Storage', 'Frozen Storage')
WHERE m.storage_condition <> 'Ambient'
	AND ( (m.storage_condition = 'Cold'AND spc.capability_type = 'Cold Storage')
       OR (m.storage_condition = 'Frozen' AND spc.capability_type = 'Frozen Storage') )
ORDER BY m.storage_condition;


-- =============================================================================
-- TASK 14: VIEW CREATION
-- Purpose: A reusable GDP compliance view. For every temperature-monitored shipment
-- it reports how many readings were taken, how many breached the required range,
-- and the resulting compliance percentage (the temperature_compliance_rate
-- derived attribute, computed on demand rather than stored).
-- =============================================================================

DROP VIEW IF EXISTS vw_cold_chain_compliance;
CREATE OR REPLACE VIEW vw_cold_chain_compliance AS
SELECT
    tr.shipment_id,
	sp.supplier_name,
	count(*) As readings_taken,
	count(*) filter (where tr.temperature_status='Out of Range')As breaches,
	ROUND(100.0* count (*) filter (where tr.temperature_status='Within Range')/ count(*),1) As compliance_percentage
FROM temperaturerecord AS tr
JOIN  shipment AS sh
    ON sh.shipment_id = tr.shipment_id
JOIN Supplier AS sp
    ON sp.supplier_id = sh.supplier_id
GROUP BY tr.shipment_id, sp.supplier_name;

-- Test the view: worst cold-chain shipments first.
SELECT * FROM vw_cold_chain_compliance
ORDER BY compliance_percentage ASC, shipment_id;


-- =============================================================================
-- TASK 15: ANALYTICS-STYLE PERIODIC REPORT QUERY
-- Business question: How did FastLink's monthly shipment volume and revenue change over the first half of 2026?
-- =============================================================================

SELECT
    TO_CHAR(inv.invoice_date,'YYYY-MM')As report_month,
	COUNT(DISTINCT inv.shipment_id) As total_shipments,
	SUM(inv.total_amount)As monthly_revenue,
	ROUND(AVG(inv.total_amount),2) As avg_invoice_value
FROM Shipment sh
JOIN Invoice inv on inv.shipment_id =sh.shipment_id
GROUP BY TO_CHAR(inv.invoice_date,'YYYY-MM')
ORDER BY report_month;
