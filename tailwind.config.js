const { iconsPlugin, getIconCollections } = require("@egoist/tailwindcss-icons")

module.exports = {
  plugins: [
    require("daisyui"),
    iconsPlugin({
      collections: getIconCollections(["uiw"]),
    })
  ],
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ]
}
