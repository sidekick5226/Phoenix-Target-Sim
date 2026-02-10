/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,jsx}"],
  theme: {
    extend: {
      colors: {
        ink: "#0b1216",
        slate: "#101a21",
        mist: "#dae6f2",
        neon: "#55f2d8",
        ember: "#ff7a59"
      }
    }
  },
  plugins: []
};
