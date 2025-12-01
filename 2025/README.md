[2024](https://adventofcode.com/2024) Lets GO!

### Install Lua

```sh
brew install lua
```

### Install LuaRocks (package manager)

```sh
brew install luarocks
```

### Install my lib xD

```sh
luarocks install ff-lua
```

It has datastructures that default lua does not.

### Input

Copy and paste the puzzle input in a file `day<N>.in`, as `<N>` being the day.
Ex:

```sh
ls

> day01.lua day01.in

```

### Result

For checking the result save a file `day<N>.out` in this directory.
Ex:

```sh
ls

> day01.lua day01.in day01.out

```

The file must have 2 lines, each line with the expected result for each puzzle part. You can have 2 empty lines as well.

### Run

To run a specific day you can send the day number as argument.
Ex:
```sh
lua run.lua 1 #for day 1
```

Or you can run all days by skipping the argument.
Ex:
```sh
lua run.lua
```

