# elm-supervirus

## About:

Best Port. Only Port.
Cheggit - [Supervirus](http://samgqroberts.com/sylverstudios/games/supervirus/)


The original was having some keyboard issues, so this is intended to relieve that pain by completely rewriting the entire project.

Makin' gaimz.

## Try it

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



## Planning

### ~~Phase 1: Playable~~

  <details>

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
  * ~~Play tests (private beta (add email address) Sam, RJ, Pete, Dave)~~

  </details>


### Phase 2: "Playtest"-able

Prioritized
 * ~~Restart keybind - 1 hr~~
 * ~~Scoring (combo tracking) - 6hrs~~
  * ~~Score tracking from eating~~
  * ~~Metabolism (combo)~~
  * ~~Metabolism indicator (visual, not just words)~~
 * Add google analytics - 1 hr
 * Scenes
  * Lobby (controls & scoring) - 2hrs
  * GameOver (stats n' restart) - 1 hr
 * Layout
  * AgStudios logo - 1 hr
  * Github Link - 1 hr
  * Favicon - 2 hrs
  * Title - 2 hrs
 * Win condition - 1 hr


 Unpriotized
 * Allow pause
 * Remove redundant BoundaryConflict type
 * General Math2D tidyness
 * Add netlify webhook to github (unprioritized)
 * Apply delta to movement, instead of just tick size 1
 * Streamline speed / size / display (UI work)
   * Improve Images (specifically enemy overlap)
   * Create some sprites for Virus vs. Npc
   * Viewport?
   * (NTH) Battle scar concept
   * (NTH) Save the last play position and display it on the game over screen.
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

 #### Complete
 *


### Phase 3
DreamTime.

* Different types of virus
  * styles and powers
  * diffusion type
* css transitions and/or animations outside of the game
* Other keys can do other things
