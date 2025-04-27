
use Cricket_match_data_analysis;

select * from test_table;


-- """ 1. Top 3 most consistent players (highest avg. runs per match with min 10 matches played) """

SELECT batter, 
       COUNT(DISTINCT match_number) AS matches_played,
       SUM(runs_batter) AS total_runs,
       ROUND(SUM(runs_batter) / COUNT(DISTINCT match_number), 2) AS avg_runs_per_match
FROM  ipl_table
GROUP BY batter
HAVING COUNT(DISTINCT match_number) >= 10
ORDER BY avg_runs_per_match DESC
LIMIT 3;

-- 2: Venue with the highest total runs scored

SELECT venue, SUM(runs_total) AS total_runs
FROM ipl_table
GROUP BY venue
ORDER BY total_runs DESC
LIMIT 1;

-- 3. Top 5 Bowlers with highest dot ball percentage (min 100 balls bowled)

SELECT bowler,
       COUNT(*) AS total_balls,
       SUM(CASE WHEN runs_total = 0 THEN 1 ELSE 0 END) AS dot_balls,
       ROUND(100.0 * SUM(CASE WHEN runs_total = 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS dot_ball_percentage
FROM  ipl_table
WHERE runs_extras IS NOT NULL
GROUP BY bowler
HAVING COUNT(*) >= 100
ORDER BY dot_ball_percentage DESC
LIMIT 5;

-- 4. Team that chased the most successfully

SELECT batting_team, COUNT(DISTINCT match_number) AS successful_chases
FROM ipl_table
WHERE match_number IN (
    SELECT match_number
    FROM ipl_table
    GROUP BY match_number
    HAVING MAX(overs) >= 19) 
AND batting_team = winner
GROUP BY batting_team
ORDER BY successful_chases DESC
LIMIT 1;


-- 5. Batsmen who got out most frequently by the same bowler

SELECT batter, bowler, COUNT(*) AS dismissals
FROM ipl_table
WHERE player_out = batter
GROUP BY batter, bowler
HAVING COUNT(*) >= 3
ORDER BY dismissals DESC
LIMIT 5;

-- 1. Players with most 50+ scores in ODIs (minimum 5 such innings)

SELECT batter, COUNT(*) AS fifties
FROM (
    SELECT match_number, batter, SUM(runs_batter) AS runs
    FROM odi_table
    GROUP BY match_number, batter
    HAVING SUM(runs_batter) BETWEEN 50 AND 99
) AS sub
GROUP BY batter
HAVING COUNT(*) >= 5
ORDER BY fifties DESC;

-- 2. Bowlers with most wickets taken via LBW or Bowled

SELECT bowler, COUNT(*) AS total_wickets
FROM odi_table
WHERE wicket_type IN ('bowled', 'lbw')
GROUP BY bowler
ORDER BY total_wickets DESC
LIMIT 5;


-- 3. Identify the most common fielders involved in dismissals

SELECT fielder, COUNT(*) AS dismissals
FROM odi_table
WHERE fielder IS NOT NULL AND fielder != ''
GROUP BY fielder
ORDER BY dismissals DESC
LIMIT 5;

--  4  Teams with the most runs scored overall

SELECT batting_team, SUM(runs_total) AS total_runs
FROM odi_table
GROUP BY batting_team
ORDER BY total_runs DESC
LIMIT 5;

-- 5. Top partnerships (batter + non_striker pairs with highest combined runs in single innings)

SELECT batter, non_striker, match_number, SUM(runs_batter) AS partnership_runs
FROM odi_table
GROUP BY match_number, batter, non_striker
ORDER BY partnership_runs DESC
LIMIT 5;

## T20 Table related Queries 
-- 1: Top 5 batters by total runs

SELECT batter, SUM(runs_batter) AS total_runs
FROM t20s_table
GROUP BY batter
ORDER BY total_runs DESC
LIMIT 5;

-- 2: Top 5 bowlers by number of wickets

SELECT bowler, COUNT(*) AS wickets
FROM t20s_table
WHERE wicket_type IS NOT NULL AND wicket_type != ''
GROUP BY bowler
ORDER BY wickets DESC
LIMIT 5;

-- 3: Top 5 cities that hosted the most T20 matches

SELECT city, COUNT(DISTINCT match_number) AS matches_hosted
FROM t20s_table
WHERE city IS NOT NULL AND city!= ''  
GROUP BY city
ORDER BY matches_hosted DESC
LIMIT 5;

-- 4: Top bowler-batter matchups (most dismissals of a batter by a bowler)

SELECT bowler, player_out AS batter, COUNT(*) AS dismissals
FROM t20s_table
WHERE player_out IS NOT NULL AND player_out != ''
GROUP BY bowler, player_out
HAVING COUNT(*) >= 2
ORDER BY dismissals DESC
LIMIT 5;

-- 5: Best finishing teams — teams scoring most runs in the last 5 overs (16-20)

SELECT batting_team, SUM(runs_total) AS death_overs_runs
FROM t20s_table
WHERE overs BETWEEN 16 AND 20
GROUP BY batting_team
ORDER BY death_overs_runs DESC
LIMIT 5;


## TEST MATCH RELATED QUERIES 

-- 1: Most centuries by a batter in Test matches (individual score ≥ 100 in a match)

SELECT batter, COUNT(*) AS centuries
FROM (
    SELECT match_number, batter, SUM(runs_batter) AS runs
    FROM test_table
    GROUP BY match_number, batter
    HAVING SUM(runs_batter) >= 100
) AS sub
GROUP BY batter
ORDER BY centuries DESC
LIMIT 5;

-- 2: Most consistent batters — scored 30+ runs in most Test innings

SELECT batter, COUNT(*) AS innings_50plus
FROM (
    SELECT match_number, batter, SUM(runs_batter) AS runs
    FROM test_table
    GROUP BY match_number, batter
    HAVING SUM(runs_batter) >= 50
) AS sub
GROUP BY batter
ORDER BY innings_50plus DESC
LIMIT 5;

-- 3 : Longest Test matches (by number of days between start and end date)

SELECT match_number, team1, team2, city, venue,
       DATEDIFF(match_end_date, match_start_date) + 1 AS match_duration_days
FROM test_table
GROUP BY match_number, team1, team2, city, venue, match_start_date, match_end_date
ORDER BY match_duration_days DESC
LIMIT 5;

-- 4: Teams with the most wins in Test matches

SELECT winner, COUNT(DISTINCT match_number) AS wins
FROM test_table
WHERE winner IS NOT NULL AND winner != ''
GROUP BY winner
ORDER BY wins DESC
LIMIT 5;

-- 5: Top 5 bowlers by number of wickets

SELECT bowler, COUNT(*) AS wickets
FROM test_table
WHERE wicket_type IS NOT NULL AND wicket_type != ''
GROUP BY bowler
ORDER BY wickets DESC
LIMIT 5;