# DriftHound Website

Official landing page for DriftHound - A Watchdog for Your Infrastructure State.

## About

This is the source code for the DriftHound landing page, built with Jekyll and deployed on GitHub Pages.

**Live Site**: [https://drifthound.io](https://drifthound.io)

## Local Development

### Prerequisites

- Ruby 3.3 or higher
- Bundler

### Setup

1. Install dependencies:
```bash
bundle install
```

2. Run the development server:
```bash
bundle exec jekyll serve --livereload
```

3. Open your browser to `http://localhost:4000`

### Docker Setup

1. Run the following command:
```bash
docker run --rm -it \
  -v "$PWD:/srv/jekyll" \
  -p 4000:4000 \
  jekyll/jekyll:4.2.2 \
  jekyll serve --force_polling --livereload
```

2. Open your browser to `http://localhost:4000`

## Deployment

The site is automatically deployed to GitHub Pages via GitHub Actions on every push to the `main` branch.

### GitHub Pages Setup

1. Go to repository Settings > Pages
2. Set Source to "GitHub Actions"
3. Configure custom domain (optional): `drifthound.io`

## Tech Stack

- **Jekyll 4.3.2** - Static site generator
- **Vanilla CSS** - No preprocessors, modern CSS features
- **Vanilla JavaScript** - Progressive enhancement
- **GitHub Pages** - Free hosting with GitHub Actions

## Related Projects

- **DriftHound** - Main application: [github.com/drifthoundhq/DriftHound](https://github.com/drifthoundhq/drifthound)
- **DriftHound Action** - GitHub Action: [github.com/drifthoundhq/drifthound-action](https://github.com/drifthoundhq/drifthound-action)
- **Helm Chart** - Kubernetes deployment: [github.com/drifthoundhq/helm-chart-drifthound](https://github.com/drifthoundhq/helm-chart)

## License

AGPL-3.0 License - see the main DriftHound repository for details.
