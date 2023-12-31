// This file was configured by pmeijer found at https://github.com/pmeijer/webgme-react-viz

const path = require('path')
const WrapperPlugin = require('wrapper-webpack-plugin')

module.exports = {
  entry: {
    moveCodeEditor: './src/visualizers/panels/MoveCodeEditor/src/index.jsx',
    verificationProperties: './src/visualizers/panels/VerificationProperties/src/index.jsx'
  },
  output: {
    filename: '[name].reactViz.bundle.js',
    path: path.join(__dirname, './src/visualizers/panels/ReactVisualizerBundles/')
  },
  plugins: [
    new WrapperPlugin({
      test: /\.js$/,
      header: 'define([], function () {\nreturn function (VISUALIZER_INSTANCE_ID) {',
      footer: '};\n});'
    })
  ],
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: [
          'babel-loader'
        ]
      }
    ]
  },
  resolve: {
    extensions: ['.js', '.jsx']
  }
}
