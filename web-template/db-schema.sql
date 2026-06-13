-- ===========================================================
-- Web template schema
-- ===========================================================
-- Run this ONCE against the database you set in web.config's
-- DefaultDb connection string.  Creates the Users table and
-- seeds a default admin account (admin / admin123).
--
-- IMPORTANT: change the seed admin password as soon as you can!
-- Login as admin, then INSERT/UPDATE the Users row via
-- whatever tooling you build, OR delete it after creating
-- your real accounts.
-- ===========================================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        Id              INT IDENTITY(1,1) PRIMARY KEY,
        Username        NVARCHAR(64)  NOT NULL UNIQUE,
        Salt            NVARCHAR(32)  NOT NULL,
        PasswordHash    NVARCHAR(64)  NOT NULL,
        Enabled         BIT           NOT NULL CONSTRAINT DF_Users_Ena DEFAULT (1),
        CreatedAt       DATETIME2(0)  NOT NULL CONSTRAINT DF_Users_Cre DEFAULT (SYSUTCDATETIME()),
        LastLoginAt     DATETIME2(0)  NULL
    );

    -- Seed account: admin / admin123
    --   salt = 'AAAAAAAAAAAAAAAA'  (16 chars; CHANGE IN PROD)
    --   hash = base64( SHA-256( UTF-8( salt + password ) ) )
    --        = kemsxWtDZyomv8jS+s2Iqak7SGlb8ilWBiyVBRCrSjw=
    INSERT INTO Users (Username, Salt, PasswordHash)
    VALUES ('admin', 'AAAAAAAAAAAAAAAA',
            'kemsxWtDZyomv8jS+s2Iqak7SGlb8ilWBiyVBRCrSjw=');

    PRINT 'Users table created. Default account: admin / admin123';
    PRINT 'CHANGE THE ADMIN PASSWORD IMMEDIATELY!';
END
ELSE
BEGIN
    PRINT 'Users table already exists; skipping.';
END;
GO

-- Useful queries while you operate:
--   SELECT Id, Username, Role, Enabled, LastLoginAt FROM Users;
--   UPDATE Users SET Enabled = 0 WHERE Username = 'someone';
--   DELETE FROM Users WHERE Username = 'someone';
