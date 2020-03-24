-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.1.34-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win32
-- HeidiSQL Version:             9.4.0.5125
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for supply
DROP DATABASE IF EXISTS `supply`;
CREATE DATABASE IF NOT EXISTS `supply` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `supply`;

-- Dumping structure for table supply.contract
DROP TABLE IF EXISTS `contract`;
CREATE TABLE IF NOT EXISTS `contract` (
  `contract_number` int(11) NOT NULL AUTO_INCREMENT,
  `contract_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `supplier_id` int(11) NOT NULL,
  `contract_note` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`contract_number`),
  KEY `contract_ibfk_1` (`supplier_id`),
  CONSTRAINT `contract_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `supplier` (`supplier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;

-- Dumping data for table supply.contract: ~7 rows (approximately)
DELETE FROM `contract`;
/*!40000 ALTER TABLE `contract` DISABLE KEYS */;
INSERT INTO `contract` (`contract_number`, `contract_date`, `supplier_id`, `contract_note`) VALUES
	(1, '2018-09-01 00:00:00', 1, 'Order 34 on 30.08.2018'),
	(2, '2019-03-21 15:18:46', 1, 'empty'),
	(3, '2018-09-23 00:00:00', 3, 'Order 56 on 28.08.2018'),
	(4, '2018-09-24 00:00:00', 2, 'Order 74 on 11.09.2018'),
	(5, '2018-10-02 00:00:00', 2, 'Invoice 09-12 on 21.09.2018'),
	(7, '2018-12-27 13:30:04', 1, ''),
	(13, '2019-01-10 13:20:48', 4, 'Order #9876');
/*!40000 ALTER TABLE `contract` ENABLE KEYS */;

-- Dumping structure for view supply.contract_supplier
DROP VIEW IF EXISTS `contract_supplier`;
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `contract_supplier` (
	`contract_number` INT(11) NOT NULL,
	`contract_date` TIMESTAMP NOT NULL,
	`supplier_id` INT(11) NOT NULL,
	`Supplier` VARCHAR(62) NULL COLLATE 'latin1_swedish_ci'
) ENGINE=MyISAM;

-- Dumping structure for procedure supply.sp_contract
DROP PROCEDURE IF EXISTS `sp_contract`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_contract`()
BEGIN
	SELECT *
	FROM (contract LEFT JOIN supplier_org ON
		contract.supplier_id = supplier_org.supplier_id)
		LEFT JOIN supplier_person ON
		contract.supplier_id = supplier_person.supplier_id;
END//
DELIMITER ;

-- Dumping structure for procedure supply.sp_contract_ops
DROP PROCEDURE IF EXISTS `sp_contract_ops`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_contract_ops`(IN op CHAR(1), IN c_num INT, IN c_date TIMESTAMP,
												IN s_id INT, IN c_note VARCHAR(100))
BEGIN
	IF op = 'i' THEN
		INSERT INTO contract(contract_date, supplier_id, contract_note)
			VALUES(CURRENT_TIMESTAMP(), s_id, c_note);
	ELSEIF op = 'u' THEN
		UPDATE contract SET contract_date = c_date,
									supplier_id = s_id,
									contract_note = c_note
		WHERE contract_number = c_num;
	ELSE
		DELETE FROM contract WHERE contract_number = c_num;
	END IF;
END//
DELIMITER ;

-- Dumping structure for procedure supply.sp_contract_total
DROP PROCEDURE IF EXISTS `sp_contract_total`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_contract_total`(IN date_from timestamp,
												IN date_to timestamp)
BEGIN
	SELECT contract.contract_number, contract.contract_date,
		SUM(supplied.supplied_amount), SUM(supplied.supplied_amount * supplied.supplied_cost)
	FROM contract LEFT JOIN supplied ON contract.contract_number = supplied.contract_number
	WHERE contract.contract_date BETWEEN date_from AND date_to
	GROUP BY contract.contract_number, contract.contract_date;
END//
DELIMITER ;

-- Dumping structure for table supply.supplied
DROP TABLE IF EXISTS `supplied`;
CREATE TABLE IF NOT EXISTS `supplied` (
  `contract_number` int(11) NOT NULL,
  `supplied_product` varchar(20) NOT NULL,
  `supplied_amount` decimal(4,0) NOT NULL,
  `supplied_cost` decimal(8,2) NOT NULL,
  PRIMARY KEY (`contract_number`,`supplied_product`),
  CONSTRAINT `supplied_ibfk_1` FOREIGN KEY (`contract_number`) REFERENCES `contract` (`contract_number`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table supply.supplied: ~19 rows (approximately)
DELETE FROM `supplied`;
/*!40000 ALTER TABLE `supplied` DISABLE KEYS */;
INSERT INTO `supplied` (`contract_number`, `supplied_product`, `supplied_amount`, `supplied_cost`) VALUES
	(1, 'Audio Player', 25, 700.00),
	(1, 'New Product', 15, 100.00),
	(1, 'TV', 10, 1300.00),
	(1, 'Video Player', 12, 750.00),
	(2, 'Audio Player', 5, 450.00),
	(2, 'Stereo System', 11, 500.00),
	(2, 'Video Player', 8, 450.00),
	(3, 'Audio Player', 11, 550.00),
	(3, 'Monitor', 85, 550.00),
	(3, 'TV', 52, 900.00),
	(4, 'Audio Player', 22, 320.00),
	(4, 'Printer', 41, 332.50),
	(4, 'TV', 56, 990.00),
	(5, 'Audio Player', 33, 580.00),
	(5, 'TV', 14, 860.00),
	(5, 'Video Player', 17, 850.00),
	(7, 'Phone', 5, 5999.00),
	(7, 'TV', 10, 2999.00);
/*!40000 ALTER TABLE `supplied` ENABLE KEYS */;

-- Dumping structure for table supply.supplier
DROP TABLE IF EXISTS `supplier`;
CREATE TABLE IF NOT EXISTS `supplier` (
  `supplier_id` int(11) NOT NULL,
  `supplier_address` varchar(100) NOT NULL,
  `supplier_phone` varchar(20) NOT NULL,
  PRIMARY KEY (`supplier_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table supply.supplier: ~5 rows (approximately)
DELETE FROM `supplier`;
/*!40000 ALTER TABLE `supplier` DISABLE KEYS */;
INSERT INTO `supplier` (`supplier_id`, `supplier_address`, `supplier_phone`) VALUES
	(1, 'Kharkiv, Nauky av., 55, apt. 108', 'phone: 32-18-44'),
	(2, 'Kyiv, Peremohy av., 154, apt. 3', ''),
	(3, 'Kharkiv, Pushkinska str., 77', 'phone: 33-33-44, fax'),
	(4, 'Odesa, Derebasivska str., 75', ''),
	(5, 'Poltava, Soborna str., 15, apt. 43', '');
/*!40000 ALTER TABLE `supplier` ENABLE KEYS */;

-- Dumping structure for view supply.supplier_info
DROP VIEW IF EXISTS `supplier_info`;
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `supplier_info` (
	`supplier_id` INT(11) NOT NULL,
	`supplier_address` VARCHAR(100) NOT NULL COLLATE 'latin1_swedish_ci',
	`Info` VARCHAR(62) NULL COLLATE 'latin1_swedish_ci'
) ENGINE=MyISAM;

-- Dumping structure for table supply.supplier_org
DROP TABLE IF EXISTS `supplier_org`;
CREATE TABLE IF NOT EXISTS `supplier_org` (
  `supplier_id` int(11) NOT NULL,
  `supplier_org_name` varchar(20) NOT NULL,
  PRIMARY KEY (`supplier_id`),
  CONSTRAINT `supplier_org_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `supplier` (`supplier_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table supply.supplier_org: ~2 rows (approximately)
DELETE FROM `supplier_org`;
/*!40000 ALTER TABLE `supplier_org` DISABLE KEYS */;
INSERT INTO `supplier_org` (`supplier_id`, `supplier_org_name`) VALUES
	(2, 'Interfruit Ltd.'),
	(4, 'Transservice LLC');
/*!40000 ALTER TABLE `supplier_org` ENABLE KEYS */;

-- Dumping structure for table supply.supplier_person
DROP TABLE IF EXISTS `supplier_person`;
CREATE TABLE IF NOT EXISTS `supplier_person` (
  `supplier_id` int(11) NOT NULL,
  `supplier_last_name` varchar(20) NOT NULL,
  `supplier_first_name` varchar(20) NOT NULL,
  `supplier_middle_name` varchar(20) NOT NULL,
  PRIMARY KEY (`supplier_id`),
  CONSTRAINT `supplier_person_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `supplier` (`supplier_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table supply.supplier_person: ~3 rows (approximately)
DELETE FROM `supplier_person`;
/*!40000 ALTER TABLE `supplier_person` DISABLE KEYS */;
INSERT INTO `supplier_person` (`supplier_id`, `supplier_last_name`, `supplier_first_name`, `supplier_middle_name`) VALUES
	(1, 'Petrov', 'Pavlo', 'Petrovych'),
	(3, 'Ivanov', 'Illia', 'Illych'),
	(5, 'Sydorov', 'Serhii', 'Stepanovych');
/*!40000 ALTER TABLE `supplier_person` ENABLE KEYS */;

-- Dumping structure for view supply.v_max
DROP VIEW IF EXISTS `v_max`;
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `v_max` (
	`supplied_product` VARCHAR(20) NOT NULL COLLATE 'latin1_swedish_ci',
	`num` BIGINT(21) NOT NULL
) ENGINE=MyISAM;

-- Dumping structure for view supply.v_total
DROP VIEW IF EXISTS `v_total`;
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `v_total` (
	`supplied_product` VARCHAR(20) NOT NULL COLLATE 'latin1_swedish_ci',
	`total` DECIMAL(12,2) NOT NULL
) ENGINE=MyISAM;

-- Dumping structure for view supply.v_upd_supplied
DROP VIEW IF EXISTS `v_upd_supplied`;
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `v_upd_supplied` (
	`contract_number` INT(11) NOT NULL,
	`supplied_product` VARCHAR(20) NOT NULL COLLATE 'latin1_swedish_ci',
	`supplied_amount` DECIMAL(4,0) NOT NULL,
	`supplied_cost` DECIMAL(8,2) NOT NULL
) ENGINE=MyISAM;

-- Dumping structure for trigger supply.check_supplier_org
DROP TRIGGER IF EXISTS `check_supplier_org`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `check_supplier_org` BEFORE INSERT ON `supplier_person` FOR EACH ROW BEGIN
	IF NEW.supplier_id IN (SELECT supplier_id FROM supplier_org) THEN
		SET @message = CONCAT('The person with id ', NEW.supplier_id, 
			' is already stored as the organization!');
		SIGNAL SQLSTATE '45001'
		SET MESSAGE_TEXT = @message;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger supply.not_null_date
DROP TRIGGER IF EXISTS `not_null_date`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `not_null_date` BEFORE INSERT ON `contract` FOR EACH ROW BEGIN
	IF NEW.contract_date IS NULL THEN
		SET NEW.contract_date = CURRENT_TIMESTAMP();
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for view supply.contract_supplier
DROP VIEW IF EXISTS `contract_supplier`;
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `contract_supplier`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `contract_supplier` AS SELECT contract.contract_number, contract.contract_date, supplier.supplier_id,
	IFNULL(supplier_org.supplier_org_name, CONCAT(supplier_person.supplier_last_name, ' ',
	supplier_person.supplier_first_name, ' ', supplier_person.supplier_middle_name)) AS `Supplier`
FROM contract INNER JOIN supplier ON contract.supplier_id = supplier.supplier_id
	LEFT OUTER JOIN supplier_org ON supplier.supplier_id = supplier_org.supplier_id
	LEFT OUTER JOIN supplier_person ON supplier.supplier_id = supplier_person.supplier_id ;

-- Dumping structure for view supply.supplier_info
DROP VIEW IF EXISTS `supplier_info`;
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `supplier_info`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `supplier_info` AS SELECT supplier.supplier_id, supplier.supplier_address, 
	IFNULL(supplier_org.supplier_org_name, CONCAT(supplier_person.supplier_last_name, ' ',
	supplier_person.supplier_first_name, ' ', supplier_person.supplier_middle_name)) AS `Info`
FROM supplier LEFT OUTER JOIN supplier_org ON supplier.supplier_id = supplier_org.supplier_id
	LEFT OUTER JOIN supplier_person ON supplier.supplier_id = supplier_person.supplier_id ;

-- Dumping structure for view supply.v_max
DROP VIEW IF EXISTS `v_max`;
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `v_max`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `v_max` AS SELECT supplied_product, COUNT(*) AS num
FROM supplied
GROUP BY supplied_product ;

-- Dumping structure for view supply.v_total
DROP VIEW IF EXISTS `v_total`;
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `v_total`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `v_total` AS SELECT supplied_product, supplied_amount * supplied_cost AS total
FROM supplied ;

-- Dumping structure for view supply.v_upd_supplied
DROP VIEW IF EXISTS `v_upd_supplied`;
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `v_upd_supplied`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` VIEW `v_upd_supplied` AS SELECT * FROM supplied
WHERE supplied.supplied_amount > 10
WITH CHECK OPTION ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
