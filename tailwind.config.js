/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './layouts/**/*.html',
    './content/**/*.{html,md}',
    './themes/*/layouts/**/*.html',
  ],
  theme: {
    extend: {
      fontFamily: {
        'sans': ['Inter', 'Atkinson Hyperlegible', 'ui-sans-serif', 'system-ui'],
        'mono': ['Noto Sans Mono', 'ui-monospace', 'SFMono-Regular'],
        'brand': ['Noto Sans', 'sans-serif'],
        'heading': ['Noto Sans', 'sans-serif'],
        'body': ['Inter', 'Atkinson Hyperlegible', 'ui-sans-serif', 'system-ui'],
      },
      fontSize: {
        'base': '1rem',
        'sm': '0.875rem',
        'lg': '1.25rem',
        'xl': '1.5rem',
        '2xl': '2rem',
      },
      lineHeight: {
        'body': '1.6',
        'heading': '1.25',
      },
      maxWidth: {
        '20ch': '20ch',
        '30ch': '30ch',
      },
      colors: {
        // Brand Colors
        'brand-teal': '#0ca678',
        'brand-logo-orange': '#d77350',
        'brand-purple': '#a625a4',
        'brand-blue': '#4078f2',
        'brand-gold': '#b66b02',
        'brand-alert-red': '#e45549',

        'bg-website': '#f0eee6',
        'bg-section-neutral': '#e3dacc',
        'bg-section-mint': '#bcd1ca',
        'bg-section-blue': '#cbcadb',
        'bg-light': '#fdfbf9',
        'bg-light-alt': '#faf9f5',

        'text-base-dark': '#141413',
        'text-muted': '#393a42',
        'text-mono': '#002a1e',
        'text-soft': '#a0a1a6',

        'btn-primary-bg': '#b9b2a7',
        'btn-secondary-bg': '#cdc6b9',
        'hover-orange': '#da7756',
        'highlight-bg': '#fff8d0',

        // Solarized Light
        'sl-base03': '#002b36',
        'sl-base02': '#073642',
        'sl-base01': '#586e75',
        'sl-base00': '#657b83',
        'sl-base0':  '#839496',
        'sl-base1':  '#93a1a1',
        'sl-base2':  '#eee8d5',
        'sl-base3':  '#fdf6e3',

        // Solarized Dark (aliasing same colors under "sd-" prefix)
        'sd-base03': '#002b36',
        'sd-base02': '#073642',
        'sd-base01': '#586e75',
        'sd-base00': '#657b83',
        'sd-base0':  '#839496',
        'sd-base1':  '#93a1a1',
        'sd-base2':  '#eee8d5',
        'sd-base3':  '#fdf6e3',

        // Accents (shared)
        'sl-yellow':  '#b58900',
        'sl-orange':  '#cb4b16',
        'sl-red':     '#dc322f',
        'sl-magenta': '#d33682',
        'sl-violet':  '#6c71c4',
        'sl-blue':    '#268bd2',
        'sl-cyan':    '#2aa198',
        'sl-green':   '#859900',
      }
    }
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
}