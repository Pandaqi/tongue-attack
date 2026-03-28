# Shape Sweepers (Devlog)

Welcome to the devlog (or "developer's diary") for my game called [Shape Sweepers](@TODO:Link). It was the first truly educational _One Button Game_ I made for the online store. (Earlier One Button Games were _themed_, e.g. about Christmas, and mostly used to test the idea and refine it.)

I had a list of ideas for games and had to make a decision. In such cases, I always rank them by how small and risk-free they are, so that I can start with the "easiest" (or "most certain") of the ideas.

Usually, that doesn't mean the idea is simple to make, it just means my other ideas were even harder ;)

In any case, my goal with these games is to make _fun games_ where the educational part is simply integral to the experience. I am not interested in making "educational games" that are just homework exercises but on a screen---not games at all, really. It should a _fun game_ first and foremost, something you can play with the whole family, something kids _want_ to play, and they'll learn because that's simply required to play _well_.

So ... how do we do that?

## What's the idea?

When teaching _shapes_ to kids, there are a few goals to consider.

* Teach them the _basic shapes_ and their general name/look.
* Teach them to _generalize_ this: even if a triangle is a bit wonky, or upside-down, it's still a triangle.
* Teach them _why they need to know_. Show them how it can be used for tasks or problem solving.

This thinking brought me to this game idea.

* The entire map **is** a basic shape. You're literally inside a circle/triangle/square.
* You move around by jumping off the edges. 
  * You simply fly in a straight line from there until you hit the opposite edge.
  * There, you can re-aim again and shoot off.
  * This is ONE BUTTON: "jump off"!
* All players are "cleaners" (or brooms or whatever). You erase the entire path you take each time.
  * Your goal is to **erase the entire map/shape**! You can play alone, or together, it's cooperative.

This felt like a strong way to really integrate shapes and what they into the entire gameplay from start to finish.

* You're constantly looking at that one shape and your movement is constrained by it.
* You're erasing the shape, constantly considering its surface area and where you can clean up the most.
* Moreover, I can easily extend this by adding "powerups" to grab along the way. 
  * For example, maybe only powerups **with the same shape as the map** are "good"---the others are "bad".
  * I can write code to make shapes a little wonky, so kids need to learn to actually recognize triangles instead of _memorizing_ the one look they have.

## How do we make that? (Technical)

This part contains all the technical details! Skip this if you're just interested in the high-level game design and educational considerations.

### Generating Shapes

I wrote a simple system to _generate any shape_. I simply tell it "give me a square!", and it gives me the list of vertices that define the square. 

The algorithm I've always used for creating such polygons is to grab equidistant points on a circle. Or, more specifically,

* Start with `angle = 0` and `list = []`
* Loop as many times as the number of vertices. (_For a square that'd be 4._)
  * Each time, add `2pi / num_vertices` to the angle.
  * Now the next vertex of the polygon is `Vector2.from_angle(angle)`
  * Add that to the list!
* Once done, you'll have made a full circle and saved the exact number of vertices you need in a list.

A _circle_ is just the same thing but with _loads_ of vertices. Enough that it starts to look like a circle instead of a polygon. (True circles don't exist on computers. It's all just polygons: a list of points to connect.)

### Sticking to the shape

My game engine has a handy function called `Geometry2D.is_point_in_polygon(point, shape)`. Each frame, I call this to figure out if a player is still inside the shape. 

If so, great!

If not, snap us back inside! Find the closest point on the polygon and put us there. 

More specifically,

* Loop through all line segments of the polygon (made in the previous step).
* Call `Geometry2D.get_closest_point_to_segment(point, s1, s2)`. As the name implies, this gives us the closest point between where we are and the edge of our polygon.
  * If this is the best we've found so far (the "closest of them all"), save it!
  * Otherwise, ignore it, we've found a spot that's better
* When done, we have the best point to snap towards.

Snapping is not enough, though. We also need to always be oriented _inside_ the shape. When we press our one button, we need to jump off _into the shape_.

So, I also return the _line segment_ that our closest point was on. Because all our polygons are defined clockwise, we know we can _rotate_ that segment clockwise by 90 degrees (or `0.5 pi`). The result is the vector pointing _into_ the shape. 

The "aiming" code animates an arrow bouncing around this vector. When you press your button, whatever direction the arrow aims at now is how you'll shoot off and move forward.

### Erasing your path (Method 1)

At first, I coded a "naive, simple implementation" just to see how it looked and get started. I knew I had to replace it eventually, but only because my game had such specific requirements. That implementation might be fine for many games!

* Create a `SubViewport`
* Send its texture to a `Sprite2D` that you display in the same position as the big map shape.
* Add a `Polygon2D` child. Set its `points` to the points list of the current big map shape.
* Whenever a player moves through the shape, 
  * Create a new `Line2D` for them.
  * Keep adding its current position to it.
  * And set its `material` to something with `render_mode` set to `subtract`. (This SUBTRACTS the line from whatever is behind it, in this case the polygon.)

This worked fine. It gives very crisp lines, it erases as it should, and I saw no performance issues. (Although I expect them to appear if you actually played for 5 minutes, as those `Line2D`s are _never removed_! You just can't do that while playing, because then the entire system breaks.)

It showed me that the idea was working. It was definitely possible to "clean" the dirty texture with this movement and it was quite fun too.

I had too many reasons, though, for wanting something better.

* I wanted to support **different shapes** for erasing. A player that looked like a square, for example, should erase with a _square shape_. It's a game about shapes after all!
* I wanted to support **painting the texture again**. The current method only allows _subtraction_, but maybe some bad powerups or enemies would explode and _add back some paint_.
* As stated, if games really go on for a while, that means thousands and thousands of `Line2D`s and it will certainly cause issues.
* If I want some funky textures or patterns on this erasable texture, it's easier with a different method.

### Erasing your path (Method 2)

I implemented a second method that is simpler ... on the surface.

* I create an `Image.new()`
* Whenever you erase stuff, I find the actual pixels you affect, and simply **update those raw pixels**.
* When done, I call `ImageTexture.create_from_image(that_image)` and give that to the `Sprite2D` to display the new version.

In this method I'm manipulating an actual image file, in real time, constantly, setting individual pixels. As expected, this is even _worse_ for performance, at least for now.

But we can improve that!

I don't need to make that `Image` the same as the screen resolution. I can make it a _much lower resolution_ (e.g. `(512,512)` instead of `(1280,720)`). When you erase, I convert your real position to the scaled-down one. When drawing the texture, I blow it back up to full size.

There are more improvements, but they're not necessary now. With a scaled-down version, performance is fine. And, notably, performance is "constant". No matter how long you've been playing, no matter what you're doing, the performance impact of this will stay the same.

### Have you won?

You win the game by cleaning the entire area. But ... how do we know? Also, it's incredibly annoying if you've cleaned 99.999% of it and just keep missing that final tiny pixel somewhere. We should be a bit more graceful about it.

I learned all these tricks when I made my game _Rolling in the Sheepe_. And in this case, the trick is the same as in the previous section!

* We maintain a small low-resolution grid. Just a long list of `true/false` statements about whether you have erased some general _area_ of the image. This grid can be as small as `(16,16)` or `(32,32)` for this to work fine.
* When erasing, we convert the player position to the grid and mark those cells as `false` (they are empty now).
* To know if we're done, we calculate **how many `true`s are still left in that grid**.
* When we pass some threshold (say, only 2% of the grid is still not erased), we send a signal that it's all clean.

This is both great for performance and very generous to players. You don't actually need to clean it all perfectly to win. Getting close enough is fine.

### Everything else

Now the hardest part was done. 

* Players are nicely snapped inside a map of any shape, moving around as they should.
* As they do, they clean up the parts of the image that they're moving over.
* And when they've done so well enough, the game knows it should end.

At this point, such game prototypes are just a nice "toy" really. Because actual gameplay isn't here yet.

I knew I had to reward your for cleaning up efficiently. I knew I could spawn powerups inside the shape that you wanted to grab, or _not_ grab. (Such as the one that explodes and re-paints that parts of the texture!) Nothing about this is a technical challenge anymore---now we're left with game design challenges!

### Performance Optimizations (for the die-hards)

Here are a few more things to optimize this system for erasing textures. This is _heavy_ on computers. Even more so when the texture is basically _the entire screen_ because the entire game revolves around it. I have a crappy 15 year old laptop that was never meant for any graphics stuff, so I'm always looking for ways to improve performance.

**Trick #1:** We don't need to run through the entire grid array and count how many cells are "empty/filled" each time. This is just a number we can count on the fly. So, every time you paint, I simply check "did this cell change?" and then update the number. 

* This isn't a big deal, sure.
* But if that grid is say `(32,32)`, then it's still looping through 32x32 = 1024 elements each time. 
* Now it's just looking up a single number we already have.

**Trick #2:** I tried calling the `draw()` function less often (30 times or 15 times a second). But this created the old issue of lines not being smooth continous anymore. If the system only "erases" the part around you once in a while, then there will be _gaps_ in your erasing. And the faster you move, the bigger those gaps.

* So I made your drawing update speed **depend on your speed**. The faster you go, the more quickly it refreshes.
* This saves a lot of performance without getting those gaps. Because slower players only need to update ~10 times a second for a smooth line!
* On top of that, I simply changed the game design to never make players move that quickly. Lower the overall speed, set maximum bounds, etc.

**Trick #3:** Similarly, I only actually `draw()` stuff if you've moved sufficiently far from your previous position. With a gap of ~5 pixels, this is not noticeable, while it saves hundreds of drawing operations per movement from side to side. (As expected, it already did not draw anything when you're _not moving_---just stuck to the side of the map shape and aiming.)

**Trick #4**: I considered batching draw calls. That is, when you say `draw()`, the texture merely _registers_ that you wanted to draw somewhere. Once in a while (a few times per second), it finally executes _all the commands it has registered_. This has the advantage of ...

* Making it predictable---I control the one moment I do this expensive operation each time.
* Making it much faster if I don't allow any duplicate draw calls. (No use if three players close to each other all want to erase the same cell.)

In the end, however, this created some issues with a noticeable delay, while not getting enough performance benefits because players are generally _not_ affecting the same parts of the map. So I scrapped this.

The performance of the erasing (per player) is now on the same level as any other element in the game. This means it's negligible, not a concern anymore. When there's a big explosion (from that powerup), the cost of that one draw call is `~1.5ms`. This might cause lag if there are 5+ explosions going on at once, but I don't think that's a very common occurrence. (Even so, I could look into that later _if it is a problem_.)

## Improving the Game Design (Non-Technical)

Alright. We have a shape, we have players moving around inside (using a single button), and the map is erased by your movement until you win.

This is ... fine, but not really a game yet. You'll always win if you just keep trying hard enough. There's not much (varied) challenge beyond just vaguely aiming where most of the "dirt" is left.

How does it become a proper game?

### Add a way to lose

I considered a **time limit** and **losing all your lives**. 

In the end, time just does not mean much to kids yet (they can't read clocks, they can't count yet, their brains are literally too in the moment, etcetera). It's also hard to balance this when you can play with any number of players, and they can even drop in/out. 

I chose to give players **lives**.

* A bunch of big hearts on the screen are easy to understand and work with.
* I can simply _add one/remove one_ for _more/fewer players_.
* It feels less stressful, even though it's just as hard.

### Add reasons to pick different paths

As I said, now there's no reason to pick one path over another. Any path that cleans up some stuff is _fine_!

How do we change that?

By adding **powerups** on the map. Now you have a reason to pick a path because you want _that powerup_. They do obvious, simple things:

* Increase/decrease your brush size
* Increase/decrease your speed
* Explode (this can be good---erase in a big circle---or bad---paint the texture again in a big circle)
* Add/remove hearts

As explained in the technical part, I know what points are _inside_ the map shape. Powerups are only placed there, of course, otherwise players could never reach it.

An important part of why I like "powerup"-type elements in my games is that they are _not overwhelming_. You can completely ignore them if you want. You can just stay out of their way. Or you can bump into one and just ... see what happens. There are no rules to learn, nothing you _must_ understand first, so they add variety without learning complexity. (And it's rather easy to just add a toggle in the settings to turn the entire system off ...)

I did end up adding _moving_ powerups too. They simply start off-screen and then move in a straight line to their point, so they'll always _pass through_ the map. You always have a _chance_ to grab it if you want. 

As I played with this system more, I realized just how powerful my idea of "the map is a basic shape; players are locked inside" is! By constricting the play area in this way, moving powerups suddenly become very interesting because you only have a brief window to grab them. I'll probably make some more games with this kind of map in the future ...

### Add progression (and invididuality)

The second reason games feel stale is when there is no progression. When after playing for 2 minutes you mostly feel like you were in the same state as before, with the same options.

Sure, the _cleaning_ provides clear visual progression, but, well, people are addicted to progression and you can never have enough!

And so,

* You start **very small and slow**
* The more you **erase**, the **bigger and faster you get**.

This is individual. By playing, soon enough, different players will be different sizes and speeds. It's a way for players to still progress _individually_, instead of only working on the group goal of cleaning. A way to always have a goal and feel valued in a match. 

Because now, for example, if you play with 4 players and one was able to get quite large, you can start assigning tasks and collaborating. The big player goes off to that faraway chunk to clean up a lot at once!

Another way to have individual worth is to focus on **each player being a different shape**.

* Your shape determines how you erase stuff, which can make a difference, but not _that_ much or the game breaks.
* Instead, powerups _have a shape too_. Which gave me several different rules to try:
  * Any powerup with _your shape_ is GOOD for you.
  * OR: only _you_ can grab good powerups with your shape.
  * OR: only _you_ can grab powerups with your shape, good or bad.

In the end, rule XX was the most fun (@TODO: Test and write result) and easiest to understand.

Now different players are the _only_ ones who can grab specific powerups, who can do specific actions, and it gives this nice balance between cooperative and individual play.

I also want to remark how important this _cooperation_ is. Social skills and collaborative skills are much too undervalued in education. But _talking_ while playing this game _requires_ naming shapes. It requires calling out the right names such that others know what to do. ("There's a square powerup! You must grab it, Sarah!") This is much much more effective for teaching this and reinforcing it until kids will never forget ... and they're just having fun playing this game.

### Add interaction

The final reason games don't feel like games is because they forget about the most important advantage: _interaction_. Not just with systems in the game and elements like powerups, but also _other players_ of course.

So ...

> When players **bump into each other**, it causes a **paint explosion**! 

This is _bad_, of course. So communicate where you're going; you can't change directory while moving/erasing.

I did consider letting your button do ... something while you're moving. It seemed a waste to not do that, but it also didn't seem necessary?

So I added an _optional_ feature if you think your players are ready.

> While moving, you can _hold_ your button to **change your shape**. (From triangle -> square -> pentagon -> etcetera.)




### Theme & Visuals

Sometimes theme and visuals come first; I'll have a mockup of what the final game _should look like_ before even testing if my idea functions.

This time, as the devlog illustrates, it was all about code and smart algorithms first. As such, I basically had a working game using gray squares and blobs ... and had to find a theme now. Something that appeals to kids. Something that makes it "make sense" that you're cleaning.

This is especially important in educational games. Because the theme is basically your second chance at adding educational value. Something _else_ from the real world to show kids, such as ...

> Cleaning up waste! (Plastic ocean kind of thing.)

I added a blue background to the texture. So, as you erase, the clear water comes through more and more. 

* The bad powerups are all "waste".
* The good powerups are all nature, plants, fishes, etcetera => they _only appear in parts you've cleaned up_!

This was like a final piece of the puzzle I had to figure out. Something felt off about good and bad powerups randomly spawning, right from the start until the end. It makes much more thematic sense to only "allow" good powerups when you've cleaned the water and life can thrive there again.







@TODO