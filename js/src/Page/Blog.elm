module Page.Blog exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D
import Json.Encode as E

import Auth exposing (Auth(..))
import Util

type alias Model =
    { posts : List Post
    , target : Maybe (Post, Action)
    }

type Msg = GotPosts (Result Http.Error (List Post))
         | GotSuccess (Result Http.Error Bool)
         | SetPost
         | SetTarget (Maybe (Int, Action))
         | ConfirmDelete
         | ContentInput String

type alias Post =
    { id : Int
    , author : String
    , date : String
    , content : String
    }

type Action = Edit | Delete

init : (Model, Cmd Msg)
init = (Model [] Nothing, getIndex)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
                       GotPosts result -> ({ model | posts = Result.withDefault [] result}, Cmd.none)
                       GotSuccess result -> ({ model | target = Nothing }, Cmd.none)
                       SetTarget mTarget -> ({ model | target = Maybe.map (targetPost model.posts) mTarget}, Cmd.none)
                       SetPost -> Maybe.withDefault (model, Cmd.none) <| Maybe.map (\(post, _) -> (model, setPost post)) model.target
                       ConfirmDelete -> Maybe.withDefault (model, Cmd.none) <| Maybe.map (\(post, _) -> (model, deletePost post)) model.target
                       ContentInput content -> ({ model | target = Maybe.map (\(post, action) -> ({ post | content = content }, action)) model.target}, Cmd.none)

newPost : Post
newPost = Post 0 "" "" ""

getIndex : Cmd Msg
getIndex = Http.get
           { url = Util.endpoint ++ "blog"
           , expect = Http.expectJson GotPosts decodePosts
           }

setPost : Post -> Cmd Msg
setPost post = Http.post
          { url = Util.endpoint ++ "blog"
          , body = Http.jsonBody <| E.object
                   [ ("id", E.int post.id )
                   , ("content", E.string post.content)
                   ]
          , expect = Http.expectJson GotSuccess <| D.field "success" D.bool
          }

deletePost : Post -> Cmd Msg
deletePost post = Http.post
                  { url = Util.endpoint ++ "blog/delete"
                  , body = Http.jsonBody <| E.object
                           [ ("id", E.int post.id )
                           ]
                  , expect = Http.expectJson GotSuccess <| D.field "success" D.bool
                  }

decodePosts : D.Decoder (List Post)
decodePosts = D.list <| D.map4 Post
              (D.field "id" D.int)
              (D.field "author" D.string)
              (D.field "date" <| D.field "date" D.string)
              (D.field "content" D.string)


viewBlogs : Model -> Auth.Auth -> Html Msg
viewBlogs model auth = div [class "container"]
                       [ div [class "columns is-multiline"] (List.map (viewPost auth) model.posts)
                       , case auth of
                             Guest -> div [] []
                             _ -> div [class "container"]
                                  [ div [class "level"]
                                        [ div [ class "level-item has-text-centered" ]
                                              [ button [class "button is-primary", onClick <| SetTarget <| Just (0, Edit)] [text "New Post"]
                                              ]
                                        ]
                                  ]
                       , Maybe.withDefault (div [] [])
                           <| Maybe.map (viewAction auth) model.target
                       ]

viewPost : Auth.Auth -> Post -> Html Msg
viewPost auth post = div [class "container column is-10 box"]
                      [ text post.content
                      , br [] []
                      , span [class "tag is-dark"] [text post.author], span [class "tag is-gray"] [text <| String.left 10 post.date]
                      , div [class "buttons is-centered"]
                          (case auth of
                               Admin _ -> [ button [class "button"
                                                   , onClick <| SetTarget <| Just (post.id, Edit)
                                                   ] [text "Edit"]
                                          , button [class "button is-danger"
                                                   , onClick <| SetTarget <| Just (post.id, Delete)
                                                   ] [text "Delete"]
                                          ]
                               _ -> [])
                      ]

viewAction : Auth.Auth -> (Post, Action) -> Html Msg
viewAction auth (post, action) = div [class "modal is-active"]
                          [ div [class "modal-background", onClick <| SetTarget Nothing ] []
                          , div [ class "modal-content"]
                              [case action of
                                   Edit -> editPost post
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

editPost : Post -> Html Msg
editPost post = div [class "level"]
                [ div [ class "level-item has-text-centered" ]
                      [ Html.form [class "container box", onSubmit SetPost]
                            [ div [class "field"]
                                [ label [class "label"] [text "Post content:"]
                                , div [class "control"] [ input [ class "input"
                                                                , type_ "text"
                                                                , placeholder "markdown"
                                                                , onInput ContentInput
                                                                , value post.content
                                                                ] []
                                                        ]
                                ]
                            , button [class "button is-primary"] [text "Submit"]
                            ]
                      ]
                ]


targetPost : List Post -> (Int, Action) -> (Post, Action)
targetPost posts (id, action) = (Maybe.withDefault newPost <| List.head <| List.filter (\p -> p.id == id) posts, action)
