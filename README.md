# ox_lib

A FiveM library and resource implementing reusable modules, methods, and UI elements.

![](https://img.shields.io/github/downloads/communityox/ox_lib/total?logo=github)
![](https://img.shields.io/github/downloads/communityox/ox_lib/latest/total?logo=github)
![](https://img.shields.io/github/contributors/communityox/ox_lib?logo=github)
![](https://img.shields.io/github/v/release/communityox/ox_lib?logo=github)

For guidelines to contributing to the project, and to see our Contributor License Agreement, see [CONTRIBUTING.md](./CONTRIBUTING.md)

For additional legal notices, refer to [NOTICE.md](./NOTICE.md).


## 📚 Documentation

https://coxdocs.dev/ox_lib

## 💾 Download

https://github.com/communityox/ox_lib/releases/latest/download/ox_lib.zip

## 📦 npm package

https://www.npmjs.com/package/@communityox/ox_lib

## 🖥️ Lua Language Server

- Install [Lua Language Server](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) to ease development with annotations, type checking, diagnostics, and more.
- Install [CfxLua IntelliSense](https://marketplace.visualstudio.com/items?itemName=communityox.cfxlua-vscode-cox) to add natives and cfxlua runtime declarations to LLS.
- You can load ox_lib into your global development environment by modifying workspace/user settings "Lua.workspace.library" with the resource path.
  - e.g. "c:/fxserver/resources/ox_lib"

## ✨ New Modules

### Switch
Pattern matching switch statement with chaining support.
```lua
lib.switch(job)
    :on('police', function() lib.notify('Eres policía') end)
    :on('medic', function() lib.notify('Eres médico') end)
    :default(function() lib.notify('Civil') end)
```

### Vector
Vector utilities using FiveM's efficient `#(v1 - v2)` syntax.
```lua
lib.vector.distance(v1, v2)
lib.vector.distance2D(v1, v2)
lib.vector.heading(v1, v2)
lib.vector.offset(v, heading, distance)
lib.vector.closest(target, points)
lib.vector.inRange(v1, v2, maxDistance)
```

### Random
Random utilities including weighted selection and UUID generation.
```lua
lib.random.choice(tbl)
lib.random.weighted(tbl)
lib.random.uuid()
lib.random.between(min, max)
lib.random.char()
lib.random.bool(chance)
```

### String Extensions
Additional string manipulation functions.
```lua
string.split(str, separator)
string.startsWith(str, prefix)
string.endsWith(str, suffix)
string.capitalize(str)
string.truncate(str, length, ellipsis)
string.trim(str)
string.formatCurrency(amount, symbol, decimals)
```

### Table Extensions
Additional table manipulation functions.
```lua
table.find(tbl, value)
table.keys(tbl)
table.values(tbl)
table.count(tbl, predicate)
table.flat(tbl, depth)
table.chunk(tbl, size)
```

### Array Extensions
Additional Array class methods.
```lua
lib.array:some(testFn)
lib.array:sort(comparator)
lib.array:unique()
lib.array:flatMap(cb)
lib.array:sample()
```

### Math Extensions
Additional calculation functions.
```lua
math.sum(tbl)
math.avg(tbl)
math.median(tbl)
math.maxArray(tbl)
math.minArray(tbl)
math.range(start, stop, step)
math.percent(value, total)
```
