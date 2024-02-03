-- Advanced Database Task 1

-- Task 1.1

-- Important Notes:
-- For convenience, the required objects have already been created in the included .BAK File
-- To demonstrate the functionality of these objects, kindly head to section 6.A 
-- There you will insert the sample records and move on to 6.B for the functionality checks
-- Alternatively, simply run this query per section for a uninterrupted session
-- Thank you!

---------------------------------
-- + 1.Creating the Database + --
---------------------------------

-- Drops Existing Database to Avoid Errors
DROP DATABASE IF EXISTS LibraryDB;

-- Creates the Database
CREATE DATABASE LibraryDB;

-- Uses the Database
USE LibraryDB;
GO

-------------------------------
-- + 1.Creating the Tables + --
-------------------------------

-- Creates the Members Table
CREATE TABLE Members (
    MemberID		INT IDENTITY NOT NULL,
    FirstName		VARCHAR(50) NOT NULL,
    LastName		VARCHAR(50) NOT NULL,
    DateOfBirth		DATE NOT NULL,
    Email			NVARCHAR(100) NULL,
    PhoneNumber		VARCHAR(20) NULL,
    DateJoined		DATE NOT NULL
);

-- Creates the MemberAddress Table
CREATE TABLE MemberAddress (
	AddressID   INT IDENTITY NOT NULL,
    MemberID    INT NOT NULL,
    Address1    NVARCHAR(100) NOT NULL,
    Address2    NVARCHAR(100) NULL,
    City        NVARCHAR(50) NOT NULL,
    Postcode    NVARCHAR(10) NOT NULL
);

-- Creates the MemberLogin Table
CREATE TABLE MemberLogin (
    MemberID            INT NOT NULL,
    Username            NVARCHAR(50) NOT NULL,
    PasswordHash        VARBINARY(64) NOT NULL,
    Salt                UNIQUEIDENTIFIER NOT NULL
);

-- Creates the Fines Table
CREATE TABLE Fines (
    FineID              INT IDENTITY NOT NULL,
    MemberID            INT NOT NULL,
    LoanID              INT NOT NULL,
    Amount              MONEY NOT NULL,
    DateIssued          DATE NOT NULL,
    DateRepaid          DATE NULL,
    OutstandingBalance  MONEY NOT NULL
);

-- Creates the Repayments Table
CREATE TABLE Repayments (
	RepaymentID		INT IDENTITY NOT NULL,
	FineID			INT NOT NULL,
	Amount			MONEY NOT NULL,
	Date			DATE NOT NULL,
	Method			NVARCHAR(50) NOT NULL,
);

-- Creates the LibraryItems Table
CREATE TABLE LibraryItems (
	ItemID			INT IDENTITY NOT NULL,
	Title			NVARCHAR(100) NOT NULL,
	ItemType		NVARCHAR(50) NOT NULL,
	Author			NVARCHAR(100) NOT NULL,
	DatePublished	DATE NOT NULL,
	DateAdded		DATE NOT NULL,
	Status			NVARCHAR(50) NOT NULL,
	ISBN			NVARCHAR(50) NULL,
	DateIdentified	DATE NULL
);

-- Creates the Loans Table
CREATE TABLE Loans (
	LoanID			INT IDENTITY NOT NULL,
	MemberID		INT NOT NULL,
	ItemID			INT NOT NULL,
	DateTaken		DATE NOT NULL,
	DateDue			DATE NOT NULL,
	DateReturned	DATE NULL
);

-- Creates the Archive Table
CREATE TABLE Archive (
	MemberID		INT NOT NULL,
	FirstName		VARCHAR(50) NOT NULL,
	LastName		VARCHAR(50) NOT NULL,
	DateOfBirth		DATE NOT NULL,
	Email			NVARCHAR(100) NULL,
	PhoneNumber		VARCHAR(20) NULL,
	DateJoined		DATE NOT NULL,
	DateArchived	DATE NOT NULL
);

-----------------------------------------------------
-- + 1.Creating the Constraints for Primary Keys + --
-----------------------------------------------------

-- Creates the Constraints for the Members Table
ALTER TABLE Members
ADD CONSTRAINT PK_Members PRIMARY KEY (MemberID);

-- Creates the Constraints for the MemberAddress Table
ALTER TABLE MemberAddress
ADD CONSTRAINT PK_MemberAddress PRIMARY KEY (AddressID);

-- Creates the Constraints for the MemberLogin Table
ALTER TABLE MemberLogin
ADD CONSTRAINT PK_MemberLogin PRIMARY KEY (MemberID);

-- Creates the Constraints for the Fines Table
ALTER TABLE Fines
ADD CONSTRAINT PK_Fines PRIMARY KEY (FineID);

-- Creates the Constraints for the Repayments Table
ALTER TABLE Repayments
ADD CONSTRAINT PK_Repayments PRIMARY KEY (RepaymentID);

-- Creates the Constraints for the LibaryItems Table
ALTER TABLE LibraryItems
ADD CONSTRAINT PK_LibraryItems PRIMARY KEY (ItemID);

-- Creates the Constraints for the Loans Table
ALTER TABLE Loans
ADD CONSTRAINT PK_Loans PRIMARY KEY (LoanID);

-- Creates the Constraints for the Archive Table
ALTER TABLE Archive
ADD CONSTRAINT PK_Archive PRIMARY KEY (MemberID);

-----------------------------------------------------
-- + 1.Creating the Constraints for Foreign Keys + --
-----------------------------------------------------

-- Creates the Foreign Key Constraint Between MemberAddress & Members Table
ALTER TABLE MemberAddress
ADD CONSTRAINT FK_MemberAddress_Members FOREIGN KEY (MemberID) REFERENCES Members(MemberID) ON DELETE CASCADE;

-- Creates the Foreign Key Constraint Between MemberLogin & Members Table
ALTER TABLE MemberLogin
ADD CONSTRAINT FK_MemberLogin_Members FOREIGN KEY (MemberID) REFERENCES Members(MemberID) ON DELETE CASCADE;

-- Creates the Foreign Key Constraint Between Fines & Members Table
ALTER TABLE Fines
ADD CONSTRAINT FK_Fines_Members FOREIGN KEY (MemberID) REFERENCES Members(MemberID);

-- Creates the Foreign Key Constraint Between Repayments & Fines Table
ALTER TABLE Repayments
ADD CONSTRAINT FK_Repayments_Fines FOREIGN KEY (FineID) REFERENCES Fines(FineID);

-- Creates the Foreign Key Constraint Between Loans & Members Table
ALTER TABLE Loans
ADD CONSTRAINT FK_Loans_Members FOREIGN KEY (MemberID) REFERENCES Members(MemberID);

-- Creates the Foreign Key Constraint Between Loans & LibraryItems Table
ALTER TABLE Loans
ADD CONSTRAINT FK_Loans_LibraryItems FOREIGN KEY (ItemID) REFERENCES LibraryItems(ItemID);

-----------------------------------------------
-- + 1.Creating the Additional Constraints + --
-----------------------------------------------

-- Creates the Constraint to Ensure Member Email Inputs Valid Format
ALTER TABLE Members
ADD CONSTRAINT CHK_EmailFormat CHECK (Email LIKE '%_@_%._%');

-- Creates the Constraint to Ensure MemberLogin Does Not Contain Repeat Usernames
ALTER TABLE MemberLogin
ADD CONSTRAINT UQ_MemberLogin_Username UNIQUE (Username);

-- Creates the Constraint to Ensure OutstandingBalance is Not Greater Than Amount in Fines Table
ALTER TABLE Fines
ADD CONSTRAINT CK_Fines_OutstandingBalance CHECK (OutstandingBalance <= Amount);

-- Creates the Constraint to Ensure Payment Method is Cash or Card
ALTER TABLE Repayments
ADD CONSTRAINT CHK_Repayments_Method CHECK (Method IN ('Credit Card', 'Debit Card', 'Cash'));

-- Creates the Constraint to Ensure Item Status is Valid
ALTER TABLE LibraryItems
ADD CONSTRAINT CHK_LibraryItems_Status CHECK (Status IN ('Available', 'Lost', 'Removed', 'On Loan', 'Overdue'));

-- Creates the Constraint to Ensure DateReturned is Not Earlier Than DateTaken or Later Than DateDue in Loans Table
ALTER TABLE Loans
ADD CONSTRAINT CK_Loans_Dates CHECK (DateReturned IS NULL OR (DateReturned >= DateTaken OR DateReturned <= DateDue));

----------------------------------------------
-- + 2.Creating the Procedures/Functions + --
----------------------------------------------

-- Procedure/Function 1 -- 
-- Creates a Procedure to Search the LibraryItems for Matching Character 
-- Strings by Title, Results Sorted by Most Recent Published Date
CREATE OR ALTER PROCEDURE SearchLibrary
    @title NVARCHAR(100)
AS
BEGIN
    SELECT *
    FROM LibraryItems
    WHERE Title LIKE '%' + @title + '%'
    ORDER BY DatePublished DESC;
END;

-- Procedure/Function 2 --
-- Creates a Function to Return the Full List of Items Currently On Loan
-- With a Due Date of Less Than Five Days from the Current Date (System Date)
CREATE OR ALTER FUNCTION GetLoan()
RETURNS @result TABLE (
    ItemID INT,
    Title NVARCHAR(100),
    DateDue DATE
)
AS
BEGIN
    INSERT INTO @result
    SELECT i.ItemID, i.Title, l.DateDue
    FROM LibraryItems i
    INNER JOIN Loans l ON i.ItemID = l.ItemID
    WHERE l.DateDue <= DATEADD(DAY, 5, GETDATE()) AND l.DateReturned IS NULL
    ORDER BY l.DateDue ASC;
    RETURN;
END;

-- Procedure/Function 3 --
-- Creates a Procedure to Insert a New Member in the Library Database
CREATE OR ALTER PROCEDURE InsertMember
    @FirstName      VARCHAR(50),
    @LastName       VARCHAR(50),
    @DateOfBirth    DATE,
    @Address1       NVARCHAR(100),
    @Address2       NVARCHAR(100) = NULL,
    @City           NVARCHAR(50),
    @Postcode       NVARCHAR(10),
    @Username       NVARCHAR(50),
    @Password       NVARCHAR(50),
    @Email          NVARCHAR(100) = NULL,
    @PhoneNumber    VARCHAR(20) = NULL
AS
BEGIN
    
    -- Inserts the New Member's Details in the Members Table
    INSERT INTO Members (FirstName, LastName, DateOfBirth, Email, PhoneNumber, DateJoined)
    VALUES (@FirstName, @LastName, @DateOfBirth, @Email, @PhoneNumber, GETDATE());
    
    DECLARE @MemberID INT = SCOPE_IDENTITY();
    
    -- Inserts the New Member's Address in the MemberAddress Table
    INSERT INTO MemberAddress (MemberID, Address1, Address2, City, Postcode)
    VALUES (@MemberID, @Address1, @Address2, @City, @Postcode);
    
    -- Generates Salt for Password Hashing
    DECLARE @Salt UNIQUEIDENTIFIER = NEWID();
    
    -- Hash Password with Salt
    DECLARE @PasswordHash VARBINARY(64) = HASHBYTES('SHA2_512', @Password + CAST(@Salt AS NVARCHAR(36)));
    
    -- Inserts the New Member's Login Details in the MemberLogin Table
    INSERT INTO MemberLogin (MemberID, Username, PasswordHash, Salt)
    VALUES (@MemberID, @Username, @PasswordHash, @Salt);
END;

-- Procedure/Function 4 --
-- Creates a Procedure to Update an Existing Member's Details
CREATE OR ALTER PROCEDURE UpdateMember
	@MemberID		INT,
	@FirstName		VARCHAR(50) = NULL,
	@LastName		VARCHAR(50) = NULL,
	@DateOfBirth	DATE = NULL,
	@Address1		NVARCHAR(100) = NULL,
	@Address2		NVARCHAR(100) = NULL,
	@City			NVARCHAR(50) = NULL,
	@Postcode		NVARCHAR(10) = NULL,
	@Username		NVARCHAR(50) = NULL,
	@Password		NVARCHAR(50) = NULL,
	@Email			NVARCHAR(100) = NULL,
	@PhoneNumber	VARCHAR(20) = NULL
AS
BEGIN

    -- Updates the Member's Details in the Members Table
    IF	@FirstName IS NOT NULL OR @LastName IS NOT NULL OR @DateOfBirth IS NOT NULL OR 
		@Email IS NOT NULL OR @PhoneNumber IS NOT NULL
    BEGIN
        UPDATE Members
        SET FirstName = COALESCE(@FirstName, FirstName),
            LastName = COALESCE(@LastName, LastName),
            DateOfBirth = COALESCE(@DateOfBirth, DateOfBirth),
            Email = COALESCE(@Email, Email),
            PhoneNumber = COALESCE(@PhoneNumber, PhoneNumber)
        WHERE MemberID = @MemberID;
    END;

    -- Updates the Member's Address in the MemberAddress table
    IF @Address1 IS NOT NULL OR @Address2 IS NOT NULL OR @City IS NOT NULL OR @Postcode IS NOT NULL
    BEGIN
        UPDATE MemberAddress
        SET Address1 = COALESCE(@Address1, Address1),
            Address2 = COALESCE(@Address2, Address2),
            City = COALESCE(@City, City),
            Postcode = COALESCE(@Postcode, Postcode)
        WHERE MemberID = @MemberID;
    END;

	-- Updates the Member's Login Details in the MemberLogin Table
    IF @Username IS NOT NULL OR @Password IS NOT NULL
	BEGIN
		UPDATE MemberLogin
		SET Username = ISNULL(@Username, Username),
			PasswordHash = CASE WHEN @Password IS NOT NULL THEN HASHBYTES('SHA2_512', 
			@Password + CAST(NEWID() AS NVARCHAR(36))) ELSE PasswordHash END,
			Salt = CASE WHEN @Password IS NOT NULL THEN NEWID() ELSE Salt END
		WHERE MemberID = @MemberID;
	END;
END;

---------------------------------------------
-- + 3.Creating the View for Loan History + --
---------------------------------------------

-- Creates the View to Identify the Loan History --
CREATE OR ALTER VIEW LoanHistory AS
SELECT l.LoanID, l.MemberID, l.ItemID, li.Title, li.ItemType, li.Author,
    l.DateTaken, l.DateDue, l.DateReturned,
    SUM(f.Amount) AS TotalFines,
    COALESCE(SUM(CASE WHEN r.Amount IS NOT NULL THEN r.Amount ELSE 0 END), 0) AS TotalRepayments,
    SUM(f.OutstandingBalance) AS OutstandingBalance
FROM Loans l
INNER JOIN LibraryItems li ON l.ItemID = li.ItemID
LEFT JOIN Fines f ON l.LoanID = f.LoanID
LEFT JOIN Repayments r ON f.FineID = r.FineID
GROUP BY l.LoanID, l.MemberID, l.ItemID, li.Title, li.ItemType, li.Author,
    l.DateTaken, l.DateDue, l.DateReturned;

---------------------------------------------------------------------------
-- + 4.Creating Triggers to Automatically Update the Status of an Item + --
---------------------------------------------------------------------------

-- Creates the Trigger to Update Item Status to Overdue --
CREATE OR ALTER TRIGGER TRG_Overdue
ON Loans
AFTER UPDATE
AS
BEGIN
    IF (UPDATE(DateReturned) OR UPDATE(DateDue))
    BEGIN
        UPDATE LibraryItems SET Status = 'Overdue' WHERE ItemID IN (SELECT ItemID FROM inserted)
        AND (SELECT DateReturned FROM inserted) IS NULL AND (SELECT DateDue FROM inserted) < GETDATE();
    END
END;

-- Creates the Trigger to Update Item Status to Available --
CREATE OR ALTER TRIGGER TRG_Available
ON Loans
AFTER UPDATE
AS
BEGIN
    IF (UPDATE(DateReturned))
    BEGIN
        UPDATE LibraryItems SET Status = 'Available' WHERE ItemID = (SELECT ItemID FROM inserted)
        AND (SELECT DateReturned FROM inserted) IS NOT NULL;
    END
END;

------------------------------------------------------------------------
-- + 5.Creating a View to Identify the Loan Count on Specified Date + --
------------------------------------------------------------------------

-- Creates the View to Identify Loan Count on Specified Date --
CREATE OR ALTER VIEW LoanCount AS
SELECT DateTaken, COUNT(*) AS TotalLoans
FROM Loans
GROUP BY DateTaken;

-------------------------------------------
-- + 7.Creating the Additional Objects + --
-------------------------------------------

-- Creates a Trigger to Archive a Leaving Member --
CREATE OR ALTER TRIGGER TRG_Archive
ON Members
AFTER DELETE AS
BEGIN
  INSERT INTO Archive
  (MemberID, FirstName, LastName, DateOfBirth, Email, PhoneNumber, DateJoined, DateArchived)
  SELECT d.MemberID, d.FirstName, d.LastName, d.DateOfBirth, d.Email, d.PhoneNumber, d.DateJoined, GETDATE()
  FROM deleted d;
END;

-- Creates the Trigger to Calculate Overdue Fees --
CREATE OR ALTER TRIGGER TRG_OverdueFee
ON Loans
AFTER UPDATE, INSERT
AS
BEGIN

    DECLARE @LoanID INT, @DueDate DATE, @MemberID INT, @DateReturned DATE, @OverdueDays INT, @Fee MONEY;
    
    SELECT @LoanID = i.LoanID, @DueDate = i.DateDue, @MemberID = i.MemberID, @DateReturned = i.DateReturned
    FROM inserted i;
    
    IF (@DateReturned IS NOT NULL)
    BEGIN
        SET @OverdueDays = DATEDIFF(DAY, @DueDate, @DateReturned);
        IF (@OverdueDays > 0)
        BEGIN
            SET @Fee = CAST(@OverdueDays AS MONEY) * 0.10;
            INSERT INTO Fines (MemberID, LoanID, Amount, DateIssued, OutstandingBalance)
            VALUES (@MemberID, @LoanID, @Fee, GETDATE(), @Fee);
        END
    END
END;

-- Creates a Procedure to Process Repayments --
CREATE OR ALTER PROCEDURE ProcessPay
    @FineID INT,
    @RepaymentAmount MONEY,
    @RepaymentMethod NVARCHAR(50)
AS
BEGIN
    DECLARE @RepaymentDate DATE = GETDATE()
    
    -- Checks If Payment Amount is Valid
    DECLARE @FineBalance MONEY
    SELECT @FineBalance = OutstandingBalance
    FROM Fines
    WHERE FineID = @FineID
    
    IF @RepaymentAmount <= 0 OR @RepaymentAmount > @FineBalance
    BEGIN
        PRINT 'Payment Amount Must Be Greater Than 0 and Within the Outstanding Amount.'
        RETURN
    END
    
    -- Updates the DateRepaid & Outstanding Balance in the Fines Table
    UPDATE Fines
    SET OutstandingBalance = OutstandingBalance - @RepaymentAmount,
        DateRepaid = CASE WHEN (OutstandingBalance - @RepaymentAmount) = 0 THEN GETDATE() ELSE DateRepaid END
    WHERE FineID = @FineID
    
    -- Inserts Details of the Payment to the Repayments Table
    INSERT INTO Repayments (FineID, Amount, Date, Method)
    VALUES (@FineID, @RepaymentAmount, @RepaymentDate, @RepaymentMethod)
    
    PRINT 'Payment Successful.'
END;

-- Creates a Procedure to Insert a New Item --
CREATE OR ALTER PROCEDURE AddItem
    @Title NVARCHAR(100),
    @ItemType NVARCHAR(50),
    @Author NVARCHAR(100),
    @DatePublished DATE,
    @DateAdded DATE,
    @Status NVARCHAR(50),
    @ISBN NVARCHAR(50) = NULL,
    @DateIdentified DATE = NULL
AS
BEGIN

    INSERT INTO LibraryItems (Title, ItemType, Author, DatePublished, DateAdded, Status, ISBN, DateIdentified)
    VALUES (@Title, @ItemType, @Author, @DatePublished, @DateAdded, @Status, @ISBN, @DateIdentified)
END;

-- Creates a Procedure to Update an Item --
CREATE OR ALTER PROCEDURE UpdateItem
    @ItemID INT,
    @Title NVARCHAR(100) = NULL,
    @ItemType NVARCHAR(50) = NULL,
    @Author NVARCHAR(100) = NULL,
    @DatePublished DATE = NULL,
    @DateAdded DATE = NULL,
    @Status NVARCHAR(50) = NULL,
    @DateIdentified DATE = NULL,
    @ISBN NVARCHAR(50) = NULL
AS
BEGIN
    UPDATE LibraryItems
    SET Title = ISNULL(@Title, Title),
        ItemType = ISNULL(@ItemType, ItemType),
        Author = ISNULL(@Author, Author),
        DatePublished = ISNULL(@DatePublished, DatePublished),
        DateAdded = ISNULL(@DateAdded, DateAdded),
        Status = ISNULL(@Status, Status),
        DateIdentified = ISNULL(@DateIdentified, DateIdentified),
        ISBN = ISNULL(@ISBN, ISBN)
    WHERE ItemID = @ItemID
END;

-- Creates a Set Condition Type Trigger for Non-Book Item's ISBN to None --
CREATE OR ALTER TRIGGER LibraryISBN
ON LibraryItems
AFTER INSERT
AS
BEGIN
    IF NOT EXISTS(SELECT 1 FROM inserted WHERE ItemType = 'Book')
    BEGIN
        UPDATE LibraryItems
        SET ISBN = 'None'
        WHERE ItemID IN (SELECT ItemID FROM Inserted);
    END
END;

------------------------------------------------------------------------------
-- + 6.A Inserting Sample Records to the Tables to Demonstrate Functionality --
------------------------------------------------------------------------------

-- Inserts Sample Records to the Member Information Tables
EXEC InsertMember 
    @FirstName = 'Anakin',
    @LastName = 'Skywalker',
    @DateOfBirth = '2000-05-01',
    @Address1 = 'Mos',
	@Address2 = 'Espa',
    @City = 'Tatooine',
    @Postcode = 'TM01',
    @Username = 'ChosenOne',
    @Password = 'Padme4Ever',
	@Email = 'anakin.skywalker@jediorder.com',
    @PhoneNumber = '123-1234';

EXEC InsertMember 
    @FirstName = 'Obi-Wan',
    @LastName = 'Kenobi',
    @DateOfBirth = '1990-01-01',
    @Address1 = 'Jedi',
	@Address2 = 'Temple',
    @City = 'Coruscant',
    @Postcode = 'JT10',
    @Username = 'Ben',
    @Password = 'HighGround',
	@Email = 'obiwan.kenobi@jediorder.com',
    @PhoneNumber = '222-1234';

EXEC InsertMember 
    @FirstName = 'Ahsoka',
    @LastName = 'Tano',
    @DateOfBirth = '2002-02-01',
    @Address1 = 'Jedi',
	@Address2 = 'Temple',
    @City = 'Coruscant',
    @Postcode = 'JT10',
    @Username = 'Snips',
    @Password = 'SkyGuy',
	@Email = 'ahsoka.tano@jediorder.com',
    @PhoneNumber = '789-9876';

EXEC InsertMember
	@FirstName = 'Padme',
	@LastName = 'Amidala',
	@DateOfBirth = '2000-04-01',
	@Address1 = 'Theed',
	@Address2 = 'Palace',
	@City = 'Naboo',
	@Postcode = 'TP50',
	@Username = 'Queen',
	@Password = 'Ani4Ever',
	@Email = 'padme.amidala@naboo.com',
	@PhoneNumber = '234-2345';

EXEC InsertMember 
    @FirstName = 'Captain',
    @LastName = 'Rex',
    @DateOfBirth = '2010-01-01',
    @Address1 = 'Clone',
	@Address2 = 'Barracks',
    @City = 'Kamino',
    @Postcode = 'CB99',
    @Username = 'CT-7567',
    @Password = '501stLegion',
	@Email = 'captain.rex@trooper.com',
    @PhoneNumber = '001-7567';

EXEC InsertMember 
    @FirstName = 'Luke',
    @LastName = 'Skywalker',
    @DateOfBirth = '2004-04-04',
    @Address1 = 'Jedi',
	@Address2 = 'Temple',
    @City = 'Coruscant',
    @Postcode = 'JT10',
    @Username = 'LastJedi',
    @Password = 'Rebels4Life',
	@Email = 'luke@jediorder.com',
    @PhoneNumber = '220-9090';

-- Views the Contents of Members, MemberAddress, & MemberLogin
SELECT * FROM Members
SELECT * FROM MemberAddress
SELECT * FROM MemberLogin

-- Inserts Sample Records to the LibaryItems Table
EXEC AddItem 
	@Title = 'Star Wars: The Old Republic',
	@ItemType = 'Journal',
	@Author = 'Paul S. Kemp',
	@DatePublished = '2011-01-11',
	@DateAdded = '2015-02-22',
	@Status = 'On Loan';

EXEC AddItem 
	@Title = 'Star Wars: The Rise of Skywalker',
	@ItemType = 'DVD',
	@Author = 'J.J. Abrams',
	@DatePublished = '2020-03-30',
	@DateAdded = '2022-03-03',
	@Status = 'Available';

EXEC AddItem 
	@Title = 'Star Wars: Rebels: Season 1',
	@ItemType = 'Other Media',
	@Author = 'Dave Filoni',
	@DatePublished = '2014-10-15',
	@DateAdded = '2017-01-10',
	@Status = 'On Loan';

EXEC AddItem 
	@Title = 'Star Wars: The Bad Batch',
	@ItemType = 'Other Media',
	@Author = 'Dave Filoni',
	@DatePublished = '2021-05-05',
	@DateAdded = '2021-05-05',
	@Status = 'On Loan';

EXEC AddItem 
	@Title = 'Star Wars: The Clone Wars',
	@ItemType = 'Other Media',
	@Author = 'Dave Filoni',
	@DatePublished = '2020-02-20',
	@DateAdded = '2020-05-10',
	@Status = 'On Loan';

EXEC AddItem 
	@Title = 'Star Wars: Thrawn Ascendancy',
	@ItemType = 'Book',
	@Author = 'Timothy Zahn',
	@DatePublished = '2017-09-01',
	@DateAdded = '2019-03-10',
	@Status = 'On Loan',
	@ISBN = 'ISBN-ORDER-66';

-- Views the Contents of LibraryItems
SELECT * FROM LibraryItems;

-- Inserts Sample Records to the Loans Table
INSERT INTO Loans (ItemID, MemberID, DateTaken, DateDue, DateReturned) 
VALUES (1, 1, '2023-04-10', '2023-04-15', NULL),
       (2, 2, '2023-04-10', '2023-04-15', '2023-4-12');

-- Inserts Sample Records to the Loans Table
INSERT INTO Loans (ItemID, MemberID, DateTaken, DateDue)
VALUES	(3, 3, GETDATE(), DATEADD(DAY, 12, GETDATE())),
		(4, 4, GETDATE(), DATEADD(DAY, 4, GETDATE())),
		(5, 5, DATEADD(DAY, -5, GETDATE()), GETDATE()),
		(6, 6, DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -2, GETDATE()));

-- Views the Contents of Loans
SELECT * FROM Loans;

-------------------------------------------------------------------
-- + 6.B Demonstrating the Functionality of All Created Objects + --
-------------------------------------------------------------------

-- 2.A Executes Procedure/Function 1 --
EXEC SearchLibrary 'Old';

-- 2.B Executes Procedure/Function 2 --
SELECT * FROM GetLoan();

-- 2.C Executes Procedure/Function 3 --
EXEC InsertMember 
    @FirstName = 'Barriss',
    @LastName = 'Offee',
    @DateOfBirth = '2001-01-10',
    @Address1 = 'Jedi',
	@Address2 = 'Temple',
    @City = 'Coruscant',
    @Postcode = 'JT10',
    @Username = 'Mirialan',
    @Password = 'Freedom',
	@Email = 'barriss.offee@jediorder.com',
    @PhoneNumber = '010-9090';

-- Views the Contents of New Member's Details Including Address & Logins After Insert
SELECT * FROM Members
SELECT * FROM MemberAddress
SELECT * FROM MemberLogin

-- 2.D Executes Procedure/Function 4 --
EXEC UpdateMember 
    @MemberID = 7,
    @Address1 = 'Republic',
    @Address2 = 'Prison',
    @City = 'Coruscant',
    @Postcode = 'EO99',
    @Email = 'barriss.offee@prisoner.com',
	@Password = 'Traitor';

-- Views the Contents of New Member's Details, Address, & Logins After Update
SELECT * FROM Members
SELECT * FROM MemberAddress
SELECT * FROM MemberLogin

-- 3. Executes the Loan History View --
SELECT * FROM LoanHistory;

-- 4. Demonstrating the Overdue & Available Trigger --
-- Verify Status is On Loan
SELECT * FROM LibraryItems WHERE ItemID = 5;
SELECT * FROM Loans WHERE ItemID = 5;

-- Updates the Loan's Due Date
UPDATE Loans SET DateDue = GETDATE() WHERE ItemID = 5

-- Verify Status is Overdue
SELECT * FROM LibraryItems WHERE ItemID = 5;
SELECT * FROM Loans WHERE ItemID = 5;

-- Updates the Loan's Return Date
UPDATE Loans SET DateReturned = GETDATE() WHERE ItemID = 5;

-- Verify Status is Available
SELECT * FROM LibraryItems WHERE ItemID = 5;
SELECT * FROM Loans WHERE ItemID = 5;

-- 5. Executes the Loan Count View --
SELECT TotalLoans FROM LoanCount
WHERE DateTaken = '2023-04-10';

-- 7. Demonstrating the Archive Trigger --
-- Views the Contents of Members, MemberAddress, & MemberLogin Before Archive
SELECT * FROM Members
SELECT * FROM MemberAddress
SELECT * FROM MemberLogin

-- Executes the Archive Trigger
BEGIN TRAN
DELETE FROM Members 
WHERE MemberID = 7;

-- Rollback Utilized in Case Wrong Member Archived
-- ROLLBACK TRAN

-- Views the Contents of Members, MemberAddress, & MemberLogin After Archive
SELECT * FROM Members
SELECT * FROM MemberAddress
SELECT * FROM MemberLogin

-- Views the Content of Archive
SELECT * FROM Archive

-- Commit Archived Transaction 
COMMIT;

-- 7. Demonstrating the Calculate Overdue Fee Trigger --
-- Views the Content of Loans
SELECT * FROM Loans;

-- Updates the Loan with the Returned Date to Trigger the Overdue Fee
UPDATE Loans SET DateReturned =  GETDATE() WHERE LoanID = 6;

-- Views the Created Fine in the Fines Table
SELECT * FROM Fines;

-- 7. Demonstrating the Process Payment Procedure --
-- Executing the Repayment Procedure
EXECUTE ProcessPay @FineID = 1, @RepaymentMethod = 'Credit Card', @RepaymentAmount = 0.20;

-- Views the Contents of Fines & Repayments After Payment
SELECT * FROM Fines
SELECT * FROM Repayments

-- 7. Demonstrating the Update Item Procedure --
-- Views the Contents of LibraryItems Before Update
SELECT * FROM LibraryItems WHERE ItemID = 1;

-- Updates Item to Lost
EXEC UpdateItem
    @ItemID = 1,
    @Status = 'Lost';

-- Views the Contents of LibraryItems After Update
SELECT * FROM LibraryItems WHERE ItemID = 1;

-- Updates Item to Identified
EXEC UpdateItem
    @ItemID = 1,
    @Status = 'Available',
    @DateIdentified = '2023-04-28';

-- Views the Contents of LibraryItems After Update
SELECT * FROM LibraryItems WHERE ItemID = 1;

---------------------------------------------------------------------------------------------------------
-- + 7.Demonstrating the Creation of Employee Roles & Back-Up Scripts for Additional Database Security,+ --
---------------------------------------------------------------------------------------------------------

-- Creates a Login for the Front Desk Employee --
CREATE LOGIN FrontDeskEmployee WITH PASSWORD = 'FrontMan';

-- Creates a User for the Front Desk Employee --
CREATE USER FrontDeskEmployee FOR LOGIN FrontDeskEmployee;

-- Grants the Front Desk Employee Specific Permissions to the Given Tables --
GRANT SELECT, INSERT, UPDATE, DELETE ON Members TO FrontDeskEmployee;
GRANT SELECT, INSERT, UPDATE ON MemberAddress TO FrontDeskEmployee;
GRANT SELECT, INSERT, UPDATE ON MemberLogin TO FrontDeskEmployee;
GRANT SELECT, INSERT, UPDATE ON Fines TO FrontDeskEmployee;
GRANT SELECT, INSERT, UPDATE ON Repayments TO FrontDeskEmployee;
GRANT SELECT, INSERT, UPDATE ON Loans TO FrontDeskEmployee;
GRANT SELECT, UPDATE ON LibraryItems TO FrontDeskEmployee;

-- Creates a Login for the Inventory Manager --
CREATE LOGIN InventoryManager WITH PASSWORD = 'InvisibleMan';

-- Creates a User for the Inventory Manager
CREATE USER InventoryManager FOR LOGIN InventoryManager;

-- Grants the Inventory Manager Specific Permissions to the Given Tables
GRANT SELECT, INSERT, UPDATE, DELETE ON LibraryItems TO InventoryManager;
GRANT SELECT ON Loans TO InventoryManager;

-- Creates a Login for the System Administrator --
CREATE LOGIN SystemAdmin WITH PASSWORD = 'HackerMan';

-- Creates a User for the System Admin
CREATE USER SystemAdmin FOR LOGIN SystemAdmin;

-- Grants the System Admin Full Control Permissions to All Tables in the Database
GRANT CONTROL ON DATABASE::LibraryDB TO SystemAdmin;

-- Creates the Back-Up Script for LibraryDB to Avoid Data Loss --
-- Connects to MSDB
USE msdb;
GO

-- Creates & Enables the Back-Up Job
EXEC dbo.sp_add_job
@Job_Name = 'LibraryDB_Backup_Job',
@Enabled = 1,
@Description = 'LibraryDB - Daily Back-Up';
GO

-- Identifies the Subsytem for the Library
EXEC dbo.sp_enum_sqlagent_subsystems;

-- Creates the Job Step to Specify Preferred Back-Up Location
EXEC dbo.sp_add_jobstep
@Job_Name = 'LibraryDB_Backup_Job',
@Step_Name = 'LibraryDB_Backup_Step',
@Subsystem = 'TSQL',
@Command = 'BACKUP DATABASE LibraryDB TO DISK = ''C:\Insert\Preferred\Location\LibraryDB.bak'' WITH INIT, COMPRESSION, STATS = 10, CHECKSUM',
@Retry_Attempts = 5,
@Retry_Interval = 5;
GO

-- Creates the Daily Schedule for the Job
EXEC dbo.sp_add_schedule
@Schedule_Name = 'LibraryDB_Backup_Schedule',
@Freq_Type = 4,
@Freq_Interval = 1,
@Freq_Recurrence_Factor = 1,
@Active_Start_Time = 230000,
@Active_End_Time = 235959;
GO

-- Attaches the Schedule to Job
EXEC dbo.sp_attach_schedule
@Job_Name = 'LibraryDB_Backup_Job',
@Schedule_Name = 'LibraryDB_Backup_Schedule';
GO

-- Sets the Job on Local Server
EXEC dbo.sp_add_jobserver
@job_name = 'LibraryDB_Backup_Job',
@server_name = '(local)';

-- Starts the Job
EXEC dbo.sp_start_job 'LibraryDB_Backup_Job';

-- Script to Ensure the Database is Not Corrupted
RESTORE VERIFYONLY
FROM DISK = 'C:\Insert\Preferred\Location\LibraryDB.bak' 
WITH CHECKSUM;

-- Script to Restore the Database 
RESTORE DATABASE LibraryDB
FROM DISK = 'C:\Insert\Preferred\Location\LibraryDB.bak'
WITH REPLACE, RECOVERY;
GO

-----------------------
-- + END OF TASK 1 + --
-----------------------