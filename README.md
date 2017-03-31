# detco

A script to resolve `t.co` links that creep into your Instapaper feed.

## Usage

You'll need to [request your own Instapaper OAuth consumer tokens](https://www.instapaper.com/main/request_oauth_consumer_token), then copy `secrets.yml.example` to `.secrets.yml`, editing in the tokens you receive. On first run, the script will prompt you for an interactive user login, and persist the OAuth user credentials it receives.

The script will use `curl` to try to resolve `t.co` URLs, then add the unshortened link to your Instapaper feed and delete the `t.co` one. I suggest increasing the bookmark limit to 500 for the initial run, then putting this script in a cron job.
