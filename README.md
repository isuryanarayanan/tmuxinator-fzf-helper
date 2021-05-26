# Tmuxinator helper

Helper script for tmuxinator commands using FZF

Add this to your bash aliases

```bash
alias <alias name>='bash /<path to>/tmuxinator-helper.sh'
```

## Usage

To open or close just run the script without any parameters,
if params are passed it will be to fuzzy search

- Templates

  - `tmuxinator-helper.sh --new-template <template file path> <template name>`
  - `tmuxinator-helper.sh --delete-template <template name>`

- Projects
  - `tmuxinator-helper.sh --new <project name>`
  - ` tmuxinator-helper.sh --new <project name> --template <template name>`
  - `tmuxinator-helper.sh --edit <project name>`
  - `tmuxinator-helper.sh --delete <project name>`
