USE votenow;

DROP TABLE IF EXISTS answer;
DROP TABLE IF EXISTS question;
DROP TABLE IF EXISTS device;

CREATE TABLE device (
	id 				BIGINT NOT NULL AUTO_INCREMENT,
	device_type		CHAR(20) NOT NULL,
	device_id		CHAR(250) NOT NULL,
	PRIMARY KEY (id)
) ENGINE=InnoDB;
	

CREATE TABLE question (
	id 				BIGINT NOT NULL AUTO_INCREMENT,
	email 			CHAR(60) NOT NULL,
	title			TEXT(500) NOT NULL, 
	endTime			DATETIME NOT NULL,
	code			CHAR(20) UNIQUE NOT NULL,
	anonym			BOOLEAN NOT NULL,
	multichoice		BOOLEAN NOT NULL,
	closed			BOOLEAN NOT NULL,
	device_id		BIGINT NOT NULL,
	
	PRIMARY KEY (id),
	FOREIGN KEY (device_id) REFERENCES device(id) ON DELETE CASCADE
) ENGINE=InnoDB;

ALTER TABLE question ADD INDEX code_idx (code);
ALTER TABLE question ADD INDEX endTime_idx (endTime);

CREATE TABLE answer (
	id				BIGINT NOT NULL AUTO_INCREMENT,
	question_id		BIGINT NOT NULL,
	answers			TEXT,
	name			TEXT(50),
	message			TEXT(500),
	device_id		BIGINT NOT NULL,
	
	PRIMARY KEY (id),
	FOREIGN KEY (question_id) REFERENCES question(id) ON DELETE CASCADE,
	FOREIGN KEY (device_id) REFERENCES device(id) ON DELETE CASCADE
	
) ENGINE=InnoDB;

ALTER TABLE answer ADD INDEX question_id_idx (question_id);



CREATE TABLE chosable (
	id				BIGINT NOT NULL AUTO_INCREMENT,
	question_id		BIGINT NOT NULL,
	chosable_number	INT,
	text			TEXT(510),
	PRIMARY KEY (id),
	FOREIGN KEY (question_id) REFERENCES question(id) ON DELETE CASCADE
) ENGINE=InnoDB;

ALTER TABLE chosable ADD INDEX chosable_question_id(question_id);