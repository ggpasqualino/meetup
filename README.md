# Meet the Meetup

[![Deps Status](https://beta.hexfaktor.org/badge/all/github/ggpasqualino/meetup.svg)](https://beta.hexfaktor.org/github/ggpasqualino/meetup)

A project to help meetup organizers to understand the members of their Meetup.com groups

API Authentication:
  * Create a Meetup.com OAuth consumer at https://secure.meetup.com/meetup_api/oauth_consumers/
  * Export the values of `Key`, `Secret` and `Redirect URI` to your environment
   
   ```bash
   export MEETUP_CLIENT_ID=[Key]
   export MEETUP_CLIENT_SECRET=[Secret]
   export MEETUP_REDIRECT_URI=[Redirect URI]
   ```

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`
