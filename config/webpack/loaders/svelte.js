module.exports = {
  test: /\.svelte(\.erb)?$/,
  use: [{
    loader: 'svelte-loader',
    options: {
      dev: true,
      hotReload: false,
      preprocess: require('svelte-preprocess')({})
    }
  }],
};
