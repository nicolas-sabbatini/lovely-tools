# Interpolation

> This library can be used outside of Löve 2D.

A simple interpolation library that can be used to interpolate between _MULTIPLES_ values.

## About the contents:

- `Lerp`: A module that can be used to interpolate between _MULTIPLES_ values.
  > WARNING: This module is not meant to be used as a standalone module. It is meant to be usedin conjunction with the `Ease` module.
- `Ease`: A module that can be used to apply easing functions to the interpolation.

## Usage:

```lua
-- Import the library
local lerp = require("lerp")

-- Create a new lerp object
local lerperA = lerp.new(
    { 20, 400, 780, 20 }, -- Values to interpolate
    lerp.easeFunction.easeInOutElastic, -- Easing function (default is linear)
    true -- Repeat (default is false)
)

-- Lerp
lerperA:update(dt)
```
