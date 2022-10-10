// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
const colors = require('tailwindcss/colors');

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/tictactwo_web.ex',
    '../lib/tictactwo_web/**/*.*ex',
    '../deps/petal_components/**/*.*ex'
  ],
  theme: {
    extend: {
      colors: {
        primary: colors.blue,
        secondary: colors.orange,
        blue: colors.blue,
        orange: colors.orange
      },
      gridTemplateColumns: {
        'lobby-desktop': '1fr 6fr'
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms')
  ]
}
