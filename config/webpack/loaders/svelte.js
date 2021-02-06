const autoPreprocess = require('svelte-preprocess');

module.exports = {
  test: /\.svelte(\.erb)?$/,
  use: {
    loader: 'svelte-loader',
    options: {
      dev: true,
      hotReload: false,
      preprocess: autoPreprocess()
    }
  }
};
