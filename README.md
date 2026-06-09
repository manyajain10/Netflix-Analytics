# Netflix Data Analytics and Visualization Platform
Developed an end-to-end SQL data analysis and visualization project on the Netflix Movies and TV Shows dataset to extract meaningful business insights and content trends. The project involved designing database schemas, cleaning and transforming raw data, and solving multiple real-world business problems using advanced SQL queries. Interactive Tableau dashboard analyzing 8,800+ Netflix titles across
10 sheets covering content growth, genre trends, country distribution, duration analysis, and ratings breakdown.
<img width="2226" height="678" alt="image" src="https://github.com/user-attachments/assets/a3349fd8-0497-47eb-baed-c75f1e8d26fb" />

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Tools Used
- PostgreSQL — data cleaning and query building
- Tableau Desktop — dashboard design and visualization
- Dataset: Netflix Movies and TV Shows (Kaggle)

## Live Dashboard
View on Tableau Public: -**Link:** [Tableau Public Link](https://public.tableau.com/app/profile/dhruv.sharma8302/viz/NetflixDashboard_17801640607900/NetfixDatabaseDashboard?publish=yes) 

## Dashboard Preview
<img width="1049" height="803" alt="image" src="https://github.com/user-attachments/assets/0b4f33d9-3634-404d-9ed3-d592f2c026a6" />

## Dataset

The data for this project is sourced from the Kaggle dataset: - **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema
<img width="503" height="344" alt="image" src="https://github.com/user-attachments/assets/a6c1b45b-c0d5-45b8-b7ae-d475ac83d626" />

## Sheets Built
1. Content growth over years
2. Country-wise content map
3. Top 5 Genre by popularity
4. Movie vs TV ratio donut
5. Top 10 Ratings distribution
6. Top 10 directors
7. Global KPI calculated fields
   - Total Titles
   - Movie Percentage
   - Countries Represented
   - Avg Movie Duration (in mins)
  

## PostgreSQL queries for all advanced sheets:
<img width="346" height="301" alt="image" src="https://github.com/user-attachments/assets/52dad5fa-015a-4cdb-bf9e-dba3d02ba50e" />


1. Sheet 1: Content growth over years
   ```sql
   SELECT
    release_year,
    COUNT(*) AS total_content
   FROM netflix_clean
   GROUP BY release_year
   ORDER BY release_year;

2. Sheet2: Country-Wise Content Map
   ```sql
   SELECT
    country,
    COUNT(*) AS total_content
   FROM netflix_clean
   WHERE country IS NOT NULL
   GROUP BY country
   ORDER BY total_content DESC;

3. Sheet 3: Top 5 Genre by popularity
   ```sql
   SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
    COUNT(*) AS total_titles
   FROM netflix_clean
   GROUP BY genre
   ORDER BY total_titles DESC
   LIMIT 5;

4. Sheet 4: Movie vs TV ratio
   ```sql
   SELECT
    type,
    COUNT(*) AS total
   FROM netflix_clean
   GROUP BY type;

5. Sheet 5: Top 10 Ratings Distribution
   ```sql
   SELECT
    rating,
    COUNT(*) AS total_titles
   FROM netflix_clean
   WHERE rating IS NOT NULL
   GROUP BY rating
   ORDER BY total_titles DESC
   LIMIT 10;

6. Sheet 6: Top 10 Directors
   ```sql
   SELECT
    director,
    COUNT(*) AS total_titles
   FROM netflix_clean
   WHERE director IS NOT NULL
   GROUP BY director
   ORDER BY total_titles DESC
   LIMIT 10;

7. Sheet 7: Global KPI calculated fields
    ```sql
    SELECT
    COUNT(show_id) AS total_titles,
    COUNT(CASE WHEN type = 'Movie'   THEN 1 END) AS total_movies,
    COUNT(CASE WHEN type = 'TV Show' THEN 1 END) AS total_tv_shows,
    ROUND(
        COUNT(CASE WHEN type = 'Movie' THEN 1 END)::NUMERIC
        / COUNT(show_id) * 100, 1
    ) AS movie_percentage,
    COUNT(DISTINCT TRIM(SPLIT_PART(country, ',', 1))) AS countries_represented,
    ROUND(AVG(
        CASE WHEN type = 'Movie'
        THEN CAST(SPLIT_PART(duration, ' ', 1) AS INT) END
    ), 0) AS avg_movie_runtime_mins,
    MODE() WITHIN GROUP (ORDER BY rating) AS most_common_rating
    FROM netflix_clean
    WHERE date_added IS NOT NULL AND TRIM(date_added) <> '';


## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;
```
**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

