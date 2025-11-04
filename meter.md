CREATE TABLE Meter (
    MeterID VARCHAR(15) PRIMARY KEY,
    CustomerID VARCHAR(10),
    UtilityID VARCHAR(10),
    Status VARCHAR(20),
    Location VARCHAR(50),
    InstallDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (UtilityID) REFERENCES Utility_Type(UtilityID)
);

