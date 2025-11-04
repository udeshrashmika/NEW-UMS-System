CREATE DATABASE UMS_DATABASE;
USE UMS_DATABASE;

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


-- 2. Create Table Utility_Type
CREATE TABLE Utility_Type (
    UtilityID VARCHAR(10) PRIMARY KEY,
    UtilityName VARCHAR(50) NOT NULL,
    Unit VARCHAR(10) NOT NULL
);

USE UMS_DATABASE;

CREATE TABLE User_Staff (
    UserID NVARCHAR(20) PRIMARY KEY NOT NULL,         
    Username NVARCHAR(50) UNIQUE NOT NULL,            
    Password NVARCHAR(255) NOT NULL,                  
    FullName NVARCHAR(100) NOT NULL,                  
    Role     NVARCHAR(20) NOT NULL,                       
    CONSTRAINT CHK_UserRole CHECK (Role IN ('Admin', 'FieldOfficer', 'Cashier', 'Manager'))
);
GO


