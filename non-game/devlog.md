# Tongue Attack (Devlog)

Welcome to the devlog (or "developer's diary") for my game called [Tongue Attack](@TODO:Link). It was one of the first educational _One Button Games_ I made for the online store. It ended up being the first one I actually finished, simply because it was "simpler" and "smaller" than the other ideas. 

That doesn't mean it wasn't without its problems, though. A lot of them, in fact, and I'll try to explain what they are and how I solved them in clear language!

## What's the idea?

I wanted a general purpose "matching" game. Colors, shapes, letters, numbers, the basics. What's the easiest way to turn this into a game? One with a clear approachable theme, where each player really only needs a single button?

> **Each player is a frog at the edge of the screen. Press your button to extend your tongue and grab flies moving past!**

It seemed like one of my simplest ideas. One for which I could find some clear visuals and which would work with all these different things to match.

I had to finish my current project first, and in those few days the idea already became more specific.

* PRESS your button to extend your tongue.
* PRESS it again (at any time) to make it go back again.
* Each frog has its own "desires": grab those for points.
* Any other things are "bad" for you: if you grab them, you lose a life.

You play until you're out of lives (loss) or you've reached the points goal (win).

I envisioned tall tree trunks at the side of the screen, with frogs sitting on big leaves jutting out (either all the way to the left or to the right).

With that "plan", I got started.

## An Endless Tongue

This game had no real programming challenges, which is why I deemed it the "simplest" of my ideas. I don't mean that it was super easy or flawless to program, I just mean that there's no new algorithm or interesting idea to explain here. 

The game is mostly a combination of typical code I've written a hundred times before.

* Randomly spawn collectibles at the top. Make them fall down. Make them disappear when at the bottom.
* Listen to the _One Button_ that each player has. If pressed, extend/retract tongue.
* The collectibles have a "body". The tongue has an "area". When the area detects a body inside, it collects it!

There are only two interesting parts that challenged me to problem solve.

One is the fact that I needed a clean way to support all these different things to "match" (colors, letters, etcetera). I did not want to write this super long list of `if-else` statements checking for each individual thing. That would be prone to bugs, errors, and headaches on my end. 

So, instead, I created a "template" (or blueprint) for each type (`DesireType`). A simple script that the game can call and which will _generate_ (before the game starts) all the options for that type (e.g. all possible SHAPES). I called these `Desire`s. These objects are all inserted into a big list from which it draws randomly. When checking if a frog grabs the right thing, now we just need to compare if the `Desire` saved on the collectible is also in the list of `Desire`s from the frog. 

This allows turning each type on/off at will, while keeping code quite clean and simple!

The second challenge was the **frog tongue**. It had to extend as far as needed, which means we can't just use a single image of a specific size. Instead, I used the following technique.

* The technique has three elements: `SpriteStart`, `Line2D`, and `SpriteEnd`
* The "tip of your tongue" is just an empty node that I move back and forth when you press your button.
  * The `Line2D` is just a line with two points: your frog's mouth (start) and your tongue tip (end).
  * The `SpriteStart` is placed at the _start_, over the mouth of your frog, to pretend the tongue is coming out.
  * As expected, the `SpriteEnd` is placed on the tongue tip, to curve the tongue and make its end look nice.
* That line can be as long or short as we want now (the start/end sprites just stay the same size). To make its look match, though, we use a simple shader to "tile" the texture.
  * In other words, instead of _stretching_ this texture over the whole line, keep its same size and just _repeat_ it as often as needed to cover the whole thing.

It's not perfect---it never is. But while playing, at speed, if your nose isn't pressed against the screen, it looks very crisp and good. 

## Fun Is Designed

I recently heard another game developer say "fun is not inherent, it is designed". I kept thinking about this as I developed the game. Kept reminind myself of this whenever I was in doubt or wanted to throw the idea away.

Because the version I just described, that first prototype I made, was _not_ fun. It rarely is. Even the best ideas start out very raw and mediocre, and you have to _design_ it into something fun. 

What are the issues?

* You are stuck on one side of the screen. As such, there might be a juicy butterfly at the opposite end ... but with three things you _don't_ need in the way! You have no way to grab that without grabbing all the wrong things too.
* You can retract the tongue ... but while retracting, it can't extend again. So you have to wait until it's back at base, and waiting is rarely fun.
* If I only spawn things _that people need_, then the game becomes extremely simple/easy, especially at 1 or 2 players. Just grab everything! 
* If everyone wants _different things_, then with 3+ players you will _not_ have anything to grab most of the time. Because all things on screen belong to _other players_!

So, yes, I had a pretty screen with frogs sending out their tongues. I could've said "hey, educational game, kids can practice matching the right desires---we're done!" But the whole point of my online store (and _One Button Games_) is to prove eductional games should just be _good games_ that _anyone wants to play_.

So ... let's design the fun.

### Step 1: Tongue Sticking

My first try implemented the idea of the tongue **getting stuck**.

* If you hit an object from the _side_, your tongue gets stuck to it.
* This can be _good_---it doesn't retract, so you can grab lots of stuff for free.
* Or this can be _bad_---if bad things are coming that you don't want to grab.
* Furthermore, your tongue sticks if it reaches all the way to the opposite end of the screen.

To unstick, simply **hold** your button for ~0.5 seconds. 

{{% remark %}}
This is the pattern for all One Button Games I've made or prototyped so far. The main gameplay is just PRESS your button. But more advanced tactics/actions can be put on HOLDING the button.
{{% /remark %}}

This worked fine, but I wasn't convinced yet. Let's implement a few more things before our playtest.

### Step 2: Better Desires

Then I tried out all my ideas for changing how the desires (or "collectibles") work.

* Everyone wants the **same** things! Easier, simpler.
* If you stick to a desire, it **slowly fades away**. 
  * This allows _removing_ things you don't match (though it takes more time and you get no reward for it).
  * Which is nice because it provides a way to "save" everyone, even if you don't _match_ the thing that's about to fall to its death.
* Spawn some things that nobody needs. (The more players you have, the lower the probability of this happening. With 5+ players, there's enough going on to not need this.)
* Just **ignore** bad matches, don't get penalized for them.
* You still **grab** bad matches, but simply get no reward for them.
* **Don't** penalize players for missing things. (That is, something you SHOULD have grabbed with your tongue ends up falling off-screen at the bottom.)
* **Balance** spawning. Keep track of how many of each collectible is already on screen, and purposely spawn things that are missing. This ensures no player is randomly without anything to match for 30 seconds.

Again, all these changes were interesting things to add, but without more testing I couldn't be sure.

### Step 3: Funky Frogs

Finally, I tried out ways to play with how the frogs worked.

* Faster/slower tongue speed.
* If you stick to the other side, you actually **move there**.
* Similarly, if you **hold your button** (while idle), you will **hop down** to the next leaf.
* Tongues can stick to each other too (if two frogs are opposite).

The idea of the frogs moving around was really _fun_. It's just fun to hop around and reposition yourself, accidentally or not.

Additionally, it was another attempt at solving those big issues with the first idea.

* If you can change sides, then you _can_ reach things that are blocked from your side.
* Similarly, if you can hop down, you can still _save_ something that you missed earlier.

With aaaalll these possible rules behind settings toggles, I did my playtest.

## Playtest Results

This was a playtest with 4 players. Some on keyboard, some on gamepad. These players were my family members, not kids in classrooms or anything.

My first page of notes is the usual "WHY DOES IT CRASH THERE!?" Situations in which the game never crashed on my own laptop, but it does on other computers. Not that interesting, mostly frustrating ;)

We played about 10 different rounds with different combinations of rules and settings.

First, some surprising results.

**Result #1:** I thought tongue speed should be _slower_ to make the game "easier". But it's actually easier and more satisfying if it's much _faster_. Why?

Because a slow tongue means you have to predict a few seconds ahead! You need to know "I need to press the button NOW, so I grab the thing that will probably be THERE in a second". With a much snappier tongue, you can react more quickly and also get away more quickly from bad things.

**Result #2:** Similarly, gravity speed should be _faster_ too. Or, rather, there should be less _variance_. When playtesting, the gravity could be between `25.0` and `80.0` (px/s). That means some collectibles went almost 4x as fast as others. That divide is what confused players and created moments in which the game was _overwhelming_ (far too fast suddenly!) and other periods when it was _boring_ (they barely fall down!).

I reduced the variance such that the fastest collectible is only twice as fast as the slowest. I also raised the average gravity slightly, as testing simply showed players liked that more and it gave the game a better "flow".

**Result #3:** Hopping around _is_ fun ... but it's really an advanced strategy. When you first start the game, you don't understand why you'd use it, while it confuses the heck out of you when you "suddenly" hop to a different leaf.

As such, by default (when you start the game for the first time), any _movement_ and _getting stuck_ is **turned off**.

**Result #4:** I purposely made the main button just a _press_, not a _hold_. Still, after saying "quick tap your button to extend your tongue" ... two players held it down all the time. This issue was alleviated when I turned off anything that required a hold (getting unstuck/hopping), because, well, then holding just does nothing and won't make you think it does.

In other words, I kept it a **press**. Any rules that require **holding** are turned off by default.

Then, some less surprising results, but you still need a practical playtest to show it. These are mostly a consequence of the three things I mentioned above.

Without _moving your frog_ or _tongue sticking_, there is only one way to solve the annoying part of grabbing the wrong things: don't penalize it. You simply **don't grab things that don't match**. They pass through your tongue. This turned out to be _simplest_ and _clearest_ (because you only get big feedback on _good matches_). 

* You simply want to **grab the right things**. That's your sole focus (in your first games): "grab things that match".
* You only lose lives if you **miss the right things** (they fall off the bottom).
* The game also tracks **time**: you can try to improve your _time_ in this "easy mode".

It always takes some iterations to find the simplest, most fun core of a game. Without getting stuck, and without hopping confusing new players, and without bad stuff happening if your tongue doesn't leave soon enough, we get that fun core to shine through. Find the matches, time it right, and get a satisfying pling and bounce when you snatch it from the air!

All the other ideas _need_ that core. They only make sense when added _on top_, for players who are comfortable with the game.

## The Final Product

As such, I decided to subdivide the settings into three groups: EASY, MEDIUM, HARD. Turning on settings in the "Hard" group, as expected, modulates the game difficulty to be harder. Things like moving around will be here.

The core game looks great, is very easy to teach and play, and focuses completely on matching the right things.

I purposely focused a lot more on the _visuals_ this time. It's always the thing that gets lowest priority, which is a shame, because good visuals is the first thing players see and makes them interested. I could focus on visuals now because the game itself was relatively simple, not ground-breaking at all. Unsurprisingly, spending a day on visuals only makes a game look _much_ better, who would've thought!? 

{{% remark %}}
It also helps that I had a really strong vision for this game in my head. That just happens sometimes---about 1/3 of the time. You get a picture in your head of the final game, and if you can just approximate that, then you can quickly get a nice unified final look. You might look at this the other way around: pick game ideas for which you have a strong vision, it makes your life easier.
{{% /remark %}}

On top of this, of course, I added lots of polish and tweaks. Things that slowly move or sway in the wind (in the background). Little animations and feedback on all actions. Some more messing with numbers to get them just right. (Most of the time, this means making them _higher_. As I explained with the "tongue speed" example, making things slower usually doesn't necessarily make things easier, and it never makes them more fun.)

I had to concede a few things too. I just wasn't able to localize the words/letters and narration aspect in the game too (that's all English). I don't have the funds and resources (at all).

I also had the idea of allowing you to **change** your desires.

* Grabbing bad stuff would have a chance of randomly _shuffling_ them again.
* Holding your button (when idle) would shift colors along the color wheel, or shift shapes in terms of corners (square -> pentagon)

But, alas, the game went in a different direction and these were now too unlike the rest of the game. Too hard to incorporate, program, and explain. So I moved them to another future game, maybe.

I also considered a **competitive mode**. It might work---just track which individual frog got the most points and lost the fewest lives---but the project isn't set up for it and it doesn't match the general collaborative, friendly vibe this game goes for. So I wrote it down as a possible future improvement, but left it at that.

The game also helped improve my _One Button Games_ framework further. For example, I had somehow screwed up the order of gamepad buttons, so the image for which one to press was just wrong on two of them. Those kinds of things are fixed now, as well as cleaner code behind the scenes.

I'll now take that framework and drop it into the _next_ educational OBG, probably still about colors and shapes.

Until the next devlog,

Pandaqi







