START TRANSACTION;

ALTER TABLE users MODIFY discrim varchar(4);
ALTER TABLE users	MODIFY discrim smallint unsigned NOT NULL,
	ADD discrim_prefix tinyint unsigned NOT NULL DEFAULT 0,
	-- Enforce unique discrims
	-- Note that this key requires queries to always include discrim_prefix to be indexed
	ADD UNIQUE KEY (_name, discrim_prefix, discrim),
	-- Enforce 4/6 digit discriminator sizes
	ADD CONSTRAINT discrim_size CHECK (discrim < 10000 
		AND (discrim_prefix >= 10 OR discrim_prefix = 0)
		AND discrim_prefix < 100);

COMMIT;
