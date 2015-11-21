-- Database schema for tracking artwork of interest and the people who made it.

CREATE TABLE people (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL
);

-- TODO See if PostGres supports an inline comment syntax a la MySQL.
-- I don't love much about MySQL but that was convenient.
COMMENT ON TABLE people IS
'Humans whose creative output might be interesting.';

COMMENT ON COLUMN people.name IS
'Full name, exactly as entered.';

CREATE TABLE media (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL
);

COMMENT ON TABLE media IS
'List of creative media we''re interested in.';

COMMENT ON COLUMN media.name IS
'This medium''s name - e.g., ''Book''.';

-- Initial values for media types. Users can always add more, but this is the
-- default set.
INSERT INTO media (name)
VALUES ('Book'),
       ('Poem'),
       ('Film'),
       ('Show'),
       ('Play'),
       ('Album'),
       ('Song'),
       ('Game'),
       ('Video Game');

-- Creative works we are interested in.
CREATE TABLE pieces (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    subtitle VARCHAR(200),
    medium_id INTEGER NOT NULL REFERENCES media (id),
    description TEXT
);

-- TODO Look for PostGres flycheck syntax checker.
COMMENT ON TABLE pieces IS
'Creative works we''re interested in.';

-- TODO Suggest that || should be allowed in defining comments.
-- As it stands, I would have to post-process my comments if I wanted a given
-- paragraph without newlines. That's probably not a big deal, but it seems like
-- an arbitrary limitation.
COMMENT ON COLUMN pieces.title IS
'This piece''s title.

Should arguably be nullable, so users can enter pieces whose titles they do
not know, as long as a description is provided.';

COMMENT ON COLUMN pieces.subtitle IS
'This piece''s (optional) subtitle.';

COMMENT ON COLUMN pieces.description IS
'Notes on the piece, perhaps including why it is of interest to the user.';


CREATE TABLE makers (
    id SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL REFERENCES people (id),
    piece_id INTEGER NOT NULL REFERENCES pieces (id),

    -- TODO Break this out into its own lookup table?
    -- If we do, should titles be linked to particular media types?
    title VARCHAR(100) NOT NULL
);

COMMENT ON TABLE makers IS
'Links people to creative works they contributed to.';

COMMENT ON COLUMN makers.title IS
'Job title for the maker''s work on the piece.';

-- Record of the times a piece has been experienced.
-- No row in this table implies that it has not yet been experienced.
--
-- TODO Is there a better name? 'experiences' seems pretty vague.
-- 'viewings' is the only other candidate I've thought of, but it suggests
-- principally visual experiences, while this table could contain events like
-- listening to an album.
CREATE TABLE experiences (
    id SERIAL PRIMARY KEY,
    piece_id INTEGER NOT NULL REFERENCES pieces (id),

    -- FIXME Every one of these fields is nullable.
    -- I don't love that, but for usability's sake in the UI, it seems
    -- necessary. Often enough, you don't remember exactly when you did
    -- something, and you don't want to bother figuring out - just let me check
    -- the "saw it" button in the UI and move on.

    -- TODO Is there a cleaner way to make the time fields optional?
    -- Declaring them separately from the date feels odd, but with timestamp
    -- and friends, it seems like you couldn't know if the time portion was
    -- actually exact, entered sloppily, or an attempt to indicate that time is
    -- unknown.
    experienced_during daterange,

    start_time TIME WITH TIME ZONE,
    end_time TIME WITH TIME ZONE,

    date_error_margin INTERVAL
);

COMMENT ON TABLE experiences IS
'A record of how often pieces have been experienced.

If this table has no rows for a piece, it has not been experienced.';

COMMENT ON COLUMN experiences.experienced_during IS
'Optional date range over which the piece was experienced.

Some kinds of art can take days, weeks, or even months to get through, so the
start date and the end date may vary widely.

Books are the most likely offenders.';

COMMENT ON COLUMN experiences.start_time IS
'Optional record of the time the experience began.

If present, augments the experienced_during field.';

COMMENT ON COLUMN experiences.end_time IS
'Optional record of the time the experience ended.

If present, augments the experienced_during field.';

COMMENT ON COLUMN experiences.date_error_margin IS
'An optional record of the accuracy of the start/end fields.

People do not always know exactly when something happened, so we let them say
roughly how accurate they think the dates and times are.

Should not be allowed unless start and end date exist?';

-- TODO Add tables for managing users and API keys.

-- TODO Add tables for tracking recommendations and appropriateness rankings.
