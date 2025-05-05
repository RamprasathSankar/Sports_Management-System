-- Create Database
CREATE DATABASE SportsTeamsManagement;
USE SportsTeamsManagement;

-- Leagues Table
CREATE TABLE Leagues (
    league_id INT PRIMARY KEY AUTO_INCREMENT,
    league_name VARCHAR(100) UNIQUE NOT NULL,
    country VARCHAR(50)
);

-- Teams Table
CREATE TABLE Teams (
    team_id INT PRIMARY KEY AUTO_INCREMENT,
    team_name VARCHAR(100) UNIQUE NOT NULL,
    league_id INT,
    coach_name VARCHAR(100),
    founded_year YEAR,
    FOREIGN KEY (league_id) REFERENCES Leagues(league_id)
);

-- Players Table
CREATE TABLE Players (
    player_id INT PRIMARY KEY AUTO_INCREMENT,
    player_name VARCHAR(100) NOT NULL,
    team_id INT,
    position VARCHAR(50),
    age INT,
    nationality VARCHAR(50),
    FOREIGN KEY (team_id) REFERENCES Teams(team_id)
);

-- Matches Table
CREATE TABLE Matches (
    match_id INT PRIMARY KEY AUTO_INCREMENT,
    league_id INT,
    home_team_id INT,
    away_team_id INT,
    match_date DATETIME,
    venue VARCHAR(100),
    FOREIGN KEY (league_id) REFERENCES Leagues(league_id),
    FOREIGN KEY (home_team_id) REFERENCES Teams(team_id),
    FOREIGN KEY (away_team_id) REFERENCES Teams(team_id)
);

-- Scores Table
CREATE TABLE Scores (
    score_id INT PRIMARY KEY AUTO_INCREMENT,
    match_id INT,
    team_id INT,
    goals_scored INT DEFAULT 0,
    player_id INT,
    minute_scored INT,
    FOREIGN KEY (match_id) REFERENCES Matches(match_id),
    FOREIGN KEY (team_id) REFERENCES Teams(team_id),
    FOREIGN KEY (player_id) REFERENCES Players(player_id)
);




-- Inserting the data 

-- Leagues
INSERT INTO Leagues (league_name, country) VALUES
('Premier League', 'Delhi'),
('La Liga', 'Mumbai'),
('Serie A', 'Chennai'),
('Bundesliga', 'Kolkata'),
('Ligue 1', 'Hyderabad');

-- Teams
INSERT INTO Teams (team_name, league_id, coach_name, founded_year) VALUES
('Warrior', 1, 'Dinesh', 2021),
('Rockers', 1, 'Rahul', 2023),
('Legends', 2, 'John', 2022),
('Emperors', 2, 'Smith', 2024),
('Fireball', 4, 'Rohit', 2025);

-- Players
INSERT INTO Players (player_name, team_id, position, age, nationality) VALUES
('Siva', 1, 'Forward', 26, 'Indian'),
('Gowtham', 2, 'Defender', 31, 'Indian'),
('Harish', 3, 'Goaly', 36, 'Indian'),
('Yasar', 4, 'Backward', 35, 'Indian'),
('Rockey', 5, 'Midfielder', 29, 'Indian');

-- Matches
INSERT INTO Matches (league_id, home_team_id, away_team_id, match_date, venue) VALUES
(1, 1, 2, '2025-02-15 20:00:00', 'Nehru stadium'),
(2, 3, 4, '2025-02-18 21:00:00', 'Lotus stadium'),
(4, 5, 1, '2025-02-20 19:30:00', 'Mumbai football stadium');

-- Scores
INSERT INTO Scores (match_id, team_id, goals_scored, player_id, minute_scored) VALUES
(1, 1, 1, 1, 30),  
(1, 2, 2, 2, 45),  
(2, 3, 1, 3, 50),  
(2, 4, 1, 4, 70),  
(3, 5, 2, 5, 65);



-- DQL Quries 


-- Select all data
SELECT * FROM Leagues;
SELECT * FROM Teams;
SELECT * FROM Players;
SELECT * FROM Matches;
SELECT * FROM Scores;

-- JOIN with match info
SELECT m.match_id, l.league_name, t1.team_name AS home_team, t2.team_name AS away_team,
    s.goals_scored, p.player_name AS scorer, s.minute_scored
FROM Scores s
JOIN Matches m ON s.match_id = m.match_id
JOIN Teams t1 ON m.home_team_id = t1.team_id
JOIN Teams t2 ON m.away_team_id = t2.team_id
LEFT JOIN Players p ON s.player_id = p.player_id
JOIN Leagues l ON m.league_id = l.league_id
ORDER BY m.match_date;

-- Player Summary View Query
SELECT p.player_id, p.player_name, p.position, p.age, p.nationality, 
       t.team_name, l.league_name 
FROM Players p
JOIN Teams t ON p.team_id = t.team_id
JOIN Leagues l ON t.league_id = l.league_id;



-- Group By


-- Total goals per team
SELECT t.team_name, SUM(s.goals_scored) AS total_goals 
FROM Scores s
JOIN Teams t ON s.team_id = t.team_id
GROUP BY t.team_name;

-- Average player age per team
SELECT t.team_name, AVG(p.age) AS avg_age
FROM Players p
JOIN Teams t ON p.team_id = t.team_id
GROUP BY t.team_name;



-- SubQuries 


-- Teams with highest scorer
SELECT team_name FROM Teams 
WHERE team_id IN (
    SELECT team_id FROM Scores 
    WHERE goals_scored = (SELECT MAX(goals_scored) FROM Scores)
);

-- Players in team with highest average age
SELECT player_name, age FROM Players 
WHERE team_id = (
    SELECT team_id FROM Players
    GROUP BY team_id
    ORDER BY AVG(age) DESC
    LIMIT 1
);




-- Store Procedure


DELIMITER $$
CREATE PROCEDURE GetTeamsByLeague(IN leagueName VARCHAR(100))
BEGIN
    SELECT t.team_name, t.coach_name, t.founded_year 
    FROM Teams t
    JOIN Leagues l ON t.league_id = l.league_id
    WHERE l.league_name = leagueName;
END $$
DELIMITER ;

-- Call it
CALL GetTeamsByLeague('Premier League');




-- Trigger


DELIMITER $$
CREATE TRIGGER validate_goals BEFORE INSERT ON Scores
FOR EACH ROW
BEGIN
  IF NEW.goals_scored < 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Goals cannot be negative';
  END IF;
END $$
DELIMITER ;



-- View

CREATE VIEW PlayerSummary AS
SELECT p.player_name, p.age, p.position, t.team_name, l.league_name
FROM Players p
JOIN Teams t ON p.team_id = t.team_id
JOIN Leagues l ON t.league_id = l.league_id;



-- Indexex

CREATE INDEX idx_player_name ON Players(player_name);
CREATE INDEX idx_match_date ON Matches(match_date);


-- DML


-- Insert
INSERT INTO Players (player_name, team_id, position, age, nationality) 
VALUES ('Arun', 2, 'Forward', 25, 'Indian');

-- Update
UPDATE Teams SET coach_name = 'Manoj' WHERE team_name = 'Warrior';

-- Delete
DELETE FROM Scores WHERE score_id = 5;


-- TCL

START TRANSACTION;

UPDATE Players SET age = age + 1 WHERE nationality = 'Indian';
COMMIT;
ROLLBACK;

