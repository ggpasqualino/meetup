# Meet the Meetup

[![Deps Status](https://beta.hexfaktor.org/badge/all/github/ggpasqualino/meetup.svg)](https://beta.hexfaktor.org/github/ggpasqualino/meetup)
[![Build Status](https://travis-ci.org/ggpasqualino/meetup.svg?branch=master)](https://travis-ci.org/ggpasqualino/meetup)

A project to help meetup organizers to understand the members of their Meetup.com groups

API Authentication:
  * OAuth
    * This method is recommended for using the application as a service for multiple users 
    * Create a Meetup.com OAuth consumer at https://secure.meetup.com/meetup_api/oauth_consumers/
    * Export the values of `Key`, `Secret` and `Redirect URI` to your environment
   
   ```bash
   export MEETUP_CLIENT_ID=[Key]
   export MEETUP_CLIENT_SECRET=[Secret]
   export MEETUP_REDIRECT_URI=[Redirect URI]
   ```
  
  * API Key:
    * This method is recommended for using the application by only one user
    * Get your key at https://secure.meetup.com/meetup_api/key/
    * Export it to your environment with `export MEETUP_API_KEY=[your-key]`

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`
