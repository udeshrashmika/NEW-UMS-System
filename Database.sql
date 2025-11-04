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



