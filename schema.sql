-- Database schema for tracking artwork of interest and the people who made it.

CREATE TABLE people (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL
);

-- TODO See if PostGres supports an inline comment syntax a la MySQL.
-- I don't love much about MySQL but that was convenient.
COMMENT ON TABLE people IS 'Humans whose creative output might be interesting.';

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
VALUES ('Book',
        'Poem',
        'Film',
        'Show',
        'Play',
        'Album',
        'Song',
        'Game',
        'Video Game');

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

COMMENT ON COLUMN pieces.title IS
'This piece''s title.

Should arguably be nullable, so users can enter pieces whose titles they do ' ||
'not know, as long as a description is provided.';

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
-- TODO Is there a better name? 'viewings' suggests principally visual
-- experiences, while this table could contain events like listening to an album.
-- 'experiences' seems pretty vague.
CREATE TABLE experiences (
    id SERIAL PRIMARY KEY,
    piece_id INTEGER NOT NULL REFERENCES pieces (id),

    -- TODO Should the start/end fields be a single tstzrange field?
    -- Would that make both ends required, and if so is that too restrictive?

    -- TODO Is there a cleaner way to make the time fields optional?
    -- Declaring them separately from the date feels odd, but with timestamp
    -- and friends, it seems like you couldn't know if the time portion was
    -- actually exact, entered sloppily, or an attempt to indicate that time is
    -- unknown.
    start_date DATE,
    start_time TIME,

    end_date DATE,
    end_time TIME,

    date_error_margin INTERVAL
);

COMMENT ON TABLE experiences IS
'A record of how often pieces have been experienced.

If this table has no rows for a piece, it has not been experienced.';

COMMENT ON COLUMN experiences.start_date IS
'The optional date the experience of the piece began.

Some kinds of art can take days, weeks, or even months to get through, so the ' ||
'start date and the end date may vary widely.

Books are the most likely offenders.';

COMMENT ON COLUMN experiences.date_error_margin IS
'An optional record of the accuracy of the start/end fields.

People do not always know exactly when something happened, so we let them say ' ||
'roughly how accurate they think the dates and times are.';
