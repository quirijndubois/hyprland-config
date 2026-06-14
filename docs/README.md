# Qaskade Documentation

This documentation site is built with Jekyll and hosted on GitHub Pages.

## Building Locally

### Prerequisites
- Ruby 2.7 or higher
- Bundler

### Setup

```bash
cd docs
bundle install
bundle exec jekyll serve
```

The site will be available at `http://localhost:4000/qaskade/`

## Structure

- `index.md` - Main documentation page
- `_config.yml` - Jekyll configuration
- `_layouts/` - Page layout templates
- `assets/css/` - Stylesheets
- `Gemfile` - Ruby dependencies

## Customization

The site uses the Catppuccin Mocha color palette by default. To customize colors, edit `assets/css/style.css` and modify the CSS variables in the `:root` selector.

## Deployment

GitHub Pages automatically builds and deploys the site when you push to the `docs/` folder on the main branch. Ensure GitHub Pages is enabled in repository settings with source set to `main` and the `docs` folder.
