const { environment } = require('@rails/webpacker')
const erb = require('./loaders/erb')
const svelte = require('./loaders/svelte')

environment.loaders.prepend('svelte', svelte)
environment.loaders.prepend('erb', erb)
module.exports = environment
