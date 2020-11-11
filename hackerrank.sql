USE hackeranker;

-- 1. hard - interview
SELECT 
	con.contest_id,
    con.hacker_id,
    con.name,
    SUM(IFNULL(t1.total_submissions,0)) AS total_submissions,
    SUM(IFNULL(t1.total_accepted_submissions,0)) AS total_accepted_submissions,
    SUM(IFNULL(t2.total_views,0)) AS total_views,
    SUM(IFNULL(t2.total_unique_views,0)) AS total_unique_views
FROM 
	(SELECT 
		challenge_id, 
        SUM(total_views) AS total_views, 
        SUM(total_unique_views) as total_unique_views
	FROM View_stats_1
    GROUP BY challenge_id) t2
    RIGHT JOIN
		((SELECT 
			challenge_id, 
			SUM(total_submissions) AS total_submissions, 
			SUM(total_accepted_submissions) AS total_accepted_submissions 
		FROM Submission_stats_1 
		GROUP BY challenge_id) t1
		RIGHT JOIN
			(challenges_1 cha
			INNER JOIN
				(contests_1 con
				INNER JOIN colleges_1 col
					ON con.contest_id = col.contest_id)
				ON cha.college_id = col.college_id)
			ON t1.challenge_id = cha.challenge_id)
		ON t2.challenge_id = cha.challenge_id
GROUP BY con.contest_id, con.hacker_id, con.name
HAVING SUM(IFNULL(t1.total_submissions,0)) + SUM(IFNULL(t1.total_accepted_submissions,0)) + SUM(IFNULL(t2.total_views,0)) + SUM(IFNULL(t2.total_unique_views,0)) != 0
ORDER BY contest_id;


-- 2. hard - 15 days of learning SQL
SELECT 
    s1.submission_date,
    (
     SELECT COUNT(DISTINCT s2.hacker_id)
     FROM submissions s2
     WHERE s2.submission_date = s1.submission_date
        AND
            (
            SELECT COUNT(DISTINCT s3.submission_date)
            FROM submissions s3
            WHERE s3.hacker_id = s2.hacker_id
                AND
                 s3.submission_date < s2.submission_date
            ) = DATEDIFF(s2.submission_date, '2016-03-01')
    ),
    (
    SELECT s2.hacker_id
    FROM submissions s2
    WHERE s2.submission_date = s1.submission_date
    GROUP BY s2.hacker_id
    ORDER BY COUNT(s2.submission_id) DESC, s2.hacker_id
    LIMIT 1
    ) AS t1,
    (
    SELECT name
    FROM hackers
    WHERE hacker_id = t1
    )
FROM
    (
     SELECT DISTINCT submission_date 
     FROM submissions
     ) s1
GROUP BY submission_date;

-- 3. medium - the PADS
SELECT CONCAT(name, "(",LEFT(occupation,1),")") AS name
FROM occupations
ORDER BY name;

SELECT CONCAT("There are a total of ",COUNT(name)," ",LOWER(occupation),"s.") AS occupations
FROM occupations
GROUP BY occupation
ORDER BY COUNT(name), occupation;

-- 4. medium - occupations
SELECT 
    MAX(Doctor) AS Doctor,
    MAX(Professor) AS Professor,
    MAX(Singer) AS Singer,
    MAX(Actor) AS Actor
FROM (
    SELECT 
        ID,
        CASE WHEN occupation = "Doctor" THEN name END AS Doctor,
        CASE WHEN occupation = "Professor" THEN name END AS Professor,
        CASE WHEN occupation = "Singer" THEN name END AS Singer,
        CASE WHEN occupation = "Actor" THEN name END AS Actor
    FROM (
        SELECT 
            ROW_NUMBER() OVER(PARTITION BY occupation ORDER BY name) AS ID,
            name,
            occupation
        FROM occupations) tmp) tmp2
GROUP BY ID;

-- 5. medium - Binary Tree Nodes
SELECT
    DISTINCT N,
    CASE WHEN P IS NULL THEN 'Root'
        WHEN second_nodes IS NULL THEN 'Leaf'
        ELSE 'Inner'
        END AS nodes
FROM (
    SELECT b1.N, b1.P, b2.N AS second_nodes
    FROM bst b1
    LEFT JOIN bst b2
        ON b1.N = b2.P) t1
ORDER BY N;

-- 6. medium - New Companies
SELECT
    DISTINCT c.company_code,
    c.founder,
    t1.num_lead_manager,
    t2.num_senior_manager,
    t3.num_manager,
    t4.num_employee   
FROM company c
LEFT JOIN 
    (SELECT company_code, COUNT(DISTINCT lead_manager_code) AS num_lead_manager 
     FROM lead_manager
     GROUP BY company_code) t1
    ON c.company_code = t1.company_code
LEFT JOIN
    (SELECT company_code, COUNT(DISTINCT senior_manager_code) AS num_senior_manager
    FROM senior_manager
    GROUP BY company_code) t2
    ON c.company_code = t2.company_code
LEFT JOIN 
    (SELECT company_code, COUNT(DISTINCT manager_code) AS num_manager
    FROM manager
    GROUP BY company_code) t3
    ON c.company_code = t3.company_code
LEFT JOIN
    (SELECT company_code, COUNT(DISTINCT employee_code) AS num_employee
    FROM employee
    GROUP BY company_code) t4
    ON c.company_code = t4.company_code
ORDER BY 1;

-- 7. medium - Weather Observation Station 18
SELECT 
    ROUND(ABS(MIN(lat_n) - MAX(lat_n)) + ABS(MIN(long_w) - MAX(long_w)),
            4)
FROM
    station;
    
-- 8. medium - Weather Observation Station 19
SELECT 
    ROUND(SQRT(POWER((MIN(lat_n) - MAX(lat_n)), 2) + POWER((MIN(long_w) - MAX(long_w)), 2)),
            4)
FROM
    station;

-- 9. medium - Weather Observation Station 20
SELECT
    ROUND(AVG(t1.lat_n),4) AS median_lat_n
FROM (
    SELECT
        lat_n,
        CAST(ROW_NUMBER() OVER(ORDER BY lat_n) AS SIGNED) AS asc_lat,
        CAST(ROW_NUMBER() OVER(ORDER BY lat_n DESC) AS SIGNED) AS desc_lat
    FROM station) t1
WHERE ABS(t1.asc_lat - t1.desc_lat) <= 1;

-- 10. medium - The Report
WITH a AS 
(
    SELECT
        s.name,
        g.grade,
        s.marks
    FROM students s
    INNER JOIN grades g
        ON s.marks <= g.max_mark AND s.marks >= g.min_mark
)
SELECT
    name,
    grade,
    marks
FROM a
WHERE grade >= 8
UNION ALL
SELECT
    NULL AS name,
    grade,
    marks
FROM a
WHERE grade < 8
ORDER BY grade DESC, name, marks;

-- 11. medium - Top Competitors
SELECT
    s.hacker_id,
    h.name
FROM 
    difficulty d
    INNER JOIN
        (
        challenges ch
        INNER JOIN
            (
            submissions s
            INNER JOIN hackers h
                ON s.hacker_id = h.hacker_id
            )
            ON ch.challenge_id = s.challenge_id
        )
        ON d.difficulty_level = ch.difficulty_level
WHERE s.score = d.score
GROUP BY s.hacker_id, h.name
HAVING COUNT(DISTINCT s.submission_id) > 1
ORDER BY COUNT(DISTINCT s.submission_id) DESC, hacker_id;

-- 12. medium - Ollivander's Inventory
SELECT
    w.id,
    wp.age,
    w.coins_needed,
    w.power
FROM wands w
INNER JOIN wands_property wp
    ON w.code = wp.code
WHERE wp.is_evil = 0
    AND
    w.coins_needed IN 
    (SELECT MIN(w1.coins_needed)
     FROM wands w1
     INNER JOIN wands_property wp1
        ON w1.code = wp1.code
     WHERE wp1.is_evil = 0
        AND
        wp1.age = wp.age 
        AND
        w1.power = w.power
    )
ORDER BY power DESC, age DESC;
    
-- 13. medium - Challenges
SELECT
    h.hacker_id,
    h.name,
    COUNT(DISTINCT ch.challenge_id) AS ct
FROM hackers h
INNER JOIN challenges ch
    ON h.hacker_id = ch.hacker_id
GROUP BY h.hacker_id, h.name
HAVING ct =
        (SELECT COUNT(DISTINCT challenge_id) AS ct
        FROM challenges
        GROUP BY hacker_id
        ORDER BY ct DESC
        LIMIT 1)
        OR
        ct IN
        (SELECT
            ct
        FROM (
            SELECT hacker_id,COUNT(DISTINCT challenge_id) AS ct
            FROM challenges
            GROUP BY hacker_id) t1
        GROUP BY ct
        HAVING COUNT(hacker_id) = 1)
ORDER BY ct DESC, hacker_id;         

-- 14. medium -  Contest Leaderboard
SELECT
    t1.hacker_id,
    h.name,
    SUM(t1.max_score) AS max_score
FROM hackers h
INNER JOIN 
    (
    SELECT
        hacker_id,
        challenge_id,
        MAX(score) AS max_score
    FROM submissions 
    GROUP BY hacker_id, challenge_id) t1
    ON t1.hacker_id = h.hacker_id
GROUP BY t1.hacker_id, h.name
HAVING max_score > 0
ORDER BY max_score DESC, hacker_id;

-- 15. medium - SQL Project Planning
WITH a AS (
SELECT
 *,
 ROW_NUMBER() OVER(ORDER BY start_date) AS rn
 FROM projects
),
b AS (
SELECT 
    *,
    DATE_SUB(start_date, INTERVAL rn DAY) AS seq
FROM a)
SELECT
    MIN(start_date) AS start_date,
    MAX(end_date) AS end_date
FROM b
GROUP BY seq
ORDER BY DATEDIFF(MAX(end_date), MIN(start_date)), start_date;

-- 16. medium - Placements
SELECT
	t1.name
FROM 
	(SELECT s.id, s.name, p.salary FROM students s INNER JOIN packages p ON s.id = p.id) t1
INNER JOIN
	(SELECT f.id, p.salary AS friend_salary FROM friends f INNER JOIN packages p ON f.friend_id = p.id ) t2
	ON t1.id = t2.id
WHERE t1.salary < t2.friend_salary
ORDER BY t2.friend_salary;
    
-- 17. medium - Symmetric Pairs
SELECT
    DISTINCT f1.x, f1.y
FROM functions f1
INNER JOIN functions f2
    ON f1.x = f2.y AND f1.y = f2.x AND f1.x <> f2.x AND f1.y <> f2.y
WHERE f1.x <= f1.y
UNION ALL
SELECT x, y
FROM functions
WHERE x = y
GROUP BY x, y
HAVING COUNT(x) > 1
ORDER BY x;

-- 18. medium - Print Prime Numbers
SET @prime = 1;
SET @divisor = 1;

SELECT GROUP_CONCAT(prime SEPARATOR '&')
FROM 
    (SELECT @prime := @prime + 1 AS prime
    FROM information_schema.tables t1, information_schema.tables t2
    LIMIT 1000) list_of_prime
WHERE NOT EXISTS
    (SELECT *
    FROM
        (SELECT @divisor := @divisor + 1 AS divisor
        FROM information_schema.tables t1, information_schema.tables t2) list_of_divisor
    WHERE MOD(prime, divisor) = 0
        AND
        prime <> divisor);














    
























