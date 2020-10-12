module Util exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

import Json.Decode as D
import Json.Encode as E

type ErrorResponse = List String

endpoint : String
endpoint = "/api/"

homepoint : String
homepoint = "/rel-cool"

decodeSuccess : D.Decoder Bool
decodeSuccess = D.field "success" D.bool

encodeItem item = E.object
             [ ( "text", E.string item.text )
             , ( "url", E.string item.url )
             ]

loadingDiv = [ h1 [class "title has-text-centered"] [text "Loading..."]
             , progress [class "progress is-primary is-large"] []
             ]
