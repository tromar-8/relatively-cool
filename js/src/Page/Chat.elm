module Page.Chat exposing (Model, Msg, init, update, view)

import Html exposing (..)

type Msg = NaDa

type alias Model = {
    }

init = ({}, Cmd.none)

update msg model = (model, Cmd.none)

view model auth = div [] [text "Chat"]
