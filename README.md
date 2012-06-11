SQUPluginSystem
===============

A simple plugin system for OS X.

Plugins are simply bundles with a custom extension. The plugin system is currently in use by an app in development. There's some code for an example plugin included — it demonstrates how to provide a preference view, store preferences and how to do two-way communications between app and plugin. Of course, it also teaches you a little about Scripting Bridge.

To show a possible real-life application of this plugin system, there's a single test app for you to test all your plugins in. When opened, it will try to load all plugins in it's application support folder, as well as the app bundle's PlugIns folder. The plugin mentioned earlier is included in the app, so you can see how it works. Here's a screenshot of it:

![Screenshot](http://dl.dropbox.com/u/14283494/Screenshots/Screen%20Shot%202012-06-11%20at%2009.49.06.png)

Licensed under the MIT license:

Copyright (c) 2012 Tristan Seifert

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
