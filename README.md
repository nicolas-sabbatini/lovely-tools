# Lovely Tools

A happy collection of tools that I use for game dev in the amazing Löve 2D game engine.
This collection is a work in progress and will be updated as I go along in my game dev journey.
I hope you find something useful here. Enjoy! ♥

## About the contents:

All the tools are organized in folders. Each folder contains a `README.md` file with
a brief description of the tool and how to use it.

The tools are created with the intention of being used in a Löve 2D project, so they are not standalone
applications. They are meant to be used as part of a Löve 2D project, but some can be used in other contexts or engines,
this is specified in the tool's `README.md` file.

## Contents:

### Interpolation

A simple interpolation library that can be used to interpolate between two values.
It has 2 modules that can be used independently: `Interpolation` and `Easing`.

### Simple Keyboard

> Previously known as [ "simpleKey" ](https://github.com/nicolas-sabbatini/simpleKey).

A simple keyboard library that can be used to check if a key is pressed, released or held down.
The library dosn't use the `love.keypressed` and `love.keyreleased` callbacks, so you can have control over the input.

## Examples:

In each tool's folder, there is an `example` folder that contains a Löve 2D project that demonstrates how to use the tool,
and in the root repository folder, there is a `main.lua` file that contains a simple example of how to use all the tools together.

## External Tools:

- [Push](https://github.com/Ulydev/push): Push is a simple resolution-handling library that allows you to focus on making your game with a fixed resolution.
