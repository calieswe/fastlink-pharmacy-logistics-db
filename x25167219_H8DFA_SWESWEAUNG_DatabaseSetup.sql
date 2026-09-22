-- =============================================================================
-- DATABASE SETUP SCRIPT
-- Student: SWE SWE AUNG
-- Student ID: x25167219
-- Domain: Transportation and Logistics System
-- Target DBMS: PostgreSQL
-- Database name used in the demonstration: FastLink3PL
-- =============================================================================

--Phase 2: Physical Database Implementation

-- =============================================================================
-- TASK 4: SQL DDL SCHEMA CREATION
-- ===============================================================
-- Table: Customer
DROP TABLE IF EXISTS Customer CASCADE;
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100) NOT NULL UNIQUE,
    customer_phone VARCHAR(20)not null,
    customer_address VARCHAR(250) NOT NULL,
    customer_type VARCHAR(20) NOT NULL CONSTRAINT customer_type_check CHECK (customer_type IN ('Individual', 'Business')),
    customer_status VARCHAR(10) NOT NULL CONSTRAINT customer_status_check CHECK (customer_status IN ('Active', 'Inactive'))
);


-- Table: Supplier
DROP TABLE IF EXISTS Supplier CASCADE;
CREATE TABLE Supplier (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    supplier_email VARCHAR(100) NOT NULL UNIQUE,
    supplier_phone VARCHAR(20)NOT NULL,
    supplier_address VARCHAR(250) NOT NULL,
    supplier_status VARCHAR(15) NOT NULL CONSTRAINT supplier_status_check CHECK (supplier_status IN ('Active', 'Inactive', 'Suspended'))
);


-- Table: SupplierCapability
DROP TABLE IF EXISTS SupplierCapability CASCADE;
CREATE TABLE SupplierCapability (
    supplier_id INT NOT NULL,
    capability_type VARCHAR(30) NOT NULL CONSTRAINT capability_type_check CHECK (capability_type IN (
                        'Road', 'Air', 'Sea', 'Rail',
                        'Ambient Storage', 'Cold Storage',
                        'Frozen Storage'
                     )),
    PRIMARY KEY (supplier_id, capability_type),
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);


-- Table: Medicine
DROP TABLE IF EXISTS Medicine CASCADE;
CREATE TABLE Medicine (
    medicine_id INT PRIMARY KEY,
    medicine_name VARCHAR(100) NOT NULL,
    medicine_category VARCHAR(50) NOT NULL,
    storage_condition varchar(10) not null
        constraint storage_condition_check check(storage_condition in ('Ambient','Cold','Frozen')),
    min_temp_required DECIMAL(5,2) not null,
    max_temp_required DECIMAL(5,2) not null,

        CONSTRAINT temp_required_check CHECK (min_temp_required<max_temp_required),
        CONSTRAINT storage_range_check check ((storage_condition='Ambient' and min_temp_required=15 and max_temp_required=25)
            or (storage_condition='Cold' and min_temp_required=2 and max_temp_required=8)
            or (storage_condition='Frozen' and min_temp_required=-25 and max_temp_required=-15))
);


-- Table: Orders
DROP TABLE IF EXISTS Orders CASCADE;
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    pickup_address VARCHAR(300),
    order_status VARCHAR(20) not null constraint order_status_check check(order_status in ('Pending', 'Processing', 'Completed', 'Cancelled')),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);


-- Table: Shipment
DROP TABLE IF EXISTS Shipment CASCADE;
CREATE TABLE Shipment (
    shipment_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    supplier_id INT NOT NULL,
    shipment_date DATE NOT NULL,
    expected_delivery_date DATE NOT NULL,
    actual_delivery_date DATE,
    destination_address VARCHAR(250) NOT NULL,
    shipment_status VARCHAR(20) NOT NULL CONSTRAINT shipment_status_check CHECK (shipment_status IN ('Pending', 'In Transit', 'Delivered', 'Failed')),
    transportation_type VARCHAR(20) NOT NULL CONSTRAINT transportation_type_check CHECK (transportation_type IN ('Road', 'Air', 'Sea', 'Rail')),
    special_note TEXT,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);


-- Table: ShipmentItem
DROP TABLE IF EXISTS ShipmentItem CASCADE;
CREATE TABLE ShipmentItem (
    shipment_id INT NOT NULL,
    medicine_id INT NOT NULL,
    quantity INT NOT NULL CONSTRAINT quantity_check CHECK (quantity > 0),
    PRIMARY KEY (shipment_id, medicine_id),
    FOREIGN KEY (shipment_id) REFERENCES Shipment(shipment_id),
    FOREIGN KEY (medicine_id) REFERENCES Medicine(medicine_id)
);


DROP TABLE IF EXISTS Invoice CASCADE;
CREATE TABLE Invoice (
    invoice_id INT PRIMARY KEY,
    shipment_id INT NOT NULL UNIQUE,
    invoice_date DATE NOT NULL,
    due_date DATE GENERATED ALWAYS AS (invoice_date + INTERVAL '15 days') STORED,
    total_amount DECIMAL(10,2) NOT NULL CONSTRAINT total_amount_check CHECK (total_amount > 0),
    payment_status VARCHAR(15) NOT NULL CONSTRAINT payment_status_check CHECK (payment_status IN ('Paid', 'Unpaid', 'Overdue')),
    FOREIGN KEY(shipment_id) REFERENCES Shipment(shipment_id)
);


DROP TABLE IF EXISTS TemperatureRecord CASCADE;
CREATE TABLE TemperatureRecord (
    temperature_id INT PRIMARY KEY,
    shipment_id INT NOT NULL,
    recorded_at TIMESTAMP NOT NULL,
    temperature_degree DECIMAL(5,2) NOT NULL,
    temperature_status VARCHAR(15) NOT NULL CONSTRAINT temperature_status_check CHECK (temperature_status IN ('Within Range', 'Out of Range')),
    FOREIGN KEY (shipment_id) REFERENCES Shipment(shipment_id)
);


-- Customer (30)
INSERT INTO Customer VALUES (1,'St. James''s Hospital','stjamesshospital1@fastlink-client.ie','0629-514002','James''s St, Dublin 8','Business','Active');
INSERT INTO Customer VALUES (2,'Cork University Hospital','corkuniversityhospital2@fastlink-client.ie','0119-961168','Wilton, Cork','Business','Active');
INSERT INTO Customer VALUES (3,'Beacon Hospital','beaconhospital3@fastlink-client.ie','0922-483452','Sandyford, Dublin 18','Business','Active');
INSERT INTO Customer VALUES (4,'Galway Clinic','galwayclinic4@fastlink-client.ie','0174-325127','Doughiska, Galway','Business','Active');
INSERT INTO Customer VALUES (5,'Mater Misericordiae Hospital','matermisericordiaehosp5@fastlink-client.ie','0121-554710','Eccles St, Dublin 7','Business','Active');
INSERT INTO Customer VALUES (6,'Tallaght University Hospital','tallaghtuniversityhosp6@fastlink-client.ie','0718-352353','Tallaght, Dublin 24','Business','Active');
INSERT INTO Customer VALUES (7,'University Hospital Limerick','universityhospitallime7@fastlink-client.ie','0280-545140','Dooradoyle, Limerick','Business','Active');
INSERT INTO Customer VALUES (8,'Sligo University Hospital','sligouniversityhospita8@fastlink-client.ie','0182-229815','The Mall, Sligo','Business','Active');
INSERT INTO Customer VALUES (9,'Letterkenny University Hospital','letterkennyuniversityh9@fastlink-client.ie','0490-757911','Kilmacrennan Rd, Donegal','Business','Inactive');
INSERT INTO Customer VALUES (10,'Boots Ireland - Grafton St','bootsirelandgraftonst10@fastlink-client.ie','0183-713984','Grafton St, Dublin 2','Business','Active');
INSERT INTO Customer VALUES (11,'Boots Ireland - Henry St','bootsirelandhenryst11@fastlink-client.ie','0716-331821','Henry St, Dublin 1','Business','Active');
INSERT INTO Customer VALUES (12,'Hickey''s Pharmacy Dublin','hickeyspharmacydublin12@fastlink-client.ie','0181-239643','O''Connell St, Dublin 1','Business','Active');
INSERT INTO Customer VALUES (13,'Hickey''s Pharmacy Cork','hickeyspharmacycork13@fastlink-client.ie','0563-251262','St Patrick''s St, Cork','Business','Active');
INSERT INTO Customer VALUES (14,'LloydsPharmacy Blanchardstown','lloydspharmacyblanchar14@fastlink-client.ie','0925-698646','Blanchardstown, Dublin 15','Business','Active');
INSERT INTO Customer VALUES (15,'LloydsPharmacy Swords','lloydspharmacyswords15@fastlink-client.ie','0581-955770','Pavilions, Swords, Co. Dublin','Business','Active');
INSERT INTO Customer VALUES (16,'McCabes Pharmacy','mccabespharmacy16@fastlink-client.ie','0323-709851','Blackrock, Co. Dublin','Business','Active');
INSERT INTO Customer VALUES (17,'Life Pharmacy Galway','lifepharmacygalway17@fastlink-client.ie','0457-202163','Shop St, Galway','Business','Active');
INSERT INTO Customer VALUES (18,'Sam McCauley Chemists','sammccauleychemists18@fastlink-client.ie','0918-691783','Redmond Sq, Wexford','Business','Active');
INSERT INTO Customer VALUES (19,'Meaghers Pharmacy','meagherspharmacy19@fastlink-client.ie','0189-315963','Baggot St, Dublin 4','Business','Active');
INSERT INTO Customer VALUES (20,'Allcare Pharmacy Limerick','allcarepharmacylimeric20@fastlink-client.ie','0897-657549','William St, Limerick','Business','Inactive');
INSERT INTO Customer VALUES (21,'Bon Secours Hospital Cork','bonsecourshospitalcork21@fastlink-client.ie','0750-588218','College Rd, Cork','Business','Active');
INSERT INTO Customer VALUES (22,'Blackrock Health Hermitage','blackrockhealthhermita22@fastlink-client.ie','0856-414328','Lucan, Dublin','Business','Active');
INSERT INTO Customer VALUES (23,'Kingsbridge Private Hospital','kingsbridgeprivatehosp23@fastlink-client.ie','0433-832948','Sandyford, Dublin 18','Business','Active');
INSERT INTO Customer VALUES (24,'Aoife Nolan','aoife.nolan@gmail.com','0420-702326','5 Beech Rd, Naas, Co. Kildare','Individual','Active');
INSERT INTO Customer VALUES (25,'Liam Byrne','liam.byrne@gmail.com','0577-619167','9 Oak Drive, Ennis, Co. Clare','Individual','Inactive');
INSERT INTO Customer VALUES (26,'Sarah O''Brien','sarah.obrien@gmail.com','0667-401924','17 Rose Ave, Limerick','Individual','Active');
INSERT INTO Customer VALUES (27,'Conor Walsh','conor.walsh@gmail.com','0225-636800','3 Maple Court, Athlone','Individual','Active');
INSERT INTO Customer VALUES (28,'Niamh Kelly','niamh.kelly@gmail.com','0731-893919','22 Cedar Grove, Kilkenny','Individual','Active');
INSERT INTO Customer VALUES (29,'Declan Murphy','declan.murphy@gmail.com','0629-612714','8 Willow Park, Dundalk','Individual','Active');
INSERT INTO Customer VALUES (30,'Emma Doyle','emma.doyle@gmail.com','0715-800675','14 Elm St, Waterford','Individual','Active');

-- Supplier (15)
INSERT INTO Supplier VALUES (1,'ColdChain Logistics Ltd','ops@coldchainlogis.ie','02-6263809','Ballymount, Dublin 12','Active');
INSERT INTO Supplier VALUES (2,'PharmaFreight Express','ops@pharmafreighte.ie','06-6875018','Citywest, Dublin 24','Active');
INSERT INTO Supplier VALUES (3,'Emerald Haulage','ops@emeraldhaulage.ie','08-8653855','Naas Rd, Dublin 22','Active');
INSERT INTO Supplier VALUES (4,'Atlantic Air Cargo','ops@atlanticaircar.ie','02-2570280','Shannon Airport, Co. Clare','Active');
INSERT INTO Supplier VALUES (5,'Celtic Distribution','ops@celticdistribu.ie','05-8954050','Little Island, Cork','Active');
INSERT INTO Supplier VALUES (6,'NordFrost Transport','ops@nordfrosttrans.ie','02-2017864','Baldonnell, Dublin 22','Active');
INSERT INTO Supplier VALUES (7,'Shannon Freight','ops@shannonfreight.ie','05-8476611','Raheen, Limerick','Suspended');
INSERT INTO Supplier VALUES (8,'IrishRail Logistics','ops@irishraillogis.ie','05-7472506','Heuston, Dublin 8','Active');
INSERT INTO Supplier VALUES (9,'DublinPort Shipping','ops@dublinportship.ie','06-1378543','Alexandra Rd, Dublin 1','Active');
INSERT INTO Supplier VALUES (10,'CryoMed Transport','ops@cryomedtranspo.ie','08-6963698','Grangecastle, Dublin 22','Active');
INSERT INTO Supplier VALUES (11,'Swift Couriers','ops@swiftcouriers.ie','03-2964541','Tallaght, Dublin 24','Inactive');
INSERT INTO Supplier VALUES (12,'GreenLine Logistics','ops@greenlinelogis.ie','08-1989091','Oranmore, Galway','Active');
INSERT INTO Supplier VALUES (13,'Nationwide Pharma Carriers','ops@nationwidephar.ie','04-5822307','Little Island, Cork','Active');
INSERT INTO Supplier VALUES (14,'Arctic Cold Freight','ops@arcticcoldfrei.ie','03-5154287','Rosslare, Co. Wexford','Active');
INSERT INTO Supplier VALUES (15,'Eirway Distribution','ops@eirwaydistribu.ie','07-7559047','Portlaoise, Co. Laois','Active');

-- SupplierCapability
INSERT INTO SupplierCapability VALUES (1,'Road');
INSERT INTO SupplierCapability VALUES (1,'Cold Storage');
INSERT INTO SupplierCapability VALUES (1,'Ambient Storage');
INSERT INTO SupplierCapability VALUES (2,'Road');
INSERT INTO SupplierCapability VALUES (2,'Air');
INSERT INTO SupplierCapability VALUES (2,'Cold Storage');
INSERT INTO SupplierCapability VALUES (3,'Road');
INSERT INTO SupplierCapability VALUES (3,'Ambient Storage');
INSERT INTO SupplierCapability VALUES (4,'Air');
INSERT INTO SupplierCapability VALUES (4,'Cold Storage');
INSERT INTO SupplierCapability VALUES (4,'Ambient Storage');
INSERT INTO SupplierCapability VALUES (5,'Road');
INSERT INTO SupplierCapability VALUES (5,'Ambient Storage');
INSERT INTO SupplierCapability VALUES (6,'Road');
INSERT INTO SupplierCapability VALUES (6,'Cold Storage');
INSERT INTO SupplierCapability VALUES (6,'Frozen Storage');
INSERT INTO SupplierCapability VALUES (7,'Road');
INSERT INTO SupplierCapability VALUES (7,'Ambient Storage');
INSERT INTO SupplierCapability VALUES (8,'Rail');
INSERT INTO SupplierCapability VALUES (8,'Road');
INSERT INTO SupplierCapability VALUES (8,'Ambient Storage');
INSERT INTO SupplierCapability VALUES (9,'Sea');
INSERT INTO SupplierCapability VALUES (9,'Road');
INSERT INTO SupplierCapability VALUES (9,'Ambient Storage');
INSERT INTO SupplierCapability VALUES (10,'Road');
INSERT INTO SupplierCapability VALUES (10,'Air');
INSERT INTO SupplierCapability VALUES (10,'Cold Storage');
INSERT INTO SupplierCapability VALUES (10,'Frozen Storage');
INSERT INTO SupplierCapability VALUES (11,'Road');
INSERT INTO SupplierCapability VALUES (11,'Ambient Storage');
INSERT INTO SupplierCapability VALUES (12,'Road');
INSERT INTO SupplierCapability VALUES (12,'Cold Storage');
INSERT INTO SupplierCapability VALUES (12,'Ambient Storage');
INSERT INTO SupplierCapability VALUES (13,'Road');
INSERT INTO SupplierCapability VALUES (13,'Ambient Storage');
INSERT INTO SupplierCapability VALUES (14,'Road');
INSERT INTO SupplierCapability VALUES (14,'Cold Storage');
INSERT INTO SupplierCapability VALUES (14,'Frozen Storage');
INSERT INTO SupplierCapability VALUES (15,'Rail');
INSERT INTO SupplierCapability VALUES (15,'Road');
INSERT INTO SupplierCapability VALUES (15,'Ambient Storage');

-- Medicine (25)
--TRUNCATE TABLE Medicine CASCADE;
INSERT INTO Medicine VALUES (1,'Covid-19 mRNA Vaccine','Vaccine','Frozen',-25.0,-15.0);
INSERT INTO Medicine VALUES (2,'Varicella Vaccine','Vaccine','Frozen',-25.0,-15.0);
INSERT INTO Medicine VALUES (3,'Zoster Vaccine','Vaccine','Frozen',-25.0,-15.0);
INSERT INTO Medicine VALUES (4,'Fresh Frozen Plasma','Blood Product','Frozen',-25.0,-15.0);
INSERT INTO Medicine VALUES (5,'Insulin Glargine','Diabetes','Cold',2.0,8.0);
INSERT INTO Medicine VALUES (6,'Insulin Aspart','Diabetes','Cold',2.0,8.0);
INSERT INTO Medicine VALUES (7,'Insulin Lispro','Diabetes','Cold',2.0,8.0);
INSERT INTO Medicine VALUES (8,'Influenza Vaccine','Vaccine','Cold',2.0,8.0);
INSERT INTO Medicine VALUES (9,'Hepatitis B Vaccine','Vaccine','Cold',2.0,8.0);
INSERT INTO Medicine VALUES (10,'HPV Vaccine','Vaccine','Cold',2.0,8.0);
INSERT INTO Medicine VALUES (11,'Human Albumin 20%','Blood Product','Cold',2.0,8.0);
INSERT INTO Medicine VALUES (12,'Filgrastim','Oncology','Cold',2.0,8.0);
INSERT INTO Medicine VALUES (13,'Erythropoietin','Nephrology','Cold',2.0,8.0);
INSERT INTO Medicine VALUES (14,'Paracetamol 500mg','Analgesic','Ambient',15.0,25.0);
INSERT INTO Medicine VALUES (15,'Ibuprofen 400mg','Analgesic','Ambient',15.0,25.0);
INSERT INTO Medicine VALUES (16,'Amoxicillin 500mg','Antibiotic','Ambient',15.0,25.0);
INSERT INTO Medicine VALUES (17,'Azithromycin 250mg','Antibiotic','Ambient',15.0,25.0);
INSERT INTO Medicine VALUES (18,'Metformin 850mg','Diabetes','Ambient',15.0,25.0);
INSERT INTO Medicine VALUES (19,'Omeprazole 20mg','Gastro','Ambient',15.0,25.0);
INSERT INTO Medicine VALUES (20,'Salbutamol Inhaler','Respiratory','Ambient',15.0,25.0);
INSERT INTO Medicine VALUES (21,'Atorvastatin 20mg','Cardiovascular','Ambient',15.0,25.0);
INSERT INTO Medicine VALUES (22,'Amlodipine 5mg','Cardiovascular','Ambient',15.0,25.0);
INSERT INTO Medicine VALUES (23,'Aspirin 75mg','Cardiovascular','Ambient',15.0,25.0);
INSERT INTO Medicine VALUES (24,'Cetirizine 10mg','Antihistamine','Ambient',15.0,25.0);
INSERT INTO Medicine VALUES (25,'Ramipril 5mg','Cardiovascular','Ambient',15.0,25.0);

-- Orders (60)
INSERT INTO Orders VALUES (1,17,'2026-01-26','Shop St, Galway','Processing');
INSERT INTO Orders VALUES (2,16,'2026-04-18','Blackrock, Co. Dublin','Completed');
INSERT INTO Orders VALUES (3,10,'2026-02-10','Grafton St, Dublin 2','Cancelled');
INSERT INTO Orders VALUES (4,15,'2026-05-26','Pavilions, Swords, Co. Dublin','Completed');
INSERT INTO Orders VALUES (5,26,'2026-04-22','17 Rose Ave, Limerick','Completed');
INSERT INTO Orders VALUES (6,24,'2026-04-13','5 Beech Rd, Naas, Co. Kildare','Processing');
INSERT INTO Orders VALUES (7,5,'2026-01-27','Eccles St, Dublin 7','Processing');
INSERT INTO Orders VALUES (8,5,'2026-03-06','Eccles St, Dublin 7','Completed');
INSERT INTO Orders VALUES (9,8,'2026-01-09','The Mall, Sligo','Completed');
INSERT INTO Orders VALUES (10,30,'2026-06-05','14 Elm St, Waterford','Processing');
INSERT INTO Orders VALUES (11,10,'2026-03-19','Grafton St, Dublin 2','Pending');
INSERT INTO Orders VALUES (12,5,'2026-04-23','Eccles St, Dublin 7','Completed');
INSERT INTO Orders VALUES (13,13,'2026-06-11','St Patrick''s St, Cork','Completed');
INSERT INTO Orders VALUES (14,12,'2026-02-07','O''Connell St, Dublin 1','Completed');
INSERT INTO Orders VALUES (15,18,'2026-06-13','Redmond Sq, Wexford','Completed');
INSERT INTO Orders VALUES (16,24,'2026-07-14','5 Beech Rd, Naas, Co. Kildare','Pending');
INSERT INTO Orders VALUES (17,16,'2026-06-29','Blackrock, Co. Dublin','Cancelled');
INSERT INTO Orders VALUES (18,19,'2026-04-16','Baggot St, Dublin 4','Completed');
INSERT INTO Orders VALUES (19,14,'2026-04-16','Blanchardstown, Dublin 15','Pending');
INSERT INTO Orders VALUES (20,17,'2026-06-17','Shop St, Galway','Completed');
INSERT INTO Orders VALUES (21,2,'2026-02-23','Wilton, Cork','Pending');
INSERT INTO Orders VALUES (22,7,'2026-04-28','Dooradoyle, Limerick','Processing');
INSERT INTO Orders VALUES (23,4,'2026-04-03','Doughiska, Galway','Completed');
INSERT INTO Orders VALUES (24,2,'2026-02-01','Wilton, Cork','Pending');
INSERT INTO Orders VALUES (25,21,'2026-02-13','College Rd, Cork','Completed');
INSERT INTO Orders VALUES (26,4,'2026-04-09','Doughiska, Galway','Completed');
INSERT INTO Orders VALUES (27,1,'2026-01-24','James''s St, Dublin 8','Cancelled');
INSERT INTO Orders VALUES (28,7,'2026-06-12','Dooradoyle, Limerick','Completed');
INSERT INTO Orders VALUES (29,5,'2026-06-17','Eccles St, Dublin 7','Completed');
INSERT INTO Orders VALUES (30,13,'2026-06-09','St Patrick''s St, Cork','Completed');
INSERT INTO Orders VALUES (31,17,'2026-02-06','Shop St, Galway','Pending');
INSERT INTO Orders VALUES (32,17,'2026-05-05','Shop St, Galway','Completed');
INSERT INTO Orders VALUES (33,17,'2026-03-26','Shop St, Galway','Pending');
INSERT INTO Orders VALUES (34,5,'2026-02-01','Eccles St, Dublin 7','Completed');
INSERT INTO Orders VALUES (35,12,'2026-07-14','O''Connell St, Dublin 1','Completed');
INSERT INTO Orders VALUES (36,17,'2026-07-02','Shop St, Galway','Processing');
INSERT INTO Orders VALUES (37,18,'2026-01-11','Redmond Sq, Wexford','Processing');
INSERT INTO Orders VALUES (38,18,'2026-04-08','Redmond Sq, Wexford','Processing');
INSERT INTO Orders VALUES (39,26,'2026-05-25','17 Rose Ave, Limerick','Pending');
INSERT INTO Orders VALUES (40,28,'2026-05-21','22 Cedar Grove, Kilkenny','Completed');
INSERT INTO Orders VALUES (41,23,'2026-01-29','Sandyford, Dublin 18','Completed');
INSERT INTO Orders VALUES (42,10,'2026-05-18','Grafton St, Dublin 2','Completed');
INSERT INTO Orders VALUES (43,6,'2026-04-07','Tallaght, Dublin 24','Cancelled');
INSERT INTO Orders VALUES (44,8,'2026-05-22','The Mall, Sligo','Completed');
INSERT INTO Orders VALUES (45,28,'2026-05-14','22 Cedar Grove, Kilkenny','Completed');
INSERT INTO Orders VALUES (46,23,'2026-03-04','Sandyford, Dublin 18','Completed');
INSERT INTO Orders VALUES (47,29,'2026-02-24','8 Willow Park, Dundalk','Cancelled');
INSERT INTO Orders VALUES (48,8,'2026-04-18','The Mall, Sligo','Completed');
INSERT INTO Orders VALUES (49,29,'2026-03-05','8 Willow Park, Dundalk','Processing');
INSERT INTO Orders VALUES (50,18,'2026-05-12','Redmond Sq, Wexford','Completed');
INSERT INTO Orders VALUES (51,27,'2026-01-13','3 Maple Court, Athlone','Pending');
INSERT INTO Orders VALUES (52,29,'2026-03-18','8 Willow Park, Dundalk','Completed');
INSERT INTO Orders VALUES (53,10,'2026-02-24','Grafton St, Dublin 2','Completed');
INSERT INTO Orders VALUES (54,22,'2026-04-04','Lucan, Dublin','Completed');
INSERT INTO Orders VALUES (55,29,'2026-07-10','8 Willow Park, Dundalk','Completed');
INSERT INTO Orders VALUES (56,13,'2026-01-26','St Patrick''s St, Cork','Processing');
INSERT INTO Orders VALUES (57,4,'2026-03-05','Doughiska, Galway','Completed');
INSERT INTO Orders VALUES (58,7,'2026-04-02','Dooradoyle, Limerick','Processing');
INSERT INTO Orders VALUES (59,17,'2026-06-14','Shop St, Galway','Completed');
INSERT INTO Orders VALUES (60,30,'2026-01-06','14 Elm St, Waterford','Completed');

-- Shipment (80)
INSERT INTO Shipment VALUES (1,1,14,'2026-01-30','2026-02-06','2026-02-06','Shop St, Galway','Delivered','Road',NULL);
INSERT INTO Shipment VALUES (2,2,6,'2026-04-21','2026-04-25','2026-04-24','Blackrock, Co. Dublin','Delivered','Road','Priority delivery before 10am');
INSERT INTO Shipment VALUES (3,4,8,'2026-05-29','2026-05-31','2026-06-03','Pavilions, Swords, Co. Dublin','Delivered','Road','Signature required on delivery');
INSERT INTO Shipment VALUES (4,5,5,'2026-04-25','2026-04-27','2026-04-26','17 Rose Ave, Limerick','Delivered','Road','Deliver to loading bay 2');
INSERT INTO Shipment VALUES (5,6,6,'2026-04-16','2026-04-22','2026-04-24','5 Beech Rd, Naas, Co. Kildare','Delivered','Road','Keep upright at all times');
INSERT INTO Shipment VALUES (6,7,5,'2026-01-30','2026-02-06','2026-02-05','Eccles St, Dublin 7','Delivered','Road','Priority delivery before 10am');
INSERT INTO Shipment VALUES (7,8,10,'2026-03-07','2026-03-11','2026-03-09','Eccles St, Dublin 7','Delivered','Air',NULL);
INSERT INTO Shipment VALUES (8,9,10,'2026-01-13','2026-01-20','2026-01-21','The Mall, Sligo','Delivered','Road',NULL);
INSERT INTO Shipment VALUES (9,10,4,'2026-06-09','2026-06-13',NULL,'14 Elm St, Waterford','Failed','Air','Signature required on delivery');
INSERT INTO Shipment VALUES (10,11,13,'2026-03-20','2026-03-27',NULL,'Grafton St, Dublin 2','Pending','Road',NULL);
INSERT INTO Shipment VALUES (11,12,14,'2026-04-25','2026-04-29','2026-04-29','Eccles St, Dublin 7','Delivered','Road','Contact pharmacy on arrival');
INSERT INTO Shipment VALUES (12,13,2,'2026-06-14','2026-06-19','2026-06-19','St Patrick''s St, Cork','Delivered','Road',NULL);
INSERT INTO Shipment VALUES (13,14,14,'2026-02-08','2026-02-11','2026-02-09','O''Connell St, Dublin 1','Delivered','Road','Do not leave unattended');
INSERT INTO Shipment VALUES (14,15,5,'2026-06-18','2026-06-24',NULL,'Redmond Sq, Wexford','Pending','Road','Signature required on delivery');
INSERT INTO Shipment VALUES (15,16,12,'2026-07-15','2026-07-22',NULL,'5 Beech Rd, Naas, Co. Kildare','Pending','Road',NULL);
INSERT INTO Shipment VALUES (16,18,10,'2026-04-17','2026-04-19','2026-04-22','Baggot St, Dublin 4','Delivered','Road','Contact pharmacy on arrival');
INSERT INTO Shipment VALUES (17,19,8,'2026-04-21','2026-04-28','2026-04-28','Blanchardstown, Dublin 15','Delivered','Rail','Handle with care, fragile vials');
INSERT INTO Shipment VALUES (18,20,14,'2026-06-21','2026-06-25',NULL,'Shop St, Galway','In Transit','Road','Priority delivery before 10am');
INSERT INTO Shipment VALUES (19,21,14,'2026-02-27','2026-03-04','2026-03-07','Wilton, Cork','Delivered','Road','Priority delivery before 10am');
INSERT INTO Shipment VALUES (20,22,12,'2026-05-01','2026-05-05',NULL,'Dooradoyle, Limerick','In Transit','Road','Priority delivery before 10am');
INSERT INTO Shipment VALUES (21,23,1,'2026-04-04','2026-04-11','2026-04-12','Doughiska, Galway','Delivered','Road','Priority delivery before 10am');
INSERT INTO Shipment VALUES (22,24,6,'2026-02-02','2026-02-06','2026-02-08','Wilton, Cork','Delivered','Road','Temperature-sensitive, do not delay');
INSERT INTO Shipment VALUES (23,25,4,'2026-02-15','2026-02-22','2026-02-22','College Rd, Cork','Delivered','Air','Signature required on delivery');
INSERT INTO Shipment VALUES (24,26,2,'2026-04-13','2026-04-15','2026-04-16','Doughiska, Galway','Delivered','Air',NULL);
INSERT INTO Shipment VALUES (25,28,5,'2026-06-16','2026-06-20','2026-06-20','Dooradoyle, Limerick','Delivered','Road','Handle with care, fragile vials');
INSERT INTO Shipment VALUES (26,29,15,'2026-06-18','2026-06-25','2026-06-25','Eccles St, Dublin 7','Delivered','Rail','Deliver to loading bay 2');
INSERT INTO Shipment VALUES (27,30,12,'2026-06-12','2026-06-14','2026-06-12','St Patrick''s St, Cork','Delivered','Road',NULL);
INSERT INTO Shipment VALUES (28,31,13,'2026-02-10','2026-02-16','2026-02-16','Shop St, Galway','Delivered','Road','Do not leave unattended');
INSERT INTO Shipment VALUES (29,32,15,'2026-05-06','2026-05-08',NULL,'Shop St, Galway','Failed','Rail','Do not leave unattended');
INSERT INTO Shipment VALUES (30,33,12,'2026-03-28','2026-04-02','2026-04-02','Shop St, Galway','Delivered','Road','Priority delivery before 10am');
INSERT INTO Shipment VALUES (31,34,8,'2026-02-06','2026-02-13','2026-02-12','Eccles St, Dublin 7','Delivered','Road',NULL);
INSERT INTO Shipment VALUES (32,35,2,'2026-07-19','2026-07-22','2026-07-22','O''Connell St, Dublin 1','Delivered','Air','Temperature-sensitive, do not delay');
INSERT INTO Shipment VALUES (33,36,3,'2026-07-04','2026-07-08','2026-07-08','Shop St, Galway','Delivered','Road','Keep upright at all times');
INSERT INTO Shipment VALUES (34,37,5,'2026-01-15','2026-01-20',NULL,'Redmond Sq, Wexford','In Transit','Road','Keep upright at all times');
INSERT INTO Shipment VALUES (35,38,5,'2026-04-13','2026-04-17','2026-04-19','Redmond Sq, Wexford','Delivered','Road',NULL);
INSERT INTO Shipment VALUES (36,39,4,'2026-05-29','2026-06-02',NULL,'17 Rose Ave, Limerick','Pending','Air','Handle with care, fragile vials');
INSERT INTO Shipment VALUES (37,40,1,'2026-05-22','2026-05-24','2026-05-26','22 Cedar Grove, Kilkenny','Delivered','Road','Temperature-sensitive, do not delay');
INSERT INTO Shipment VALUES (38,41,15,'2026-01-31','2026-02-06',NULL,'Sandyford, Dublin 18','Failed','Rail','Deliver to loading bay 2');
INSERT INTO Shipment VALUES (39,42,2,'2026-05-20','2026-05-26',NULL,'Grafton St, Dublin 2','Pending','Road',NULL);
INSERT INTO Shipment VALUES (40,44,3,'2026-05-23','2026-05-25','2026-05-27','The Mall, Sligo','Delivered','Road',NULL);
INSERT INTO Shipment VALUES (41,45,5,'2026-05-15','2026-05-21','2026-05-22','22 Cedar Grove, Kilkenny','Delivered','Road','Priority delivery before 10am');
INSERT INTO Shipment VALUES (42,46,13,'2026-03-09','2026-03-12','2026-03-13','Sandyford, Dublin 18','Delivered','Road',NULL);
INSERT INTO Shipment VALUES (43,48,1,'2026-04-22','2026-04-24','2026-04-27','The Mall, Sligo','Delivered','Road','Do not leave unattended');
INSERT INTO Shipment VALUES (44,49,4,'2026-03-08','2026-03-15','2026-03-13','8 Willow Park, Dundalk','Delivered','Air','Priority delivery before 10am');
INSERT INTO Shipment VALUES (45,50,9,'2026-05-14','2026-05-19','2026-05-19','Redmond Sq, Wexford','Delivered','Sea','Deliver to loading bay 2');
INSERT INTO Shipment VALUES (46,51,12,'2026-01-17','2026-01-24','2026-01-26','3 Maple Court, Athlone','Delivered','Road','Signature required on delivery');
INSERT INTO Shipment VALUES (47,52,1,'2026-03-22','2026-03-24',NULL,'8 Willow Park, Dundalk','In Transit','Road','Signature required on delivery');
INSERT INTO Shipment VALUES (48,53,9,'2026-02-26','2026-03-02','2026-03-05','Grafton St, Dublin 2','Delivered','Sea',NULL);
INSERT INTO Shipment VALUES (49,54,5,'2026-04-06','2026-04-08','2026-04-08','Lucan, Dublin','Delivered','Road','Deliver to loading bay 2');
INSERT INTO Shipment VALUES (50,55,2,'2026-07-13','2026-07-18','2026-07-21','8 Willow Park, Dundalk','Delivered','Air','Temperature-sensitive, do not delay');
INSERT INTO Shipment VALUES (51,56,6,'2026-01-30','2026-02-01',NULL,'St Patrick''s St, Cork','In Transit','Road','Keep upright at all times');
INSERT INTO Shipment VALUES (52,57,8,'2026-03-06','2026-03-10','2026-03-08','Doughiska, Galway','Delivered','Rail',NULL);
INSERT INTO Shipment VALUES (53,58,6,'2026-04-05','2026-04-12',NULL,'Dooradoyle, Limerick','In Transit','Road','Contact pharmacy on arrival');
INSERT INTO Shipment VALUES (54,59,1,'2026-06-15','2026-06-20',NULL,'Shop St, Galway','In Transit','Road','Temperature-sensitive, do not delay');
INSERT INTO Shipment VALUES (55,60,15,'2026-01-10','2026-01-13','2026-01-16','14 Elm St, Waterford','Delivered','Rail','Priority delivery before 10am');
INSERT INTO Shipment VALUES (56,1,6,'2026-01-31','2026-02-03','2026-02-02','Shop St, Galway','Delivered','Road','Keep upright at all times');
INSERT INTO Shipment VALUES (57,2,13,'2026-04-20','2026-04-25',NULL,'Blackrock, Co. Dublin','Pending','Road','Deliver to loading bay 2');
INSERT INTO Shipment VALUES (58,4,12,'2026-05-30','2026-06-04',NULL,'Pavilions, Swords, Co. Dublin','Failed','Road','Temperature-sensitive, do not delay');
INSERT INTO Shipment VALUES (59,5,4,'2026-04-27','2026-05-04','2026-05-06','17 Rose Ave, Limerick','Delivered','Air',NULL);
INSERT INTO Shipment VALUES (60,6,15,'2026-04-16','2026-04-20',NULL,'5 Beech Rd, Naas, Co. Kildare','In Transit','Road','Keep upright at all times');
INSERT INTO Shipment VALUES (61,7,3,'2026-01-30','2026-02-05','2026-02-03','Eccles St, Dublin 7','Delivered','Road','Do not leave unattended');
INSERT INTO Shipment VALUES (62,8,4,'2026-03-10','2026-03-12','2026-03-13','Eccles St, Dublin 7','Delivered','Air','Keep upright at all times');
INSERT INTO Shipment VALUES (63,9,6,'2026-01-10','2026-01-12','2026-01-14','The Mall, Sligo','Delivered','Road','Keep upright at all times');
INSERT INTO Shipment VALUES (64,10,4,'2026-06-06','2026-06-13','2026-06-15','14 Elm St, Waterford','Delivered','Air','Contact pharmacy on arrival');
INSERT INTO Shipment VALUES (65,11,6,'2026-03-21','2026-03-25','2026-03-28','Grafton St, Dublin 2','Delivered','Road',NULL);
INSERT INTO Shipment VALUES (66,12,6,'2026-04-28','2026-05-02','2026-04-30','Eccles St, Dublin 7','Delivered','Road','Temperature-sensitive, do not delay');
INSERT INTO Shipment VALUES (67,13,8,'2026-06-16','2026-06-18',NULL,'St Patrick''s St, Cork','In Transit','Rail','Do not leave unattended');
INSERT INTO Shipment VALUES (68,14,6,'2026-02-12','2026-02-16','2026-02-14','O''Connell St, Dublin 1','Delivered','Road','Contact pharmacy on arrival');
INSERT INTO Shipment VALUES (69,15,12,'2026-06-17','2026-06-19',NULL,'Redmond Sq, Wexford','Pending','Road','Do not leave unattended');
INSERT INTO Shipment VALUES (70,16,15,'2026-07-15','2026-07-21','2026-07-22','5 Beech Rd, Naas, Co. Kildare','Delivered','Rail','Deliver to loading bay 2');
INSERT INTO Shipment VALUES (71,18,14,'2026-04-19','2026-04-22','2026-04-20','Baggot St, Dublin 4','Delivered','Road','Deliver to loading bay 2');
INSERT INTO Shipment VALUES (72,19,9,'2026-04-17','2026-04-22','2026-04-24','Blanchardstown, Dublin 15','Delivered','Sea',NULL);
INSERT INTO Shipment VALUES (73,20,1,'2026-06-21','2026-06-24','2026-06-22','Shop St, Galway','Delivered','Road','Do not leave unattended');
INSERT INTO Shipment VALUES (74,21,8,'2026-02-25','2026-02-27',NULL,'Wilton, Cork','Pending','Rail',NULL);
INSERT INTO Shipment VALUES (75,22,1,'2026-05-03','2026-05-06','2026-05-09','Dooradoyle, Limerick','Delivered','Road','Contact pharmacy on arrival');
INSERT INTO Shipment VALUES (76,23,3,'2026-04-07','2026-04-10','2026-04-12','Doughiska, Galway','Delivered','Road','Temperature-sensitive, do not delay');
INSERT INTO Shipment VALUES (77,24,15,'2026-02-03','2026-02-07','2026-02-05','Wilton, Cork','Delivered','Rail','Temperature-sensitive, do not delay');
INSERT INTO Shipment VALUES (78,25,13,'2026-02-18','2026-02-20','2026-02-22','College Rd, Cork','Delivered','Road','Do not leave unattended');
INSERT INTO Shipment VALUES (79,26,1,'2026-04-11','2026-04-14',NULL,'Doughiska, Galway','Failed','Road','Temperature-sensitive, do not delay');
INSERT INTO Shipment VALUES (80,28,15,'2026-06-13','2026-06-17','2026-06-17','Dooradoyle, Limerick','Delivered','Rail','Signature required on delivery');



-- ShipmentItem (116 rows)
INSERT INTO ShipmentItem VALUES (1,14,50);
INSERT INTO ShipmentItem VALUES (1,19,10);
INSERT INTO ShipmentItem VALUES (2,1,20);
INSERT INTO ShipmentItem VALUES (3,20,150);
INSERT INTO ShipmentItem VALUES (3,16,10);
INSERT INTO ShipmentItem VALUES (4,24,50);
INSERT INTO ShipmentItem VALUES (5,1,10);
INSERT INTO ShipmentItem VALUES (5,2,20);
INSERT INTO ShipmentItem VALUES (6,16,200);
INSERT INTO ShipmentItem VALUES (7,18,25);
INSERT INTO ShipmentItem VALUES (8,17,50);
INSERT INTO ShipmentItem VALUES (8,21,25);
INSERT INTO ShipmentItem VALUES (9,17,5);
INSERT INTO ShipmentItem VALUES (9,24,10);
INSERT INTO ShipmentItem VALUES (10,20,50);
INSERT INTO ShipmentItem VALUES (10,16,25);
INSERT INTO ShipmentItem VALUES (11,14,100);
INSERT INTO ShipmentItem VALUES (11,21,100);
INSERT INTO ShipmentItem VALUES (12,9,25);
INSERT INTO ShipmentItem VALUES (12,16,25);
INSERT INTO ShipmentItem VALUES (13,1,5);
INSERT INTO ShipmentItem VALUES (14,24,150);
INSERT INTO ShipmentItem VALUES (14,17,100);
INSERT INTO ShipmentItem VALUES (15,7,150);
INSERT INTO ShipmentItem VALUES (15,9,20);
INSERT INTO ShipmentItem VALUES (16,24,10);
INSERT INTO ShipmentItem VALUES (17,22,200);
INSERT INTO ShipmentItem VALUES (17,14,10);
INSERT INTO ShipmentItem VALUES (18,24,25);
INSERT INTO ShipmentItem VALUES (19,17,5);
INSERT INTO ShipmentItem VALUES (20,15,20);
INSERT INTO ShipmentItem VALUES (21,14,50);
INSERT INTO ShipmentItem VALUES (21,21,200);
INSERT INTO ShipmentItem VALUES (22,6,50);
INSERT INTO ShipmentItem VALUES (22,8,150);
INSERT INTO ShipmentItem VALUES (22,15,25);
INSERT INTO ShipmentItem VALUES (23,23,50);
INSERT INTO ShipmentItem VALUES (24,17,200);
INSERT INTO ShipmentItem VALUES (24,21,150);
INSERT INTO ShipmentItem VALUES (25,20,100);
INSERT INTO ShipmentItem VALUES (26,20,150);
INSERT INTO ShipmentItem VALUES (26,15,150);
INSERT INTO ShipmentItem VALUES (27,19,50);
INSERT INTO ShipmentItem VALUES (28,17,5);
INSERT INTO ShipmentItem VALUES (29,22,200);
INSERT INTO ShipmentItem VALUES (29,25,20);
INSERT INTO ShipmentItem VALUES (30,12,50);
INSERT INTO ShipmentItem VALUES (30,5,50);
INSERT INTO ShipmentItem VALUES (31,18,20);
INSERT INTO ShipmentItem VALUES (32,22,150);
INSERT INTO ShipmentItem VALUES (33,17,100);
INSERT INTO ShipmentItem VALUES (34,14,150);
INSERT INTO ShipmentItem VALUES (35,14,25);
INSERT INTO ShipmentItem VALUES (35,21,10);
INSERT INTO ShipmentItem VALUES (36,11,20);
INSERT INTO ShipmentItem VALUES (37,25,200);
INSERT INTO ShipmentItem VALUES (37,21,25);
INSERT INTO ShipmentItem VALUES (38,17,200);
INSERT INTO ShipmentItem VALUES (39,14,50);
INSERT INTO ShipmentItem VALUES (40,22,25);
INSERT INTO ShipmentItem VALUES (40,24,150);
INSERT INTO ShipmentItem VALUES (41,23,100);
INSERT INTO ShipmentItem VALUES (42,21,50);
INSERT INTO ShipmentItem VALUES (43,17,100);
INSERT INTO ShipmentItem VALUES (44,14,10);
INSERT INTO ShipmentItem VALUES (44,19,25);
INSERT INTO ShipmentItem VALUES (45,18,200);
INSERT INTO ShipmentItem VALUES (46,17,150);
INSERT INTO ShipmentItem VALUES (47,14,150);
INSERT INTO ShipmentItem VALUES (48,25,200);
INSERT INTO ShipmentItem VALUES (48,15,5);
INSERT INTO ShipmentItem VALUES (49,19,100);
INSERT INTO ShipmentItem VALUES (49,25,150);
INSERT INTO ShipmentItem VALUES (50,20,25);
INSERT INTO ShipmentItem VALUES (51,17,150);
INSERT INTO ShipmentItem VALUES (51,19,5);
INSERT INTO ShipmentItem VALUES (52,21,100);
INSERT INTO ShipmentItem VALUES (53,19,50);
INSERT INTO ShipmentItem VALUES (53,23,50);
INSERT INTO ShipmentItem VALUES (54,14,150);
INSERT INTO ShipmentItem VALUES (55,20,20);
INSERT INTO ShipmentItem VALUES (55,21,25);
INSERT INTO ShipmentItem VALUES (56,21,150);
INSERT INTO ShipmentItem VALUES (56,19,10);
INSERT INTO ShipmentItem VALUES (57,21,50);
INSERT INTO ShipmentItem VALUES (58,17,20);
INSERT INTO ShipmentItem VALUES (59,20,10);
INSERT INTO ShipmentItem VALUES (60,18,200);
INSERT INTO ShipmentItem VALUES (60,25,25);
INSERT INTO ShipmentItem VALUES (61,17,50);
INSERT INTO ShipmentItem VALUES (62,24,200);
INSERT INTO ShipmentItem VALUES (63,18,10);
INSERT INTO ShipmentItem VALUES (64,12,25);
INSERT INTO ShipmentItem VALUES (65,3,25);
INSERT INTO ShipmentItem VALUES (65,1,5);
INSERT INTO ShipmentItem VALUES (66,24,200);
INSERT INTO ShipmentItem VALUES (66,19,10);
INSERT INTO ShipmentItem VALUES (67,20,50);
INSERT INTO ShipmentItem VALUES (68,9,25);
INSERT INTO ShipmentItem VALUES (68,11,150);
INSERT INTO ShipmentItem VALUES (69,8,100);
INSERT INTO ShipmentItem VALUES (69,5,200);
INSERT INTO ShipmentItem VALUES (70,16,100);
INSERT INTO ShipmentItem VALUES (71,16,150);
INSERT INTO ShipmentItem VALUES (72,18,150);
INSERT INTO ShipmentItem VALUES (73,8,20);
INSERT INTO ShipmentItem VALUES (74,15,5);
INSERT INTO ShipmentItem VALUES (74,16,100);
INSERT INTO ShipmentItem VALUES (75,12,200);
INSERT INTO ShipmentItem VALUES (75,9,200);
INSERT INTO ShipmentItem VALUES (76,14,20);
INSERT INTO ShipmentItem VALUES (77,20,5);
INSERT INTO ShipmentItem VALUES (77,15,5);
INSERT INTO ShipmentItem VALUES (78,15,20);
INSERT INTO ShipmentItem VALUES (79,23,50);
INSERT INTO ShipmentItem VALUES (80,24,100);

-- Invoice (80)  -- due_date auto = invoice_date + 15 days
DELETE FROM Invoice;
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (1,1,'2026-02-01',2842.93,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (2,2,'2026-04-23',9267.54,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (3,3,'2026-05-31',2729.93,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (4,4,'2026-04-26',3749.53,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (5,5,'2026-04-17',1782.66,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (6,6,'2026-01-31',1852.68,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (7,7,'2026-03-09',732.69,'Unpaid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (8,8,'2026-01-14',5454.28,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (9,9,'2026-06-09',2628.93,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (10,10,'2026-03-21',7157.44,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (11,11,'2026-04-26',9511.44,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (12,12,'2026-06-15',3363.32,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (13,13,'2026-02-08',1927.37,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (14,14,'2026-06-18',3042.29,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (15,15,'2026-07-16',6237.7,'Unpaid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (16,16,'2026-04-19',8933.24,'Unpaid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (17,17,'2026-04-23',594.95,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (18,18,'2026-06-23',6110.76,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (19,19,'2026-02-28',8626.46,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (20,20,'2026-05-01',5988.68,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (21,21,'2026-04-04',304.38,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (22,22,'2026-02-02',5155.19,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (23,23,'2026-02-16',5719.07,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (24,24,'2026-04-13',3693.31,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (25,25,'2026-06-16',9009.03,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (26,26,'2026-06-18',4481.95,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (27,27,'2026-06-12',8400.38,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (28,28,'2026-02-11',9293.7,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (29,29,'2026-05-08',8599.75,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (30,30,'2026-03-30',4415.79,'Unpaid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (31,31,'2026-02-06',1818.72,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (32,32,'2026-07-19',5233.84,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (33,33,'2026-07-04',1763.9,'Unpaid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (34,34,'2026-01-15',395.1,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (35,35,'2026-04-13',1605.92,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (36,36,'2026-05-31',6269.91,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (37,37,'2026-05-23',7860.71,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (38,38,'2026-02-01',874.31,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (39,39,'2026-05-22',7577.32,'Unpaid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (40,40,'2026-05-23',3776.48,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (41,41,'2026-05-16',1030.06,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (42,42,'2026-03-09',2385.84,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (43,43,'2026-04-22',6282.26,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (44,44,'2026-03-10',8902.66,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (45,45,'2026-05-14',2759.01,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (46,46,'2026-01-18',6671.04,'Unpaid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (47,47,'2026-03-23',6263.47,'Unpaid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (48,48,'2026-02-26',1076.12,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (49,49,'2026-04-06',2706.64,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (50,50,'2026-07-15',2169.88,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (51,51,'2026-01-31',2068.85,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (52,52,'2026-03-08',2509.04,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (53,53,'2026-04-07',9429.08,'Unpaid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (54,54,'2026-06-17',4655.67,'Unpaid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (55,55,'2026-01-12',339.48,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (56,56,'2026-02-02',2459.28,'Unpaid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (57,57,'2026-04-21',6082.84,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (58,58,'2026-05-30',1627.62,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (59,59,'2026-04-27',6076.75,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (60,60,'2026-04-16',6810.9,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (61,61,'2026-01-30',6735.27,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (62,62,'2026-03-12',912.15,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (63,63,'2026-01-12',7379.68,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (64,64,'2026-06-08',8586.73,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (65,65,'2026-03-23',9081.12,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (66,66,'2026-04-28',2173.46,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (67,67,'2026-06-18',1095.22,'Unpaid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (68,68,'2026-02-14',2958.24,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (69,69,'2026-06-17',7661.14,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (70,70,'2026-07-16',3254.37,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (71,71,'2026-04-19',3550.4,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (72,72,'2026-04-18',8764.31,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (73,73,'2026-06-22',8214.84,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (74,74,'2026-02-25',7634.0,'Overdue');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (75,75,'2026-05-05',7484.6,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (76,76,'2026-04-09',728.45,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (77,77,'2026-02-05',8316.07,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (78,78,'2026-02-19',1867.86,'Paid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (79,79,'2026-04-11',2967.28,'Unpaid');
INSERT INTO Invoice (invoice_id, shipment_id, invoice_date, total_amount, payment_status) VALUES (80,80,'2026-06-13',320.65,'Paid');

-- TemperatureRecord (89 rows) — Cold and Frozen shipments only, readings every 6 hours
INSERT INTO TemperatureRecord VALUES (1,2,'2026-04-21 08:00:00',-17.21,'Within Range');
INSERT INTO TemperatureRecord VALUES (2,2,'2026-04-21 14:00:00',-20.05,'Within Range');
INSERT INTO TemperatureRecord VALUES (3,2,'2026-04-21 20:00:00',-16.88,'Within Range');
INSERT INTO TemperatureRecord VALUES (4,2,'2026-04-22 02:00:00',-15.83,'Within Range');
INSERT INTO TemperatureRecord VALUES (5,2,'2026-04-22 08:00:00',-22.68,'Within Range');
INSERT INTO TemperatureRecord VALUES (6,2,'2026-04-22 14:00:00',-20.02,'Within Range');
INSERT INTO TemperatureRecord VALUES (7,2,'2026-04-22 20:00:00',-12.63,'Out of Range');
INSERT INTO TemperatureRecord VALUES (8,5,'2026-04-16 08:00:00',-21.36,'Within Range');
INSERT INTO TemperatureRecord VALUES (9,5,'2026-04-16 14:00:00',-20.99,'Within Range');
INSERT INTO TemperatureRecord VALUES (10,5,'2026-04-16 20:00:00',-23.89,'Within Range');
INSERT INTO TemperatureRecord VALUES (11,5,'2026-04-17 02:00:00',-24.46,'Within Range');
INSERT INTO TemperatureRecord VALUES (12,5,'2026-04-17 08:00:00',-22.23,'Within Range');
INSERT INTO TemperatureRecord VALUES (13,5,'2026-04-17 14:00:00',-19.99,'Within Range');
INSERT INTO TemperatureRecord VALUES (14,5,'2026-04-17 20:00:00',-16.39,'Within Range');
INSERT INTO TemperatureRecord VALUES (15,12,'2026-06-14 08:00:00',4.79,'Within Range');
INSERT INTO TemperatureRecord VALUES (16,12,'2026-06-14 14:00:00',6.37,'Within Range');
INSERT INTO TemperatureRecord VALUES (17,12,'2026-06-14 20:00:00',5.79,'Within Range');
INSERT INTO TemperatureRecord VALUES (18,12,'2026-06-15 02:00:00',4.06,'Within Range');
INSERT INTO TemperatureRecord VALUES (19,12,'2026-06-15 08:00:00',0.96,'Out of Range');
INSERT INTO TemperatureRecord VALUES (20,12,'2026-06-15 14:00:00',4.67,'Within Range');
INSERT INTO TemperatureRecord VALUES (21,12,'2026-06-15 20:00:00',5.43,'Within Range');
INSERT INTO TemperatureRecord VALUES (22,13,'2026-02-08 08:00:00',-13.17,'Out of Range');
INSERT INTO TemperatureRecord VALUES (23,13,'2026-02-08 14:00:00',-22.19,'Within Range');
INSERT INTO TemperatureRecord VALUES (24,13,'2026-02-08 20:00:00',-16.93,'Within Range');
INSERT INTO TemperatureRecord VALUES (25,13,'2026-02-09 02:00:00',-17.9,'Within Range');
INSERT INTO TemperatureRecord VALUES (26,13,'2026-02-09 08:00:00',-17.9,'Within Range');
INSERT INTO TemperatureRecord VALUES (27,13,'2026-02-09 14:00:00',-21.42,'Within Range');
INSERT INTO TemperatureRecord VALUES (28,13,'2026-02-09 20:00:00',-15.72,'Within Range');
INSERT INTO TemperatureRecord VALUES (29,15,'2026-07-15 08:00:00',7.46,'Within Range');
INSERT INTO TemperatureRecord VALUES (30,15,'2026-07-15 14:00:00',3.19,'Within Range');
INSERT INTO TemperatureRecord VALUES (31,15,'2026-07-15 20:00:00',3.36,'Within Range');
INSERT INTO TemperatureRecord VALUES (32,15,'2026-07-16 02:00:00',0.16,'Out of Range');
INSERT INTO TemperatureRecord VALUES (33,15,'2026-07-16 08:00:00',3.36,'Within Range');
INSERT INTO TemperatureRecord VALUES (34,15,'2026-07-16 14:00:00',2.88,'Within Range');
INSERT INTO TemperatureRecord VALUES (35,15,'2026-07-16 20:00:00',4.4,'Within Range');
INSERT INTO TemperatureRecord VALUES (36,22,'2026-02-02 08:00:00',9.64,'Out of Range');
INSERT INTO TemperatureRecord VALUES (37,22,'2026-02-02 14:00:00',5.71,'Within Range');
INSERT INTO TemperatureRecord VALUES (38,22,'2026-02-02 20:00:00',3.07,'Within Range');
INSERT INTO TemperatureRecord VALUES (39,22,'2026-02-03 02:00:00',4.49,'Within Range');
INSERT INTO TemperatureRecord VALUES (40,22,'2026-02-03 08:00:00',7.2,'Within Range');
INSERT INTO TemperatureRecord VALUES (41,22,'2026-02-03 14:00:00',5.4,'Within Range');
INSERT INTO TemperatureRecord VALUES (42,30,'2026-03-28 08:00:00',4.57,'Within Range');
INSERT INTO TemperatureRecord VALUES (43,30,'2026-03-28 14:00:00',6.2,'Within Range');
INSERT INTO TemperatureRecord VALUES (44,30,'2026-03-28 20:00:00',6.48,'Within Range');
INSERT INTO TemperatureRecord VALUES (45,30,'2026-03-29 02:00:00',6.9,'Within Range');
INSERT INTO TemperatureRecord VALUES (46,30,'2026-03-29 08:00:00',5.76,'Within Range');
INSERT INTO TemperatureRecord VALUES (47,30,'2026-03-29 14:00:00',3.99,'Within Range');
INSERT INTO TemperatureRecord VALUES (48,36,'2026-05-29 08:00:00',2.83,'Within Range');
INSERT INTO TemperatureRecord VALUES (49,36,'2026-05-29 14:00:00',6.52,'Within Range');
INSERT INTO TemperatureRecord VALUES (50,36,'2026-05-29 20:00:00',5.7,'Within Range');
INSERT INTO TemperatureRecord VALUES (51,36,'2026-05-30 02:00:00',4.59,'Within Range');
INSERT INTO TemperatureRecord VALUES (52,36,'2026-05-30 08:00:00',5.66,'Within Range');
INSERT INTO TemperatureRecord VALUES (53,36,'2026-05-30 14:00:00',5.95,'Within Range');
INSERT INTO TemperatureRecord VALUES (54,64,'2026-06-06 08:00:00',3.29,'Within Range');
INSERT INTO TemperatureRecord VALUES (55,64,'2026-06-06 14:00:00',6.5,'Within Range');
INSERT INTO TemperatureRecord VALUES (56,64,'2026-06-06 20:00:00',4.95,'Within Range');
INSERT INTO TemperatureRecord VALUES (57,64,'2026-06-07 02:00:00',2.51,'Within Range');
INSERT INTO TemperatureRecord VALUES (58,64,'2026-06-07 08:00:00',3.17,'Within Range');
INSERT INTO TemperatureRecord VALUES (59,64,'2026-06-07 14:00:00',7.38,'Within Range');
INSERT INTO TemperatureRecord VALUES (60,65,'2026-03-21 08:00:00',-23.75,'Within Range');
INSERT INTO TemperatureRecord VALUES (61,65,'2026-03-21 14:00:00',-19.61,'Within Range');
INSERT INTO TemperatureRecord VALUES (62,65,'2026-03-21 20:00:00',-19.89,'Within Range');
INSERT INTO TemperatureRecord VALUES (63,65,'2026-03-22 02:00:00',-16.91,'Within Range');
INSERT INTO TemperatureRecord VALUES (64,65,'2026-03-22 08:00:00',-20.84,'Within Range');
INSERT INTO TemperatureRecord VALUES (65,65,'2026-03-22 14:00:00',-22.73,'Within Range');
INSERT INTO TemperatureRecord VALUES (66,68,'2026-02-12 08:00:00',4.42,'Within Range');
INSERT INTO TemperatureRecord VALUES (67,68,'2026-02-12 14:00:00',2.96,'Within Range');
INSERT INTO TemperatureRecord VALUES (68,68,'2026-02-12 20:00:00',4.22,'Within Range');
INSERT INTO TemperatureRecord VALUES (69,68,'2026-02-13 02:00:00',9.25,'Out of Range');
INSERT INTO TemperatureRecord VALUES (70,68,'2026-02-13 08:00:00',0.88,'Out of Range');
INSERT INTO TemperatureRecord VALUES (71,68,'2026-02-13 14:00:00',2.89,'Within Range');
INSERT INTO TemperatureRecord VALUES (72,69,'2026-06-17 08:00:00',4.46,'Within Range');
INSERT INTO TemperatureRecord VALUES (73,69,'2026-06-17 14:00:00',7.55,'Within Range');
INSERT INTO TemperatureRecord VALUES (74,69,'2026-06-17 20:00:00',7.49,'Within Range');
INSERT INTO TemperatureRecord VALUES (75,69,'2026-06-18 02:00:00',3.19,'Within Range');
INSERT INTO TemperatureRecord VALUES (76,69,'2026-06-18 08:00:00',2.67,'Within Range');
INSERT INTO TemperatureRecord VALUES (77,69,'2026-06-18 14:00:00',3.34,'Within Range');
INSERT INTO TemperatureRecord VALUES (78,73,'2026-06-21 08:00:00',6.19,'Within Range');
INSERT INTO TemperatureRecord VALUES (79,73,'2026-06-21 14:00:00',3.09,'Within Range');
INSERT INTO TemperatureRecord VALUES (80,73,'2026-06-21 20:00:00',6.79,'Within Range');
INSERT INTO TemperatureRecord VALUES (81,73,'2026-06-22 02:00:00',4.53,'Within Range');
INSERT INTO TemperatureRecord VALUES (82,73,'2026-06-22 08:00:00',6.4,'Within Range');
INSERT INTO TemperatureRecord VALUES (83,73,'2026-06-22 14:00:00',6.51,'Within Range');
INSERT INTO TemperatureRecord VALUES (84,75,'2026-05-03 08:00:00',6.53,'Within Range');
INSERT INTO TemperatureRecord VALUES (85,75,'2026-05-03 14:00:00',6.1,'Within Range');
INSERT INTO TemperatureRecord VALUES (86,75,'2026-05-03 20:00:00',7.61,'Within Range');
INSERT INTO TemperatureRecord VALUES (87,75,'2026-05-04 02:00:00',4.9,'Within Range');
INSERT INTO TemperatureRecord VALUES (88,75,'2026-05-04 08:00:00',6.61,'Within Range');
INSERT INTO TemperatureRecord VALUES (89,75,'2026-05-04 14:00:00',5.83,'Within Range');


-- =============================================================================
-- TASK 6: INDEXING
-- =============================================================================
-- Index 1 (SEARCHING): shipment_status is commonly used for searching to
-- know current delivery statement (Pending / In Transit) and Failed shipments for review.

DROP INDEX IF EXISTS idx_shipment_status;

CREATE INDEX idx_shipment_status
    ON shipment (shipment_status);
	
ANALYZE Shipment;
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM shipment
WHERE shipment_status = 'Pending';

-- Index 2 (JOIN / GROUPING): supplier_id is commonly used to connect Shipment and Supplier. Indexing it speeds
-- up joining the tables and grouping shipments by supplier.

DROP INDEX IF EXISTS idx_shipment_supplier;

CREATE INDEX idx_shipment_supplier
    ON shipment (supplier_id);
	
ANALYZE shipment;
EXPLAIN (ANALYZE, BUFFERS)
SELECT sp.supplier_name, COUNT(*) AS shipments
FROM shipment As sh
JOIN supplier As sp on sp.supplier_id=sh.supplier_id
GROUP BY sp.supplier_name;

-- Index 3 (FILTER + SORT): Task 9 finds unpaid/overdue invoices and sorts them by due date.
-- Indexing payment_status and due_date together will speed up both steps.

DROP INDEX IF EXISTS idx_invoice_status_due;

CREATE INDEX idx_invoice_status_due
    ON Invoice (payment_status, due_date);

ANALYZE Invoice;
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM Invoice
WHERE payment_status='Overdue'
Order by due_date DESC;

