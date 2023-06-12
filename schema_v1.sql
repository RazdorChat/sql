-- -- -- -- -- --
-- GUILD: ID, OWNER_ID, _NAME
-- USER: ID, _NAME
-- -- -- -- -- -- 


CREATE TABLE IF NOT EXISTS guilds (
  id bigint unsigned NOT NULL,
  owner_id bigint unsigned NOT NULL,
  _name text NOT NULL,

  PRIMARY KEY (id)
);
CREATE TABLE IF NOT EXISTS users (
  id bigint unsigned NOT NULL,
  _name text NOT NULL,
  authentication TEXT NOT NULL,
  salt TEXT NOT NULL,
  created_at bigint unsigned NOT NULL DEFAULT UNIX_TIMESTAMP(),
  -- TODO: discriminator
  PRIMARY KEY (id)
);


-- -- -- -- -- --
-- CHANNELS:       GUILD_ID, ID, _NAME
-- MESSAGES:       ID, DMCHANNELID, CHANNELID, CONTENT, SENT_TIMESTAMP 
-- DMCHANNELS:     ID
-- DMCHANNELUSERS: PARENT_ID, USER_ID
-- GUILDUSERS:     PARENT_ID, USER_ID
-- -- -- -- -- -- 

CREATE TABLE IF NOT EXISTS channels (
  guild_id bigint unsigned,
  old_guild_id bigint unsigned,
  id bigint unsigned NOT NULL,
  _name text NOT NULL,
  delete_after_timestamp bigint unsigned,

  PRIMARY KEY (id),
  FOREIGN KEY (guild_id) REFERENCES guilds(id),
  CHECK (ISNULL(guild_id) + ISNULL(old_guild_id) = 1), -- A channel is either attached or detached from a guild
  CONSTRAINT permadelete CHECK (ISNULL(old_guild_id) + ISNULL(delete_after_timestamp) IN (0, 2)) -- If a channel is detached, it must have a set deletion time
);


CREATE TABLE DMChannels (
  id bigint unsigned NOT NULL,

  PRIMARY KEY (id)
);

CREATE TABLE DMchannelUsers (
  parent_id bigint unsigned NOT NULL, -- This would be the DM Channel's ID
  user_id bigint unsigned NOT NULL,

  PRIMARY KEY (parent_id, user_id),
  FOREIGN KEY (parent_id) REFERENCES DMChannels(id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE guildUsers (
  parent_id bigint unsigned NOT NULL, -- This would be the guild's ID
  user_id bigint unsigned NOT NULL,

  PRIMARY KEY (parent_id, user_id),
  FOREIGN KEY (parent_id) REFERENCES guilds(id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


CREATE TABLE messages (
  id bigint unsigned NOT NULL,
  authorID bigint unsigned NOT NULL,
  DMChannelID bigint unsigned, -- It can either be a DM/DM Channel
  channelID bigint unsigned,   -- Or it can be a regular channel
  content text NOT NULL,
  sent_timestamp bigint unsigned NOT NULL DEFAULT UNIX_TIMESTAMP(),

  PRIMARY KEY (id),
  FOREIGN KEY (DMChannelID) REFERENCES DMChannels(id),   -- DM channel
  FOREIGN KEY (channelID) REFERENCES channels(id), -- Channel
  FOREIGN KEY (authorID) REFERENCES users(id) ON DELETE SET NULL, -- User
  CONSTRAINT checkmessagesbeforerun CHECK (ISNULL(DMChannelID) + ISNULL(channelID) = 1) -- Exactly 1 parent ID exists
);







-- -- -- -- -- -- Special clarification is needed for all of this, even if only for myself.
CREATE TABLE rolePermissions ( -- On creation of every role, this table should be populated with data, this data is for GUILD WIDE PERMS only.
                                -- On creation of the GUILD, this table should be ppopulated with the DEFAULT permissions for a DEFAULT role.
  guildID bigint unsigned,                   -- The guild .
  roleID bigint unsigned,                    -- The role thats getting permissions.


  -- Default permissions
  send_message boolean not null default 1,    -- A user can send messages by default.
  view_channels boolean not null default 1,   -- A user can see open channels by default.


  -- Specific permissions
  delete_message boolean not null default 0, -- Only Authorized users should be able to delete other user messages.
  change_nick boolean not null default 0,    -- Only Authorized users should be able to change other user nicknames.
  manage_guild boolean not null default 0,   -- Only Authorized users should be able to change guild settings.
  manage_roles boolean not null default 0,   -- Only Authorized users should be able to change role settings.
  kick_perms boolean not null default 0,     -- Only Authorized users should be able to kick.
  ban_perms boolean not null default 0,      -- Only Authorized users should be able to kick.



  PRIMARY KEY (guildID, roleID),
  FOREIGN KEY (guildID) REFERENCES guilds(id) ON DELETE CASCADE,  -- Guild deleted, set the guild to NULL
);
-- -- -- -- -- -- 





-- -- -- -- -- --
-- ROLES:                       GUILD_ID, ID, _NAME
-- PENDINGFRIENDREQUESTS:       ID, DMCHANNELID, CHANNELID, CONTENT, SENT_TIMESTAMP 
-- FRIENDS:                      ID
-- -- -- -- -- -- 

CREATE TABLE roles (
  guildID bigint unsigned,  
  id bigint unsigned NOT NULL, 
  _name text NOT NULL,


  PRIMARY KEY (guildID, id),
  FOREIGN KEY (parent_id) REFERENCES DMChannels(id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);



CREATE TABLE pendingFriendRequests (
  outgoingUserID bigint unsigned NOT NULL,
  incomingUserID bigint unsigned NOT NULL,
  start_timestamp bigint unsigned NOT NULL DEFAULT UNIX_TIMESTAMP(),

  PRIMARY KEY (outgoingUserID, incomingUserID),
  FOREIGN KEY (outgoingUserID) REFERENCES users(id),
  FOREIGN KEY (incomingUserID) REFERENCES users(id)
);



CREATE TABLE friends (
  userOneID bigint unsigned NOT NULL,
  userTwoID bigint unsigned NOT NULL,
  start_timestamp bigint unsigned NOT NULL DEFAULT UNIX_TIMESTAMP(),

  PRIMARY KEY (userOneID, userTwoID),
  FOREIGN KEY (userOneID) REFERENCES users(id),
  FOREIGN KEY (userTwoID) REFERENCES users(id)
);