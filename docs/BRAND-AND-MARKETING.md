# Browser Toast — Brand Identity, Marketing Strategy & Website Plan

## Brand Persona

If Browser Toast were a person, it would be the senior engineer at the coffee shop who has strong opinions about tools but never brings them up unprompted. Calm. Competent. Minimal setup, maximum output. The kind of person who has three sentences where others need three paragraphs — and every sentence lands.

Browser Toast doesn't try to impress you. It just works, and you notice the absence of friction more than the presence of a product. Warm, reliable, and ready exactly when you need it — like a perfect piece of toast.

### Character Traits

| Trait | Expression |
| --- | --- |
| **Quiet confidence** | Never oversells. States what it does. Lets you decide. |
| **Respectful of attention** | No onboarding wizard, no tooltip tour, no "what's new" popup. You click, it works. |
| **Opinionated simplicity** | One way to do things, and it's the right way. No preferences panel with 40 toggles. |
| **Craftsmanship over features** | Every pixel considered. Signed, notarized, zero dependencies. The details you don't see are the ones that matter most. |
| **Generous** | Free, open source, no tracking. Gives more than it asks. |

### Brand Archetype

**The Sage** meets **The Craftsman.**

The Sage knows the right answer and delivers it without ego. The Craftsman obsesses over the quality of the work itself, not the recognition. Browser Toast combines both: it knows exactly what you need (your default browser changed, now) and delivers it with invisible precision — every time, perfectly toasted.

### If Browser Toast Were...

| Prompt | Answer |
| --- | --- |
| A car | A matte black Porsche 911 — no spoiler, no decals, just engineering |
| A font | Helvetica Neue Light — clean, confident, everywhere and nowhere |
| A material | Brushed aluminum — premium, tactile, ages well |
| A sound | A toaster popping — satisfying, crisp, done |
| An appliance | A Dualit toaster — industrial, beautiful, does one thing flawlessly |
| A place | A Japanese tool shop — everything has one purpose, nothing is extra |

---

## Brand Identity

### Name

**Browser Toast**

"Toast" captures the action: quick, crisp, done. You put something in, it comes out exactly how you want it. The name works because it's unexpected in tech — warm, tactile, human — while being instantly searchable with zero noise in results. It's a name that works as a product and as a verb — "just toast it to Firefox."

### Positioning Statement

Browser Toast is the macOS menu bar utility that sets your default browser in one click. No settings panels, no configuration files, no friction. It's the warm, reliable shortcut between your links and your browsers that you forget is there — until you use someone else's Mac and miss it.

### Tagline

**"Managing browsers is as simple as making toast."**

Alternatives for different contexts:

| Context | Tagline |
| --- | --- |
| Hero / primary | Managing browsers is as simple as making toast. |
| Short / badge | Click. Toast. Browse. |
| Action | Toast your browser. |
| Technical | Your default browser, one click from the menu bar. |
| Conversational | Stop digging through System Settings. |
| Emotional | The menu bar shortcut macOS forgot. |
| Playful | Every browser, toasted just right. |

### Brand Pillars

| Pillar | What it means | How it shows up |
| --- | --- | --- |
| **Effortless** | The core promise is removal of friction. | One click. No config. No onboarding. |
| **Native** | It should feel like Apple built it. | Pure AppKit. SF Symbols. Semantic colors. Signed and notarized. |
| **Invisible** | The best utility is one you forget about. | Menu bar only. No Dock icon. No windows. Silent launch. |
| **Honest** | No dark patterns, no data collection, no upsells. | Open source. MIT license. "No tracking" as a feature. |
| **Deep** | Simple surface, powerful underneath. | Option-key power tools. Network context. Caffeine mode. |

---

## Brand Voice

### Principles

1. **Lead with the verb.** Don't describe what the app is. Describe what it does. "Change your default browser" not "a utility for managing browser preferences."

2. **One sentence beats two.** If a feature can be explained in six words, use six words. Respect the reader's time the way the app respects the user's attention.

3. **Confident, not clever.** No puns beyond the name itself. No startup-speak ("leverage," "empower," "revolutionize"). Say what you mean.

4. **Technical when it helps.** "Pure AppKit, zero dependencies" means something to the target audience. Don't dumb it down. But don't gatekeep either — keep the primary message accessible.

5. **Warm in small doses.** The origin story can be personal ("I got tired of..."). Feature descriptions are factual. The tone shifts based on context, but never gets corporate. The "toast" metaphor adds warmth without forcing it.

### Voice Examples

| Context | Do | Don't |
| --- | --- | --- |
| Feature description | "See your IP, ISP, and VPN status in the menu." | "Browser Toast's integrated network intelligence dashboard provides real-time visibility into your connection metadata." |
| Error message | "Couldn't change the default browser. macOS may need permission." | "Oops! Something went wrong. Please try again later." |
| README intro | "Browser Toast changes your default browser from the menu bar." | "Welcome to Browser Toast! We're so excited to help you manage your browsing experience." |
| Social post | "I switch between 4 browsers a day. This keeps it sane." | "Excited to announce our groundbreaking new utility!" |
| About panel | "Browser Toast 1.0 — by Adam Abernathy" | "Thank you for choosing Browser Toast! We hope you love it!" |

### Writing Checklist

Before publishing any copy, check:

- [ ] Can I cut a sentence without losing meaning? Cut it.
- [ ] Am I describing the product or the experience? Prefer the experience.
- [ ] Would I say this out loud to a colleague? If not, rewrite.
- [ ] Is the first word a verb or a noun? Prefer verbs.
- [ ] Does this sound like Apple's copywriting? Good. Does it sound like a SaaS landing page? Rewrite.

---

## Visual Identity

### Color Palette

The app itself uses only semantic `NSColor` — no brand colors touch the UI. The palette below is for marketing, the website, and social assets only.

**Core palette:**

| Role | Name | Light | Dark | Usage |
| --- | --- | --- | --- | --- |
| Text | Ink | `#1D1D1F` | `#F5F5F7` | Headlines, body copy |
| Text secondary | Smoke | `#86868B` | `#86868B` | Captions, metadata |
| Accent | Crisp | `#E85D2A` | `#FF7A45` | CTAs, links, the "toast" highlight |
| Surface | Paper | `#FBFBFD` | `#141414` | Page backgrounds |
| Card | Pane | `#FFFFFF` | `#1C1C1E` | Elevated surfaces |
| Border | Mist | `rgba(0,0,0,0.06)` | `rgba(255,255,255,0.08)` | Dividers, card edges |
| Success | Current | `#34C759` | `#30D158` | Active browser indicator |

**Why "Crisp" for the accent:** A warm amber-orange — the color of perfectly toasted bread. It signals warmth, readiness, and the moment something is done. It's distinctive in a sea of blue-accented developer tools.

> [!TIP]
> The accent color should only appear on interactive elements and the "selected" state. Overusing it dilutes its meaning. When in doubt, use Ink.

### Typography

| Role | Font | Weight | Size Range | Fallback |
| --- | --- | --- | --- | --- |
| Display | SF Pro Display | Semibold | 36–64px | -apple-system, system-ui, sans-serif |
| Headline | SF Pro Display | Medium | 24–32px | -apple-system, system-ui, sans-serif |
| Body | SF Pro Text | Regular | 16–18px | -apple-system, system-ui, sans-serif |
| Caption | SF Pro Text | Regular | 13–14px | -apple-system, system-ui, sans-serif |
| Code | SF Mono | Regular | 14–16px | ui-monospace, 'Cascadia Code', monospace |

**Tracking:** Headlines at -0.01em. Body at default. Never track body copy wider than default — it breaks reading rhythm.

### Iconography

- **SF Symbols only.** No custom icon set, no raster icons, no icon fonts.
- **Monochrome default.** Color only when it conveys state (green = active, amber = interactive).
- **16x16 in menus.** 20x20 in feature cards on the website. Always set `accessibilityDescription`.
- **Weight: medium.** Matches SF Pro Text regular in optical weight.

### The Toast Mark

The app icon is a custom-drawn glyph inside a squircle — a stylized toaster slot with a browser emerging, or alternatively, the existing flow-branch routing mark that represents URLs routing to the right browser:

```
                         o   <-- outlined (other browser)
                      /
             /------
   * =============== *      <-- bold, filled (selected browser)
             \------
                      \
                         o   <-- outlined (other browser)
```

**Properties:**
- 512x512 squircle, corner radius 96
- `windowBackgroundColor` background (adapts to light/dark)
- `labelColor` for all glyph elements (adapts to light/dark)
- Source node (left): filled circle, r=14
- Selected destination (center-right): filled circle, r=18, connected by bold 7.5pt line
- Other destinations (top/bottom-right): outlined circles, r=13, connected by 5.5pt bezier curves at 40% opacity
- S-curves use cubic beziers with matched control points for smooth routing

**Lockup options:**

```
[Icon]  Browser Toast                   <-- Horizontal lockup (primary)

        [Icon]
    Browser Toast                       <-- Stacked lockup (social, favicon)
```

**Wordmark:** "Browser Toast" in SF Pro Display Semibold, tracked at -0.01em. "Browser" in Ink, "Toast" in Accent (Crisp amber) — the only place the name gets color treatment.

### Photography & Imagery Style

No stock photography. The brand is purely typographic and diagrammatic.

- **Screenshots:** Always framed in macOS window chrome. Light and dark variants.
- **Diagrams:** Use the routing visual language. Lines that branch and converge. Dots as nodes.
- **Backgrounds:** Subtle warm-toned mesh gradients — never flat color, never busy.
- **Motion:** If animated, use ease-in-out curves. No bouncing, no spring physics. Smooth and satisfying — like a toaster popping.

---

## Target Audience

### Primary: Mac developers and power users

- Use 2–4 browsers daily (Safari for personal, Chrome for dev tools, Firefox for testing, Arc for focused work)
- Comfortable with the terminal but appreciate good GUI tools
- Value tools that respect system conventions and feel native
- Annoyed by the System Settings detour to switch defaults
- **Where they are:** Hacker News, r/macapps, Mastodon (#macdev), Mac newsletters, GitHub trending

### Secondary: Presenters and screen-sharers

- Need to quickly hide desktop icons, toggle Stage Manager, keep the screen awake
- The Option-key power tools are a strong differentiator for this group
- **Where they are:** r/macOS, YouTube (productivity channels), Product Hunt

### Tertiary: QA and testing professionals

- Switch between browsers constantly for cross-browser testing
- Need the checkmark indicator to confirm which browser is currently default
- **Where they are:** r/webdev, r/QualityAssurance, testing-focused Slack communities

---

## Marketing Strategy

### Phase 1 — Foundation (Pre-Launch / v1.0)

**Goal:** Establish presence and build credibility before any promotion.

| Action | Channel | Details |
| --- | --- | --- |
| Polish the GitHub README | GitHub | The README is the real landing page. Add a hero GIF showing a browser change in action. |
| Ship the landing page | Web | Single-page site at `browsertoast.com` (see Website section). |
| Write the origin story | Dev.to / blog | "Why I built Browser Toast" — relatable frustration, simple solution. |
| Submit to directories | Directories | macapps.link, opensourcemac.org, awesome-macos on GitHub. |
| Create a Homebrew cask | Homebrew | `brew install --cask browser-toast` — the developer's expected install path. |

### Phase 2 — Launch (v1.0 Release)

**Goal:** Generate awareness in developer communities.

| Action | Channel | Details |
| --- | --- | --- |
| Show HN | Hacker News | "Show HN: Browser Toast — change your default macOS browser from the menu bar." Factual, short. |
| Reddit posts | r/macapps, r/macOS, r/webdev | Short post with GIF, link to site, one-liner install. |
| Product Hunt launch | Product Hunt | Tuesday launch. 5 screenshots, 30s GIF, maker comment with the origin story. |
| Social threads | X, Mastodon, Bluesky | "I switch between 4 browsers every day. macOS makes this annoying. So I built a menu bar app." Thread with GIF. |
| Indie Mac community | Mastodon | Tag #macdev, #swiftlang, #indiedev. The Mac indie dev scene is strong here. |

### Phase 3 — Growth (Post-Launch)

**Goal:** Sustain organic discovery.

| Action | Channel | Details |
| --- | --- | --- |
| SEO articles | Blog / Website | "How to change default browser on Mac" — target the search query directly. |
| Mac newsletters | Email outreach | Mac Power Users, Club MacStories, iOS Dev Weekly, Swift Weekly Brief. |
| YouTube demo | YouTube | 60–90 second screencast. No intro, no subscribe prompt. Just the product. |
| Changelog updates | GitHub + Site | Every release gets a changelog entry. Keep the community engaged. |
| GitHub Sponsors | GitHub | Add a Sponsor button. Let people support the work. |

---

## Website Plan

### URL

`browsertoast.com` (preferred) or `getbrowsertoast.com`

### Structure

Single-page marketing site. Fast, native-feeling, converts visitors to installers.

### Page Sections

#### 1. Hero

```
[Toast Mark Icon]

Browser Toast
Managing browsers is as simple as making toast.

A macOS menu bar utility that changes your default
browser in one click. Free and open source.

  [ Download for Mac ]    [ View on GitHub ]

Requires macOS 14 (Sonoma) or later.
```

- Centered layout, generous whitespace
- Subtle warm mesh gradient background (CSS only, no JS)
- Download links to latest GitHub Release `.zip`
- "View on GitHub" as secondary outline button

#### 2. Demo

- Looping `<video>` (muted, autoplay, no controls) showing the full flow:
  1. Click menu bar icon
  2. See browser list with checkmark
  3. Click a different browser
  4. Checkmark moves — done
- Framed in macOS menu bar chrome mockup
- Caption: "One click. Perfectly toasted."

#### 3. Features

2x3 card grid. Each card: SF Symbol icon, title, one sentence.

| Icon | Title | Copy |
| --- | --- | --- |
| `checkmark.circle` | One-Click Switching | Change your default browser without opening System Settings. |
| `magnifyingglass` | Auto-Discovery | Finds every browser on your Mac. Zero configuration. |
| `network` | Network Context | Your IP, ISP, and VPN status — right in the menu. |
| `cup.and.saucer` | Caffeine Mode | Keep the display awake during demos and presentations. |
| `eye.slash` | Hide Desktop Icons | Clean desktop before screen sharing, one toggle. |
| `option` | Power Tools | Hold Option for Stage Manager controls and more. |

#### 4. Install

Three-tab switcher:

**One-Liner (Recommended)**
```bash
curl -fsSL https://raw.githubusercontent.com/adamabernathy/default-browser/main/scripts/install.sh | bash
```

**Download**
Direct `.zip` from GitHub Releases.

**Homebrew** *(coming soon)*
```bash
brew install --cask browser-toast
```

#### 5. Before & After

| Without Browser Toast | With Browser Toast |
| --- | --- |
| Open System Settings | Click the menu bar icon |
| Navigate to Desktop & Dock | Pick a browser |
| Scroll to Default web browser | Done |
| Select from dropdown | |
| Close System Settings | |

Caption: "Five steps become one."

#### 6. Open Source

> Browser Toast is MIT-licensed and open source.
> Built with pure AppKit. Zero dependencies. Signed and notarized.

GitHub stars badge. Build status badge. Link to repo.

#### 7. Footer

- Made by Adam Abernathy
- GitHub · MIT License
- "No tracking. No analytics. No telemetry."

### Design System for the Site

```css
:root {
  --color-ink: #1D1D1F;
  --color-smoke: #86868B;
  --color-crisp: #E85D2A;
  --color-paper: #FBFBFD;
  --color-pane: #FFFFFF;
  --color-mist: rgba(0, 0, 0, 0.06);
  --font-display: -apple-system, BlinkMacSystemFont, 'SF Pro Display', system-ui, sans-serif;
  --font-body: -apple-system, BlinkMacSystemFont, 'SF Pro Text', system-ui, sans-serif;
  --font-mono: 'SF Mono', ui-monospace, 'Cascadia Code', monospace;
  --radius: 12px;
  --transition: 200ms ease-in-out;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-ink: #F5F5F7;
    --color-smoke: #86868B;
    --color-crisp: #FF7A45;
    --color-paper: #141414;
    --color-pane: #1C1C1E;
    --color-mist: rgba(255, 255, 255, 0.08);
  }
}
```

### Site Principles

1. **Feels like macOS.** System fonts, subtle blur, semantic-feeling colors.
2. **Dark mode native.** `prefers-color-scheme`. No toggle — respect the system.
3. **Fast.** Static HTML + CSS. No frameworks. Only JS for the install tab switcher.
4. **Responsive.** Mac-only app, but people discover on phones.
5. **Accessible.** Semantic HTML, proper headings, alt text, 4.5:1 contrast.
6. **No tracking.** Practice what you preach.

---

## Content Calendar (First 30 Days)

| Day | Action | Channel |
| --- | --- | --- |
| -7 | Publish "Why I built Browser Toast" | Dev.to / blog |
| -3 | Submit to macapps.link, opensourcemac.org | Directories |
| 0 | Ship v1.0. Publish site. Post Show HN. | GitHub, Web, HN |
| 0 | Post to r/macapps, r/macOS | Reddit |
| 1 | Launch on Product Hunt | Product Hunt |
| 1 | Social threads (X, Mastodon, Bluesky) | Social |
| 3 | Respond to all community comments | HN, Reddit, PH |
| 7 | Publish YouTube demo | YouTube |
| 14 | Reach out to Mac newsletter editors | Email |
| 21 | SEO article: "How to change default browser on Mac" | Blog / Site |
| 30 | v1.1 release with changelog | GitHub, Site, Social |

---

## Competitive Landscape

| Tool | Type | How Browser Toast is different |
| --- | --- | --- |
| System Settings | Built-in | 1 click vs. 5 steps |
| Browserosaurus | Open source | Browserosaurus intercepts every link. Browser Toast changes the *default* — simpler model. |
| Choosy | Paid ($10) | Browser Toast is free and open source. Choosy does rule-based routing — different use case. |
| Finicky | Open source | Finicky needs a config file. Browser Toast is zero-config. |

**Browser Toast wins on simplicity.** One thing, done well, out of the way.

---

## Key Metrics

No telemetry in the app. Measure success externally:

- **GitHub stars and forks** — growth signal
- **Release download counts** — `gh api` can pull these
- **Install script hits** — raw.githubusercontent.com referrer logs
- **Website traffic** — Plausible or Fathom if privacy-respecting analytics are added later
- **Community mentions** — periodic search for "Browser Toast" on Twitter, Reddit, HN

---

## Summary

Browser Toast is a brand built on restraint and warmth. The persona is quiet, competent, and generous. The visual identity is monochrome with a single warm accent color — Crisp amber — that means "active" and "done." The voice is short, direct, and verb-first. The icon represents routing: one input, multiple paths, one clear choice.

The name is unexpected, memorable, and completely uncontested in search. It's warm where developer tools are cold, playful where utilities are sterile, and human where software is abstract.

The core message: **"Managing browsers is as simple as making toast."**
