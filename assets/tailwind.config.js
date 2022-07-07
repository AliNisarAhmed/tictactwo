// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
module.exports = {
  content: [
    './js/**/*.js',
    '../lib/tictactwo_web.ex',
    '../lib/tictactwo_web/**/*.*ex'
  ],
  theme: {
    extend: {
      gridTemplateColumns: {
        'lobby-desktop': '1fr 6fr'
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms')
  ]
}
