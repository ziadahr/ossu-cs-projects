# Space Invaders

A fully playable Space Invaders game built in **ISL (Intermediate Student Language)** using DrRacket's `big-bang` library, as part of the Systematic Program Design course.

## How to Play

Open `space-invaders.rkt` in DrRacket and run `(main (make-game empty empty T0))` in the interactions area.

| Key | Action |
|---|---|
| `→` | Move tank right |
| `←` | Move tank left |
| `Space` | Fire missile |

Invaders spawn randomly from the top and move diagonally. Shoot them before they reach the ground — if any invader lands, game over.

## What It Covers

| Concept | Where |
|---|---|
| HtDW (How to Design Worlds) | `main`, `next-game`, `render-game`, `handle-game` |
| Compound data | `Game`, `Invader`, `Missile`, `Tank` — all `define-struct` |
| Self-reference | `ListOfInvader`, `ListOfMissile` |
| Reference rule + natural helpers | `render-loi` → `render-invader`, `render-lom` → `render-missile` |
| Function composition | `render-war` composes `render-loi`, `render-lom`, `render-tank` |
| Mutual list processing | `lom-hit-loi`, `loi-hit-lom` — two lists working together |
| Helper functions | `hit?`, `hitground?`, `offscreen?`, `handle-cases` |

## Structure

```
Game
├── ListOfInvader  → Invader (x, y, dx)
├── ListOfMissile  → Missile (x, y)
└── Tank           (x, dir)
```

Every tick:
1. Invaders move diagonally, bounce off walls, randomly spawn new ones
2. Missiles move upward, removed when off-screen
3. Tank moves based on key input
4. Hit detection removes colliding missiles and invaders
5. Game ends when any invader reaches the bottom

## Course

[Systematic Program Design](https://www.edx.org/learn/coding/university-of-british-columbia-how-to-code-simple-data) — University of British Columbia (via edX)

Part of my [OSSU Computer Science](https://github.com/ossu/computer-science) journey.
