const emptyScope = {
  name: "               empty scope",
  value: "",
};

module.exports = {
  types: [
    {
      value: "docs",
      name: "docs:       Documentation only changes",
    },
    {
      value: "fix",
      name: "fix:        A fix to LaTeX errors",
    },
    {
      value: "style",
      name: "style:      Changes that do not affect the meaning of the code (white-space, formatting, etc)",
    },
    {
      value: "refactor",
      name: "refactor:   A change that neither fixes a bug nor adds a feature",
    },
    {
      value: "build",
      name: "build:      Changes that affect the build system or external dependencies",
    },
    {
      value: "chore",
      name: "chore:      Other changes that don't modify src or test files",
    },
    {
      value: "ci",
      name: "ci:         Changes to our CI configuration files and scripts",
    },
    {
      value: "revert",
      name: "revert:     Revert a previous commit",
    },
  ],

  scopes: [
    // this comments forces prettier to keep the array on multiple lines
    emptyScope,
    "verbali",
    "AdR",
    "glossario",
    "PdP",
    "PdQ",
    "NdP",
    "SdF",
  ],

  // it needs to match the value for field type. Eg.: 'fix'
  scopeOverrides: {
    build: [
      // this comments forces prettier to keep the array on multiple lines
      emptyScope,
      {name: "latex"},
    ],
    chore: [
      // this comments forces prettier to keep the array on multiple lines
      emptyScope,
      {name: "vscode"},
    ],
    ci: [{name: "actions"}],
  },

  allowBreakingChanges: [],
  allowCustomScopes: false,
  askForBreakingChangeFirst: true,
  skipQuestions: ["breaking"],
  subjectLimit: 72,
};
