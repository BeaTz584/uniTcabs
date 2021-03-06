-- phpMyAdmin SQL Dump
-- version 4.9.5
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: May 30, 2021 at 08:20 AM
-- Server version: 10.4.15-MariaDB
-- PHP Version: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `u552397378_tcabs`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `DeleteProj` (IN `pid` INT(10))  NO SQL
BEGIN 
  DECLARE `Error` CONDITION FOR SQLSTATE '45000';
  DECLARE vProd_ID INT(10);
  SELECT count(ProjectID) INTO vProd_ID FROM teams WHERE ProjectID = pid;

IF vProd_ID > 0 THEN 
  SIGNAL `Error` SET MESSAGE_TEXT = 'You cannot delete a project that has been assigned to a team!';
ELSE
  DELETE FROM projects WHERE ProjectID = pid; 
END IF;
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `displaystu` ()  NO SQL
sp: BEGIN
      DECLARE vCnt INT;
DECLARE `Error` CONDITION FOR SQLSTATE '45000';
      DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;        
        RESIGNAL;
      END;


      SELECT COUNT(1)
      INTO vCnt
      FROM DUAL
      WHERE EXISTS (SELECT 1 FROM `user` 
LEFT JOIN `userroles` 
ON `userroles`.`UserID` = `user`.`UserID` );

IF vCnt = 0 THEN
SIGNAL `Error` SET MESSAGE_TEXT = 'No Rows Found';
LEAVE sp;
ELSE

   SELECT `user`.`Firstname`, `user`.`Surname`, `userroles`.`RoleID`, `enrolment`.`Unitoffer`, `unitsoffering`.`Semester`, `unit`.`Unitname`
FROM `user` 
LEFT JOIN `userroles` 
ON `userroles`.`UserID` = `user`.`UserID` 
LEFT JOIN `enrolment` 
ON `enrolment`.`UserID` = `user`.`UserID` 
LEFT JOIN `unitsoffering` 
ON `enrolment`.`Unitoffer` = `unitsoffering`.`Unitoffer` 
LEFT JOIN `unit` 
ON `unitsoffering`.`Unitcode` = `unit`.`Unitcode`
where userroles.RoleID = 5;

END IF;
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `DisplayUnit` ()  NO SQL
sp: BEGIN
      DECLARE vCnt INT;
DECLARE `Error` CONDITION FOR SQLSTATE '45000';
      DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;        
        RESIGNAL;
      END;

IF vCnt = 0 THEN
SIGNAL `Error` SET MESSAGE_TEXT = 'No Rows Found';
LEAVE sp;
ELSE

SELECT unit.Unitname,
             unitsoffering.Location,
             unitsoffering.ConvenorID,
             unitsoffering.Year,
             unitsoffering.Semester,
             unitsoffering.Teachingper
      FROM unitsoffering INNER JOIN unit ON
           unit.Unitcode = unitsoffering.Unitcode;
END IF;
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `disunitstudy` ()  BEGIN  
SELECT unit.Unitname,unitsoffering.Location,unitsoffering.ConvenorID,unitsoffering.Year,unitsoffering.Semester,unitsoffering.Teachingper from unitsoffering INNER JOIN unit ON unit.Unitcode = unitsoffering.Unitcode; 
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `EnrolUnit` (IN `pUserid` INT(10), IN `pUnitoffer` INT(11), IN `pTeamid` VARCHAR(10), OUT `pErrMsg` VARCHAR(4000))  sp: BEGIN
  DECLARE vCnt BIGINT(20);

  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
    ROLLBACK;
    SET pErrMsg = 'An error has occurred and operation rollbacked';
  END;

  SET pErrMsg = '';
  
  SET vCnt = 0;

  SELECT COUNT(*) INTO vCnt FROM user WHERE UserID = pUserID;
      IF vCnt = 0 THEN
        SET pErrMsg = 'User ID not found';
        LEAVE sp;
      END IF;
	  
	 SET vCnt = 0;
	  
	  SELECT COUNT(*) INTO vCnt FROM userroles WHERE RoleID = 5 and UserID = pUserID;
      IF vCnt = 0 THEN
        SET pErrMsg = 'User role is not student';
        LEAVE sp;
      END IF;
  
      SET vCnt = 0;
  
  	  SELECT COUNT(*) INTO vCnt FROM unitsoffering WHERE Unitoffer = pUnitoffer;
      IF vCnt = 0 THEN
        SET pErrMsg = 'Unit offer not found';
        LEAVE sp;
      END IF;
	  
	  SET vCnt = 0;
	  
	  SELECT COUNT(*) INTO vCnt FROM teams WHERE TeamID = pTeamID;
      IF vCnt = 0 THEN
        SET pErrMsg = 'Team ID not found';
        LEAVE sp;
      END IF;
	  
	  SET vCnt = 0;
	  
	  	  SELECT COUNT(*) INTO vCnt FROM enrolment WHERE UserID = pUserID and TeamID = pTeamID and Unitoffer = pUnitoffer;
      IF vCnt > 0 THEN
        SET vCnt = 'User has already enrolled in this unit and team';
        LEAVE sp;
      END IF;
  
  INSERT INTO enrolment
    (UserID, TeamID, Unitoffer)
  VALUES
    (pUserID, pTeamID, pUnitoffer);
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `Login` (IN `pUserID` VARCHAR(255), IN `pURL` VARCHAR(255), OUT `pOUT` BOOLEAN)  BEGIN
DECLARE vUserID INT(2);
DECLARE vURL INT(2);
DECLARE vURLID INT(2);

SELECT MIN(roles.RoleID) into vUserID from roles JOIN (userroles, user) ON (userroles.RoleID=roles.RoleID AND user.UserID=userroles.UserID) WHERE user.UserID = pUserID;

SELECT PermID INTO vURLID FROM `permissions` WHERE pMenuurl=pURL;

SELECT MAX(roles.RoleID) INTO vURL FROM roles JOIN (rolespermissions, permissions) ON (rolespermissions.RoleID=roles.RoleID AND permissions.PermID=rolespermissions.PermID) WHERE permissions.PermID = vURLID;

IF vURL>=vUserID THEN
SET pOUT = True;
ELSEIF vURL<vUserID THEN
SET pOUT = False;
END IF;
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `Menulist` (IN `pMenuname` VARCHAR(255), IN `PmenuURL` VARCHAR(255), IN `PmenuRole` VARCHAR(255))  BEGIN
DECLARE vPermID INT(2);
DECLARE vRoleID INT(2);

SELECT AUTO_INCREMENT INTO vPermID
FROM information_schema.tables 
WHERE table_name = 'permissions' 
and table_schema = 'u552397378_tcabs';

INSERT INTO permissions(Permname, pMenuurl) VALUES (pMenuname, PmenuURL);

SELECT RoleID INTO vRoleID
FROM roles 
Where Rolename = pmenuRole;

INSERT INTO rolespermissions(RoleID, PermID) 
VALUES (vRoleID, vPermID);
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `MenuRole` (IN `pPermname` VARCHAR(255), IN `pRole` VARCHAR(255))  BEGIN
DECLARE vPermID INT(10);
DECLARE vRoleID INT(10);

SELECT PermID INTO vPermID
FROM permissions
Where Permname = pPermname;

SELECT RoleID INTO vRoleID
FROM roles 
Where Rolename = pRole;

INSERT INTO rolespermissions(RoleID, PermID) 
VALUES (vRoleID, vPermID);
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `Navbar` (IN `pUserID` INT(255))  BEGIN

SELECT roles.RoleID FROM roles JOIN (userroles, user) ON (userroles.RoleID=roles.RoleID AND user.UserID=userroles.UserID) WHERE user.UserID = pUserID;

END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `passchange` (IN `pID` INT, IN `pNew` VARCHAR(255), IN `pRe` VARCHAR(255), IN `pNewup` VARCHAR(255))  BEGIN
DECLARE `Error` CONDITION FOR SQLSTATE '45000';
DECLARE vPass Varchar(255);

SELECT Password INTO vPass FROM user WHERE UserID=pID;

IF pNew<>pRE THEN
SIGNAL `Error` SET MESSAGE_TEXT = 'Passowords do not match';
ELSE
UPDATE user SET Password=pNewup WHERE UserID=pID;
END IF;
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `perm` (IN `pUserID` INT(10), OUT `pRole` VARCHAR(20))  BEGIN
select rolename INTO pRole from roles JOIN (userroles, user) ON (userroles.RoleID=roles.RoleID and userroles.UserID=user.UserID) WHERE user.UserID=pUserID;
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `RegEmp` (IN `pUsername` VARCHAR(255), IN `pPassword` VARCHAR(255), IN `pFirstname` VARCHAR(50), IN `pSurname` VARCHAR(50), IN `pEmail` VARCHAR(255), IN `pPhonenumber` VARCHAR(10), IN `pRole` VARCHAR(20))  sp: BEGIN
DECLARE `Error` CONDITION FOR SQLSTATE '45000';
DECLARE vUserID INT(10);
DECLARE vRoleID INT(1);
DECLARE vUser INT(1);
DECLARE vID INT(1);
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK;
RESIGNAL;
END;

SELECT AUTO_INCREMENT INTO vUserID
FROM information_schema.tables 
WHERE table_name = 'user' 
and table_schema = 'u552397378_tcabs';

Select count(UserID) INTO vID From user Where UserID=vUserID;

Select count(username) INTO vUser From user Where Username=pUsername;

IF vID > 0 THEN
SIGNAL `Error` SET MESSAGE_TEXT = 'User ID already Exists.';
LEAVE sp;
ELSEIF vUser > 0 THEN
SIGNAL `Error` SET MESSAGE_TEXT = 'Username Already in Use, Please select a different username.';
LEAVE sp;
ELSEIF pEmail NOT LIKE '%@%' THEN
SIGNAL `Error` SET MESSAGE_TEXT = 'Email Must Contain a @ Symbol.';
LEAVE sp;
ELSEIF  LENGTH(pPhonenumber)<>10 THEN
SIGNAL `Error` SET MESSAGE_TEXT = 'Phonenumber must be valid.';
LEAVE sp;
ELSE


INSERT INTO user (Username, Password, Firstname, Surname, Email, Phonenumber) 
VALUES (pUsername, pPassword, pFirstname, pSurname, pEmail, pPhonenumber);

SELECT RoleID INTO vRoleID
FROM roles 
Where Rolename = pRole;

INSERT INTO userroles(UserID, RoleID) 
VALUES (vUserID, vRoleID);
END IF;
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `RegMem` (IN `puid` INT(10), IN `pTnumber` INT(10), IN `puname` VARCHAR(255), IN `pfname` VARCHAR(20), IN `psname` VARCHAR(20), IN `ppid` INT(10), IN `pUnitcode` INT(11))  BEGIN

DECLARE vUserID INT(10);
DECLARE vTeamID INT(10);
DECLARE vUnitID INT(11);

DECLARE vEnrolmentc INT(4);
SELECT AUTO_INCREMENT INTO vEnrolmentc FROM information_schema.tables 
where table_name = 'enrolment' and table_schema = 'tcabs';


SELECT TeamID INTO vTeamID From teams WHERE Teamnumber=pTnumber;

SELECT Unitoffer INTO vUnitID FROM unitsoffering WHERE Unitcode = pUnitcode ;

INSERT INTO enrolment(UserID,TeamID,Unitoffer) VALUES (puid, vTeamID, vUnitID);

END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `Regnewunit` (IN `punitcode` VARCHAR(10), IN `punitname` VARCHAR(255), OUT `pErrMsg` VARCHAR(4000))  NO SQL
BEGIN
DECLARE EXIT HANDLER FOR SQLSTATE '23000' BEGIN
    SET pErrMsg = CONCAT(UPPER(punitcode), ' has already existed. Please try other ID.');  
  END;
DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
    ROLLBACK;
    SET pErrMsg = 'An error has occurred and operation rollbacked';
  END;
  SET pErrMsg = '';
INSERT INTO unit (Unitcode, Unitname)
VALUES (UPPER(punitcode),punitname);
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `RegProj` (IN `pproj_name` VARCHAR(50), IN `pproj_desc` VARCHAR(200), IN `punitcode` VARCHAR(10))  NO SQL
BEGIN 
  DECLARE `Error` CONDITION FOR SQLSTATE '45000';
  -- DECLARE vProj_ID INT(10);
  DECLARE vUnitcode INT(10);
  DECLARE vProj_name INT(10);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SELECT count(Projectname) INTO vProj_name FROM projects WHERE Projectname = pproj_name;
  -- SELECT count(ProjectID) INTO vProj_ID FROM projects WHERE ProjectID = pid;
  SELECT count(Unitcode) INTO vUnitcode From projects Where Unitcode = punitcode;

  -- IF vProj_ID > 0 THEN 
  -- SIGNAL `Error` SET MESSAGE_TEXT = 'Project ID already exists.';
  IF vProj_name > 0 THEN 
  SIGNAL `Error` SET MESSAGE_TEXT = 'Project name already exists, please choose another';
  ELSEIF vUnitcode > 9 THEN 
  SIGNAL `Error` SET MESSAGE_TEXT = 'You cannot register more than 10 projects for any unit!';
  ELSE
  INSERT INTO projects(Projectname, Projectdesc, Unitcode) VALUES(pproj_name, pproj_desc, punitcode); 
  END IF;
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `RegStu` (IN `pPassword` VARCHAR(255), IN `pFirstname` VARCHAR(50), IN `pSurname` VARCHAR(50), IN `pEmail` VARCHAR(255), IN `pPhonenumber` INT(10))  sp: BEGIN
DECLARE `Error` CONDITION FOR SQLSTATE '45000';
DECLARE vUserID INT(10);
DECLARE vRoleID INT(1);
DECLARE vUser INT(1);
DECLARE vID INT(1);
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK;
RESIGNAL;
END;

SELECT AUTO_INCREMENT INTO vUserID
FROM information_schema.tables 
WHERE table_name = 'user' 
and table_schema = 'u552397378_tcabs';

Select count(UserID) INTO vID From user Where UserID=vUserID;

IF vID > 0 THEN
SIGNAL `Error` SET MESSAGE_TEXT = 'User ID already Exists.';
ELSEIF pEmail NOT LIKE '%@%' THEN
SIGNAL `Error` SET MESSAGE_TEXT = 'Email Must Contain a @ Symbol.';
ELSEIF  LENGTH(pPhonenumber)<>10 THEN
SIGNAL `Error` SET MESSAGE_TEXT = 'Phonenumber must be valid.';
ELSE

INSERT INTO user (Username, Password, Firstname, Surname, Email, Phonenumber) 
VALUES (vUserID, pPassword, pFirstname, pSurname, pEmail, pPhonenumber);

SELECT RoleID INTO vRoleID
FROM roles 
Where Rolename = 'Student';

INSERT INTO userroles(UserID, RoleID) 
VALUES (vUserID, vRoleID);
END IF;
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `Regsuper` ()  NO SQL
sp: BEGIN
      DECLARE vCnt INT;
DECLARE `Error` CONDITION FOR SQLSTATE '45000';
      DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;        
        RESIGNAL;
      END;

SELECT COUNT(*) INTO vCnt
FROM user
LEFT JOIN userroles
ON userroles.UserID=user.UserID
where userroles.RoleID = 4;

IF vCnt = 0 THEN
SIGNAL `Error` SET MESSAGE_TEXT = 'No Rows Found';
LEAVE sp;
ELSE

SELECT user.Firstname, user.Surname, user.Email
FROM user
LEFT JOIN userroles
ON userroles.UserID=user.UserID
where userroles.RoleID = 4;

END IF;
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `RegTeam` (IN `pTName` VARCHAR(255), IN `pTnumber` INT(3), IN `pProname` INT(10))  BEGIN

Declare vProID INT(10);
Declare vTeamID INT(10);

SELECT AUTO_INCREMENT INTO vTeamID FROM information_schema.tables 
where table_name = 'teams' and table_schema = 'tcabs';

SELECT ProjectID INTO vProID FROM projects WHERE Projectname = pProname; 

INSERT INTO teams(Teamname,Teamnumber,ProjectID) 
VALUES (pTName, PTnumber, vProID);

END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `Regunit` (IN `pLocation` VARCHAR(225), IN `pFaculty` VARCHAR(20), IN `pConvenorID` VARCHAR(10), IN `pYear` INT(4), IN `pSemester` INT(2), IN `pTeachingper` INT(2), IN `pUnitcode` VARCHAR(50))  BEGIN
DECLARE vUnit Varchar(10);
SELECT Unitcode INTO vUnit FROM unit Where Unitname = pUnitcode;

INSERT INTO unitsoffering (Location, Faculty, ConvenorID,Year, Semester, Teachingper,Unitcode)
VALUES (pLocation,pFaculty,pConvenorID, pYear,pSemester,pTeachingper,vUnit);
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `SelectProj` (IN `pid` INT(10))  BEGIN SELECT * FROM projects WHERE projects.ProjectID = pid; END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `UpdateProj` (IN `pproj_name` VARCHAR(50), IN `pproj_desc` VARCHAR(200), IN `punitcode` VARCHAR(10), IN `pid` INT(10))  NO SQL
BEGIN 
DECLARE `Error` CONDITION FOR SQLSTATE '45000';
DECLARE vProj_name VARCHAR(50);
DECLARE vUnitcode INT(10);
DECLARE EXIT HANDLER FOR SQLEXCEPTION 
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

Select count(Projectname) INTO vProj_name From projects Where Projectname=pproj_name;
Select count(Unitcode) INTO vUnitcode From projects Where Unitcode = punitcode;

IF vProj_name > 1 THEN
  SIGNAL `Error` SET MESSAGE_TEXT = 'Project name alredy exists, please choose another';
ELSEIF vUnitcode > 9 THEN 
  SIGNAL `Error` SET MESSAGE_TEXT = 'You cannot register more than 10 projects for any unit!';
ELSE
UPDATE projects 
SET Projectname = pproj_name, Projectdesc = pproj_desc, Unitcode = pUnitcode 
WHERE ProjectID = pid; 
END IF;
END$$

CREATE DEFINER=`u552397378_tcabs`@`127.0.0.1` PROCEDURE `Yearupdate` ()  BEGIN
INSERT INTO `year` (`year`) VALUES ('2021'),('2022'),('2023'),('2024'),('2025'),('2026'),('2027'),('2028'),('2029'),('2030'),('2031'),('2032'),('2033'),('2034'),('2035'),('2036'),('2037'),('2038'),('2039'),('2040'),('2041'),('2042'),('2043'),('2044'),('2045'),('2046'),('2047'),('2048'),('2049'),('2050'),('2051'),('2052'),('2053'),('2054'),('2055'),('2056'),('2057'),('2058'),('2059'),('2060'),('2061'),('2062'),('2063'),('2064'),('2065'),('2066'),('2067'),('2068'),('2069'),('2070'),('2071');
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `enrolment`
--

CREATE TABLE `enrolment` (
  `Enrolmentc` int(4) NOT NULL,
  `UserID` int(10) NOT NULL,
  `TeamID` int(10) NOT NULL,
  `Unitoffer` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `enrolment`
--

INSERT INTO `enrolment` (`Enrolmentc`, `UserID`, `TeamID`, `Unitoffer`) VALUES
(8, 1, 21, 6);

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `PermID` int(10) NOT NULL,
  `Permname` varchar(50) NOT NULL,
  `pMenuurl` varchar(200) NOT NULL,
  `pMenustat` varchar(20) NOT NULL DEFAULT 'Enable'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`PermID`, `Permname`, `pMenuurl`, `pMenustat`) VALUES
(1, 'Home', 'home.php', 'Enable'),
(2, 'Register Employee', 'regemp.php', 'Enable'),
(3, 'CSV', 'CSV.php', 'Enable'),
(4, 'AddMenuphp', 'Addmenudb.php', 'Enable'),
(5, 'Add Menu', 'addmenu.php', 'Enable'),
(6, 'Register Unit', 'regunit.php', 'Enable'),
(7, 'Register Unit PHP', 'Registerunit.php', 'Enable'),
(8, 'Register Member', 'regtmember.php', 'Enable'),
(9, 'Register Team', 'Regteam.php', 'Enable'),
(10, 'Register Student', 'regstu.php', 'Enable'),
(11, 'Register Team Member DB', 'Registertmember.php', 'Enable'),
(12, 'Register Student DB', 'registerstu.php', 'Enable'),
(13, 'Register Employee DB', 'registeremp.php', 'Enable'),
(14, 'Register Team DB', 'register_team.php', 'Enable'),
(15, 'Profile', 'profile.php', 'Enable'),
(16, 'Edit/Update Employee', 'userdetails.php', 'Enable'),
(17, 'Edit Employee', 'edituser.php', 'Enable'),
(18, 'Delete Employee', 'deleteuser.php', 'Enable'),
(19, 'Register Projects', 'Reg_Project.php', 'Enable'),
(20, 'Add Permission', 'addmenuperm.php', 'Enable'),
(22, 'Delete Permission', 'delete_menu.php', 'Enable'),
(25, 'Password Change', 'passchange.php', 'Enable'),
(28, ' Add student to team', 'enrolunit.php', 'Enable'),
(29, 'List projects ', 'listregprjects.php', 'Enable'),
(30, 'List of Supervisors', 'listRegsuperviser.php', 'Enable'),
(34, 'Update project', 'Update_reg_proj.php', 'Enable'),
(36, 'List of registered units', 'listregconandunit.php', 'Enable'),
(37, 'List of students', 'listregstudyinstudy.php', 'Enable'),
(39, 'Register new unit', 'Registernewunit.php', 'Enable'),
(40, 'reg new unit', 'regnewunit.php', 'Enable'),
(45, 'delete team', 'delete.php', 'Enable'),
(46, 'Edit team', 'edit.php', 'Enable');

-- --------------------------------------------------------

--
-- Table structure for table `projects`
--

CREATE TABLE `projects` (
  `ProjectID` int(10) NOT NULL,
  `Projectname` varchar(50) NOT NULL,
  `Projectdesc` varchar(200) NOT NULL,
  `Unitcode` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `projects`
--

INSERT INTO `projects` (`ProjectID`, `Projectname`, `Projectdesc`, `Unitcode`) VALUES
(4452, 'tcabs', 'team ', 'INF30011');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `RoleID` int(2) NOT NULL,
  `Rolename` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`RoleID`, `Rolename`) VALUES
(1, 'Super Admin'),
(2, 'Admin'),
(3, 'Convenor'),
(4, 'Supervisor'),
(5, 'Student');

-- --------------------------------------------------------

--
-- Table structure for table `rolespermissions`
--

CREATE TABLE `rolespermissions` (
  `Rolesper` int(2) NOT NULL,
  `RoleID` int(2) NOT NULL,
  `PermID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `rolespermissions`
--

INSERT INTO `rolespermissions` (`Rolesper`, `RoleID`, `PermID`) VALUES
(54, 1, 1),
(60, 1, 2),
(2, 1, 4),
(1, 1, 5),
(63, 1, 6),
(65, 1, 7),
(74, 1, 13),
(76, 1, 15),
(90, 1, 16),
(87, 1, 17),
(91, 1, 18),
(3, 1, 20),
(4, 1, 22),
(81, 1, 25),
(144, 2, 2),
(145, 2, 6),
(128, 2, 16),
(125, 2, 17),
(126, 2, 17),
(127, 2, 18),
(140, 2, 30),
(141, 2, 36),
(142, 2, 39),
(143, 2, 40),
(56, 3, 1),
(62, 3, 3),
(67, 3, 8),
(69, 3, 9),
(71, 3, 10),
(68, 3, 11),
(73, 3, 12),
(75, 3, 14),
(78, 3, 15),
(86, 3, 19),
(83, 3, 25),
(96, 3, 28),
(99, 3, 29),
(110, 3, 34),
(113, 3, 37),
(134, 3, 45),
(135, 3, 45),
(136, 3, 46),
(107, 4, 1),
(119, 4, 15),
(121, 4, 25),
(137, 5, 1),
(139, 5, 15),
(138, 5, 25);

-- --------------------------------------------------------

--
-- Table structure for table `teachingperiod`
--

CREATE TABLE `teachingperiod` (
  `Teachingper` int(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `teachingperiod`
--

INSERT INTO `teachingperiod` (`Teachingper`) VALUES
(1),
(2),
(3);

-- --------------------------------------------------------

--
-- Table structure for table `teams`
--

CREATE TABLE `teams` (
  `TeamID` int(10) NOT NULL,
  `Teamname` varchar(225) NOT NULL,
  `Teamnumber` int(3) NOT NULL,
  `ProjectID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `teams`
--

INSERT INTO `teams` (`TeamID`, `Teamname`, `Teamnumber`, `ProjectID`) VALUES
(21, 'team 1', 1, 4452);

-- --------------------------------------------------------

--
-- Table structure for table `unit`
--

CREATE TABLE `unit` (
  `Unitcode` varchar(10) NOT NULL,
  `Unitname` varchar(200) NOT NULL,
  `Faculty` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `unit`
--

INSERT INTO `unit` (`Unitcode`, `Unitname`, `Faculty`) VALUES
('INF30011', 'Database Implementation', 'Technology');

-- --------------------------------------------------------

--
-- Table structure for table `unitsoffering`
--

CREATE TABLE `unitsoffering` (
  `Unitoffer` int(11) NOT NULL,
  `Location` varchar(225) NOT NULL,
  `Faculty` varchar(20) NOT NULL,
  `ConvenorID` varchar(10) NOT NULL,
  `Year` int(4) NOT NULL,
  `Semester` int(2) NOT NULL,
  `Teachingper` int(2) NOT NULL,
  `Unitcode` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `unitsoffering`
--

INSERT INTO `unitsoffering` (`Unitoffer`, `Location`, `Faculty`, `ConvenorID`, `Year`, `Semester`, `Teachingper`, `Unitcode`) VALUES
(6, 'Hawthorn', '12', '21', 2026, 2, 2, 'INF30011'),
(7, 'Hawthorn', 'it', '111', 2021, 1, 2, 'INF30011');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `UserID` int(10) NOT NULL,
  `Username` varchar(255) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Firstname` varchar(50) NOT NULL,
  `Surname` varchar(50) NOT NULL,
  `Email` varchar(225) NOT NULL,
  `Phonenumber` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`UserID`, `Username`, `Password`, `Firstname`, `Surname`, `Email`, `Phonenumber`) VALUES
(1, 'SAdmin', '$2y$10$YHV1glX4WoZuOYlSlmWNA.UWTr50eD1SdYz0ngsv8OkPdfBPbQfIq', 'Super', 'Admin', 'Super@Admin', 1234567891),
(2, 'Admin', '$2y$10$egUHh5Lk9FND3nLzrNN7i.brXoCXR.H4DQdIuR84XXNomswBRlIV6', 'Admin', 'Admin', 'Admin@Admin', 1234567890),
(3, 'Convenor', '$2y$10$UdAlnxccCuIcANj56xgDquI2GsXwVVVWCGx5FzaZCsIYoC0S9GL9i', 'Convenor', 'Convenor', 'Convenor@Convenor', 2147483647),
(4, 'Supervisor', '$2y$10$X22HqNjgtCGRBCz/iihbN.1UcvHnYQ/uLS9xh8ABD/XoA6BCo3kYe', 'Supervisor', 'Supervisor', 'Supervisor@Supervisor', 2147483647),
(5, 'Student', '$2y$10$96AXl3XZ8nUGxS4GmM/qPuNDLiVgMj/rCkpQRyH67d3FreF484qqm', 'Student', 'Student', 'Student@Student', 1234567890),
(47, 'LPola-Carter1', '$2y$10$oN2rmNGC24sDPgDAotI8tuRpNJ8lxE1HVk8YfPVy5bF0iS.6OixQe', 'Lachlan', 'Pola-Carter', 'Loksta456@gmail.com', 614037198),
(54, 'MLiolios', '$2y$10$JhKwn2gSzHbmrN219ye.H.X4oLsprGPNT4DueuRxU5HvNHEYb7Q9u', 'Michael', 'Liolios', 'mgliolios@gmail.com', 614048243),
(58, 'LPola-Carter12', '$2y$10$16LDXGscA.Pbz2tMA79CBOBdASWjnFk9QMMLI.MLzZKYgSwnONXaG', 'Lachlan', 'Pola-Carter', 'Loksta456@gmail.com', 614037198),
(59, 'LPola-Carter', '$2y$10$zXqU7Lru2YVZooG3XfWpTuuPxNeM00FVnn70/bAxHPsAe8VMsRbnu', 'Lachlan', 'Pola-Carter', 'Loksta456@gmail.com', 614037198),
(60, '60', '$2y$10$UYucGIjsrIRHbrg2C2vAWO1jF4ioY0Usil2LPrPfveGZKTre0j53W', 'test', 'test', 'test@', 1234567788),
(61, '61', '$2y$10$QQezpKPYpD8Qh6zg.gmsFuaQocky9/amUp/UbX1ugC3r/fXhPFdwy', 'test', 'test', 'test@', 1234567788),
(62, 'DThaker', '$2y$10$gRghVOLrxNSisqTaiPkUTeP2gAy7asHwYPwUvAuQMbSvXStOGC8em', 'Dev', 'Thaker', 'devhthaker@gmail.com', 416278735),
(63, '63', '$2y$10$Vpi3hcGoHihhCzC6apLHSuy8Emupz0tDGLU/G6Fb0G1nlfqX2JUWG', 'Qing', 'Yang', 'c@sd', 2147483647);

-- --------------------------------------------------------

--
-- Table structure for table `userroles`
--

CREATE TABLE `userroles` (
  `Userroles` int(10) NOT NULL,
  `UserID` int(10) NOT NULL,
  `RoleID` int(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `userroles`
--

INSERT INTO `userroles` (`Userroles`, `UserID`, `RoleID`) VALUES
(4, 1, 1),
(5, 2, 2),
(6, 3, 3),
(7, 4, 4),
(8, 5, 5),
(13, 1, 3),
(55, 54, 4),
(59, 58, 3),
(60, 59, 2),
(61, 60, 5),
(62, 61, 5),
(63, 62, 4),
(64, 63, 5);

-- --------------------------------------------------------

--
-- Table structure for table `year`
--

CREATE TABLE `year` (
  `year` int(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `year`
--

INSERT INTO `year` (`year`) VALUES
(2021),
(2022),
(2023),
(2024),
(2025),
(2026),
(2027),
(2028),
(2029),
(2030),
(2031),
(2032),
(2033),
(2034),
(2035),
(2036),
(2037),
(2038),
(2039),
(2040),
(2041),
(2042),
(2043),
(2044),
(2045),
(2046),
(2047),
(2048),
(2049),
(2050),
(2051),
(2052),
(2053),
(2054),
(2055),
(2056),
(2057),
(2058),
(2059),
(2060),
(2061),
(2062),
(2063),
(2064),
(2065),
(2066),
(2067),
(2068),
(2069),
(2070),
(2071);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `enrolment`
--
ALTER TABLE `enrolment`
  ADD PRIMARY KEY (`Enrolmentc`),
  ADD KEY `Unitoffer` (`Unitoffer`),
  ADD KEY `UserID` (`UserID`,`TeamID`),
  ADD KEY `TeamID` (`TeamID`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`PermID`);

--
-- Indexes for table `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`ProjectID`),
  ADD KEY `Unitcode` (`Unitcode`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`RoleID`);

--
-- Indexes for table `rolespermissions`
--
ALTER TABLE `rolespermissions`
  ADD PRIMARY KEY (`Rolesper`),
  ADD KEY `RoleID` (`RoleID`,`PermID`),
  ADD KEY `PermID` (`PermID`);

--
-- Indexes for table `teachingperiod`
--
ALTER TABLE `teachingperiod`
  ADD PRIMARY KEY (`Teachingper`);

--
-- Indexes for table `teams`
--
ALTER TABLE `teams`
  ADD PRIMARY KEY (`TeamID`),
  ADD KEY `ProjectID` (`ProjectID`);

--
-- Indexes for table `unit`
--
ALTER TABLE `unit`
  ADD PRIMARY KEY (`Unitcode`);

--
-- Indexes for table `unitsoffering`
--
ALTER TABLE `unitsoffering`
  ADD PRIMARY KEY (`Unitoffer`),
  ADD KEY `Year` (`Year`,`Teachingper`,`Unitcode`),
  ADD KEY `Teachingper` (`Teachingper`),
  ADD KEY `Unitcode` (`Unitcode`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`UserID`);

--
-- Indexes for table `userroles`
--
ALTER TABLE `userroles`
  ADD PRIMARY KEY (`Userroles`),
  ADD KEY `UserID` (`UserID`),
  ADD KEY `RoleID` (`RoleID`);

--
-- Indexes for table `year`
--
ALTER TABLE `year`
  ADD PRIMARY KEY (`year`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `enrolment`
--
ALTER TABLE `enrolment`
  MODIFY `Enrolmentc` int(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `PermID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT for table `projects`
--
ALTER TABLE `projects`
  MODIFY `ProjectID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4453;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `RoleID` int(2) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `rolespermissions`
--
ALTER TABLE `rolespermissions`
  MODIFY `Rolesper` int(2) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=148;

--
-- AUTO_INCREMENT for table `teams`
--
ALTER TABLE `teams`
  MODIFY `TeamID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `unitsoffering`
--
ALTER TABLE `unitsoffering`
  MODIFY `Unitoffer` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `UserID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT for table `userroles`
--
ALTER TABLE `userroles`
  MODIFY `Userroles` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `enrolment`
--
ALTER TABLE `enrolment`
  ADD CONSTRAINT `enrolment_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`) ON DELETE CASCADE,
  ADD CONSTRAINT `enrolment_ibfk_2` FOREIGN KEY (`TeamID`) REFERENCES `teams` (`TeamID`) ON DELETE CASCADE,
  ADD CONSTRAINT `enrolment_ibfk_3` FOREIGN KEY (`Unitoffer`) REFERENCES `unitsoffering` (`Unitoffer`) ON DELETE CASCADE;

--
-- Constraints for table `projects`
--
ALTER TABLE `projects`
  ADD CONSTRAINT `projects_ibfk_1` FOREIGN KEY (`Unitcode`) REFERENCES `unit` (`Unitcode`) ON DELETE CASCADE;

--
-- Constraints for table `rolespermissions`
--
ALTER TABLE `rolespermissions`
  ADD CONSTRAINT `rolespermissions_ibfk_1` FOREIGN KEY (`RoleID`) REFERENCES `userroles` (`RoleID`) ON DELETE CASCADE,
  ADD CONSTRAINT `rolespermissions_ibfk_2` FOREIGN KEY (`PermID`) REFERENCES `permissions` (`PermID`) ON DELETE CASCADE;

--
-- Constraints for table `teams`
--
ALTER TABLE `teams`
  ADD CONSTRAINT `teams_ibfk_1` FOREIGN KEY (`ProjectID`) REFERENCES `projects` (`ProjectID`) ON DELETE CASCADE;

--
-- Constraints for table `unitsoffering`
--
ALTER TABLE `unitsoffering`
  ADD CONSTRAINT `unitsoffering_ibfk_1` FOREIGN KEY (`Teachingper`) REFERENCES `teachingperiod` (`Teachingper`) ON DELETE CASCADE,
  ADD CONSTRAINT `unitsoffering_ibfk_2` FOREIGN KEY (`Year`) REFERENCES `year` (`year`) ON DELETE CASCADE,
  ADD CONSTRAINT `unitsoffering_ibfk_3` FOREIGN KEY (`Unitcode`) REFERENCES `unit` (`Unitcode`) ON DELETE CASCADE;

--
-- Constraints for table `userroles`
--
ALTER TABLE `userroles`
  ADD CONSTRAINT `userroles_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`) ON DELETE CASCADE,
  ADD CONSTRAINT `userroles_ibfk_2` FOREIGN KEY (`RoleID`) REFERENCES `roles` (`RoleID`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
