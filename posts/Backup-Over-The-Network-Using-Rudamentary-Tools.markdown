---
title: Backup Over the Network Using Rudamentary Tools
date: 2009-04-06
---

There are many good ways to do a backup over the network. If you are trying to backup some files in a directory or even files on a whole system rsync is a great program to have around. If however, you want a very rudimentary tool to just dump data off a hard disk, USB device or flash card to another then you probably want to use dd. With the help of ssh, dd can be used over a network to provide a bit by bit copy. However, using dd is a naive approach and will copy every single last bit from the originating device wasting both time and bandwidth. There is a better approach which uses gzip which it what I'll cover here.


# Setup Your SSH Key

First we need to do a couple of things so that when we ssh to the remote system we aren't prompted for a password. First generate an ssh key:

	ssh-keygen

Next copy that key to the remote server:

	ssh-copy-id user@host.example.com

Now we'll invoke the ssh-agent:

	ssh-agent

You should get some output that looks like the following:

	SSH_AUTH_SOCK=/tmp/ssh-cdQXi12427/agent.12427; export SSH_AUTH_SOCK;
	SSH_AGENT_PID=12428; export SSH_AGENT_PID;
	echo Agent pid 12428;

Verify that your key was added with:

	ssh-add -l

Test that you can now log in with your passphrase:

	ssh user@host.example.com

Now that you've logged in using your key and the agent is running, you will be able to log into the remote system without using a password until your session is closed.

# Performing the Backup

Now to execute the dump over the network use the following:

	ssh root@host.example.com gzip -1 -c /dev/sda \\
		| gzip -d - | sudo tee /dev/sdh > /dev/null

If you'd like to monitor the progress of your backup I've found pv to be a great tool. I modify the above line to the following when making a mirror copy of a router.

	ssh root@host.example.com gzip -1 -c /dev/sda \\
		| pv -e -r -b -s 4096m | gzip -d - \\
		| sudo tee /dev/sdh > /dev/null

This gives a nice status bar like the following:

	76MB [ 855kB/s] ETA 2:11:26

It won't end up copying all the data so the ETA is really a worst case scenario as if you were using dd instead of gzip. 
