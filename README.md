# garmin-swimmy

Garmin watch app and phone companion for swimming performance.

## Phase 1 target

- **Primary watch target:** Garmin **Quatix 7 Pro (AMOLED)**
- Focus on high-readability watch UI for swimmers wearing goggles
- Pair with a phone companion app to manage workouts and presets

## Initial implementation plan

### 1) Foundation (watch + phone)
- Create a Connect IQ watch app shell for Quatix 7 Pro.
- Create a phone companion shell to store workout presets and custom workouts.
- Define a shared workout model:
  - preset workouts (e.g., endurance, intervals, drill sets)
  - custom workouts (name, distance/interval blocks, rest rules)

### 2) Sensor strategy for swim tracking
Use watch data that directly supports lap/performance and health insights:
- accelerometer + stroke/motion patterns for lap/stroke detection support
- pool-length/lap events and elapsed time for pacing
- heart rate for effort/load trends
- calories/body metrics from device profile where available

### 3) Watch UX (Material-inspired, readability-first)
- High contrast AMOLED color tokens (dark background, bright accent).
- Large typography and big tap targets.
- Minimal per-screen information density.
- One primary action per screen.

### 4) Workout picker flow
- Watch shows a quick workout picker before swim start.
- Picker includes:
  - recent workout
  - preset workouts synced from phone
  - custom workouts synced from phone
- Phone app is source of truth for creating/editing/deleting presets/custom workouts.

### 5) Milestones + haptic rewards
- Trigger haptics at meaningful milestones:
  - completed lap count milestones
  - target distance reached
  - workout block completion
  - personal best split (when detected)
- Keep haptics short and distinct to avoid distraction.

## Interface mockup (first pass)

### Watch screens

#### A) Pre-swim workout picker
- **Header:** “Select Workout”
- **List items (large rows):**
  1. Quick Start Swim
  2. Preset: 10x100m Intervals
  3. Preset: 1500m Endurance
  4. Custom: Coach Tuesday Set
- **Footer action:** Start

#### B) In-swim main data screen
- **Primary metric (largest text):** Current pace /100m
- **Secondary metrics:** Lap count, elapsed time, heart rate
- **Optional compact row:** Current set progress (e.g., 4/10)
- Always-on high contrast with minimal clutter.

#### C) Milestone feedback card (temporary overlay)
- Big label: “Milestone!”
- Detail: “500m completed” or “Lap 20”
- Immediate haptic pulse pattern
- Auto-dismiss back to main data screen

### Phone companion screens

#### A) Workout library
- Segmented tabs: Presets | Custom
- Card list with title, distance/structure summary, and edit action

#### B) Workout editor
- Name field
- Repeat blocks (distance, effort, rest)
- Save + sync to watch

#### C) Sync & device status
- Last sync time
- Pending updates count
- Manual “Sync now” action

## Next step implementation slice

1. Scaffold watch app views for picker + in-swim metrics layout.
2. Scaffold phone workout library/editor views with Material components.
3. Implement sync contract for presets/custom workouts to the watch.
4. Add milestone detection hooks and haptic trigger mapping.
