This minetest mod resets the accounts of players who have weak passwords.

By default, a password is considered "weak" if it is blank, or is among the 100 most-common passwords found amongst
many large leaked password lists.

==== Frequently asked question
===== Isn't resetting a player's account pretty harsh?
Yes, it is. However, I consider having a weak password to be a serious threat to the server. Your account
might be hacked at any point in time, and you could lose much more than your current inventory. Also,
trolls/hackers can use accounts with weak passwords to get around the IP blocking features of SBAN.

For a moment, I thought I might prefer if a player with a weak password was given an impassible pop-up
demanding that they change their password to something better, but this doesn't help w/ the issue
of trolls/hackers getting into a player's account. Resetting a player, and re-verifying them, feels like
the safer option.

==== Caveat
Because authentication data of new users is not set at the time that the prelogin hooks are executed,
We cannot reject them before they actually log into the server. At this point, they are kicked, and their passwords
reset. However, that part of the process seems to be a bit buggy due to some race condition...
