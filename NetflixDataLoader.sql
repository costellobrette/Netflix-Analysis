USE Netflix_DW;
GO

GO


INSERT INTO dim.Shows(ShowID,Show_Name,Genre)
	SELECT stg.ID 
		  ,stg.ShowName
		  ,stg.Genre
	FROM stg.Shows stg

;
GO


INSERT INTO dim.Movies(MovieID, Movie_Name,Genre)
	SELECT stg.Movie_ID
		  ,stg.MovieName
		  ,stg.Genre
	FROM stg.Movies stg
;
GO


INSERT INTO dim.Calendar(PK_CalendarDate,[Year],[Month],[MonthName],[Day],[DayName],Weekend,WeekofYear)
	SELECT stg.[Date]
		  ,stg.[Year]
		  ,stg.[Month]
		  ,stg.[MonthName]
		  ,stg.[Day]
		  ,stg.[DayName]
		  ,stg.Weekend
		  ,stg.WeekofYear
	FROM stg.Calendar stg
;



GO

INSERT INTO dim.Profiles(Profile_ID, Profile_Name)
	SELECT stg.Profile_ID
		  ,stg.[Profile Name]
	FROM stg.Profiles stg

;
GO

INSERT INTO dim.Genres(Genre_ID,Genre)
	SELECT stg.Genre_ID
		,stg.Genre
	FROM stg.Genres stg

;
GO

INSERT INTO dim.Devices(Device_ID, Device_Type,Times_Device_Used,Device_Usage)
	SELECT stg.Device_ID
		,stg.Device_Type
		,stg.[Times_Device_Used]
		,stg.[Device_Usage]
	FROM stg.Devices stg

;
GO

--Fact Tables

CREATE OR ALTER VIEW vw.fNetflixMovies AS
SELECT [Date] as 'Date'
	,Profile_ID 
	,Movie_ID
	,Genre_ID
	,Device_ID
	,SUM(Duration) as 'Total Duration'
FROM stg.fNetflixMovies
GROUP BY Profile_ID,Movie_ID,Genre_ID,Device_ID,[Date]
;

GO
	
CREATE OR ALTER VIEW vw.fNetflixShows AS
SELECT [Date] as 'Date'
	,Profile_ID
	,Show_ID
	,Genre_ID
	,Device_ID
	,SUM(Duration) as 'Total Duration'
FROM stg.fNetflixShows f
GROUP BY Date,Profile_ID,Show_ID,Genre_ID,Device_ID,[Date]
ORDER BY 'Date' ASC
;

GO

INSERT INTO fact.NetflixShows ([Date], Show_Name, Profile_ID, Show_ID, Genre_ID, Device_ID, Total_Duration)
SELECT 
    vw.[Date],
    sh.Show_Name,
    vw.Show_ID,
    vw.Profile_ID,
    vw.Genre_ID,
    vw.Device_ID,
    SUM(vw.[Total Duration]) AS Total_Duration
FROM 
    vw.fNetflixShows vw
INNER JOIN 
    dim.Calendar cal ON vw.[Date] = cal.[PK_CalendarDate]
INNER JOIN 
    dim.Shows sh ON vw.Show_ID = sh.Show_ID
GROUP BY 
    vw.[Date], sh.Show_Name, vw.Profile_ID, vw.Show_ID, vw.Genre_ID, vw.Device_ID
;

GO

	
INSERT INTO fact.NetflixMovies([Date],Movie_Name,Profile_ID,Movie_ID,Genre_ID,Device_ID,Total_Duration)
	SELECT vw.[Date]
		,mv.Movie_Name
		,vw.Profile_ID
		,vw.Movie_ID
		,vw.Genre_ID
		,vw.Device_ID
		,SUM([Total Duration]) as 'Total_Duration'
	FROM vw.fNetflixMovies vw
	INNER JOIN dim.Calendar cal 
	ON vw.[Date] = cal.[PK_CalendarDate]
	INNER JOIN dim.Movies mv
	ON vw.Movie_ID = mv.MovieID
	GROUP BY vw.[Date], mv.Movie_Name, vw.Profile_ID, vw.Movie_ID, vw.Genre_ID, vw.Device_ID
;

GO

ALTER TABLE dim.Shows
DROP COLUMN ShowID;

ALTER TABLE dim.Movies
DROP COLUMN MovieID;

ALTER TABLE dim.Shows
ADD Title_ID SMALLINT NULL;

ALTER TABLE dim.Movies
ADD Title_ID SMALLINT NULL;

GO

CREATE OR ALTER VIEW vw.dim AS
SELECT mv.Movie_Name as 'Title'
	,mv.Genre
	,mv.Title_ID
FROM dim.Movies mv
UNION ALL
SELECT sh.Show_Name as 'Title'
	,sh.Genre
	,sh.Title_ID
FROM dim.Shows sh
;

GO
	
INSERT INTO dim.Titles(Title,Genre)
SELECT Title
	,Genre
FROM vw.dim
;

GO
	
UPDATE dim.Titles
SET Title_ID = 10000 + PK_MovieShow_ID;

UPDATE dim.Titles
SET [Type] = 'Movie'
WHERE Title_ID < 11402;

UPDATE dim.Titles
SET [Type] = 'Show'
WHERE Title_ID >= 11402;

GO
	
CREATE OR ALTER VIEW vw.Fact AS
SELECT sh.[Date]
	,sh.Show_Name as 'Title'
	,sh.Profile_ID
	,sh.Show_ID as 'Netflix_ID'
	,sh.Genre_ID
	,sh.Device_ID
	,sh.Total_Duration
FROM fact.NetflixShows sh
UNION ALL
SELECT mv.[Date]
	,mv.Movie_Name as 'Title'
	,mv.Profile_ID
	,mv.Movie_ID as 'Netflix_ID'
	,mv.Genre_ID
	,mv.Device_ID
	,mv.Total_Duration
FROM fact.NetflixMovies mv
;

GO
	
INSERT INTO fact.Netflix([Date], Title, Profile_ID, Title_ID, Genre_ID, Device_ID, Total_Duration)
SELECT 
    f.[Date],
    f.Title,
    f.Profile_ID,
    f.Netflix_ID,
    f.Genre_ID,
    f.Device_ID,
    (f.[Total_Duration]) AS Total_Duration
FROM 
    vw.Fact f
GROUP BY 
    f.[Date], f.Title, f.Profile_ID, f.Netflix_ID, f.Genre_ID, f.Device_ID,f.Total_Duration
;

GO
	
UPDATE fact.Netflix
SET fact.Netflix.Title_ID = dim.Titles.Title_ID
FROM fact.Netflix
INNER JOIN dim.Titles ON fact.Netflix.Title = dim.Titles.Title;

ALTER TABLE dim.Titles
ALTER COLUMN Title_ID SMALLINT NOT NULL;

ALTER TABLE dim.Titles
ADD CONSTRAINT UC_Title UNIQUE (Title_ID);

ALTER TABLE fact.Netflix
ADD CONSTRAINT PK_NETFLIXtoTITLES 
FOREIGN KEY (Title_ID) 
 REFERENCES dim.Titles(Title_ID); 
