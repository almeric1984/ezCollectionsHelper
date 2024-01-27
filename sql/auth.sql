CREATE TABLE IF NOT EXISTS `custom_ezCollectionsHelperConfig` (
  `RealmID` tinyint DEFAULT NULL,
  `Prefix` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'ezCollections',
  `Version` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '2.4.4',
  `CacheVersion` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '0',
  `ModulesConfPath` varchar(255) DEFAULT '../../etc/modules'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `custom_ezCollectionsHelperConfig` (`RealmID`, `Prefix`, `Version`, `CacheVersion`, `ModulesConfPath`) VALUES
	(1, 'ezCollections', '2.4.4', 'nocache', 'etc/modules');