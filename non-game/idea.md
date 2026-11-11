# Tongue Attack

Players are frogs sitting at the left/right side of the screen. Press your button to extend your tongue. Press it again to retract (it will also auto-retract after X seconds or after a wrong collection?)

Between you, stuff is falling from the sky/floating down the river. Stuff with a specific **color/shape/etc**. 

As expected: **try to catch only the ones that belong to you**! (As each player/frog has a designated color/shape/icon.)

When playing with **colors**, we can also add that extra rule:

* EXPANSION = When you **hold** your button, you cycle through the COLOR WHEEL (changing your color)

When playing with **shapes**, we can add this extra rule: (A kind of geometry dash.)

* EXPANSION = When you **hold** your button, you can change your shape (go _up_ a corner, until from octagon back to triangle/circle?)
* (Additionally, you might be shooting slanted/at an angle now. => We could allow tongues to get STUCK IN EACH OTHER then ... detect area enter on tongue tip)

**YES IT SHOULD BE ...**

* PRESS BUTTON to extend tongue
* PRESS BUTTON AGAIN to unextend it

This allows accidentally (or not) catching stuff that was meant for other players lower than you.

Additionally, solid "blocks" might come down from above. If you hit them with your tongue, they actually become _permanent_ and will block tongues on the other side. (They'll stay for a while or until something hits them or whatever.) => I envision these as random walls between players that shorten how far your tongue can go/what you can grab.


_Great function for spring smoothing, usable basically anywhere_.

speed = lerp(speed, (goal - thing) * stiffness, damping_factor)
thing += speed








# To-Do


## For release

A single video of playtest?

WRITE DEVLOG about "small bad collect area" and the "score per player" change.


## Expansions / Game Mechanics

BUG: Some creasure on Texture RIDs leaked on exit??

Pretty useful:

* COMPETITIVE mode?
* Settings: Add tooltips

Not that useful:

* A way to **shuffle** everyone's desires while playing? Maybe when something bad falls off the bottom or **someone gets stuck to a stone**?
* Wrong Collection / Let Something Fall To Bottom (which was meant for you) = **your tongue immediately retracts/gets stuck**
* Hold button to change color/shape => MOVE TO SOME OTHER GAME IN THIS TOPIC
* Be very generous with bad collectibles: don't grab them if you haven't been touching them for long enough. (A delay of 50--100 milliseconds should not be that noticeable.) --> Not really nice for coding nor playing, my "small bad collect area" solution is MUCH better





# Reference

## Settings

### Difficulty: Easy

* Desire: Icons
* Desire: Colors
* Starting Lives
* Starting Score
* Narrate matches
* Everyone has the same desire
* Penalty missed

### Difficulty: Medium

* Desire: Shapes
* Desire: Numbers
* Tongue can get stuck
* Pick up wrong collectibles (but no penalty)
* Tongue speed
* Gravity scale
* Max Score / Target Score

### Difficulty: Hard

* Desire: Letters
* Frog Hopping
* Penalty wrong collectibles
* Spawn Stones
* (@TODO: Randomly Change Desires = Whenever you lose a life or points, there's a chance all frog's desires shuffle.) (NEW)