module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2021, // Specify the ECMAScript version you're using
    sourceType: "module", // Specify that you are using ES6 modules
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    quotes: ["error", "double"],
  },
};


// export const root=true;
// export const env={
//   es6: true,
//   node: true,
// };
// export const parserOptions={
//   ecmaVersion: 2021,
//   sourceType: "module", // Specify that you are using ES6 modules
// };
// export const extend=[
//   "eslint:recommended",
//   "google",
// ];
// export const rules={
//   quotes: ["error","double"],
// };
