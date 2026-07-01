---
name: scroll-story
description: "Scroll-driven storytelling — sticky sections, horizontal pan, parallax, sequence reveals, scroll progress"
triggers:
  - "scroll storytelling"
  - "scroll animation"
  - "sticky sections"
  - "horizontal scroll"
  - "parallax"
  - "scroll-driven"
---

# Scroll Story — Scroll-Driven Experiences

## When to Invoke

Use when building pages where scroll IS the interaction — product launches, case studies, landing pages with narrative flow, portfolio pieces, data stories.

## Pattern Library

### 1. Sticky Stack (cards pin and layer)

Cards pin to the top of the viewport and stack as user scrolls. Later cards slide over earlier ones.

**When to use:** Feature breakdowns, step-by-step processes, comparison sections.

```tsx
"use client"
import { useRef, useEffect } from "react"
import { gsap } from "gsap"
import { ScrollTrigger } from "gsap/ScrollTrigger"
import { useReducedMotion } from "motion/react"

gsap.registerPlugin(ScrollTrigger)

export function StickyStack({ cards }: { cards: React.ReactNode[] }) {
  const ref = useRef<HTMLDivElement>(null)
  const reduce = useReducedMotion()

  useEffect(() => {
    if (reduce || !ref.current) return
    const ctx = gsap.context(() => {
      const els = gsap.utils.toArray<HTMLElement>(".stack-card")
      els.forEach((card, i) => {
        if (i === els.length - 1) return
        ScrollTrigger.create({
          trigger: card,
          start: "top top",
          endTrigger: els[els.length - 1],
          end: "top top",
          pin: true,
          pinSpacing: false,
        })
        gsap.to(card, {
          scale: 0.92,
          opacity: 0.5,
          ease: "none",
          scrollTrigger: {
            trigger: els[i + 1],
            start: "top bottom",
            end: "top top",
            scrub: true,
          },
        })
      })
    }, ref)
    return () => ctx.revert()
  }, [reduce])

  return (
    <div ref={ref}>
      {cards.map((card, i) => (
        <div key={i} className="stack-card sticky top-0 min-h-[100dvh] flex items-center justify-center">
          {card}
        </div>
      ))}
    </div>
  )
}
```

### 2. Horizontal Pan (vertical scroll → horizontal movement)

Section pins, content slides horizontally as user scrolls vertically.

**When to use:** Galleries, timelines, wide comparisons, product showcases.

```tsx
"use client"
import { useRef, useEffect } from "react"
import { gsap } from "gsap"
import { ScrollTrigger } from "gsap/ScrollTrigger"
import { useReducedMotion } from "motion/react"

gsap.registerPlugin(ScrollTrigger)

export function HorizontalPan({ children }: { children: React.ReactNode }) {
  const wrap = useRef<HTMLDivElement>(null)
  const track = useRef<HTMLDivElement>(null)
  const reduce = useReducedMotion()

  useEffect(() => {
    if (reduce || !wrap.current || !track.current) return
    const ctx = gsap.context(() => {
      const dist = track.current!.scrollWidth - window.innerWidth
      gsap.to(track.current, {
        x: -dist,
        ease: "none",
        scrollTrigger: {
          trigger: wrap.current,
          start: "top top",
          end: () => `+=${dist}`,
          pin: true,
          scrub: 1,
          invalidateOnRefresh: true,
        },
      })
    }, wrap)
    return () => ctx.revert()
  }, [reduce])

  return (
    <section ref={wrap} className="overflow-hidden">
      <div ref={track} className="flex h-[100dvh] items-center gap-8">
        {children}
      </div>
    </section>
  )
}
```

### 3. Parallax Layers (elements move at different speeds)

**When to use:** Hero backgrounds, depth effects, subtle visual richness.

```tsx
"use client"
import { motion, useScroll, useTransform } from "motion/react"
import { useRef } from "react"

export function ParallaxHero() {
  const ref = useRef(null)
  const { scrollYProgress } = useScroll({ target: ref, offset: ["start start", "end start"] })
  const bgY = useTransform(scrollYProgress, [0, 1], ["0%", "30%"])
  const textY = useTransform(scrollYProgress, [0, 1], ["0%", "50%"])
  const opacity = useTransform(scrollYProgress, [0, 0.8], [1, 0])

  return (
    <section ref={ref} className="relative h-[100dvh] overflow-hidden">
      <motion.div style={{ y: bgY }} className="absolute inset-0">
        <img src="/hero-bg.jpg" className="w-full h-full object-cover" alt="" />
      </motion.div>
      <motion.div style={{ y: textY, opacity }} className="relative z-10 flex items-center justify-center h-full">
        <h1>Your headline</h1>
      </motion.div>
    </section>
  )
}
```

### 4. Progress Reveal (text/elements reveal as you scroll through)

**When to use:** Long-form content, manifestos, data reveals.

```tsx
"use client"
import { motion, useScroll, useTransform } from "motion/react"
import { useRef } from "react"

export function TextReveal({ text }: { text: string }) {
  const ref = useRef(null)
  const { scrollYProgress } = useScroll({ target: ref, offset: ["start 80%", "end 40%"] })
  const words = text.split(" ")

  return (
    <p ref={ref} className="text-4xl leading-relaxed">
      {words.map((word, i) => {
        const start = i / words.length
        const end = start + 1 / words.length
        return <Word key={i} word={word} range={[start, end]} progress={scrollYProgress} />
      })}
    </p>
  )
}

function Word({ word, range, progress }) {
  const opacity = useTransform(progress, range, [0.2, 1])
  return <motion.span style={{ opacity }} className="inline-block mr-2">{word}</motion.span>
}
```

### 5. Scroll Progress Bar

```tsx
"use client"
import { motion, useScroll } from "motion/react"

export function ScrollProgress() {
  const { scrollYProgress } = useScroll()
  return (
    <motion.div
      style={{ scaleX: scrollYProgress, transformOrigin: "left" }}
      className="fixed top-0 left-0 right-0 h-1 bg-accent z-50"
    />
  )
}
```

### 6. Scroll-Snap Sections (CSS-native)

**When to use:** Full-screen section-by-section navigation without GSAP overhead.

```css
.scroll-container {
  scroll-snap-type: y mandatory;
  overflow-y: scroll;
  height: 100dvh;
}
.scroll-section {
  scroll-snap-align: start;
  height: 100dvh;
}
```

## Choosing the Right Pattern

| Effect | Pattern | Library |
|--------|---------|---------|
| Elements appear on scroll | Scroll-reveal stagger | Motion `whileInView` |
| Section pins while content animates | Sticky stack / Horizontal pan | GSAP ScrollTrigger |
| Background moves slower than foreground | Parallax layers | Motion `useScroll` + `useTransform` |
| Text highlights word-by-word | Progress reveal | Motion `useScroll` + `useTransform` |
| Full-screen sections snap | Scroll-snap | CSS native |
| Progress indicator | Scroll progress bar | Motion `useScroll` |
| Video/3D tied to scroll position | Sequence scroll | GSAP or CSS `animation-timeline` |

## Performance Checklist

- [ ] `start: "top top"` for pins (not "top center" — causes jump)
- [ ] `scrub: 1` (smooth) or `scrub: true` (instant catch-up)
- [ ] `invalidateOnRefresh: true` for responsive resize
- [ ] `useEffect` cleanup: `return () => ctx.revert()`
- [ ] No `window.addEventListener('scroll')` anywhere
- [ ] Test on mobile (touch scroll is different from wheel scroll)
- [ ] Reduced motion fallback (show all content, no scroll-driven hide)

## Reduced Motion Fallback

When `prefers-reduced-motion: reduce`:
- Show all content immediately (no scroll-gated reveals)
- Remove parallax (elements stay in normal flow)
- Remove pinning (sections scroll naturally)
- Keep progress indicators (they're informational, not decorative)
