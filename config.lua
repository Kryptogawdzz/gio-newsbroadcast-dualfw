Config = {}

--[[
    ANNOUNCEMENT TYPES
    ──────────────────
    Each key (e.g. 'police', 'ambulance') maps to a /announce type.
    Usage in-game: /announce pd Your message here

    Fields per type:
      job      - The job name required to use this type.
                 Set to false to allow anyone (e.g. admin events).
      grade    - Minimum job grade level required.
                 0 = any grade, 1 = second grade up, 3 = senior/supervisor, etc.
                 Check your job grades in your database or qbx jobs config.
      header   - Short bold text shown in the red label (e.g. 'PD NEWS').
      subheader- Longer description shown at the start of the scrolling message.
      color    - Hex color for the label and category tag. Default is red #cc0000.
                 You can change this per type (e.g. '#0055cc' for blue, '#228B22' for green).

    To add a new type:
      ['fire'] = {
          job = 'fire',
          grade = 2,
          header = 'FIRE DEPT',
          subheader = 'LOS SANTOS FIRE DEPARTMENT',
          color = '#cc4400'
      },
--]]

Config.AnnouncementTypes = {
    ['ambulance'] = {
        job       = 'ambulance',
        grade     = 2,          -- Change: 0 = any EMS, 2 = supervisor+, 4 = chief only
        header    = 'EMS NEWS',
        subheader = 'EMERGENCY MEDICAL SERVICES',
        color     = '#cc0000',
        cooldown  = 30          -- seconds between broadcasts per player (0 = disabled)
    },
    ['police'] = {
        job       = 'police',   -- Change to match your server's job name
        grade     = 3,          -- Change: 0 = any officer, 3 = sergeant+, 5 = command only
        header    = 'PD NEWS',
        subheader = 'LOS SANTOS POLICE DEPARTMENT',
        color     = '#cc0000',
        cooldown  = 30          -- seconds between broadcasts per player (0 = disabled)
    },
    ['gov'] = {
        job       = 'gov',
        grade     = 1,          -- Change: 0 = any gov employee, 1 = senior staff+
        header    = 'GOV NEWS',
        subheader = 'CITY GOVERNMENT',
        color     = '#cc0000',
        cooldown  = 60          -- seconds between broadcasts per player (0 = disabled)
    },
    ['event'] = {
        job       = false,      -- false = no job required
        grade     = 0,          -- ignored when job = false
        header    = 'EVENT ALERT',
        subheader = 'SPECIAL BROADCAST',
        color     = '#cc0000',
        cooldown  = 120,        -- seconds between broadcasts per player (0 = disabled)
        -- ace    = 'gio-news.event'  -- Uncomment to restrict to ACE-permitted players only.
        --                              Add 'add_ace group.admin gio-news.event allow' in server.cfg.
    }
}

--[[
    GENERAL SETTINGS
    ────────────────
    TickerPosition - Where the ticker bar appears: 'bottom' or 'top'
    ScrollSpeed    - Seconds for the text to complete one full scroll. Higher = slower.
    ShowFor        - How long (ms) the ticker stays visible after appearing.
                     0 = stays on screen until the next announcement or /clearticker.
                     60000 = 60 seconds.
    Sound          - true/false. Plays a notification sound when announcement fires.
    IntroDuration  - How long (ms) the Breaking News intro animation plays before
                     the ticker slides in. Default 4600 matches the animation length.
                     Do not set lower than 4200 or the animation will be cut off.
--]]

Config.TickerPosition = 'bottom'
Config.ScrollSpeed    = 35
Config.ShowFor        = 60000
Config.Sound          = true
Config.IntroDuration  = 4600
