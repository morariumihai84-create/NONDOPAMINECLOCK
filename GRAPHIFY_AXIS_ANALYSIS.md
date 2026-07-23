# Graphify Analysis: AXIS OS 2026 - Dopamine Operating System

## 📊 Project Overview

**File:** `AxisPremium-4.2$2-android.html`
**Type:** Single-page application (SPA) - Mobile-first web UI
**Purpose:** Dopamine-aware operating system for focus, habit tracking, and gamified wellness
**Framework:** Vanilla JavaScript (no external dependencies except Stripe)
**Platform:** Mobile web app (iOS/Android responsive)

---

## 🏗️ Architecture Map

```
┌─────────────────────────────────────────────────────────┐
│          AXIS OS - Client Architecture                   │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │           STATE LAYER (localStorage)             │   │
│  │  - Dopamine Score                                │   │
│  │  - Focus sessions & streaks                      │   │
│  │  - User preferences (detox, grayscale, etc)      │   │
│  │  - Challenge progress & water tracking           │   │
│  └──────────────────────────────────────────────────┘   │
│                      ↓↑ (persist)                        │
│  ┌──────────────────────────────────────────────────┐   │
│  │         DOPAMINE SCORE ENGINE                    │   │
│  │  computeScore() → [0-100]                        │   │
│  │  - Focus minutes (35 pts max)                    │   │
│  │  - Urges beaten (14 pts max)                     │   │
│  │  - Morning protocol (15 pts max)                 │   │
│  │  - Breathwork (8 pts max)                        │   │
│  │  - Hydration (5 pts max)                         │   │
│  │  - Mode bonuses (detox +5, grayscale +3)         │   │
│  └──────────────────────────────────────────────────┘   │
│                      ↓                                   │
│  ┌──────────────────────────────────────────────────┐   │
│  │         VIEW LAYER (Navigation)                  │   │
│  │  - view-home (dashboard)                         │   │
│  │  - view-focus (pomodoro timer)                   │   │
│  │  - view-health (protocols, breathwork)           │   │
│  │  - view-detox (streaks, challenges)              │   │
│  │  - view-premium (payment via Stripe)             │   │
│  └──────────────────────────────────────────────────┘   │
│                      ↓                                   │
│  ┌──────────────────────────────────────────────────┐   │
│  │    MODAL LAYER (Overlays)                        │   │
│  │  - Breathwork player                             │   │
│  │  - Intention gate (detox reminder)               │   │
│  │  - Share card generator                          │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 🔌 Key Components & Their Relationships

### 1. **STATE MANAGEMENT** → Core Logic
```javascript
DEFAULTS object → localStorage ('axis-state-v2')
                 → dailyReset() [streak logic, day rollover]
                 → save() [persistence]
```

**State Properties:**
| Property | Type | Purpose |
|----------|------|---------|
| `isDetox` | boolean | Enables intention gate on social apps |
| `grayscale` | boolean | Visual desaturation mode |
| `winddown` | boolean | Evening warm/dim aesthetic |
| `todayFocusMin` | number | Focus minutes accumulated today |
| `streakDays` | number | Consecutive "Monk Day" (80+ score) count |
| `waterMl` | number | Hydration tracking (0-3000ml) |
| `protocolDone` | array | Morning protocol checkboxes |
| `challenges` | object | Challenge join timestamps |
| `weeklyFocusMin` | number | League scoring metric |

---

### 2. **DOPAMINE SCORE ENGINE** → View Updates
```
computeScore() function
    ↓
updateScore() 
    ├→ Updates ring SVG stroke-dashoffset
    ├→ Sets score state (Baseline/Building/Locked In/Monk Mode)
    ├→ Checks for Monk Day unlock (score >= 80)
    │   └→ Extends streak, logs monkDayLogged
    └→ Triggers toast notification on milestone
```

**Scoring Formula:**
```javascript
score = 20 (baseline)
      + min(35, focusMinutes * 0.5)
      + min(14, urgesBeaten * 2)
      + protocolDone.length * 3
      + min(8, breathSessions * 4)
      + min(5, floor(waterMl / 500))
      + (isDetox ? 5 : 0)
      + (grayscale ? 3 : 0)
```

---

### 3. **FOCUS / POMODORO TIMER** → Score Update
```
toggleFocus()
    ↓
[interval every 1s] → updateFocusDisplay()
    ↓
completeFocusSession()
    ├→ state.sessionsToday++
    ├→ state.todayFocusMin += duration
    ├→ state.reclaimedMinutes += duration
    ├→ state.weeklyFocusMin += duration
    ├→ save()
    └→ updateDashboard() → updateScore() → UI refresh
```

**Durations Supported:**
- 15 min (Warm-up)
- 25 min (Pomodoro)
- 45 min (Deep Work)
- 90 min (Monk Block)

---

### 4. **INTENTION GATE** (Detox Mode Protection)
```
triggerDangerApp(appName) [Instagram/TikTok/X]
    ├→ If !isDetox: launch immediately
    └→ If isDetox: open gate-overlay
       ├→ 10-second countdown
       ├→ Require 15+ character reason in textarea
       ├→ gateStay() → urgesBeaten++, +2 score
       └→ gateOpen() → log app access as conscious
```

**Flow Diagram:**
```
User taps [Instagram]
    ↓
isDetox check
    ├→ YES → show gate overlay
    │    ├→ timer: 10s → "Decide with intention"
    │    ├→ reason input (15+ chars required)
    │    └→ Two buttons:
    │        ├─ Stay Focused (+2 score)
    │        └─ Open Anyway (tracked)
    │
    └→ NO → direct launch
```

---

### 5. **MORNING PROTOCOL** → Score Multiplier
```
PROTOCOL array (5 tasks)
    ├─ ☀️ 10 min sunlight
    ├─ 📵 No phone 30 min
    ├─ 💧 Hydrate before caffeine
    ├─ 🏃 Move 5+ minutes
    └─ 🧊 Cold shower finish

Each task: +3 points per completion
Full protocol: +15 points + toast notification
```

**Interaction:**
```javascript
.check-item click
    ↓
Toggle protocolDone array
    ↓
save() → renderProtocol() → updateScore()
```

---

### 6. **BREATHWORK LIBRARY** → Score & Wellness
```
startBreathwork(key)
    ├─ key: 'box' / '478' / 'coherence'
    ├─ Fetch from PROTOCOLS object
    ├─ Calculate total animation time
    ├─ Schedule timeouts for:
    │   ├─ Text updates (Inhale/Hold/Exhale)
    │   ├─ Circle scaling (pulse effect)
    │   └─ Cycle counter
    └─ On completion:
        ├─ state.breathSessions++
        ├─ save()
        └─ updateScore() [+4 points]
```

**Protocols:**
| Name | Cycles | Rhythm | Effect |
|------|--------|--------|--------|
| Box | 4 | 4-4-4-4 | Calm under pressure |
| 4-7-8 | 3 | 4-7-8 | Evening wind-down |
| Coherence 5.5 | 6 | 5.5-5.5 | Steady rhythm |

---

### 7. **WATER TRACKING** → Hydration UI
```
addWater(ml)
    ├─ state.waterMl += ml (capped at 3000)
    ├─ save()
    ├─ renderWater()
    │   ├─ Update total display
    │   ├─ Fill 10 dots (250ml each)
    │   └─ Status text update
    └─ updateScore() [+0 to +5 based on 250ml buckets]
```

---

### 8. **STREAK & MILESTONES** → Long-term Gamification
```
Daily Reset Logic:
    ├─ Check if today != lastDate
    ├─ If yesterday's monkDayLogged = false → streakDays reset
    ├─ If gap >= 2 days → streakDays reset
    └─ Roll: todayFocusMin, sessionsToday, protocolDone → 0

Monk Day Check (score >= 80):
    ├─ Set monkDayLogged = true
    ├─ streakDays++
    ├─ bestStreak = max(bestStreak, streakDays)
    └─ Flame emoji: 🕯 (1-7) → 🔥 (7-30) → 🌋 (30+)

Milestones:
    ├─ 3-Day Spark
    ├─ 1-Week Reset
    ├─ 14-Day Fortnight
    ├─ 30-Day Rewire
    └─ 90-Day Monk
```

---

### 9. **FOCUS LEAGUE** (Social Competition)
```
renderLeaderboard()
    ├─ LEAGUE array (6 hardcoded users)
    ├─ Add { user account, weeklyFocusMin }
    ├─ Sort by minutes descending
    └─ Render rows with rank, avatar, name, minutes
       (User row highlighted if .me = true)

Weekly Reset:
    └─ Monday 00:00 → state.weeklyFocusMin = 0
```

---

### 10. **CHALLENGES** (Seasonal Goals)
```
CHALLENGES array:
    ├─ 30-Day Dopamine Reset (score >= 60 daily)
    ├─ 7-Day No-Scroll (no gated apps)
    └─ 14 Sunrises (morning protocol logged)

Join Challenge:
    ├─ state.challenges[id] = Date.now()
    ├─ save()
    └─ Calculate progress: (now - joinTime) / 86400000

Display: Progress bar + day counter
```

---

### 11. **SHARE CARD** (Social Proof)
```
openShareCard()
    ├─ Show overlay with preview
    ├─ Ratio options: story (9:16) or square (1:1)
    ├─ Handle input field (@username)
    ├─ renderShareCard() updates preview
    └─ downloadShareCard() → canvas export (mocked)
```

---

### 12. **NAVIGATION SYSTEM** → View Switching
```
nav(viewId)
    ├─ Remove .active from all .view elements
    ├─ Add .active to target viewId
    ├─ Update .dock-item active state
    └─ Trigger CSS transition: opacity + transform

VIEWS array: ['view-home', 'view-focus', 'view-health', 'view-detox', 'view-premium']
```

---

### 13. **QUICK TOGGLES** (Mode System)
```
Detox Mode:
    └─ toggleDetox() → isDetox = !isDetox
       ├─ triggerDangerApp() checks this flag
       ├─ +5 score bonus
       └─ Visual indicator on chip

Grayscale Mode:
    └─ toggleGrayscale() → grayscale = !grayscale
       ├─ Device class: .grayscale filter applied
       ├─ +3 score bonus
       └─ CSS: filter: grayscale(1)

Wind-Down Mode:
    └─ toggleWinddown() → winddown = !winddown
       ├─ Device class: .winddown filter applied
       ├─ CSS: sepia(0.35) brightness(0.82)
       └─ No score bonus
```

---

## 🔗 Data Flow Diagrams

### Focus Session → Score Update
```
User taps "Start" on Focus timer
    ↓
toggleFocus() sets focusActive = true
    ↓
setInterval updateFocusDisplay() [every 1s]
    ↓
focusTime reaches 0
    ↓
completeFocusSession()
    ├─ sessionsToday++
    ├─ todayFocusMin += duration
    ├─ save()
    ├─ updateDashboard()
    │   └─ Update widget values
    ├─ updateScore()
    │   ├─ Recalculate score
    │   ├─ Update ring SVG
    │   ├─ Check Monk Day (>= 80)
    │   │   └─ If true: streakDays++, monkDayLogged=true
    │   └─ Update state label
    ├─ renderLeaderboard() [update weekly minutes]
    └─ toast() + UI pulse animation
```

### Beaten Urge → Score Update
```
User taps [Instagram] with Detox on
    ↓
triggerDangerApp() opens gate-overlay
    ↓
User fills reason (15+ chars) + waits 10s
    ↓
User taps "Stay Focused"
    ↓
gateStay()
    ├─ urgesBeaten++
    ├─ save()
    ├─ updateDashboard()
    ├─ updateScore()
    │   └─ +2 from urgesBeaten formula
    └─ toast('+2 Dopamine Score')
```

### Daily Rollover → Streak Logic
```
Page load (any day)
    ↓
dailyReset() function
    ├─ today = new Date().toDateString()
    ├─ Compare to state.lastDate
    │
    ├─ If lastDate === today
    │   └─ Do nothing (same day)
    │
    ├─ If lastDate === yesterday && monkDayLogged === false
    │   └─ streakDays = 0 (missed Monk Day bar)
    │
    ├─ Else if lastDate !== today && gap > 1 day
    │   └─ streakDays = 0 (missed days)
    │
    ├─ Update lastDate = today
    ├─ Reset daily counters:
    │   ├─ todayFocusMin = 0
    │   ├─ sessionsToday = 0
    │   ├─ protocolDone = []
    │   ├─ waterMl = 0
    │   └─ monkDayLogged = false
    │
    └─ If new Date().getDay() === 1 (Monday)
       └─ weeklyFocusMin = 0 (league reset)
```

---

## 🎨 UI/UX Component Tree

```
Device (400x900px container)
├─ Notch (clock display)
│
├─ View: HOME
│   ├─ Score Hero (ring + state + rank)
│   ├─ Quick Controls (chip row: detox/grayscale/winddown)
│   ├─ AI Coach Card (rotating tips)
│   ├─ Stats Grid (4 widgets)
│   ├─ App Launcher (8 items, 4 danger apps)
│   └─ [scrollable]
│
├─ View: FOCUS
│   ├─ Hero Title
│   ├─ Focus Circle (animated, pulsing when active)
│   ├─ Timer Display (MM:SS)
│   ├─ Start/Pause + Reset buttons
│   └─ Duration selector (15/25/45/90 min)
│
├─ View: HEALTH
│   ├─ Morning Protocol (5 checkboxes)
│   ├─ Water Tracker (10 dots + ml counter)
│   ├─ Breathwork Library (3 cards)
│   └─ Body Signals (HRV, sleep, sunlight)
│
├─ View: DETOX/STREAK
│   ├─ Streak Hero (flame + day count)
│   ├─ Share Card Button
│   ├─ Live Challenges (3 cards w/ progress)
│   └─ Focus League Leaderboard (6 users)
│
├─ View: PREMIUM
│   ├─ Feature list (5 items)
│   ├─ Stripe card element
│   ├─ Apple Pay button (conditional)
│   ├─ Google Pay button
│   └─ Subscribe button ($4.99/mo)
│
├─ Overlays:
│   ├─ Breathwork player (circle pulse + text)
│   ├─ Intention gate (timer + reason textarea)
│   └─ Share card generator (ratio toggle + preview)
│
├─ Dock (5 navigation items at bottom)
│
└─ Toast (bottom notification)
```

---

## 🔐 Security & Persistence

**Storage:**
- Key: `axis-state-v2`
- Format: JSON
- Location: browser localStorage
- ⚠️ Client-side only (no backend sync in this demo)

**Stripe Integration:**
- Public key embedded (test mode: `pk_test_...`)
- Card element mounted on #card-element
- ⚠️ No server-side token validation in this demo

---

## 🚀 Initialization Flow

```javascript
window.onload → init()
    ├─ updateDashboard()
    ├─ updateScore()
    ├─ updateChips()
    ├─ renderProtocol()
    ├─ renderWater()
    ├─ renderStreak()
    ├─ renderChallenges()
    ├─ renderLeaderboard()
    ├─ renderCoach()
    └─ Daily reset check (dailyReset)
```

---

## 📋 CSS Variables (Design Tokens)

```css
--bg-base: #0f0f0f              /* Main background */
--bg-surface: #1a1a1a           /* Card backgrounds */
--text-primary: #ffffff         /* Main text */
--text-secondary: #a8a8a8       /* Secondary text */
--accent-green: #9fdb4d         /* Primary accent */
--accent-blue: #65b7f1          /* Secondary accent */
--accent-red: #f17373           /* Danger/delete */
--accent-gold: #e8c547          /* Milestone/premium */
--accent-violet: #b88df5        /* Coach/insight */
--spring: cubic-bezier(0.175, 0.885, 0.32, 1.15)
--ease: cubic-bezier(0.25, 1, 0.5, 1)
--smooth: cubic-bezier(0.4, 0, 0.2, 1)
```

---

## 🎯 Key Interaction Patterns

| Action | Handler | Result |
|--------|---------|--------|
| Complete focus session | `completeFocusSession()` | +score, update league, pulse animation |
| Beat app urge | `gateStay()` | +2 score, update counter, toast |
| Log morning task | `check-item.onclick` | +3 score per item, full protocol bonus |
| Breathwork completion | `startBreathwork()` timeout | +4 score, increment session counter |
| Add water | `addWater(ml)` | +0-5 score, update dots, UI bar |
| Hit Monk Day (80+) | `updateScore()` | +1 streak, extend flame emoji, unlock badge |

---

## 🔧 Customization Points

**Easy to modify:**
- Scoring formula (adjust multipliers in `computeScore()`)
- Protocol tasks (edit `PROTOCOL` array)
- Breathwork rhythms (edit `PROTOCOLS` object)
- Challenge definitions (edit `CHALLENGES` array)
- Leaderboard names (edit `LEAGUE` array)
- Coach tips (edit `COACH_TIPS` array)
- Milestone thresholds (edit `MILESTONES` array)
- Colors (CSS variables in `:root`)

**Requires backend:**
- Multi-device sync (needs API)
- Real leaderboard (API + database)
- Payment processing (Stripe webhook)
- Notion integration (OAuth)
- Friend challenges (WebSocket or API)

---

## ⚡ Performance Notes

- **DOM:** Minimal redraw, CSS transitions used heavily
- **Storage:** ~5KB per user (state JSON)
- **Memory:** Timers cleaned up on breathwork exit
- **Animations:** CSS-based, hardware-accelerated
- **Mobile:** Tap highlights disabled, font smoothing enabled

---

## 📱 Responsive Behavior

```css
Mobile (<= 500px):
  └─ Device: 100vw × 100vh (full screen)
  └─ Remove border-radius & border
  └─ Adjust padding
```

---

## 🎓 Learning Value

This SPA demonstrates:
✅ State management without Redux (vanilla JS patterns)
✅ localStorage persistence with daily rollover logic
✅ SVG animation (score ring stroke-dashoffset)
✅ CSS filters & transforms (grayscale, sepia, scale)
✅ Interval-based timers (pomodoro, breathwork)
✅ Gamification mechanics (scoring, streaks, badges)
✅ Modal overlays with blocking logic
✅ Responsive mobile-first design
✅ Stripe integration (basic setup)
✅ UX patterns: intention gates, share cards, progress bars

---

**Generated by Graphify | AXIS OS 2026 Analysis**
