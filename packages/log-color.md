## Node

### console.log colors

```js
console.log("\u001b[0m reset \u001b[0m");
console.log("\u001b[1m bold \u001b[22m");
console.log("\u001b[2m dim \u001b[22m");
console.log("\u001b[4m underline \u001b[24m");
console.log("\u001b[3m italic \u001b[23m");
console.log("\u001b[7m inverse \u001b[27m");
console.log("\u001b[8m hidden \u001b[28m");
console.log("\u001b[9m strikethrough \u001b[29m");
console.log(" -------- ");
console.log("\u001b[30m black \u001b[39m");
console.log("\u001b[31m red \u001b[39m");
console.log("\u001b[32m green \u001b[39m");
console.log("\u001b[33m yellow \u001b[39m");
console.log("\u001b[34m blue \u001b[39m");
console.log("\u001b[35m magenta \u001b[39m");
console.log("\u001b[36m cyan \u001b[39m");
console.log("\u001b[37m white \u001b[39m");
console.log("\u001b[90m gray grey \u001b[39m");
console.log(" -------- ");
console.log("\u001b[40m bgBlack \u001b[49m");
console.log("\u001b[41m bgRed \u001b[49m");
console.log("\u001b[42m bgGreen \u001b[49m");
console.log("\u001b[43m bgYellow \u001b[49m");
console.log("\u001b[44m bgBlue \u001b[49m");
console.log("\u001b[45m bgMagenta \u001b[49m");
console.log("\u001b[46m bgCygan \u001b[49m");
console.log("\u001b[47m bgWhite \u001b[49m");
```

### util

```ts
type TextStyle = "italic";
type TextDecoration = "overline" | "strikethrough" | "underline";
type FontWeight = "bold";
type TextColor =
  | "black"
  | "red"
  | "green"
  | "yellow"
  | "blue"
  | "magenta"
  | "cyan"
  | "white"
  | "gray"
  | "grey";
type BackgroundColor =
  | "black"
  | "red"
  | "green"
  | "yellow"
  | "blue"
  | "magenta"
  | "cyan"
  | "white";

type LogOptions = {
  style?: TextStyle;
  color?: TextColor;
  decoration?: TextDecoration;
  fontWeight?: FontWeight;
  background?: BackgroundColor;
};

type WrapperFunc = (
  content: string,
  options: LogOptions
) => [string, LogOptions];

const textStyles = {
  default: null,
  italic: [3, 23],
};

const fontWeights = {
  default: null,
  bold: [1, 22],
};

const textDecorations = {
  default: null,
  strikethrough: [9, 29],
  underline: [4, 24],
  overline: [53, 55],
};

const textColors = {
  default: null,
  black: [30, 39],
  red: [31, 39],
  green: [32, 39],
  yellow: [33, 39],
  blue: [34, 39],
  magenta: [35, 39],
  cyan: [36, 39],
  white: [37, 39],
  grey: [90, 39],
  gray: [90, 39],
};

const backgroundColors = {
  default: null,
  black: [40, 49],
  red: [41, 49],
  green: [42, 49],
  yellow: [43, 49],
  blue: [44, 49],
  magenta: [45, 49],
  cyan: [46, 49],
  white: [47, 49],
};

const compose = (...fns: WrapperFunc[]) =>
  fns.reduce(
    (prev, next) => (content: string, options: LogOptions) =>
      next(...prev(content, options))
  );

const wrapper = (content: string, pack: number[] | null) => {
  if (!pack) return content;

  const [start, end] = pack;

  return `\u001b[${start}m${content}\u001b[${end}m`;
};

const wrapperStyle: WrapperFunc = (content, options) => {
  const { style = "default" } = options;
  const output = wrapper(content, textStyles[style]);

  return [output, options];
};

const wrapperDecoration: WrapperFunc = (content, options) => {
  const { decoration = "default" } = options;
  const output = wrapper(content, textDecorations[decoration]);

  return [output, options];
};

const wrapperFontWeight: WrapperFunc = (content, options) => {
  const { fontWeight = "default" } = options;
  const output = wrapper(content, fontWeights[fontWeight]);

  return [output, options];
};

const wrapperColor: WrapperFunc = (content: string, options: LogOptions) => {
  const { color = "default" } = options;
  const output = wrapper(content, textColors[color]);

  return [output, options];
};

const wrapperBackground: WrapperFunc = (content, options) => {
  const { background = "default" } = options;
  const output = wrapper(content, backgroundColors[background]);

  return [output, options];
};

function formatLog(content: string, options: LogOptions = {}): string {
  const result = compose(
    wrapperDecoration,
    wrapperBackground,
    wrapperFontWeight,
    wrapperColor,
    wrapperStyle
  )(content, options);

  const [output] = result;

  return output;
}
```
