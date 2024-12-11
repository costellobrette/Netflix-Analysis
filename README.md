# Netflix Analysis 🎬


 ## <u>Introduction</u>

Our family Netflix account has been shared between 3 profiles, my brother Chase, my mother Sharleen, and myself for over a decade (2013-2024). In that time, we have all watched hundreds of movies and TV shows of different genres. My analysis will show how similar and different we are as a family when it comes to our taste and watching patterns while we are on Netflix.

To determine this, I will be answering 4 questions:

1) Which devices does each profile watch on the most for both shows and movies?

2) What are the most popular years, months, and days of the week each of us watch both shows and movies on?

3) What are the most popular titles for shows and movies by genre and profile?

4) What is the amount of time spent watching each genre by profile and type category?

To answer these questions, I will be using a Netflix Data Mart I created that includes seven dim tables and three fact tables. However, to analyze the data I will only be using five dim tables and one fact table. The purpose of the others, (two fact and two dimension tables), is to create an easier-to-use final dim and fact table for end users that ensures data consistency. These tables will be clearly indicated in the staging and data loading processes.

### <ins>Data Sources</ins> 💻

The data pulled for this analysis was provided by my Netflix BI Presentation in Power BI, and transferred to SQL using the application DAX Studios. The data was originally provided by Netflix. Below is the link to request your Netflix account data: 

[Emoji Copy]: https://emojicopy.com/
[Netflix Data Request]: https://www.netflix.com/account/getmyinfo
[Draw.io]: https://www.drawio.com/
[Netflix Data Request]

Emoji icons used in this notebook are provided by [Emoji Copy]

Visualization for the EDR is provided by [Draw.io]

## 🎥 Steps to Mart Creation 🎥

To begin creating the Netflix DataMart, I created a new database in Microsoft SQL Server 2022 (SSMS) called "Netflix_DW". I did this by right-clicking on 'Databases' and selecting 'New Database'. From there, I left the default sizing options, went into 'Options', set 'Recovery Mode' to 'Simple', and then pressed finish to create the new database.

Before pulling my data in, I created the schema 'stg' (shown below under 'Schema Creations') so that when I transferred my data over, I could clearly differentiate between my newly created tables and their data loading sources. Afterward, I used DAX Studio to pull in all of my dimension and fact tables from my previous Power BI presentation mentioned above in data sources. I then exported the data under the 'Export Data' pane. I selected my new database, chose the 'SQL tables' option, and used the schema 'stg' for my tables to be created under. Finally, I moved on to begin the schema creation for the new Data Mart using T-SQL against SSMS.

### 🎞️ <ins>Schema Creation</ins> 🎞️
Below are the four different schemas I created for the Data Mart. The schema 'stg' was used to pull the data in from DAX Studios, 'vw' was used in the creation of the 'dim' and 'fact' tables, and 'dim' and 'fact' were created for the new tables that would store data and be used for analysis.

- stg
- vw
- dim
- fact

### 📊 <ins>Data Loading</ins> 📊
Statments used to load data into the tables for the Data Mart are as follows:

- INSERT INTO
- UPDATE
- SET
- DROP

### <u>Links to Schema and Data Loader</u>




 
