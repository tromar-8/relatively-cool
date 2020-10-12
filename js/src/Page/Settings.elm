module Page.Settings exposing (init, view, update, Model, Msg)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Encode as E
import Json.Decode as D

import Layout
import Auth
import Util

type Model = Loading
           | Got Settings

type alias Settings = {
        layout : Layout.Layout
    }

type Msg = TitleInput String
         | EmailInput String
         | SetInfo
         | ReloadMsg (Result Http.Error (Maybe String))

init = (Loading, Cmd.none)

update msg wModel = case wModel of
                       Loading -> (wModel, Cmd.none)
                       Got model -> let layoutModel = model.layout
                                        layoutInfo = model.layout.info
                                    in case msg of
                                           TitleInput str -> (Got { model | layout = { layoutModel | info = { layoutInfo | email = str }}}, Cmd.none)
                                           EmailInput str -> (Got { model | layout = { layoutModel | info = { layoutInfo | email = str }}}, Cmd.none)
                                           SetInfo -> (Got model, setInfo model.layout.info)
                                           ReloadMsg result -> (Got model, Cmd.none)

view wModel auth = case wModel of
                       Loading -> div [class "columns"]
                                 [ div [ class "column is-narrow container" ] Util.loadingDiv
                                 ]
                       Got model -> div [ class "container box" ]
                                    [ h1 [ class "title" ] [ text "Settings:" ]
                                    , if Auth.isAdmin auth
                                      then viewToggleMenu <| viewLayoutEdit model
                                      else div [] []
                                    ]

viewLayoutEdit model = ( Html.form [class "container", onSubmit SetInfo]
                             [ div [class "field" ]
                                   [ label [class "label"] [text "Site Title:"]
                                   , div [class "control"] [ input [ class "input"
                                                                   , type_ "text"
                                                                   , placeholder "title"
                                                                   , onInput TitleInput
                                                                   , value model.layout.info.title
                                                                   ] []
                                                           ]
                                   ]
                             , div [ class "field" ]
                                   [ label [class "label"] [text "Author Email:"]
                                   , div [class "control"] [ input [ class "input"
                                                                   , type_ "text"
                                                                   , placeholder "email"
                                                                   , onInput EmailInput
                                                                   , value model.layout.info.email
                                                                   ] []
                                                           ]
                                   ]
                             ]
                       ) ::
                       (List.map viewItemEdit model.layout.nav) ++
                       (List.map viewItemEdit model.layout.footer) ++
                       [ button [class "button is-primary"] [text "Update"]
                       ]

viewToggleMenu html = div [] html

viewItemEdit item = div [] []

setInfo input = Http.post { expect = Http.expectJson ReloadMsg decodeNothing
                    , body = Http.jsonBody <| E.object
                             [ ( "title", E.string input.title )
                             , ( "email", E.string input.email )
                             ]
                    , url = Util.endpoint ++ "info"
                    }

decodeNothing = D.maybe <| D.field "error" D.string
