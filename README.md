# elm-supervirus

## About:

Best Port. Only Port.
Cheggit - [Supervirus](http://samgqroberts.com/sylverstudios/games/supervirus/)


The original was having some keyboard issues, so this is intended to relieve that pain by completely rewriting the entire project.

Makin' gaimz.

## Status Check!

### Working stuff
 * `wsad` keys are sending messages!
 * View is displaying model!


## Planning

### Phase 1
Playable.
#### Complete
 * ~~Replace favicon & only page~~
 * ~~Collision detection~~
 * ~~Boundaries~~
 * ~~Scoring~~
 * ~~Smooth borders~~
 * ~~Enemy Movement~~
   * ~~Enemy wall bounce~~
   * ~~random in play~~
   * ~~Enemy random velocity on spawn~~
   * ~~Fuzzy test for enemy movement (within boundary, velocity stays at same abs val)~~
 * ~~Automated Enemy Spawning~~
 * ~~Apply velocity and acceleration to user~~
 * ~~Move the clock into the game.~~
   * ~~If we are in the start state or gameOver state, the clock isn't running~~
   * ~~Subscriptions only apply during Playing state~~
 * ~~Implement Slide with running velocity (tangent projection)~~
 * ~~Improve pacing (user is WAY TOO FAST)~~
 * ~~Deploy with netlify!~~

#### On Deck
 * Play tests (private beta (add email address) Sam, RJ, Pete, Dave)
 * Remove redundant BoundaryConflict type
 * General Math2D tidyness
 * Retro

### Phase 2
Enjoyable or server implementation
#### Complete
 *
#### On Deck
 * Allow pause
 * Add netlify webhook to github (unprioritized)
 * Apply delta to movement, instead of just tick size 1
 * Streamline speed / size / display (UI work)
   * Improve Images (specifically enemy overlap)
   * Create some sprites for Virus vs. Npc
   * Viewport?
   * (NTH) Battle scar concept
   * (NTH) Save the last play position and display it on the game over screen.
 * Win Condition (80% of volume?)
 * Improve scoring
 * Outside of game view
   * Layout / spacing / design
   * Supervirus2 -> 2uperVirus
   * GameOver View
 * Serve it with Heroku
   * Elixir phoenix
   * (NTH) websocket (hotreloading leaderboard on the side of the game!!!)
   * (NTH) Absinthe
   * (NTH) Leaderboard
   * (NTH) Checkout [Guardian](https://github.com/ueberauth/guardian)
 * Music
 * Sound effects
 * Release
 * ???
 * Gromit!


### Phase 3
DreamTime.

* Different types of virus
  * styles and powers
  * diffusion type
* css transitions and/or animations outside of the game
* Other keys can do other things

## Do stuff

* Just once
  * `npm install -g elm elm-format yarn`
* Whenever you change a dependency
  * `npm run prep`
* When you're working
  * `npm run start`
* Tests (from Root)
  * `elm-test`
* Build a prod version (minified)
  * `npm run deploy`
