CREATE TABLE Employee( 
	id INT NOT NULL PRIMARY KEY,
	[name] VARCHAR(150) NOT NULL 
);

CREATE TABLE Dependence( 
	id INT NOT NULL PRIMARY KEY,
	[name] VARCHAR(150) NOT NULL,
	eid INT NOT NULL FOREIGN KEY REFERENCES Employee(id)
);



ALTER TRIGGER trigger_Test ON Dependence
AFTER INSERT,UPDATE,DELETE
AS
	DECLARE @EID INT;
	DECLARE @COUNT INT;
	SELECT @EID = eid FROM inserted;
	SELECT @COUNT = COUNT(*) FROM Dependence WHERE eid = @EID;
	IF @COUNT > 2
	BEGIN
		PRINT 'Cannot add more than 2 dependences for employee'
		ROLLBACK TRAN
	END
	
	
	



INSERT INTO Dependence VALUES (1,'A',1);
INSERT INTO Dependence VALUES (2,'A2',1);

INSERT INTO Dependence VALUES (3,'B',2);
DELETE Dependence WHERE  id = 3;

UPDATE Dependence SET name = 'BBBBB' WHERE id = 3

SELECT * FROM Dependence

INSERT INTO Dependence VALUES (4,'A3',1);
INSERT INTO Dependence VALUES (4,'B',2);
	
