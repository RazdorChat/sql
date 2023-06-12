CREATE TABLE IF NOT EXISTS channels (
  guild_id bigint unsigned,
  old_guild_id bigint unsigned,
  id bigint unsigned NOT NULL,
  _name text NOT NULL,
  delete_after_timestamp bigint unsigned,

  PRIMARY KEY (id),
  FOREIGN KEY (guild_id) REFERENCES guilds(id),
  CONSTRAINT permadelete CHECK ((guild_id IS NOT NULL) OR (old_guild_id IS NOT NULL AND delete_after_timestamp IS NOT NULL))
);