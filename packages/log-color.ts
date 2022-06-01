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
  const { style = 'default' } = options;
  const output = wrapper(content, textStyles[style]);

  return [output, options];
};

const wrapperDecoration: WrapperFunc = (content, options) => {
  const { decoration = 'default' } = options;
  const output = wrapper(content, textDecorations[decoration]);

  return [output, options];
};

const wrapperFontWeight: WrapperFunc = (content, options) => {
  const { fontWeight = 'default' } = options;
  const output = wrapper(content, fontWeights[fontWeight]);

  return [output, options];
};

const wrapperColor: WrapperFunc = (content: string, options: LogOptions) => {
  const { color = 'default' } = options;
  const output = wrapper(content, textColors[color]);

  return [output, options];
};

const wrapperBackground: WrapperFunc = (content, options) => {
  const { background = 'default' } = options;
  const output = wrapper(content, backgroundColors[background])

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

const list: LogOptions[] = [
  { color: "green" },
  { color: "cyan", decoration: "overline" },
  { style: "italic", color: "black", background: "white" },
  {
    style: "italic",
    color: "gray",
    decoration: "strikethrough",
  },
  {
    color: "blue",
    fontWeight: "bold",
    decoration: "underline",
    background: "green",
  },
  {
    style: "italic",
    color: "magenta",
    fontWeight: "bold",
  },
  {
    style: "italic",
    color: "red",
    background: "cyan",
  },
];

list.forEach((options) => {
  let attrs: any[] = [];
  let key: keyof LogOptions;
  for (key in options) {
    if ({}.hasOwnProperty.call(options, key)) {
      attrs.push(`${key}: ${options[key]}`);
    }
  }
  const text = `${attrs.join("\n")}`;
  console.log("\n");
  console.log(formatLog(text, options));
});
