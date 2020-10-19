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
import Api

type Model = Loading
           | Got Settings

type alias Settings = {
        layout : Layout.Layout,
        preferences : Preferences,
        activePane : Maybe Pane
    }

type alias Preferences = {
        nightMode : Bool
    }

type Pane = LayoutPane | NavPane | FooterPane | PrefsPane

type Msg = TitleInput String
         | EmailInput String
         | SetInfo
         | GetInfo (Result Http.Error Layout.Info)
         | GetPrefs (Result Http.Error Preferences)
         | SetPane Pane
         | SetNav
         | GetNav (Result Http.Error (List Layout.Item))
         | AddNavItem
         | NightMode Bool

init auth = ( Loading
            , Cmd.batch <|
                (if Auth.isAdmin auth
                 then Cmd.batch
                     [ Api.get GetInfo Layout.decodeInfo "info"
                     ]
                 else Cmd.none
                )::
                [ Api.get GetPrefs decodePrefs "preferences"
                ]
            )

newSettings = { layout = Layout.newLayout, preferences = { nightMode = False }, activePane = Nothing}

update msg wModel = case wModel of
                       Loading -> case msg of
                                      GetInfo _ -> update msg <| Got newSettings
                                      GetPrefs _ -> update msg <| Got newSettings
                                      _ -> (wModel, Cmd.none)
                       Got model -> let layoutModel = model.layout
                                        layoutInfo = model.layout.info
                                        withError error = Got { model | layout = { layoutModel | error = error }}
                                    in case msg of
                                           TitleInput str -> (Got { model | layout = { layoutModel | info = { layoutInfo | title = str }}}, Cmd.none)

                                           EmailInput str -> (Got { model | layout = { layoutModel | info = { layoutInfo | email = str }}}, Cmd.none)

                                           SetInfo -> (Got model, Api.setBaseInfo GetInfo Layout.decodeInfo model.layout.info)

                                           GetInfo response -> let withInfo info = Got { model | layout = { layoutModel | info = info }}
                                                               in (Result.withDefault (withError <| Just ["Could not fetch site info"])
                                                                       <| Result.map withInfo response, Cmd.none)

                                           GetNav response -> (Got model, Cmd.none)

                                           SetNav -> (Got model, Api.setNav GetNav (D.list Layout.decodeItem) Layout.encodeItem model.layout.nav)

                                           AddNavItem -> (Got { model | layout = { layoutModel | nav = Layout.newItem::layoutModel.nav }}, Cmd.none)

                                           SetPane pane -> (if Maybe.withDefault False <| Maybe.map (\p -> pane == p) model.activePane
                                                            then Got { model | activePane = Nothing }
                                                            else Got { model | activePane = Just pane}, Cmd.none)
                                                   --(Got { model | layout = { layoutModel | info = response }}, Cmd.none)

                                           GetPrefs response -> let withPrefs prefs = Got { model | preferences = prefs }
                                                                in (Result.withDefault (withError <| Just ["Could not fetch user preferences"])
                                                                        <| Result.map withPrefs response, Cmd.none)

                                           NightMode bool -> (Got { model | preferences = Preferences bool }, Cmd.none)

view wModel auth = case wModel of
                       Loading -> div [class "columns"]
                                 [ div [ class "column is-narrow container" ] Util.loadingDiv
                                 ]
                       Got model -> div [ class "container" ]
                                    <| (if Auth.isAdmin auth
                                       then
                                           [ viewLayoutEdit model
                                           , viewNavPages model
                                           ]
                                       else []) ++
                                    [ viewUserPreferences model ]

viewLayoutEdit model = div [class "box"]
                       [ button [class "block button is-large is-fullwidth", onClick <| SetPane LayoutPane] [text <| "Site info:"]
                       , if Maybe.withDefault False <| Maybe.map (\pane -> LayoutPane == pane) model.activePane then
                             Html.form [ onSubmit SetInfo]
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
                                 , div [class "control"] [button [class "button is-primary"] [text "Save changes"]]
                                 ]
                         else div [] []
                       , div [class "block"] []
                       ]

viewNavPages model = div [class "box"]
                     [ button [class "block button is-large is-fullwidth", onClick <| SetPane NavPane] [text <| "Navbar pages:"]
                     , if Maybe.withDefault False <| Maybe.map (\pane -> NavPane == pane) model.activePane then
                           Html.form [ onSubmit SetNav ]
                               [ div [] <| List.map viewItemEdit model.layout.nav
                               , div [class "control"] [button [class "button", onClick AddNavItem ] [text "Add item"]]
                               , div [class "control"] [button [class "button is-primary"] [text "Save changes"]]
                               ]
                       else div [] []
                     , div [class "block"] []
                     ]

viewItemEdit item = case item of
                        Layout.Link ref str -> div [] [ div [ class "field"]
                                                     [ label [class "label"] [text "Item text:"]
                                                     , div [class "control"] [ input [ class "input"
                                                                                     , type_ "text"
                                                                                     , placeholder "text"
                                                                                     , value str
                                                                                     ] []
                                                                             ]
                                                     ]
                                               , div [ class "field" ]
                                                   [ label [class "label"] [text "Item URL:"]
                                                   , div [class "control"] [ input [ class "input"
                                                                                   , type_ "text"
                                                                                   , placeholder "url"
                                                                                   , value ref
                                                                                   ] []
                                                                           ]
                                                   ]
                                               ]
                        Layout.Text str -> p [class "tag is-dark is-medium"] [ text str ]

viewUserPreferences model = div [class "box"]
                       [ button [class "block button is-large is-fullwidth", onClick <| SetPane PrefsPane] [text <| "User preferences:"]
                       , if Maybe.withDefault False <| Maybe.map (\pane -> PrefsPane == pane) model.activePane then
                             div [class "block"]
                                 [ div [class "field" ]
                                       [ div [class "control"]
                                             [ label [class "checkbox"]
                                                   [ input [ type_ "checkbox"
                                                           , onCheck NightMode
                                                           ] []
                                                   , b [] [text " purposeless check box"]
                                                   ]
                                             ]
                                       ]
                                 ]
                         else div [] []
                       ]

decodePrefs = D.map Preferences
              (D.field "night-mode" D.bool)
