module Project exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as D
import Json.Encode as E
import Http
import Task

import Util
import Auth exposing (Auth(..))

type alias Model =
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

update msg model = let mp = model.projects
                       unwrapId default function = Maybe.withDefault default <| Maybe.map (\(id, _) -> function id) model.target
                       mId = unwrapId 0 (\id -> id)
                   in case msg of
                       GotProjects result -> ({model | projects = Result.withDefault [] result}, Cmd.none)
                       GotProject result -> case Result.withDefault False result of
                                                True -> ({ model | target = Nothing}, Cmd.none)
                                                False -> ({ model | error = "Could not update"}, Cmd.none)
                       SetTarget target -> ({ model | target = target }, Cmd.none)
                       ConfirmDelete -> (model, unwrapId Cmd.none deleteProject)
                       DeleteProject result -> case Result.withDefault False result && mId /= 0 of -- id 0 is fail
                                                   True -> ({ model | projects = List.filter (\p -> p.id /= mId) mp
                                                            , target = Nothing}, Cmd.none)
                                                   False -> (model, Cmd.none) -- error
                       NameInput name -> ({ model
                                              | projects = getTargetProject model
                                              |> \p -> { p | name = name }
                                              |> \p2 -> p2 :: List.filter (\p3 -> p3.id /= mId) mp
                                          }
                                         , Cmd.none)
                       UrlInput url -> ({ model
                                              | projects = getTargetProject model
                                              |> \p -> { p | url = url }
                                              |> \p2 -> p2 :: List.filter (\p3 -> p3.id /= mId) mp
                                          }
                                         , Cmd.none)
                       DescriptionInput description -> ({ model
                                              | projects = getTargetProject model
                                              |> \p -> { p | description = description }
                                              |> \p2 -> p2 :: List.filter (\p3 -> p3.id /= mId) mp
                                          }
                                         , Cmd.none)
                       SetProject -> (model, setProject <| getTargetProject model)

viewProjects model auth = div [] [ div [class "columns is-multiline"] <| List.map (viewProject auth) model.projects
                                         , case auth of
                                               -- New Project Button
                                               Admin _ -> div [class "container"]
                                                          [ div [class "level"]
                                                                [ div [ class "level-item has-text-centered" ]
                                                                      [ button [class "button is-primary", onClick <| SetTarget <| Just (0, Edit)] [text "New Project"]
                                                                      ]
                                                                ]
                                                          ]
                                               _ -> div [] []
                                         , Maybe.withDefault (div [] [])
                                             <| Maybe.map
                                                 (viewAction <<
                                                 \(id, action) -> (getTargetProject model, action)
                                                 )
                                             <| model.target
                                         ]

viewProject auth project = div [class "column container box content has-text-centered is-5"]
                      [ h1 [class "title"] [a [href project.url] [text project.name]]
                      , p [class "subtitle"] [text project.description]
                      , div [class "buttons is-centered"]
                          <| a [class "button is-primary", href project.url] [text "Visit"] ::
                              (case auth of
                                   Admin _ -> [ button [class "button"
                                                       , onClick <| SetTarget <| Just (project.id, Edit)
                                                       ] [text "Edit"]
                                              , button [class "button is-danger"
                                                       , onClick <| SetTarget <| Just (project.id, Delete)
                                                       ] [text "Delete"]]
                                   _ -> [])
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
                                        , div [class "control"] [ input [ class "input"
                                                                        , type_ "text"
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
                             , url = Util.endpoint ++ "project/delete"
                             , expect = Http.expectJson DeleteProject Util.decodeSuccess
                             }

getProjects = Http.get { expect = Http.expectJson GotProjects decodeProjects, url = Util.endpoint ++ "project" }

setProject project = Http.post { expect = Http.expectJson GotProject Util.decodeSuccess
                    , body = Http.jsonBody <| E.object
                             [ ( "id", E.int project.id )
                             , ( "name", E.string project.name )
                             , ( "url", E.string project.url )
                             , ( "description", E.string project.description )]
                    , url = Util.endpoint ++ "project"
                    }

init : (Model, Cmd Msg)
init = (Model [] Nothing "", getProjects)

decodeProjects = D.list decodeProject

decodeProject = D.map4 Project
                 (D.field "id" D.int)
                 (D.field "name" D.string)
                 (D.field "url" D.string)
                 (D.field "description" D.string)
