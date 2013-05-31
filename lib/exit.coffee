# oauthd
# http://oauth.io
#
# Copyright (c) 2013 thyb, bump
# Licensed under the MIT license.

async = require 'async'

closing_stack = []
closing = false

# clean exit when possible
cleanExit = (killer) ->
	closing = true
	k = setTimeout (->
		console.error '--- FORCING STOP'
		process.kill process.pid
	), 5000
	async.series closing_stack, (err, res) ->
		console.log '--- successfully closed !'
		setTimeout killer, 100

# nodemon restarting
process.once 'SIGUSR2', ->
	console.log '--- closing server...'
	cleanExit -> process.kill process.pid, 'SIGUSR2'

# uncaught exception catching
process.on 'uncaughtException', (err) ->
	if closing
		console.error '--- uncaughtException WHILE CLOSING'
	else
		console.error '--- uncaughtException'
	console.error err.stack.toString()
	console.error '--- node exiting now...'
	if closing
		process.exit 2
	else
		cleanExit -> process.exit 1

# push a closing function
exports.push = (name, f) ->
	closing_stack.push (callback) ->
		console.log 'Closing `' + name + '`...'
		f callback
