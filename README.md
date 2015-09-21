# Zizou

Elo ranking managed through the messaging software Slack.

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

## Installation

* Set the Slack API token (you can get it from [Slack](https://api.slack.com/web)) as an environment variable named: `SLACK_API_TOKEN`
* Create an Outgoing Webhook in your team's Slack: `https://YOUR_SLACK_TEAM.slack.com/services`
Give this webhook the channel you want zizou to listen to, and set the trigger word as `fifa`.
* Set the Outgoing Webhook token as an environment variable named: `SLACK_WEBHOOK_TOKEN`

## Usage

Zizou comes pre-packaged with a set of commands designed to help you store and retrieves 1v1 and 2v2 matches.

* First, add the teams you plan to use and their ratings in Zizou with the following command:
`fifa addteam BAR XX XX XX`. Obviously, replace BAR by the acronym of the team you want to add, and the XXs by respectively, the attack, midfield, and defense ratings of the team.
* Then, you're ready to add matches with the following command:
`fifa match @slack_player_username TEAM score @slack_player_username TEAM score`. Replace TEAM by the team acronym and score by the actual score the player had in the game.
Example: `fifa match @bill_gates BAR 4 @bill_murray ASSE 5`

The whole set of commands is the following:

```
fifa ranking [n_weeks]
fifa ranking2 [n_weeks]
fifa r [n_weeks]
fifa r2 [n_weeks]
fifa 2v2 player11 player12 team1 score1 player21 player22 team2 score2
fifa match player1 team1 score1 player2 team2 score2
fifa teams
fifa addteam name attack midfield defense
fifa challenge player [time]
fifa challenges
fifa stats player
fifa undo
fifa ribery
```

## Routes

* `POST /bot` : Currently the only route. It is the endpoint your Slack will be sending messages to.

## Adding new commands

In lib/slackbot.rb, you can add your own commands.
As you'll see when inspecting this file, every command is actually a method named `hear_COMMANDNAME`. To add commands, simply add a new PRIVATE method named `hear_yourCommandName(optional_parameters...)`.
The parameters will be displayed in the help and optional parameters will immediately be annotated as optional in the help as well.

## Future work

There are a couple of improvements we have in mind. Feel free to send us pull
requests if you want to contribute!

* Add a proper API so that a web interface can be made, in case you want to display it on a screen in your office.
* Zizou is currently speaking french, why not improving his languages skills ? (good luck with the translation of Ribery quotes)
* Add a betting system with a fake currency.
* More?
