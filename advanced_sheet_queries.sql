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
