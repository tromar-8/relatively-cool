module Page.ShowCase exposing (Model, Msg, init, view, update)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as D
import Json.Encode as E
import Http
import Task
import Markdown

import Util
import Auth

type Model = Loading | Got
    { projects : List Project
    , target : Maybe (Int, Action)
    , error : String
    }

type Action = Edit | Delete

type alias Project =
    { id : Int
    , name : String
    , url : String
    , description : String
    }

newProject = Project 0 "" "" ""
getTargetProject model = let mp = model.projects
                             unwrapId default function = Maybe.withDefault default <| Maybe.map (\(id, _) -> function id) model.target
                             mId = unwrapId 0 (\id -> id)
                         in Maybe.withDefault newProject <| List.head <| List.filter (\p -> p.id == mId) mp


type Msg = GotProjects (Result Http.Error (List Project))
         | GotProject (Result Http.Error Bool)
         | SetProject
         | ConfirmDelete
         | DeleteProject (Result Http.Error Bool)
         | SetTarget (Maybe (Int, Action))
         | NameInput String
         | UrlInput String
         | DescriptionInput String

update msg wModel =
    case wModel of
        Loading -> case msg of
                       GotProjects _ -> update msg <| Got {projects = [], target = Nothing, error = ""}
                       _ -> (wModel, Cmd.none)
        Got model ->
            let mp = model.projects
                unwrapId default function = Maybe.withDefault default <| Maybe.map (\(id, _) -> function id) model.target
                mId = unwrapId 0 (\id -> id)
            in case msg of
                   GotProjects result -> (Got {model | projects = Result.withDefault [] result}, Cmd.none)
                   GotProject result -> case Result.withDefault False result of
                                            True -> (Got { model | target = Nothing}, Cmd.none)
                                            False -> (Got { model | error = "Could not update"}, Cmd.none)
                   SetTarget target -> (Got { model | target = target }, Cmd.none)
                   ConfirmDelete -> (Got model, unwrapId Cmd.none deleteProject)
                   DeleteProject result -> case Result.withDefault False result && mId /= 0 of -- id 0 is fail
                                               True -> (Got { model | projects = List.filter (\p -> p.id /= mId) mp
                                                        , target = Nothing}, Cmd.none)
                                               False -> (Got model, Cmd.none) -- error
                   NameInput name -> (Got { model
                                          | projects = getTargetProject model
                                          |> \p -> { p | name = name }
                                          |> \p2 -> p2 :: List.filter (\p3 -> p3.id /= mId) mp
                                      }
                                     , Cmd.none)
                   UrlInput url -> (Got { model
                                        | projects = getTargetProject model
                                        |> \p -> { p | url = url }
                                        |> \p2 -> p2 :: List.filter (\p3 -> p3.id /= mId) mp
                                    }
                                   , Cmd.none)
                   DescriptionInput description -> (Got { model
                                                        | projects = getTargetProject model
                                                        |> \p -> { p | description = description }
                                                        |> \p2 -> p2 :: List.filter (\p3 -> p3.id /= mId) mp
                                                    }
                                                   , Cmd.none)
                   SetProject -> (Got model, setProject <| getTargetProject model)

view wModel auth = case wModel of
                      Loading -> div [class "columns"]
                                 [ div [ class "column is-narrow container" ] Util.loadingDiv
                                 ]
                      Got model ->
                          div [] [ div [] (List.map (viewProject auth) model.projects)
                                 , if Auth.isAdmin auth
                                   -- New Project Button
                                   then div [class "container"]
                                       [ div [class "level"]
                                             [ div [ class "level-item has-text-centered" ]
                                                   [ button [class "button is-primary", onClick <| SetTarget <| Just (0, Edit)] [text "New Project"]
                                                   ]
                                             ]
                                       ]
                                   else div [] []
                                 , Maybe.withDefault (div [] [])
                                     <| Maybe.map
                                         (viewAction <<
                                         \(id, action) -> (getTargetProject model, action)
                                         )
                                         <| model.target
                                 ]

viewProject auth project = div [class "hero section"]
                           [ div [class "hero-body box"]
                                 [ h1 [class "title"] [a [href project.url] [text project.name]]
                                 , p [class "subtitle"] [Markdown.toHtml [class "content"] project.description]
                                 , div [class "buttons"]
                                     <| a [class "button is-primary", href project.url] [text "Visit"] ::
                                 ( if Auth.isAdmin auth
                                   then [ button [class "button"
                                                 , onClick <| SetTarget <| Just (project.id, Edit)
                                                 ] [text "Edit"]
                                        , button [class "button is-danger"
                                                 , onClick <| SetTarget <| Just (project.id, Delete)
                                                 ] [text "Delete"]]
                                   else [])
                                 ]
                           ]

viewAction (project, action) = div [class "modal is-active"]
                          [ div [class "modal-background", onClick <| SetTarget Nothing ] []
                          , div [ class "modal-content"]
                              [case action of
                                   Edit -> editProject project
                                   Delete -> div [class "box has-text-centered"]
                                             [ p [class "title"] [text "Confirm:"]
                                             , div [class "buttons is-centered"]
                                                 [ button [class "button is-danger", onClick <| ConfirmDelete] [text "Delete"]
                                                 , button [class "button is-success", onClick <| SetTarget Nothing] [text "Cancel"]
                                                 ]
                                             ]
                              ]
                          , button [class "modal-close is-large", onClick <| SetTarget Nothing] []
                          ]

editProject project = div [class "level"]
                      [ div [ class "level-item has-text-centered" ]
                            [ Html.form [class "container box", onSubmit SetProject]
                                  [ div [class "field"]
                                        [ label [class "label"] [text "Site Title:"]
                                        , div [class "control"] [ input [ class "input"
                                                                        , type_ "text"
                                                                        , placeholder "title"
                                                                        , onInput NameInput
                                                                        , value project.name
                                                                        ] []
                                                                ]
                                        ]
                                  , div [class "field"]
                                        [ label [class "label"] [text "Site URL:"]
                                        , div [class "control"] [ input [ class "input"
                                                                        , type_ "text"
                                                                        , placeholder "url"
                                                                        , onInput UrlInput
                                                                        , value project.url
                                                                        ] []
                                                                ]
                                        ]
                                  , div [class "field"]
                                        [ label [class "label"] [text "Site Description:"]
                                        , div [class "control"] [ textarea [ class "textarea"
                                                                           , placeholder "description"
                                                                           , onInput DescriptionInput
                                                                           , value project.description
                                                                           ] []
                                                                ]
                                        ]
                                  , button [class "button is-primary"] [text "Submit"]
                                  ]
                            ]
                      ]

deleteProject id = Http.post { body = Http.jsonBody <| E.object
                                  [ ("id", E.int id)
                                  ]
                             , url = Util.endpoint ++ "showcase/delete"
                             , expect = Http.expectJson DeleteProject Util.decodeSuccess
                             }

getProjects = Http.get { expect = Http.expectJson GotProjects decodeProjects, url = Util.endpoint ++ "showcase" }

setProject project = Http.post { expect = Http.expectJson GotProject Util.decodeSuccess
                    , body = Http.jsonBody <| E.object
                             [ ( "id", E.int project.id )
                             , ( "name", E.string project.name )
                             , ( "url", E.string project.url )
                             , ( "description", E.string project.description )
                             ]
                    , url = Util.endpoint ++ "showcase"
                    }

init : (Model, Cmd Msg)
init = (Loading, getProjects)

decodeProjects = D.list decodeProject

decodeProject = D.map4 Project
                 (D.field "id" D.int)
                 (D.field "name" D.string)
                 (D.field "url" D.string)
                 (D.field "description" D.string)
