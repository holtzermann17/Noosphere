-- invalidation document frequency table

create table inv_dfs (
	id int NOT NULL,
	word_or_phrase tinyint default 0,
	count tinyint default 0,
	key(id)
);

-- invalidation index

create table inv_idx (

	id int NOT NULL,
	word_or_phrase tinyint default 0,
	objectid int NOT NULL,
	key(id),
	key(objectid)
);

-- invalidation words dictionary

create table inv_words (
	id mediumint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	word char(32) NOT NULL UNIQUE INDEX
);

-- invalidation phrases dictionary (word tuples)

create table inv_phrases (

	phrase char(255) NOT NULL,
	id mediumint unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT
);

