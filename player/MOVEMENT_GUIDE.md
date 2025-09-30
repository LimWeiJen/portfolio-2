# 2D Platformer Movement Script Guide

## Overview
This script provides a complete, polished 2D platformer movement system with advanced mechanics for smooth and satisfying gameplay.

## Features Implemented

### 1. **Basic Movement**
- Smooth acceleration and deceleration
- Different physics for ground vs air movement
- Configurable move speed, acceleration, and friction

### 2. **Variable Jump Height**
- Hold jump button longer = higher jump
- Release early for shorter, more precise jumps
- Separate jump velocities for first jump and double jump

### 3. **Double Jump**
- Configurable number of air jumps (default: 1)
- Can be enabled/disabled via inspector
- Slightly lower velocity than first jump for balance

### 4. **Coyote Time**
- Grace period after walking off ledges (default: 0.15s)
- Allows jumping shortly after leaving ground
- Makes platforming feel more forgiving

### 5. **Jump Buffer**
- Press jump slightly before landing (default: 0.1s)
- Jump executes automatically on landing
- Reduces need for frame-perfect inputs

### 6. **Dash Mechanic**
- Fast directional dash in 8 directions
- Cooldown system to prevent spam
- Can dash in air or on ground
- Dash direction based on input or facing direction

### 7. **Wall Mechanics**
- **Wall Slide**: Slower fall speed when against wall
- **Wall Jump**: Jump away from wall with horizontal boost
- **Wall Climb**: Hold against wall to slide slowly
- Push time prevents immediate direction change after wall jump

### 8. **Advanced Physics**
- Fast fall when holding down
- Maximum fall speed cap
- Reduced gravity during wall slide
- Smooth movement interpolation

## Controls

### Default Godot Input Map
- **Move Left/Right**: Arrow Keys or A/D
- **Jump**: Space Bar (ui_accept)
- **Dash**: Shift (ui_focus_next)
- **Fast Fall**: Down Arrow (ui_down)
- **Dash Up**: Up Arrow (ui_up)

### Input Actions Required
Make sure these are set up in Project Settings → Input Map:
- `ui_left` - Move left
- `ui_right` - Move right
- `ui_accept` - Jump
- `ui_focus_next` - Dash (Shift key)
- `ui_up` - Dash up
- `ui_down` - Fast fall / Dash down

## Customization

All parameters are exposed in the Godot Inspector under organized groups:

### Movement Group
- **Move Speed**: Base horizontal speed (default: 300)
- **Acceleration**: How fast you reach max speed (default: 2000)
- **Friction**: How fast you stop (default: 1800)
- **Air Acceleration**: Acceleration while airborne (default: 1200)
- **Air Friction**: Friction while airborne (default: 400)

### Jump Group
- **Jump Velocity**: Initial jump strength (default: -500)
- **Jump Cut Multiplier**: Variable jump height factor (default: 0.5)
- **Max Fall Speed**: Terminal velocity (default: 800)
- **Fast Fall Multiplier**: Speed boost when holding down (default: 1.5)

### Double Jump Group
- **Enable Double Jump**: Toggle feature on/off
- **Double Jump Velocity**: Air jump strength (default: -450)
- **Double Jump Count**: Number of air jumps (default: 1)

### Coyote Time Group
- **Coyote Time**: Grace period duration (default: 0.15s)

### Jump Buffer Group
- **Jump Buffer Time**: Early jump window (default: 0.1s)

### Dash Group
- **Enable Dash**: Toggle feature on/off
- **Dash Speed**: Dash velocity (default: 700)
- **Dash Duration**: How long dash lasts (default: 0.2s)
- **Dash Cooldown**: Time between dashes (default: 0.5s)

### Wall Group
- **Enable Wall Mechanics**: Toggle all wall features
- **Wall Slide Speed**: Max speed while sliding (default: 100)
- **Wall Jump Velocity**: Jump force away from wall (default: 400, -500)
- **Wall Jump Push Time**: Lock input duration (default: 0.15s)

### Gravity Group
- **Gravity Scale**: Multiplier for default gravity (default: 1.0)
- **Wall Gravity Scale**: Reduced gravity on walls (default: 0.3)

## Tips for Tuning

### Making Movement Feel Snappier
- Increase acceleration and friction
- Reduce air acceleration for more commitment to jumps

### Making Movement Feel Floatier
- Reduce gravity scale
- Increase jump velocity
- Increase coyote time

### Making Movement Feel Heavier
- Increase gravity scale
- Reduce jump velocity
- Reduce air acceleration

### Balancing Dash
- Shorter duration + higher speed = quick burst
- Longer duration + lower speed = extended movement
- Adjust cooldown to control frequency

## Technical Notes

### Performance
- Uses Godot's built-in `CharacterBody2D` physics
- Efficient timer-based state management
- No raycasts needed for wall detection

### Extensibility
- Clean function separation for easy modification
- State variables clearly documented
- Easy to add new mechanics (wall run, ledge grab, etc.)

### Known Limitations
- Requires a Sprite2D child node named "Sprite2D" for flip
- Uses default Godot input actions
- Assumes standard 2D physics setup

## Troubleshooting

### Player doesn't move
- Check that input actions are set up in Project Settings
- Verify the player node is a CharacterBody2D
- Make sure the script is attached to the player

### Dash doesn't work
- Ensure "ui_focus_next" is mapped (usually Shift)
- Check that `enable_dash` is true in inspector
- Verify cooldown isn't too long

### Wall mechanics not working
- Ensure `enable_wall_mechanics` is true
- Check that walls are StaticBody2D or similar
- Verify collision layers/masks are set correctly
- Must hold direction into wall to slide

### Sprite doesn't flip
- Ensure there's a child node named "Sprite2D"
- Check that the sprite is a Sprite2D node
- Modify line 289 if using different node name

## Future Enhancements

Consider adding:
- Ledge grabbing
- Wall running
- Ground pound
- Slide mechanic
- Stamina system for dash
- Particle effects for dash/jump
- Animation state machine integration
- Sound effect triggers

