module Auth exposing (navWidget, newModel, checkAuth, update, Msg(..), Model, Auth(..))

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D
import Json.Encode as E
import Browser.Navigation as Nav

import Util

type Msg = WhoAmIResponse (Result Http.Error (Auth, Maybe String))
         | Login
         | Logout
         | Register
         | NameInput String
         | PassInput String
         | Pass2Input String
         | SwitchTab Tab

type alias Model =
    { auth : Auth
    , tab : Tab
    , inputUser : String
    , inputPass : String
    , inputPass2 : String
    , error : Maybe String
    }

type Auth = Guest | User String | Admin String

type Tab = RegisterTab | LoginTab

newModel : Model
newModel = Model Guest LoginTab "" "" "" Nothing

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
                       WhoAmIResponse result -> let (auth, error) = Result.withDefault (Guest, Just "Did not authenticate") result
                                                in ({ model | auth = auth, error = error }, Cmd.none)
                       Login -> (model, Http.post
                                     { body = Http.jsonBody <| E.object
                                           [ ( "username", E.string model.inputUser )
                                           , ( "password", E.string model.inputPass )]
                                     , expect = Http.expectJson WhoAmIResponse decodeAuth
                                     , url = Util.endpoint ++ "login"
                                     }
                                )
                       Logout -> (model, Cmd.batch
                                      [ Http.get
                                            { expect = Http.expectJson WhoAmIResponse decodeAuth
                                            , url = Util.endpoint ++ "logout"
                                            }
                                      , Nav.load "/"
                                      ]
                                 )
                       Register -> (model, Http.post
                                        { body = Http.jsonBody <| E.object
                                              [ ( "username", E.string model.inputUser )
                                              , ( "password", E.string model.inputPass )
                                              , ( "confirm", E.string model.inputPass2 )
                                              ]
                                        , expect = Http.expectJson WhoAmIResponse decodeAuth
                                        , url = Util.endpoint ++ "register"
                                        }
                                   )
                       NameInput name -> ({ model | inputUser = name }, Cmd.none)
                       PassInput pass -> ({ model | inputPass = pass }, Cmd.none)
                       Pass2Input pass -> ({ model | inputPass2 = pass }, Cmd.none)
                       SwitchTab tab -> ({ model | tab = tab }, Cmd.none)

checkAuth : Cmd Msg
checkAuth = Http.get { expect = Http.expectJson WhoAmIResponse decodeAuth, url = Util.endpoint ++ "whoami" }

decodeAuth : D.Decoder (Auth, Maybe String)
decodeAuth = D.field "success" D.bool
           |> D.andThen (\success ->
                             if success
                             then D.field "admin" D.bool |>
                             D.andThen (\admin ->
                                            D.map2 (\a -> \b -> (a, b))
                                            (D.map (if admin then Admin else User) <| D.field "name" D.string)
                                            (D.succeed Nothing)
                                       )
                             else D.map2 (\a -> \b -> (a,b))
                                 (D.succeed Guest)
                                 (D.maybe <| D.field "error" D.string)
                        ) -- TODO LESS MAPPING

navWidget model = let ifCheck check true false = if check then true else false
                      (tab, buttonText) = (case model.tab of
                                               LoginTab -> (Login, "Login")
                                               RegisterTab -> (Register, "Register")
                                          )
                  in case model.auth of
                         Guest -> [ div [ class "navbar-item is-hoverable has-dropdown" ]
                                        [ div [class "navbar-link"] [text "Log In / Register"]
                                        , div [class "navbar-dropdown"]
                                            [ div [class "navbar-item"]
                                                  [ div [class "tabs"]
                                                        [ ul []
                                                              [ li [ class <| ifCheck (model.tab == LoginTab) "is-active" "" ]
                                                                    [ a [ href "#", onClick <| SwitchTab LoginTab ] [text "Login"]]
                                                              , li [ class <| ifCheck (model.tab == RegisterTab) "is-active" "" ]
                                                                  [ a [ href "#", onClick <| SwitchTab RegisterTab ] [text "Register"]]
                                                              ]
                                                        ]
                                                  ]
                                            , Maybe.withDefault (div [] [])
                                                <| Maybe.map (\error -> div [class "navbar-item"] [p [class "help is-danger"] [text error]]) model.error
                                            , Html.form [onSubmit tab] [
                                                   div [class "navbar-item", onSubmit tab]
                                                       [ div [class "field"]
                                                             [ label [class "label"] [text "Username:"]
                                                             , div [class "control"] [ input [ class "input"
                                                                                             , type_ "text"
                                                                                             , placeholder "username"
                                                                                             , onInput NameInput
                                                                                             ] []]
                                                             ]
                                                       ]
                                                  , div [class "navbar-item"]
                                                       [ div [class "field"]
                                                             [ label [class "label"] [text "Password:"]
                                                             , div [class "control"] [ input [ class "input"
                                                                                             , type_ "password"
                                                                                             , placeholder "password"
                                                                                             , onInput PassInput
                                                                                             ] []]
                                                             ]
                                                       ]
                                                  , if model.tab == RegisterTab
                                                    then div [class "navbar-item"]
                                                       [ div [class "field"]
                                                             [ label [class "label"] [text "Confirm Password:"]
                                                             , div [class "control"] [ input [ class "input"
                                                                                             , type_ "password"
                                                                                             , placeholder "password"
                                                                                             , onInput Pass2Input
                                                                                             ] []]
                                                             ]
                                                       ]
                                                    else div [] []
                                                  , div [class "navbar-item"]
                                                       [ button [class "button is-primary"] [text buttonText]
                                                       ]
                                                  ]
                                            ]
                                        ]
                                  , div [class "navbar-item"] [text "Welcome, Guest!"]
                                  ]
                         User name -> [div [class "navbar-item"] [text <| "Welcome, " ++ name ++ "!"]
                                      , div [class "navbar-item"] [button [class "button", onClick Logout] [text "Logout"]]
                                      ]
                         Admin name -> [ div [class "navbar-item"] [text <| "Welcome, " ++ name ++ "!"]
                                       , div [class "navbar-item"]
                                           [ a [class "button", href "/admin"] [text "Admin"]
                                           ]
                                       , div [class "navbar-item"] [button [class "button", onClick Logout] [text "Logout"]]
                                       ]
