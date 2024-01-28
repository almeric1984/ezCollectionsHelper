DROP TABLE IF EXISTS `custom_ezCollectionsHelperCameras`;
CREATE TABLE IF NOT EXISTS `custom_ezCollectionsHelperCameras` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `option` int DEFAULT NULL,
  `race` int DEFAULT '30',
  `sex` int DEFAULT '3',
  `x` float DEFAULT NULL,
  `y` float DEFAULT NULL,
  `z` float DEFAULT NULL,
  `f` float DEFAULT NULL,
  `anim` int DEFAULT '0',
  `name` int DEFAULT '0',
  `class` int DEFAULT '2',
  `subclass` int DEFAULT '0',
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `custom_ezCollectionsHelperCameras` (`Id`, `option`, `race`, `sex`, `x`, `y`, `z`, `f`, `anim`, `name`, `class`, `subclass`) VALUES
	(1, 1, 30, 3, -1, -1, -1, -1, 0, 0, 2, 15);

DROP TABLE IF EXISTS `custom_ezCollectionsHelperConfig`;
CREATE TABLE IF NOT EXISTS `custom_ezCollectionsHelperConfig` (
  `RealmID` tinyint DEFAULT NULL,
  `Prefix` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'ezCollections',
  `Version` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '2.4.4',
  `CacheVersion` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '0',
  `ModulesConfPath` varchar(255) DEFAULT '../../etc/modules',
  `AllowedToHide` varchar(255) DEFAULT 'HEAD:SHOULDER:BACK:CHEST:TABARD:SHIRT:WRIST:HANDS:WAIST:LEGS:FEET:MAINHAND:OFFHAND:RANGED:MISC:ENCHANT'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `custom_ezCollectionsHelperConfig` (`RealmID`, `Prefix`, `Version`, `CacheVersion`, `ModulesConfPath`, `AllowedToHide`) VALUES
	(2, 'ezCollections', '2.4.4', 'noca2che7', 'etc/modules', 'HEAD:SHOULDER:BACK:CHEST:TABARD:SHIRT:WRIST:HANDS:WAIST:LEGS:FEET:MAINHAND:OFFHAND:RANGED:MISC:ENCHANT');
