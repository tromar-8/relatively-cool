module Api exposing (..)

import Http
import Json.Encode as E

endpoint = "/api/"

get response decode path = Http.get { expect = Http.expectJson response decode, url = endpoint ++ path}

setBaseInfo response decode input = Http.post { expect = Http.expectJson response decode
                                             , body = Http.jsonBody <| E.object
                                                      [ ( "title", E.string input.title )
                                                      , ( "email", E.string input.email )
                                                      ]
                                             , url = endpoint ++ "info"
                                             }

setNav response decode encode input = Http.post { expect = Http.expectJson response decode
                                                , body = Http.jsonBody <| E.list encode input
                                                , url = endpoint ++ "nav"
                                         }
