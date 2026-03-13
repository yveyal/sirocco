# Sirocco Hugo Theme - AI Agent Context

## Project Overview

This is **Sirocco**, a personal minimalistic blog/website theme for the [Hugo](https://gohugo.io/) static site generator.

- **Goal:** Showcase technical skills, experience, and thoughts (blog) with elegance and simplicity.
- **Core Philosophy:** Configuration over Code. Users should control the site via `data/` and `hugo.yaml` without touching HTML/CSS.
- **Tech Stack:** Hugo (Extended), bootstrap 5, Vanilla JavaScript, Hugo Pipes.

## Development Environment

We use `make` and `docker` for deterministic tooling and task management.

### Quick Start

1. **Dev Server:** Run `make dev`.
   - This will mount the exampleSite automatically.
   - Serves the site at `localhost:1313`.
3. **Verify Changes:** TBD

## Project Structure

### 1. The "ּSection-Driven" Layout

Sirocco differs from standard Hugo themes. It aims to decouple the content and the theme management. Global theme related configurations should reside in the `hugo.yaml` file . Content is seperated into *sections*. 

- **`layouts/partials/`**: Contains the reusable UI components.  
- **`assets/styles/`**: Styling. We use SCSS.

#### 1.1 Section

The top level abstraction - the first directory layer under the blog `content` root. 
Each sections configurations lives within the frontmatter in **`content/<SECTION>/_index.md`**, Controlling the layout configurations of that section.

### 2. Directory Map

- `static/`
  - `css/theme.css`: Theme css configuration definition.
- `layouts/`
  - `_default/` Where base structure of pages are defined.
  - `partials/`: Where the core logic lives. Break complex logic into partials.
  - `shortcodes/`: Custom markdown components for users.
- `exampleSite/`: The integration test bed.
  - `hugo.yaml`: Main configuration.
  - `content/`: Blog posts and markdown content.

## Coding Guidelines

### HTML & Go Templates

- **Semantics:** Use semantic Bootstrap5 + HTML5 (`<section>`, `<article>`, `<nav>`).
- **Partials:** If a block of code is used more than once, extract it to `layouts/partials`.
- **IDs/Classes:** Use meaningful kebab-case class names.
- **Safe HTML:** Use `safeHTML` only when absolutely necessary and verified safe.

### CSS

- **CSS:** All styles must reside in `static/css/theme.css`.
- **Responsiveness:** Mobile-first approach is preferred, but ensure desktop elegance.

### JavaScript

- **Vanilla JS:** Avoid adding libraries (jQuery, etc.) unless strictly necessary.
- **Fingerprinting:** All JS resources in templates must be fingerprinted for cache busting.
  - _Example:_ `$js := resources.Get "js/script.js" | fingerprint`
- **DOM Manipulation:** Ensure DOM elements exist before attaching listeners.

## Contributing Rules (Strict)

1. **Backward Compatibility:** NEVER break existing `config` or `_index.md` structures.
2. **Configurability:** Every new visual feature must be toggleable via `hugo.yaml` or `_index.md` files.
3. **Defaults:** New features must be **disabled by default**.

## Common Workflows

### How to Fix a Bug

1. Reproduce it in `exampleSite`.
2. Fix the logic in the theme `layouts` or `theme.css`.
3. Verify the fix by running `make dev`.

## Repository working rules

- Update `README.md` whenever setup, commands, structure, behavior, or conventions change.
- Use a `Makefile` as the standard entrypoint for common local development, testing, and operational commands.
- Prefer reusable partials over duplicated templates.
- Keep layouts predictable and easy to scan.
- Avoid unnecessary dependencies.
- Prefer explicit, maintainable solutions over clever abstractions.