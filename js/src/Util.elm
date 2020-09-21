module Util exposing (..)

import Json.Decode as D

type ErrorResponse = List String

endpoint : String
endpoint = "/api/"

homepoint : String
homepoint = "/rel-cool"

decodeSuccess : D.Decoder Bool
decodeSuccess = D.field "success" D.bool
