CREATE TABLE IF NOT EXISTS `jbbvtc` (
  `citizenid` varchar(255) DEFAULT NULL,
  `total_course` int(11) NOT NULL DEFAULT 0,
  `total_earning` int(11) NOT NULL DEFAULT 0,
  `rate` number(1,1) NOT NULL DEFAULT 5.0,
  `history` text DEFAULT '[]',
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
