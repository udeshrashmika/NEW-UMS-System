# NEW-UMS-System

--DATA BASE--

-- Check if the database already exists and drop it if it does
-- This allows you to re-run the script multiple times without errors
IF DB_ID('UMS_NSBM') IS NOT NULL
BEGIN
    ALTER DATABASE UMS_NSBM SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE UMS_NSBM;
END
GO

-- Create the new database
CREATE DATABASE UMS_NSBM;
GO

-- Switch to the context of the new database
USE UMS_NSBM;
GO

-------------------------------------------------
-- 1. CREATE TABLES (IN ORDER OF DEPENDENCY)
-------------------------------------------------

-- Table: Customer (No dependencies)
CREATE TABLE Customer (
    CustomerID NVARCHAR(20) PRIMARY KEY NOT NULL,
    CustomerName NVARCHAR(100) NOT NULL,
    CustomerType NVARCHAR(20) NOT NULL,
    ServiceAddress NVARCHAR(255) NOT NULL,
    BillingAddress NVARCHAR(255) NULL,
    Email NVARCHAR(100) UNIQUE NULL,
    Phone NVARCHAR(20) NULL,
    RegistrationDate DATE NOT NULL,
    -- Add CHECK constraint for ENUM values
    CONSTRAINT CHK_CustomerType CHECK (CustomerType IN ('Household', 'Business', 'Government'))
);
GO

-- Table: User_Staff (No dependencies)
CREATE TABLE User_Staff (
    UserID NVARCHAR(20) PRIMARY KEY NOT NULL,
    Username NVARCHAR(50) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL, -- In a real app, store a strong hash
    FullName NVARCHAR(100) NOT NULL,
    Role NVARCHAR(20) NOT NULL,
    -- Add CHECK constraint for ENUM values
    CONSTRAINT CHK_UserRole CHECK (Role IN ('Admin', 'FieldOfficer', 'Cashier', 'Manager'))
);
GO

-- Table: Utility_Type (No dependencies)
CREATE TABLE Utility_Type (
    UtilityID NVARCHAR(20) PRIMARY KEY NOT NULL,
    UtilityName NVARCHAR(50) NOT NULL,
    Unit NVARCHAR(10) NOT NULL -- e.g., 'kWh', 'm³', 'Unit'
);
GO

-- Table: Meter (Depends on Customer, Utility_Type)
CREATE TABLE Meter (
    MeterID NVARCHAR(50) PRIMARY KEY NOT NULL,
    CustomerID NVARCHAR(20) NOT NULL FOREIGN KEY REFERENCES Customer(CustomerID),
    UtilityID NVARCHAR(20) NOT NULL FOREIGN KEY REFERENCES Utility_Type(UtilityID),
    Status NVARCHAR(20) NOT NULL,
    Location NVARCHAR(100) NULL,
    InstallDate DATE NULL,
    -- Add CHECK constraint for ENUM values
    CONSTRAINT CHK_MeterStatus CHECK (Status IN ('Active', 'Pending Install', 'Inactive'))
);
GO

-- Table: Meter_Reading (Depends on Meter, User_Staff)
CREATE TABLE Meter_Reading (
    ReadingID INT IDENTITY(1,1) PRIMARY KEY NOT NULL, -- IDENTITY(1,1) is T-SQL for AUTO_INCREMENT
    MeterID NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES Meter(MeterID),
    UserID NVARCHAR(20) NOT NULL FOREIGN KEY REFERENCES User_Staff(UserID),
    ReadingValue DECIMAL(10, 2) NOT NULL,
    ReadingDate DATE NOT NULL,
    Notes NVARCHAR(MAX) NULL -- NVARCHAR(MAX) is T-SQL for TEXT
);
GO

-- Table: Tariff (Depends on Utility_Type)
CREATE TABLE Tariff (
    TariffID NVARCHAR(20) PRIMARY KEY NOT NULL,
    UtilityID NVARCHAR(20) NOT NULL FOREIGN KEY REFERENCES Utility_Type(UtilityID),
    TariffName NVARCHAR(100) NOT NULL,
    Rate DECIMAL(10, 2) NOT NULL,
    MinUnits DECIMAL(10, 2) DEFAULT 0,
    MaxUnits DECIMAL(10, 2) NULL,
    FixedCharge DECIMAL(10, 2) DEFAULT 0
);
GO

-- Table: Bill (Depends on Customer, Meter, Meter_Reading)
CREATE TABLE Bill (
    BillID NVARCHAR(50) PRIMARY KEY NOT NULL,
    CustomerID NVARCHAR(20) NOT NULL FOREIGN KEY REFERENCES Customer(CustomerID),
    MeterID NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES Meter(MeterID),
    ReadingID INT NOT NULL FOREIGN KEY REFERENCES Meter_Reading(ReadingID),
    BillDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    PreviousReadingValue DECIMAL(10, 2) NOT NULL,
    CurrentReadingValue DECIMAL(10, 2) NOT NULL,
    Consumption AS (CurrentReadingValue - PreviousReadingValue), -- Computed column
    AmountDue DECIMAL(10, 2) NOT NULL,
    Status NVARCHAR(10) NOT NULL,
    -- Add CHECK constraint for ENUM values
    CONSTRAINT CHK_BillStatus CHECK (Status IN ('Unpaid', 'Paid', 'Overdue'))
);
GO

-- Table: Payment (Depends on Bill, User_Staff)
CREATE TABLE Payment (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    BillID NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES Bill(BillID),
    UserID NVARCHAR(20) NOT NULL FOREIGN KEY REFERENCES User_Staff(UserID),
    PaymentAmount DECIMAL(10, 2) NOT NULL,
    PaymentDate DATETIME NOT NULL,
    PaymentMethod NVARCHAR(10) NOT NULL,
    -- Add CHECK constraint for ENUM values
    CONSTRAINT CHK_PaymentMethod CHECK (PaymentMethod IN ('Cash', 'Card', 'Online'))
);
GO

-------------------------------------------------
-- 2. INSERT SAMPLE DATA
-------------------------------------------------

-- Insert User_Staff (4 roles)
INSERT INTO User_Staff (UserID, Username, PasswordHash, FullName, Role)
VALUES
('ADM-001', 'admin', 'hashed_password', 'Admin User', 'Admin'),
('FLD-001', 'field', 'hashed_password', 'Field Officer 1', 'FieldOfficer'),
('CSH-001', 'cashier', 'hashed_password', 'Cashier User', 'Cashier'),
('MGR-001', 'manager', 'hashed_password', 'Manager User', 'Manager');
GO

-- Insert Customers (from our prototype)
INSERT INTO Customer (CustomerID, CustomerName, CustomerType, ServiceAddress, BillingAddress, Email, Phone, RegistrationDate)
VALUES
('CUST-001', 'John Doe', 'Household', '123 Galle Rd, Colombo 03', '123 Galle Rd, Colombo 03', 'john.doe@example.com', '+94771234567', '2024-01-15'),
('CUST-002', 'ABC Holdings PLC', 'Business', '45 Main St, Kandy', 'PO Box 15, Kandy', 'accounts@abc.com', '+94112555888', '2023-05-10'),
('CUST-003', 'Ministry of Education', 'Government', 'Isurupaya, Battaramulla', 'Isurupaya, Battaramulla', 'info@moe.gov.lk', '+94112785141', '2022-02-01');
GO

-- Insert Utility_Types
INSERT INTO Utility_Type (UtilityID, UtilityName, Unit)
VALUES
('ELEC', 'Electricity', 'kWh'),
('WATR', 'Water', 'm³'),
('GAS', 'Gas', 'Unit');
GO

-- Insert Meters (from our prototype)
INSERT INTO Meter (MeterID, CustomerID, UtilityID, Status, Location, InstallDate)
VALUES
('MTR-E-001', 'CUST-001', 'ELEC', 'Active', '123 Galle Rd, Colombo 03', '2024-01-20'),
('MTR-W-001', 'CUST-001', 'WATR', 'Active', '123 Galle Rd, Colombo 03', '2024-01-20'),
('MTR-E-002', 'CUST-002', 'ELEC', 'Active', '45 Main St, Kandy', '2023-05-15'),
('MTR-G-001', 'CUST-002', 'GAS', 'Pending Install', '45 Main St, Kandy', NULL);
GO

-- Insert Meter_Readings (sample data)
-- We need readings to generate bills
INSERT INTO Meter_Reading (MeterID, UserID, ReadingValue, ReadingDate, Notes)
VALUES
('MTR-E-001', 'FLD-001', 14502.00, '2025-10-19', 'Meter box OK'),
('MTR-E-002', 'FLD-001', 75000.00, '2025-10-19', 'Large complex'),
('MTR-W-001', 'FLD-001', 120.00, '2025-10-18', NULL);
GO

-- Insert Tariff Plans (from our prototype)
INSERT INTO Tariff (TariffID, UtilityID, TariffName, Rate, MinUnits, MaxUnits)
VALUES
('ELEC-S1', 'ELEC', 'Domestic (0-60 kWh)', 30.00, 0, 60),
('ELEC-S2', 'ELEC', 'Domestic (61-90 kWh)', 45.00, 61, 90),
('WATR-D1', 'WATR', 'Domestic Water', 60.00, 0, NULL),
('GAS-D1', 'GAS', 'Domestic Gas', 4000.00, 0, NULL);
GO

-- Insert Bills (from our prototype)
-- Note: Manually entering sample data that would normally be calculated
INSERT INTO Bill (BillID, CustomerID, MeterID, ReadingID, BillDate, DueDate, PreviousReadingValue, CurrentReadingValue, AmountDue, Status)
VALUES
('BILL-1050', 'CUST-001', 'MTR-E-001', 1, '2025-10-20', '2025-11-05', 14387.00, 14502.00, 3450.00, 'Unpaid'), -- John Doe
('BILL-1051', 'CUST-002', 'MTR-E-002', 2, '2025-10-20', '2025-11-05', 70000.00, 75000.00, 78200.00, 'Unpaid'), -- ABC Holdings
('BILL-1048', 'CUST-001', 'MTR-W-001', 3, '2025-10-19', '2025-11-04', 100.00, 120.00, 1500.00, 'Paid'); -- Ministry of Edu (oops, CUST-003)
GO
-- Let's fix that last bill to be for CUST-003
UPDATE Bill SET CustomerID = 'CUST-003' WHERE BillID = 'BILL-1048';
GO

-- Insert one Payment (for the 'Paid' bill)
INSERT INTO Payment (BillID, UserID, PaymentAmount, PaymentDate, PaymentMethod)
VALUES
('BILL-1048', 'CSH-001', 1500.00, '2025-10-22 14:30:00', 'Cash');
GO




