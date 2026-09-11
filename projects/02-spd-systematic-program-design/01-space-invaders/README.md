# Space Invaders

A fully playable **Space Invaders** game built in **ISL (Intermediate Student Language)** using DrRacket's `big-bang` library, as part of the **Systematic Program Design** course.

## How to Play

Open `space-invaders.rkt` in DrRacket and run:

```racket
(main (make-game empty empty T0))
```

| Key     | Action          |
| ------- | --------------- |
| `→`     | Move tank right |
| `←`     | Move tank left  |
| `Space` | Fire missile    |

Invaders spawn randomly from the top and move diagonally across the screen. Shoot them before they reach the ground. If an invader reaches the bottom, the game is over.

## Concepts

| Concept                     | Used in                                            |
| --------------------------- | -------------------------------------------------- |
| How to Design Worlds (HtDW) | `main`, `next-game`, `render-game`, `handle-game`  |
| Compound data               | `Game`, `Invader`, `Missile`, `Tank`               |
| Self-referential data       | `ListOfInvader`, `ListOfMissile`                   |
| Function composition        | `render-war`                                       |
| Recursive list processing   | Movement, rendering, collision detection           |
| Helper functions            | `hit?`, `hitground?`, `offscreen?`, `handle-cases` |
| Event handling              | Keyboard input and clock ticks                     |

## Game Structure

```text
Game
├── ListOfInvader → Invader (x, y, dx)
├── ListOfMissile → Missile (x, y)
└── Tank          → Tank (x, dir)
```

Each game tick:

1. Invaders move, bounce off the walls, and may spawn.
2. Missiles move upward and are removed when they leave the screen.
3. The tank responds to keyboard input.
4. Collisions remove missiles and invaders.
5. The game ends when an invader reaches the ground.

## Course

[Systematic Program Design](https://www.edx.org/learn/coding/university-of-british-columbia-how-to-code-simple-data) — University of British Columbia (via edX)

Part of my [OSSU Computer Science](https://github.com/ossu/computer-science) journey.

