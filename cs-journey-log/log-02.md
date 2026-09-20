# Log 02
**Date: Saturday, September 20, 2026**

---

## Finishing SPD

This week I completed the final three modules of Systematic Program Design: 09b-Search, 10-Accumulators, and 11-Graphs.

**Search** was the hardest module of the entire course. I understood the concepts — generative recursion, backtracking, the arbitrary-arity tree pattern — but when it came to hard problems like Sudoku, N-Queens, and the Triangle Peg Solitaire, my data definitions were too complex. That complexity made my code messy and hard to reason about. I learned something important: if your data is wrong, no amount of clever logic will save you. The function just enforces the structure — the data IS the constraint.

On the struggle time: in Log 1 I promised myself to stop losing entire days to one problem. I adjusted that to something more realistic — follow the time the course itself recommends for each problem. Some problems are meant to take more than an hour, others less. That boundary helped me stay moving instead of getting stuck.

**Accumulators** was a different kind of hard. Less about the problem, more about the mental model. The key insight I took from it is how to read code as separate parts rather than one big block: the structural recursion template, the local wrapper with trampoline, and the accumulator parameter — three distinct pieces. Once I could see those separately, the whole module became much cleaner. The worklist pattern was the most interesting part — flattening recursion into a queue doesn't remove the implicit state, it just makes it explicit. You become responsible for carrying what the call stack used to carry for free.

**Graphs** felt like the natural end of the course. Everything I learned — mutual recursion, worklists, context-preserving accumulators, backtracking — all blended into one template. The new idea was `shared`, a construct in Advanced Student Language for building cyclic data that ISL can't express. And the key rule for graphs: use a `visited` accumulator to prevent infinite loops in cycles. The deeper lesson that tied it together:

> *The skill in complex problems is recognizing which template blend is needed and designing that structure before writing logic.*

---

## What Finishing SPD Means

I can say this is the best thing I've done in years.

Not because the course was easy — it wasn't. But because it changed how I think about programming. Before SPD, I thought programming was about writing code. Now I understand it's about designing before you type anything. Data definitions drive function design. The structure of information becomes the structure of code. Templates are not just boilerplate — they are models of what the code will look like before you know the details.

I can't claim I understand everything 100%. There are still things I need more practice on — complex data definitions, knowing instinctively which accumulator pattern a problem needs, reading someone else's recursive code quickly. That's normal and expected after a first pass through a course this dense.

---

## The Next 10 Days

Before October and before the next course, I'm spending 10 days on review:

- Hard SPD problems I struggled with — rework them cleanly
- The SPD final project
- Python — I haven't touched it seriously in months. That changes now. The goal is to build the Monte Carlo Simulation project I've been planning, and make sure Python fundamentals are solid before I move forward.

Python wasn't neglected on purpose — SPD just required full focus. But now both courses get their due.

---

*Next entry: after the 10-day review.*
