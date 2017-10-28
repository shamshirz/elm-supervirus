var path = require('path');
var webpack = require('webpack');
var merge = require('webpack-merge');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var autoprefixer = require('autoprefixer');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var CopyWebpackPlugin = require('copy-webpack-plugin');


// To build prod pass --env.prod


// entry and output path/filename variables
const entryPath = path.join(__dirname, 'src/static/index.js');
const outputPath = path.join(__dirname, 'dist');
const outputFilename = isProd ? '[name]-[hash].js' : '[name].js'

// common webpack config (valid for dev and prod)
var commonConfig = {
    output: {
        path: outputPath,
        filename: `static/js/${outputFilename}`,
    },
    resolve: {
        extensions: ['.js', '.elm'],
        modules: ['node_modules']
    },
    module: {
        noParse: /\.elm$/,
        rules: [{
            test: /\.(eot|ttf|woff|woff2|svg)$/,
            use: 'file-loader?publicPath=../../&name=static/css/[hash].[ext]'
        }]
    },
    plugins: [
        new webpack.LoaderOptionsPlugin({
            options: {
                postcss: [autoprefixer()]
            }
        }),
        new HtmlWebpackPlugin({
            template: 'src/static/index.html',
            inject: 'body',
            filename: 'index.html'
        })
    ]
}

const devSpecific = {
    entry: [entryPath, 'webpack-dev-server/client?http://localhost:8080'],
    devServer: {
        // serve index.html in place of 404 responses
        historyApiFallback: true,
        contentBase: './src',
        hot: true
    },
    module: {
        rules: [{
            test: /\.elm$/,
            exclude: [/elm-stuff/, /node_modules/],
            use: [{
                loader: 'elm-webpack-loader',
                options: {
                    verbose: true,
                    warn: true,
                    debug: true
                }
            }]
        },{
            test: /\.sc?ss$/,
            use: ['style-loader', 'css-loader', 'postcss-loader', 'sass-loader']
        }]
    }
};

const prodSpecific = {
    entry: entryPath,
    module: {
        rules: [{
            test: /\.elm$/,
            exclude: [/elm-stuff/, /node_modules/],
            use: 'elm-webpack-loader'
        }, {
            test: /\.sc?ss$/,
            use: ExtractTextPlugin.extract({
                fallback: 'style-loader',
                use: ['css-loader', 'postcss-loader', 'sass-loader']
            })
        }]
    },
    plugins: [
        new ExtractTextPlugin({
            filename: 'static/css/[name]-[hash].css',
            allChunks: true,
        }),
        new CopyWebpackPlugin([{
            from: 'src/static/img/',
            to: 'static/img/'
        }, {
            from: 'src/favicon.ico'
        }]),

        // extract CSS into a separate file
        // minify JS/CSS
        new webpack.optimize.UglifyJsPlugin({
            minimize: true,
            compressor: {
                warnings: false
            }
        })
    ]
};

module.exports = function(env) {
    const isProd = (env && env.prod)
    console.log('WEBPACK GO! Building for ' + (isProd ? 'prod' : 'dev'));

    let specificConfig = isProd ? prodSpecific : devSpecific
    return merge(commonConfig, specificConfig)
}
