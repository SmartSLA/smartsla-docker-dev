CREATE DATABASE IF NOT EXISTS lininfosec;

USE lininfosec;

DROP TABLE IF EXISTS
	`cves_notified`,
	`cpe_monitored`,
	`cpe_references`,
	`monitored_configurations`,
	`cpe_dict`
;

CREATE TABLE `cpe_dict` (
	`uri`        VARCHAR(255) NOT NULL, 
	`part`       CHAR NOT NULL,
	`vendor`     VARCHAR(128) NOT NULL,
	`product`    VARCHAR(128) NOT NULL,
	`version`    VARCHAR(128),
	`updatecl`   VARCHAR(128),
	`edition`    VARCHAR(128),
	`swedition`  VARCHAR(128),
	`targetSW`   VARCHAR(128),
	`targethw`   VARCHAR(128),
	`other`      VARCHAR(128),
	`language`   VARCHAR(128),
	`title`      TEXT ,
	PRIMARY KEY (`uri`),
	FULLTEXT INDEX (`title`)
)
DEFAULT CHARACTER SET utf8mb4
ENGINE InnoDB
COMMENT 'CPE dictionnary'
;

CREATE TABLE `cpe_references` (
	`cpe_uri`     VARCHAR(255) NOT NULL, 
	`url`         TEXT NOT NULL,
	`description` TEXT,
	PRIMARY KEY (`cpe_uri`, `url`(255),`description`(255)),
	 -- 255 Limit to fit within the maximum key length:
	 --     some entries in the CPE dictionnary have urls and descriptions of up to 300 chars
	 --     Restricting the key to the first 255 characters is very unlikely to create false duplicates
	 --       and doesn't happen in the dictionnary as it is at the time of creation of this schema
	CONSTRAINT references_uri_fkey
		FOREIGN KEY (`cpe_uri`) REFERENCES cpe_dict (`uri`)
		ON DELETE CASCADE
		ON UPDATE RESTRICT
)
ENGINE InnoDB
DEFAULT CHARACTER SET utf8mb4
COMMENT 'References for each cpe in the CPE dictionnary'
;


CREATE TABLE monitored_configurations (
	uid      VARCHAR(255) NOT NULL UNIQUE COMMENT 'unique name of the softawre configuration used',
	PRIMARY KEY (`uid`)
)
ENGINE InnoDB
DEFAULT CHARACTER SET utf8mb4
COMMENT 'Software configuration to be monitored for cve publications'
;

CREATE TABLE cpe_monitored (
	`cpe_uri`        VARCHAR(255) NOT NULL, 
	`configuration_uid`      VARCHAR(255) NOT NULL,
	CONSTRAINT monitored_uri_fkey
		FOREIGN KEY (`cpe_uri`) REFERENCES cpe_dict (`uri`)
		ON DELETE CASCADE
		ON UPDATE RESTRICT,
	CONSTRAINT monitored_configuration_fkey
		FOREIGN KEY (`configuration_uid`) REFERENCES monitored_configurations (`uid`)
		ON DELETE CASCADE
		ON UPDATE RESTRICT
)
ENGINE InnoDB
DEFAULT CHARACTER SET utf8mb4
COMMENT 'CPEs to be monitored for new CVE publications'
;

CREATE TABLE `cves_notified` (
	`id`                   INT          NOT NULL AUTO_INCREMENT COMMENT 'ID of the notification',
	`ts`                   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Time of the notification',
	`cve_id`               VARCHAR(128) NOT NULL COMMENT 'Common Vulnerability and Exposure (CVE) ID',
	`configuration_uid`            VARCHAR(255) NOT NULL COMMENT 'Software configuration that was notified for the given ID',
	PRIMARY KEY (`id`),
	CONSTRAINT cve_notified_fkey
		FOREIGN KEY (`configuration_uid`) REFERENCES monitored_configurations (`uid`)
		ON DELETE CASCADE
		ON UPDATE RESTRICT
)
ENGINE InnoDB
DEFAULT CHARACTER SET utf8mb4
COMMENT 'Notification history'
;

