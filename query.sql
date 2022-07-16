GO
CREATE FUNCTION Cal_ave() RETURNS FLOAT	
AS
BEGIN
	DECLARE @total float(2);
	SELECT @total = sum(tbl1.Weight/100 * Score)  FROM
	(SELECT a.*, g.Score, g.sID FROM Assesment a
	INNER JOIN Grade g on a.AssID = g.AssID ) tbl1 group by sID, CourseID order by sID
	return @total
END
go

CREATE PROC update_status
	@average float
AS
BEGIN
	IF(@average > 5) 
	UPDATE [View] SET [Status] = 'PASSED' 
END

SELECT CourseID, sID , sum(tbl1.Weight/100 * Score) as total FROM
(SELECT a.*, g.Score, g.sID FROM Assesment a
INNER JOIN Grade g on a.AssID = g.AssID ) tbl1 group by sID, CourseID order by sID

-- update average
go
DECLARE @courseID varchar(10);
DECLARE @sID char(8);
DECLARE update_total_cursor_1 CURSOR FOR
SELECT CourseID, sID FROM [View];
OPEN update_total_cursor_1;
FETCH NEXT FROM update_total_cursor_1 INTO @courseiD, @sID
WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @total float(2);
	SELECT @total = sum(tbl1.Weight/100 * Score)  FROM
	(SELECT a.*, g.Score, g.sID FROM Assesment a
	INNER JOIN Grade g on a.AssID = g.AssID ) tbl1 WHERE CourseID = @courseID and sid = @sid;
	UPDATE [View] SET Average = @TOTAL WHERE CourseID = @courseID and sid = @sid;
	FETCH NEXT FROM update_total_cursor_1 INTO @courseID, @sid
END
CLOSE update_total_cursor_1;
DEALLOCATE update_total_cursor_1;

-- UPDATE STATUS
go
DECLARE @courseID varchar(10);
DECLARE @sID char(8);
DECLARE update_status_cursor CURSOR FOR
SELECT CourseID, sID FROM [View];
OPEN update_status_cursor;
FETCH NEXT FROM update_status_cursor INTO @courseiD, @sID
WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @average float;
	SELECT @average = Average FROM [View] WHERE CourseID = @courseID and sid = @sid;
	EXEC update_status @average
	FETCH NEXT FROM update_status_cursor INTO @courseID, @sid
END
CLOSE update_status_cursor;
DEALLOCATE update_status_cursor;

