# Browser Switch — Brand, Marketing Strategy & Website Plan

## Brand Identity

### Positioning Statement

Browser Switch is the invisible productivity tool for Mac power users who juggle multiple browsers daily. It replaces a buried System Settings panel with a single menu bar click — native, lightweight, and respectful of your attention.

### Brand Pillars

| Pillar | Description |
| --- | --- |
| **Invisible by design** | Menu bar only, no Dock icon, no windows. It stays out of the way until you need it. |
| **Native & trustworthy** | Pure AppKit, signed and notarized, zero dependencies. Feels like part of macOS. |
| **One-click simplicity** | The entire value proposition fits in three words: click, switch, done. |
| **Power when you want it** | Option-key power tools, network context, Caffeine mode — depth without clutter. |

### Brand Voice

- **Concise.** Short sentences. No fluff. Mirror the app's efficiency.
- **Confident, not loud.** State facts. Let the product speak.
- **Technical but approachable.** Developers are the primary audience, but the app is simple enough for anyone.
- **Warm, not corporate.** First person ("we built this because...") when telling the story. Direct address ("you") for benefits.

### Tagline Options

1. **"Switch browsers. Not workflows."** (recommended)
2. "Your default browser, one click away."
3. "The menu bar shortcut macOS forgot."
4. "Click. Switch. Done."

### Color Palette

Stay minimal and let macOS semantics lead. The brand palette is for marketing and the website only — the app itself uses only semantic `NSColor`.

| Role | Color | Hex | Usage |
| --- | --- | --- | --- |
| Primary | Charcoal | `#1D1D1F` | Headlines, body text |
| Accent | macOS Blue | `#007AFF` | CTAs, links, highlights |
| Surface | Snow | `#FAFAFA` | Page backgrounds (light) |
| Surface Dark | Graphite | `#161617` | Page backgrounds (dark) |
| Success | System Green | `#34C759` | Checkmark / "current browser" indicator |
| Muted | Warm Gray | `#8E8E93` | Secondary text, captions |

### Typography

| Role | Font | Fallback |
| --- | --- | --- |
| Headlines | SF Pro Display (semibold) | -apple-system, system-ui |
| Body | SF Pro Text (regular) | -apple-system, system-ui |
| Code | SF Mono | ui-monospace, monospace |

> [!NOTE]
> SF Pro is available via Apple's CDN for web use. For non-Apple platforms, fall back to the system font stack.

### Logo Concept

The app icon is already well-defined: a squircle with the SF Symbol grid/checkmark glyph. For marketing, extend this with:

- **Wordmark**: "Browser Switch" in SF Pro Display Semibold, tracked slightly loose
- **Icon + Wordmark lockup**: Icon left, wordmark right, vertically centered
- **Favicon**: The squircle icon at 32x32 and 16x16
- **Social preview**: 1200x630 card with the icon, tagline, and a macOS-style blurred background

---

## Target Audience

### Primary: Mac developers and power users

- Use 2-4 browsers daily (Safari for personal, Chrome for dev tools, Firefox for testing, Arc for focused work)
- Comfortable with the terminal but appreciate good GUI tools
- Value tools that respect system conventions and feel native
- Annoyed by the System Settings detour to switch defaults

### Secondary: Presenters and screen-sharers

- Need to quickly hide desktop icons, toggle Stage Manager, keep the screen awake
- The Option-key power tools are a strong differentiator for this group

### Tertiary: QA and testing professionals

- Switch between browsers constantly for cross-browser testing
- Need the checkmark indicator to confirm which browser is currently default

---

## Marketing Strategy

### Phase 1 — Foundation (Pre-Launch / v1.0)

**Goal:** Establish presence and build a small, loyal user base before any promotion push.

| Action | Channel | Details |
| --- | --- | --- |
| Polish the GitHub README | GitHub | The README *is* the landing page for developers. It already has a screenshot, install command, and feature list — good. Add a hero GIF showing a browser switch in action. |
| Ship a landing page | Web | Single-page site (see Website section below). |
| Write a "Why I built this" post | Personal blog / Dev.to | Origin story. Relatable frustration. Show the before/after. |
| Submit to macOS utility directories | Directories | macapps.link, opensourcemac.org, awesome-macos on GitHub. |
| Create a Homebrew cask | Homebrew | `brew install --cask browser-switch` is the gold standard for Mac developer distribution. |

### Phase 2 — Launch (v1.0 Release)

**Goal:** Generate awareness in developer communities.

| Action | Channel | Details |
| --- | --- | --- |
| Hacker News "Show HN" post | HN | Title: "Show HN: Browser Switch — change your default macOS browser from the menu bar". Keep the post factual. HN rewards simplicity. |
| Reddit posts | r/macapps, r/macOS, r/webdev | Short post with GIF, link to site, and the one-liner install. |
| Product Hunt launch | PH | Schedule for a Tuesday. Prepare 5 screenshots, a 30s demo GIF, and a maker comment explaining the motivation. |
| Twitter/X thread | Social | "I switch between 4 browsers every day. macOS makes this annoying. So I built a menu bar app." Thread format with GIF. |
| Mastodon / Bluesky crosspost | Social | The indie Mac dev community is very active on Mastodon. Tag #macdev, #swiftlang. |

### Phase 3 — Growth (Post-Launch)

**Goal:** Sustain organic discovery and expand the audience.

| Action | Channel | Details |
| --- | --- | --- |
| SEO content | Blog / Website | Target keywords: "change default browser mac", "switch default browser macos", "mac menu bar browser switcher". Write short how-to articles. |
| Changelog updates | GitHub Releases + Website | Every release gets a short changelog entry on the site. Keep users engaged. |
| Sponsor/feature in Mac newsletters | Newsletters | Reach out to: Mac Power Users, Club MacStories, iOS Dev Weekly (has a macOS section), Swift Weekly Brief. |
| YouTube demo | YouTube | 60-90 second screencast. No intro animation, no subscribe begging. Just show the product. |
| GitHub Sponsors | GitHub | Add a Sponsor button. Some users want to support good open-source tools. |

---

## Website Plan

### Structure

A single-page marketing site. No blog initially — use Dev.to or a personal blog. The site should load fast, look native to macOS, and convert visitors to installers.

### URL

`browserswitch.app` or `browserswitchapp.com` (check availability)

### Page Sections (Top to Bottom)

#### 1. Hero

```
[App Icon]                    Browser Switch
                              Switch browsers. Not workflows.

                              A macOS menu bar utility that changes your
                              default browser in one click.

                              [ Download for Mac ]    [ View on GitHub ]
```

- Full-width, centered layout
- Subtle macOS-style mesh gradient background (like apple.com hero sections)
- The Download button links to the latest GitHub Release `.zip`
- "View on GitHub" is a secondary outline button
- Below the buttons: "Requires macOS 14 (Sonoma) or later. Free and open source."

#### 2. Demo

- A single looping GIF or short `<video>` (muted, autoplay) showing:
  1. Click the menu bar icon
  2. See the browser list with the checkmark
  3. Click a different browser
  4. Checkmark moves — done
- Framed inside a macOS window chrome mockup for polish
- Caption: "One click. New default. No System Settings required."

#### 3. Features Grid

A 2x3 or 3x2 card grid. Each card has an SF Symbol (rendered as SVG or image), a title, and one sentence.

| Icon | Title | Description |
| --- | --- | --- |
| `checkmark.circle` | One-Click Switching | Change your default browser without opening System Settings. |
| `magnifyingglass` | Auto-Discovery | Automatically finds every browser on your Mac. No configuration. |
| `network` | Network Context | See your IP, ISP, and VPN status right in the menu. |
| `cup.and.saucer` | Caffeine Mode | Keep your display awake during demos and presentations. |
| `eye.slash` | Hide Desktop Icons | Clean up your desktop before screen sharing with a single toggle. |
| `option` | Power Tools | Hold Option to reveal advanced controls for Stage Manager and more. |

#### 4. Installation

Three tabs or cards:

**One-Liner (Recommended)**
```bash
curl -fsSL https://raw.githubusercontent.com/adamabernathy/default-browser/main/scripts/install.sh | bash
```

**Download**
Direct link to the latest signed `.zip` from GitHub Releases.

**Homebrew** *(coming soon)*
```bash
brew install --cask browser-switch
```

#### 5. Why Browser Switch?

A short two-column comparison:

| Without Browser Switch | With Browser Switch |
| --- | --- |
| Open System Settings | Click the menu bar icon |
| Navigate to Desktop & Dock | Pick a browser |
| Scroll to Default web browser | Done |
| Select from dropdown | |
| Close System Settings | |

Caption: "Five steps become one."

#### 6. Open Source

- "Browser Switch is MIT-licensed and open source."
- Link to GitHub repo
- "Built with pure AppKit. Zero dependencies. Signed and notarized."
- GitHub stars badge, build status badge

#### 7. Footer

- "Made by Adam Abernathy" with link
- GitHub link
- MIT License link
- "No tracking. No analytics. No telemetry."

### Design Principles for the Site

1. **macOS-native feel.** Use `-apple-system` fonts, vibrancy-inspired glassmorphism for cards, and subtle shadows that match macOS window chrome.
2. **Dark mode support.** Use `prefers-color-scheme` media query. Light and dark variants for every section.
3. **Fast.** Static HTML + CSS. No JavaScript frameworks. Minimal JS only for the install tab switcher and dark mode toggle (if not relying on system preference).
4. **Mobile-friendly.** Even though the app is Mac-only, people discover it on phones. The site should be responsive.
5. **Accessible.** Semantic HTML, proper heading hierarchy, alt text on every image, 4.5:1 contrast ratios.

### Tech Stack for the Site

| Layer | Choice | Rationale |
| --- | --- | --- |
| Hosting | GitHub Pages | Free, fast, custom domain support, deploys on push |
| Generator | None (static HTML) or 11ty | Keep it simple. A single `index.html` works. |
| CSS | Vanilla CSS with custom properties | No build step. CSS variables for dark mode. |
| Assets | Optimized PNG/WebP + inline SVG | SF Symbol-style icons as SVG for crisp rendering |
| Analytics | None | "No tracking" is a feature, not a limitation |

### Sample CSS Custom Properties

```css
:root {
  --color-text: #1D1D1F;
  --color-text-secondary: #8E8E93;
  --color-accent: #007AFF;
  --color-surface: #FAFAFA;
  --color-card: #FFFFFF;
  --color-border: rgba(0, 0, 0, 0.06);
  --font-display: -apple-system, BlinkMacSystemFont, 'SF Pro Display', system-ui, sans-serif;
  --font-body: -apple-system, BlinkMacSystemFont, 'SF Pro Text', system-ui, sans-serif;
  --font-mono: 'SF Mono', ui-monospace, monospace;
  --radius: 12px;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-text: #F5F5F7;
    --color-text-secondary: #8E8E93;
    --color-accent: #0A84FF;
    --color-surface: #161617;
    --color-card: #1C1C1E;
    --color-border: rgba(255, 255, 255, 0.08);
  }
}
```

---

## Content Calendar (First 30 Days Around Launch)

| Day | Action | Channel |
| --- | --- | --- |
| -7 | Publish "Why I built Browser Switch" blog post | Dev.to / Personal blog |
| -3 | Submit to macapps.link and opensourcemac.org | Directories |
| 0 | Ship v1.0. Publish site. Post Show HN. | GitHub, Web, HN |
| 0 | Post to r/macapps and r/macOS | Reddit |
| 1 | Launch on Product Hunt | Product Hunt |
| 1 | Twitter/X thread + Mastodon crosspost | Social |
| 3 | Respond to all HN/Reddit/PH comments | Community |
| 7 | Publish YouTube demo video | YouTube |
| 14 | Reach out to Mac newsletter editors | Email |
| 21 | Write SEO article: "How to change default browser on Mac" | Blog / Site |
| 30 | v1.1 release with changelog post | GitHub, Site, Social |

---

## Key Metrics to Track

Since the app has no telemetry (and shouldn't), measure success through:

- **GitHub stars and forks** — primary growth indicator
- **GitHub Release download counts** — `gh api` can pull these
- **Install script hits** — raw.githubusercontent.com referrer logs (limited but available)
- **Website traffic** — if you add privacy-respecting analytics later (e.g., Plausible, Fathom), measure page views and download button clicks
- **Community mentions** — search Twitter, Reddit, HN for "Browser Switch" periodically

---

## Competitive Landscape

| Tool | Type | Differentiator for Browser Switch |
| --- | --- | --- |
| System Settings | Built-in | Browser Switch is faster (1 click vs. 5 steps) |
| Browserosaurus | Open source | Browserosaurus intercepts every link click. Browser Switch changes the *default* — simpler mental model. |
| Choosy | Paid ($10) | Browser Switch is free and open source. Choosy has rule-based routing — different use case. |
| Finicky | Open source | Finicky uses a config file for rules. Browser Switch is zero-config. |

**Browser Switch wins on simplicity.** It does one thing, does it well, and gets out of the way. That's the message.

---

## Summary

The brand is minimal, native, and developer-friendly. The marketing strategy leans into organic developer channels (HN, Reddit, Product Hunt, Mac newsletters) rather than paid acquisition. The website is a single fast page that communicates the value in seconds and gets users to the install command as quickly as possible.

The core message throughout everything: **"Switch browsers. Not workflows."**
