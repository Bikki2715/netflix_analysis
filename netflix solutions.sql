SELECT * FROM public.netflix
-- Netflix Data Analysis using SQL
-- Solutions of business problems

-- 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1

-- 2. Find the most common rating for movies and TV shows

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


-- 3. List all movies released in a specific year (e.g., 2020)
SELECT
	type,
	title,
	release_year
from netflix 
where release_year =2020 and type = 'Movie';

-- 4. Find the top 5 countries with the most content on Netflix


select 
	UNNEST(STRING_TO_ARRAY(country, ',')) AS NEW_COUNTRY,-- we use unnest for split the country names beacuse some rows have multiple country names
	COUNT(show_id) as total_content
from netflix
group by country
order by total_content desc limit 5;

-- 5. Identify the longest movie

SELECT 
	type,
	duration,
	title
FROM netflix
WHERE type = 'Movie' 
and 
duration is not null
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC  limit 1

-- 6. Find content added in the last 5 years(2020-08-11)
select current_date - interval ' 5 years';


select *
from netflix
where
date_added >= '2020-08-11';



SELECT
	*,
	to_date(date_added, 'Month DD, YYYY')
FROM netflix
	WHERE  date_added >= CURRENT_DATE - INTERVAL '5 years'

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select 
	type,
	director,
	title
from netflix 
where director ilike '%Rajiv Chilaka' ;

-- 8. List all TV shows with more than 5 seasons
select 
	type,
	duration
from netflix 
where 
	type = 'TV Show'
	and 
	SPLIT_PART(duration, ' ',1)::int > 5

-- 9. Count the number of content items in each genre
select 
	unnest(string_to_array(listed_in,',')) as genre,
	count(listed_in) as total_count
from netflix
group by 1


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 ,2)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5

-- 11. List all movies that are documentaries
select 
	unnest(string_to_array(listed_in,',')) as genre,
	type
from netflix
where
	type = 'Movie'
	and
	listed_in ilike 'Documentaries'

-- 12. Find all content without a director
select * from netflix where director is null


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT 
	type,
	casts
FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	-- and
	-- type = 'Movie'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.


SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/


 
SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2

--16. Determine the number of titles that are co-productions (multiple countries) versus single-country productions to understand global collaboration.
 
SELECT
  SUM(CASE WHEN country LIKE '%,%' THEN 1 ELSE 0 END) AS multi_country_titles,
  SUM(CASE WHEN country NOT LIKE '%,%' THEN 1 ELSE 0 END) AS single_country_titles
FROM netflix;
