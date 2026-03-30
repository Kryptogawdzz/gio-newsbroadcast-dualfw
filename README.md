# 📺 gio-newsbroadcast-dualfw

A FiveM resource that enables authorized jobs (Police, EMS, Government, and open Event broadcasts) to deliver in-game news broadcasts to all players on the server. Built with dual-framework support for both **ESX** and **Qbox**.

---

## ✨ Features

- 📡 Server-wide news broadcasts visible to all online players
- 🔐 Job/role-based permission system — only authorized roles can broadcast
- 🎨 Per-type customizable header, subheader, and color
- 🧩 Dual-framework compatible — works out of the box with **ESX** and **Qbox**
- 🗂️ Clean, easy-to-configure `config.lua`

---

## 📋 Requirements

- [ox_lib](https://github.com/overextended/ox_lib) *(required)*
- ESX **or** Qbox framework

---

## 📁 File Structure

```
gio-newsbroadcast-dualfw/
├── html/
│   ├── index.html
│   ├── style.css
│   └── script.js
├── client.lua
├── server.lua
├── config.lua
└── fxmanifest.lua
```

---

## ⚙️ Configuration

All configuration is handled through `config.lua` in the root directory.

### Announcement Types

Each key maps to a `/announce` type used in-game. Define which job and minimum grade is required per type, along with the ticker's visual appearance.

```lua
Config.AnnouncementTypes = {
    ['ambulance'] = {
        job       = 'ambulance',  -- Job name required. Set to false to allow anyone.
        grade     = 2,            -- Minimum grade level. 0 = any grade.
        header    = 'EMS NEWS',
        subheader = 'EMERGENCY MEDICAL SERVICES',
        color     = '#cc0000'
    },
    ['police'] = {
        job       = 'police',
        grade     = 3,            -- e.g. sergeant and above
        header    = 'PD NEWS',
        subheader = 'LOS SANTOS POLICE DEPARTMENT',
        color     = '#cc0000'
    },
    ['gov'] = {
        job       = 'gov',
        grade     = 1,
        header    = 'GOV NEWS',
        subheader = 'CITY GOVERNMENT',
        color     = '#cc0000'
    },
    ['event'] = {
        job       = false,        -- false = no job required, any player can use
        grade     = 0,
        header    = 'EVENT ALERT',
        subheader = 'SPECIAL BROADCAST',
        color     = '#cc0000'
    }
}
```

> ℹ️ Set `grade` to the **minimum grade** required. `0` means any grade within that job is permitted. Set `job = false` to allow any player to use that type regardless of job.

---

## 💬 Command Usage

### `/announce [type] [message]`

Sends a server-wide news broadcast to all online players using the specified announcement type.

| Parameter | Type   | Description                                              |
|-----------|--------|----------------------------------------------------------|
| `type`    | string | Announcement type: `ambulance`, `police`, `gov`, `event` |
| `message` | string | The news message to broadcast (5–300 characters)         |

**Example:**
```
/announce police There is an active pursuit on the highway — all civilians please avoid the area.
```

**Permissions:**
Each type has its own job and grade requirement defined in `config.lua`. The `event` type has no job requirement and can be used by any player. Unauthorized players will receive an error notification.

---

## 🔀 Dual Framework Support

This resource is designed to work seamlessly with both **ESX** and **Qbox** without requiring any manual changes. Framework detection is handled **automatically at runtime**.

- If **ESX** is detected, the resource uses ESX player data for job/grade checks.
- If **Qbox** is detected, the resource uses Qbox player data for job/grade checks.

No need to comment/uncomment code or change any settings — just install and go.

> ⚠️ Do **not** run both ESX and Qbox simultaneously. The resource auto-detects whichever framework is active on your server.

---

## 🔑 ACE Permissions

To control who can use the `clearticker` command, add the appropriate entries to your server's `server.cfg`:

```cfg
# Admins only
add_ace group.admin command.clearticker allow

# A specific job group (if you have custom groups)
add_ace group.supervisor command.clearticker allow

# A specific player by identifier
add_principal identifier.fivem:123456 group.admin
```

> ℹ️ Replace `identifier.fivem:123456` with the target player's actual FiveM identifier. You can find this in your server console or admin panel.

---

## 🛒 Support

For issues or questions, please contact via the store platform where this resource was purchased.

---
