# Save The Republic Twitter Testing Bot

The bot monitors content from accounts it follows and responds with facts where lies are being posted.

It pulls information from fact-checking websites such as Politifact, Snopes, etc and pair content with those websites to counter misinformation.

Text processing algorithms will are used to determine if a claim is true or false. Amazon Web Services are used to analyze content posted by followed accounts

This bot supports the following.

1. Analyzes tweets from followed accounts
1. Posts tweets on followed accounts.
1. Follows accounts that have spread lies on followed accounts.
1. Posts to slack when a claim is refuted.

## See Also

If you're part of Save The Republic you can find sensitive details about this bot [here](https://savetherepublic.atlassian.net/l/c/LvxoNceZ).

## Tail the logs

```shell
awslogs get /aws/lambda/twitter-bot --profile twitter-bot-test --aws-region us-east-1 ALL --watch
```
