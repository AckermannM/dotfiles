# herdr-automatic-rename config, see:
# https://github.com/qu8n/herdr-automatic-rename/blob/main/config.example.sh

# Name agent tabs after the program ("claude") instead of the task the agent
# reports in its terminal title. Claude Code's title tracks the conversation
# topic, which we don't want showing up as the herdr tab/pane label or, via
# ui.window_title = "{tab}" in config.toml, in Ghostty's window title either.
AGENT_TITLES=0
