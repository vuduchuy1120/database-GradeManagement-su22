
-- SELECT ra total.
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
-- Hàm check điều kiện xem có điểm thành phần nào không đủ điều kiện không?. 
CREATE FUNCTION check_pass(@courseID varchar(10), @sID char(8)) 
RETURNS int
AS
BEGIN
	DECLARE @flag int;
	DECLARE @categoryID varchar(10);
	SET @flag = 0;
	DECLARE check_pass_cursor CURSOR FOR
	SELECT [sID],CourseID, CategoryID FROM 
	(
	SELECT g.sID, a.CourseID, c.CategoryID, AVG(Score) as sub_total, CompletionCriteria FROM Grade g
	INNER JOIN Assesment a on g.AssID = a.AssID
	INNER JOIN CategoryDetails cd on cd.cdID = a.CDID
	INNER JOIN Category c on c.CategoryID = cd.CategoryID  GROUP BY CourseID, sID, c.CategoryID, CompletionCriteria
	) as tbl1 WHERE  CourseID = @courseID and [sID] = @sID ;
	OPEN check_pass_cursor;
	FETCH NEXT FROM check_pass_cursor INTO @sID, @courseID, @categoryID
	WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE @score fLOAT;
			DECLARE @scoreMin FLOAT
			SELECT @score = sub_total , @scoreMin = CompletionCriteria FROM 
			(
				SELECT g.sID, a.CourseID, c.CategoryID, AVG(Score) as sub_total, CompletionCriteria
				FROM Grade g
				INNER JOIN Assesment a on g.AssID = a.AssID
				INNER JOIN CategoryDetails cd on cd.cdID = a.CDID
				INNER JOIN Category c on c.CategoryID = cd.CategoryID
				GROUP BY CourseID, sID, c.CategoryID, CompletionCriteria 
			) as tbl1 WHERE tbl1.CourseID = @courseID  AND  tbl1.[sID] = @sID AND  CategoryID = @categoryID 
			IF @score <= @scoreMin
				BEGIN
					set @flag = 1;
					break;
				END
			FETCH NEXT FROM check_pass_cursor INTO @courseID, @sid, @categoryID
		END
	CLOSE check_pass_cursor;
	DEALLOCATE check_pass_cursor;
	return @flag;
END

GO
SELECT dbo.check_pass('PRF192', 'HE111112')
go
-- Stored Procedure update status is passed or not passed.
CREATE PROC update_status_pass
	@courseID varchar(10),
	@sID char(8)
AS
BEGIN
	DECLARE @average1 FLOAT;
	SELECT @average1 = Average FROM [View] WHERE  CourseID = @courseID  and  [sID] = @sID ;
	IF @average1 > 5 AND dbo.check_pass(@courseID,@sID) = 0
	UPDATE [View] SET [Status] = 'PASSED' WHERE  CourseID = @courseID  and  [sID] = @sID ;
	ELSE
	UPDATE [View] SET [Status] = 'NOT PASSED' WHERE  CourseID = @courseID  and  [sID] = @sID ;
END

-- cusor update status while have average.
go
DECLARE @courseID varchar(10);
DECLARE @sID char(8);
DECLARE update_status_cursor CURSOR FOR
SELECT CourseID, [sID] FROM [View];
OPEN update_status_cursor;
FETCH NEXT FROM update_status_cursor INTO @courseiD, @sID
WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC update_status_pass @CourseID, @sID
	FETCH NEXT FROM update_status_cursor INTO @courseID, @sid
END
CLOSE update_status_cursor;
DEALLOCATE update_status_cursor;


--
SELECT g.sID, a.CourseID, c.CategoryID, AVG(Score) as sub_total, CompletionCriteria FROM Grade g
INNER JOIN Assesment a on g.AssID = a.AssID
INNER JOIN CategoryDetails cd on cd.cdID = a.CDID
INNER JOIN Category c on c.CategoryID = cd.CategoryID  GROUP BY CourseID, sID, c.CategoryID, CompletionCriteria

-- test
GO
go
CREATE PROC select_sub_total
AS
BEGIN
	SELECT g.sID, a.CourseID, c.CategoryID, AVG(Score) as sub_total, CompletionCriteria FROM Grade g
	INNER JOIN Assesment a on g.AssID = a.AssID
	INNER JOIN CategoryDetails cd on cd.cdID = a.CDID
	INNER JOIN Category c on c.CategoryID = cd.CategoryID  GROUP BY CourseID, sID, c.CategoryID, CompletionCriteria
END
GO

EXEC select_sub_total



-- TRIGGER WHILE INPUT DATA AVERAGE OR STATUS-- 
GO
CREATE TRIGGER View_Average ON [View]
AFTER INSERT, UPDATE
AS
DECLARE @AVG FLOAT;
DECLARE @courseID VARCHAR(10);
DECLARE @ses varchar(10)
DECLARE @sID char(8);
DECLARE @average FLOAT;
DECLARE @status VARCHAR(20);

SELECT @sID = sID, @courseID = CourseID, @ses = Semester,
		@average = Average, @status = [Status]  
FROM inserted;
SELECT @AVG = sum(tbl1.Weight/100 * Score) FROM
		(SELECT a.*, g.Score, g.sID FROM Assesment a
		    INNER JOIN Grade g on a.AssID = g.AssID  WHERE sID = @sID and CourseID = @courseID
			) as tbl1 group by sID, CourseID 
IF @AVG <> @average
BEGIN
	PRINT 'Conflict input data'
	ROLLBACK TRAN
END
ELSE IF (NOT @status = 'PASSED') AND (NOT @status = 'NOT PASSED')
BEGIN
	PRINT 'Status must be passed or not passed'
	ROLLBACK TRAN
END
ELSE IF (@AVG <= 5 AND @status = 'PASSED') OR (@AVG > 5 AND @status = 'NOT PASSED')
BEGIN
	PRINT 'Incorrect Status'
	ROLLBACK TRAN
END
	
UPDATE [View] SET Average = 8, [Status] = 'PASSED', Semester ='FALL21' WHERE sID = 'HE111112' AND CourseID = 'MAE101'

SELECT * FROM [View]
