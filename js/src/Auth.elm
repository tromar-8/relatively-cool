module Auth exposing (navWidget, init, update, isAdmin, Msg(..), Model(..))

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D
import Json.Encode as E
import Browser.Navigation as Nav

import Util

type Msg = WhoAmIResponse (Result Http.Error AuthResponse)
         | Login
         | Logout
         | Register
         | NameInput String
         | PassInput String
         | Pass2Input String
         | SwitchTab Tab

type Model = Authenticating
           | Guest LoginForm (List Roles)
           | User String (List Roles)

type Roles = Admin

type alias LoginForm =
    { tab : Tab
    , inputUser : String
    , inputPass : String
    , inputPass2 : String
    , error : Maybe String
    }

type Tab = RegisterTab | LoginTab

type alias AuthResponse =
    { username : Maybe String
    , roles : List Roles
    , error : Maybe String
    }

init : (Model, Cmd Msg)
init = (Authenticating, checkAuth)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
                       WhoAmIResponse result -> let authResponse = Result.withDefault (AuthResponse Nothing [] (Just "Generic error, not good!")) result
                                                in case authResponse.username of
                                                       Just name -> (User name authResponse.roles, Cmd.none)
                                                       Nothing -> case model of
                                                                      Guest form roles -> (Guest { form | error = authResponse.error } roles, Cmd.none)
                                                                      _ -> (Guest (LoginForm LoginTab "" "" "" authResponse.error) [], Cmd.none)
                       Login -> case model of
                                    Guest loginForm roles ->
                                        (Authenticating, Http.post
                                             { body = Http.jsonBody <| E.object
                                                   [ ( "username", E.string loginForm.inputUser )
                                                   , ( "password", E.string loginForm.inputPass )]
                                             , expect = Http.expectJson WhoAmIResponse decodeAuth
                                             , url = Util.endpoint ++ "login"
                                             }
                                        )
                                    _ -> (model, Cmd.none)
                       Logout -> (Authenticating, Cmd.batch
                                      [ Http.get
                                            { url = Util.endpoint ++ "logout"
                                            , expect = Http.expectJson WhoAmIResponse decodeAuth
                                            }
                                      ]
                                 )
                       Register -> case model of
                                       Guest loginForm roles ->
                                           (model, Http.post
                                                { body = Http.jsonBody <| E.object
                                                      [ ( "username", E.string loginForm.inputUser )
                                                      , ( "password", E.string loginForm.inputPass )
                                                      , ( "confirm", E.string loginForm.inputPass2 )
                                                      ]
                                                , expect = Http.expectJson WhoAmIResponse decodeAuth
                                                , url = Util.endpoint ++ "register"
                                                }
                                           )
                                       _ -> (model, Cmd.none)
                       NameInput name -> case model of
                                             Guest loginForm roles -> (Guest { loginForm | inputUser = name } roles, Cmd.none)
                                             _ -> (model, Cmd.none)
                       PassInput pass -> case model of
                                             Guest loginForm roles -> (Guest { loginForm | inputPass = pass } roles, Cmd.none)
                                             _ -> (model, Cmd.none)
                       Pass2Input pass -> case model of
                                             Guest loginForm roles -> (Guest { loginForm | inputPass2 = pass } roles, Cmd.none)
                                             _ -> (model, Cmd.none)
                       SwitchTab tab -> case model of
                                             Guest loginForm roles -> (Guest { loginForm | tab = tab } roles, Cmd.none)
                                             _ -> (model, Cmd.none)

checkAuth : Cmd Msg
checkAuth = Http.get { expect = Http.expectJson WhoAmIResponse decodeAuth, url = Util.endpoint ++ "whoami" }

decodeAuth : D.Decoder AuthResponse
decodeAuth = D.map3 AuthResponse
             (D.maybe <| D.field "username" D.string)
             (D.andThen (\roles -> D.succeed (if List.member "admin" roles
                                              then [Admin]
                                              else [])
                        ) <| D.field "roles" <| D.list D.string)
             (D.maybe <| D.field "error" D.string)

navWidget model =
    case model of
        Authenticating -> [ div [class "navbar-item"] [text "Authenticating..."] ]
        Guest form roles ->
            let (tab, buttonText) = (case form.tab of
                                         LoginTab -> (Login, "Login")
                                         RegisterTab -> (Register, "Register")
                                    )
            in [ div [ class "navbar-item is-hoverable has-dropdown" ]
                     [ div [class "navbar-link"] [text "Log In / Register"]
                     , div [class "navbar-dropdown"]
                         [ div [class "navbar-item"]
                               [ div [class "tabs"]
                                     [ ul []
                                           [ li [ class <| if form.tab == LoginTab then "is-active" else "" ]
                                                 [ a [ href "#", onClick <| SwitchTab LoginTab ] [text "Login"]]
                                           , li [ class <| if form.tab == RegisterTab then "is-active" else "" ]
                                               [ a [ href "#", onClick <| SwitchTab RegisterTab ] [text "Register"]]
                                           ]
                                     ]
                               ]
                         , Maybe.withDefault (div [] [])
                             <| Maybe.map (\error -> div [class "navbar-item"] [p [class "help is-danger"] [text error]]) form.error
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
                               , if form.tab == RegisterTab
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
               , a [class "navbar-item", href "/settings" ] [ text "⚙️ Settings" ]
               ]
        User name roles -> [ a [class "navbar-item", href "/settings"] [text <| name++" ⚙️"]
                           , a [class "navbar-item", onClick Logout, href "#"] [text "Logout"]
                           ]

isAdmin model = case model of
                    User name roles -> List.member Admin roles
                    _ -> False
