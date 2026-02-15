/*----------------------------------------------------------
1.what are the top skills based on salary for 'Data Analyst'
in the philippines.
-----------------------------------------------------------*/
SELECT
    sk.skills AS top_skills,
    AVG(salary_year_avg) AS avg_salary
FROM
    skills_dim AS sk
JOIN
    skills_job_dim AS s
    ON s.skill_id = sk.skill_id
JOIN
    job_postings_fact AS j
    ON  j.job_id = s.job_id
WHERE salary_year_avg IS NOT NULL AND
    job_location = 'Philippines' AND
    job_title_short = 'Data Analyst'
GROUP BY
    sk.skills  
ORDER BY
    avg_salary DESC
LIMIT 5;

/*--------------------------------------------------
2. what are the top-paying roles in the philippines?
---------------------------------------------------*/
SELECT
    job_title_short AS roles,
    salary_year_avg
FROM
    job_postings_fact
WHERE job_location = 'Philippines' AND
    salary_year_avg > (
        SELECT
            AVG(salary_year_avg)
        FROM
            job_postings_fact
    )
/*----------------------------------------------------------
3. what are the skills required for these top paying roles
in the philippines?
------------------------------------------------------------*/
WITH top_paying_jobs AS (
    SELECT 
        skill_id,
        j.job_title_short AS roles,
        j.job_location,
        j.salary_year_avg AS yearly_salary
    FROM
        skills_job_dim
    JOIN
        job_postings_fact AS j
        ON j.job_id = skills_job_dim.job_id
    WHERE j.salary_year_avg IS NOT NULL AND
          j.job_location = 'Philippines'  
)
SELECT
    s.skills,
    t.roles,
    AVG(t.yearly_salary) AS avg_salary
FROM
    skills_dim AS s
JOIN
    top_paying_jobs AS t
    ON t.skill_id = s.skill_id
GROUP BY
    s.skills,
    t.roles
ORDER BY
    avg_salary DESC
LIMIT 10;

/*------------------------------------------------------
4.What skills are required for high-paying jobs but are 
    relatively rare in the job market?"
-------------------------------------------------------*/
WITH skills_required AS (
    SELECT
        sj.skill_id,
        j.salary_year_avg
    FROM
        skills_job_dim AS sj
    JOIN
        job_postings_fact AS j
        ON j.job_id = sj.job_id
    WHERE j.salary_year_avg IS NOT NULL
)
SELECT
    s.skills,
    COUNT(*) AS demand,
    AVG(sk.salary_year_avg) avg_salary
FROM
    skills_dim AS s
JOIN
    skills_required AS sk
    ON sk.skill_id = s.skill_id
GROUP BY
    s.skills
HAVING
    COUNT(*) < 10
ORDER BY
    avg_salary DESC;

/*---------------------------------------------
5. what are the most optimal skills to learn?
 • Optimal: High Demand AND High Paying
---------------------------------------------*/
SELECT
    skills,
    COUNT(*) skill_demand,
    AVG(j.salary_year_avg) salary_avg
FROM
    skills_dim
JOIN
    skills_job_dim AS s
    ON s.skill_id = skills_dim.skill_id
JOIN
    job_postings_fact AS j
    ON s.job_id = j.job_id
WHERE j.salary_year_avg IS NOT NULL
GROUP BY
    skills
HAVING
    AVG(salary_year_avg) > 100000
ORDER BY
    skill_demand DESC
LIMIT 10;