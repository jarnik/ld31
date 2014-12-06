
package hext;

class ExpressionGenerator 
{

	private var _actions:Array<String>;
	private var _commands:Array<String>;
	private var _switches:Array<String>;
	private var _signs:Array<String>;

	public function new():Void
	{
	    this._actions = parseArray( ",", ADMIN_ACTIONS );
	    this._commands = parseArray( ",", ADMIN_COMMANDS );
	    this._switches = parseArray( " ", SWITCHES );
	    this._signs = parseArray( " ", SIGNS );
	}

	public function getAdminAction():String
	{
	    return getRandomItem(this._actions);
	}

	public function getScan():String
	{
		var output:String = "";
		output += getX()+getRandomItem(this._signs)+" ";
		output += getX()+getRandomItem(this._signs)+" ";
		output += getX()+getRandomItem(this._signs);
	    return output;
	}

	private function getX():String
	{
	    return getRandomItem(this._commands)+" -"+getRandomItem(this._switches);
	}

	private function getRandomItem(array:Array<String>):String
	{
	    return array[ Math.floor( Math.random() * array.length ) ];
	}

	private function parseArray(delimiter:String, input:String):Array<String>
	{
		var items:Array<String> = input.split(delimiter);
		var itemsTrimmed:Array<String> = [];
		for ( i in items )
		{
			itemsTrimmed.push( StringTools.trim( i ) );
		}
	    return itemsTrimmed;
	}

	private static var ADMIN_ACTIONS:String = "facepalm, clean mouse, slap user, 
	connect mouse, connect keyboard, turn on, turn off, restart, turn on monitor, 
	maniacal laughter, watch porn, turn back, reinstall win, reboot, pray, 
	eat harmburger, drink coke, tweet, google, take selfie, take footie, 
	feet on table, sleep";

	private static var ADMIN_COMMANDS:String = "admin, alias, ar, at, batch, bc, bg, 
	cat, cd, cflow, chgrp, chmod, chown, cksum, cmp, comm, compress, cp, crontab, 
	ctags, csplit, cut, cxref, dd, delta, df, diff, dirname, du, echo, env, exfc, 
	fg, file, find, fold, fort77, fuser, gencat, deadcat, getconf, grep, hash, 
	id, ipcrm, ipcs, jobs, kill, lex, lexlutor, link, in, locale, logger, logname, 
	lp, ls, m4, mailx, make, man, woman,  mesg, mkdir, mkfile, more, mv, nice, guy, nl, 
	nm, od, odd, paste, patch, pax, pox, pr, prs, qalter, qdel, qhold, qmove, qmsg, qrerun, 
	qrls, qselect, renice, rm, rmdir, sact, sccs, split, tail, tee, time, touch, tput, tr, 
	tty, ulimit, umask, unalias, unget, uniq, uucp, uustat, uux, val, vi, wc, what, who, 
	where, when, xargs, yacc, zcat, xowl";

	private static var SWITCHES:String = "a b c d e f g h i j k l m n o p q r s t u v w x y z";	

	private static var SIGNS:String = "; | > < &";	

}