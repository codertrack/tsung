%%%
%%%  Copyright � IDEALX S.A.S. 2004
%%%
%%%	 Author : Nicolas Niclausse <nicolas.niclausse@IDEALX.com>
%%%  Created: 20 Apr 2004 by Nicolas Niclausse <nicolas.niclausse@IDEALX.com>
%%%
%%%  This program is free software; you can redistribute it and/or modify
%%%  it under the terms of the GNU General Public License as published by
%%%  the Free Software Foundation; either version 2 of the License, or
%%%  (at your option) any later version.
%%%
%%%  This program is distributed in the hope that it will be useful,
%%%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%%%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%%  GNU General Public License for more details.
%%%
%%%  You should have received a copy of the GNU General Public License
%%%  along with this program; if not, write to the Free Software
%%%  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
%%% 

-module(ts_config_jabber).
-vc('$Id$ ').
-author('nicolas.niclausse@IDEALX.com').

-export([parse_config/2 ]).

-include("ts_profile.hrl").
-include("ts_jabber.hrl").
-include("ts_config.hrl").

-include_lib("xmerl/inc/xmerl.hrl").


%%----------------------------------------------------------------------
%% Func: parse_config/2
%% Args: Element, Config
%% Returns: List
%% Purpose: parse a request defined in the XML config file
%%----------------------------------------------------------------------
%% TODO: Dynamic content substitution is not yet supported for Jabber
parse_config(Element = #xmlElement{name=jabber}, 
             Config=#config{curid= Id, session_tab = Tab,
                            sessions = [CurS |SList]}) ->
    TypeStr  = ts_config:getAttr(Element#xmlElement.attributes, type, "chat"),
    AckStr  = ts_config:getAttr(Element#xmlElement.attributes, ack, "no_ack"),
    DestStr= ts_config:getAttr(Element#xmlElement.attributes, destination,"random"),
    SizeStr= ts_config:getAttr(Element#xmlElement.attributes, size,"0"),
    Type= list_to_atom(TypeStr),
    Size= list_to_integer(SizeStr),
    Dest= list_to_atom(DestStr),
    Ack = list_to_atom(AckStr),

	Domain  =ts_config:get_default(Tab, jabber_domain_name, jabber_domain),
	UserName=ts_config:get_default(Tab, jabber_username, jabber_username),
	Passwd  =ts_config:get_default(Tab, jabber_passwd, jabber_passwd),

	Msg=#ts_request{ack   = Ack,
                    endpage = true,
                    param = #jabber{domain = Domain,
                                    username = UserName,
                                    passwd = Passwd,
                                    type   = Type,
                                    dest   = Dest,
                                    size   = Size
							   }
				},
    ts_config:mark_prev_req(Id-1, Tab, CurS),
    ets:insert(Tab,{{CurS#session.id, Id}, Msg}),
    lists:foldl( fun(A,B) -> ts_config:parse(A,B) end,
                 Config#config{},
                 Element#xmlElement.content);
%% Parsing default values
parse_config(Element = #xmlElement{name=default}, Conf = #config{session_tab = Tab}) ->
    case ts_config:getAttr(Element#xmlElement.attributes, name) of
        "username" ->
            Val = ts_config:getAttr(Element#xmlElement.attributes, value),
            ets:insert(Tab,{{jabber_username,value}, Val});
        "passwd" ->
            Val = ts_config:getAttr(Element#xmlElement.attributes, value),
            ets:insert(Tab,{{jabber_passwd,value}, Val});
        "domain" ->
            Val = ts_config:getAttr(Element#xmlElement.attributes, value),
            ets:insert(Tab,{{jabber_domain_name,value}, Val});
        "global_number" ->
            Val = ts_config:getAttr(Element#xmlElement.attributes, value),
            {ok, [{integer,1,N}],1} = erl_scan:string(Val),
            ts_timer:config(N),
            ets:insert(Tab,{{jabber_global_number, value}, N});
        "userid_max" ->
            Val = ts_config:getAttr(Element#xmlElement.attributes, value),
            {ok, [{integer,1,N}],1} = erl_scan:string(Val),
            ts_user_server:reset(N),
            ets:insert(Tab,{{jabber_userid_max,value}, N})
    end,
    lists:foldl( fun(A,B) -> ts_config:parse(A,B) end, Conf, Element#xmlElement.content);
%% Parsing other elements
parse_config(Element = #xmlElement{}, Conf = #config{}) ->
    lists:foldl( fun(A,B) -> ts_config:parse(A,B) end, Conf, Element#xmlElement.content);
%% Parsing non #xmlElement elements
parse_config(Element, Conf = #config{}) ->
    Conf.
